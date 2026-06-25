function TM00b_tables9_12_candidate_sets_v1(rootDir, tm00aXlsx)
% TM00b_tables9_12_candidate_sets_v1
%
% Purpose:
%   Build explicit candidate sets from the TM00a common lowX inventory.
%   This is an inventory/candidate-set naming run only.
%   It does NOT compute PM, does NOT refit F1, and does NOT create L/D corrections.
%
% Inputs:
%   rootDir   : folder containing TM00a output xlsx. Default = pwd.
%   tm00aXlsx : optional TM00a xlsx path. If omitted, latest
%               TM00a_tables9_12_common_lowX_inventory_*.xlsx is used.
%
% Required TM00a sheets:
%   - raw_all
%   - all_lowX
%
% Main candidate sets:
%   1. raw_all_9_12                    : all Table9/10/11/12 raw rows
%   2. all_lowX_9_12                   : x_report <= 0.05, all sources
%   3. source01_lowX_9_12              : main source01 lowX candidate set
%   4. source01_lowX_P_ge_2000         : source01 lowX, P >= 2000 psia
%   5. table10_source09_lowX           : Weatherhead/ANL overlap candidate
%   6. per-table source01 lowX sheets  : T9/T10/T11/T12 source01 lowX
%
% Policy:
%   - Candidate sets are named and exported, but no final adoption is decided.
%   - source/G/L-D/flag/Table are not used as universal exclusion gates here.
%   - Weatherhead/source09 is kept as an overlap-candidate set, not as an
%     automatically independent added dataset.

if nargin < 1 || strlength(string(rootDir)) == 0
    rootDir = pwd;
end
rootDir = char(rootDir);

if nargin < 2 || strlength(string(tm00aXlsx)) == 0
    tm00aXlsx = findLatestTM00a(rootDir);
else
    tm00aXlsx = char(tm00aXlsx);
end
assert(isfile(tm00aXlsx), 'TM00a xlsx not found: %s', tm00aXlsx);

ts = datestr(now, 'yyyymmdd_HHMMSS');
outXlsx = fullfile(rootDir, sprintf('TM00b_tables9_12_candidate_sets_%s.xlsx', ts));
outMd   = fullfile(rootDir, sprintf('run_report_TM00b_tables9_12_candidate_sets_%s.md', ts));

fprintf('Reading TM00a output: %s\n', tm00aXlsx);
raw_all = readtable(tm00aXlsx, 'Sheet', 'raw_all', 'PreserveVariableNames', true);
all_lowX = readtable(tm00aXlsx, 'Sheet', 'all_lowX', 'PreserveVariableNames', true);

raw_all = normalizeTypes(raw_all);
all_lowX = normalizeTypes(all_lowX);

% Candidate sets
C = struct();
C.raw_all_9_12            = raw_all;
C.all_lowX_9_12           = all_lowX;
C.source01_lowX_9_12      = all_lowX(all_lowX.source == "source01", :);
C.source01_lowX_Pge2000   = all_lowX(all_lowX.source == "source01" & all_lowX.Pressure_psia >= 2000, :);
C.table10_source09_lowX   = all_lowX(all_lowX.TableNo == 10 & all_lowX.source == "source09", :);
C.T9_source01_lowX        = all_lowX(all_lowX.TableNo == 9  & all_lowX.source == "source01", :);
C.T10_source01_lowX       = all_lowX(all_lowX.TableNo == 10 & all_lowX.source == "source01", :);
C.T11_source01_lowX       = all_lowX(all_lowX.TableNo == 11 & all_lowX.source == "source01", :);
C.T12_source01_lowX       = all_lowX(all_lowX.TableNo == 12 & all_lowX.source == "source01", :);
C.all_lowX_cleanFlag      = all_lowX(all_lowX.flag_norm == "none", :);
C.all_lowX_nonCleanFlag   = all_lowX(all_lowX.flag_norm ~= "none", :);

% Candidate set summary
candidateNames = fieldnames(C);
summaryRows = cell(numel(candidateNames), 1);
for i = 1:numel(candidateNames)
    nm = candidateNames{i};
    summaryRows{i} = summarizeCandidate(nm, C.(nm));
end
candidate_summary = vertcat(summaryRows{:});

% Table/source summaries for key sets
source01_by_table = groupSummary(C.source01_lowX_9_12, {'TableNo'});
source01_by_table_source = groupSummary(C.source01_lowX_9_12, {'TableNo','source'});
all_lowX_by_table_source = groupSummary(C.all_lowX_9_12, {'TableNo','source'});
source09_by_flag = groupSummary(C.table10_source09_lowX, {'flag_norm'});

% Expected checks
expected_checks = makeExpectedChecks(C);

% Candidate membership table on raw_all
M = raw_all(:, {'TableNo','ExptNo','source','flag_norm','Pressure_psia','D_in','L_in','L_over_D', ...
    'G_1e6_lb_hr_ft2','G_SI_kg_m2s','Hsub_BTU_lb','Hsub_kJ_kg', ...
    'qCHF_1e6_BTU_hr_ft2','qCHF_MW_m2','x_report','lowX','provenance'});
M.in_all_lowX = M.lowX;
M.in_source01_lowX = M.lowX & M.source == "source01";
M.in_source01_lowX_Pge2000 = M.lowX & M.source == "source01" & M.Pressure_psia >= 2000;
M.in_T10_source09_lowX = M.lowX & M.TableNo == 10 & M.source == "source09";
M.in_T9_source01_lowX = M.lowX & M.TableNo == 9 & M.source == "source01";
M.in_T10_source01_lowX = M.lowX & M.TableNo == 10 & M.source == "source01";
M.in_T11_source01_lowX = M.lowX & M.TableNo == 11 & M.source == "source01";
M.in_T12_source01_lowX = M.lowX & M.TableNo == 12 & M.source == "source01";

fprintf('Writing Excel output: %s\n', outXlsx);
writetable(candidate_summary, outXlsx, 'Sheet', 'candidate_summary');
writetable(expected_checks, outXlsx, 'Sheet', 'expected_checks');
writetable(M, outXlsx, 'Sheet', 'candidate_membership');
writetable(C.raw_all_9_12, outXlsx, 'Sheet', 'raw_all_9_12');
writetable(C.all_lowX_9_12, outXlsx, 'Sheet', 'all_lowX_9_12');
writetable(C.source01_lowX_9_12, outXlsx, 'Sheet', 'source01_lowX');
writetable(C.source01_lowX_Pge2000, outXlsx, 'Sheet', 'source01_lowX_Pge2000');
writetable(C.table10_source09_lowX, outXlsx, 'Sheet', 'T10_source09_lowX');
writetable(C.T9_source01_lowX, outXlsx, 'Sheet', 'T9_source01_lowX');
writetable(C.T10_source01_lowX, outXlsx, 'Sheet', 'T10_source01_lowX');
writetable(C.T11_source01_lowX, outXlsx, 'Sheet', 'T11_source01_lowX');
writetable(C.T12_source01_lowX, outXlsx, 'Sheet', 'T12_source01_lowX');
writetable(C.all_lowX_cleanFlag, outXlsx, 'Sheet', 'all_lowX_cleanFlag');
writetable(C.all_lowX_nonCleanFlag, outXlsx, 'Sheet', 'all_lowX_nonCleanFlag');
writetable(source01_by_table, outXlsx, 'Sheet', 'src01_by_table');
writetable(source01_by_table_source, outXlsx, 'Sheet', 'src01_by_table_src');
writetable(all_lowX_by_table_source, outXlsx, 'Sheet', 'alllowX_table_source');
writetable(source09_by_flag, outXlsx, 'Sheet', 'T10src09_by_flag');

fprintf('Writing Markdown report: %s\n', outMd);
writeReport(outMd, rootDir, tm00aXlsx, outXlsx, candidate_summary, expected_checks, ...
    source01_by_table, all_lowX_by_table_source);

fprintf('\nDone.\n');
fprintf('Excel : %s\n', outXlsx);
fprintf('Report: %s\n', outMd);
end

%% ------------------------------------------------------------------------
function latest = findLatestTM00a(rootDir)
D = dir(fullfile(rootDir, 'TM00a_tables9_12_common_lowX_inventory_*.xlsx'));
assert(~isempty(D), 'No TM00a xlsx found in %s', rootDir);
[~,idx] = max([D.datenum]);
latest = fullfile(D(idx).folder, D(idx).name);
end

%% ------------------------------------------------------------------------
function T = normalizeTypes(T)
% Convert key text variables to string where needed.
for v = ["source","flag_norm","provenance","input_file","TableLabel","G_SI_bin","LD_bin"]
    if ismember(v, string(T.Properties.VariableNames))
        T.(v) = string(T.(v));
    end
end
if ismember('ExptNo', T.Properties.VariableNames)
    T.ExptNo = string(T.ExptNo);
end
end

%% ------------------------------------------------------------------------
function S = summarizeCandidate(candidateName, T)
if isempty(T)
    S = table(string(candidateName), 0, "", "", NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
        'VariableNames', {'candidate_set','N','table_counts','source_counts','P_min','P_max','GSI_min','GSI_max', ...
        'LD_min','LD_max','Hsub_min','Hsub_max','x_min','x_max'});
    return;
end
S = table();
S.candidate_set = string(candidateName);
S.N = height(T);
S.table_counts = compactCounts(T.TableNo);
S.source_counts = compactCounts(T.source);
S.flag_counts = compactCounts(T.flag_norm);
S.P_min = min(T.Pressure_psia, [], 'omitnan');
S.P_max = max(T.Pressure_psia, [], 'omitnan');
S.GSI_min = min(T.G_SI_kg_m2s, [], 'omitnan');
S.GSI_max = max(T.G_SI_kg_m2s, [], 'omitnan');
S.LD_min = min(T.L_over_D, [], 'omitnan');
S.LD_max = max(T.L_over_D, [], 'omitnan');
S.Hsub_min = min(T.Hsub_kJ_kg, [], 'omitnan');
S.Hsub_max = max(T.Hsub_kJ_kg, [], 'omitnan');
S.x_min = min(T.x_report, [], 'omitnan');
S.x_max = max(T.x_report, [], 'omitnan');
S.D_min_mm = min(T.D_mm, [], 'omitnan');
S.D_max_mm = max(T.D_mm, [], 'omitnan');
end

%% ------------------------------------------------------------------------
function s = compactCounts(x)
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
function S = groupSummary(T, groupVars)
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
function Ck = makeExpectedChecks(C)
checkName = strings(0,1); expected = zeros(0,1); actual = zeros(0,1); status = strings(0,1);
add('raw_all_9_12', 772, height(C.raw_all_9_12));
add('all_lowX_9_12', 397, height(C.all_lowX_9_12));
add('source01_lowX_9_12', 280, height(C.source01_lowX_9_12));
add('source01_lowX_P_ge_2000', 250, height(C.source01_lowX_Pge2000));
add('table10_source09_lowX', 117, height(C.table10_source09_lowX));
add('T9_source01_lowX', 30, height(C.T9_source01_lowX));
add('T10_source01_lowX', 190, height(C.T10_source01_lowX));
add('T11_source01_lowX', 30, height(C.T11_source01_lowX));
add('T12_source01_lowX', 30, height(C.T12_source01_lowX));
Ck = table(checkName, expected, actual, status);

    function add(name, expVal, actVal)
        checkName(end+1,1) = string(name);
        expected(end+1,1) = expVal;
        actual(end+1,1) = actVal;
        if expVal == actVal
            status(end+1,1) = "OK";
        else
            status(end+1,1) = "CHECK";
        end
    end
end

%% ------------------------------------------------------------------------
function writeReport(outMd, rootDir, tm00aXlsx, outXlsx, candidate_summary, expected_checks, source01_by_table, all_lowX_by_table_source)
fid = fopen(outMd, 'w');
assert(fid > 0, 'Cannot open report file: %s', outMd);
c = onCleanup(@() fclose(fid));

fprintf(fid, '# TM00b Tables9-12 Candidate Sets\n\n');
fprintf(fid, '作成日: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

fprintf(fid, '## 1. 目的\n\n');
fprintf(fid, ['TM00aで作成したTable9〜12共通lowX棚卸し結果から、今後参照する候補集合を明示的に切り出す。\n\n' ...
    'このrunでは採用点を決めない。PM計算、F1再fit、L/D補正式作成は行わない。\n\n']);

fprintf(fid, '## 2. 入力・出力\n\n');
fprintf(fid, '- rootDir: `%s`\n', rootDir);
fprintf(fid, '- input TM00a xlsx: `%s`\n', getFileName(tm00aXlsx));
fprintf(fid, '- output Excel: `%s`\n\n', getFileName(outXlsx));

fprintf(fid, '## 3. Expected checks\n\n');
writeMarkdownTable(fid, expected_checks);

fprintf(fid, '\n## 4. Candidate set summary\n\n');
writeMarkdownTable(fid, candidate_summary);

fprintf(fid, '\n## 5. source01 lowX by table\n\n');
writeMarkdownTable(fid, source01_by_table);

fprintf(fid, '\n## 6. all lowX by table/source\n\n');
writeMarkdownTable(fid, all_lowX_by_table_source);

fprintf(fid, '\n## 7. 読み方\n\n');
fprintf(fid, ['- `source01_lowX_9_12` は主解析候補である。\n' ...
    '- `all_lowX_9_12` は全source棚卸し候補であり、Table10 source09/Weatherhead相当を含む。\n' ...
    '- `source01_lowX_P_ge_2000` はTable10〜12相当のPWR近傍寄り候補である。\n' ...
    '- `table10_source09_lowX` はWeatherhead/ANLとの行単位照合候補であり、独立追加データとしてはまだ採用しない。\n' ...
    '- Table9 source01 lowX 30点は、過去のTable9 30点扱いと対応する候補である。\n']);

fprintf(fid, '\n## 8. 採用・保留\n\n');
fprintf(fid, '### 採用\n\n');
fprintf(fid, ['- TM00bは候補集合の命名・固定runとして扱う。\n' ...
    '- 主解析候補は `source01_lowX_9_12` とする。\n' ...
    '- 全source棚卸し候補は `all_lowX_9_12` とする。\n' ...
    '- Weatherhead照合候補は `table10_source09_lowX` として別枠保持する。\n']);
fprintf(fid, '\n### 保留\n\n');
fprintf(fid, ['- どの候補集合でF1再fitやPM診断に進むか。\n' ...
    '- source09/Weatherheadの重複照合結果。\n' ...
    '- legacy Table10 86点との対応確認。\n' ...
    '- Table8/13/14の正本化とTM00本体への取り込み。\n']);
end

%% ------------------------------------------------------------------------
function writeMarkdownTable(fid, T)
if isempty(T)
    fprintf(fid, '_empty table_\n');
    return;
end
vars = string(T.Properties.VariableNames);
fprintf(fid, '| %s |\n', strjoin(vars, ' | '));
fprintf(fid, '| %s |\n', strjoin(repmat("---", 1, numel(vars)), ' | '));
for i = 1:height(T)
    vals = strings(1,numel(vars));
    for j = 1:numel(vars)
        x = T{i,j};
        vals(j) = formatCell(x);
    end
    fprintf(fid, '| %s |\n', strjoin(vals, ' | '));
end
end

%% ------------------------------------------------------------------------
function s = formatCell(x)
if iscell(x); x = x{1}; end
if isstring(x) || ischar(x)
    s = string(x);
elseif islogical(x)
    s = string(x);
elseif isnumeric(x)
    if isscalar(x)
        if isnan(x)
            s = "";
        elseif abs(x - round(x)) < 1e-12 && abs(x) < 1e9
            s = sprintf('%d', round(x));
        else
            s = sprintf('%.6g', x);
        end
    else
        s = mat2str(x);
    end
else
    s = string(x);
end
s = replace(s, '|', '\|');
end

%% ------------------------------------------------------------------------
function name = getFileName(p)
[~, n, e] = fileparts(char(p));
name = [n e];
end
