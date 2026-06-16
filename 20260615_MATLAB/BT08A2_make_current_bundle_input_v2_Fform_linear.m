%% BT08A2_make_current_bundle_input_v2_Fform_linear.m
% BT08-A2：current_bundle_input_v2へ Fform_linear / Fform_legacy を集約する
%
% 目的：
%   Excelを手作業でいじらず、MATLABで current_bundle_input_v2 を作る。
%
%   BT08-A1dで確定した F_form linear_v1 を、
%   current_bundle_input_v1 の各 noF1/F1 シートに追記する。
%
%   重要：
%     - 既存の F_form 列は上書きしない。
%     - 既存F_formは Fform_legacy として残す。
%     - 新しい正本候補は Fform_linear として別列に追加する。
%     - マクロ再計算はまだ行わない。
%     - マクロ投入用の差し替え表も同時に出す。
%
% 入力：
%   H52Q_current_bundle_input_v1_*.xlsx
%   バンドルデータ整理r3.xlsx
%
% 出力：
%   H52Q_current_bundle_input_v2_FformLinear_yyyymmdd_HHMMSS.xlsx
%   run_report_BT08A2_current_bundle_input_v2_FformLinear_yyyymmdd_HHMMSS.md
%
% 次：
%   BT08-A3 / BT09-0：
%     マクロブック側のF_form入力位置を確認し、
%     Fform_linear版再計算の差し替え手順を作る。

clear; clc;

%% ===== Settings =====

inputCurrentFile = "";
inputR3File = "";

if strlength(inputCurrentFile) == 0
    inputCurrentFile = findLatestFile("H52Q_current_bundle_input_v1_*.xlsx");
end

if strlength(inputR3File) == 0
    inputR3File = findLatestFile("バンドルデータ整理r*.xlsx");
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "H52Q_current_bundle_input_v2_FformLinear_" + timestamp + ".xlsx";
outMd   = "run_report_BT08A2_current_bundle_input_v2_FformLinear_" + timestamp + ".md";

fprintf("Input current_bundle v1: %s\n", inputCurrentFile);
fprintf("Input r3 workbook      : %s\n", inputR3File);

%% ===== Build Fform_linear master from r3 =====

bundles = [108, 161, 164];

profilePoints = table();

for b = bundles
    shBase = "非一様加熱を一様加熱に補正" + string(b);
    sh = resolveSheetName(inputR3File, shBase);
    P = readProfileSheet(inputR3File, sh, b);
    profilePoints = [profilePoints; P]; %#ok<AGROW>
end

dnbAnchors = readXeqSummary(inputR3File);

FformMaster = table();

for i = 1:height(dnbAnchors)
    b = dnbAnchors.Bundle(i);
    zD = dnbAnchors.z_ratio(i);

    P = profilePoints(profilePoints.Bundle == b, :);
    row = computeLinearFform(P, b, zD);

    row.Fform_definition_version = "linear_v1";
    row.Fform_source_book = string(inputR3File);
    row.Fform_source_sheet = row.profile_sheet;
    row.r3_blue_area_stored_legacy_like = dnbAnchors.numerator_r3(i);
    row.r3_total_area_stored = dnbAnchors.denominator_r3(i);
    row.r3_z_heat_ratio_stored = dnbAnchors.z_heat_ratio(i);
    row.r3_note = dnbAnchors.note(i);

    row.case_label = inferCaseLabel(b, zD);
    row.Fform_status = "adopt_linear_v1";
    if b == 161
        row.Fform_status = "uniform_or_nearly_uniform";
    end

    FformMaster = [FformMaster; row]; %#ok<AGROW>
end

% Reorder
FformMaster = movevars(FformMaster, ["Fform_definition_version","case_label"], "Before", "Bundle");

%% ===== Read current workbook sheets and create v2 =====

try
    sheets = string(sheetnames(inputCurrentFile));
catch
    [~, rawSheets] = xlsfinfo(inputCurrentFile);
    sheets = string(rawSheets);
end

if exist(outXlsx, "file")
    delete(outXlsx);
end

sheetInventory = table();
rowMapping = table();
targetSheets = strings(0,1);

for sh = sheets(:)'
    isTarget = isBundleDataSheet(sh);

    if isTarget
        T = readtable(inputCurrentFile, 'Sheet', sh, 'VariableNamingRule', 'preserve');
        [T2, mapT] = addFformLinearColumns(T, sh, FformMaster);
        writetable(T2, outXlsx, 'Sheet', sh);

        targetSheets(end+1,1) = sh; %#ok<AGROW>
        rowMapping = [rowMapping; mapT]; %#ok<AGROW>

        inv = table();
        inv.sheet = sh;
        inv.kind = "bundle_data_with_Fform_linear_added";
        inv.rows = height(T2);
        inv.cols = width(T2);
        inv.mapped_rows = sum(mapT.mapping_status == "mapped" | mapT.mapping_status == "nearest_mapped");
        inv.unmapped_rows = sum(~(mapT.mapping_status == "mapped" | mapT.mapping_status == "nearest_mapped"));
        sheetInventory = [sheetInventory; inv]; %#ok<AGROW>
    else
        % Preserve non-target sheets as best as possible.
        % Some sheets may not be rectangular tables, so use readcell/writecell.
        try
            C = readcell(inputCurrentFile, 'Sheet', sh);
            writecell(C, outXlsx, 'Sheet', sh);
            rows = size(C,1); cols = size(C,2);
            kind = "copied_as_cell_sheet";
        catch
            rows = NaN; cols = NaN;
            kind = "copy_failed_or_unsupported";
        end

        inv = table();
        inv.sheet = sh;
        inv.kind = kind;
        inv.rows = rows;
        inv.cols = cols;
        inv.mapped_rows = NaN;
        inv.unmapped_rows = NaN;
        sheetInventory = [sheetInventory; inv]; %#ok<AGROW>
    end
end

%% ===== Macro replacement map =====

macroReplaceMap = rowMapping;
if height(macroReplaceMap) > 0
    macroReplaceMap.replace_action = repmat("replace_legacy_F_form_with_Fform_linear_in_macro_copy_only", height(macroReplaceMap), 1);
    macroReplaceMap.do_not_edit_original = repmat(true, height(macroReplaceMap), 1);
    macroReplaceMap.macro_note = repmat("This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook.", height(macroReplaceMap), 1);
end

%% ===== Summary tables =====

caseSummary = summarizeByCase(rowMapping);
diffSummary = summarizeDiff(rowMapping);
decision = makeDecision(FformMaster, sheetInventory, rowMapping, macroReplaceMap);

fieldsV2 = cell2table({
    "Fform_definition_version", "linear_v1", "F_form定義バージョン"
    "Fform_source_book", "バンドルデータ整理r3.xlsx", "軸方向出力分布の出典"
    "Fform_source_sheet", "非一様加熱を一様加熱に補正108/161/164", "軸方向出力分布シート"
    "Fform_case_label", "108_70in / 108_76in / 161_uniform / 164_112in / 164_134in_normal", "DNB位置別の識別"
    "Fform_DNB_z_ratio_linear", "x_DNB = DNB位置 / 加熱長", "DNB位置"
    "Fform_q_DNB_linear", "interp1(x,f,x_DNB)", "DNB位置の軸方向係数"
    "Fform_blue_area_linear", "integral_0^xDNB f(x) dx by linear interpolation", "DNB位置までの線形補間積分面積"
    "Fform_orange_area_linear", "x_DNB * q_DNB_linear", "基準長方形面積"
    "Fform_linear", "Fform_blue_area_linear / Fform_orange_area_linear", "修正後F_form"
    "Fform_legacy", "existing F_form in current_bundle_input_v1", "既存F_form"
    "Fform_diff_linear_minus_legacy", "Fform_linear - Fform_legacy", "定義変更差"
    "Fform_ratio_linear_to_legacy", "Fform_linear / Fform_legacy", "定義変更比"
    "Fform_mapping_status", "mapped / nearest_mapped / no_DNB_columns / no_master", "行対応状態"
    "Fform_definition_note", "全ケースを線形補間・線形積分で統一。legacyは上書きせず保持。", "定義メモ"
}, 'VariableNames', {'field','suggested_value_or_formula','meaning'});

%% ===== Write additional sheets =====

writetable(FformMaster, outXlsx, 'Sheet', 'BT08A2_Fform_linear_master');
writetable(rowMapping, outXlsx, 'Sheet', 'BT08A2_row_mapping');
writetable(macroReplaceMap, outXlsx, 'Sheet', 'BT08A2_macro_replace_map');
writetable(caseSummary, outXlsx, 'Sheet', 'BT08A2_case_summary');
writetable(diffSummary, outXlsx, 'Sheet', 'BT08A2_diff_summary');
writetable(sheetInventory, outXlsx, 'Sheet', 'BT08A2_sheet_inventory');
writetable(fieldsV2, outXlsx, 'Sheet', 'BT08A2_fields_added');
writetable(decision, outXlsx, 'Sheet', 'BT08A2_decision_flags');

fprintf("Wrote current_bundle v2: %s\n", outXlsx);

%% ===== Write Markdown report =====

md = strings(0,1);

md(end+1) = "# BT08-A2 current_bundle_input_v2 FformLinear";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT08-A1dで確定したF_form linear_v1をcurrent_bundle_input_v1へ集約し、current_bundle_input_v2を作成する。既存F_formは上書きせずlegacyとして残し、Fform_linearを別列として追加する。";
md(end+1) = "";
md(end+1) = "## 2. 入力と出力";
md(end+1) = "";
md(end+1) = "- input current_bundle v1: `" + inputCurrentFile + "`";
md(end+1) = "- input r3: `" + inputR3File + "`";
md(end+1) = "- output current_bundle v2: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 3. 方針";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "- 既存F_form列は上書きしない。";
md(end+1) = "- 既存F_formは Fform_legacy として残す。";
md(end+1) = "- 新しい定義は Fform_linear として追加する。";
md(end+1) = "- current_bundle_input_v2作成段階ではマクロ再計算しない。";
md(end+1) = "- マクロ用には BT08A2_macro_replace_map を別途出す。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 4. Fform linear master";
md(end+1) = "";
md(end+1) = tableToMarkdown(FformMaster);
md(end+1) = "";
md(end+1) = "## 5. Sheet inventory";
md(end+1) = "";
md(end+1) = tableToMarkdown(sheetInventory);
md(end+1) = "";
md(end+1) = "## 6. Case summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(caseSummary);
md(end+1) = "";
md(end+1) = "## 7. Diff summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(diffSummary);
md(end+1) = "";
md(end+1) = "## 8. Macro replacement map preview";
md(end+1) = "";
md(end+1) = tableToMarkdown(firstN(macroReplaceMap, 40));
md(end+1) = "";
md(end+1) = "## 9. Decision flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(decision);
md(end+1) = "";
md(end+1) = "## 10. 次アクション";
md(end+1) = "";
md(end+1) = "1. 出力された current_bundle_input_v2 の `BT08A2_Fform_linear_master` と `BT08A2_row_mapping` を確認する。";
md(end+1) = "2. 問題なければ、次はBT08-A3としてマクロ投入用F_form差し替え表を確定する。";
md(end+1) = "3. その後BT09-0として、マクロブック側のF_form入力位置を確認する。";
md(end+1) = "4. マクロブックは必ずコピーしてから、Fform_linear版を作る。";
md(end+1) = "5. Fform_linear版のマクロ再計算後、BT10としてPM影響を再診断する。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display =====

disp("=== FformMaster ===");
disp(FformMaster(:, ["case_label","Bundle","z_DNB_ratio","f_DNB_linear","Blue_area_linear","Orange_area_linear","Fform_linear"]));

disp("=== diffSummary ===");
disp(diffSummary);

disp("=== decision ===");
disp(decision);

%% ===== Local functions =====

function latest = findLatestFile(pattern)
    d = dir(pattern);
    if isempty(d)
        error("No file matching pattern: %s", pattern);
    end
    [~, idx] = max([d.datenum]);
    latest = string(d(idx).name);
end

function latest = findLatestFileOptional(pattern)
    d = dir(pattern);
    if isempty(d)
        latest = "";
        return;
    end
    [~, idx] = max([d.datenum]);
    latest = string(d(idx).name);
end

function s = nullText(x)
    if strlength(string(x)) == 0
        s = "なし";
    else
        s = string(x);
    end
end

function tf = isBundleDataSheet(sh)
    s = lower(string(sh));
    tf = (contains(s, "tm_f1_") || contains(s, "tm_nof1_") || contains(s, "tm_noF1_")) ...
        && (contains(s, "108") || contains(s, "161") || contains(s, "164"));
    % MATLAB lower makes noF1 check redundant, but kept for clarity.
end

function actualName = resolveSheetName(file, desiredName)
    desiredName = string(desiredName);
    try
        sheets = string(sheetnames(file));
    catch
        [~, rawSheets] = xlsfinfo(file);
        sheets = string(rawSheets);
    end

    idx = find(sheets == desiredName, 1);
    if ~isempty(idx)
        actualName = sheets(idx);
        return;
    end

    idx = find(strtrim(sheets) == strtrim(desiredName), 1);
    if ~isempty(idx)
        actualName = sheets(idx);
        return;
    end

    idx = find(contains(strtrim(sheets), strtrim(desiredName)), 1);
    if ~isempty(idx)
        actualName = sheets(idx);
        return;
    end

    fprintf("Available sheets:\n");
    disp(sheets(:));
    error("Sheet not found. desired=[%s]", desiredName);
end

function P = readProfileSheet(file, sheetName, bundle)
    C = readcell(file, 'Sheet', sheetName);

    % 優先：E/F列 = z, f(x)
    z = getNumericCol(C, 5);
    f = getNumericCol(C, 6);
    ok = isfinite(z) & isfinite(f) & z >= 0 & z <= 1.0000001;

    if sum(ok) < 3
        % 代替：A/C列
        z = getNumericCol(C, 1);
        f = getNumericCol(C, 3);
        ok = isfinite(z) & isfinite(f) & z >= 0 & z <= 1.0000001;
        source_cols = "A/C";
    else
        source_cols = "E/F";
    end

    z = z(ok);
    f = f(ok);

    [z, idx] = sort(z);
    f = f(idx);

    [zu, ~, ic] = unique(z);
    fu = accumarray(ic, f, [], @mean);
    z = zu;
    f = fu;

    P = table();
    P.Bundle = repmat(bundle, numel(z), 1);
    P.profile_sheet = repmat(string(sheetName), numel(z), 1);
    P.source_cols = repmat(string(source_cols), numel(z), 1);
    P.point_index = (1:numel(z))';
    P.z = z;
    P.f = f;
end

function X = readXeqSummary(file)
    sheetName = resolveSheetName(file, "02_xeq_recalc");
    C = readcell(file, 'Sheet', sheetName);

    X = table();
    X.Bundle = zeros(0,1);
    X.z_ratio = zeros(0,1);
    X.z_heat_ratio = zeros(0,1);
    X.note = strings(0,1);
    X.row_in_sheet = zeros(0,1);
    X.numerator_r3 = zeros(0,1);
    X.denominator_r3 = zeros(0,1);

    rows = [];
    for i = 1:size(C,1)
        b = cellToDouble(C{i,1});
        zratio = cellToDouble(C{i,2});
        zheat = cellToDouble(C{i,5});

        if ismember(round(b), [108,161,164]) && isfinite(zratio) && zratio >= 0 && zratio <= 1.2 && isfinite(zheat) && zheat >= 0 && zheat <= 1.2
            rows = [rows; i]; %#ok<AGROW>
        end
    end

    rows = rows(rows < 20);

    for k = 1:numel(rows)
        i = rows(k);
        newRow = table();
        newRow.Bundle = round(cellToDouble(C{i,1}));
        newRow.z_ratio = cellToDouble(C{i,2});
        newRow.numerator_r3 = cellToDouble(C{i,3});
        newRow.denominator_r3 = cellToDouble(C{i,4});
        newRow.z_heat_ratio = cellToDouble(C{i,5});
        newRow.note = cellToString(C{i,6});
        newRow.row_in_sheet = i;

        X = [X; newRow]; %#ok<AGROW>
    end
end

function row = computeLinearFform(P, bundle, zD)
    z = P.z(:);
    f = P.f(:);

    [z, idx] = sort(z);
    f = f(idx);

    fD = interp1(z, f, zD, 'linear', 'extrap');
    blue = integrateExactToZ(z, f, zD);
    orange = zD * fD;
    F = safeRatio(blue, orange);

    row = table();
    row.Bundle = bundle;
    row.z_DNB_ratio = zD;
    row.profile_sheet = P.profile_sheet(1);
    row.profile_source_cols = P.source_cols(1);
    row.profile_N = numel(z);
    row.z_min = min(z);
    row.z_max = max(z);
    row.f_DNB_linear = fD;
    row.Blue_area_linear = blue;
    row.Orange_area_linear = orange;
    row.Fform_linear = F;
    row.Blue_area_method = "linear_integral_0_to_xDNB";
    row.f_DNB_method = "linear_interp_at_xDNB";
    row.Orange_area_method = "xDNB_times_fDNB";
end

function val = integrateExactToZ(z, f, zD)
    z = z(:);
    f = f(:);

    [z, idx] = sort(z);
    f = f(idx);

    if zD <= z(1)
        val = 0;
        return;
    end

    val = 0;

    for i = 1:numel(z)-1
        z0 = z(i);
        z1 = z(i+1);
        f0 = f(i);
        f1 = f(i+1);

        if z0 >= zD
            break;
        end

        zz1 = min(z1, zD);
        if zz1 <= z0
            continue;
        end

        ff1 = f0 + (f1 - f0) * (zz1 - z0) / (z1 - z0);
        val = val + (f0 + ff1) / 2 * (zz1 - z0);

        if z1 >= zD
            break;
        end
    end
end

function label = inferCaseLabel(bundle, zD)
    if bundle == 108 && abs(zD - 70/96) < 1e-4
        label = "108_70in";
    elseif bundle == 108 && abs(zD - 76/96) < 1e-4
        label = "108_76in";
    elseif bundle == 161
        label = "161_uniform";
    elseif bundle == 164 && abs(zD - 112/168) < 1e-4
        label = "164_112in";
    elseif bundle == 164 && abs(zD - 134/168) < 1e-4
        label = "164_134in_normal";
    else
        label = "unknown";
    end
end

function [T2, mapT] = addFformLinearColumns(T, sh, master)
    T2 = T;
    n = height(T);

    bundle = inferBundleFromSheet(sh);

    Flegacy = getNumColFromTable(T, ["F_form","Fform","F_FORM"]);
    L_DNB = getNumColFromTable(T, ["L_DNB","LDNB","z_DNB","zDNB"]);
    L = getNumColFromTable(T, ["L","HeatedLength","L_heat"]);
    DH = getNumColFromTable(T, ["DH","D_h","Dh"]);
    No = getNumColFromTable(T, ["No","NO","no"]);

    zRatio = L_DNB ./ L;
    zDH = L_DNB ./ DH;

    % initialize added columns
    T2.Fform_definition_version = repmat("linear_v1", n, 1);
    T2.Fform_case_label = strings(n,1);
    T2.Fform_DNB_z_ratio_linear = NaN(n,1);
    T2.Fform_q_DNB_linear = NaN(n,1);
    T2.Fform_blue_area_linear = NaN(n,1);
    T2.Fform_orange_area_linear = NaN(n,1);
    T2.Fform_linear = NaN(n,1);
    T2.Fform_legacy = Flegacy;
    T2.Fform_diff_linear_minus_legacy = NaN(n,1);
    T2.Fform_ratio_linear_to_legacy = NaN(n,1);
    T2.Fform_mapping_status = strings(n,1);
    T2.Fform_definition_note = repmat("linear_v1: f_DNB=interp1(x,f,x_DNB), Blue_area=integral_0^xDNB f(x)dx, Orange=x_DNB*f_DNB. Existing F_form kept as legacy.", n, 1);

    mapT = table();

    M = master(master.Bundle == bundle, :);

    for i = 1:n
        status = "unmapped";
        idx = NaN;
        dz = NaN;

        if height(M) == 0
            status = "no_master_for_bundle";
        elseif ~isfinite(zRatio(i))
            status = "no_DNB_or_L_columns";
        else
            [dz, idx] = min(abs(M.z_DNB_ratio - zRatio(i)));
            if dz <= 0.015
                status = "mapped";
            else
                status = "nearest_mapped";
            end

            T2.Fform_case_label(i) = M.case_label(idx);
            T2.Fform_DNB_z_ratio_linear(i) = M.z_DNB_ratio(idx);
            T2.Fform_q_DNB_linear(i) = M.f_DNB_linear(idx);
            T2.Fform_blue_area_linear(i) = M.Blue_area_linear(idx);
            T2.Fform_orange_area_linear(i) = M.Orange_area_linear(idx);
            T2.Fform_linear(i) = M.Fform_linear(idx);
            T2.Fform_diff_linear_minus_legacy(i) = T2.Fform_linear(i) - Flegacy(i);
            T2.Fform_ratio_linear_to_legacy(i) = safeRatio(T2.Fform_linear(i), Flegacy(i));
        end

        T2.Fform_mapping_status(i) = status;

        row = table();
        row.sheet = string(sh);
        row.data_row_index = i;
        row.excel_row_if_header1 = i + 1;
        row.Bundle = bundle;
        row.No = No(i);
        row.z_DNB_over_L_current = zRatio(i);
        row.z_DNB_over_DH_current = zDH(i);
        row.nearest_master_case_label = T2.Fform_case_label(i);
        row.master_z_DNB_ratio = T2.Fform_DNB_z_ratio_linear(i);
        row.mapping_abs_dz = dz;
        row.Fform_legacy = Flegacy(i);
        row.Fform_linear = T2.Fform_linear(i);
        row.Fform_diff_linear_minus_legacy = T2.Fform_diff_linear_minus_legacy(i);
        row.Fform_ratio_linear_to_legacy = T2.Fform_ratio_linear_to_legacy(i);
        row.mapping_status = status;
        row.replace_target_column = "F_form";
        row.new_value_column = "Fform_linear";

        mapT = [mapT; row]; %#ok<AGROW>
    end
end

function bundle = inferBundleFromSheet(sh)
    s = string(sh);
    if contains(s, "108")
        bundle = 108;
    elseif contains(s, "161")
        bundle = 161;
    elseif contains(s, "164")
        bundle = 164;
    else
        bundle = NaN;
    end
end

function Tsum = summarizeByCase(rowMapping)
    Tsum = table();
    if height(rowMapping) == 0
        return;
    end

    keys = unique(rowMapping.nearest_master_case_label);
    keys = keys(strlength(keys) > 0);

    for k = keys(:)'
        R = rowMapping(rowMapping.nearest_master_case_label == k, :);
        row = table();
        row.case_label = k;
        row.Bundle = mode(R.Bundle);
        row.N_rows = height(R);
        row.N_mapped = sum(R.mapping_status == "mapped" | R.mapping_status == "nearest_mapped");
        row.mean_Fform_legacy = mean(R.Fform_legacy, 'omitnan');
        row.mean_Fform_linear = mean(R.Fform_linear, 'omitnan');
        row.mean_diff_linear_minus_legacy = mean(R.Fform_diff_linear_minus_legacy, 'omitnan');
        row.mean_ratio_linear_to_legacy = mean(R.Fform_ratio_linear_to_legacy, 'omitnan');
        row.min_z_current = min(R.z_DNB_over_L_current, [], 'omitnan');
        row.max_z_current = max(R.z_DNB_over_L_current, [], 'omitnan');
        Tsum = [Tsum; row]; %#ok<AGROW>
    end
end

function D = summarizeDiff(rowMapping)
    D = table();
    if height(rowMapping) == 0
        return;
    end

    bundles = unique(rowMapping.Bundle);
    for b = bundles(:)'
        R = rowMapping(rowMapping.Bundle == b, :);
        row = table();
        row.Bundle = b;
        row.N_rows = height(R);
        row.mean_Fform_legacy = mean(R.Fform_legacy, 'omitnan');
        row.mean_Fform_linear = mean(R.Fform_linear, 'omitnan');
        row.mean_diff_linear_minus_legacy = mean(R.Fform_diff_linear_minus_legacy, 'omitnan');
        row.max_abs_diff = max(abs(R.Fform_diff_linear_minus_legacy), [], 'omitnan');
        row.mean_ratio_linear_to_legacy = mean(R.Fform_ratio_linear_to_legacy, 'omitnan');
        D = [D; row]; %#ok<AGROW>
    end
end

function decision = makeDecision(master, sheetInventory, rowMapping, macroReplaceMap)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("BT08A2_position", "OK", "", "current_bundle_input_v2にFform_linearとlegacy列を集約した。マクロ再計算はまだ行わない。");
    add("definition", "adopt", "linear_v1", "F_form定義は全ケースで線形補間・線形積分に統一。");
    add("legacy_policy", "adopt", "keep_legacy", "既存F_formは上書きせずFform_legacyとして残す。");
    add("master_cases", "OK", sprintf("N=%d", height(master)), "Fform_linear masterを作成。");
    add("target_sheets", "OK", sprintf("N=%d", sum(sheetInventory.kind=="bundle_data_with_Fform_linear_added")), "noF1/F1の108/161/164対象シートに列を追加。");

    if height(rowMapping) > 0
        add("row_mapping", "OK", sprintf("rows=%d", height(rowMapping)), "行ごとのlegacy→linear対応表を作成。");
        add("max_abs_diff", "diagnostic", sprintf("%.8g", max(abs(rowMapping.Fform_diff_linear_minus_legacy), [], 'omitnan')), "Fform_linearとlegacyの最大差。");
    else
        add("row_mapping", "NG", "rows=0", "行対応表が空。シート名または列名を確認する必要がある。");
    end

    add("macro_replace_map", "prepared", sprintf("rows=%d", height(macroReplaceMap)), "次段階でマクロブックのコピーに適用する差し替え表。");
    add("next", "next", "BT08-A3 / BT09-0", "マクロ投入用差し替え表の確認とマクロブック側F_form入力位置確認へ進む。");

    decision = table(item, status, value, reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function x = getNumericCol(C, col)
    n = size(C,1);
    x = NaN(n,1);
    for i = 1:n
        x(i) = cellToDouble(C{i,col});
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
    if ismissing(x)
        s = "";
    elseif ischar(x) || isstring(x)
        s = string(x);
    elseif isnumeric(x) && isscalar(x) && isfinite(x)
        s = string(x);
    elseif islogical(x) && isscalar(x)
        s = string(x);
    else
        s = "";
    end
end

function r = safeRatio(a, b)
    r = NaN(size(a));
    ok = isfinite(a) & isfinite(b) & abs(b) > 0;
    r(ok) = a(ok) ./ b(ok);
end

function v = getNumColFromTable(T, candidates)
    name = findColumn(T, candidates);
    if strlength(name) == 0
        v = NaN(height(T),1);
        return;
    end

    raw = T.(char(name));
    if isnumeric(raw)
        v = double(raw);
    elseif iscell(raw)
        v = str2double(string(raw));
    else
        v = str2double(string(raw));
    end
end

function name = findColumn(T, candidates)
    vars = string(T.Properties.VariableNames);

    for c = string(candidates)
        idx = find(vars == c, 1);
        if ~isempty(idx)
            name = vars(idx);
            return;
        end
    end

    normVars = normalizeNames(vars);
    for c = string(candidates)
        nc = normalizeNames(c);
        idx = find(normVars == nc, 1);
        if ~isempty(idx)
            name = vars(idx);
            return;
        end
    end

    name = "";
end

function s = normalizeNames(s)
    s = lower(string(s));
    s = regexprep(s, "[^a-z0-9]", "");
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
