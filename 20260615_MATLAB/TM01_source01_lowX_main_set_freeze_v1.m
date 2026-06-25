function TM01_source01_lowX_main_set_freeze_v1(rootDir, tm00bXlsx, tm00cXlsx)
% TM01_source01_lowX_main_set_freeze_v1
%
% Purpose:
%   Freeze the new canonical T&M Table9-12 main candidate set:
%       Table in 9-12, source01, x_report <= 0.05
%
%   The expected main set is:
%       Table9  = 30
%       Table10 = 190
%       Table11 = 30
%       Table12 = 30
%       Total   = 280
%
%   This run does NOT compute PM, does NOT refit F1, and does NOT create
%   an L/D correction. It only fixes the analysis entrance, adds optional
%   TM00c bridge labels, and exports condition summaries for the 280 points.
%
% Inputs:
%   rootDir   : folder. Default = pwd.
%   tm00bXlsx : optional. If omitted, latest
%               TM00b_tables9_12_candidate_sets_*.xlsx is used.
%   tm00cXlsx : optional. If omitted, latest
%               TM00c_legacy_bridge_audit_*.xlsx is used if available.
%
% Output:
%   TM01_source01_lowX_main_set_freeze_YYYYMMDD_HHMMSS.xlsx
%   run_report_TM01_source01_lowX_main_set_freeze_YYYYMMDD_HHMMSS.md
%
% Interpretation:
%   - The old legacy 176 set is frozen as a legacy reference only.
%   - The new main entrance is source01_lowX_9_12 = 280.
%   - The Table10 legacy/new difference is not treated as an error; the old
%     Table10 86 was not a lowX-defined set.

if nargin < 1 || strlength(string(rootDir)) == 0
    rootDir = pwd;
end
rootDir = char(rootDir);

if nargin < 2 || strlength(string(tm00bXlsx)) == 0
    tm00bXlsx = findLatest(rootDir, 'TM00b_tables9_12_candidate_sets_*.xlsx', true);
else
    tm00bXlsx = char(tm00bXlsx);
end
assert(isfile(tm00bXlsx), 'TM00b xlsx not found: %s', tm00bXlsx);

if nargin < 3 || strlength(string(tm00cXlsx)) == 0
    tm00cXlsx = findLatest(rootDir, 'TM00c_legacy_bridge_audit_*.xlsx', false);
else
    tm00cXlsx = char(tm00cXlsx);
end

fprintf('TM00b workbook : %s\n', tm00bXlsx);
if strlength(string(tm00cXlsx)) > 0 && isfile(tm00cXlsx)
    fprintf('TM00c workbook : %s\n', tm00cXlsx);
else
    fprintf('TM00c workbook : not loaded (optional)\n');
    tm00cXlsx = '';
end

ts = datestr(now, 'yyyymmdd_HHMMSS');
outXlsx = fullfile(rootDir, sprintf('TM01_source01_lowX_main_set_freeze_%s.xlsx', ts));
outMd   = fullfile(rootDir, sprintf('run_report_TM01_source01_lowX_main_set_freeze_%s.md', ts));

% ---- read main candidate from TM00b
Traw = readtable(tm00bXlsx, 'Sheet', 'source01_lowX', 'PreserveVariableNames', true);
T = normalizeMainTable(Traw);
T = T(ismember(T.TableNo, [9 10 11 12]) & T.source == "source01" & T.x_report <= 0.05, :);
T.key = makeKey(T.TableNo, T.ExptNo);

% Deduplicate only for checks; do not silently drop rows from the main export.
[uniqueKeys, firstIdx] = unique(T.key, 'stable'); %#ok<ASGLU>
duplicateCount = height(T) - numel(firstIdx);

T.TM01_main_inclusion = true(height(T),1);
T.TM01_selection_rule = repmat("Table9-12 AND source01 AND x_report<=0.05", height(T), 1);
T.legacy_bridge_group = repmat("not_loaded", height(T), 1);
T.in_legacy_176 = false(height(T), 1);

bridgeLoaded = false;
bridgeCounts = table(string.empty(0,1), zeros(0,1), 'VariableNames', {'bridge_group','N'});
if strlength(string(tm00cXlsx)) > 0 && isfile(tm00cXlsx)
    try
        C = readtable(tm00cXlsx, 'Sheet', 'new_source01_lowX', 'PreserveVariableNames', true);
        C = normalizeBridgeTable(C);
        if ~ismember('key', C.Properties.VariableNames)
            C.key = makeKey(C.TableNo, C.ExptNo);
        else
            C.key = string(C.key);
        end
        if ismember('membership', C.Properties.VariableNames)
            C.membership = string(C.membership);
        else
            C.membership = repmat("unknown", height(C), 1);
        end
        [tf, loc] = ismember(T.key, C.key);
        T.in_legacy_176(tf) = C.in_legacy(loc(tf));
        bg = repmat("not_in_TM00c", height(T), 1);
        for i = 1:height(T)
            if tf(i)
                mem = string(C.membership(loc(i)));
                if contains(mem, "overlap")
                    bg(i) = "overlap_with_legacy";
                elseif contains(mem, "new_only")
                    bg(i) = "new_only_vs_legacy";
                else
                    bg(i) = mem;
                end
            end
        end
        T.legacy_bridge_group = bg;
        bridgeLoaded = true;
        bridgeCounts = simpleCount(T.legacy_bridge_group, 'bridge_group');
    catch ME
        warning('Could not load TM00c bridge labels: %s', ME.message);
    end
end

% Add LD bins for summaries.
T.LD_bin = makeLDBin(getNumeric(T, 'L_over_D'));
T.x_bin = makeXBin(T.x_report);
T.Hsub_bin = makeHsubBin(getNumeric(T, 'Hsub_kJ_kg'));

% ---- summaries and checks
expectedChecks = makeExpectedChecks(T, duplicateCount, bridgeLoaded);
mainSummary = summarizeCandidate("source01_lowX_9_12_TM01_main", T);
byTable = groupConditionSummary(T, {'TableNo'});
byTableLD = groupConditionSummary(T, {'TableNo','LD_bin'});
byFlag = groupConditionSummary(T, {'flag_norm'});
byBridge = groupConditionSummary(T, {'legacy_bridge_group'});
byTableBridge = groupConditionSummary(T, {'TableNo','legacy_bridge_group'});
byXbin = groupConditionSummary(T, {'x_bin'});
byHsubBin = groupConditionSummary(T, {'Hsub_bin'});

policy = makePolicyTable(bridgeLoaded);

% ---- export Excel
fprintf('Writing Excel output: %s\n', outXlsx);
writetable(expectedChecks, outXlsx, 'Sheet', 'expected_checks');
writetable(mainSummary, outXlsx, 'Sheet', 'main_summary');
writetable(policy, outXlsx, 'Sheet', 'policy_notes');
writetable(T, outXlsx, 'Sheet', 'source01_lowX_main280');
writetable(byTable, outXlsx, 'Sheet', 'by_table');
writetable(byTableLD, outXlsx, 'Sheet', 'by_table_LD');
writetable(byFlag, outXlsx, 'Sheet', 'by_flag');
writetable(byBridge, outXlsx, 'Sheet', 'by_bridge');
writetable(byTableBridge, outXlsx, 'Sheet', 'by_table_bridge');
writetable(byXbin, outXlsx, 'Sheet', 'by_x_bin');
writetable(byHsubBin, outXlsx, 'Sheet', 'by_Hsub_bin');
if bridgeLoaded
    writetable(bridgeCounts, outXlsx, 'Sheet', 'bridge_counts');
end

% ---- export Markdown
fprintf('Writing Markdown report: %s\n', outMd);
writeReport(outMd, rootDir, tm00bXlsx, tm00cXlsx, outXlsx, expectedChecks, mainSummary, byTable, byBridge, byTableBridge, policy, bridgeLoaded);

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
function T = normalizeMainTable(T)
T = ensureVar(T, 'TableNo', {'TableNo','Table','table','Table_No'});
T = ensureVar(T, 'ExptNo', {'ExptNo','Expt','Experiment','No','No_'});
T = ensureVar(T, 'source', {'source','Source','source_id','SourceID'});
T = ensureVar(T, 'flag_norm', {'flag_norm','Flag','flag','FLAG'});
T = ensureVar(T, 'Pressure_psia', {'Pressure_psia','Pressure','P_psia'});
T = ensureVar(T, 'x_report', {'x_report','ExitQuality','ExitQuality_lb_lb','x','X'});

T.TableNo = round(double(T.TableNo));
T.ExptNo = normalizeNumeric(T.ExptNo);
T.source = string(T.source);
T.source = lower(strtrim(T.source));
T.flag_norm = string(T.flag_norm);
T.flag_norm = strtrim(T.flag_norm);
T.flag_norm(ismissing(T.flag_norm) | T.flag_norm == "") = "none";
T.x_report = normalizeNumeric(T.x_report);
end

%% ------------------------------------------------------------------------
function C = normalizeBridgeTable(C)
C = ensureVar(C, 'TableNo', {'TableNo','Table','table','Table_No'});
C = ensureVar(C, 'ExptNo', {'ExptNo','Expt','Experiment','No','No_'});
if ~ismember('in_legacy', C.Properties.VariableNames)
    if ismember('in_legacy_176', C.Properties.VariableNames)
        C.in_legacy = logical(C.in_legacy_176);
    elseif ismember('in_legacy_source01_9_12', C.Properties.VariableNames)
        C.in_legacy = logical(C.in_legacy_source01_9_12);
    else
        C.in_legacy = false(height(C),1);
    end
end
C.TableNo = round(double(C.TableNo));
C.ExptNo = normalizeNumeric(C.ExptNo);
end

%% ------------------------------------------------------------------------
function T = ensureVar(T, canonical, candidates)
vars = string(T.Properties.VariableNames);
if ismember(canonical, vars)
    return;
end
for i = 1:numel(candidates)
    c = string(candidates{i});
    idx = find(strcmpi(vars, c), 1);
    if ~isempty(idx)
        T.(canonical) = T.(vars(idx));
        return;
    end
end
error('Required column not found for %s. Tried: %s. Available: %s', canonical, strjoin(string(candidates), ', '), strjoin(vars, ', '));
end

%% ------------------------------------------------------------------------
function x = normalizeNumeric(v)
if isnumeric(v)
    x = double(v);
elseif iscell(v)
    x = str2double(string(v));
elseif isstring(v) || ischar(v) || iscategorical(v)
    x = str2double(string(v));
elseif islogical(v)
    x = double(v);
else
    x = str2double(string(v));
end
end

%% ------------------------------------------------------------------------
function key = makeKey(tableNo, exptNo)
key = "T" + string(round(double(tableNo))) + "_" + string(exptNo);
end

%% ------------------------------------------------------------------------
function x = getNumeric(T, varname)
if ismember(varname, T.Properties.VariableNames)
    x = normalizeNumeric(T.(varname));
else
    x = nan(height(T),1);
end
end

%% ------------------------------------------------------------------------
function bin = makeLDBin(ld)
bin = strings(numel(ld),1);
bin(isnan(ld)) = "missing";
bin(ld < 60) = "LD_lt_60";
bin(ld >= 60 & ld < 100) = "LD_60_100";
bin(ld >= 100 & ld < 200) = "LD_100_200";
bin(ld >= 200 & ld < 300) = "LD_200_300";
bin(ld >= 300) = "LD_ge_300";
bin(bin == "") = "missing";
end

%% ------------------------------------------------------------------------
function bin = makeXBin(x)
bin = strings(numel(x),1);
bin(isnan(x)) = "missing";
bin(x < -0.40) = "x_lt_m0p40";
bin(x >= -0.40 & x < -0.20) = "x_m0p40_to_m0p20";
bin(x >= -0.20 & x < -0.05) = "x_m0p20_to_m0p05";
bin(x >= -0.05 & x <= 0.05) = "x_m0p05_to_0p05";
bin(bin == "") = "missing";
end

%% ------------------------------------------------------------------------
function bin = makeHsubBin(h)
bin = strings(numel(h),1);
bin(isnan(h)) = "missing";
bin(h < 250) = "Hsub_lt_250";
bin(h >= 250 & h < 500) = "Hsub_250_500";
bin(h >= 500 & h < 1000) = "Hsub_500_1000";
bin(h >= 1000 & h < 1500) = "Hsub_1000_1500";
bin(h >= 1500) = "Hsub_ge_1500";
bin(bin == "") = "missing";
end

%% ------------------------------------------------------------------------
function checks = makeExpectedChecks(T, duplicateCount, bridgeLoaded)
rows = {};
rows(end+1,:) = {'main_total', 280, height(T), statusText(280, height(T))};
rows(end+1,:) = {'all_source01', 280, sum(T.source == "source01"), statusText(280, sum(T.source == "source01"))};
rows(end+1,:) = {'all_lowX_x_report_le_0p05', 280, sum(T.x_report <= 0.05), statusText(280, sum(T.x_report <= 0.05))};
rows(end+1,:) = {'duplicate_keys', 0, duplicateCount, statusText(0, duplicateCount)};
rows(end+1,:) = {'T9_main', 30, sum(T.TableNo == 9), statusText(30, sum(T.TableNo == 9))};
rows(end+1,:) = {'T10_main', 190, sum(T.TableNo == 10), statusText(190, sum(T.TableNo == 10))};
rows(end+1,:) = {'T11_main', 30, sum(T.TableNo == 11), statusText(30, sum(T.TableNo == 11))};
rows(end+1,:) = {'T12_main', 30, sum(T.TableNo == 12), statusText(30, sum(T.TableNo == 12))};
if bridgeLoaded
    rows(end+1,:) = {'bridge_overlap_with_legacy', 137, sum(T.legacy_bridge_group == "overlap_with_legacy"), statusText(137, sum(T.legacy_bridge_group == "overlap_with_legacy"))};
    rows(end+1,:) = {'bridge_new_only_vs_legacy', 143, sum(T.legacy_bridge_group == "new_only_vs_legacy"), statusText(143, sum(T.legacy_bridge_group == "new_only_vs_legacy"))};
else
    rows(end+1,:) = {'bridge_loaded', NaN, 0, 'INFO_not_loaded'};
end
checks = cell2table(rows, 'VariableNames', {'checkName','expected','actual','status'});
end

%% ------------------------------------------------------------------------
function s = statusText(exp, act)
if isnan(exp)
    s = "INFO";
elseif isequal(double(exp), double(act))
    s = "OK";
else
    s = "CHECK";
end
end

%% ------------------------------------------------------------------------
function row = summarizeCandidate(name, T)
row = table(string(name), height(T), joinCounts(T.TableNo), joinCounts(T.source), joinCounts(T.flag_norm), ...
    minOrNaN(getNumeric(T,'Pressure_psia')), maxOrNaN(getNumeric(T,'Pressure_psia')), ...
    minOrNaN(getNumeric(T,'G_SI_kg_m2s')), maxOrNaN(getNumeric(T,'G_SI_kg_m2s')), ...
    minOrNaN(getNumeric(T,'L_over_D')), maxOrNaN(getNumeric(T,'L_over_D')), ...
    minOrNaN(getNumeric(T,'Hsub_kJ_kg')), maxOrNaN(getNumeric(T,'Hsub_kJ_kg')), ...
    minOrNaN(getNumeric(T,'x_report')), maxOrNaN(getNumeric(T,'x_report')), ...
    minOrNaN(getNumeric(T,'D_mm')), maxOrNaN(getNumeric(T,'D_mm')), ...
    'VariableNames', {'candidate_set','N','table_counts','source_counts','flag_counts', ...
    'P_min','P_max','GSI_min','GSI_max','LD_min','LD_max','Hsub_min','Hsub_max','x_min','x_max','D_min_mm','D_max_mm'});
end

%% ------------------------------------------------------------------------
function G = groupConditionSummary(T, groupVars)
if isempty(T) || height(T) == 0
    G = table();
    return;
end
n = height(T);
key = strings(n,1);
for i = 1:n
    parts = strings(1,numel(groupVars));
    for j = 1:numel(groupVars)
        v = T.(groupVars{j});
        parts(j) = string(v(i));
    end
    key(i) = strjoin(parts, '|');
end
[u, ~, g] = unique(key, 'stable');
rows = cell(numel(u), 1);
for k = 1:numel(u)
    idx = (g == k);
    S = T(idx,:);
    base = table();
    for j = 1:numel(groupVars)
        v = S.(groupVars{j});
        base.(groupVars{j}) = v(1);
    end
    summary = summarizeCondition(S);
    rows{k} = [base summary];
end
G = vertcat(rows{:});
end

%% ------------------------------------------------------------------------
function S = summarizeCondition(T)
S = table(height(T), joinCounts(T.flag_norm), ...
    minOrNaN(getNumeric(T,'Pressure_psia')), maxOrNaN(getNumeric(T,'Pressure_psia')), ...
    minOrNaN(getNumeric(T,'G_SI_kg_m2s')), maxOrNaN(getNumeric(T,'G_SI_kg_m2s')), ...
    minOrNaN(getNumeric(T,'L_over_D')), maxOrNaN(getNumeric(T,'L_over_D')), ...
    minOrNaN(getNumeric(T,'Hsub_kJ_kg')), maxOrNaN(getNumeric(T,'Hsub_kJ_kg')), ...
    minOrNaN(getNumeric(T,'x_report')), maxOrNaN(getNumeric(T,'x_report')), ...
    minOrNaN(getNumeric(T,'D_mm')), maxOrNaN(getNumeric(T,'D_mm')), ...
    'VariableNames', {'N','flag_counts','P_min','P_max','GSI_min','GSI_max','LD_min','LD_max','Hsub_min','Hsub_max','x_min','x_max','D_min_mm','D_max_mm'});
end

%% ------------------------------------------------------------------------
function C = simpleCount(v, name)
v = string(v);
[u, ~, g] = unique(v, 'stable');
n = accumarray(g, 1);
C = table(u, n, 'VariableNames', {name, 'N'});
end

%% ------------------------------------------------------------------------
function s = joinCounts(v)
if isempty(v)
    s = "";
    return;
end
v = string(v);
[u, ~, g] = unique(v, 'stable');
n = accumarray(g, 1);
parts = strings(numel(u),1);
for i = 1:numel(u)
    parts(i) = u(i) + ":" + string(n(i));
end
s = strjoin(parts, ', ');
end

%% ------------------------------------------------------------------------
function y = minOrNaN(x)
x = x(~isnan(x));
if isempty(x), y = NaN; else, y = min(x); end
end

%% ------------------------------------------------------------------------
function y = maxOrNaN(x)
x = x(~isnan(x));
if isempty(x), y = NaN; else, y = max(x); end
end

%% ------------------------------------------------------------------------
function policy = makePolicyTable(bridgeLoaded)
items = [
    "TM01 adopts source01_lowX_9_12 = 280 as the main T&M Table9-12 entrance."
    "Selection rule is Table9-12 AND source01 AND x_report <= 0.05."
    "The legacy 176 set is frozen as a reference for old diagnostics, not used as the main entrance."
    "The old Table10 86 set was not selected by quality; the difference from new Table10 190 is not an error."
    "This run does not compute PM, does not refit F1, and does not create an L/D correction."
    ];
if bridgeLoaded
    items(end+1) = "TM00c bridge labels are loaded for overlap/new_only reference.";
else
    items(end+1) = "TM00c bridge labels were not loaded; bridge columns are marked not_loaded.";
end
policy = table((1:numel(items))', items, 'VariableNames', {'No','policy_note'});
end

%% ------------------------------------------------------------------------
function writeReport(outMd, rootDir, tm00bXlsx, tm00cXlsx, outXlsx, expectedChecks, mainSummary, byTable, byBridge, byTableBridge, policy, bridgeLoaded)
fid = fopen(outMd, 'w');
assert(fid > 0, 'Could not open report for writing: %s', outMd);
cleaner = onCleanup(@() fclose(fid));

fprintf(fid, '# TM01 Source01 lowX Main Set Freeze\n\n');
fprintf(fid, '作成日: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

fprintf(fid, '## 1. 目的\n\n');
fprintf(fid, 'TM00bで固定した `source01_lowX_9_12 = 280` を、今後のT&M Table9〜12主解析入口として明示的に固定する。\n\n');
fprintf(fid, 'このrunでは採用入口を固定するだけであり、PM計算、F1再fit、L/D補正式作成は行わない。\n\n');

fprintf(fid, '## 2. 入力・出力\n\n');
fprintf(fid, '- rootDir: `%s`\n', rootDir);
fprintf(fid, '- input TM00b xlsx: `%s`\n', getFileName(tm00bXlsx));
if strlength(string(tm00cXlsx)) > 0
    fprintf(fid, '- input TM00c xlsx: `%s`\n', getFileName(tm00cXlsx));
else
    fprintf(fid, '- input TM00c xlsx: not loaded\n');
end
fprintf(fid, '- output Excel: `%s`\n\n', getFileName(outXlsx));

fprintf(fid, '## 3. Expected checks\n\n');
writeMarkdownTable(fid, expectedChecks);

fprintf(fid, '\n## 4. Main set summary\n\n');
writeMarkdownTable(fid, mainSummary);

fprintf(fid, '\n## 5. By-table summary\n\n');
writeMarkdownTable(fid, byTable);

fprintf(fid, '\n## 6. Bridge summary\n\n');
if bridgeLoaded
    fprintf(fid, 'TM00cのbridge labelを読み込んだ。`overlap_with_legacy` は旧176点にも含まれる新正本点、`new_only_vs_legacy` は旧176点には含まれない新正本点である。\n\n');
    writeMarkdownTable(fid, byBridge);
    fprintf(fid, '\n### By table and bridge group\n\n');
    writeMarkdownTable(fid, byTableBridge);
else
    fprintf(fid, 'TM00c bridge labelは読み込んでいない。bridge列は `not_loaded` とした。\n');
end

fprintf(fid, '\n## 7. Policy notes\n\n');
writeMarkdownTable(fid, policy);

fprintf(fid, '\n## 8. 読み方\n\n');
fprintf(fid, '- 今後のT&M Table9〜12主解析入口は `x_report <= 0.05` かつ `source01` の280点である。\n');
fprintf(fid, '- Table9/11/12は旧legacy集合と一致していたが、Table10は旧86点と新190点で抽出思想が異なる。\n');
fprintf(fid, '- 旧Table10 86点はquality条件で絞った集合ではないため、新Table10 190点との差を誤りとして扱わない。\n');
fprintf(fid, '- 旧176点は過去診断との比較用legacy集合として凍結し、今後の主解析入口には使わない。\n');
fprintf(fid, '- 次にPM/F1診断へ進む場合は、このTM01 main setを入口として用いる。ただし、このrunではまだPM/F1診断を実施していない。\n\n');

fprintf(fid, '## 9. 採用・保留\n\n');
fprintf(fid, '### 採用\n\n');
fprintf(fid, '- TM01を主解析入口固定runとして扱う。\n');
fprintf(fid, '- 主解析入口は `source01_lowX_9_12 = 280` とする。\n');
fprintf(fid, '- 入口条件は `x_report <= 0.05` とする。\n');
fprintf(fid, '- 旧176点はlegacy referenceとして凍結する。\n\n');
fprintf(fid, '### 保留\n\n');
fprintf(fid, '- この280点でPM診断へ進んだとき、旧176点診断と結果がどう変わるか。\n');
fprintf(fid, '- F1再fitへ進むかどうか。\n');
fprintf(fid, '- Table10 new_only 143点が診断結果に与える影響。\n');
fprintf(fid, '- source09/Weatherhead照合後の扱い。\n\n');
fprintf(fid, '### まだ行わない\n\n');
fprintf(fid, '- PM計算。\n');
fprintf(fid, '- F1再fit。\n');
fprintf(fid, '- L/D補正式作成。\n');
end

%% ------------------------------------------------------------------------
function name = getFileName(path)
[~, n, e] = fileparts(char(path));
name = [n e];
end

%% ------------------------------------------------------------------------
function writeMarkdownTable(fid, T)
if isempty(T) || height(T) == 0 || width(T) == 0
    fprintf(fid, '(empty)\n');
    return;
end
vars = string(T.Properties.VariableNames);
fprintf(fid, '| %s |\n', strjoin(vars, ' | '));
fprintf(fid, '| %s |\n', strjoin(repmat("---", 1, numel(vars)), ' | '));
for i = 1:height(T)
    vals = strings(1, numel(vars));
    for j = 1:numel(vars)
        vals(j) = mdCell(T{i,j});
    end
    fprintf(fid, '| %s |\n', strjoin(vals, ' | '));
end
end

%% ------------------------------------------------------------------------
function s = mdCell(v)
if isnumeric(v)
    if isempty(v) || isnan(v)
        s = "";
    else
        s = string(sprintf('%.6g', v));
    end
elseif islogical(v)
    s = string(v);
elseif iscell(v)
    s = string(v{1});
else
    s = string(v);
end
s = replace(s, "|", "\\|");
s = replace(s, newline, " ");
end
