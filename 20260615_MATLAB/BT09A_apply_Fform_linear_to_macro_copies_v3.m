%% BT09A_apply_Fform_linear_to_macro_copies_v3.m
% BT09-A v3：コピー版マクロブックへ Fform_linear を投入する
%
% v2修正点：
%   v1では Excel COM の ws.Cells.Item(r,c).Value で環境依存エラーが発生した。
%   v2では ws.Range('BG2').Value のようにA1アドレス指定で書き込む。
%
% 目的：
%   BT08-A3で確定したF_form差し替え表を使い、
%   マクロブックのコピー版だけに Fform_linear を投入する。
%
% 対象：
%   - F1なし版マクロブック：target_kind = noF1
%   - F1あり版マクロブック：target_kind = F1
%
% 重要：
%   - 元マクロブックは上書きしない。
%   - 必ずコピーを作ってから、コピー側だけを編集する。
%   - 編集するのは tm シートの F_form 列のみ。
%   - No列で行対応する。
%   - このスクリプトはマクロを実行しない。
%
% 前提（BT09-0 v2の結果）：
%   - macro sheet = tm
%   - No header = M1
%   - F_form header = BG1
%   - data starts at row 2
%
% 入力：
%   - BT08A3_macro_Fform_replace_package_*.xlsx
%   - *F1なし*.xlsm
%   - *F1あり*.xlsm
%
% 出力：
%   - *_FformLinear_v1_yyyymmdd_HHMMSS.xlsm
%   - BT09A_Fform_linear_macro_replacement_summary_yyyymmdd_HHMMSS.xlsx
%   - run_report_BT09A_Fform_linear_macro_replacement_yyyymmdd_HHMMSS.md
%
% 次：
%   ユーザーがコピー版マクロブックを開いて、必要なマクロ再計算を実行する。
%   再計算後、出力ブックまたはrun_reportをアップロードし、BT10でPM影響を診断する。

clear; clc;

%% ===== Settings =====

inputPackageFile = "";
macroNoF1File = "";
macroF1File = "";

if strlength(inputPackageFile) == 0
    inputPackageFile = findLatestFile("BT08A3_macro_Fform_replace_package_*.xlsx");
end

if strlength(macroNoF1File) == 0
    macroNoF1File = findLatestFile("*F1なし*.xlsm");
end

if strlength(macroF1File) == 0
    macroF1File = findLatestFile("*F1あり*.xlsm");
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outSummaryXlsx = "BT09A_v3_Fform_linear_macro_replacement_summary_" + timestamp + ".xlsx";
outMd = "run_report_BT09A_v3_Fform_linear_macro_replacement_" + timestamp + ".md";

fprintf("A3 package : %s\n", inputPackageFile);
fprintf("NoF1 macro : %s\n", macroNoF1File);
fprintf("F1 macro   : %s\n", macroF1File);

%% ===== Read A3 replace map =====

replaceMap = readtable(inputPackageFile, 'Sheet', 'A3_macro_replace_map', 'VariableNamingRule', 'preserve');
replaceMap = normalizeReplaceMap(replaceMap);

%% ===== Process both macro workbooks =====

allReplacementRows = table();
workbookSummary = table();

[summaryNoF1, rowsNoF1] = processOneMacroWorkbook(macroNoF1File, replaceMap, "noF1", timestamp);
[summaryF1, rowsF1]     = processOneMacroWorkbook(macroF1File,   replaceMap, "F1",   timestamp);

workbookSummary = [summaryNoF1; summaryF1];
allReplacementRows = [rowsNoF1; rowsF1];

%% ===== Summary by bundle/case =====

summaryByWorkbookBundle = summarizeByKeys(allReplacementRows, ["target_kind","Bundle"]);
summaryByWorkbookCase = summarizeByKeys(allReplacementRows, ["target_kind","nearest_master_case_label"]);
qc = makeQC(workbookSummary, allReplacementRows);

instructions = makeInstructions(workbookSummary);

%% ===== Write summary workbook =====

if exist(outSummaryXlsx, "file")
    delete(outSummaryXlsx);
end

writetable(workbookSummary, outSummaryXlsx, 'Sheet', 'BT09A_workbook_summary');
writetable(allReplacementRows, outSummaryXlsx, 'Sheet', 'BT09A_replacement_rows');
writetable(summaryByWorkbookBundle, outSummaryXlsx, 'Sheet', 'BT09A_summary_by_bundle');
writetable(summaryByWorkbookCase, outSummaryXlsx, 'Sheet', 'BT09A_summary_by_case');
writetable(qc, outSummaryXlsx, 'Sheet', 'BT09A_QC_flags');
writetable(instructions, outSummaryXlsx, 'Sheet', 'BT09A_next_steps');

fprintf("Wrote summary workbook: %s\n", outSummaryXlsx);

%% ===== Write Markdown report =====

md = strings(0,1);

md(end+1) = "# BT09-A Fform_linear macro replacement";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT08-A3で確定したF_form差し替え表を使い、F1なし版・F1あり版マクロブックのコピーにFform_linearを投入する。元マクロブックは上書きしない。";
md(end+1) = "";
md(end+1) = "## 1.1 v2/v3修正点";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "v1では Excel COM の ws.Cells.Item(r,c).Value で環境依存エラーが出た。";
md(end+1) = "v2/v3では ws.Range('BG2').Value のようなA1セルアドレス指定でF_formを書き込む。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- A3 package: `" + inputPackageFile + "`";
md(end+1) = "- noF1 macro: `" + macroNoF1File + "`";
md(end+1) = "- F1 macro: `" + macroF1File + "`";
md(end+1) = "";
md(end+1) = "## 3. マクロブック側の差し替え位置";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "sheet      = tm";
md(end+1) = "No列       = M列";
md(end+1) = "F_form列   = BG列";
md(end+1) = "header row = 1";
md(end+1) = "data start = 2";
md(end+1) = "row match  = No";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 4. Workbook summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(workbookSummary);
md(end+1) = "";
md(end+1) = "## 5. QC flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(qc);
md(end+1) = "";
md(end+1) = "## 6. Summary by bundle";
md(end+1) = "";
md(end+1) = tableToMarkdown(summaryByWorkbookBundle);
md(end+1) = "";
md(end+1) = "## 7. Summary by case";
md(end+1) = "";
md(end+1) = tableToMarkdown(summaryByWorkbookCase);
md(end+1) = "";
md(end+1) = "## 8. Replacement rows preview";
md(end+1) = "";
md(end+1) = tableToMarkdown(firstN(allReplacementRows, 120));
md(end+1) = "";
md(end+1) = "## 9. Next steps";
md(end+1) = "";
md(end+1) = tableToMarkdown(instructions);
md(end+1) = "";
md(end+1) = "## 10. 判断メモ";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "- このBT09-Aでは、コピー版マクロブックのtmシートBG列だけをFform_linearに差し替えた。";
md(end+1) = "- 元マクロブックは変更していない。";
md(end+1) = "- まだマクロ再計算はしていない。";
md(end+1) = "- 次にコピー版を開き、必要なマクロ再計算を実行する。";
md(end+1) = "- 再計算後、BT10でP/M影響を診断する。";
md(end+1) = "```";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown report: %s\n", outMd);

%% ===== Display =====

disp("=== Workbook summary ===");
disp(workbookSummary);

disp("=== QC ===");
disp(qc);

%% ===== Functions =====

function latest = findLatestFile(pattern)
    d = dir(pattern);
    if isempty(d)
        error("No file matching pattern: %s", pattern);
    end
    [~, idx] = max([d.datenum]);
    latest = string(d(idx).name);
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

function [summary, replRows] = processOneMacroWorkbook(inputFile, replaceMap, targetKind, timestamp)
    fprintf("Processing %s as target_kind=%s\n", inputFile, targetKind);

    inputFile = string(inputFile);
    targetKind = string(targetKind);

    [folder, base, ext] = fileparts(inputFile);
    if strlength(folder) == 0
        folder = pwd;
    end

    outFile = fullfile(folder, base + "_FformLinear_v1_" + timestamp + ext);

    if isfile(outFile)
        delete(outFile);
    end
    copyfile(inputFile, outFile);

    % Read before edit for row matching and header check
    C = readcell(outFile, 'Sheet', 'tm');
    C = sanitizeCellMatrix(C);

    headerRow = 1;
    noCol = findHeaderCol(C, headerRow, ["No"]);
    fformCol = findHeaderCol(C, headerRow, ["F_form","Fform","F_FORM"]);

    if isnan(noCol) || isnan(fformCol)
        error("Could not find No or F_form header in tm sheet of %s", inputFile);
    end

    dataStartRow = headerRow + 1;
    lastRow = findLastNumericNoRow(C, noCol, dataStartRow);

    M = replaceMap(replaceMap.target_kind == targetKind, :);
    if height(M) == 0
        error("No replace rows for target_kind=%s", targetKind);
    end

    % Build replacement row table based on No
    replRows = table();

    for r = dataStartRow:lastRow
        noVal = cellToDouble(C{r,noCol});
        if ~isfinite(noVal)
            continue;
        end
        noValRound = round(noVal);

        idx = find(round(M.No) == noValRound, 1);
        if isempty(idx)
            continue;
        end

        oldWorkbookValue = cellToDouble(C{r, fformCol});
        originalValue = M.original_value(idx);
        replaceValue = M.replace_value(idx);

        row = table();
        row.input_macro_file = inputFile;
        row.output_macro_file = string(outFile);
        row.target_kind = targetKind;
        row.sheet = "tm";
        row.excel_row = r;
        row.No = noValRound;
        row.Bundle = M.Bundle(idx);
        row.nearest_master_case_label = string(M.nearest_master_case_label(idx));
        row.Fform_col = fformCol;
        row.Fform_cell = excelAddress(r, fformCol);
        row.workbook_old_value = oldWorkbookValue;
        row.original_value_from_A3 = originalValue;
        row.replace_value = replaceValue;
        row.value_delta = replaceValue - oldWorkbookValue;
        row.A3_value_delta = M.value_delta(idx);
        row.old_matches_A3_original = abs(oldWorkbookValue - originalValue) < 1e-6;
        row.replace_status = "pending_write";

        replRows = [replRows; row]; %#ok<AGROW>
    end

    % Apply replacement with Excel COM to preserve xlsm
    if height(replRows) > 0
        applyReplacementWithExcelCOM(outFile, replRows);
        replRows.replace_status(:) = "written_to_copy";
    end

    nMismatch = sum(~replRows.old_matches_A3_original);

    summary = table();
    summary.input_macro_file = inputFile;
    summary.output_macro_file = string(outFile);
    summary.target_kind = targetKind;
    summary.macro_sheet = "tm";
    summary.No_header_cell = excelAddress(headerRow, noCol);
    summary.Fform_header_cell = excelAddress(headerRow, fformCol);
    summary.data_start_row = dataStartRow;
    summary.last_row_checked = lastRow;
    summary.N_replace_rows = height(replRows);
    summary.N_old_value_mismatch_vs_A3 = nMismatch;
    summary.min_No = min(replRows.No, [], 'omitnan');
    summary.max_No = max(replRows.No, [], 'omitnan');
    summary.mean_old_Fform = mean(replRows.workbook_old_value, 'omitnan');
    summary.mean_new_Fform = mean(replRows.replace_value, 'omitnan');
    summary.mean_delta_new_minus_old = mean(replRows.value_delta, 'omitnan');
    summary.max_abs_delta_new_minus_old = max(abs(replRows.value_delta), [], 'omitnan');
    summary.status = "copy_written_no_macro_run";

    if nMismatch > 0
        summary.status = "copy_written_with_old_value_mismatch_check";
    end
end

function applyReplacementWithExcelCOM(outFile, replRows)
    outFileFull = char(java.io.File(outFile).getCanonicalPath());

    try
        Excel = actxserver('Excel.Application');
    catch ME
        error("Excel COM could not start. This script requires Windows Excel to preserve .xlsm macros. Original error: %s", ME.message);
    end

    Excel.DisplayAlerts = false;
    Excel.Visible = false;

    wb = [];
    try
        wb = Excel.Workbooks.Open(outFileFull);
        ws = wb.Worksheets.Item('tm');

        for i = 1:height(replRows)
            r = replRows.excel_row(i);
            c = replRows.Fform_col(i);
            v = replRows.replace_value(i);
            ws.Range(char(excelAddress(r, c))).Value = v;
        end

        wb.Save();
        wb.Close(false);
        Excel.Quit();
        delete(Excel);
    catch ME
        try
            if ~isempty(wb)
                wb.Close(false);
            end
        catch
        end
        try
            Excel.Quit();
            delete(Excel);
        catch
        end
        rethrow(ME);
    end
end

function noCol = findHeaderCol(C, headerRow, candidates)
    noCol = NaN;
    candidatesNorm = normalizeText(string(candidates));

    for c = 1:size(C,2)
        s = normalizeText(cellToString(C{headerRow,c}));
        if any(s == candidatesNorm)
            noCol = c;
            return;
        end
    end

    % fuzzy for F_form
    for c = 1:size(C,2)
        s = normalizeText(cellToString(C{headerRow,c}));
        if any(contains(s, candidatesNorm)) || any(contains(candidatesNorm, s))
            if strlength(s) > 0
                noCol = c;
                return;
            end
        end
    end
end

function lastRow = findLastNumericNoRow(C, noCol, startRow)
    lastRow = startRow - 1;
    for r = startRow:size(C,1)
        v = cellToDouble(C{r,noCol});
        if isfinite(v)
            lastRow = r;
        end
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

function v = cellToDouble(x)
    if isnumeric(x) && isscalar(x)
        v = double(x);
    elseif islogical(x) && isscalar(x)
        v = double(x);
    elseif ischar(x) || isstring(x)
        v = str2double(string(x));
    else
        v = NaN;
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

function S = summarizeByKeys(T, keyVars)
    S = table();
    if height(T) == 0
        return;
    end

    keyVars = string(keyVars);
    key = strings(height(T),1);
    for v = keyVars
        key = key + "|" + string(T.(v));
    end

    keys = unique(key);

    for k = keys(:)'
        mask = key == k;
        R = T(mask,:);
        row = table();

        for v = keyVars
            row.(v) = R.(v)(1);
        end

        row.N_rows = height(R);
        row.N_old_match_A3 = sum(R.old_matches_A3_original);
        row.mean_old_Fform = mean(R.workbook_old_value, 'omitnan');
        row.mean_new_Fform = mean(R.replace_value, 'omitnan');
        row.mean_delta = mean(R.value_delta, 'omitnan');
        row.max_abs_delta = max(abs(R.value_delta), [], 'omitnan');
        row.min_No = min(R.No, [], 'omitnan');
        row.max_No = max(R.No, [], 'omitnan');

        S = [S; row]; %#ok<AGROW>
    end
end

function qc = makeQC(workbookSummary, rows)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("workbooks_processed", "OK", sprintf("%d", height(workbookSummary)), "処理したマクロブック数。期待値は2。");

    if all(workbookSummary.N_replace_rows > 0)
        add("replacement_rows", "OK", strjoin(string(workbookSummary.target_kind + "=" + string(workbookSummary.N_replace_rows)), ", "), "各マクロブックで置換行あり。");
    else
        add("replacement_rows", "CHECK", strjoin(string(workbookSummary.target_kind + "=" + string(workbookSummary.N_replace_rows)), ", "), "置換行が0のブックあり。");
    end

    if sum(workbookSummary.N_old_value_mismatch_vs_A3) == 0
        add("old_value_match_A3", "OK", "0 mismatches", "コピー前のF_form値がA3 original_valueと一致。");
    else
        add("old_value_match_A3", "CHECK", sprintf("%d mismatches", sum(workbookSummary.N_old_value_mismatch_vs_A3)), "コピー前値がA3 original_valueと一致しない行あり。");
    end

    if all(isfile(workbookSummary.output_macro_file))
        add("output_files_exist", "OK", "true", "コピー版マクロブックが作成された。");
    else
        add("output_files_exist", "CHECK", "false", "出力ファイルの存在を確認。");
    end

    add("edit_policy", "adopt", "copy_only", "元マクロブックは上書きしていない。");
    add("macro_run", "not_done", "manual_next", "このスクリプトはマクロを実行していない。");
    add("next", "next", "run_macro_then_BT10", "コピー版を開いてマクロ再計算し、その結果をBT10で診断する。");

    qc = table(item, status, value, reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function instructions = makeInstructions(workbookSummary)
    step = (1:7)';
    action = strings(7,1);
    detail = strings(7,1);

    action(1) = "Open copied macro workbooks";
    detail(1) = "Open the output xlsm files listed in BT09A_workbook_summary.";

    action(2) = "Enable macros if required";
    detail(2) = "Enable content only for the copied files, not the originals.";

    action(3) = "Confirm F_form column";
    detail(3) = "tm sheet BG column should contain Fform_linear values.";

    action(4) = "Run recalculation macro";
    detail(4) = "Run the same macro workflow used for the legacy calculation.";

    action(5) = "Save recalculated output";
    detail(5) = "Save with a name including FformLinear_v1_recalc.";

    action(6) = "Upload outputs";
    detail(6) = "Upload recalculated xlsm/xlsx and any run_report/log.";

    action(7) = "BT10 diagnosis";
    detail(7) = "Compare legacy vs FformLinear PM/q values.";

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
