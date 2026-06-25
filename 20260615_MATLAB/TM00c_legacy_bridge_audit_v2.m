function TM00c_legacy_bridge_audit_v2(rootDir, tm00bXlsx, legacyXlsx, legacySheet)
% TM00c_legacy_bridge_audit_v2
%
% Purpose:
%   Bridge-audit between the old legacy Table9/10/11/12 set used in prior
%   diagnostics and the new canonical Markdown based source01-lowX set.
%
%   This run does NOT compute PM, does NOT refit F1, and does NOT create
%   an L/D correction.  It only checks key-level membership and condition
%   ranges so that old v15/v16 style results can be compared safely with
%   the new canonical Table9-12 candidate set.
%
% Inputs:
%   rootDir     : folder. Default = pwd.
%   tm00bXlsx   : optional. If omitted, latest
%                 TM00b_tables9_12_candidate_sets_*.xlsx is used.
%   legacyXlsx  : optional. If omitted, a likely legacy workbook is searched.
%   legacySheet : optional. If omitted, a likely F1/current single-tube
%                 sheet is selected.
%
% Expected legacy target:
%   old source01 Table9-12 set:
%     Table9  = 30
%     Table10 = 86
%     Table11 = 30
%     Table12 = 30
%     Total   = 176
%
% Expected new target:
%   new canonical source01_lowX_9_12 from TM00b:
%     Table9  = 30
%     Table10 = 190
%     Table11 = 30
%     Table12 = 30
%     Total   = 280
%
% Important interpretation:
%   The old Table10 86 is not assumed to be identical to, or a subset of,
%   the new Table10 source01 lowX 190. This run verifies the overlap.

if nargin < 1 || strlength(string(rootDir)) == 0
    rootDir = pwd;
end
rootDir = char(rootDir);

if nargin < 2 || strlength(string(tm00bXlsx)) == 0
    tm00bXlsx = findLatest(rootDir, 'TM00b_tables9_12_candidate_sets_*.xlsx');
else
    tm00bXlsx = char(tm00bXlsx);
end
assert(isfile(tm00bXlsx), 'TM00b xlsx not found: %s', tm00bXlsx);

if nargin < 3 || strlength(string(legacyXlsx)) == 0
    legacyXlsx = findLegacyWorkbook(rootDir);
else
    legacyXlsx = char(legacyXlsx);
end
assert(isfile(legacyXlsx), 'Legacy xlsx not found: %s', legacyXlsx);

if nargin < 4 || strlength(string(legacySheet)) == 0
    legacySheet = chooseLegacySheet(legacyXlsx);
else
    legacySheet = char(legacySheet);
end

fprintf('TM00b workbook : %s\n', tm00bXlsx);
fprintf('Legacy workbook: %s\n', legacyXlsx);
fprintf('Legacy sheet   : %s\n', legacySheet);

ts = datestr(now, 'yyyymmdd_HHMMSS');
outXlsx = fullfile(rootDir, sprintf('TM00c_legacy_bridge_audit_%s.xlsx', ts));
outMd   = fullfile(rootDir, sprintf('run_report_TM00c_legacy_bridge_audit_%s.md', ts));

% ---- read new candidate set
newT = readtable(tm00bXlsx, 'Sheet', 'source01_lowX', 'PreserveVariableNames', true);
newT = normalizeNewTable(newT);
newT = newT(ismember(newT.TableNo, [9 10 11 12]) & newT.source == "source01", :);
newT.key = makeKey(newT.TableNo, newT.ExptNo);

% ---- read and normalize legacy selected set
legacyRaw = readtable(legacyXlsx, 'Sheet', legacySheet, 'PreserveVariableNames', true);
legacyT = normalizeLegacyTable(legacyRaw);
legacyT = legacyT(ismember(legacyT.TableNo, [9 10 11 12]) & legacyT.source == "source01", :);
legacyT.key = makeKey(legacyT.TableNo, legacyT.ExptNo);

% Deduplicate for membership comparison while retaining first rows.
legacyKeys = unique(legacyT.key, 'stable');
newKeys = unique(newT.key, 'stable');

overlapKeys = intersect(legacyKeys, newKeys, 'stable');
legacyOnlyKeys = setdiff(legacyKeys, newKeys, 'stable');
newOnlyKeys = setdiff(newKeys, legacyKeys, 'stable');

legacyUnique = takeFirstByKey(legacyT, legacyKeys);
newUnique = takeFirstByKey(newT, newKeys);
overlapNew = takeFirstByKey(newT, overlapKeys);
overlapLegacy = takeFirstByKey(legacyT, overlapKeys);
legacyOnly = takeFirstByKey(legacyT, legacyOnlyKeys);
newOnly = takeFirstByKey(newT, newOnlyKeys);

% Add membership flags to new and legacy tables.
newMembership = newUnique;
newMembership.in_legacy = ismember(newMembership.key, legacyKeys);
newMembership.membership = strings(height(newMembership),1);
newMembership.membership(newMembership.in_legacy) = "overlap_legacy_and_new";
newMembership.membership(~newMembership.in_legacy) = "new_only";

legacyMembership = legacyUnique;
legacyMembership.in_new_source01_lowX = ismember(legacyMembership.key, newKeys);
legacyMembership.membership = strings(height(legacyMembership),1);
legacyMembership.membership(legacyMembership.in_new_source01_lowX) = "overlap_legacy_and_new";
legacyMembership.membership(~legacyMembership.in_new_source01_lowX) = "legacy_only";

% Bridge labels for combined condition summary. Prefer new canonical condition
% values when available; use legacy rows for legacy-only.
B_overlap = overlapNew; B_overlap.bridge_group = repmat("overlap", height(B_overlap), 1);
B_newOnly = newOnly; B_newOnly.bridge_group = repmat("new_only", height(B_newOnly), 1);
B_legacyOnly = legacyOnly; B_legacyOnly.bridge_group = repmat("legacy_only", height(B_legacyOnly), 1);
bridgeRows = vertcatAlign(B_overlap, B_newOnly, B_legacyOnly);

% Summaries
expectedChecks = makeExpectedChecks(newUnique, legacyUnique, overlapKeys, newOnlyKeys, legacyOnlyKeys);
overallSummary = makeOverallSummary(newUnique, legacyUnique, overlapKeys, newOnlyKeys, legacyOnlyKeys);
byTable = makeByTableSummary(newUnique, legacyUnique);
bridgeByTable = makeBridgeByTableSummary(newUnique, legacyUnique, overlapKeys, newOnlyKeys, legacyOnlyKeys);
conditionSummary = groupConditionSummary(bridgeRows, {'bridge_group'});
conditionByTable = groupConditionSummary(bridgeRows, {'TableNo','bridge_group'});

% Also produce focused Table10 sheets.
T10legacy = legacyUnique(legacyUnique.TableNo == 10, :);
T10new = newUnique(newUnique.TableNo == 10, :);
T10overlapKeys = intersect(T10legacy.key, T10new.key, 'stable');
T10legacyOnlyKeys = setdiff(T10legacy.key, T10new.key, 'stable');
T10newOnlyKeys = setdiff(T10new.key, T10legacy.key, 'stable');
T10overlap = takeFirstByKey(newT, T10overlapKeys);
T10legacyOnly = takeFirstByKey(legacyT, T10legacyOnlyKeys);
T10newOnly = takeFirstByKey(newT, T10newOnlyKeys);

fprintf('Writing Excel output: %s\n', outXlsx);
writetable(expectedChecks, outXlsx, 'Sheet', 'expected_checks');
writetable(overallSummary, outXlsx, 'Sheet', 'overall_summary');
writetable(byTable, outXlsx, 'Sheet', 'legacy_new_by_table');
writetable(bridgeByTable, outXlsx, 'Sheet', 'bridge_by_table');
writetable(conditionSummary, outXlsx, 'Sheet', 'condition_summary');
writetable(conditionByTable, outXlsx, 'Sheet', 'condition_by_table');
writetable(newMembership, outXlsx, 'Sheet', 'new_source01_lowX');
writetable(legacyMembership, outXlsx, 'Sheet', 'legacy_source01_9_12');
writetable(overlapNew, outXlsx, 'Sheet', 'overlap_new_values');
writetable(overlapLegacy, outXlsx, 'Sheet', 'overlap_legacy_values');
writetable(newOnly, outXlsx, 'Sheet', 'new_only');
writetable(legacyOnly, outXlsx, 'Sheet', 'legacy_only');
writetable(T10overlap, outXlsx, 'Sheet', 'T10_overlap');
writetable(T10newOnly, outXlsx, 'Sheet', 'T10_new_only');
writetable(T10legacyOnly, outXlsx, 'Sheet', 'T10_legacy_only');

fprintf('Writing Markdown report: %s\n', outMd);
writeReport(outMd, rootDir, tm00bXlsx, legacyXlsx, legacySheet, outXlsx, ...
    expectedChecks, overallSummary, byTable, bridgeByTable, conditionSummary, conditionByTable);

fprintf('\nDone.\n');
fprintf('Excel : %s\n', outXlsx);
fprintf('Report: %s\n', outMd);
end

%% ------------------------------------------------------------------------
function latest = findLatest(rootDir, pattern)
D = dir(fullfile(rootDir, pattern));
assert(~isempty(D), 'No file found for pattern %s in %s', pattern, rootDir);
[~,idx] = max([D.datenum]);
latest = fullfile(D(idx).folder, D(idx).name);
end

%% ------------------------------------------------------------------------
function f = findLegacyWorkbook(rootDir)
patterns = { ...
    'H52Q_current_single_tube_input*.xlsx', ...
    '*current_single_tube_input*.xlsx', ...
    '20260612_計算結果比較r8_staging_TM8_14_v1.xlsx', ...
    '*staging_TM8_14*.xlsx', ...
    '20260612_計算結果比較r8_result_文献追加用.xlsx', ...
    '*r8_result*文献追加*.xlsx', ...
    '*計算結果比較r8*.xlsx' ...
    };
allD = [];
for i = 1:numel(patterns)
    D = dir(fullfile(rootDir, patterns{i}));
    if ~isempty(D)
        allD = [allD; D(:)]; %#ok<AGROW>
    end
end
assert(~isempty(allD), ['No legacy workbook found. Provide legacyXlsx explicitly, e.g.\n' ...
    '  TM00c_legacy_bridge_audit_v2(pwd, "", "H52Q_current_single_tube_input_v1_....xlsx")']);
[~,idx] = max([allD.datenum]);
f = fullfile(allD(idx).folder, allD(idx).name);
end

%% ------------------------------------------------------------------------
function sheet = chooseLegacySheet(xlsx)
[~, sheets] = xlsfinfo(xlsx);
assert(~isempty(sheets), 'No sheets found in legacy workbook: %s', xlsx);
prefer = { ...
    'ST_F1_T8_14_current', ...
    'SRC_tm_r124_F1_T8_14', ...
    'tm_r124_F1_T8_14', ...
    'tm_F1_ST', ...
    'ST_noF1_T8_14_current', ...
    'SRC_tm_r123_noF1_T8_14', ...
    'tm_r123_noF1_T8_14', ...
    'tm_ST' ...
    };
for i = 1:numel(prefer)
    if any(strcmp(sheets, prefer{i}))
        sheet = prefer{i};
        return;
    end
end
% Last-resort heuristic: first sheet containing F1 and T8_14/ST.
for i = 1:numel(sheets)
    s = string(sheets{i});
    if contains(lower(s), 'f1') && (contains(lower(s), 't8') || contains(lower(s), 'st'))
        sheet = char(s);
        return;
    end
end
sheet = sheets{1};
warning('No preferred legacy sheet found; using first sheet: %s', sheet);
end

%% ------------------------------------------------------------------------
function T = normalizeNewTable(T)
T = convertTextColumns(T);
T = ensureVar(T, 'TableNo', {'TableNo','Table','table','Table_No'});
T = ensureVar(T, 'ExptNo', {'ExptNo','EXPT NO','No_TableNo','NoTableNo','No'});
T = ensureVar(T, 'source', {'source','Source'});
if ~ismember('flag_norm', T.Properties.VariableNames)
    if ismember('Flag', T.Properties.VariableNames)
        T.flag_norm = string(T.Flag);
    elseif ismember('flag', T.Properties.VariableNames)
        T.flag_norm = string(T.flag);
    else
        T.flag_norm = repmat("none", height(T), 1);
    end
end
T.flag_norm = normalizeFlag(T.flag_norm);
T.source = normalizeSource(T.source, T.ExptNo);
T.ExptNo = normalizeExptNo(T.ExptNo);
T.ExptNo = addDefaultSourceSuffixIfMissing(T.ExptNo, T.source);
T.TableNo = double(T.TableNo);
T = ensureNumericAliases(T);
end

%% ------------------------------------------------------------------------
function T = normalizeLegacyTable(T)
T = convertTextColumns(T);

% Legacy current_single_tube sheets use No_TableNo as the table number and
% No as the experiment number.  v1 treated No_TableNo as an ExptNo candidate
% but not as a TableNo candidate, which failed on ST_F1_T8_14_current.
T = ensureVar(T, 'TableNo', {'TableNo','Table','table','Table_No','TableN','Table_No_','No_TableNo'});
T = ensureVar(T, 'ExptNo', {'ExptNo','EXPT NO','No','NoTableNo','No_Table','No_Table_No','ExpNo','ExperimentNo'});

T.TableNo = double(toDouble(T.TableNo));
T.ExptNo = normalizeExptNo(T.ExptNo);

if ~ismember('source', T.Properties.VariableNames)
    T.source = strings(height(T),1);
end
T.source = normalizeSourceLegacy(T.source, T.ExptNo, T.TableNo);
T.ExptNo = addDefaultSourceSuffixIfMissing(T.ExptNo, T.source);

if ~ismember('flag_norm', T.Properties.VariableNames)
    if ismember('Flag', T.Properties.VariableNames)
        T.flag_norm = string(T.Flag);
    elseif ismember('flag', T.Properties.VariableNames)
        T.flag_norm = string(T.flag);
    else
        T.flag_norm = repmat("none", height(T), 1);
    end
end
T.flag_norm = normalizeFlag(T.flag_norm);
T = ensureNumericAliases(T);
end

%% ------------------------------------------------------------------------
function T = convertTextColumns(T)
for i = 1:numel(T.Properties.VariableNames)
    v = T.Properties.VariableNames{i};
    if iscellstr(T.(v)) || iscell(T.(v)) || ischar(T.(v))
        T.(v) = string(T.(v));
    end
end
end

%% ------------------------------------------------------------------------
function T = ensureVar(T, canonical, candidates)
if ismember(canonical, T.Properties.VariableNames)
    return;
end
vars = string(T.Properties.VariableNames);
for i = 1:numel(candidates)
    cand = string(candidates{i});
    idx = find(strcmpi(vars, cand), 1);
    if ~isempty(idx)
        T.(canonical) = T.(vars(idx));
        return;
    end
end
error('Required column not found for %s. Tried: %s. Available: %s', ...
    canonical, strjoin(string(candidates), ', '), strjoin(vars, ', '));
end

%% ------------------------------------------------------------------------
function x = normalizeExptNo(x)
x = string(x);
x = strtrim(x);
% numeric imported as strings can have trailing .0; keep real suffixes.
for i = 1:numel(x)
    xi = x(i);
    if strlength(xi) == 0 || ismissing(xi)
        continue;
    end
    xi = regexprep(xi, '\s+', '');
    % If read as e.g. 1.0100, do not aggressively shorten because source suffix matters.
    % But for exact integer-like values, use integer string.
    x(i) = xi;
end
end

%% ------------------------------------------------------------------------
function s = normalizeSource(sourceIn, exptNo)
sourceIn = string(sourceIn);
exptNo = string(exptNo);
s = strings(numel(exptNo),1);
for i = 1:numel(exptNo)
    val = strtrim(sourceIn(i));
    if strlength(val) > 0 && ~ismissing(val)
        val = lower(val);
        if startsWith(val, 'source')
            s(i) = val;
        else
            % numeric-like source code
            code = regexprep(val, '[^0-9]', '');
            if strlength(code) > 0
                s(i) = "source" + pad(code, 2, 'left', '0');
            else
                s(i) = val;
            end
        end
    else
        token = regexp(char(exptNo(i)), '\.(\d+)$', 'tokens', 'once');
        if ~isempty(token)
            s(i) = "source" + pad(string(token{1}), 2, 'left', '0');
        else
            s(i) = "unknown";
        end
    end
end
end

%% ------------------------------------------------------------------------
function s = normalizeSourceLegacy(sourceIn, exptNo, tableNo)
% Legacy sheets sometimes have no explicit source column and experiment No
% may be an integer without .01 suffix.  For the legacy bridge target,
% Table9/10/11/12 rows in current_single_tube are the old source01 set.
% If a source suffix is present in ExptNo, use it.  Otherwise assign source01
% for Table9-12 so the old 176-point anchor can be compared to canonical data.
sourceIn = string(sourceIn);
exptNo = string(exptNo);
tableNo = double(tableNo);
s = normalizeSource(sourceIn, exptNo);
for i = 1:numel(s)
    if s(i) == "unknown" && ismember(tableNo(i), [9 10 11 12])
        s(i) = "source01";
    end
end
end

%% ------------------------------------------------------------------------
function x = addDefaultSourceSuffixIfMissing(x, source)
x = string(x);
source = string(source);
for i = 1:numel(x)
    if strlength(x(i)) == 0 || ismissing(x(i))
        continue;
    end
    if ~contains(x(i), '.')
        tok = regexp(char(source(i)), 'source(\d+)', 'tokens', 'once');
        if ~isempty(tok)
            x(i) = x(i) + "." + pad(string(tok{1}), 2, 'left', '0');
        end
    end
end
end

%% ------------------------------------------------------------------------
function f = normalizeFlag(f)
f = string(f);
f = strtrim(f);
f(ismissing(f) | strlength(f)==0 | lower(f)=="nan" | lower(f)=="missing") = "none";
f = upper(f);
f(f=="NONE") = "none";
end

%% ------------------------------------------------------------------------
function T = ensureNumericAliases(T)
% Add common numeric aliases if possible. Missing columns are filled with NaN
% so summaries remain robust.
T = aliasNumeric(T, 'Pressure_psia', {'Pressure_psia','P_psia','P','Pressure'});
T = aliasNumeric(T, 'G_1e6_lb_hr_ft2', {'G_1e6_lb_hr_ft2','G','MassVelocity_x1e-6_lb_hr_ft2','MassVelocity','MassVelocity_x1e_6_lb_hr_ft2'});
T = aliasNumeric(T, 'G_SI_kg_m2s', {'G_SI_kg_m2s','GSI','G_kg_m2s'});
T = aliasNumeric(T, 'L_over_D', {'L_over_D','LD','L_D','L/D'});
T = aliasNumeric(T, 'Hsub_kJ_kg', {'Hsub_kJ_kg','Hsub','hSub_kJ_kg','Hsub_true_kJkg'});
T = aliasNumeric(T, 'x_report', {'x_report','ExitQuality_lb_lb','Exit Quality','x','x_Mes','xMes'});
T = aliasNumeric(T, 'D_mm', {'D_mm','DIA_mm','D_mm_'});
T = aliasNumeric(T, 'D_in', {'D_in','DIA','Dia_in','DIA_in'});
T = aliasNumeric(T, 'L_in', {'L_in','Length_in','LENGTH','Length'});

% If G_SI absent but G_T&M exists, convert.
if all(isnan(T.G_SI_kg_m2s)) && ~all(isnan(T.G_1e6_lb_hr_ft2))
    T.G_SI_kg_m2s = T.G_1e6_lb_hr_ft2 * 1356.23;
end
% If D_mm absent but D_in exists, convert.
if all(isnan(T.D_mm)) && ~all(isnan(T.D_in))
    T.D_mm = T.D_in * 25.4;
end
% If L/D absent but L and D exist, compute.
if all(isnan(T.L_over_D)) && ~all(isnan(T.L_in)) && ~all(isnan(T.D_in))
    T.L_over_D = T.L_in ./ T.D_in;
end
end

%% ------------------------------------------------------------------------
function T = aliasNumeric(T, canonical, candidates)
if ismember(canonical, T.Properties.VariableNames)
    T.(canonical) = toDouble(T.(canonical));
    return;
end
vars = string(T.Properties.VariableNames);
for i = 1:numel(candidates)
    idx = find(strcmpi(vars, string(candidates{i})), 1);
    if ~isempty(idx)
        T.(canonical) = toDouble(T.(vars(idx)));
        return;
    end
end
T.(canonical) = nan(height(T),1);
end

%% ------------------------------------------------------------------------
function y = toDouble(x)
if isnumeric(x)
    y = double(x);
else
    y = str2double(string(x));
end
end

%% ------------------------------------------------------------------------
function key = makeKey(tableNo, exptNo)
key = "T" + string(round(double(tableNo))) + "_" + string(exptNo);
end

%% ------------------------------------------------------------------------
function Tout = takeFirstByKey(T, keys)
keys = string(keys);
if isempty(keys)
    Tout = T([],:);
    return;
end
[tf, loc] = ismember(keys, T.key);
loc = loc(tf);
Tout = T(loc,:);
end

%% ------------------------------------------------------------------------
function C = vertcatAlign(varargin)
% Vertically concatenate tables by aligning to union of variables.
vars = strings(0);
for i = 1:nargin
    vars = union(vars, string(varargin{i}.Properties.VariableNames), 'stable');
end
C = table();
for i = 1:nargin
    T = varargin{i};
    for v = vars'
        if ~ismember(v, string(T.Properties.VariableNames))
            T.(v) = missingColumnLike(C, T, v);
        end
    end
    T = T(:, cellstr(vars));
    C = [C; T]; %#ok<AGROW>
end
end

%% ------------------------------------------------------------------------
function col = missingColumnLike(~, T, v)
% Simple default for missing variables.
if contains(lower(v), 'key') || contains(lower(v), 'source') || contains(lower(v), 'flag') || contains(lower(v), 'group') || contains(lower(v), 'expt')
    col = strings(height(T),1);
else
    col = nan(height(T),1);
end
end

%% ------------------------------------------------------------------------
function E = makeExpectedChecks(newT, legacyT, overlapKeys, newOnlyKeys, legacyOnlyKeys)
metrics = table();
metrics.checkName = [ ...
    "new_source01_lowX_9_12"; ...
    "legacy_source01_9_12"; ...
    "new_T9"; "new_T10"; "new_T11"; "new_T12"; ...
    "legacy_T9"; "legacy_T10"; "legacy_T11"; "legacy_T12"; ...
    "overlap_all_observed"; ...
    "new_only_all_observed"; ...
    "legacy_only_all_observed"; ...
    "T10_overlap_observed"; ...
    "T10_new_only_observed"; ...
    "T10_legacy_only_observed" ...
    ];
% Only the new/legacy input set sizes are fixed expectations.  Overlap
% sizes are observations because old Table10 86 may not be a simple subset
% under the canonical TableNo+ExptNo key.
metrics.expected = [280;176;30;190;30;30;30;86;30;30;NaN;NaN;NaN;NaN;NaN;NaN];
actual = nan(height(metrics),1);
actual(1) = height(newT);
actual(2) = height(legacyT);
for tbl = 9:12
    actual(2 + (tbl-8)) = sum(newT.TableNo == tbl);
    actual(6 + (tbl-8)) = sum(legacyT.TableNo == tbl);
end
actual(11) = numel(overlapKeys);
actual(12) = numel(newOnlyKeys);
actual(13) = numel(legacyOnlyKeys);
newT10 = newT(newT.TableNo == 10,:);
legacyT10 = legacyT(legacyT.TableNo == 10,:);
actual(14) = numel(intersect(unique(newT10.key), unique(legacyT10.key)));
actual(15) = numel(setdiff(unique(newT10.key), unique(legacyT10.key)));
actual(16) = numel(setdiff(unique(legacyT10.key), unique(newT10.key)));
metrics.actual = actual;
metrics.status = repmat("OK", height(metrics), 1);
metrics.status(isnan(metrics.expected)) = "INFO";
idxFixed = ~isnan(metrics.expected);
metrics.status(idxFixed & metrics.actual ~= metrics.expected) = "CHECK";
E = metrics;
end

%% ------------------------------------------------------------------------
function S = makeOverallSummary(newT, legacyT, overlapKeys, newOnlyKeys, legacyOnlyKeys)
S = table();
S.item = ["new_source01_lowX_9_12"; "legacy_source01_9_12"; "overlap"; "new_only"; "legacy_only"];
S.N = [height(newT); height(legacyT); numel(overlapKeys); numel(newOnlyKeys); numel(legacyOnlyKeys)];
S.note = [ ...
    "New canonical source01 lowX set from TM00b"; ...
    "Old legacy source01 Table9-12 set from legacy workbook"; ...
    "Keys present in both sets"; ...
    "New canonical keys absent from old legacy set"; ...
    "Old legacy keys absent from new canonical source01 lowX set" ...
    ];
end

%% ------------------------------------------------------------------------
function S = makeByTableSummary(newT, legacyT)
tables = (9:12)';
S = table();
S.TableNo = tables;
S.N_new = zeros(numel(tables),1);
S.N_legacy = zeros(numel(tables),1);
S.N_overlap = zeros(numel(tables),1);
S.N_new_only = zeros(numel(tables),1);
S.N_legacy_only = zeros(numel(tables),1);
for i = 1:numel(tables)
    tbl = tables(i);
    nk = unique(newT.key(newT.TableNo == tbl));
    lk = unique(legacyT.key(legacyT.TableNo == tbl));
    S.N_new(i) = numel(nk);
    S.N_legacy(i) = numel(lk);
    S.N_overlap(i) = numel(intersect(nk, lk));
    S.N_new_only(i) = numel(setdiff(nk, lk));
    S.N_legacy_only(i) = numel(setdiff(lk, nk));
end
end

%% ------------------------------------------------------------------------
function S = makeBridgeByTableSummary(newT, legacyT, overlapKeys, newOnlyKeys, legacyOnlyKeys)
allKeys = [overlapKeys(:); newOnlyKeys(:); legacyOnlyKeys(:)];
groups = [repmat("overlap", numel(overlapKeys), 1); repmat("new_only", numel(newOnlyKeys), 1); repmat("legacy_only", numel(legacyOnlyKeys), 1)];
TableNo = nan(numel(allKeys),1);
for i = 1:numel(allKeys)
    k = allKeys(i);
    idx = find(newT.key == k, 1);
    if ~isempty(idx)
        TableNo(i) = newT.TableNo(idx);
    else
        idx = find(legacyT.key == k, 1);
        if ~isempty(idx)
            TableNo(i) = legacyT.TableNo(idx);
        end
    end
end
T = table(TableNo, groups, 'VariableNames', {'TableNo','bridge_group'});
[G, keys] = findgroups(T(:, {'TableNo','bridge_group'}));
S = keys;
S.N = splitapply(@numel, T.TableNo, G);
end

%% ------------------------------------------------------------------------
function S = groupConditionSummary(T, groupVars)
if isempty(T)
    S = table();
    return;
end
gv = string(groupVars);
[G, keys] = findgroups(T(:, cellstr(gv)));
S = keys;
n = max(G);
N = zeros(n,1);
P_min = nan(n,1); P_max = nan(n,1);
GSI_min = nan(n,1); GSI_max = nan(n,1);
LD_min = nan(n,1); LD_max = nan(n,1);
Hsub_min = nan(n,1); Hsub_max = nan(n,1);
x_min = nan(n,1); x_max = nan(n,1);
flag_counts = strings(n,1);
for i = 1:n
    idx = G == i;
    Ti = T(idx,:);
    N(i) = height(Ti);
    P_min(i) = min(Ti.Pressure_psia, [], 'omitnan');
    P_max(i) = max(Ti.Pressure_psia, [], 'omitnan');
    GSI_min(i) = min(Ti.G_SI_kg_m2s, [], 'omitnan');
    GSI_max(i) = max(Ti.G_SI_kg_m2s, [], 'omitnan');
    LD_min(i) = min(Ti.L_over_D, [], 'omitnan');
    LD_max(i) = max(Ti.L_over_D, [], 'omitnan');
    Hsub_min(i) = min(Ti.Hsub_kJ_kg, [], 'omitnan');
    Hsub_max(i) = max(Ti.Hsub_kJ_kg, [], 'omitnan');
    x_min(i) = min(Ti.x_report, [], 'omitnan');
    x_max(i) = max(Ti.x_report, [], 'omitnan');
    flag_counts(i) = compactCounts(Ti.flag_norm);
end
S.N = N;
S.flag_counts = flag_counts;
S.P_min = P_min; S.P_max = P_max;
S.GSI_min = GSI_min; S.GSI_max = GSI_max;
S.LD_min = LD_min; S.LD_max = LD_max;
S.Hsub_min = Hsub_min; S.Hsub_max = Hsub_max;
S.x_min = x_min; S.x_max = x_max;
end

%% ------------------------------------------------------------------------
function s = compactCounts(x)
if isempty(x)
    s = "";
    return;
end
if isnumeric(x)
    ux = unique(x(~isnan(x)));
    parts = strings(numel(ux),1);
    for i = 1:numel(ux)
        parts(i) = sprintf('%g:%d', ux(i), sum(x == ux(i)));
    end
else
    x = string(x);
    ux = unique(x);
    parts = strings(numel(ux),1);
    for i = 1:numel(ux)
        parts(i) = sprintf('%s:%d', ux(i), sum(x == ux(i)));
    end
end
s = strjoin(parts, ', ');
end

%% ------------------------------------------------------------------------
function writeReport(outMd, rootDir, tm00bXlsx, legacyXlsx, legacySheet, outXlsx, ...
    expectedChecks, overallSummary, byTable, bridgeByTable, conditionSummary, conditionByTable)

fid = fopen(outMd, 'w');
assert(fid > 0, 'Cannot open report for writing: %s', outMd);
c = onCleanup(@() fclose(fid));

fprintf(fid, '# TM00c Legacy Bridge Audit\n\n');
fprintf(fid, '作成日: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
fprintf(fid, '## 1. 目的\n\n');
fprintf(fid, ['TM00bで固定した新しい正本候補 `source01_lowX_9_12` と、過去診断で使っていた旧Table9〜12集合の関係をキー単位で確認する。\n\n' ...
    'このrunでは採用点を決めない。PM計算、F1再fit、L/D補正式作成は行わない。\n\n']);

fprintf(fid, '## 2. 入力・出力\n\n');
fprintf(fid, '- rootDir: `%s`\n', rootDir);
fprintf(fid, '- input TM00b xlsx: `%s`\n', fileNameOnly(tm00bXlsx));
fprintf(fid, '- legacy xlsx: `%s`\n', fileNameOnly(legacyXlsx));
fprintf(fid, '- legacy sheet: `%s`\n', legacySheet);
fprintf(fid, '- output Excel: `%s`\n\n', fileNameOnly(outXlsx));

fprintf(fid, '## 3. Expected checks\n\n');
writeMdTable(fid, expectedChecks);

fprintf(fid, '\n## 4. Overall bridge summary\n\n');
writeMdTable(fid, overallSummary);

fprintf(fid, '\n## 5. By-table bridge summary\n\n');
writeMdTable(fid, byTable);

fprintf(fid, '\n## 6. Bridge groups by table\n\n');
writeMdTable(fid, bridgeByTable);

fprintf(fid, '\n## 7. Condition summary by bridge group\n\n');
writeMdTable(fid, conditionSummary);

fprintf(fid, '\n## 8. Condition summary by table and bridge group\n\n');
writeMdTable(fid, conditionByTable);

fprintf(fid, '\n## 9. 読み方\n\n');
fprintf(fid, ['- `source01_lowX_9_12` は正本Markdown起点の新しい主解析候補である。\n' ...
    '- 旧集合は過去のv15/v16系診断の入口であり、Table10旧86点を含む。\n' ...
    '- 新旧の差は主にTable10で出るはずである。\n' ...
    '- 旧Table10 86点を、新Table10 source01 lowX 190点の単純な部分集合と仮定しない。\n' ...
    '- 数だけを見ると新Table10は旧86点より104点多いが、集合差としては overlap / new_only / legacy_only を見る。\n' ...
    '- このrunで食い違いがあっても、直ちに誤りとはせず、旧集合の抽出条件と新しいlowX入口条件の違いとして読む。\n']);

fprintf(fid, '\n## 10. 採用・保留\n\n');
fprintf(fid, '### 採用\n\n');
fprintf(fid, ['- TM00cは旧176点相当集合と新280点集合の橋渡し監査runとして扱う。\n' ...
    '- 新旧比較はTableNo + ExptNoキーで行う。\n' ...
    '- TM00cではPM計算、F1再fit、L/D補正式には進まない。\n']);
fprintf(fid, '\n### 保留\n\n');
fprintf(fid, ['- どの候補集合でPM診断・F1再fitへ進むか。\n' ...
    '- 旧Table10 86点の抽出思想を今後保持するか。\n' ...
    '- 新Table10 source01 lowXのnew_only点をどこまで主解析に入れるか。\n' ...
    '- legacy_only点がlowX外または旧F1/TmTsat監査由来としてどう位置づくか。\n']);
end

%% ------------------------------------------------------------------------
function fn = fileNameOnly(path)
[~, name, ext] = fileparts(path);
fn = [name ext];
end

%% ------------------------------------------------------------------------
function writeMdTable(fid, T)
if isempty(T)
    fprintf(fid, '_No rows._\n');
    return;
end
vars = string(T.Properties.VariableNames);
fprintf(fid, '| %s |\n', strjoin(vars, ' | '));
fprintf(fid, '| %s |\n', strjoin(repmat("---", size(vars)), ' | '));
for i = 1:height(T)
    vals = strings(1, numel(vars));
    for j = 1:numel(vars)
        vals(j) = formatValue(T{i,j});
    end
    fprintf(fid, '| %s |\n', strjoin(vals, ' | '));
end
end

%% ------------------------------------------------------------------------
function s = formatValue(v)
if iscell(v)
    v = v{1};
end
if ismissingValue(v)
    s = "";
elseif isnumeric(v)
    if isscalar(v)
        if isnan(v)
            s = "";
        elseif abs(v - round(v)) < 1e-12
            s = string(sprintf('%.0f', v));
        else
            s = string(sprintf('%.6g', v));
        end
    else
        s = "[array]";
    end
elseif islogical(v)
    s = string(v);
else
    s = string(v);
end
s = replace(s, "|", "\\|");
end

%% ------------------------------------------------------------------------
function tf = ismissingValue(v)
try
    tf = ismissing(v);
    if ~isscalar(tf); tf = false; end
catch
    tf = false;
end
end
