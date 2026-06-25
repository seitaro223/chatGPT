%% BT12C_make_current_bundle_input_v2_tmCompatible.m
% BT12-C：current_bundle_input_v2をtm互換構成で作り直す
%
% 背景：
%   BT12-B minimal版では、tmシートの列を削りすぎた。
%   current_bundle_input の利点は、tmシートがマクロブック由来の列構成と対応していることだった。
%
% 目的：
%   - v1のtmシート列構成を維持する。
%   - 変更はF_form列の値だけに限定する。
%   - 追加管理列はtmシートへ入れない。
%   - FformLinear_v1の正本化情報・legacy扱い・QCはREADME_BT12Cとrun_reportへ逃がす。
%
% 方針：
%   - v1は上書きしない。
%   - BT12-B minimal版は今後の入力には使わない。
%   - BT12-Cを今後のバンドル解析入力候補にする。
%   - tm_108 / tm_161 / tm_164 / tm_F1_108 / tm_F1_161 / tm_F1_164 は、
%     v1と同じ列数・同じ列名・同じ列順を維持する。
%   - F_form列だけをFformLinear_v1に置換する。
%   - README_BT12Cだけを追加し、そこに監査情報を入れる。
%
% 入力：
%   H52Q_current_bundle_input_v1_20260615_180822.xlsx
%   BT08A3_macro_Fform_replace_package_*.xlsx
%      または BT08A3_macro_Fform_replace_map_*.csv
%
% 出力：
%   H52Q_current_bundle_input_v2_FformLinearCanonical_tmCompatible_yyyymmdd_HHMMSS.xlsx
%   run_report_BT12C_current_bundle_input_v2_tmCompatible_yyyymmdd_HHMMSS.md
%
% 注意：
%   - legacy F_formはtmシート内には残さない。
%   - legacy F_formは、v1、BT08A3 map、run_report、working_logで追跡する。
%   - legacyは感度比較ではなく、deprecated / audit only。
%   - このスクリプトは補正式を作らない。

clear; clc;

%% ===== Settings =====

inputBundleV1File = "H52Q_current_bundle_input_v1_20260615_180822.xlsx";
inputFformMapFile = "";

if ~isfile(inputBundleV1File)
    inputBundleV1File = findLatestFile("H52Q_current_bundle_input_v1_*.xlsx");
end

if strlength(inputFformMapFile) == 0
    d1 = dir("BT08A3_macro_Fform_replace_package_*.xlsx");
    d2 = dir("BT08A3_macro_Fform_replace_map_*.csv");

    if ~isempty(d1)
        [~, idx] = max([d1.datenum]);
        inputFformMapFile = string(d1(idx).name);
    elseif ~isempty(d2)
        [~, idx] = max([d2.datenum]);
        inputFformMapFile = string(d2(idx).name);
    else
        error("No BT08A3 Fform replace package/map found.");
    end
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "H52Q_current_bundle_input_v2_FformLinearCanonical_tmCompatible_" + timestamp + ".xlsx";
outMd   = "run_report_BT12C_current_bundle_input_v2_tmCompatible_" + timestamp + ".md";

targetSheets = [
    "tm_108"
    "tm_161"
    "tm_164"
    "tm_F1_108"
    "tm_F1_161"
    "tm_F1_164"
];

fprintf("Input bundle v1 : %s\n", inputBundleV1File);
fprintf("Input Fform map : %s\n", inputFformMapFile);
fprintf("Output v2       : %s\n", outXlsx);

%% ===== Read map =====

Mraw = readFformMap(inputFformMapFile);
M = normalizeFformMap(Mraw);

%% ===== Build tm-compatible workbook =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

sheetSummary = table();
rowAudit = table();

for sh = targetSheets(:)'
    fprintf("Processing sheet: %s\n", sh);

    T0 = readtable(inputBundleV1File, 'Sheet', sh, 'VariableNamingRule', 'preserve');

    originalVars = string(T0.Properties.VariableNames);
    originalWidth = width(T0);

    [T1, audit] = replaceOnlyFform(T0, M, sh);

    newVars = string(T1.Properties.VariableNames);
    newWidth = width(T1);

    if originalWidth ~= newWidth || any(originalVars ~= newVars)
        error("Column structure changed in %s. This should not happen.", sh);
    end

    writetable(T1, outXlsx, 'Sheet', sh);

    S = summarizeSheet(T0, T1, audit, sh);
    sheetSummary = [sheetSummary; S]; %#ok<AGROW>

    rowAudit = [rowAudit; audit]; %#ok<AGROW>
end

%% ===== README sheet only =====

readme = makeReadme(inputBundleV1File, inputFformMapFile, outXlsx, sheetSummary, rowAudit);
writetable(readme, outXlsx, 'Sheet', 'README_BT12C');

workbookQC = makeWorkbookQC(sheetSummary, rowAudit, inputBundleV1File, inputFformMapFile, outXlsx);

%% ===== Markdown report =====

md = strings(0,1);

md(end+1) = "# BT12-C current_bundle_input v2 tmCompatible FformLinearCanonical";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT12-B minimal版ではtmシートの列を削りすぎたため、v1のtm列構成を保持したままF_form列のみをFformLinear_v1へ置換するtm互換版を作成する。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- bundle v1: `" + inputBundleV1File + "`";
md(end+1) = "- Fform map: `" + inputFformMapFile + "`";
md(end+1) = "";
md(end+1) = "## 3. 出力";
md(end+1) = "";
md(end+1) = "- output v2 tmCompatible: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 4. 方針";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "- tmシートの列数・列名・列順はv1と同じにする。";
md(end+1) = "- tmシートに追加管理列を入れない。";
md(end+1) = "- 変更はF_form列の値だけに限定する。";
md(end+1) = "- README_BT12Cだけを追加し、正本化・legacy扱い・QCはそこへ逃がす。";
md(end+1) = "- BT12-B minimal版は今後の入力には使わない。";
md(end+1) = "- legacy F_formは感度比較ではなくdeprecated / audit only。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 5. 対象シート";
md(end+1) = "";
md(end+1) = "```text";
for sh = targetSheets(:)'
    md(end+1) = sh;
end
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 6. Sheet summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(sheetSummary);
md(end+1) = "";
md(end+1) = "## 7. Workbook QC";
md(end+1) = "";
md(end+1) = tableToMarkdown(workbookQC);
md(end+1) = "";
md(end+1) = "## 8. 判断";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "BT12-B minimal版は列を削りすぎたため、今後の入力としては不採用とする。";
md(end+1) = "BT12-Cでは、v1と同じtm列構成を維持し、F_form列だけをFformLinear_v1へ置換した。";
md(end+1) = "追加管理列はtmに入れず、README_BT12Cとrun_reportへ逃がした。";
md(end+1) = "以後のBT解析では、このtmCompatible版を入力候補とする。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 9. 次アクション";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "BT12-C結果を確認する。";
md(end+1) = "問題なければworking_logへ追記する。";
md(end+1) = "その後、BT13としてtmCompatible v2を入力にして108過大化診断へ進む。";
md(end+1) = "```";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Excel: %s\n", outXlsx);
fprintf("Wrote Markdown: %s\n", outMd);

disp("=== Sheet summary ===");
disp(sheetSummary);
disp("=== Workbook QC ===");
disp(workbookQC);

%% ===== Local functions =====

function latest = findLatestFile(pattern)
    d = dir(pattern);
    if isempty(d)
        error("No file matching pattern: %s", pattern);
    end
    [~, idx] = max([d.datenum]);
    latest = string(d(idx).name);
end

function M = readFformMap(file)
    file = string(file);
    [~,~,ext] = fileparts(file);

    if lower(ext) == ".csv"
        M = readtable(file, 'VariableNamingRule', 'preserve');
        return;
    end

    sheets = string(sheetnames(file));

    preferred = [
        "macro_replace_map"
        "BT08A3_macro_replace_map"
        "Fform_replace_map"
        "replace_map"
    ];

    for sh = preferred(:)'
        if any(sheets == sh)
            M = readtable(file, 'Sheet', sh, 'VariableNamingRule', 'preserve');
            return;
        end
    end

    % fallback: find a sheet containing No and replace/linear columns
    for sh = sheets(:)'
        T = readtable(file, 'Sheet', sh, 'VariableNamingRule', 'preserve');
        vars = string(T.Properties.VariableNames);
        nvars = normalizeNames(vars);

        hasNo = any(nvars == "no");
        hasReplace = any(contains(nvars, "replace")) || any(contains(nvars, "linear"));
        hasOriginal = any(contains(nvars, "original")) || any(contains(nvars, "legacy"));

        if hasNo && hasReplace && hasOriginal
            M = T;
            return;
        end
    end

    error("Could not find Fform replace map sheet in %s", file);
end

function M = normalizeFformMap(Mraw)
    M = table();
    M.No = getNumCol(Mraw, ["No","NO","no"]);

    M.target_sheet = getStringCol(Mraw, ["target_sheet","sheet","Sheet","targetSheet"]);
    M.target_kind = getStringCol(Mraw, ["target_kind","kind","TargetKind","Fform_target_kind"]);

    M.original_value = getNumCol(Mraw, ["original_value","Fform_legacy","F_form_legacy","legacy_value","old_value","Fform_original"]);
    M.replace_value = getNumCol(Mraw, ["replace_value","Fform_linear","Fform_linear_v1","F_form_linear_v1","new_value","FformLinear_v1"]);

    if all(~isfinite(M.replace_value))
        error("Could not identify replace_value / Fform_linear_v1 in Fform map.");
    end

    for i = 1:height(M)
        [bundle, ~] = inferBundleCase(M.No(i));

        if strlength(M.target_kind(i)) == 0
            if contains(lower(M.target_sheet(i)), "f1")
                M.target_kind(i) = "F1";
            else
                M.target_kind(i) = "noF1";
            end
        end

        if strlength(M.target_sheet(i)) == 0
            if M.target_kind(i) == "F1"
                M.target_sheet(i) = "tm_F1_" + string(bundle);
            else
                M.target_sheet(i) = "tm_" + string(bundle);
            end
        end
    end

    keep = isfinite(M.No) & isfinite(M.replace_value);
    M = M(keep,:);
end

function [T1, audit] = replaceOnlyFform(T0, M, sheetName)
    T1 = T0;

    no = getNumCol(T0, ["No","NO","no"]);
    oldF = getNumCol(T0, ["F_form","Fform","F_FORM"]);
    fName = findCol(T0, ["F_form","Fform","F_FORM"]);

    if all(~isfinite(no))
        error("No column not found in sheet %s", sheetName);
    end
    if strlength(fName) == 0 || all(~isfinite(oldF))
        error("F_form column not found in sheet %s", sheetName);
    end

    targetKind = inferKindFromSheet(sheetName);

    newF = NaN(height(T0),1);
    mapOriginal = NaN(height(T0),1);
    status = strings(height(T0),1);

    for i = 1:height(T0)
        idx = find(M.No == no(i) & M.target_kind == targetKind);

        if isempty(idx)
            idx = find(M.No == no(i) & M.target_sheet == sheetName);
        end

        if isempty(idx)
            newF(i) = oldF(i);
            status(i) = "no_map_keep_old";
            continue;
        elseif numel(idx) > 1
            idx = idx(1);
            status(i) = "mapped_duplicate_first";
        else
            status(i) = "mapped_ok";
        end

        newF(i) = M.replace_value(idx);
        mapOriginal(i) = M.original_value(idx);
    end

    T1.(char(fName)) = newF;

    audit = table();
    audit.sheet = repmat(string(sheetName), height(T0), 1);
    audit.target_kind = repmat(string(targetKind), height(T0), 1);
    audit.No = no;
    audit.Fform_legacy_from_v1 = oldF;
    audit.Fform_linear_v1 = newF;
    audit.delta_linear_minus_legacy = newF - oldF;
    audit.map_original_value = mapOriginal;
    audit.abs_v1_old_minus_map_original = abs(oldF - mapOriginal);
    audit.mapping_status = status;
end

function S = summarizeSheet(T0, T1, audit, sheetName)
    fOld = audit.Fform_legacy_from_v1;
    fNew = audit.Fform_linear_v1;

    S = table();
    S.sheet = string(sheetName);
    S.N_rows = height(T1);
    S.N_cols_v1 = width(T0);
    S.N_cols_v2 = width(T1);
    S.N_cols_delta = width(T1) - width(T0);
    S.N_mapped_ok = sum(audit.mapping_status == "mapped_ok");
    S.N_mapped_duplicate_first = sum(audit.mapping_status == "mapped_duplicate_first");
    S.N_no_map_keep_old = sum(audit.mapping_status == "no_map_keep_old");
    S.N_column_structure_same = double(width(T0) == width(T1) && all(string(T0.Properties.VariableNames) == string(T1.Properties.VariableNames)));
    S.No_min = min(audit.No, [], 'omitnan');
    S.No_max = max(audit.No, [], 'omitnan');
    S.Fform_old_mean = mean(fOld, 'omitnan');
    S.Fform_new_mean = mean(fNew, 'omitnan');
    S.Fform_delta_mean = mean(fNew - fOld, 'omitnan');
    S.Fform_delta_min = min(fNew - fOld, [], 'omitnan');
    S.Fform_delta_max = max(fNew - fOld, [], 'omitnan');
    S.N_rows_changed = sum(abs(fNew - fOld) > 1e-12, 'omitnan');
    S.N_old_vs_map_original_large_diff = sum(audit.abs_v1_old_minus_map_original > 1e-8, 'omitnan');
end

function R = makeReadme(inputBundle, inputMap, outputFile, sheetSummary, rowAudit)
    key = strings(0,1);
    value = strings(0,1);
    note = strings(0,1);

    add("created_at", string(datetime("now")), "");
    add("task", "BT12-C", "current_bundle_input_v2 tmCompatible FformLinearCanonical");
    add("input_bundle_v1", inputBundle, "旧F_formを含む監査用入力");
    add("input_Fform_map", inputMap, "FformLinear_v1差し替え元");
    add("output_bundle_v2", outputFile, "以後のBT解析入力候補");
    add("Fform_definition_version", "linear_v1", "F_form列そのものをlinear_v1正本値に置換");
    add("Fform_status", "canonical", "FformLinear_v1を正本採用");
    add("legacy_Fform_status", "deprecated_definition_error_audit_only", "legacyは感度比較ではなく監査用");
    add("tm_sheet_policy", "same columns/order as v1", "tmシートには管理列を追加しない");
    add("BT12B_status", "rejected_as_input", "minimal版は列を削りすぎたため入力には使わない");
    add("target_rows", string(height(rowAudit)), "noF1 58 + F1 58 = 116 expected");
    add("mapped_ok", string(sum(rowAudit.mapping_status == "mapped_ok")), "");
    add("mapped_duplicate_first", string(sum(rowAudit.mapping_status == "mapped_duplicate_first")), "");
    add("no_map_keep_old", string(sum(rowAudit.mapping_status == "no_map_keep_old")), "");
    add("old_vs_map_original_large_diff", string(sum(rowAudit.abs_v1_old_minus_map_original > 1e-8, 'omitnan')), "");
    add("target_sheets", strjoin(string(sheetSummary.sheet), ", "), "");

    R = table(key, value, note);

    function add(a,b,c)
        key(end+1,1) = string(a);
        value(end+1,1) = string(b);
        note(end+1,1) = string(c);
    end
end

function Q = makeWorkbookQC(sheetSummary, rowAudit, inputBundle, inputMap, outputFile)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("input_bundle_v1", "info", inputBundle, "旧F_formを含む監査用入力。");
    add("input_Fform_map", "info", inputMap, "FformLinear_v1差し替え元。");
    add("output_bundle_v2", "info", outputFile, "今後のバンドル解析入力候補。");

    totalRows = sum(sheetSummary.N_rows);
    totalMapped = sum(sheetSummary.N_mapped_ok) + sum(sheetSummary.N_mapped_duplicate_first);
    totalNoMap = sum(sheetSummary.N_no_map_keep_old);
    nSame = sum(sheetSummary.N_column_structure_same);
    nOldDiff = sum(sheetSummary.N_old_vs_map_original_large_diff);

    add("target_rows", statusOK(totalRows == 116), sprintf("%d", totalRows), "noF1 58 + F1 58 = 116 が期待値。");
    add("mapped_rows", statusOK(totalMapped == totalRows), sprintf("%d/%d", totalMapped, totalRows), "全対象行がFformLinear_v1へマップされること。");
    add("no_map_rows", statusOK(totalNoMap == 0), sprintf("%d", totalNoMap), "マップ不可行は0が期待値。");
    add("tm_column_structure_same", statusOK(nSame == height(sheetSummary)), sprintf("%d/%d", nSame, height(sheetSummary)), "対象6シートすべてでv1と列構成が同じ。");
    add("old_value_vs_map_original", statusOK(nOldDiff == 0), sprintf("large_diff=%d", nOldDiff), "v1旧F_formとmap originalの不一致確認。");
    add("readme_only_metadata", "OK", "README_BT12C", "管理情報はtmではなくREADMEへ逃がした。");
    add("legacy_status", "OK", "deprecated audit only", "legacyは感度比較ではない。");
    add("Fform_status", "OK", "linear_v1 canonical", "FformLinear_v1を正本として採用。");

    Q = table(item, status, value, reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function s = statusOK(tf)
    if tf
        s = "OK";
    else
        s = "CHECK";
    end
end

function kind = inferKindFromSheet(sheetName)
    if contains(lower(string(sheetName)), "f1")
        kind = "F1";
    else
        kind = "noF1";
    end
end

function [bundle, label] = inferBundleCase(no)
    if ~isfinite(no)
        bundle = NaN;
        label = "";
        return;
    end
    no = round(no);

    if no >= 229 && no <= 254
        bundle = 108;
        if no == 252 || no == 253
            label = "108_76in";
        else
            label = "108_70in";
        end
    elseif no >= 268 && no <= 317
        bundle = 161;
        label = "161_uniform";
    elseif no >= 319 && no <= 381
        bundle = 164;
        if no == 339
            label = "164_112in";
        else
            label = "164_134in_normal";
        end
    else
        bundle = NaN;
        label = "unknown";
    end
end

function v = getNumCol(T, candidates)
    name = findCol(T, candidates);
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

function v = getStringCol(T, candidates)
    name = findCol(T, candidates);
    if strlength(name) == 0
        v = strings(height(T),1);
        return;
    end

    raw = T.(char(name));
    if isstring(raw)
        v = raw;
    elseif iscell(raw)
        v = string(raw);
    elseif iscategorical(raw)
        v = string(raw);
    else
        v = string(raw);
    end

    v(ismissing(v)) = "";
end

function name = findCol(T, candidates)
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
