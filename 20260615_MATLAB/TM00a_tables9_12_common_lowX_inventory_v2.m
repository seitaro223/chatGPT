function TM00a_tables9_12_common_lowX_inventory_v2(rootDir)
% TM00a_tables9_12_common_lowX_inventory_v2
%
% Purpose:
%   Inventory Thompson & Macbeth Tables 9-12 from canonical Markdown inputs.
%   This is NOT an adoption/filtering run and does NOT fit F1, PM, or L/D corrections.
%
% Inputs expected in rootDir:
%   - thompson_macbeth_tables_9_11_12_confirmed_final.md
%   - thompson_macbeth_table10_2000psia_r1.md
%
% Main entry condition:
%   lowX = x_report <= 0.05
%
% Important policy:
%   Do NOT initially cut by source, G, L/D, flag, or Table.
%   Keep these as stratification axes only.
%
% Outputs:
%   - TM00a_tables9_12_common_lowX_inventory_YYYYMMDD_HHMMSS.xlsx
%   - run_report_TM00a_tables9_12_common_lowX_inventory_YYYYMMDD_HHMMSS.md
%   - fig_TM00a_*.png

if nargin < 1 || strlength(string(rootDir)) == 0
    rootDir = pwd;
end
rootDir = char(rootDir);

ts = datestr(now, 'yyyymmdd_HHMMSS');
outXlsx = fullfile(rootDir, sprintf('TM00a_tables9_12_common_lowX_inventory_%s.xlsx', ts));
outMd   = fullfile(rootDir, sprintf('run_report_TM00a_tables9_12_common_lowX_inventory_%s.md', ts));
figDir  = fullfile(rootDir, sprintf('fig_TM00a_tables9_12_common_lowX_inventory_%s', ts));
if ~exist(figDir, 'dir'); mkdir(figDir); end

file912 = fullfile(rootDir, 'thompson_macbeth_tables_9_11_12_confirmed_final.md');
file10  = fullfile(rootDir, 'thompson_macbeth_table10_2000psia_r1.md');

assert(isfile(file912), 'Missing input file: %s', file912);
assert(isfile(file10),  'Missing input file: %s', file10);

fprintf('Parsing Table9/11/12 confirmed Markdown...\n');
T912 = parseTM912Markdown(file912);

fprintf('Parsing Table10 canonical Markdown...\n');
T10 = parseTM10Markdown(file10);

T = [T912; T10];
T = addDerivedColumns(T);
T = sortrows(T, {'TableNo','source','ExptNo'});
Tlow = T(T.lowX, :);

% Summaries
byTable       = groupSummary(T, {'TableNo'});
bySource      = groupSummary(T, {'source'});
byTableSource = groupSummary(T, {'TableNo','source'});
byFlag        = groupSummary(T, {'flag_norm'});
byTableFlag   = groupSummary(T, {'TableNo','flag_norm'});
byGBin        = groupSummary(T, {'G_SI_bin'});
byLDBin       = groupSummary(T, {'LD_bin'});
byTableGBin   = groupSummary(T, {'TableNo','G_SI_bin'});
byTableLDBin  = groupSummary(T, {'TableNo','LD_bin'});
checkSummary  = expectedChecks(T);

% Write Excel output
fprintf('Writing Excel output: %s\n', outXlsx);
writetable(T, outXlsx, 'Sheet', 'raw_all');
writetable(Tlow, outXlsx, 'Sheet', 'all_lowX');
writetable(byTable, outXlsx, 'Sheet', 'by_table');
writetable(bySource, outXlsx, 'Sheet', 'by_source');
writetable(byTableSource, outXlsx, 'Sheet', 'by_table_source');
writetable(byFlag, outXlsx, 'Sheet', 'by_flag');
writetable(byTableFlag, outXlsx, 'Sheet', 'by_table_flag');
writetable(byGBin, outXlsx, 'Sheet', 'by_G_SI_bin');
writetable(byLDBin, outXlsx, 'Sheet', 'by_LD_bin');
writetable(byTableGBin, outXlsx, 'Sheet', 'by_table_G_bin');
writetable(byTableLDBin, outXlsx, 'Sheet', 'by_table_LD_bin');
writetable(checkSummary, outXlsx, 'Sheet', 'expected_checks');

% Figures
fprintf('Writing figures...\n');
figPaths = strings(0,1);
figPaths(end+1) = makeScatterByGroup(T, 'G_SI_kg_m2s', 'x_report', 'TableLabel', ...
    fullfile(figDir, sprintf('fig_TM00a_01_raw_x_vs_GSI_by_table_%s.png', ts)), ...
    'TM Table9-12 raw: x_{report} vs G_{SI}', 'G_{SI} [kg/m^2/s]', 'x_{report}');
figPaths(end+1) = makeScatterByGroup(Tlow, 'G_SI_kg_m2s', 'L_over_D', 'TableLabel', ...
    fullfile(figDir, sprintf('fig_TM00a_02_lowX_LD_vs_GSI_by_table_%s.png', ts)), ...
    'TM Table9-12 lowX: L/D vs G_{SI}', 'G_{SI} [kg/m^2/s]', 'L/D');
figPaths(end+1) = makeScatterByGroup(Tlow, 'L_over_D', 'Hsub_kJ_kg', 'TableLabel', ...
    fullfile(figDir, sprintf('fig_TM00a_03_lowX_Hsub_vs_LD_by_table_%s.png', ts)), ...
    'TM Table9-12 lowX: Hsub vs L/D', 'L/D', 'Hsub [kJ/kg]');
figPaths(end+1) = makeScatterByGroup(Tlow, 'G_SI_kg_m2s', 'Hsub_kJ_kg', 'source', ...
    fullfile(figDir, sprintf('fig_TM00a_04_lowX_Hsub_vs_GSI_by_source_%s.png', ts)), ...
    'TM Table9-12 lowX: Hsub vs G_{SI}', 'G_{SI} [kg/m^2/s]', 'Hsub [kJ/kg]');

% Markdown report
fprintf('Writing Markdown report: %s\n', outMd);
writeReport(outMd, rootDir, file912, file10, outXlsx, figPaths, T, Tlow, ...
    byTable, bySource, byTableSource, byFlag, byGBin, byLDBin, checkSummary);

fprintf('\nDone.\n');
fprintf('Excel : %s\n', outXlsx);
fprintf('Report: %s\n', outMd);
fprintf('Figures: %s\n', figDir);

end

%% ------------------------------------------------------------------------
function T = parseTM912Markdown(mdFile)
text = fileread(mdFile);
lines = splitlines(string(text));
rows = {};
for i = 1:numel(lines)
    s = strtrim(lines(i));
    if ~startsWith(s, '|'); continue; end
    if contains(s, '---'); continue; end
    parts = splitMdRowKeepEmpty(s);
    if numel(parts) < 10; continue; end
    if ~isNumericToken(parts(1)); continue; end
    tabNo = str2double(parts(1));
    if ~ismember(tabNo, [9 11 12]); continue; end
    rows(end+1,:) = cellstr(parts(1:10)); %#ok<AGROW>
end

if isempty(rows)
    error('No Table9/11/12 rows were parsed from %s', mdFile);
end

n = size(rows,1);
TableNo = zeros(n,1);
ExptNo = strings(n,1);
flag_norm = strings(n,1);
Pressure_psia = zeros(n,1);
D_in = zeros(n,1);
L_in = zeros(n,1);
G_1e6_lb_hr_ft2 = zeros(n,1);
Hsub_BTU_lb = zeros(n,1);
qCHF_1e6_BTU_hr_ft2 = zeros(n,1);
x_report = zeros(n,1);

for r = 1:n
    TableNo(r) = str2double(rows{r,1});
    ExptNo(r) = string(rows{r,2});
    flag_norm(r) = normalizeFlag(rows{r,3});
    Pressure_psia(r) = str2double(rows{r,4});
    D_in(r) = str2double(rows{r,5});
    L_in(r) = str2double(rows{r,6});
    G_1e6_lb_hr_ft2(r) = str2double(rows{r,7});
    Hsub_BTU_lb(r) = str2double(rows{r,8});
    qCHF_1e6_BTU_hr_ft2(r) = str2double(rows{r,9});
    x_report(r) = str2double(rows{r,10});
end

source = sourceFromExptNo(ExptNo);
provenance = repmat("confirmed_final_md_T9_11_12", n, 1);
input_file = repmat(string(getFileName(mdFile)), n, 1);

T = table(TableNo, ExptNo, source, flag_norm, Pressure_psia, D_in, L_in, ...
    G_1e6_lb_hr_ft2, Hsub_BTU_lb, qCHF_1e6_BTU_hr_ft2, x_report, provenance, input_file);
end

%% ------------------------------------------------------------------------
function T = parseTM10Markdown(mdFile)
text = fileread(mdFile);
lines = splitlines(string(text));
rows = {};
for i = 1:numel(lines)
    s = strtrim(lines(i));
    if ~startsWith(s, '|'); continue; end
    if contains(s, '---'); continue; end
    parts = splitMdRowKeepEmpty(s);
    if numel(parts) < 7; continue; end
    if ~isNumericToken(parts(1)); continue; end
    % Table10 canonical columns:
    % EXPT NO | DIA | LENGTH | G | Inlet Subcool | Burnout HF | Exit Quality | flag
    if numel(parts) < 8
        parts(8) = "";
    end
    rows(end+1,:) = cellstr(parts(1:8)); %#ok<AGROW>
end

if isempty(rows)
    error('No Table10 rows were parsed from %s', mdFile);
end

n = size(rows,1);
TableNo = repmat(10, n, 1);
ExptNo = strings(n,1);
flag_norm = strings(n,1);
Pressure_psia = repmat(2000, n, 1);
D_in = zeros(n,1);
L_in = zeros(n,1);
G_1e6_lb_hr_ft2 = zeros(n,1);
Hsub_BTU_lb = zeros(n,1);
qCHF_1e6_BTU_hr_ft2 = zeros(n,1);
x_report = zeros(n,1);

for r = 1:n
    ExptNo(r) = string(rows{r,1});
    D_in(r) = str2double(rows{r,2});
    L_in(r) = str2double(rows{r,3});
    G_1e6_lb_hr_ft2(r) = str2double(rows{r,4});
    Hsub_BTU_lb(r) = str2double(rows{r,5});
    qCHF_1e6_BTU_hr_ft2(r) = str2double(rows{r,6});
    x_report(r) = str2double(rows{r,7});
    flag_norm(r) = normalizeFlag(rows{r,8});
end

source = sourceFromExptNo(ExptNo);
provenance = repmat("canonical_md_T10_r1", n, 1);
input_file = repmat(string(getFileName(mdFile)), n, 1);

T = table(TableNo, ExptNo, source, flag_norm, Pressure_psia, D_in, L_in, ...
    G_1e6_lb_hr_ft2, Hsub_BTU_lb, qCHF_1e6_BTU_hr_ft2, x_report, provenance, input_file);
end

%% ------------------------------------------------------------------------
function T = addDerivedColumns(T)
T.TableLabel = "Table" + string(T.TableNo);
T.Pressure_MPa = T.Pressure_psia * 0.006894757293168;
T.D_mm = T.D_in * 25.4;
T.L_mm = T.L_in * 25.4;
T.L_over_D = T.L_in ./ T.D_in;
T.G_SI_kg_m2s = T.G_1e6_lb_hr_ft2 * 1356.23;
T.Hsub_kJ_kg = T.Hsub_BTU_lb * 2.326;
T.qCHF_MW_m2 = T.qCHF_1e6_BTU_hr_ft2 * 3.15459;
T.lowX = T.x_report <= 0.05;
T.flag_is_none = T.flag_norm == "none";
T.source_code = extractAfter(T.source, "source");

% bins. Keep text labels spreadsheet-friendly.
T.G_SI_bin = strings(height(T),1);
for i = 1:height(T)
    g = T.G_SI_kg_m2s(i);
    if g < 1000
        T.G_SI_bin(i) = "G_lt_1000";
    elseif g < 2000
        T.G_SI_bin(i) = "G_1000_2000";
    elseif g < 4000
        T.G_SI_bin(i) = "G_2000_4000";
    elseif g < 6000
        T.G_SI_bin(i) = "G_4000_6000";
    else
        T.G_SI_bin(i) = "G_ge_6000";
    end
end

T.LD_bin = strings(height(T),1);
for i = 1:height(T)
    ld = T.L_over_D(i);
    if ld < 60
        T.LD_bin(i) = "LD_lt_60";
    elseif ld < 100
        T.LD_bin(i) = "LD_60_100";
    elseif ld < 200
        T.LD_bin(i) = "LD_100_200";
    elseif ld < 300
        T.LD_bin(i) = "LD_200_300";
    else
        T.LD_bin(i) = "LD_ge_300";
    end
end
end

%% ------------------------------------------------------------------------
function S = groupSummary(T, groupVars)
if ischar(groupVars); groupVars = {groupVars}; end
[G, groupVals] = findgroups(T(:, groupVars));
N = splitapply(@numel, T.TableNo, G);
N_lowX = splitapply(@sum, double(T.lowX), G);
frac_lowX = N_lowX ./ N;
N_flag_non_none = splitapply(@sum, double(T.flag_norm ~= "none"), G);
P_min = splitapply(@min, T.Pressure_psia, G);
P_max = splitapply(@max, T.Pressure_psia, G);
GSI_min = splitapply(@min, T.G_SI_kg_m2s, G);
GSI_max = splitapply(@max, T.G_SI_kg_m2s, G);
LD_min = splitapply(@min, T.L_over_D, G);
LD_max = splitapply(@max, T.L_over_D, G);
Hsub_min = splitapply(@min, T.Hsub_kJ_kg, G);
Hsub_max = splitapply(@max, T.Hsub_kJ_kg, G);
x_min = splitapply(@min, T.x_report, G);
x_max = splitapply(@max, T.x_report, G);
D_min_mm = splitapply(@min, T.D_mm, G);
D_max_mm = splitapply(@max, T.D_mm, G);

S = [groupVals, table(N, N_lowX, frac_lowX, N_flag_non_none, ...
    P_min, P_max, GSI_min, GSI_max, LD_min, LD_max, ...
    Hsub_min, Hsub_max, x_min, x_max, D_min_mm, D_max_mm)];
end

%% ------------------------------------------------------------------------
function C = expectedChecks(T)
checkName = [
    "rows_Table9"; "rows_Table10"; "rows_Table11"; "rows_Table12"; "rows_total_raw"; ...
    "lowX_Table9_expected_source01_30"; "lowX_Table10_expected_307"; ...
    "lowX_Table11_expected_30"; "lowX_Table12_expected_30"; "lowX_total_expected_397" ];
expected = [63; 649; 30; 30; 772; 30; 307; 30; 30; 397];
actual = [
    sum(T.TableNo==9); sum(T.TableNo==10); sum(T.TableNo==11); sum(T.TableNo==12); height(T); ...
    sum(T.TableNo==9 & T.lowX); sum(T.TableNo==10 & T.lowX); ...
    sum(T.TableNo==11 & T.lowX); sum(T.TableNo==12 & T.lowX); sum(T.lowX) ];
status = strings(numel(expected),1);
for i = 1:numel(expected)
    if actual(i) == expected(i)
        status(i) = "OK";
    else
        status(i) = "CHECK";
    end
end
C = table(checkName, expected, actual, status);
end

%% ------------------------------------------------------------------------
function writeReport(outMd, rootDir, file912, file10, outXlsx, figPaths, T, Tlow, ...
    byTable, bySource, byTableSource, byFlag, byGBin, byLDBin, checkSummary)
fid = fopen(outMd, 'w', 'n', 'UTF-8');
assert(fid > 0, 'Cannot open output Markdown: %s', outMd);
cleanupObj = onCleanup(@() fclose(fid));

fprintf(fid, '# TM00a Tables9-12 Common lowX Inventory\n\n');
fprintf(fid, '作成日: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
fprintf(fid, '## 1. 目的\n\n');
fprintf(fid, ['T&M Table9/11/12 confirmed Markdown と Table10 canonical Markdown を同じ列定義・同じ単位系で読み込み、', ...
              '`x_report <= 0.05` を入口条件とした棚卸しを行う。\n\n']);
fprintf(fid, ['このrunでは採用点を決めない。F1再fit、L/D補正式、PM計算は行わない。', ...
              'source、G、L/D、flag、Tableでは最初から切らず、層別軸として保持する。\n\n']);

fprintf(fid, '## 2. 入力\n\n');
fprintf(fid, '- rootDir: `%s`\n', rootDir);
fprintf(fid, '- Table9/11/12: `%s`\n', getFileName(file912));
fprintf(fid, '- Table10: `%s`\n', getFileName(file10));
fprintf(fid, '- output Excel: `%s`\n\n', getFileName(outXlsx));

fprintf(fid, '## 3. 抽出条件\n\n');
fprintf(fid, '```text\n');
fprintf(fid, 'lowX = x_report <= 0.05\n');
fprintf(fid, 'No initial cut by source, G, L/D, flag, or Table.\n');
fprintf(fid, 'G_SI [kg/m2/s] = G_T&M * 1356.23\n');
fprintf(fid, 'Hsub [kJ/kg] = InletSubCooling [BTU/lb] * 2.326\n');
fprintf(fid, 'qCHF [MW/m2] = BurnoutHF [10^6 BTU/hr/ft2] * 3.15459\n');
fprintf(fid, '```\n\n');

fprintf(fid, '## 4. QC expected checks\n\n');
writeTableMd(fid, checkSummary, height(checkSummary));

fprintf(fid, '\n## 5. Raw / lowX counts\n\n');
fprintf(fid, '- raw_all rows: %d\n', height(T));
fprintf(fid, '- all_lowX rows: %d\n', height(Tlow));
fprintf(fid, '- lowX fraction: %.4f\n\n', height(Tlow)/height(T));

fprintf(fid, '### 5.1 by_table\n\n');
writeTableMd(fid, byTable, height(byTable));

fprintf(fid, '\n### 5.2 by_source\n\n');
writeTableMd(fid, bySource, height(bySource));

fprintf(fid, '\n### 5.3 by_table_source\n\n');
writeTableMd(fid, byTableSource, height(byTableSource));

fprintf(fid, '\n### 5.4 by_flag\n\n');
writeTableMd(fid, byFlag, height(byFlag));

fprintf(fid, '\n### 5.5 by_G_SI_bin\n\n');
writeTableMd(fid, byGBin, height(byGBin));

fprintf(fid, '\n### 5.6 by_LD_bin\n\n');
writeTableMd(fid, byLDBin, height(byLDBin));

fprintf(fid, '\n## 6. Figures\n\n');
for i = 1:numel(figPaths)
    fprintf(fid, '- `%s`\n', getFileName(figPaths(i)));
end

fprintf(fid, '\n## 7. 読み方\n\n');
fprintf(fid, ['- Table9はrawでは63点。Table9を30点と見ていた過去の扱いは、Table9全体ではなく、', ...
              'lowXに入るsource01系列を主に見ていた可能性がある。\n']);
fprintf(fid, '- Table11/12は各30点で、ほぼsource01系列のlowX候補として扱える。\n');
fprintf(fid, '- Table10はraw 649点で、lowX 307点が再現されるかを確認する。\n');
fprintf(fid, '- このrunでG、L/D、source、flagによる採用/除外判断はしない。\n');

fprintf(fid, '\n## 8. 採用・保留\n\n');
fprintf(fid, '### 採用\n\n');
fprintf(fid, '- Table9/11/12/10を同一列定義へ正規化して棚卸しする。\n');
fprintf(fid, '- `x_report <= 0.05` を入口条件とする。\n');
fprintf(fid, '- source、G、L/D、flag、Tableは層別軸として保持する。\n');

fprintf(fid, '\n### 保留\n\n');
fprintf(fid, '- Table8/13/14をいつ正本化してTM00本体に入れるか。\n');
fprintf(fid, '- source03/source07を今後の主解析に入れるか、raw_all保持だけにするか。\n');
fprintf(fid, '- Weatherhead/source09の行単位重複照合。\n');
end

%% ------------------------------------------------------------------------
function p = makeScatterByGroup(T, xvar, yvar, groupvar, outPng, titleText, xLabelText, yLabelText)
if height(T) == 0
    p = string(outPng);
    return;
end
f = figure('Visible','off');
hold on;
g = string(T.(groupvar));
groups = unique(g, 'stable');
for i = 1:numel(groups)
    idx = g == groups(i);
    scatter(T.(xvar)(idx), T.(yvar)(idx), 32, 'filled', 'DisplayName', char(groups(i)));
end
xlabel(xLabelText, 'Interpreter', 'none');
ylabel(yLabelText, 'Interpreter', 'none');
title(titleText, 'Interpreter', 'none');
grid on;
legend('Location', 'best', 'Interpreter', 'none');
hold off;
saveas(f, outPng);
close(f);
p = string(outPng);
end

%% ------------------------------------------------------------------------
function writeTableMd(fid, T, maxRows)
if nargin < 3; maxRows = min(height(T), 20); end
maxRows = min(maxRows, height(T));
vars = T.Properties.VariableNames;
fprintf(fid, '| %s |\n', strjoin(vars, ' | '));
fprintf(fid, '| %s |\n', strjoin(repmat({'---'}, 1, numel(vars)), ' | '));
for i = 1:maxRows
    vals = strings(1, numel(vars));
    for j = 1:numel(vars)
        v = T.(vars{j})(i);
        vals(j) = toMdScalar(v);
    end
    fprintf(fid, '| %s |\n', strjoin(cellstr(vals), ' | '));
end
if height(T) > maxRows
    fprintf(fid, '\n（表示は先頭%d行。全%d行はExcelを参照。）\n', maxRows, height(T));
end
end

%% ------------------------------------------------------------------------
function s = toMdScalar(v)
if isnumeric(v) || islogical(v)
    if isscalar(v)
        if isnan(v)
            s = "NaN";
        elseif abs(v - round(v)) < 1e-12
            s = string(sprintf('%d', round(v)));
        else
            s = string(sprintf('%.6g', v));
        end
    else
        s = "[array]";
    end
elseif isstring(v)
    s = v;
elseif iscell(v)
    s = string(v{1});
elseif iscategorical(v)
    s = string(v);
else
    s = string(v);
end
s = replace(s, "|", "/");
end

%% ------------------------------------------------------------------------

function parts = splitMdRowKeepEmpty(s)
% Split a Markdown table row while preserving intentionally blank inner cells.
% Example: | 9 | 1.01 |  | 1750 | ... | must keep the blank flag cell.
s = string(s);
parts = split(s, '|');
% Markdown rows with leading/trailing pipes create empty first/last cells.
% Remove only those boundary cells, not blank inner cells.
if numel(parts) >= 1 && strlength(strtrim(parts(1))) == 0
    parts(1) = [];
end
if numel(parts) >= 1 && strlength(strtrim(parts(end))) == 0
    parts(end) = [];
end
parts = strtrim(parts);
end

function ok = isNumericToken(s)
s = strtrim(string(s));
ok = ~isempty(regexp(s, '^[+-]?\d+(\.\d+)?$', 'once'));
end

function f = normalizeFlag(s)
s = strtrim(string(s));
if strlength(s) == 0 || lower(s) == "none"
    f = "none";
else
    f = upper(s);
end
end

function source = sourceFromExptNo(exptNo)
source = strings(numel(exptNo),1);
for i = 1:numel(exptNo)
    tok = regexp(char(exptNo(i)), '\.(\d+)$', 'tokens', 'once');
    if isempty(tok)
        source(i) = "source_unknown";
    else
        n = str2double(tok{1});
        source(i) = "source" + string(sprintf('%02d', n));
    end
end
end

function name = getFileName(p)
[~, n, e] = fileparts(char(p));
name = [n e];
end
