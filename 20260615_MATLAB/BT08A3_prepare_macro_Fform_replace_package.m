%% BT08A3_prepare_macro_Fform_replace_package.m
% BT08-A3：マクロ投入用 F_form 差し替えパッケージを確定する
%
% 目的：
%   BT08-A2bで作成した current_bundle_input_v2b から、
%   マクロブックに投入するための F_form 差し替え表を作る。
%
%   ここではマクロブックを編集しない。
%   Excelを手作業でいじらないために、
%   「どの行の F_form を legacy から linear_v1 に置き換えるか」を
%   MATLAB出力として固定する。
%
% 入力：
%   H52Q_current_bundle_input_v2b_FformLinear_*.xlsx
%
% 出力：
%   BT08A3_macro_Fform_replace_package_yyyymmdd_HHMMSS.xlsx
%   BT08A3_macro_Fform_replace_map_yyyymmdd_HHMMSS.csv
%   run_report_BT08A3_macro_Fform_replace_package_yyyymmdd_HHMMSS.md
%
% 次：
%   BT09-0：
%     マクロブック側の F_form 入力位置を確認する。
%
% 注意：
%   - このスクリプトはマクロブックを編集しない。
%   - 元マクロブックを上書きしない。
%   - マクロ再計算はBT09以降で行う。

clear; clc;

%% ===== Settings =====

inputV2bFile = "";

if strlength(inputV2bFile) == 0
    inputV2bFile = findLatestFile("H52Q_current_bundle_input_v2b_FformLinear_*.xlsx");
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "BT08A3_macro_Fform_replace_package_" + timestamp + ".xlsx";
outCsv  = "BT08A3_macro_Fform_replace_map_" + timestamp + ".csv";
outMd   = "run_report_BT08A3_macro_Fform_replace_package_" + timestamp + ".md";

fprintf("Input v2b: %s\n", inputV2bFile);

%% ===== Read required sheets =====

replaceMap = readtable(inputV2bFile, 'Sheet', 'BT08A2b_macro_replace_map', 'VariableNamingRule', 'preserve');
master = readtable(inputV2bFile, 'Sheet', 'BT08A2b_Fform_linear_master', 'VariableNamingRule', 'preserve');
sheetInventory = readtable(inputV2bFile, 'Sheet', 'BT08A2b_sheet_inventory', 'VariableNamingRule', 'preserve');

%% ===== Normalize types =====

replaceMap = normalizeReplaceMap(replaceMap);

%% ===== Build macro package =====

% 1. Macro-ready map
macroMap = replaceMap;
macroMap.macro_input_status = repmat("ready_for_BT09_location_check", height(macroMap), 1);
macroMap.legacy_column_name_expected = repmat("F_form", height(macroMap), 1);
macroMap.linear_column_name_in_v2b = repmat("Fform_linear", height(macroMap), 1);
macroMap.replace_value = macroMap.Fform_linear;
macroMap.original_value = macroMap.Fform_legacy;
macroMap.value_delta = macroMap.Fform_diff_linear_minus_legacy;
macroMap.value_ratio = macroMap.Fform_ratio_linear_to_legacy;

% Keep a compact view for CSV / macro handoff
keepVars = [
    "sheet"
    "target_kind"
    "data_row_index"
    "excel_row_if_header1"
    "Bundle"
    "No"
    "nearest_master_case_label"
    "z_DNB_over_L_current"
    "master_z_DNB_ratio"
    "mapping_abs_dz"
    "legacy_column_name_expected"
    "linear_column_name_in_v2b"
    "original_value"
    "replace_value"
    "value_delta"
    "value_ratio"
    "mapping_status"
    "replace_action"
    "do_not_edit_original"
];

keepVars = keepVars(ismember(keepVars, string(macroMap.Properties.VariableNames)));
macroMapCompact = macroMap(:, keepVars);

% 2. Summaries
summaryBySheet = summarizeByKeys(macroMap, ["sheet","target_kind"]);
summaryByCase  = summarizeByKeys(macroMap, ["nearest_master_case_label","Bundle"]);
summaryByBundle = summarizeByKeys(macroMap, ["Bundle"]);

% 3. QC flags
qc = makeQCFlags(macroMap, sheetInventory, master);

% 4. Instructions
instructions = makeInstructions(inputV2bFile, outXlsx, outCsv);

%% ===== Write outputs =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(macroMapCompact, outXlsx, 'Sheet', 'A3_macro_replace_map');
writetable(macroMap, outXlsx, 'Sheet', 'A3_macro_replace_map_full');
writetable(summaryBySheet, outXlsx, 'Sheet', 'A3_summary_by_sheet');
writetable(summaryByCase, outXlsx, 'Sheet', 'A3_summary_by_case');
writetable(summaryByBundle, outXlsx, 'Sheet', 'A3_summary_by_bundle');
writetable(master, outXlsx, 'Sheet', 'A3_Fform_linear_master');
writetable(sheetInventory, outXlsx, 'Sheet', 'A3_v2b_sheet_inventory');
writetable(qc, outXlsx, 'Sheet', 'A3_QC_flags');
writetable(instructions, outXlsx, 'Sheet', 'A3_macro_handoff_steps');

writetable(macroMapCompact, outCsv);

fprintf("Wrote Excel: %s\n", outXlsx);
fprintf("Wrote CSV  : %s\n", outCsv);

%% ===== Write Markdown report =====

md = strings(0,1);

md(end+1) = "# BT08-A3 macro F_form replace package";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT08-A2bで作成したcurrent_bundle_input_v2bから、マクロブックへ投入するためのF_form差し替え表を確定する。この段階ではマクロブックを編集しない。";
md(end+1) = "";
md(end+1) = "## 2. 入力と出力";
md(end+1) = "";
md(end+1) = "- input v2b: `" + inputV2bFile + "`";
md(end+1) = "- output package: `" + outXlsx + "`";
md(end+1) = "- output csv: `" + outCsv + "`";
md(end+1) = "";
md(end+1) = "## 3. 方針";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "- 元マクロブックは編集しない。";
md(end+1) = "- マクロブックはBT09以降でコピーしてから編集する。";
md(end+1) = "- 差し替え対象はF_form列。";
md(end+1) = "- 差し替え値はFform_linear列。";
md(end+1) = "- legacy値はoriginal_valueとして保持する。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 4. QC flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(qc);
md(end+1) = "";
md(end+1) = "## 5. Summary by sheet";
md(end+1) = "";
md(end+1) = tableToMarkdown(summaryBySheet);
md(end+1) = "";
md(end+1) = "## 6. Summary by case";
md(end+1) = "";
md(end+1) = tableToMarkdown(summaryByCase);
md(end+1) = "";
md(end+1) = "## 7. Summary by bundle";
md(end+1) = "";
md(end+1) = tableToMarkdown(summaryByBundle);
md(end+1) = "";
md(end+1) = "## 8. Macro replace map preview";
md(end+1) = "";
md(end+1) = tableToMarkdown(firstN(macroMapCompact, 80));
md(end+1) = "";
md(end+1) = "## 9. Macro handoff steps";
md(end+1) = "";
md(end+1) = tableToMarkdown(instructions);
md(end+1) = "";
md(end+1) = "## 10. 次アクション";
md(end+1) = "";
md(end+1) = "1. `A3_QC_flags` がOKであることを確認する。";
md(end+1) = "2. `A3_macro_replace_map` の sheet / No / original_value / replace_value を確認する。";
md(end+1) = "3. 次はBT09-0として、マクロブック側のF_form入力位置を確認する。";
md(end+1) = "4. マクロブックをコピーし、コピー側だけにFform_linearを投入する。";
md(end+1) = "5. マクロ再計算後、BT10でPM影響を診断する。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display =====

disp("=== QC flags ===");
disp(qc);

disp("=== Summary by sheet ===");
disp(summaryBySheet);

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

    stringVars = ["sheet","target_kind","nearest_master_case_label","mapping_status","replace_target_column","new_value_column","replace_action","macro_note"];
    for v = stringVars
        if ismember(v, vars)
            T.(v) = string(T.(v));
        end
    end

    numericVars = ["data_row_index","excel_row_if_header1","Bundle","No","z_DNB_over_L_current","master_z_DNB_ratio","mapping_abs_dz","Fform_legacy","Fform_linear","Fform_diff_linear_minus_legacy","Fform_ratio_linear_to_legacy"];
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
        row.N_mapped = sum(R.mapping_status == "mapped" | R.mapping_status == "nearest_mapped");
        row.mean_original_value = mean(R.Fform_legacy, 'omitnan');
        row.mean_replace_value = mean(R.Fform_linear, 'omitnan');
        row.mean_delta = mean(R.Fform_diff_linear_minus_legacy, 'omitnan');
        row.max_abs_delta = max(abs(R.Fform_diff_linear_minus_legacy), [], 'omitnan');
        row.mean_ratio = mean(R.Fform_ratio_linear_to_legacy, 'omitnan');
        row.min_No = min(R.No, [], 'omitnan');
        row.max_No = max(R.No, [], 'omitnan');

        S = [S; row]; %#ok<AGROW>
    end
end

function qc = makeQCFlags(map, sheetInventory, master)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("input_rows", "OK", sprintf("%d", height(map)), "差し替え表の行数。期待値はnoF1 58 + F1 58 = 116。");

    nNoF1 = sum(map.target_kind == "noF1");
    nF1 = sum(map.target_kind == "F1");
    if nNoF1 == 58 && nF1 == 58
        add("target_kind_balance", "OK", sprintf("noF1=%d, F1=%d", nNoF1, nF1), "noF1/F1の両方を含む。");
    else
        add("target_kind_balance", "CHECK", sprintf("noF1=%d, F1=%d", nNoF1, nF1), "noF1/F1行数を確認。");
    end

    targetSheets = sheetInventory(sheetInventory.kind == "bundle_data_with_Fform_linear_added", :);
    if height(targetSheets) == 6
        add("target_sheet_count", "OK", "6", "6対象シートを確認。");
    else
        add("target_sheet_count", "CHECK", sprintf("%d", height(targetSheets)), "対象シート数が6ではない。");
    end

    nMapped = sum(map.mapping_status == "mapped" | map.mapping_status == "nearest_mapped");
    if nMapped == height(map)
        add("mapping_status", "OK", sprintf("%d/%d", nMapped, height(map)), "全行マップ済み。");
    else
        add("mapping_status", "CHECK", sprintf("%d/%d", nMapped, height(map)), "未マップ行あり。");
    end

    maxDz = max(abs(map.mapping_abs_dz), [], 'omitnan');
    if maxDz < 0.001
        add("mapping_abs_dz", "OK", sprintf("%.8g", maxDz), "DNB位置対応差は小さい。");
    else
        add("mapping_abs_dz", "CHECK", sprintf("%.8g", maxDz), "DNB位置対応差を確認。");
    end

    maxAbsDelta = max(abs(map.Fform_diff_linear_minus_legacy), [], 'omitnan');
    add("max_abs_Fform_change", "diagnostic", sprintf("%.8g", maxAbsDelta), "legacyからlinear_v1への最大変更量。");

    if height(master) == 5
        add("master_case_count", "OK", "5", "Fform linear masterは5ケース。");
    else
        add("master_case_count", "CHECK", sprintf("%d", height(master)), "masterケース数を確認。");
    end

    add("macro_edit_policy", "adopt", "copy_only", "元マクロブックは編集しない。コピー側にだけ適用する。");
    add("next", "next", "BT09-0", "マクロブック側のF_form入力位置確認へ進む。");

    qc = table(item, status, value, reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function instructions = makeInstructions(inputV2bFile, outXlsx, outCsv)
    step = (1:9)';
    action = strings(9,1);
    detail = strings(9,1);

    action(1) = "Confirm package";
    detail(1) = "Open " + outXlsx + " and check A3_QC_flags.";

    action(2) = "Confirm replacement map";
    detail(2) = "Check A3_macro_replace_map: sheet, target_kind, No, original_value, replace_value.";

    action(3) = "Do not edit original macro workbook";
    detail(3) = "Make a copy of the macro workbook before changing F_form.";

    action(4) = "Find F_form input location";
    detail(4) = "BT09-0 should identify the exact sheet and column in the macro workbook where F_form is read.";

    action(5) = "Apply replacement only to copy";
    detail(5) = "Use replace_value from " + outCsv + " or A3_macro_replace_map.";

    action(6) = "Keep legacy file";
    detail(6) = "Original macro workbook and current_bundle_input_v1 remain unchanged.";

    action(7) = "Run macro";
    detail(7) = "Run only noF1/F1 comparison unless intentionally expanding scope.";

    action(8) = "Export recalculated results";
    detail(8) = "Save the macro output with a new name including FformLinear or linear_v1.";

    action(9) = "Run BT10";
    detail(9) = "Use recalculated output to diagnose PM impact of Fform_linear.";

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
