%% ST_QA01_single_tube_report_quality_distribution_v1.m
% H52Q-QA: T&M単管データの「報告書転記クオリティ」分布確認
%
% 目的:
%   qMやqPから熱収支で再計算したx_eqではなく、T&M報告書に記載され、
%   Excelへ転記されている実験値側クオリティ（例: x_Mes / xMes）を見る。
%
% 入力候補:
%   1) H52Q_current_single_tube_input_v1_20260615_183839.xlsx
%      sheet: ST_F1_T8_14_current
%   2) 20260612_計算結果比較r8_result_文献追加用.xlsx
%      sheet: tm_r124_F1_T8_14
%
% 出力:
%   ST_QA01_single_tube_report_quality_distribution_v1.xlsx
%   fig_ST_QA01_01_report_quality_by_table_ld.png
%   fig_ST_QA01_02_report_quality_vs_LD.png
%   fig_ST_QA01_03_report_quality_vs_Tsub.png
%   run_report_ST_QA01_single_tube_report_quality_distribution_v1.md
%
% 注意:
%   このスクリプトでは x_eq_qP_F1, xeq_qM, qMベース計算値は使わない。
%   あくまで「報告書から転記した実験値側クオリティ列」を読む。

clear; clc;

%% User settings
outPrefix = 'ST_QA01_single_tube_report_quality_distribution_v1';
targetTables = [9 10 11 12];

inputCandidates = {
    'H52Q_current_single_tube_input_v1_20260615_183839.xlsx', 'ST_F1_T8_14_current';
    '20260612_計算結果比較r8_result_文献追加用.xlsx', 'tm_r124_F1_T8_14';
    'H52Q_current_single_tube_input_v1_20260615_183839.xlsx', 'ST_noF1_T8_14_current';
    '20260612_計算結果比較r8_result_文献追加用.xlsx', 'tm_r123_noF1_T8_14'
};

%% Find input
inputFile = '';
sheetName = '';
for i = 1:size(inputCandidates,1)
    if isfile(inputCandidates{i,1})
        try
            sheets = sheetnames(inputCandidates{i,1});
            if any(strcmp(sheets, inputCandidates{i,2}))
                inputFile = inputCandidates{i,1};
                sheetName = inputCandidates{i,2};
                break;
            end
        catch
            % continue
        end
    end
end

if isempty(inputFile)
    error(['Input file not found. Put one of these files in the current folder:\n' ...
           '  H52Q_current_single_tube_input_v1_20260615_183839.xlsx\n' ...
           '  20260612_計算結果比較r8_result_文献追加用.xlsx\n']);
end

fprintf('Input: %s / %s\n', inputFile, sheetName);
T = readtable(inputFile, 'Sheet', sheetName, 'VariableNamingRule', 'preserve');
origNames = string(T.Properties.VariableNames);
canonNames = matlab.lang.makeValidName(origNames);
T.Properties.VariableNames = cellstr(canonNames);

%% Helper to find column by candidate names or regex
findCol = @(cands) local_find_col(string(T.Properties.VariableNames), origNames, string(cands));

colTable = findCol({'TableNo','Table','Table_No','No_Table','NoTable','table_no'});
colNoTableNo = findCol({'No_TableNo','NoTableNo','No'});
colSource = findCol({'source','Source','source_id','SourceID','SourceNo','sourceNo'});
colLD = findCol({'LD_geom','L_D','LoverD','L_DH','LoverDH','L_DNB_over_DH','LD','L_D'});
colTsub = findCol({'Tsub','T_sub','Tsub_K','DeltaTsub','dTsub'});
colPM = findCol({'PM_F1','PM_ratio','P_M','PM','PoverM','PM_F1_ratio'});
colP = findCol({'P_MPa','P','Pressure_MPa','Pressure'});
colHsub = findCol({'Hsub_true_kJkg','Hsub_kJkg','Hsub','hSub_kJ_kg','Hsub_used'});

% 報告書転記クオリティ候補。
% x_eq_qP_F1, xeq_qM 等は除外する。
qualityCandidates = {'x_Mes','xMes','x_MES','X_Mes','XMes','xmes','x_Mes_result','xMes_result','xMes_result_side','Quality_report','X_report','Xexp','x_exp','xDNB_exp','x_DNB_exp'};
colQ = findCol(qualityCandidates);

if isempty(colQ)
    fprintf('\nAvailable columns:\n');
    disp(T.Properties.VariableNames');
    error(['Report-based quality column was not found. ' ...
           'Please rename the report quality column to x_Mes or add it to qualityCandidates.']);
end

%% TableNo parse
if isempty(colTable)
    if isempty(colNoTableNo)
        error('Could not find TableNo or No_TableNo column.');
    end
    T.TableNo_QA = local_parse_table_no(T.(colNoTableNo));
else
    T.TableNo_QA = T.(colTable);
end
T.TableNo_QA = double(T.TableNo_QA);

%% Extract variables
T.report_quality = double(T.(colQ));
if ~isempty(colLD);   T.LD_QA = double(T.(colLD)); else; T.LD_QA = nan(height(T),1); end
if ~isempty(colTsub); T.Tsub_QA = double(T.(colTsub)); else; T.Tsub_QA = nan(height(T),1); end
if ~isempty(colPM);   T.PM_QA = double(T.(colPM)); else; T.PM_QA = nan(height(T),1); end
if ~isempty(colP);    T.P_MPa_QA = double(T.(colP)); else; T.P_MPa_QA = nan(height(T),1); end
if ~isempty(colHsub); T.Hsub_QA = double(T.(colHsub)); else; T.Hsub_QA = nan(height(T),1); end

if isempty(colSource)
    T.source_QA = repmat("", height(T), 1);
else
    T.source_QA = string(T.(colSource));
end

%% Filter target
isTarget = ismember(T.TableNo_QA, targetTables) & ~isnan(T.report_quality);
D = T(isTarget, :);
if isempty(D)
    error('No target rows found for Table9-12 with report_quality.');
end

%% LD group
D.LD_group_QA = repmat("unknown", height(D), 1);
if all(isnan(D.LD_QA))
    D.LD_group_QA(:) = "unknown";
else
    % T&Mで使ってきた概略分類: 60〜80をsmall/mid側、350級をlong側として扱う。
    D.LD_group_QA(D.LD_QA < 70) = "short_or_middle";
    D.LD_group_QA(D.LD_QA >= 70 & D.LD_QA < 120) = "short";
    D.LD_group_QA(D.LD_QA >= 120 & D.LD_QA < 250) = "middle";
    D.LD_group_QA(D.LD_QA >= 250) = "long";
end

%% Summary by Table / LD group
[G, tbl, ldgrp] = findgroups(D.TableNo_QA, D.LD_group_QA);
summary = table();
summary.TableNo = tbl;
summary.LD_group = ldgrp;
summary.N = splitapply(@numel, D.report_quality, G);
summary.x_report_mean = splitapply(@(x) mean(x,'omitnan'), D.report_quality, G);
summary.x_report_median = splitapply(@(x) median(x,'omitnan'), D.report_quality, G);
summary.x_report_min = splitapply(@(x) min(x,[],'omitnan'), D.report_quality, G);
summary.x_report_max = splitapply(@(x) max(x,[],'omitnan'), D.report_quality, G);
summary.x_report_sd = splitapply(@(x) std(x,'omitnan'), D.report_quality, G);
summary.frac_x_le_0 = splitapply(@(x) mean(x<=0,'omitnan'), D.report_quality, G);
summary.frac_x_le_005 = splitapply(@(x) mean(x<=0.05,'omitnan'), D.report_quality, G);
summary.frac_x_gt_0 = splitapply(@(x) mean(x>0,'omitnan'), D.report_quality, G);
summary.LD_mean = splitapply(@(x) mean(x,'omitnan'), D.LD_QA, G);
summary.Tsub_mean = splitapply(@(x) mean(x,'omitnan'), D.Tsub_QA, G);
summary.P_MPa_mean = splitapply(@(x) mean(x,'omitnan'), D.P_MPa_QA, G);
summary.PM_mean = splitapply(@(x) mean(x,'omitnan'), D.PM_QA, G);
summary = sortrows(summary, {'TableNo','LD_mean'});

%% Summary by table only
[G2, tbl2] = findgroups(D.TableNo_QA);
summaryTable = table();
summaryTable.TableNo = tbl2;
summaryTable.N = splitapply(@numel, D.report_quality, G2);
summaryTable.x_report_mean = splitapply(@(x) mean(x,'omitnan'), D.report_quality, G2);
summaryTable.x_report_median = splitapply(@(x) median(x,'omitnan'), D.report_quality, G2);
summaryTable.x_report_min = splitapply(@(x) min(x,[],'omitnan'), D.report_quality, G2);
summaryTable.x_report_max = splitapply(@(x) max(x,[],'omitnan'), D.report_quality, G2);
summaryTable.frac_x_le_0 = splitapply(@(x) mean(x<=0,'omitnan'), D.report_quality, G2);
summaryTable.frac_x_le_005 = splitapply(@(x) mean(x<=0.05,'omitnan'), D.report_quality, G2);
summaryTable.frac_x_gt_0 = splitapply(@(x) mean(x>0,'omitnan'), D.report_quality, G2);
summaryTable = sortrows(summaryTable, 'TableNo');

%% Output Excel
outXlsx = [outPrefix '.xlsx'];
if isfile(outXlsx); delete(outXlsx); end
writetable(summary, outXlsx, 'Sheet', 'summary_by_table_LD');
writetable(summaryTable, outXlsx, 'Sheet', 'summary_by_table');
writetable(D(:, {'TableNo_QA','LD_group_QA','report_quality','LD_QA','Tsub_QA','P_MPa_QA','Hsub_QA','PM_QA','source_QA'}), outXlsx, 'Sheet', 'case_values');

%% Figures
fig1 = ['fig_' outPrefix '_01_by_table_ld.png'];
fig2 = ['fig_' outPrefix '_02_vs_LD.png'];
fig3 = ['fig_' outPrefix '_03_vs_Tsub.png'];

% figure 1: jitter by table+LD group
f = figure('Color','w','Position',[100 100 1200 700]);
labels = strcat("T", string(D.TableNo_QA), "_", D.LD_group_QA);
[grp, lab] = findgroups(labels);
xpos = grp + 0.12*(rand(size(grp))-0.5);
scatter(xpos, D.report_quality, 55, 'filled'); hold on;
yline(0,'--'); yline(0.05,':');
for k = 1:max(grp)
    y = D.report_quality(grp==k);
    plot([k-0.25 k+0.25], [median(y,'omitnan') median(y,'omitnan')], 'k-', 'LineWidth', 2);
end
xticks(1:numel(lab)); xticklabels(lab); xtickangle(35);
ylabel('Report-based quality x_{report}');
title('T&M report-based quality by Table and L/D group');
grid on; box on;
exportgraphics(f, fig1, 'Resolution', 200);
close(f);

% figure 2: vs LD
f = figure('Color','w','Position',[100 100 1000 700]);
gscatter(D.LD_QA, D.report_quality, D.TableNo_QA, [], [], 8); hold on;
yline(0,'--'); yline(0.05,':');
xlabel('L/D'); ylabel('Report-based quality x_{report}');
title('T&M report-based quality vs L/D');
grid on; box on;
exportgraphics(f, fig2, 'Resolution', 200);
close(f);

% figure 3: vs Tsub
f = figure('Color','w','Position',[100 100 1000 700]);
gscatter(D.Tsub_QA, D.report_quality, D.TableNo_QA, [], [], 8); hold on;
yline(0,'--'); yline(0.05,':');
xlabel('Tsub [K]'); ylabel('Report-based quality x_{report}');
title('T&M report-based quality vs Tsub');
grid on; box on;
exportgraphics(f, fig3, 'Resolution', 200);
close(f);

%% Markdown report
outMd = ['run_report_' outPrefix '.md'];
fid = fopen(outMd, 'w');
fprintf(fid, '# ST-QA01 T&M単管 報告書転記クオリティ分布確認\n\n');
fprintf(fid, '## 目的\n\n');
fprintf(fid, '- qM/qPから再計算したx_eqではなく、T&M報告書から転記した実験値側クオリティを見る。\n');
fprintf(fid, '- Table9〜12について、Table別・L/D群別に、負側〜0近傍が多いか確認する。\n\n');
fprintf(fid, '## 入力\n\n');
fprintf(fid, '- input file: `%s`\n', inputFile);
fprintf(fid, '- sheet: `%s`\n', sheetName);
fprintf(fid, '- report quality column: `%s`\n\n', colQ);
fprintf(fid, '## 重要な注意\n\n');
fprintf(fid, '- このrunでは、`qM`ベースまたは`qP`ベースで計算したx_eqは使っていない。\n');
fprintf(fid, '- 使用しているのは報告書転記クオリティ列である。\n\n');
fprintf(fid, '## Table別・L/D群別summary\n\n');
local_write_md_table(fid, summary);
fprintf(fid, '\n## Table別summary\n\n');
local_write_md_table(fid, summaryTable);
fprintf(fid, '\n## 出力\n\n');
fprintf(fid, '- `%s`\n', outXlsx);
fprintf(fid, '- `%s`\n', fig1);
fprintf(fid, '- `%s`\n', fig2);
fprintf(fid, '- `%s`\n', fig3);
fclose(fid);

fprintf('Done. Outputs:\n  %s\n  %s\n  %s\n  %s\n  %s\n', outXlsx, fig1, fig2, fig3, outMd);

%% Local functions
function col = local_find_col(validNames, origNames, candidates)
    col = '';
    validLower = lower(validNames);
    origLower = lower(origNames);
    for c = candidates
        cValid = lower(string(matlab.lang.makeValidName(c)));
        cOrig = lower(string(c));
        idx = find(validLower == cValid | origLower == cOrig, 1);
        if ~isempty(idx)
            col = char(validNames(idx));
            return;
        end
    end
    % partial matching, but avoid qM/qP calculated quality columns
    for c = candidates
        c2 = lower(string(c));
        idx = find(contains(validLower, c2) | contains(origLower, c2), 1);
        if ~isempty(idx)
            name = validLower(idx);
            bad = contains(name,'qmf') || contains(name,'qm') || contains(name,'qp') || contains(name,'calc') || contains(name,'nfi') || contains(name,'cobra');
            if ~bad
                col = char(validNames(idx));
                return;
            end
        end
    end
end

function tableNo = local_parse_table_no(x)
    if isnumeric(x)
        tableNo = floor(double(x));
        return;
    end
    s = string(x);
    tableNo = nan(size(s));
    for i = 1:numel(s)
        token = regexp(s(i), '^(\d+)', 'tokens', 'once');
        if ~isempty(token)
            tableNo(i) = str2double(token{1});
        end
    end
end

function local_write_md_table(fid, T)
    vars = T.Properties.VariableNames;
    fprintf(fid, '| %s |\n', strjoin(vars, ' | '));
    fprintf(fid, '| %s |\n', strjoin(repmat({'---'}, 1, numel(vars)), ' | '));
    for i = 1:height(T)
        vals = strings(1, numel(vars));
        for j = 1:numel(vars)
            v = T.(vars{j})(i);
            if isnumeric(v)
                vals(j) = string(sprintf('%.6g', v));
            elseif isstring(v) || ischar(v) || iscategorical(v)
                vals(j) = string(v);
            else
                vals(j) = string(v);
            end
        end
        fprintf(fid, '| %s |\n', strjoin(vals, ' | '));
    end
end
