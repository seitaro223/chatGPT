%% BT00_1_make_current_bundle_input_from_r8.m
% BT00-1：r8レガシー・ブリッジブックから、バンドル用current入力ブックを作る
%
% 目的：
%   20260612_計算結果比較r8_result_文献追加用.xlsx を、
%   今後も直接読み続けるのではなく、
%   バンドル108/161/164の現行解析に必要な6シートだけを切り出す。
%
% 方針：
%   - tm系シートの列構成は極力そのまま保持する。
%   - F2 / F1F2 関係は入れない。
%   - README_CURRENT / DATA_DICTIONARY_CURRENT / SOURCE_MANIFEST を先頭に追加する。
%   - currentブックは「今後のBT01/BT02/BT03以降の入力」として使う。
%   - r8はレガシー・ブリッジブックとして凍結し、直接解釈し続けない。
%
% 入力：
%   20260612_計算結果比較r8_result_文献追加用.xlsx
%
% 出力：
%   H52Q_current_bundle_input_v1_yyyymmdd_HHMMSS.xlsx
%   run_report_BT00_1_current_bundle_input_yyyymmdd_HHMMSS.md

clear; clc;

%% ===== Settings =====

sourceFile = "20260612_計算結果比較r8_result_文献追加用.xlsx";

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "H52Q_current_bundle_input_v1_" + timestamp + ".xlsx";
outMd   = "run_report_BT00_1_current_bundle_input_" + timestamp + ".md";

includedSheets = table( ...
    ["noF1"; "noF1"; "noF1"; "F1"; "F1"; "F1"], ...
    ["108";  "161";  "164";  "108"; "161"; "164"], ...
    ["tm_108"; "tm_161"; "tm_164"; "tm_F1_108"; "tm_F1_161"; "tm_F1_164"], ...
    ["tm_108"; "tm_161"; "tm_164"; "tm_F1_108"; "tm_F1_161"; "tm_F1_164"], ...
    'VariableNames', {'correction','case_id','source_sheet','current_sheet'} ...
);

excludedFamilies = {
    "F2", "F2関係は今回のcurrent bundleでは使用しない。";
    "F1F2", "F1F2関係は今回のcurrent bundleでは使用しない。";
    "F1F2/F2旧診断", "過去検討・旧補正・補助診断はr8側に残し、currentには入れない。";
};

%% ===== Validate source =====

if ~isfile(sourceFile)
    error("Source file not found: %s", sourceFile);
end

try
    srcSheetNames = string(sheetnames(sourceFile));
catch
    % Older MATLAB fallback using Excel COM may not be available in all environments.
    % If this fails, later readtable calls will still identify missing sheets.
    srcSheetNames = strings(0,1);
end

%% ===== Read included sheets =====

sheetData = cell(height(includedSheets), 1);
sheetRows = zeros(height(includedSheets), 1);
sheetCols = zeros(height(includedSheets), 1);
sheetStatus = strings(height(includedSheets), 1);
sheetNotes = strings(height(includedSheets), 1);

allVarNames = strings(0,1);

for i = 1:height(includedSheets)
    sh = includedSheets.source_sheet(i);

    fprintf("Reading source sheet: %s\n", sh);

    try
        T = readSheetPreserve(sourceFile, sh);
        sheetData{i} = T;
        sheetRows(i) = height(T);
        sheetCols(i) = width(T);
        sheetStatus(i) = "included";
        sheetNotes(i) = "readtable成功。列構成を保持してcurrentへ転記。";

        allVarNames = [allVarNames; string(T.Properties.VariableNames(:))]; %#ok<AGROW>
    catch ME
        sheetData{i} = table();
        sheetRows(i) = 0;
        sheetCols(i) = 0;
        sheetStatus(i) = "ERROR";
        sheetNotes(i) = string(ME.message);
        warning("Failed to read sheet %s: %s", sh, ME.message);
    end
end

allVarNames = unique(allVarNames, 'stable');

%% ===== Build metadata sheets =====

readme = makeReadme(sourceFile, outXlsx, timestamp);
manifest = makeManifest(includedSheets, sheetRows, sheetCols, sheetStatus, sheetNotes, excludedFamilies);
dictionary = makeDataDictionary(allVarNames);
qualityNotes = makeQualityNotes();

%% ===== Write current workbook =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(readme,       outXlsx, 'Sheet', 'README_CURRENT');
writetable(dictionary,   outXlsx, 'Sheet', 'DATA_DICTIONARY_CURRENT');
writetable(manifest,     outXlsx, 'Sheet', 'SOURCE_MANIFEST');
writetable(qualityNotes, outXlsx, 'Sheet', 'QUALITY_NOTES');

for i = 1:height(includedSheets)
    if sheetStatus(i) == "included"
        writetable(sheetData{i}, outXlsx, 'Sheet', includedSheets.current_sheet(i));
        fprintf("Wrote current sheet: %s\n", includedSheets.current_sheet(i));
    end
end

fprintf("Wrote current workbook: %s\n", outXlsx);

%% ===== Write Markdown report =====

md = strings(0,1);

md(end+1) = "# BT00-1 current bundle input";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "r8レガシー・ブリッジブックを直接読み続けるのではなく、バンドル108/161/164の現行解析で使うシートだけを切り出したcurrent入力ブックを作成した。";
md(end+1) = "";
md(end+1) = "## 2. 入力と出力";
md(end+1) = "";
md(end+1) = "- 入力: `" + sourceFile + "`";
md(end+1) = "- 出力: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 3. current bundle の位置づけ";
md(end+1) = "";
md(end+1) = "- r8はレガシー・ブリッジブックとして扱う。";
md(end+1) = "- current bundleはBT01/BT02/BT03以降の入力として使う。";
md(end+1) = "- tm系シートの列構成は極力そのまま保持した。";
md(end+1) = "- F2/F1F2関係は含めない。";
md(end+1) = "- README_CURRENT、DATA_DICTIONARY_CURRENT、SOURCE_MANIFESTを追加した。";
md(end+1) = "";
md(end+1) = "## 4. Included sheets";
md(end+1) = "";
md(end+1) = tableToMarkdown(manifest(manifest.action=="include", :));
md(end+1) = "";
md(end+1) = "## 5. Excluded families";
md(end+1) = "";
md(end+1) = tableToMarkdown(manifest(manifest.action=="exclude_family", :));
md(end+1) = "";
md(end+1) = "## 6. 重要な列の認識";
md(end+1) = "";
md(end+1) = "- `F1`: 単管データに基づくTsub補正。";
md(end+1) = "- `F_form`: F1ではない。非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。";
md(end+1) = "- `x_Mes`: バンドル側では熱平衡クオリティ `x_eq` として扱う。";
md(end+1) = "- `F2` / `F1F2`: current bundleでは使用しない。";
md(end+1) = "";
md(end+1) = "## 7. 次アクション";
md(end+1) = "";
md(end+1) = "1. 出力されたcurrent bundleブックを確認する。";
md(end+1) = "2. BT01/BT02をcurrent bundle入力で再現する。";
md(end+1) = "3. 問題なければBT03以降はcurrent bundleを入力にする。";
md(end+1) = "4. 次にBT00-2としてcurrent single-tube入力を作成する。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown report: %s\n", outMd);

%% ===== Display quick report =====

disp("=== SOURCE MANIFEST ===");
disp(manifest);

%% ===== Local functions =====

function T = readSheetPreserve(file, sheetName)
    opts = detectImportOptions(file, 'Sheet', sheetName);
    opts.VariableNamingRule = 'preserve';
    T = readtable(file, opts);
end

function readme = makeReadme(sourceFile, outXlsx, timestamp)
    item = strings(0,1);
    value = strings(0,1);

    add("book_type", "H52Q current bundle input");
    add("created_at", timestamp);
    add("source_file", sourceFile);
    add("output_file", outXlsx);
    add("purpose", "r8レガシー・ブリッジブックから、バンドル108/161/164の現行解析に使う6シートだけを切り出す。");
    add("source_policy", "r8は今後、直接解釈し続ける対象ではなく、移行期のレガシー・ブリッジブックとして扱う。");
    add("column_policy", "tm系シートの列構成は、マクロブック互換性を優先して極力保持する。");
    add("included_cases", "108, 161, 164");
    add("included_corrections", "noF1, F1");
    add("excluded_corrections", "F2, F1F2");
    add("F1_definition", "単管データに基づくTsub補正。");
    add("F_form_definition", "F1ではない。非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。");
    add("x_Mes_definition", "バンドル側では熱平衡クオリティ x_eq として扱う。");
    add("use_for", "BT01/BT02/BT03以降のバンドル解析入力。");
    add("not_use_for", "単管T&M/BMI/13.8MPa診断。単管側は別途current_single_tubeを作る。");

    readme = table(item, value);

    function add(k, v)
        item(end+1,1) = string(k);
        value(end+1,1) = string(v);
    end
end

function manifest = makeManifest(includedSheets, rows, cols, status, notes, excludedFamilies)
    action = strings(0,1);
    correction = strings(0,1);
    case_id = strings(0,1);
    source_sheet = strings(0,1);
    current_sheet = strings(0,1);
    n_rows = zeros(0,1);
    n_cols = zeros(0,1);
    read_status = strings(0,1);
    note = strings(0,1);

    for i = 1:height(includedSheets)
        action(end+1,1) = "include";
        correction(end+1,1) = includedSheets.correction(i);
        case_id(end+1,1) = includedSheets.case_id(i);
        source_sheet(end+1,1) = includedSheets.source_sheet(i);
        current_sheet(end+1,1) = includedSheets.current_sheet(i);
        n_rows(end+1,1) = rows(i);
        n_cols(end+1,1) = cols(i);
        read_status(end+1,1) = status(i);
        note(end+1,1) = notes(i);
    end

    for j = 1:size(excludedFamilies,1)
        action(end+1,1) = "exclude_family";
        correction(end+1,1) = string(excludedFamilies{j,1});
        case_id(end+1,1) = "";
        source_sheet(end+1,1) = "";
        current_sheet(end+1,1) = "";
        n_rows(end+1,1) = NaN;
        n_cols(end+1,1) = NaN;
        read_status(end+1,1) = "not_read";
        note(end+1,1) = string(excludedFamilies{j,2});
    end

    manifest = table(action, correction, case_id, source_sheet, current_sheet, ...
                     n_rows, n_cols, read_status, note);
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

        variable_name(end+1,1) = v;
        current_name_or_alias(end+1,1) = "";
        meaning(end+1,1) = "既存tm列構成に準拠。必要に応じて下記の重要列定義を優先する。";
        unit(end+1,1) = "";
        current_use(end+1,1) = "kept";
        caution(end+1,1) = "";

        vn = normalizeName(v);

        if vn == "q_p"
            current_name_or_alias(end) = "q_calc";
            meaning(end) = "Celata計算値。";
            unit(end) = "W/m2";
            current_use(end) = "main";
        elseif vn == "q_m"
            current_name_or_alias(end) = "q_exp";
            meaning(end) = "実験値。";
            unit(end) = "W/m2";
            current_use(end) = "main";
        elseif vn == "pm_ratio"
            current_name_or_alias(end) = "PM";
            meaning(end) = "P/M = 計算値/実験値。";
            unit(end) = "-";
            current_use(end) = "main";
        elseif vn == "x_mes"
            current_name_or_alias(end) = "x_eq";
            meaning(end) = "バンドル側では熱平衡クオリティ x_eq として扱う。";
            unit(end) = "-";
            current_use(end) = "main";
            caution(end) = "COBRA-ENクオリティとは混同しない。";
        elseif vn == "f_form"
            current_name_or_alias(end) = "F_form";
            meaning(end) = "非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。F1ではない。";
            unit(end) = "-";
            current_use(end) = "main";
            caution(end) = "F1(Tsub)と混同しない。";
        elseif vn == "fcorr"
            current_name_or_alias(end) = "F1_Tsub";
            meaning(end) = "単管基準Tsub補正F1の補正係数。";
            unit(end) = "-";
            current_use(end) = "main";
        elseif vn == "tsub"
            current_name_or_alias(end) = "Tsub";
            meaning(end) = "サブクール度。F1(Tsub)の入力。";
            unit(end) = "K";
            current_use(end) = "main";
        elseif vn == "l_dnb"
            current_name_or_alias(end) = "z_DNB";
            meaning(end) = "DNB位置またはDNB位置までの長さ。";
            unit(end) = "m";
            current_use(end) = "main";
        elseif vn == "dh"
            current_name_or_alias(end) = "DH";
            meaning(end) = "水力等価直径。";
            unit(end) = "m";
            current_use(end) = "main";
        elseif vn == "l"
            current_name_or_alias(end) = "L";
            meaning(end) = "加熱長。";
            unit(end) = "m";
            current_use(end) = "main";
        elseif vn == "tin"
            current_name_or_alias(end) = "Tin";
            meaning(end) = "入口温度。";
            unit(end) = "K";
            current_use(end) = "kept";
        elseif vn == "ts"
            current_name_or_alias(end) = "Tsat";
            meaning(end) = "飽和温度。";
            unit(end) = "K";
            current_use(end) = "kept";
        elseif vn == "tm"
            current_name_or_alias(end) = "Tm";
            meaning(end) = "平均液温またはモデル内平均温度。";
            unit(end) = "K";
            current_use(end) = "kept";
        elseif vn == "tw"
            current_name_or_alias(end) = "Tw";
            meaning(end) = "壁温。";
            unit(end) = "K";
            current_use(end) = "kept";
        elseif vn == "a_corr"
            current_name_or_alias(end) = "A_corr";
            meaning(end) = "F1(Tsub)補正の振幅係数。";
            unit(end) = "-";
            current_use(end) = "main";
        elseif vn == "corr" || vn == "sigmacorr"
            current_name_or_alias(end) = "sigma_corr";
            meaning(end) = "F1(Tsub)補正の幅係数。";
            unit(end) = "K^2相当";
            current_use(end) = "main";
        elseif contains(vn, "f2")
            current_name_or_alias(end) = "";
            meaning(end) = "F2関係の可能性がある列。";
            unit(end) = "";
            current_use(end) = "not_current";
            caution(end) = "current bundleではF2/F1F2は使わない。列が残っていても解釈対象外。";
        end
    end

    % Add explicit policy rows even if columns do not exist.
    variable_name(end+1,1) = "POLICY_F2_F1F2";
    current_name_or_alias(end+1,1) = "";
    meaning(end+1,1) = "F2/F1F2関係はcurrent bundleでは使わない。";
    unit(end+1,1) = "";
    current_use(end+1,1) = "excluded";
    caution(end+1,1) = "必要ならr8側を参照するが、BT01/BT02/BT03の入力にはしない。";

    variable_name(end+1,1) = "POLICY_TM_COLUMNS";
    current_name_or_alias(end+1,1) = "";
    meaning(end+1,1) = "tm系列構成はマクロブック互換性を優先して保持する。";
    unit(end+1,1) = "";
    current_use(end+1,1) = "kept";
    caution(end+1,1) = "列が多いこと自体は許容し、READMEと辞書で意味を固定する。";

    dictionary = table(variable_name, current_name_or_alias, meaning, unit, current_use, caution);
end

function qualityNotes = makeQualityNotes()
    item = strings(0,1);
    note = strings(0,1);

    add("r8_position", "r8はレガシー・ブリッジブック。今後、直接読み続ける対象ではなく、抽出元として扱う。");
    add("current_bundle_position", "current bundleはBT01/BT02/BT03以降の現行入力。");
    add("F2_policy", "F2/F1F2はcurrent bundleに含めない。");
    add("F1_policy", "F1は単管データに基づくTsub補正。");
    add("F_form_policy", "F_formはF1ではなく、非一様加熱の局所熱流束基準換算係数。");
    add("x_Mes_policy", "x_Mesはバンドル側では熱平衡クオリティx_eqとして扱う。");
    add("single_tube_policy", "単管側は別途current_single_tube_inputを作成する。bundle currentに混ぜない。");
    add("readme_policy", "READMEは手作業で後追い修正するのではなく、MATLAB実行時に自動生成する。");

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
