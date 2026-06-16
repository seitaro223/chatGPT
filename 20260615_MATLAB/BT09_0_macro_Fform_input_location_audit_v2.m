%% BT09_0_macro_Fform_input_location_audit_v2.m
% BT09-0 v2：マクロブック側の F_form 入力位置を監査する
%
% v2修正点：
%   v1で sheetInventory.has_F_form_like が行ベクトルになり、
%   table縦結合でエラーになった。
%
%     エラー：
%       tabular/vertcat
%       table変数 'has_F_form_like' の連結で次元不一致
%
%   原因：
%       any(A) が列方向の行ベクトルを返していた。
%
%   修正：
%       any(A(:)) で必ずスカラー論理値にする。
%
% 目的：
%   マクロブック側で F_form がどのシート・どの列に入力されているかを監査する。
%   この段階ではマクロブックを編集しない。
%
% 入力：
%   - BT08A3_macro_Fform_replace_package_*.xlsx
%   - マクロブック *.xlsm
%
% 出力：
%   - BT09_0_macro_Fform_input_location_audit_v2_yyyymmdd_HHMMSS.xlsx
%   - run_report_BT09_0_macro_Fform_input_location_audit_v2_yyyymmdd_HHMMSS.md
%
% 注意：
%   - 本スクリプトは監査専用。
%   - マクロブックの値は変更しない。
%   - マクロを実行しない。
%   - 今回のアップロードが「F1なし」マクロブックであっても、
%     まずnoF1側のF_form入力位置監査として使える。

clear; clc;

%% ===== Settings =====

inputPackageFile = "";
inputMacroBook = "";

if strlength(inputPackageFile) == 0
    inputPackageFile = findLatestFile("BT08A3_macro_Fform_replace_package_*.xlsx");
end

if strlength(inputMacroBook) == 0
    inputMacroBook = findLatestMacroBook();
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "BT09_0_macro_Fform_input_location_audit_v2_" + timestamp + ".xlsx";
outMd   = "run_report_BT09_0_macro_Fform_input_location_audit_v2_" + timestamp + ".md";

fprintf("Input A3 package: %s\n", inputPackageFile);
fprintf("Input macro book: %s\n", inputMacroBook);

%% ===== Read A3 package =====

replaceMap = readtable(inputPackageFile, 'Sheet', 'A3_macro_replace_map', 'VariableNamingRule', 'preserve');
replaceMap = normalizeReplaceMap(replaceMap);

expectedSheets = unique(string(replaceMap.sheet));
expectedBundles = unique(replaceMap.Bundle);
expectedNo = unique(replaceMap.No(isfinite(replaceMap.No)));

%% ===== Inspect macro workbook =====

try
    macroSheets = string(sheetnames(inputMacroBook));
catch
    [~, rawSheets] = xlsfinfo(inputMacroBook);
    macroSheets = string(rawSheets);
end

sheetInventory = table();
headerHits = table();
fFormHeaderCandidates = table();
noHeaderCandidates = table();
formulaHits = table();
sheetNameMatches = table();
replacementLocationCandidates = table();

for sh = macroSheets(:)'
    C = [];
    readStatus = "OK";
    try
        C = readcell(inputMacroBook, 'Sheet', sh);
        C = sanitizeCellMatrix(C);
    catch ME
        readStatus = "FAILED: " + string(ME.message);
    end

    inv = table();
    inv.sheet = sh;
    inv.read_status = readStatus;

    if isempty(C)
        inv.rows = NaN;
        inv.cols = NaN;
        inv.nonempty_cells = NaN;
        inv.has_F_form_like = false;
        inv.has_No_like = false;
        inv.has_PM_like = false;
        inv.has_qP_like = false;
        inv.has_qM_like = false;
    else
        textArray = normalizeText(cellToStringArray(C));

        hasFform = contains(textArray, "fform") | contains(textArray, "f_form");
        hasNo    = textArray == "no" | textArray == "number" | textArray == "testno" | textArray == "exptno" | textArray == "expno";
        hasPM    = textArray == "pm" | contains(textArray, "pm");
        hasqP    = textArray == "qp" | contains(textArray, "qp");
        hasqM    = textArray == "qm" | contains(textArray, "qm");

        inv.rows = size(C,1);
        inv.cols = size(C,2);
        inv.nonempty_cells = countNonEmpty(C);
        inv.has_F_form_like = any(hasFform(:));
        inv.has_No_like = any(hasNo(:));
        inv.has_PM_like = any(hasPM(:));
        inv.has_qP_like = any(hasqP(:));
        inv.has_qM_like = any(hasqM(:));
    end

    sheetInventory = [sheetInventory; inv]; %#ok<AGROW>

    if isempty(C)
        continue;
    end

    % Header search in first 50 rows
    headerRowsMax = min(size(C,1), 50);
    for r = 1:headerRowsMax
        for c = 1:size(C,2)
            s = cellToString(C{r,c});
            ns = normalizeText(s);

            if strlength(ns) == 0
                continue;
            end

            if isFformLike(ns)
                row = makeCellHit(inputMacroBook, sh, r, c, s, "Fform_like_header_or_cell");
                fFormHeaderCandidates = [fFormHeaderCandidates; row]; %#ok<AGROW>
                headerHits = [headerHits; row]; %#ok<AGROW>
            end

            if isNoLike(ns)
                row = makeCellHit(inputMacroBook, sh, r, c, s, "No_like_header_or_cell");
                noHeaderCandidates = [noHeaderCandidates; row]; %#ok<AGROW>
                headerHits = [headerHits; row]; %#ok<AGROW>
            end
        end
    end

    % Keyword search over whole used range
    for r = 1:size(C,1)
        for c = 1:size(C,2)
            s = cellToString(C{r,c});
            ns = normalizeText(s);
            if strlength(ns) == 0
                continue;
            end
            if contains(ns, "fform") || contains(ns, "f_form") || ...
               contains(ns, "pm") || contains(ns, "qp") || contains(ns, "qm") || ...
               contains(ns, "qcalc") || contains(ns, "qpred")
                formulaHits = [formulaHits; makeCellHit(inputMacroBook, sh, r, c, s, "keyword_hit")]; %#ok<AGROW>
            end
        end
    end
end

%% ===== Compare expected sheet names and macro sheet names =====

for es = expectedSheets(:)'
    row = table();
    row.expected_sheet_from_A3 = es;
    row.exact_match_in_macro = any(macroSheets == es);

    containsMask = contains(macroSheets, es) | contains(es, macroSheets);
    row.contains_match_count = sum(containsMask);
    row.contains_matches = strjoin(macroSheets(containsMask), ", ");

    sheetNameMatches = [sheetNameMatches; row]; %#ok<AGROW>
end

%% ===== Build replacement location candidates =====

for i = 1:height(fFormHeaderCandidates)
    sh = fFormHeaderCandidates.sheet(i);
    rF = fFormHeaderCandidates.row(i);
    cF = fFormHeaderCandidates.col(i);

    noSameSheet = noHeaderCandidates(noHeaderCandidates.sheet == sh, :);
    if height(noSameSheet) > 0
        [~, idxNo] = min(abs(noSameSheet.row - rF));
        rNo = noSameSheet.row(idxNo);
        cNo = noSameSheet.col(idxNo);
        noHeader = noSameSheet.value(idxNo);
        confidence = "medium";
        if rNo == rF
            confidence = "high";
        end
    else
        rNo = NaN;
        cNo = NaN;
        noHeader = "";
        confidence = "low_no_No_header";
    end

    exactA3Sheet = any(expectedSheets == sh);
    if exactA3Sheet && confidence == "high"
        confidence = "high_exact_sheet_and_headers";
    elseif exactA3Sheet
        confidence = "medium_exact_sheet";
    end

    cand = table();
    cand.macro_sheet = sh;
    cand.Fform_header_row = rF;
    cand.Fform_header_col = cF;
    cand.Fform_header_cell = fFormHeaderCandidates.value(i);
    cand.No_header_row = rNo;
    cand.No_header_col = cNo;
    cand.No_header_cell = noHeader;
    cand.data_start_row_guess = rF + 1;
    cand.exact_A3_sheet_match = exactA3Sheet;
    cand.replacement_row_rule_guess = "macro_excel_row = A3.data_row_index + data_start_row_guess - 1";
    cand.replacement_col_rule_guess = "macro_col = Fform_header_col";
    cand.confidence = confidence;

    replacementLocationCandidates = [replacementLocationCandidates; cand]; %#ok<AGROW>
end

%% ===== Build sheet-level replacement feasibility =====

sheetFeasibility = buildSheetFeasibility(expectedSheets, macroSheets, replacementLocationCandidates, replaceMap);

%% ===== QC =====

qc = makeQC(sheetInventory, fFormHeaderCandidates, noHeaderCandidates, replacementLocationCandidates, sheetNameMatches, replaceMap, sheetFeasibility);

instructions = makeInstructions(inputMacroBook, inputPackageFile);

%% ===== Write outputs =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(sheetInventory, outXlsx, 'Sheet', 'B09_sheet_inventory');
writetable(sheetNameMatches, outXlsx, 'Sheet', 'B09_sheet_name_matches');
writetable(sheetFeasibility, outXlsx, 'Sheet', 'B09_sheet_feasibility');
writetable(fFormHeaderCandidates, outXlsx, 'Sheet', 'B09_Fform_header_candidates');
writetable(noHeaderCandidates, outXlsx, 'Sheet', 'B09_No_header_candidates');
writetable(replacementLocationCandidates, outXlsx, 'Sheet', 'B09_replace_location_candidates');
writetable(firstN(formulaHits, 500), outXlsx, 'Sheet', 'B09_keyword_hits_first500');
writetable(qc, outXlsx, 'Sheet', 'B09_QC_flags');
writetable(instructions, outXlsx, 'Sheet', 'B09_next_steps');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Write Markdown =====

md = strings(0,1);

md(end+1) = "# BT09-0 v2 macro F_form input location audit";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "マクロブック側でF_formがどのシート・どの列に入力されているかを監査する。この段階ではマクロブックを編集しない。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- A3 package: `" + inputPackageFile + "`";
md(end+1) = "- macro workbook: `" + inputMacroBook + "`";
md(end+1) = "";
md(end+1) = "## 3. v2修正点";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "v1では has_F_form_like が行ベクトルになる場合があり、table縦結合で次元不一致エラーになった。";
md(end+1) = "v2では any(A(:)) に統一し、必ずスカラー論理値として保存するよう修正した。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 4. QC flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(qc);
md(end+1) = "";
md(end+1) = "## 5. Sheet name matches";
md(end+1) = "";
md(end+1) = tableToMarkdown(sheetNameMatches);
md(end+1) = "";
md(end+1) = "## 6. Sheet feasibility";
md(end+1) = "";
md(end+1) = tableToMarkdown(sheetFeasibility);
md(end+1) = "";
md(end+1) = "## 7. F_form header candidates";
md(end+1) = "";
md(end+1) = tableToMarkdown(fFormHeaderCandidates);
md(end+1) = "";
md(end+1) = "## 8. No header candidates";
md(end+1) = "";
md(end+1) = tableToMarkdown(noHeaderCandidates);
md(end+1) = "";
md(end+1) = "## 9. Replacement location candidates";
md(end+1) = "";
md(end+1) = tableToMarkdown(replacementLocationCandidates);
md(end+1) = "";
md(end+1) = "## 10. Keyword hits preview";
md(end+1) = "";
md(end+1) = tableToMarkdown(firstN(formulaHits, 120));
md(end+1) = "";
md(end+1) = "## 11. Next steps";
md(end+1) = "";
md(end+1) = tableToMarkdown(instructions);
md(end+1) = "";
md(end+1) = "## 12. 判断メモ";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "- このBT09-0 v2は監査専用であり、マクロブックを編集していない。";
md(end+1) = "- F_form候補列とNo候補列の位置が確認できたら、BT09-Aでコピー版マクロブックへの差し替えを行う。";
md(end+1) = "- 今回のマクロブックがF1なし版の場合、まずnoF1側の差し替え位置確認として扱う。";
md(end+1) = "```";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display =====

disp("=== QC ===");
disp(qc);
disp("=== Replacement location candidates ===");
disp(replacementLocationCandidates);

%% ===== Functions =====

function latest = findLatestFile(pattern)
    d = dir(pattern);
    if isempty(d)
        error("No file matching pattern: %s", pattern);
    end
    [~, idx] = max([d.datenum]);
    latest = string(d(idx).name);
end

function latest = findLatestMacroBook()
    d = dir("*.xlsm");
    if isempty(d)
        error("No .xlsm macro workbook found in current folder.");
    end

    names = string({d.name});
    preferred = contains(lower(names), "celata") | contains(names, "セル") | contains(names, "櫻井") | contains(names, "バンドル");

    if any(preferred)
        dd = d(preferred);
    else
        dd = d;
    end

    [~, idx] = max([dd.datenum]);
    latest = string(dd(idx).name);
end

function T = normalizeReplaceMap(T)
    vars = string(T.Properties.VariableNames);

    stringVars = ["sheet","target_kind","nearest_master_case_label","mapping_status","replace_action","do_not_edit_original"];
    for v = stringVars
        if ismember(v, vars)
            T.(v) = string(T.(v));
        end
    end

    numericVars = ["data_row_index","excel_row_if_header1","Bundle","No","z_DNB_over_L_current","master_z_DNB_ratio","mapping_abs_dz","original_value","replace_value","value_delta","value_ratio"];
    for v = numericVars
        if ismember(v, vars)
            T.(v) = toDouble(T.(v));
        end
    end

    if ismember("original_value", string(T.Properties.VariableNames)) && ~ismember("Fform_legacy", string(T.Properties.VariableNames))
        T.Fform_legacy = T.original_value;
    end
    if ismember("replace_value", string(T.Properties.VariableNames)) && ~ismember("Fform_linear", string(T.Properties.VariableNames))
        T.Fform_linear = T.replace_value;
    end
    if ismember("value_delta", string(T.Properties.VariableNames)) && ~ismember("Fform_diff_linear_minus_legacy", string(T.Properties.VariableNames))
        T.Fform_diff_linear_minus_legacy = T.value_delta;
    end
    if ismember("value_ratio", string(T.Properties.VariableNames)) && ~ismember("Fform_ratio_linear_to_legacy", string(T.Properties.VariableNames))
        T.Fform_ratio_linear_to_legacy = T.value_ratio;
    end
end

function x = toDouble(v)
    if isnumeric(v)
        x = double(v);
    elseif iscell(v)
        x = str2double(string(v));
    else
        x = str2double(string(v));
    end
end

function C2 = sanitizeCellMatrix(C)
    C2 = C;
    for i = 1:numel(C2)
        x = C2{i};
        if ismissingValue(x)
            C2{i} = "";
        elseif isdatetime(x)
            C2{i} = char(string(x));
        elseif isduration(x)
            C2{i} = char(string(x));
        elseif iscategorical(x)
            C2{i} = char(string(x));
        elseif iscell(x)
            C2{i} = "";
        end
    end
end

function tf = ismissingValue(x)
    tf = false;
    try
        if ismissing(x)
            tf = true;
            return;
        end
    catch
    end
end

function n = countNonEmpty(C)
    n = 0;
    for i = 1:numel(C)
        if strlength(strtrim(cellToString(C{i}))) > 0
            n = n + 1;
        end
    end
end

function arr = cellToStringArray(C)
    arr = strings(size(C));
    for i = 1:numel(C)
        arr(i) = cellToString(C{i});
    end
end

function s = cellToString(x)
    if ismissingValue(x)
        s = "";
    elseif ischar(x) || isstring(x)
        s = string(x);
    elseif isnumeric(x) && isscalar(x)
        if isnan(x)
            s = "";
        else
            s = string(x);
        end
    elseif islogical(x) && isscalar(x)
        s = string(x);
    else
        try
            s = string(x);
            if numel(s) > 1
                s = strjoin(s(:)', ",");
            end
        catch
            s = "";
        end
    end
end

function ns = normalizeText(s)
    ns = lower(string(s));
    ns = regexprep(ns, "\s+", "");
    ns = replace(ns, "_", "");
    ns = replace(ns, "-", "");
    ns = replace(ns, "/", "");
    ns = replace(ns, ".", "");
    ns = replace(ns, " ", "");
end

function tf = isFformLike(ns)
    ns = string(ns);
    tf = ns == "fform" || ns == "fformlegacy" || ns == "fformlinear" || ...
         contains(ns, "fform") || contains(ns, "f_form");
end

function tf = isNoLike(ns)
    ns = string(ns);
    tf = ns == "no" || ns == "number" || ns == "exptno" || ns == "expno" || ns == "testno";
end

function row = makeCellHit(file, sheet, r, c, value, hitType)
    row = table();
    row.file = string(file);
    row.sheet = string(sheet);
    row.row = r;
    row.col = c;
    row.excel_cell = excelAddress(r, c);
    row.value = string(value);
    row.hit_type = string(hitType);
end

function addr = excelAddress(row, col)
    letters = "";
    c = col;
    while c > 0
        remd = mod(c-1, 26);
        letters = char(65 + remd) + letters;
        c = floor((c-1)/26);
    end
    addr = string(letters) + string(row);
end

function F = buildSheetFeasibility(expectedSheets, macroSheets, locCand, replaceMap)
    F = table();

    for es = expectedSheets(:)'
        R = replaceMap(replaceMap.sheet == es, :);
        exact = any(macroSheets == es);
        cand = locCand(locCand.macro_sheet == es, :);

        row = table();
        row.A3_sheet = es;
        if height(R) > 0
            row.target_kind = R.target_kind(1);
            row.N_replace_rows = height(R);
            row.min_No = min(R.No, [], 'omitnan');
            row.max_No = max(R.No, [], 'omitnan');
        else
            row.target_kind = "";
            row.N_replace_rows = 0;
            row.min_No = NaN;
            row.max_No = NaN;
        end

        row.exact_macro_sheet_exists = exact;
        row.N_location_candidates = height(cand);

        if height(cand) > 0
            row.best_Fform_cell = cand.Fform_header_cell(1);
            row.best_Fform_col = cand.Fform_header_col(1);
            row.best_Fform_header_row = cand.Fform_header_row(1);
            row.best_confidence = cand.confidence(1);
            row.feasibility_status = "candidate_found";
        elseif exact
            row.best_Fform_cell = "";
            row.best_Fform_col = NaN;
            row.best_Fform_header_row = NaN;
            row.best_confidence = "";
            row.feasibility_status = "sheet_exists_but_no_Fform_candidate";
        else
            row.best_Fform_cell = "";
            row.best_Fform_col = NaN;
            row.best_Fform_header_row = NaN;
            row.best_confidence = "";
            row.feasibility_status = "sheet_not_found";
        end

        F = [F; row]; %#ok<AGROW>
    end
end

function qc = makeQC(sheetInventory, fHits, noHits, locCand, sheetNameMatches, replaceMap, sheetFeasibility)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("macro_sheet_count", "diagnostic", sprintf("%d", height(sheetInventory)), "マクロブック内のシート数。");
    add("A3_rows", "OK", sprintf("%d", height(replaceMap)), "A3差し替え行数。");

    if height(fHits) > 0
        add("Fform_header_candidates", "OK", sprintf("%d", height(fHits)), "F_formに見えるセル候補あり。");
    else
        add("Fform_header_candidates", "CHECK", "0", "F_form候補が見つからない。列名が異なる可能性。");
    end

    if height(noHits) > 0
        add("No_header_candidates", "OK", sprintf("%d", height(noHits)), "Noに見えるセル候補あり。");
    else
        add("No_header_candidates", "CHECK", "0", "No候補が見つからない。");
    end

    if height(locCand) > 0
        add("replacement_location_candidates", "OK", sprintf("%d", height(locCand)), "差し替え位置候補あり。");
    else
        add("replacement_location_candidates", "CHECK", "0", "差し替え位置候補が作れない。");
    end

    exactMatches = sum(sheetNameMatches.exact_match_in_macro);
    add("exact_sheet_name_matches", "diagnostic", sprintf("%d/%d", exactMatches, height(sheetNameMatches)), "A3側シート名とマクロシート名の完全一致数。");

    feasible = sum(sheetFeasibility.feasibility_status == "candidate_found");
    add("feasible_A3_sheets", "diagnostic", sprintf("%d/%d", feasible, height(sheetFeasibility)), "A3シート別に差し替え候補が見つかった数。");

    highConf = sum(contains(string(locCand.confidence), "high"));
    if highConf > 0
        add("high_confidence_candidates", "OK", sprintf("%d", highConf), "高信頼候補あり。");
    else
        add("high_confidence_candidates", "CHECK", "0", "高信頼候補なし。手動確認が必要。");
    end

    add("edit_policy", "adopt", "read_only_audit", "BT09-0では編集しない。");
    add("next", "next", "BT09-A", "コピー版マクロブックへの差し替えへ進むか判断。");

    qc = table(item, status, value, reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function instructions = makeInstructions(inputMacroBook, inputPackageFile)
    step = (1:8)';
    action = strings(8,1);
    detail = strings(8,1);

    action(1) = "Check F_form candidates";
    detail(1) = "Open B09_replace_location_candidates and identify the exact F_form column.";

    action(2) = "Check No alignment";
    detail(2) = "Confirm whether No column exists on the same header row as F_form.";

    action(3) = "Check sheet matching";
    detail(3) = "Compare macro sheet names with A3 sheet names: tm_108, tm_161, tm_164, tm_F1_108, tm_F1_161, tm_F1_164.";

    action(4) = "Do not edit original";
    detail(4) = "Original macro workbook remains unchanged: " + inputMacroBook;

    action(5) = "Prepare copy";
    detail(5) = "BT09-A should copy the macro workbook before replacement.";

    action(6) = "Use A3 package";
    detail(6) = "Use A3_macro_replace_map from " + inputPackageFile + " for replacement values.";

    action(7) = "Run macro manually";
    detail(7) = "After copy replacement, run macro manually if required.";

    action(8) = "Upload run report";
    detail(8) = "Upload BT09-A or macro recalculation report for interpretation.";

    instructions = table(step, action, detail);
end

function Tsmall = firstN(T, n)
    if height(T) <= n
        Tsmall = T;
    else
        Tsmall = T(1:n,:);
    end
end

function md = tableToMarkdown(T)
    if height(T) == 0
        md = "_empty_";
        return;
    end

    vars = string(T.Properties.VariableNames);

    lines = strings(0,1);
    lines(end+1) = "| " + strjoin(vars, " | ") + " |";
    lines(end+1) = "| " + strjoin(repmat("---", 1, numel(vars)), " | ") + " |";

    maxRows = min(height(T), 120);
    for i = 1:maxRows
        row = strings(1, numel(vars));
        for j = 1:numel(vars)
            row(j) = valueToString(T{i,j});
            row(j) = replace(row(j), "|", "/");
            row(j) = replace(row(j), newline, " ");
        end
        lines(end+1) = "| " + strjoin(row, " | ") + " |";
    end

    if height(T) > maxRows
        lines(end+1) = "| " + strjoin(repmat("...", 1, numel(vars)), " | ") + " |";
    end

    md = strjoin(lines, newline);
end

function s = valueToString(val)
    if isnumeric(val)
        if isempty(val)
            s = "";
        elseif isscalar(val)
            if isnan(val)
                s = "";
            else
                s = string(sprintf("%.8g", val));
            end
        else
            s = strjoin(string(val(:)'), ",");
        end
    elseif isstring(val)
        if isempty(val)
            s = "";
        else
            s = strjoin(val(:)', ",");
        end
    elseif iscell(val)
        parts = strings(numel(val),1);
        for k = 1:numel(val)
            parts(k) = valueToString(val{k});
        end
        s = strjoin(parts, ",");
    elseif islogical(val)
        s = strjoin(string(val(:)'), ",");
    else
        try
            s = string(val);
            if numel(s) > 1
                s = strjoin(s(:)', ",");
            end
        catch
            s = "";
        end
    end
end
