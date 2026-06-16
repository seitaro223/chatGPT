%% BT00_2_make_current_single_tube_input.m
% BT00-2：単管側 current 入力ブックを作る
%
% 目的：
%   H52Q単管側（T&M/BMI）について、今後参照してよい入力・診断データを
%   current_single_tube_input として切り出す。
%
% 背景：
%   - r8 resultブックはレガシー・ブリッジブックとして扱い、直接読み続けない。
%   - 単管側では、T&M/BMIから直接L/D補正式を作る方向はいったん止める。
%   - ただし、x_eq、Hsub、P、履歴長/L/Dは、バンドル側へ送る診断軸として残す。
%
% 方針：
%   - r8 resultブックから、単管noF1/F1の元データを切り出す。
%   - v10/v11の真Hsub・Table8 middle診断ブックは、診断currentとして保持する。
%   - README_CURRENT / DATA_DICTIONARY_CURRENT / SOURCE_MANIFEST / QUALITY_NOTES を付ける。
%   - qMやx_Mesを補正式入力としては使わない方針を明記する。
%   - L/Dは補正式候補ではなく、診断項・履歴代理として保留する。
%
% 入力候補：
%   20260612_計算結果比較r8_result_文献追加用.xlsx
%   TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx
%   TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx
%
% 出力：
%   H52Q_current_single_tube_input_v1_yyyymmdd_HHMMSS.xlsx
%   run_report_BT00_2_current_single_tube_input_yyyymmdd_HHMMSS.md
%
% 重要：
%   このスクリプトは「補正式を作る」ためのものではない。
%   今後の参照入口を整理するためのcurrent化スクリプトである。

clear; clc;

%% ===== Settings =====

sourceResultFile = "20260612_計算結果比較r8_result_文献追加用.xlsx";
v10TrueHsubFile  = "TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx";
v11MiddleFile    = "TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx";

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "H52Q_current_single_tube_input_v1_" + timestamp + ".xlsx";
outMd   = "run_report_BT00_2_current_single_tube_input_" + timestamp + ".md";

% r8から固定的に切り出す単管元データ。
primarySheets = table( ...
    ["r8_result"; "r8_result"], ...
    [sourceResultFile; sourceResultFile], ...
    ["tm_r123_noF1_T8_14"; "tm_r124_F1_T8_14"], ...
    ["ST_noF1_T8_14_current"; "ST_F1_T8_14_current"], ...
    ["単管noF1の現行元データ。"; "単管F1の現行元データ。"], ...
    'VariableNames', {'source_group','source_file','source_sheet','current_sheet','role'} ...
);

% v10/v11は診断currentとして全シートを持ち込む。
diagnosticFiles = table( ...
    ["v10_trueHsub"; "v11_middleDecomp"], ...
    [v10TrueHsubFile; v11MiddleFile], ...
    ["V10"; "V11"], ...
    ["真Hsub付きTable8〜12診断。"; "Table8 middle低下理由分解診断。"], ...
    'VariableNames', {'source_group','source_file','sheet_prefix','role'} ...
);

%% ===== Validate files =====

requiredFiles = [sourceResultFile; v10TrueHsubFile; v11MiddleFile];
for i = 1:numel(requiredFiles)
    if ~isfile(requiredFiles(i))
        warning("Input file not found: %s", requiredFiles(i));
    end
end

%% ===== Collect and read sheets =====

manifest = table();
sheetTables = struct();
usedSheetNames = strings(0,1);
allVarNames = strings(0,1);

% --- Primary sheets ---
for i = 1:height(primarySheets)
    srcFile  = primarySheets.source_file(i);
    srcSheet = primarySheets.source_sheet(i);
    desired  = primarySheets.current_sheet(i);

    [curSheet, usedSheetNames] = makeUniqueSheetName(desired, usedSheetNames);

    [T, status, note] = tryReadSheet(srcFile, srcSheet);

    row = makeManifestRow("include_primary", primarySheets.source_group(i), srcFile, srcSheet, curSheet, ...
                          height(T), width(T), status, primarySheets.role(i) + " " + note);
    manifest = [manifest; row]; %#ok<AGROW>

    if status == "included"
        sheetTables.(matlab.lang.makeValidName(curSheet)) = T;
        allVarNames = [allVarNames; string(T.Properties.VariableNames(:))]; %#ok<AGROW>
    end
end

% --- Diagnostic files: copy all sheets ---
for i = 1:height(diagnosticFiles)
    srcFile = diagnosticFiles.source_file(i);
    prefix  = diagnosticFiles.sheet_prefix(i);

    if ~isfile(srcFile)
        row = makeManifestRow("missing_file", diagnosticFiles.source_group(i), srcFile, "", "", ...
                              NaN, NaN, "ERROR", "ファイルが見つからないため、診断シートを取り込めなかった。");
        manifest = [manifest; row]; %#ok<AGROW>
        continue;
    end

    sheets = getSheetNamesSafe(srcFile);

    if isempty(sheets)
        row = makeManifestRow("no_sheets", diagnosticFiles.source_group(i), srcFile, "", "", ...
                              NaN, NaN, "ERROR", "シート名を取得できなかった。");
        manifest = [manifest; row]; %#ok<AGROW>
        continue;
    end

    for j = 1:numel(sheets)
        srcSheet = sheets(j);
        desired = prefix + "_" + srcSheet;
        [curSheet, usedSheetNames] = makeUniqueSheetName(desired, usedSheetNames);

        [T, status, note] = tryReadSheet(srcFile, srcSheet);

        row = makeManifestRow("include_diagnostic", diagnosticFiles.source_group(i), srcFile, srcSheet, curSheet, ...
                              height(T), width(T), status, diagnosticFiles.role(i) + " " + note);
        manifest = [manifest; row]; %#ok<AGROW>

        if status == "included"
            sheetTables.(matlab.lang.makeValidName(curSheet)) = T;
            allVarNames = [allVarNames; string(T.Properties.VariableNames(:))]; %#ok<AGROW>
        end
    end
end

allVarNames = unique(allVarNames, 'stable');

%% ===== Metadata sheets =====

readme = makeReadme(sourceResultFile, v10TrueHsubFile, v11MiddleFile, outXlsx, timestamp);
dictionary = makeDataDictionary(allVarNames);
qualityNotes = makeQualityNotes();
scope = makeDiagnosticScope();
adoptHold = makeAdoptHoldRetract();

%% ===== Write current workbook =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(readme,       outXlsx, 'Sheet', 'README_CURRENT');
writetable(dictionary,   outXlsx, 'Sheet', 'DATA_DICTIONARY_CURRENT');
writetable(manifest,     outXlsx, 'Sheet', 'SOURCE_MANIFEST');
writetable(qualityNotes, outXlsx, 'Sheet', 'QUALITY_NOTES');
writetable(scope,        outXlsx, 'Sheet', 'ST_SCOPE_CURRENT');
writetable(adoptHold,    outXlsx, 'Sheet', 'ST_ADOPT_HOLD_RETRACT');

fields = string(fieldnames(sheetTables));
for i = 1:numel(fields)
    sh = fields(i);
    T = sheetTables.(sh);
    writetable(T, outXlsx, 'Sheet', sh);
    fprintf("Wrote sheet: %s\n", sh);
end

fprintf("Wrote current single-tube workbook: %s\n", outXlsx);

%% ===== Write Markdown report =====

md = strings(0,1);

md(end+1) = "# BT00-2 current single-tube input";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "単管側のT&M/BMI整理について、今後参照してよい入力・診断データを current_single_tube_input として切り出した。";
md(end+1) = "";
md(end+1) = "## 2. 入力と出力";
md(end+1) = "";
md(end+1) = "- r8 result: `" + sourceResultFile + "`";
md(end+1) = "- v10 trueHsub: `" + v10TrueHsubFile + "`";
md(end+1) = "- v11 middle decomp: `" + v11MiddleFile + "`";
md(end+1) = "- 出力: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 3. current single-tube の位置づけ";
md(end+1) = "";
md(end+1) = "- r8 resultブックを直接読み続けない。";
md(end+1) = "- 単管noF1/F1の現行元データを保持する。";
md(end+1) = "- v10/v11診断ブックを診断currentとして保持する。";
md(end+1) = "- L/D補正式は作らない。";
md(end+1) = "- L/Dは履歴代理・診断項として保留する。";
md(end+1) = "- qMおよびx_Mesは補正式入力としては使わない。";
md(end+1) = "- x_eqは前向き計算で使える状態量として、バンドル側へ送る候補にする。";
md(end+1) = "";
md(end+1) = "## 4. Source manifest";
md(end+1) = "";
md(end+1) = tableToMarkdown(manifest);
md(end+1) = "";
md(end+1) = "## 5. Diagnostic scope";
md(end+1) = "";
md(end+1) = tableToMarkdown(scope);
md(end+1) = "";
md(end+1) = "## 6. 採用・保留・撤回気味";
md(end+1) = "";
md(end+1) = tableToMarkdown(adoptHold);
md(end+1) = "";
md(end+1) = "## 7. 次アクション";
md(end+1) = "";
md(end+1) = "1. 出力された current_single_tube ブックを確認する。";
md(end+1) = "2. 問題なければ working log にBT00-2完了を追記する。";
md(end+1) = "3. 次に current_bundle 入力を使ってBT01/BT02再現、またはBT03へ進む。";
md(end+1) = "4. 単管側は補正式化せず、x_eq・履歴長をバンドル議論へ送る。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown report: %s\n", outMd);

%% ===== Display quick result =====

disp("=== SOURCE MANIFEST ===");
disp(manifest);

disp("=== SCOPE ===");
disp(scope);

%% ===== Local functions =====

function [T, status, note] = tryReadSheet(srcFile, srcSheet)
    T = table();
    status = "ERROR";
    note = "";

    if strlength(srcFile) == 0 || ~isfile(srcFile)
        note = "ファイルが存在しない。";
        return;
    end

    if strlength(srcSheet) == 0
        note = "シート名が空。";
        return;
    end

    try
        opts = detectImportOptions(srcFile, 'Sheet', srcSheet);
        opts.VariableNamingRule = 'preserve';
        T = readtable(srcFile, opts);
        status = "included";
        note = "readtable成功。";
    catch ME
        T = table();
        status = "ERROR";
        note = string(ME.message);
    end
end

function sheets = getSheetNamesSafe(srcFile)
    sheets = strings(0,1);
    try
        sheets = string(sheetnames(srcFile));
    catch
        try
            [~, s] = xlsfinfo(srcFile);
            sheets = string(s);
        catch
            sheets = strings(0,1);
        end
    end
end

function row = makeManifestRow(action, source_group, source_file, source_sheet, current_sheet, n_rows, n_cols, read_status, note)
    row = table();
    row.action = string(action);
    row.source_group = string(source_group);
    row.source_file = string(source_file);
    row.source_sheet = string(source_sheet);
    row.current_sheet = string(current_sheet);
    row.n_rows = n_rows;
    row.n_cols = n_cols;
    row.read_status = string(read_status);
    row.note = string(note);
end

function [outName, usedNames] = makeUniqueSheetName(rawName, usedNames)
    outName = string(rawName);

    if strlength(outName) == 0
        outName = "Sheet";
    end

    outName = regexprep(outName, '[:\\/\?\*\[\]]', '_');
    outName = replace(outName, " ", "_");
    outName = replace(outName, newline, "_");

    if strlength(outName) > 31
        outName = extractBefore(outName, 32);
    end

    base = outName;
    k = 2;
    while any(usedNames == outName)
        suffix = "_" + string(k);
        maxLen = 31 - strlength(suffix);
        if strlength(base) > maxLen
            outName = extractBefore(base, maxLen + 1) + suffix;
        else
            outName = base + suffix;
        end
        k = k + 1;
    end

    usedNames(end+1,1) = outName;
end

function readme = makeReadme(sourceResultFile, v10TrueHsubFile, v11MiddleFile, outXlsx, timestamp)
    item = strings(0,1);
    value = strings(0,1);

    add("book_type", "H52Q current single-tube input");
    add("created_at", timestamp);
    add("output_file", outXlsx);
    add("source_result_file", sourceResultFile);
    add("source_v10_trueHsub_file", v10TrueHsubFile);
    add("source_v11_middle_file", v11MiddleFile);
    add("purpose", "H52Q単管側の現行入力・診断データを固定する。");
    add("source_policy", "r8 resultブックはレガシー・ブリッジブックとして扱い、直接読み続けない。");
    add("single_tube_policy", "T&M/BMI単管から直接L/D補正式を作る方向はいったん止める。");
    add("LD_policy", "L/Dは補正式候補ではなく、履歴代理・診断項として保留する。");
    add("qM_policy", "qMは結果側量なので、補正式入力に使わない。診断量としてのみ扱う。");
    add("xMes_policy", "x_Mesは結果側量として扱い、補正式入力に使わない。");
    add("xeq_policy", "x_eqは前向き計算で使える熱収支状態量として、バンドル側でF1(Tsub)の意味を見直す候補にする。");
    add("Table8_policy", "Table8はsource03に閉じるため、L/D検証点として単純には使わない。");
    add("Table9_policy", "Table9はsource01であり、PWR下限側チェックとして扱う。");
    add("Table10_12_policy", "Table10〜12はsource01 PWR_near主解析群として扱う。");
    add("Table13_14_policy", "Table13/14は高圧側チェックであり、主補正式判断には使わない。");
    add("bundle_relation", "単管側の結論は、L/D単独補正式は弱い、x_eqが状態量として有力、という形でバンドル側へ送る。");

    readme = table(item, value);

    function add(k, v)
        item(end+1,1) = string(k);
        value(end+1,1) = string(v);
    end
end

function scope = makeDiagnosticScope()
    item = strings(0,1);
    scope_type = strings(0,1);
    current_treatment = strings(0,1);
    note = strings(0,1);

    add("Table8", "data_scope", "reference_only", "source03に閉じる。middleのみ。P/x_eq/Hsub/qMも異なるため、L/D検証点として単純には使わない。");
    add("Table9", "data_scope", "source01_lower_check", "source01で約12MPa。PWR下限側チェックとして使う。");
    add("Table10", "data_scope", "source01_PWR_near_main", "PWR_near主解析群。Table10点数が多いため、支配性には注意。");
    add("Table11", "data_scope", "source01_PWR_near_main", "PWR_near主解析群。真Hsubでshort-long差はおおむね説明可能。");
    add("Table12", "data_scope", "source01_PWR_near_main", "Hsub linearではlong残差が残るが、Hsub+P+x_eqではほぼ消える。");
    add("Table13/14", "data_scope", "high_check", "高圧側チェック。主補正式判断には使わない。");
    add("BMI-1116", "literature_scope", "context", "0.075 in短管/長管は同一系列だが、入口サブクール差が大きく、純粋なL/d比較ではない。");
    add("WAPD-188", "literature_scope", "context", "L/D項はあるが、本当はboiling length等の履歴変数かもしれない。");
    add("L/D", "variable_policy", "diagnostic_only", "補正式候補ではなく、熱履歴・沸騰履歴の代理指標として保留する。");
    add("Hsub", "variable_policy", "main_diagnostic_axis", "真Hsubを優先する。proxyは定量判断に使わない。");
    add("P", "variable_policy", "diagnostic_axis", "圧力・物性・hfgを通じた状態量として扱う。");
    add("x_eq", "variable_policy", "forward_state_candidate", "前向き計算で使える熱収支状態量として、バンドル側へ送る。");
    add("x_Mes", "variable_policy", "not_formula_input", "結果側量として扱う。補正式入力には使わない。");
    add("qM", "variable_policy", "diag_only_not_formula_input", "結果側量。補正式入力には使わない。");

    scope = table(item, scope_type, current_treatment, note);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        scope_type(end+1,1) = string(b);
        current_treatment(end+1,1) = string(c);
        note(end+1,1) = string(d);
    end
end

function ah = makeAdoptHoldRetract()
    state = strings(0,1);
    content = strings(0,1);

    add("採用", "T&M Table9〜12のTable12 long正残差は、Hsub linearでは見えるが、Hsub + P + x_eqでほぼ消える。");
    add("採用", "Table10を除いても、Table別均等重みにしても、Table12 long正残差は復活しない。");
    add("採用", "T&M単管データからL/D補正式を作る根拠は弱い。");
    add("採用", "Hsub + P + x_eqは補正式ではなく、原因切り分け用の診断式として扱う。");
    add("採用", "qMおよびx_Mesは補正式入力には使わない。");
    add("採用", "x_eqは、バンドル側で使える前向き計算量として、F1(Tsub)の代替・説明候補にする。");
    add("採用", "BMI-1116により、0.075 in短管/長管は比較不能ではないが、純粋なL/d比較ではない。");
    add("保留", "F1(Tsub)を維持するか、将来的にF(x_eq)または履歴長ベースに置換するか。");
    add("保留", "qP側に既に入っているL/D項・長さ補正の有無。");
    add("保留", "Hsub算出経路の表間整合。");
    add("保留", "source01原本で、Table9/10/11/12の装置・系列・表注・条件定義に矛盾がないか。");
    add("撤回気味", "T&M単管データから直接L/D補正式を作る案。");
    add("撤回気味", "Table12 long正残差をL/D/熱履歴効果の主証拠として扱う案。");

    ah = table(state, content);

    function add(a,b)
        state(end+1,1) = string(a);
        content(end+1,1) = string(b);
    end
end

function dictionary = makeDataDictionary(allVars)
    variable_name = strings(0,1);
    current_name_or_alias = strings(0,1);
    meaning = strings(0,1);
    unit = strings(0,1);
    current_use = strings(0,1);
    caution = strings(0,1);

    for i = 1:numel(allVars)
        v = allVars(i);
        vn = normalizeName(v);

        variable_name(end+1,1) = v;
        current_name_or_alias(end+1,1) = "";
        meaning(end+1,1) = "既存シート由来列。必要に応じて重要列定義を優先する。";
        unit(end+1,1) = "";
        current_use(end+1,1) = "kept";
        caution(end+1,1) = "";

        if any(vn == ["q_p","qp","qcalc","q_calc"])
            current_name_or_alias(end) = "q_calc / qP";
            meaning(end) = "Celata計算値。";
            unit(end) = "W/m2";
            current_use(end) = "main";
        elseif any(vn == ["q_m","qm","qexp","q_exp"])
            current_name_or_alias(end) = "q_exp / qM";
            meaning(end) = "実験値または実験値から復元した熱流束。";
            unit(end) = "W/m2";
            current_use(end) = "diagnostic";
            caution(end) = "結果側量なので補正式入力には使わない。";
        elseif any(vn == ["pm","pm_ratio","pmratio"])
            current_name_or_alias(end) = "PM";
            meaning(end) = "P/M = 計算値/実験値。";
            unit(end) = "-";
            current_use(end) = "main";
        elseif contains(vn, "hsub")
            current_name_or_alias(end) = "Hsub";
            meaning(end) = "入口サブクールエンタルピー差。真Hsubを優先する。";
            unit(end) = "kJ/kg等";
            current_use(end) = "main";
            caution(end) = "proxyとtrueを混同しない。";
        elseif contains(vn, "tsub")
            current_name_or_alias(end) = "Tsub";
            meaning(end) = "入口サブクール度。F1(Tsub)の入力。";
            unit(end) = "K";
            current_use(end) = "main";
        elseif any(vn == ["xmes","x_mes"])
            current_name_or_alias(end) = "x_Mes";
            meaning(end) = "実験/整理側の結果量として扱う。";
            unit(end) = "-";
            current_use(end) = "not_formula_input";
            caution(end) = "補正式入力には使わない。バンドル側のx_Mes=x_eq扱いとは文脈を確認する。";
        elseif contains(vn, "xeq")
            current_name_or_alias(end) = "x_eq";
            meaning(end) = "熱平衡クオリティ。前向き計算可能な状態量として扱う。";
            unit(end) = "-";
            current_use(end) = "candidate_state";
        elseif any(vn == ["p","press","pressure","p_mpa"])
            current_name_or_alias(end) = "P";
            meaning(end) = "圧力。";
            unit(end) = "MPa等";
            current_use(end) = "main";
        elseif contains(vn, "l_d") || contains(vn, "ld") || contains(vn, "l_over_d")
            current_name_or_alias(end) = "L/D";
            meaning(end) = "加熱長/管径比またはL/D相当量。";
            unit(end) = "-";
            current_use(end) = "diagnostic_only";
            caution(end) = "補正式候補ではなく、履歴代理・診断項として扱う。";
        elseif any(vn == ["source","source_id","sourceid"])
            current_name_or_alias(end) = "source";
            meaning(end) = "出典/データ系列識別子。";
            unit(end) = "-";
            current_use(end) = "main";
        elseif contains(vn, "table")
            current_name_or_alias(end) = "Table";
            meaning(end) = "T&M Table番号または系列識別子。";
            unit(end) = "-";
            current_use(end) = "main";
        elseif contains(vn, "f1")
            current_name_or_alias(end) = "F1";
            meaning(end) = "単管基準Tsub補正またはF1関連列。";
            unit(end) = "-";
            current_use(end) = "main";
        elseif contains(vn, "f2")
            current_name_or_alias(end) = "F2";
            meaning(end) = "F2関係の可能性がある列。";
            unit(end) = "-";
            current_use(end) = "not_current";
            caution(end) = "現在の単管current判断では主役にしない。";
        end
    end

    % Explicit policy rows
    addPolicy("POLICY_SINGLE_TUBE_CURRENT", "単管側currentは、T&M/BMI単管の今後参照入口。");
    addPolicy("POLICY_NO_LD_FORMULA", "T&M/BMI単管から直接L/D補正式を作る方向はいったん止める。");
    addPolicy("POLICY_QM_XMES", "qMおよびx_Mesは補正式入力には使わない。");
    addPolicy("POLICY_XEQ_TO_BUNDLE", "x_eqはF1(Tsub)の意味を見直す候補としてバンドル側へ送る。");

    dictionary = table(variable_name, current_name_or_alias, meaning, unit, current_use, caution);

    function addPolicy(name, text)
        variable_name(end+1,1) = string(name);
        current_name_or_alias(end+1,1) = "";
        meaning(end+1,1) = string(text);
        unit(end+1,1) = "";
        current_use(end+1,1) = "policy";
        caution(end+1,1) = "";
    end
end

function qualityNotes = makeQualityNotes()
    item = strings(0,1);
    note = strings(0,1);

    add("r8_position", "r8 resultブックはレガシー・ブリッジブック。今後、直接読み続ける対象ではなく抽出元として扱う。");
    add("current_single_tube_position", "current_single_tubeは単管側の現行入力・診断入口。");
    add("formula_policy", "このブックは補正式を作るためではなく、参照入口を固定するためのもの。");
    add("LD_policy", "L/Dは補正式候補ではなく診断項・履歴代理として保留。");
    add("Hsub_policy", "真Hsubを優先する。Hsub proxyは方向性確認用で定量判断には使わない。");
    add("qM_policy", "qMは結果側量。補正式入力には使わない。");
    add("xMes_policy", "x_Mesは結果側量。補正式入力には使わない。");
    add("xeq_policy", "x_eqは前向き計算可能な熱収支状態量としてバンドル側へ送る。");
    add("Table8_policy", "Table8はsource03に閉じるためL/D検証点として単純には使わない。");
    add("Table9_policy", "Table9はsource01でありPWR下限側チェックとして使う。");
    add("Table10_12_policy", "Table10〜12はsource01 PWR_near主解析群。");
    add("BMI_policy", "BMI-1116は短管/長管比較を無意味にはしないが、入口サブクール交絡が大きく純粋L/d比較ではない。");

    qualityNotes = table(item, note);

    function add(k, v)
        item(end+1,1) = string(k);
        note(end+1,1) = string(v);
    end
end

function s = normalizeName(v)
    s = lower(string(v));
    s = replace(s, "σ", "sigma");
    s = regexprep(s, "[^a-z0-9_]", "");
end

function md = tableToMarkdown(T)
    vars = string(T.Properties.VariableNames);

    lines = strings(0,1);
    lines(end+1) = "| " + strjoin(vars, " | ") + " |";
    lines(end+1) = "| " + strjoin(repmat("---", 1, numel(vars)), " | ") + " |";

    for i = 1:height(T)
        row = strings(1, numel(vars));
        for j = 1:numel(vars)
            val = T{i,j};

            if isnumeric(val)
                if isscalar(val)
                    if isnan(val)
                        row(j) = "";
                    else
                        row(j) = string(sprintf("%.6g", val));
                    end
                else
                    row(j) = "[array]";
                end
            elseif isstring(val)
                row(j) = val;
            elseif iscell(val)
                row(j) = string(val{1});
            else
                row(j) = string(val);
            end

            row(j) = replace(row(j), "|", "/");
            row(j) = replace(row(j), newline, " ");
        end
        lines(end+1) = "| " + strjoin(row, " | ") + " |";
    end

    md = strjoin(lines, newline);
end
