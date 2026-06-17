%% BT12B_make_current_bundle_input_v2_minimal.m
% BT12-B：current_bundle_input_v2を最小構成へ整理する
%
% 目的：
%   BT12-Aで作成した H52Q_current_bundle_input_v2_FformLinearCanonical は、
%   FformLinear_v1正本化としては成功した。
%   ただし、解析入力としてはreadme/QC/余分な列が増えすぎたため、
%   以後のBT解析で読むための「最小構成版」を作成する。
%
% 方針：
%   - v1は読まない。
%   - BT12-Aで作成したv2_FformLinearCanonicalを入力にする。
%   - 解析用シート6枚だけを残す。
%   - QCシート、README、補助シートは入れない。
%   - 通常解析で使うF_form列はlinear_v1正本値のままにする。
%   - legacy F_formは監査用列として最低限残す。
%   - 1タスク1ログとしてrun_reportを出す。
%
% 入力：
%   H52Q_current_bundle_input_v2_FformLinearCanonical_*.xlsx
%
% 出力：
%   H52Q_current_bundle_input_v2_minimal_FformLinearCanonical_yyyymmdd_HHMMSS.xlsx
%   run_report_BT12B_current_bundle_input_v2_minimal_yyyymmdd_HHMMSS.md
%
% 対象シート：
%   tm_108
%   tm_161
%   tm_164
%   tm_F1_108
%   tm_F1_161
%   tm_F1_164
%
% 注意：
%   - このminimal版が以後のBT解析の入力候補。
%   - BT12-A版はQC付きの作成履歴として保持。
%   - legacy F_formは感度比較ではなく、deprecated / audit only。

clear; clc;

%% ===== Settings =====

inputV2FullFile = "";

if strlength(inputV2FullFile) == 0
    inputV2FullFile = findLatestFile("H52Q_current_bundle_input_v2_FformLinearCanonical_*.xlsx");
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "H52Q_current_bundle_input_v2_minimal_FformLinearCanonical_" + timestamp + ".xlsx";
outMd   = "run_report_BT12B_current_bundle_input_v2_minimal_" + timestamp + ".md";

targetSheets = [
    "tm_108"
    "tm_161"
    "tm_164"
    "tm_F1_108"
    "tm_F1_161"
    "tm_F1_164"
];

% 最小構成で残す列。
% 存在しない列は自動でスキップする。
% No, q, PM, Tsub, Fcorr, F_form, x_eq, DNB位置、L/DH、Fform監査列だけを残す。
keepCandidates = [
    "No"
    "Bundle"
    "TableNo"
    "Source"
    "ExptNo"
    "q_M"
    "qM"
    "q_M_MW"
    "qM_MW"
    "q_P"
    "qP"
    "q_P_MW"
    "qP_MW"
    "PM"
    "PM_ratio"
    "Tsub"
    "T_sub"
    "Fcorr"
    "F_corr"
    "F_form"
    "F_form_legacy_deprecated"
    "F_form_linear_v1"
    "Fform_linear_minus_legacy"
    "Fform_linear_to_legacy_ratio"
    "Fform_definition_version"
    "Fform_status"
    "legacy_Fform_status"
    "x_Mes"
    "xMes"
    "x_eq"
    "xeq"
    "L_DNB"
    "LDNB"
    "z_DNB"
    "zDNB"
    "L"
    "DH"
    "D_h"
    "Dh"
    "z_DNB_DH"
    "z_DNB_L"
    "L_DH"
];

fprintf("Input v2 full : %s\n", inputV2FullFile);
fprintf("Output minimal: %s\n", outXlsx);

%% ===== Build minimal workbook =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

sheetSummary = table();
missingRequired = table();

for sh = targetSheets(:)'
    fprintf("Processing sheet: %s\n", sh);

    T = readtable(inputV2FullFile, 'Sheet', sh, 'VariableNamingRule', 'preserve');

    [Tmin, keptVars, droppedVars] = makeMinimalTable(T, keepCandidates);

    % Derived geometry columns may be absent; recreate if possible.
    Tmin = ensureDerivedGeometry(Tmin);

    % Required canonical checks.
    [summaryRow, missRows] = makeSheetSummary(T, Tmin, sh, keptVars, droppedVars);
    sheetSummary = [sheetSummary; summaryRow]; %#ok<AGROW>
    missingRequired = [missingRequired; missRows]; %#ok<AGROW>

    writetable(Tmin, outXlsx, 'Sheet', sh);
end

workbookQC = makeWorkbookQC(sheetSummary, missingRequired, inputV2FullFile, outXlsx);

%% ===== Write report only, not QC sheets into workbook =====
% Minimal workbookには解析入力シートだけを残す。
% QCはrun_report.mdに出す。

md = strings(0,1);

md(end+1) = "# BT12-B current_bundle_input v2 minimal FformLinearCanonical";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT12-Aで作成したFformLinearCanonical版v2を、以後のBT解析で読みやすい最小構成へ整理する。";
md(end+1) = "BT12-A版はQC付き作成履歴として保持し、BT12-B版を解析入力候補とする。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- input v2 full: `" + inputV2FullFile + "`";
md(end+1) = "";
md(end+1) = "## 3. 出力";
md(end+1) = "";
md(end+1) = "- output minimal: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 4. 方針";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "- 解析用6シートだけを残す。";
md(end+1) = "- README/QC/補助シートはworkbookには入れない。";
md(end+1) = "- F_form列はlinear_v1正本値のままにする。";
md(end+1) = "- legacy F_formは監査用列として最低限残す。";
md(end+1) = "- legacyは感度比較ではなくdeprecated / audit only。";
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
md(end+1) = "## 8. Missing required columns";
md(end+1) = "";
if height(missingRequired) == 0
    md(end+1) = "_none_";
else
    md(end+1) = tableToMarkdown(missingRequired);
end
md(end+1) = "";
md(end+1) = "## 9. 判断";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "BT12-Bで、以後のBT解析用の最小構成 current_bundle_input_v2 を作成した。";
md(end+1) = "以後のBT解析では、原則としてこのminimal版を読む。";
md(end+1) = "BT12-Aのfull版は作成履歴・QC確認用として保持する。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 10. 次アクション";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "BT12-B結果を確認する。";
md(end+1) = "問題なければworking_logへ追記する。";
md(end+1) = "その後、BT13としてminimal v2を入力にして108過大化診断へ進む。";
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

function [Tmin, keptVars, droppedVars] = makeMinimalTable(T, keepCandidates)
    vars = string(T.Properties.VariableNames);
    normVars = normalizeNames(vars);

    keep = false(size(vars));
    for c = string(keepCandidates(:))'
        nc = normalizeNames(c);
        idx = find(normVars == nc);
        keep(idx) = true;
    end

    % Always keep row identity columns if they exist under unusual names
    idPatterns = ["no","bundle","expt","table","source"];
    for p = idPatterns
        keep = keep | contains(normVars, p);
    end

    keptVars = vars(keep);
    droppedVars = vars(~keep);

    Tmin = T(:, keptVars);
end

function T = ensureDerivedGeometry(T)
    vars = string(T.Properties.VariableNames);

    has_z_DNB_DH = any(normalizeNames(vars) == "zdnbdh");
    has_z_DNB_L  = any(normalizeNames(vars) == "zdnbl");
    has_L_DH     = any(normalizeNames(vars) == "ldh");

    LDNB = getNumCol(T, ["L_DNB","LDNB","z_DNB","zDNB"]);
    L = getNumCol(T, ["L"]);
    DH = getNumCol(T, ["DH","D_h","Dh"]);

    if ~has_z_DNB_DH && any(isfinite(LDNB)) && any(isfinite(DH))
        T.z_DNB_DH = LDNB ./ DH;
    end
    if ~has_z_DNB_L && any(isfinite(LDNB)) && any(isfinite(L))
        T.z_DNB_L = LDNB ./ L;
    end
    if ~has_L_DH && any(isfinite(L)) && any(isfinite(DH))
        T.L_DH = L ./ DH;
    end
end

function [S, missingRows] = makeSheetSummary(Tfull, Tmin, sheetName, keptVars, droppedVars)
    no = getNumCol(Tmin, ["No","NO","no"]);
    fCanon = getNumCol(Tmin, ["F_form","Fform","F_FORM"]);
    fLegacy = getNumCol(Tmin, ["F_form_legacy_deprecated"]);
    fLinear = getNumCol(Tmin, ["F_form_linear_v1","Fform_linear_v1"]);

    S = table();
    S.sheet = string(sheetName);
    S.N_rows = height(Tmin);
    S.N_cols_full = width(Tfull);
    S.N_cols_minimal = width(Tmin);
    S.N_cols_dropped = numel(droppedVars);
    S.No_min = min(no, [], 'omitnan');
    S.No_max = max(no, [], 'omitnan');
    S.Fform_canonical_mean = mean(fCanon, 'omitnan');
    S.Fform_legacy_mean = mean(fLegacy, 'omitnan');
    S.Fform_delta_mean = mean(fCanon - fLegacy, 'omitnan');
    S.N_canonical_equals_linear = sum(abs(fCanon - fLinear) < 1e-12, 'omitnan');
    S.N_rows_changed_from_legacy = sum(abs(fCanon - fLegacy) > 1e-12, 'omitnan');

    required = [
        "No"
        "F_form"
        "F_form_legacy_deprecated"
        "F_form_linear_v1"
        "Fform_definition_version"
        "Fform_status"
        "legacy_Fform_status"
        "PM"
        "Tsub"
        "Fcorr"
        "x_Mes"
        "L_DNB"
        "L"
        "DH"
    ];

    missingRows = table();
    vars = string(Tmin.Properties.VariableNames);
    normVars = normalizeNames(vars);

    for r = string(required(:))'
        if ~any(normVars == normalizeNames(r))
            row = table();
            row.sheet = string(sheetName);
            row.missing_required = r;
            row.note = "存在しない場合でも解析可能な列はあるが、次BTで必要なら確認する";
            missingRows = [missingRows; row]; %#ok<AGROW>
        end
    end
end

function Q = makeWorkbookQC(sheetSummary, missingRequired, inputFile, outputFile)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("input_full_v2", "info", inputFile, "BT12-Aのfull版。");
    add("output_minimal_v2", "info", outputFile, "以後のBT解析入力候補。");

    totalRows = sum(sheetSummary.N_rows);
    totalEq = sum(sheetSummary.N_canonical_equals_linear);

    add("target_rows", statusOK(totalRows == 116), sprintf("%d", totalRows), "6シート合計116行が期待値。");
    add("canonical_equals_linear", statusOK(totalEq == totalRows), sprintf("%d/%d", totalEq, totalRows), "F_form列がF_form_linear_v1と一致すること。");
    add("sheet_count", statusOK(height(sheetSummary) == 6), sprintf("%d", height(sheetSummary)), "解析用6シートのみ処理。");
    add("missing_required_count", statusOK(height(missingRequired) == 0), sprintf("%d", height(missingRequired)), "必須候補列の欠損。実際の必要性は次BTで確認。");
    add("legacy_handling", "OK", "deprecated audit only", "legacyは感度比較ではない。");
    add("readme_qc_sheets", "OK", "not included in workbook", "最小構成のためQCはrun_reportにのみ残す。");

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
