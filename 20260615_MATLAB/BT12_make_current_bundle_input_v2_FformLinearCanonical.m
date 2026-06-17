%% BT12_make_current_bundle_input_v2_FformLinearCanonical.m
% BT12：current_bundle_inputをFformLinear_v1正本へ更新する
%
% 目的：
%   BT11-Aで FformLinear_v1 をF_form正本として採用した。
%   そのため、以後のバンドル解析で旧 current_bundle_input_v1 を読み続けないよう、
%   F_form列そのものを FformLinear_v1 に置換した v2 入力ブックを作る。
%
% 方針：
%   - v1は上書きしない。
%   - v2を新規作成する。
%   - 以後のBT解析はv2だけを読む。
%   - legacy F_formは感度比較ではなく、旧定義ミス・監査用として横に残す。
%   - 通常解析では F_form 列だけを読めば linear_v1 正本値になるようにする。
%
% 入力：
%   H52Q_current_bundle_input_v1_20260615_180822.xlsx
%   BT08A3_macro_Fform_replace_package_*.xlsx
%      または BT08A3_macro_Fform_replace_map_*.csv
%
% 出力：
%   H52Q_current_bundle_input_v2_FformLinearCanonical_yyyymmdd_HHMMSS.xlsx
%   run_report_BT12_current_bundle_input_v2_FformLinearCanonical_yyyymmdd_HHMMSS.md
%
% 対象シート：
%   tm_108
%   tm_161
%   tm_164
%   tm_F1_108
%   tm_F1_161
%   tm_F1_164
%
% 重要：
%   - F_form = FformLinear_v1 に置換する。
%   - F_form_legacy_deprecated に旧F_formを保存する。
%   - FformLinear_v1 は定義正規化であり、残差補正式ではない。
%   - legacy F_formは感度比較ではなく、deprecated / audit only とする。

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

outXlsx = "H52Q_current_bundle_input_v2_FformLinearCanonical_" + timestamp + ".xlsx";
outMd   = "run_report_BT12_current_bundle_input_v2_FformLinearCanonical_" + timestamp + ".md";

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

%% ===== Read Fform map =====

M = readFformMap(inputFformMapFile);
M = normalizeFformMap(M);

%% ===== Process each target sheet =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

sheetSummary = table();
allChecks = table();

for sh = targetSheets(:)'
    fprintf("Processing sheet: %s\n", sh);

    T = readtable(inputBundleV1File, 'Sheet', sh, 'VariableNamingRule', 'preserve');
    Tout = applyFformLinearCanonical(T, M, sh);

    writetable(Tout, outXlsx, 'Sheet', sh);

    S = makeSheetSummary(T, Tout, sh);
    sheetSummary = [sheetSummary; S]; %#ok<AGROW>

    C = makeRowCheck(Tout, sh);
    allChecks = [allChecks; C]; %#ok<AGROW>
end

%% ===== Copy non-target sheets if needed =====
% current_bundle_input_v1は基本的に6シートだけの想定だが、
% 追加シートがある場合は、対象外としてそのままコピーする。
try
    allSheetNames = string(sheetnames(inputBundleV1File));
    extraSheets = setdiff(allSheetNames, targetSheets, 'stable');

    for sh = extraSheets(:)'
        Textra = readtable(inputBundleV1File, 'Sheet', sh, 'VariableNamingRule', 'preserve');
        writetable(Textra, outXlsx, 'Sheet', sh);
    end
catch ME
    warning("Extra sheet copy skipped: %s", ME.message);
    extraSheets = strings(0,1);
end

%% ===== Workbook-level QC =====

workbookQC = makeWorkbookQC(sheetSummary, allChecks, inputBundleV1File, inputFformMapFile, outXlsx);

%% ===== Write QC sheets =====

writetable(sheetSummary, outXlsx, 'Sheet', 'BT12_sheet_summary');
writetable(allChecks, outXlsx, 'Sheet', 'BT12_row_check');
writetable(workbookQC, outXlsx, 'Sheet', 'BT12_workbook_QC');

%% ===== Markdown report =====

md = strings(0,1);

md(end+1) = "# BT12 current_bundle_input v2 FformLinearCanonical";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT11-AでFformLinear_v1をF_form正本として採用したため、以後のバンドル解析入力をv2へ更新する。";
md(end+1) = "v1は上書きせず、旧定義・監査用へ降格する。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- bundle v1: `" + inputBundleV1File + "`";
md(end+1) = "- Fform map: `" + inputFformMapFile + "`";
md(end+1) = "";
md(end+1) = "## 3. 出力";
md(end+1) = "";
md(end+1) = "- bundle v2: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 4. 方針";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "F_form = FformLinear_v1";
md(end+1) = "F_form_legacy_deprecated = 旧F_form";
md(end+1) = "Fform_definition_version = linear_v1";
md(end+1) = "Fform_status = canonical";
md(end+1) = "legacy_Fform_status = deprecated_definition_error_audit_only";
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
md(end+1) = "BT12で current_bundle_input_v2_FformLinearCanonical を作成した。";
md(end+1) = "以後のバンドル解析では、v1ではなくv2を読む。";
md(end+1) = "legacy F_formは感度比較ではなく、旧定義ミス・監査用としてのみ保持する。";
md(end+1) = "FformLinear_v1はF_form定義の正本であり、残差補正式ではない。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 9. 次アクション";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "BT12結果を確認する。";
md(end+1) = "問題なければ、working_logへ追記する。";
md(end+1) = "その後、BT13としてv2正本入力を使い、108過大化の診断を再開する。";
md(end+1) = "```";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display =====

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

    % fallback: find a sheet containing No and replace_value-like columns
    for sh = sheets(:)'
        T = readtable(file, 'Sheet', sh, 'VariableNamingRule', 'preserve');
        vars = lower(string(T.Properties.VariableNames));
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

    % target_sheet may exist. If not, infer from target_kind and Bundle/No.
    M.target_sheet = getStringCol(Mraw, ["target_sheet","sheet","Sheet","targetSheet"]);

    % target_kind may exist. If not, infer from target_sheet.
    M.target_kind = getStringCol(Mraw, ["target_kind","kind","TargetKind","Fform_target_kind"]);

    % original/replace
    M.original_value = getNumCol(Mraw, ["original_value","Fform_legacy","F_form_legacy","legacy_value","old_value","Fform_original"]);
    M.replace_value = getNumCol(Mraw, ["replace_value","Fform_linear","Fform_linear_v1","F_form_linear_v1","new_value","FformLinear_v1"]);

    if all(~isfinite(M.replace_value))
        error("Could not identify replace_value / Fform_linear_v1 in Fform map.");
    end

    % If target_kind/sheet missing, infer.
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

function Tout = applyFformLinearCanonical(Tin, M, sheetName)
    T = Tin;
    vars = string(T.Properties.VariableNames);

    no = getNumCol(T, ["No","NO","no"]);
    oldF = getNumCol(T, ["F_form","Fform","F_FORM"]);

    if all(~isfinite(no))
        error("No column not found in sheet %s", sheetName);
    end
    if all(~isfinite(oldF))
        error("F_form column not found in sheet %s", sheetName);
    end

    targetKind = inferKindFromSheet(sheetName);

    newF = NaN(height(T),1);
    mapStatus = strings(height(T),1);
    mapOriginal = NaN(height(T),1);
    absOldDiff = NaN(height(T),1);

    for i = 1:height(T)
        candidates = find(M.No == no(i) & M.target_kind == targetKind);

        if isempty(candidates)
            candidates = find(M.No == no(i) & M.target_sheet == sheetName);
        end

        if isempty(candidates)
            newF(i) = oldF(i);
            mapStatus(i) = "no_map_keep_old";
            continue;
        elseif numel(candidates) > 1
            candidates = candidates(1);
            mapStatus(i) = "mapped_duplicate_first";
        else
            mapStatus(i) = "mapped_ok";
        end

        newF(i) = M.replace_value(candidates);
        mapOriginal(i) = M.original_value(candidates);
        absOldDiff(i) = abs(oldF(i) - M.original_value(candidates));
    end

    % Preserve old F_form
    T.F_form_legacy_deprecated = oldF;
    T.F_form_linear_v1 = newF;
    T.Fform_linear_minus_legacy = newF - oldF;
    T.Fform_linear_to_legacy_ratio = newF ./ oldF;

    % Replace canonical F_form column itself.
    fName = findCol(T, ["F_form","Fform","F_FORM"]);
    T.(char(fName)) = newF;

    T.Fform_definition_version = repmat("linear_v1", height(T), 1);
    T.Fform_status = repmat("canonical", height(T), 1);
    T.legacy_Fform_status = repmat("deprecated_definition_error_audit_only", height(T), 1);
    T.Fform_source = repmat("BT08A1d_linear_v1_via_BT08A3_map", height(T), 1);
    T.BT12_mapping_status = mapStatus;
    T.BT12_map_original_value = mapOriginal;
    T.BT12_abs_oldF_minus_map_original = absOldDiff;
    T.BT12_note = repmat("F_form column is canonical linear_v1. legacy is audit only.", height(T), 1);

    Tout = T;
end

function S = makeSheetSummary(Told, Tnew, sheetName)
    no = getNumCol(Tnew, ["No","NO","no"]);
    fNew = getNumCol(Tnew, ["F_form","Fform","F_FORM"]);
    fOld = getNumCol(Tnew, ["F_form_legacy_deprecated"]);
    fLinear = getNumCol(Tnew, ["F_form_linear_v1","Fform_linear_v1"]);
    status = string(Tnew.BT12_mapping_status);

    S = table();
    S.sheet = string(sheetName);
    S.N_rows = height(Tnew);
    S.N_target_rows = sum(isfinite(no));
    S.N_mapped_ok = sum(status == "mapped_ok");
    S.N_mapped_duplicate_first = sum(status == "mapped_duplicate_first");
    S.N_no_map_keep_old = sum(status == "no_map_keep_old");
    S.No_min = min(no, [], 'omitnan');
    S.No_max = max(no, [], 'omitnan');
    S.Fform_old_mean = mean(fOld, 'omitnan');
    S.Fform_new_mean = mean(fNew, 'omitnan');
    S.Fform_delta_mean = mean(fNew - fOld, 'omitnan');
    S.Fform_delta_min = min(fNew - fOld, [], 'omitnan');
    S.Fform_delta_max = max(fNew - fOld, [], 'omitnan');
    S.N_new_equals_linear = sum(abs(fNew - fLinear) < 1e-12);
    S.N_old_new_changed = sum(abs(fNew - fOld) > 1e-12);
    S.N_old_vs_map_original_large_diff = sum(Tnew.BT12_abs_oldF_minus_map_original > 1e-8, 'omitnan');
end

function C = makeRowCheck(T, sheetName)
    no = getNumCol(T, ["No","NO","no"]);
    fNew = getNumCol(T, ["F_form","Fform","F_FORM"]);
    fOld = getNumCol(T, ["F_form_legacy_deprecated"]);
    fLinear = getNumCol(T, ["F_form_linear_v1","Fform_linear_v1"]);

    C = table();
    C.sheet = repmat(string(sheetName), height(T), 1);
    C.No = no;
    C.F_form_canonical = fNew;
    C.F_form_legacy_deprecated = fOld;
    C.F_form_linear_v1 = fLinear;
    C.delta_linear_minus_legacy = fNew - fOld;
    C.canonical_equals_linear = abs(fNew - fLinear) < 1e-12;
    C.mapping_status = string(T.BT12_mapping_status);
    C.abs_old_minus_map_original = T.BT12_abs_oldF_minus_map_original;
end

function Q = makeWorkbookQC(sheetSummary, rowCheck, inputBundle, inputMap, outputFile)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("input_bundle_v1", "info", inputBundle, "旧current_bundle_input。今後は監査用。");
    add("input_Fform_map", "info", inputMap, "FformLinear_v1差し替え元。");
    add("output_bundle_v2", "info", outputFile, "今後のバンドル解析入力。");

    totalTarget = sum(sheetSummary.N_target_rows);
    totalMapped = sum(sheetSummary.N_mapped_ok) + sum(sheetSummary.N_mapped_duplicate_first);
    totalNoMap = sum(sheetSummary.N_no_map_keep_old);

    add("target_rows", statusOK(totalTarget == 116), sprintf("%d", totalTarget), "noF1 58 + F1 58 = 116 が期待値。");
    add("mapped_rows", statusOK(totalMapped == totalTarget), sprintf("%d/%d", totalMapped, totalTarget), "全対象行がFformLinear_v1へマップされること。");
    add("no_map_rows", statusOK(totalNoMap == 0), sprintf("%d", totalNoMap), "マップ不可行は0が期待値。");

    nEq = sum(rowCheck.canonical_equals_linear);
    add("canonical_equals_linear", statusOK(nEq == height(rowCheck)), sprintf("%d/%d", nEq, height(rowCheck)), "F_form列がF_form_linear_v1と一致すること。");

    nLarge = sum(rowCheck.abs_old_minus_map_original > 1e-8, 'omitnan');
    add("old_value_vs_map_original", statusOK(nLarge == 0), sprintf("large_diff=%d", nLarge), "旧F_formとmap originalの不一致確認。");

    add("legacy_status", "OK", "deprecated_definition_error_audit_only", "legacyは感度比較ではなく監査用。");
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
