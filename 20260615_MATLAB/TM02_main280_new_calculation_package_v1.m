function TM02_main280_new_calculation_package_v1(rootDir, tm01Xlsx)
% TM02_main280_new_calculation_package_v1
%
% Purpose:
%   Prepare a NEW calculation package for the TM01 main set:
%       Table9-12 AND source01 AND x_report <= 0.05 = 280 points
%
%   This run intentionally DOES NOT audit old calculation coverage.
%   Old/legacy calculations are not used to decide coverage or validity.
%   After conditions are selected, the 280 points should be newly calculated.
%
% Inputs:
%   rootDir : folder. Default = pwd.
%   tm01Xlsx: optional. If omitted, latest
%             TM01_source01_lowX_main_set_freeze_*.xlsx is used.
%
% Outputs:
%   TM02_main280_new_calculation_package_YYYYMMDD_HHMMSS.xlsx
%   run_report_TM02_main280_new_calculation_package_YYYYMMDD_HHMMSS.md
%
% Notes:
%   - This run does not compute qP, PM, F1, or any correction.
%   - This run does not merge noF1/F1 results from legacy workbooks.
%   - It only creates a clean manifest/input table for subsequent new
%     deterministic calculation.

if nargin < 1 || strlength(string(rootDir)) == 0
    rootDir = pwd;
end
rootDir = char(rootDir);

if nargin < 2 || strlength(string(tm01Xlsx)) == 0
    tm01Xlsx = findLatest(rootDir, 'TM01_source01_lowX_main_set_freeze_*.xlsx', true);
else
    tm01Xlsx = char(tm01Xlsx);
end
assert(isfile(tm01Xlsx), 'TM01 xlsx not found: %s', tm01Xlsx);

fprintf('TM01 workbook : %s\n', tm01Xlsx);

ts = datestr(now, 'yyyymmdd_HHMMSS');
outXlsx = fullfile(rootDir, sprintf('TM02_main280_new_calculation_package_%s.xlsx', ts));
outMd   = fullfile(rootDir, sprintf('run_report_TM02_main280_new_calculation_package_%s.md', ts));

% ---- read TM01 main set
T = readtable(tm01Xlsx, 'Sheet', 'source01_lowX_main280', 'PreserveVariableNames', true);
T = normalizeMain(T);
T = T(ismember(T.TableNo, [9 10 11 12]) & lower(string(T.source)) == "source01" & T.x_report <= 0.05, :);
T.key = makeKey(T.TableNo, T.ExptNo);

% ---- add calculation status policy
T.TM02_new_calc_scope = repmat("main280_new_calculation", height(T), 1);
T.calc_action = repmat("TO_BE_NEWLY_CALCULATED", height(T), 1);
T.legacy_calc_policy = repmat("DO_NOT_USE_FOR_COVERAGE_DECISION", height(T), 1);
T.old_calc_reference_policy = repmat("legacy results may be compared later only as reference", height(T), 1);

% ---- create compact manifest with common columns first
manifest = makeManifest(T);

% ---- checks and summaries
duplicateCount = height(T) - numel(unique(T.key));
checks = makeChecks(T, duplicateCount);
summary = summarizeRows("TM02_main280_new_calculation_package", T);
byTable = groupSummary(T, {'TableNo'});
byBridge = groupSummary(T, {'legacy_bridge_group'});
byTableBridge = groupSummary(T, {'TableNo','legacy_bridge_group'});
policy = makePolicy();

% ---- export Excel
fprintf('Writing Excel output: %s\n', outXlsx);
writetable(checks, outXlsx, 'Sheet', 'expected_checks');
writetable(policy, outXlsx, 'Sheet', 'policy_notes');
writetable(summary, outXlsx, 'Sheet', 'main_summary');
writetable(byTable, outXlsx, 'Sheet', 'by_table');
writetable(byBridge, outXlsx, 'Sheet', 'by_bridge');
writetable(byTableBridge, outXlsx, 'Sheet', 'by_table_bridge');
writetable(manifest, outXlsx, 'Sheet', 'new_calc_manifest');
writetable(T, outXlsx, 'Sheet', 'source01_lowX_main280_full');

% ---- export report
fprintf('Writing Markdown report: %s\n', outMd);
writeReport(outMd, rootDir, tm01Xlsx, outXlsx, checks, summary, byTable, byBridge, byTableBridge, policy);

fprintf('\nDone.\n');
fprintf('Output Excel: %s\n', outXlsx);
fprintf('Output report: %s\n', outMd);
end

%% ------------------------------------------------------------------------
function path = findLatest(rootDir, pattern, required)
d = dir(fullfile(rootDir, pattern));
if isempty(d)
    if required
        error('No file matching %s in %s', pattern, rootDir);
    else
        path = '';
        return;
    end
end
[~, idx] = max([d.datenum]);
path = fullfile(rootDir, d(idx).name);
end

%% ------------------------------------------------------------------------
function T = normalizeMain(T)
T = ensureVar(T, 'TableNo', {'TableNo','Table','table','Table_No'});
T = ensureVar(T, 'ExptNo', {'ExptNo','Expt','Experiment','No','No_'});
T = ensureVar(T, 'source', {'source','Source','source_id','SourceID'});
T = ensureVar(T, 'x_report', {'x_report','ExitQuality','ExitQuality_lb_lb','x','X'});
T.TableNo = round(double(T.TableNo));
T.ExptNo = normalizeExptNo(T.ExptNo);
T.source = lower(strtrim(string(T.source)));
T.x_report = double(T.x_report);
if ~ismember('legacy_bridge_group', T.Properties.VariableNames)
    T.legacy_bridge_group = repmat("not_loaded", height(T), 1);
else
    T.legacy_bridge_group = string(T.legacy_bridge_group);
end
if ~ismember('flag_norm', T.Properties.VariableNames)
    if ismember('Flag', T.Properties.VariableNames)
        T.flag_norm = string(T.Flag);
    elseif ismember('flag', T.Properties.VariableNames)
        T.flag_norm = string(T.flag);
    else
        T.flag_norm = repmat("none", height(T), 1);
    end
else
    T.flag_norm = string(T.flag_norm);
end
T.flag_norm(strlength(strtrim(T.flag_norm))==0 | ismissing(T.flag_norm)) = "none";
end

%% ------------------------------------------------------------------------
function T = ensureVar(T, standardName, candidates)
vars = string(T.Properties.VariableNames);
if ismember(standardName, vars)
    return;
end
for c = string(candidates)
    idx = find(strcmpi(vars, c), 1);
    if ~isempty(idx)
        T.(standardName) = T.(vars(idx));
        return;
    end
end
error('Required column not found for %s. Tried: %s. Available: %s', standardName, strjoin(string(candidates), ', '), strjoin(vars, ', '));
end

%% ------------------------------------------------------------------------
function s = normalizeExptNo(x)
if isnumeric(x)
    s = string(x);
else
    s = string(x);
end
s = strtrim(s);
% Normalize numeric-looking values without destroying suffixes.
out = strings(size(s));
for i = 1:numel(s)
    si = s(i);
    if ismissing(si) || strlength(si)==0
        out(i) = "";
        continue;
    end
    val = str2double(si);
    if ~isnan(val)
        out(i) = regexprep(sprintf('%.2f', val), '0+$', '');
        out(i) = regexprep(out(i), '\\.$', '');
        % Keep one decimal pair if value has source suffix such as .01.
        if abs(val - round(val)) > 1e-10
            out(i) = string(sprintf('%.2f', val));
        end
    else
        out(i) = si;
    end
end
s = out;
end

%% ------------------------------------------------------------------------
function key = makeKey(tableNo, exptNo)
key = "T" + string(round(double(tableNo))) + "_" + normalizeExptNo(exptNo);
end

%% ------------------------------------------------------------------------
function M = makeManifest(T)
preferred = ["key","TableNo","ExptNo","source","flag_norm", ...
    "Pressure_psia","Dia_in","Length_in","MassVelocity_x1e_6_lb_hr_ft2", ...
    "MassVelocity_x1e-6_lb_hr_ft2","GSI","G_kgm2s","L_over_D", ...
    "InletSubCooling_BTU_lb","Hsub_kJ_kg","x_report", ...
    "BurnoutHeatFlux_x1e_6_BTU_hr_ft2","BurnoutHeatFlux_x1e-6_BTU_hr_ft2", ...
    "D_mm","legacy_bridge_group","TM02_new_calc_scope","calc_action","legacy_calc_policy"];
vars = string(T.Properties.VariableNames);
sel = preferred(ismember(preferred, vars));
% Add remaining variables after preferred fields.
rem = vars(~ismember(vars, sel));
M = T(:, cellstr([sel rem]));
end

%% ------------------------------------------------------------------------
function checks = makeChecks(T, duplicateCount)
checks = table();
checks.checkName = [
    "main_total"
    "all_source01"
    "all_lowX_x_report_le_0p05"
    "duplicate_keys"
    "T9_main"
    "T10_main"
    "T11_main"
    "T12_main"
    "calc_action_to_be_newly_calculated"
    ];
checks.expected = [280; 280; 280; 0; 30; 190; 30; 30; 280];
checks.actual = [
    height(T)
    sum(lower(string(T.source)) == "source01")
    sum(T.x_report <= 0.05)
    duplicateCount
    sum(T.TableNo == 9)
    sum(T.TableNo == 10)
    sum(T.TableNo == 11)
    sum(T.TableNo == 12)
    sum(string(T.calc_action) == "TO_BE_NEWLY_CALCULATED")
    ];
checks.status = repmat("CHECK", height(checks), 1);
checks.status(checks.expected == checks.actual) = "OK";
end

%% ------------------------------------------------------------------------
function S = summarizeRows(name, T)
S = table();
S.candidate_set = string(name);
S.N = height(T);
S.table_counts = compactCounts(T.TableNo);
S.source_counts = compactCounts(T.source);
S.bridge_counts = compactCounts(T.legacy_bridge_group);
S.flag_counts = compactCounts(T.flag_norm);
S.P_min = min(getColumn(T, {'Pressure_psia','P_psia','P'}), [], 'omitnan');
S.P_max = max(getColumn(T, {'Pressure_psia','P_psia','P'}), [], 'omitnan');
S.G_min = min(getColumn(T, {'GSI','G_kgm2s','G'}), [], 'omitnan');
S.G_max = max(getColumn(T, {'GSI','G_kgm2s','G'}), [], 'omitnan');
S.LD_min = min(getColumn(T, {'L_over_D','LD','L_D'}), [], 'omitnan');
S.LD_max = max(getColumn(T, {'L_over_D','LD','L_D'}), [], 'omitnan');
S.Hsub_min = min(getColumn(T, {'Hsub_kJ_kg','Hsub','Hsub_true_kJkg'}), [], 'omitnan');
S.Hsub_max = max(getColumn(T, {'Hsub_kJ_kg','Hsub','Hsub_true_kJkg'}), [], 'omitnan');
S.x_min = min(T.x_report, [], 'omitnan');
S.x_max = max(T.x_report, [], 'omitnan');
end

%% ------------------------------------------------------------------------
function G = groupSummary(T, groupVars)
if ischar(groupVars), groupVars = {groupVars}; end
[Gidx, keys] = findgroups(T(:, groupVars));
rows = table();
for i = 1:max(Gidx)
    Ti = T(Gidx==i, :);
    r = summarizeRows("group", Ti);
    rows = [rows; r]; %#ok<AGROW>
end
G = [keys rows(:, 2:end)];
end

%% ------------------------------------------------------------------------
function x = getColumn(T, names)
vars = string(T.Properties.VariableNames);
x = nan(height(T),1);
for n = string(names)
    idx = find(strcmpi(vars, n), 1);
    if ~isempty(idx)
        xi = T.(vars(idx));
        if isnumeric(xi)
            x = double(xi);
        else
            x = str2double(string(xi));
        end
        return;
    end
end
end

%% ------------------------------------------------------------------------
function s = compactCounts(x)
x = string(x);
x(ismissing(x) | strlength(strtrim(x))==0) = "none";
[u,~,ic] = unique(x);
counts = accumarray(ic, 1);
parts = strings(numel(u),1);
for i = 1:numel(u)
    parts(i) = u(i) + ":" + string(counts(i));
end
s = strjoin(parts, ", ");
end

%% ------------------------------------------------------------------------
function P = makePolicy()
notes = [
    "TM02 replaces the previous coverage-audit idea."
    "After selecting conditions, all main280 points should be newly calculated."
    "Old/legacy calculation results are not used to decide whether the point is valid or covered."
    "The old 176 set remains a legacy reference only."
    "This run prepares a new calculation package only; it does not compute qP, PM, F1, or L/D correction."
    "Main entrance remains Table9-12 AND source01 AND x_report <= 0.05 = 280 points."
    ];
P = table((1:numel(notes))', notes, 'VariableNames', {'No','policy_note'});
end

%% ------------------------------------------------------------------------
function writeReport(outMd, rootDir, tm01Xlsx, outXlsx, checks, summary, byTable, byBridge, byTableBridge, policy)
fid = fopen(outMd, 'w');
assert(fid > 0, 'Could not open report for writing: %s', outMd);
cleanup = onCleanup(@() fclose(fid));

fprintf(fid, '# TM02 Main280 New Calculation Package\n\n');
fprintf(fid, '作成日: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

fprintf(fid, '## 1. 目的\n\n');
fprintf(fid, 'TM01で固定した `source01_lowX_9_12 = 280` を、新規計算用の入力パッケージとして整理する。\n\n');
fprintf(fid, 'このrunでは古い計算結果のカバレッジ監査は行わない。条件を選んだ後は、280点を新しく計算する前提とする。\n\n');
fprintf(fid, 'PM計算、F1再fit、L/D補正式作成は行わない。\n\n');

fprintf(fid, '## 2. 入力・出力\n\n');
fprintf(fid, '- rootDir: `%s`\n', rootDir);
fprintf(fid, '- input TM01 xlsx: `%s`\n', getFileName(tm01Xlsx));
fprintf(fid, '- output Excel: `%s`\n\n', getFileName(outXlsx));

fprintf(fid, '## 3. Expected checks\n\n');
writeMdTable(fid, checks);

fprintf(fid, '\n## 4. Main set summary\n\n');
writeMdTable(fid, summary);

fprintf(fid, '\n## 5. By-table summary\n\n');
writeMdTable(fid, byTable);

fprintf(fid, '\n## 6. Bridge summary\n\n');
fprintf(fid, 'TM01で付与されたlegacy bridge labelを引き継ぐ。ただし、これは旧計算値を利用するためではなく、旧176点との差分を後で説明するための参照ラベルである。\n\n');
writeMdTable(fid, byBridge);

fprintf(fid, '\n### By table and bridge group\n\n');
writeMdTable(fid, byTableBridge);

fprintf(fid, '\n## 7. Policy notes\n\n');
writeMdTable(fid, policy);

fprintf(fid, '\n## 8. 読み方\n\n');
fprintf(fid, '- TM02は、古い計算結果が何点あるかを調べるrunではない。\n');
fprintf(fid, '- 条件を選んだ後は、新しい主解析入口280点を新規に計算する。\n');
fprintf(fid, '- 旧176点および旧計算結果は、過去診断との比較用referenceとしてのみ扱う。\n');
fprintf(fid, '- `new_calc_manifest` シートを次の新規計算の入力リストとして使う。\n');
fprintf(fid, '- このrunではPM、F1、L/D補正はまだ計算しない。\n\n');

fprintf(fid, '## 9. 採用・保留\n\n');
fprintf(fid, '### 採用\n\n');
fprintf(fid, '- TM02はmain280の新規計算パッケージ作成runとして扱う。\n');
fprintf(fid, '- main280は全点 `TO_BE_NEWLY_CALCULATED` とする。\n');
fprintf(fid, '- 古い計算カバレッジを確認して採否を決める案は使わない。\n\n');
fprintf(fid, '### 保留\n\n');
fprintf(fid, '- 新規計算後にPM/F1診断へ進むか。\n');
fprintf(fid, '- F1再fitへ進むか。\n');
fprintf(fid, '- Table10 new_only 143点が診断結果に与える影響。\n\n');
fprintf(fid, '### まだ行わない\n\n');
fprintf(fid, '- PM計算。\n');
fprintf(fid, '- F1再fit。\n');
fprintf(fid, '- L/D補正式作成。\n');
end

%% ------------------------------------------------------------------------
function name = getFileName(path)
[~, n, e] = fileparts(path);
name = [n e];
end

%% ------------------------------------------------------------------------
function writeMdTable(fid, T)
if isempty(T)
    fprintf(fid, '(empty)\n');
    return;
end
vars = string(T.Properties.VariableNames);
fprintf(fid, '| %s |\n', strjoin(vars, ' | '));
fprintf(fid, '| %s |\n', strjoin(repmat("---", size(vars)), ' | '));
for i = 1:height(T)
    vals = strings(1, numel(vars));
    for j = 1:numel(vars)
        v = T{i,j};
        if iscell(v), v = v{1}; end
        if isnumeric(v)
            if isempty(v) || all(isnan(v))
                vals(j) = "";
            else
                vals(j) = string(sprintf('%.6g', v));
            end
        elseif islogical(v)
            vals(j) = string(v);
        elseif isdatetime(v)
            vals(j) = string(v);
        else
            vals(j) = string(v);
        end
        vals(j) = replace(vals(j), "|", "\\|");
        vals(j) = replace(vals(j), newline, " ");
    end
    fprintf(fid, '| %s |\n', strjoin(vals, ' | '));
end
end
