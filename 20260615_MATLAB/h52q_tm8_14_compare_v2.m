%% h52q_tm8_14_compare_v2.m
% H52Q / T&M Table 8-14
% v1出力の F1_compare_all を読み、F1ありなしのPM統計・差分・図を作る。
%
% 入力:
%   out_TM8_14/TM8_14_diag_output_*.xlsx
%
% 出力:
%   out_TM8_14/TM8_14_compare_v2_yyyymmdd_HHMMSS.xlsx
%   out_TM8_14/*.png

clear; clc; close all;

%% ===== 入力ファイル選択 =====
outDir = fullfile(pwd, "out_TM8_14");

files = dir(fullfile(outDir, "TM8_14_diag_output_*.xlsx"));
if isempty(files)
    error("out_TM8_14 に TM8_14_diag_output_*.xlsx が見つかりません。");
end

[~, idx] = max([files.datenum]);
inFile = fullfile(files(idx).folder, files(idx).name);

timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outFile = fullfile(outDir, "TM8_14_compare_v2_" + timestamp + ".xlsx");

fprintf("Input : %s\n", inFile);
fprintf("Output: %s\n\n", outFile);

%% ===== 読み込み =====
T = readtable(inFile, "Sheet", "F1_compare_all", "VariableNamingRule", "preserve");

% 念のため string 化
T.LD_band = string(T.LD_band);

%% ===== 基本列 =====
TableNo = T.TableNo;
LD      = T.LD_geom;
LD_band = string(T.LD_band);

PM0 = T.PM_noF1;
PM1 = T.PM_F1;
dPM = T.dPM_F1_minus_noF1;
dPMpct = T.dPM_percent;

qP0 = T.qP_noF1;
qP1 = T.qP_F1;

%% ===== 統計表 =====
overall = makeStatsTable("all", "all", PM0, PM1, dPM, dPMpct, qP0, qP1);

tableList = [8; 9; 11; 12; 13; 14];
byTable = table();
for i = 1:numel(tableList)
    m = TableNo == tableList(i);
    byTable = [byTable; makeStatsTable("Table", string(tableList(i)), PM0(m), PM1(m), dPM(m), dPMpct(m), qP0(m), qP1(m))]; %#ok<AGROW>
end

bandList = ["short_anchor"; "middle"; "long"];
byLD = table();
for i = 1:numel(bandList)
    m = LD_band == bandList(i);
    byLD = [byLD; makeStatsTable("LD_band", bandList(i), PM0(m), PM1(m), dPM(m), dPMpct(m), qP0(m), qP1(m))]; %#ok<AGROW>
end

byTableLD = table();
for i = 1:numel(tableList)
    for j = 1:numel(bandList)
        m = TableNo == tableList(i) & LD_band == bandList(j);
        if any(m)
            byTableLD = [byTableLD; makeStatsTable("Table_LD", "T" + string(tableList(i)) + "_" + bandList(j), PM0(m), PM1(m), dPM(m), dPMpct(m), qP0(m), qP1(m))]; %#ok<AGROW>
        end
    end
end

%% ===== 注目抽出 =====
% F1でPMが大きく増えた順・減った順
topIncrease = sortrows(T, "dPM_percent", "descend");
topDecrease = sortrows(T, "dPM_percent", "ascend");

topIncrease = topIncrease(1:min(20,height(topIncrease)), :);
topDecrease = topDecrease(1:min(20,height(topDecrease)), :);

% Table 8 middleのみ
T8_middle = T(TableNo == 8 & LD_band == "middle", :);

% PMが極端なもの
outliers = T(PM1 > 2.0 | PM1 < 0.5 | PM0 > 2.0 | PM0 < 0.5, :);

%% ===== Excel出力 =====
writetable(overall, outFile, "Sheet", "overall");
writetable(byTable, outFile, "Sheet", "by_table");
writetable(byLD, outFile, "Sheet", "by_LD");
writetable(byTableLD, outFile, "Sheet", "by_table_LD");
writetable(topIncrease, outFile, "Sheet", "top_dPM_increase");
writetable(topDecrease, outFile, "Sheet", "top_dPM_decrease");
writetable(T8_middle, outFile, "Sheet", "Table8_middle");
writetable(outliers, outFile, "Sheet", "PM_outliers");
writetable(T, outFile, "Sheet", "F1_compare_all");

%% ===== 図出力 =====

% 1. noF1 vs F1 PM
fig1 = figure;
scatter(PM0, PM1, 36, "filled");
grid on; box on;
xlabel("PM ratio noF1");
ylabel("PM ratio F1");
title("T&M Table 8-14: PM ratio noF1 vs F1");
hold on;
minv = min([PM0; PM1], [], "omitnan");
maxv = max([PM0; PM1], [], "omitnan");
plot([minv maxv], [minv maxv], "k--");
exportgraphics(fig1, fullfile(outDir, "TM8_14_v2_PM_noF1_vs_F1.png"), "Resolution", 200);

% 2. PM vs L/D
fig2 = figure;
scatter(LD, PM0, 36, "filled");
hold on;
scatter(LD, PM1, 36, "filled");
grid on; box on;
xlabel("L/D");
ylabel("PM ratio");
title("T&M Table 8-14: PM ratio vs L/D");
legend("noF1", "F1", "Location", "best");
exportgraphics(fig2, fullfile(outDir, "TM8_14_v2_PM_vs_LD.png"), "Resolution", 200);

% 3. dPM% vs L/D
fig3 = figure;
scatter(LD, dPMpct, 36, "filled");
grid on; box on;
xlabel("L/D");
ylabel("dPM percent = 100*(F1-noF1)/noF1 [%]");
title("T&M Table 8-14: F1 effect vs L/D");
yline(0, "k--");
exportgraphics(fig3, fullfile(outDir, "TM8_14_v2_dPMpct_vs_LD.png"), "Resolution", 200);

% 4. Table別 PM平均
fig4 = figure;
bar(categorical("T" + string(byTable.GroupValue)), [byTable.Mean_PM_noF1, byTable.Mean_PM_F1]);
grid on; box on;
xlabel("Table");
ylabel("Mean PM ratio");
title("Mean PM ratio by Table");
legend("noF1", "F1", "Location", "best");
exportgraphics(fig4, fullfile(outDir, "TM8_14_v2_meanPM_byTable.png"), "Resolution", 200);

% 5. L/D分類別 PM平均
fig5 = figure;
bar(categorical(byLD.GroupValue), [byLD.Mean_PM_noF1, byLD.Mean_PM_F1]);
grid on; box on;
xlabel("L/D band");
ylabel("Mean PM ratio");
title("Mean PM ratio by L/D band");
legend("noF1", "F1", "Location", "best");
exportgraphics(fig5, fullfile(outDir, "TM8_14_v2_meanPM_byLD.png"), "Resolution", 200);

%% ===== 表示 =====
disp("=== overall ===");
disp(overall);

disp("=== by table ===");
disp(byTable);

disp("=== by LD ===");
disp(byLD);

fprintf("\nDone.\n");
fprintf("Excel output:\n  %s\n", outFile);
fprintf("PNG outputs are in:\n  %s\n", outDir);

%% ===== ローカル関数 =====
function S = makeStatsTable(groupType, groupValue, PM0, PM1, dPM, dPMpct, qP0, qP1)
    S = table( ...
        string(groupType), string(groupValue), numel(PM0), ...
        mean(PM0, "omitnan"), median(PM0, "omitnan"), std(PM0, "omitnan"), ...
        mean(PM1, "omitnan"), median(PM1, "omitnan"), std(PM1, "omitnan"), ...
        mean(dPM, "omitnan"), median(dPM, "omitnan"), ...
        mean(dPMpct, "omitnan"), median(dPMpct, "omitnan"), ...
        mean(qP0, "omitnan"), mean(qP1, "omitnan"), mean(qP1 ./ qP0, "omitnan"), ...
        'VariableNames', ["GroupType", "GroupValue", "N", ...
                          "Mean_PM_noF1", "Median_PM_noF1", "Std_PM_noF1", ...
                          "Mean_PM_F1", "Median_PM_F1", "Std_PM_F1", ...
                          "Mean_dPM", "Median_dPM", ...
                          "Mean_dPM_percent", "Median_dPM_percent", ...
                          "Mean_qP_noF1", "Mean_qP_F1", "Mean_qP_ratio"] ...
    );
end