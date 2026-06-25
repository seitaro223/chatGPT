%% h52q_tm8_14_confounds_v3.m
% H52Q / T&M Table 8-14
% v2出力の F1_compare_all を読み、
% L/D効果に見える差が Tin, x_Mes, G, P, q_M で説明できるか診断する。
%
% 入力:
%   out_TM8_14/TM8_14_compare_v2_*.xlsx
%
% 出力:
%   out_TM8_14/TM8_14_confounds_v3_yyyymmdd_HHMMSS.xlsx
%   out_TM8_14/TM8_14_v3_*.png

clear; clc; close all;

%% ===== 入力ファイル選択 =====
outDir = fullfile(pwd, "out_TM8_14");

files = dir(fullfile(outDir, "TM8_14_compare_v2_*.xlsx"));
if isempty(files)
    error("out_TM8_14 に TM8_14_compare_v2_*.xlsx が見つかりません。");
end

[~, idx] = max([files.datenum]);
inFile = fullfile(files(idx).folder, files(idx).name);

timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outFile = fullfile(outDir, "TM8_14_confounds_v3_" + timestamp + ".xlsx");

fprintf("Input : %s\n", inFile);
fprintf("Output: %s\n\n", outFile);

%% ===== 読み込み =====
T = readtable(inFile, "Sheet", "F1_compare_all", "VariableNamingRule", "preserve");

T.LD_band = string(T.LD_band);

%% ===== 派生列の作成 =====
% q_M は v2の表には直接ないため、PM_ratio = q_P / q_M とみなして復元する。
% つまり q_M = q_P / PM_ratio。
T.qM_est_noF1 = T.qP_noF1 ./ T.PM_noF1;
T.qM_est_F1   = T.qP_F1   ./ T.PM_F1;
T.qM_est      = mean([T.qM_est_noF1, T.qM_est_F1], 2, "omitnan");
T.qM_MW_m2    = T.qM_est / 1e6;

% 圧力 Pa → MPa
T.P_MPa = T.P_Pa / 1e6;

% 念のため、作成された列名を確認
disp("=== table variables after derived columns ===");
disp(string(T.Properties.VariableNames)');

%% ===== 診断軸 =====
axisNames = ["LD_geom", "x_Mes", "Tin", "G", "P_MPa", "qM_MW_m2"];
axisLabels = ["L/D", "x_{Mes}", "Tin [K]", "G [kg/m^2s]", "P [MPa]", "q_M [MW/m^2]"];

%% ===== 相関診断 =====
corrRows = table();

for i = 1:numel(axisNames)
    x = T.(axisNames(i));

    rowNoF1 = makeCorrRow(axisNames(i), "PM_noF1", x, T.PM_noF1);
    rowF1   = makeCorrRow(axisNames(i), "PM_F1",   x, T.PM_F1);
    rowDPM  = makeCorrRow(axisNames(i), "dPM_percent", x, T.dPM_percent);

    corrRows = [corrRows; rowNoF1; rowF1; rowDPM]; %#ok<AGROW>
end

%% ===== 各軸4分割統計 =====
binStats = table();

for i = 1:numel(axisNames)
    x = T.(axisNames(i));
    axisName = axisNames(i);

    [binID, binLabel] = makeQuantileBins(x, 4);

    for b = 1:4
        m = binID == b;
        if any(m)
            binStats = [binStats; makeGroupStats( ...
                "axis_bin", axisName + "_" + binLabel(b), ...
                T.PM_noF1(m), T.PM_F1(m), T.dPM_percent(m), ...
                T.LD_geom(m), T.x_Mes(m), T.Tin(m), T.G(m), T.P_MPa(m), T.qM_MW_m2(m))]; %#ok<AGROW>
        end
    end
end

%% ===== L/D分類ごとの背景変数分布 =====
ldBands = ["short_anchor"; "middle"; "long"];

ldContext = table();
for i = 1:numel(ldBands)
    m = T.LD_band == ldBands(i);
    ldContext = [ldContext; makeGroupStats( ...
        "LD_band", ldBands(i), ...
        T.PM_noF1(m), T.PM_F1(m), T.dPM_percent(m), ...
        T.LD_geom(m), T.x_Mes(m), T.Tin(m), T.G(m), T.P_MPa(m), T.qM_MW_m2(m))]; %#ok<AGROW>
end

%% ===== Table別背景変数分布 =====
tableList = [8; 9; 11; 12; 13; 14];

tableContext = table();
for i = 1:numel(tableList)
    m = T.TableNo == tableList(i);
    tableContext = [tableContext; makeGroupStats( ...
        "Table", "T" + string(tableList(i)), ...
        T.PM_noF1(m), T.PM_F1(m), T.dPM_percent(m), ...
        T.LD_geom(m), T.x_Mes(m), T.Tin(m), T.G(m), T.P_MPa(m), T.qM_MW_m2(m))]; %#ok<AGROW>
end

%% ===== Table × L/D分類 =====
tableLDContext = table();
for i = 1:numel(tableList)
    for j = 1:numel(ldBands)
        m = T.TableNo == tableList(i) & T.LD_band == ldBands(j);
        if any(m)
            tableLDContext = [tableLDContext; makeGroupStats( ...
                "Table_LD", "T" + string(tableList(i)) + "_" + ldBands(j), ...
                T.PM_noF1(m), T.PM_F1(m), T.dPM_percent(m), ...
                T.LD_geom(m), T.x_Mes(m), T.Tin(m), T.G(m), T.P_MPa(m), T.qM_MW_m2(m))]; %#ok<AGROW>
        end
    end
end

%% ===== Table 8 middle 詳細 =====
T8_middle = T(T.TableNo == 8 & T.LD_band == "middle", :);
T8_middle = sortrows(T8_middle, "x_Mes", "ascend");

%% ===== long高PM要因の確認用 =====
longRows = T(T.LD_band == "long", :);
longRows = sortrows(longRows, "PM_F1", "descend");

shortRows = T(T.LD_band == "short_anchor", :);
shortRows = sortrows(shortRows, "PM_F1", "descend");

%% ===== Excel出力 =====
writetable(corrRows, outFile, "Sheet", "axis_correlations");
writetable(binStats, outFile, "Sheet", "axis_bin_stats");
writetable(ldContext, outFile, "Sheet", "LD_band_context");
writetable(tableContext, outFile, "Sheet", "table_context");
writetable(tableLDContext, outFile, "Sheet", "table_LD_context");
writetable(T8_middle, outFile, "Sheet", "Table8_middle_detail");
writetable(longRows, outFile, "Sheet", "long_rows_sorted");
writetable(shortRows, outFile, "Sheet", "short_rows_sorted");
writetable(T, outFile, "Sheet", "all_with_qM_est");

%% ===== 図出力 =====
for i = 1:numel(axisNames)
    x = T.(axisNames(i));
    label = axisLabels(i);
    safeName = axisNames(i);

    % PM noF1 / F1 vs axis
    fig = figure;
    scatter(x, T.PM_noF1, 36, "filled");
    hold on;
    scatter(x, T.PM_F1, 36, "filled");
    grid on; box on;
    xlabel(label);
    ylabel("PM ratio");
    title("PM ratio vs " + label);
    legend("noF1", "F1", "Location", "best");
    exportgraphics(fig, fullfile(outDir, "TM8_14_v3_PM_vs_" + safeName + ".png"), "Resolution", 200);

    % dPM% vs axis
    fig = figure;
    scatter(x, T.dPM_percent, 36, "filled");
    grid on; box on;
    xlabel(label);
    ylabel("dPM percent = 100*(F1-noF1)/noF1 [%]");
    title("F1 effect vs " + label);
    yline(0, "k--");
    exportgraphics(fig, fullfile(outDir, "TM8_14_v3_dPMpct_vs_" + safeName + ".png"), "Resolution", 200);
end

% Table 8 middleだけ：PM vs x_Mes
if ~isempty(T8_middle)
    fig = figure;
    scatter(T8_middle.x_Mes, T8_middle.PM_noF1, 50, "filled");
    hold on;
    scatter(T8_middle.x_Mes, T8_middle.PM_F1, 50, "filled");
    grid on; box on;
    xlabel("x_{Mes}");
    ylabel("PM ratio");
    title("Table 8 middle: PM ratio vs x_{Mes}");
    legend("noF1", "F1", "Location", "best");
    exportgraphics(fig, fullfile(outDir, "TM8_14_v3_Table8_middle_PM_vs_xMes.png"), "Resolution", 200);
end

%% ===== コマンドウィンドウ表示 =====
disp("=== axis correlations ===");
disp(corrRows);

disp("=== LD band context ===");
disp(ldContext);

disp("=== table context ===");
disp(tableContext);

fprintf("\nDone.\n");
fprintf("Excel output:\n  %s\n", outFile);
fprintf("PNG outputs are in:\n  %s\n", outDir);

%% ===== ローカル関数 =====

function R = makeCorrRow(axisName, yName, x, y)
    good = ~(isnan(x) | isnan(y) | isinf(x) | isinf(y));

    if sum(good) >= 3
        pearson = corr(x(good), y(good), "Type", "Pearson");
        spearman = corr(x(good), y(good), "Type", "Spearman");
    else
        pearson = NaN;
        spearman = NaN;
    end

    R = table(string(axisName), string(yName), sum(good), pearson, spearman, ...
        'VariableNames', ["Axis", "Y", "N", "Pearson_r", "Spearman_r"]);
end

function [binID, binLabel] = makeQuantileBins(x, nbin)
    binID = nan(size(x));
    binLabel = strings(nbin, 1);

    good = ~(isnan(x) | isinf(x));
    xg = x(good);

    if isempty(xg)
        for i = 1:nbin
            binLabel(i) = "Q" + string(i) + "_empty";
        end
        return;
    end

    edges = quantile(xg, linspace(0, 1, nbin+1));
    edges = unique(edges, "stable");

    if numel(edges) < 2
        binID(good) = 1;
        binLabel(1) = "Q1_all_" + string(min(xg)) + "_to_" + string(max(xg));
        for i = 2:nbin
            binLabel(i) = "Q" + string(i) + "_empty";
        end
        return;
    end

    % discretize用に端を少し広げる
    edges(1) = -Inf;
    edges(end) = Inf;

    btmp = discretize(x, edges);
    binID = btmp;

    actualBins = max(btmp, [], "omitnan");
    for i = 1:nbin
        if i <= actualBins
            m = btmp == i;
            if any(m)
                binLabel(i) = "Q" + string(i) + "_" + ...
                    string(round(min(x(m), [], "omitnan"), 4)) + "_to_" + ...
                    string(round(max(x(m), [], "omitnan"), 4));
            else
                binLabel(i) = "Q" + string(i) + "_empty";
            end
        else
            binLabel(i) = "Q" + string(i) + "_empty";
        end
    end
end

function S = makeGroupStats(groupType, groupValue, PM0, PM1, dPMpct, LD, xMes, Tin, G, P_MPa, qM)
    S = table( ...
        string(groupType), string(groupValue), numel(PM0), ...
        mean(PM0, "omitnan"), median(PM0, "omitnan"), std(PM0, "omitnan"), ...
        mean(PM1, "omitnan"), median(PM1, "omitnan"), std(PM1, "omitnan"), ...
        mean(dPMpct, "omitnan"), median(dPMpct, "omitnan"), ...
        mean(LD, "omitnan"), min(LD, [], "omitnan"), max(LD, [], "omitnan"), ...
        mean(xMes, "omitnan"), min(xMes, [], "omitnan"), max(xMes, [], "omitnan"), ...
        mean(Tin, "omitnan"), min(Tin, [], "omitnan"), max(Tin, [], "omitnan"), ...
        mean(G, "omitnan"), min(G, [], "omitnan"), max(G, [], "omitnan"), ...
        mean(P_MPa, "omitnan"), min(P_MPa, [], "omitnan"), max(P_MPa, [], "omitnan"), ...
        mean(qM, "omitnan"), min(qM, [], "omitnan"), max(qM, [], "omitnan"), ...
        'VariableNames', ["GroupType", "GroupValue", "N", ...
                          "Mean_PM_noF1", "Median_PM_noF1", "Std_PM_noF1", ...
                          "Mean_PM_F1", "Median_PM_F1", "Std_PM_F1", ...
                          "Mean_dPM_percent", "Median_dPM_percent", ...
                          "Mean_LD", "Min_LD", "Max_LD", ...
                          "Mean_xMes", "Min_xMes", "Max_xMes", ...
                          "Mean_Tin", "Min_Tin", "Max_Tin", ...
                          "Mean_G", "Min_G", "Max_G", ...
                          "Mean_P_MPa", "Min_P_MPa", "Max_P_MPa", ...
                          "Mean_qM_MW_m2", "Min_qM_MW_m2", "Max_qM_MW_m2"] ...
    );
end