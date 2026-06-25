%% h52q_tm8_14_shortlong_v4.m
% H52Q / T&M Table 8-14
% 同一Table内の short_anchor vs long を比較する。
%
% 入力:
%   out_TM8_14/TM8_14_confounds_v3_*.xlsx
%   Sheet: all_with_qM_est
%
% 出力:
%   out_TM8_14/TM8_14_shortlong_v4_yyyymmdd_HHMMSS.xlsx
%   out_TM8_14/TM8_14_v4_*.png

clear; clc; close all;

%% ===== 入力ファイル選択 =====
outDir = fullfile(pwd, "out_TM8_14");

files = dir(fullfile(outDir, "TM8_14_confounds_v3_*.xlsx"));
if isempty(files)
    error("out_TM8_14 に TM8_14_confounds_v3_*.xlsx が見つかりません。");
end

[~, idx] = max([files.datenum]);
inFile = fullfile(files(idx).folder, files(idx).name);

timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outFile = fullfile(outDir, "TM8_14_shortlong_v4_" + timestamp + ".xlsx");

fprintf("Input : %s\n", inFile);
fprintf("Output: %s\n\n", outFile);

%% ===== 読み込み =====
T = readtable(inFile, "Sheet", "all_with_qM_est", "VariableNamingRule", "preserve");
T.LD_band = string(T.LD_band);

% 対象Table：同一Table内に short と long がある系列
targetTables = [9; 11; 12; 14];
targetBands = ["short_anchor"; "long"];

Tt = T(ismember(T.TableNo, targetTables) & ismember(T.LD_band, targetBands), :);

%% ===== Table×L/D group stats =====
groupStats = table();

for i = 1:numel(targetTables)
    for j = 1:numel(targetBands)
        m = Tt.TableNo == targetTables(i) & Tt.LD_band == targetBands(j);
        if any(m)
            groupStats = [groupStats; makeGroupStats( ...
                "T" + string(targetTables(i)), targetBands(j), Tt(m,:))]; %#ok<AGROW>
        end
    end
end

%% ===== short-long差分 summary =====
pairSummary = table();

for i = 1:numel(targetTables)
    tbl = targetTables(i);

    S = Tt(Tt.TableNo == tbl & Tt.LD_band == "short_anchor", :);
    L = Tt(Tt.TableNo == tbl & Tt.LD_band == "long", :);

    if ~isempty(S) && ~isempty(L)
        pairSummary = [pairSummary; makePairSummary(tbl, S, L)]; %#ok<AGROW>
    end
end

%% ===== 単純モデル比較 =====
% 目的：
% PM差が Tin だけで説明できそうか、L/Dも効いていそうかを見る。
% これは統計的な証明ではなく、診断用のR2比較。
modelCompare = table();

modelCompare = [modelCompare; makeModelRow("PM_noF1", "Tin_only", Tt.Tin, Tt.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "LD_only", Tt.LD_geom, Tt.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "xMes_only", Tt.x_Mes, Tt.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "P_only", Tt.P_MPa, Tt.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "G_only", Tt.G, Tt.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "qM_only", Tt.qM_MW_m2, Tt.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "Tin_LD", [Tt.Tin, Tt.LD_geom], Tt.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "Tin_xMes", [Tt.Tin, Tt.x_Mes], Tt.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "Tin_LD_xMes", [Tt.Tin, Tt.LD_geom, Tt.x_Mes], Tt.PM_noF1)];

modelCompare = [modelCompare; makeModelRow("PM_F1", "Tin_only", Tt.Tin, Tt.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "LD_only", Tt.LD_geom, Tt.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "xMes_only", Tt.x_Mes, Tt.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "P_only", Tt.P_MPa, Tt.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "G_only", Tt.G, Tt.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "qM_only", Tt.qM_MW_m2, Tt.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "Tin_LD", [Tt.Tin, Tt.LD_geom], Tt.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "Tin_xMes", [Tt.Tin, Tt.x_Mes], Tt.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "Tin_LD_xMes", [Tt.Tin, Tt.LD_geom, Tt.x_Mes], Tt.PM_F1)];

%% ===== Tin only残差 =====
% TinだけでPMを説明した場合、long側にまだ正の残差が残るかを見る。
T_resid = Tt;

[T_resid.PM_noF1_pred_TinOnly, T_resid.PM_noF1_resid_TinOnly] = simplePredictResidual(Tt.Tin, Tt.PM_noF1);
[T_resid.PM_F1_pred_TinOnly,   T_resid.PM_F1_resid_TinOnly]   = simplePredictResidual(Tt.Tin, Tt.PM_F1);

residGroupStats = table();

for i = 1:numel(targetTables)
    for j = 1:numel(targetBands)
        m = T_resid.TableNo == targetTables(i) & T_resid.LD_band == targetBands(j);
        if any(m)
            residGroupStats = [residGroupStats; makeResidGroupStats( ...
                "T" + string(targetTables(i)), targetBands(j), T_resid(m,:))]; %#ok<AGROW>
        end
    end
end

residPairSummary = table();

for i = 1:numel(targetTables)
    tbl = targetTables(i);

    S = T_resid(T_resid.TableNo == tbl & T_resid.LD_band == "short_anchor", :);
    L = T_resid(T_resid.TableNo == tbl & T_resid.LD_band == "long", :);

    if ~isempty(S) && ~isempty(L)
        residPairSummary = [residPairSummary; makeResidPairSummary(tbl, S, L)]; %#ok<AGROW>
    end
end

%% ===== Excel出力 =====
writetable(groupStats, outFile, "Sheet", "group_stats");
writetable(pairSummary, outFile, "Sheet", "short_long_summary");
writetable(modelCompare, outFile, "Sheet", "simple_model_compare");
writetable(residGroupStats, outFile, "Sheet", "TinOnly_resid_group");
writetable(residPairSummary, outFile, "Sheet", "TinOnly_resid_pair");
writetable(T_resid, outFile, "Sheet", "target_rows_with_resid");
writetable(Tt, outFile, "Sheet", "target_rows_raw");

%% ===== 図出力 =====

% 図1：Tableごとの short vs long PM_F1
fig1 = figure;
cats = categorical("T" + string(pairSummary.TableNo));
bar(cats, [pairSummary.Mean_PM_F1_short, pairSummary.Mean_PM_F1_long]);
grid on; box on;
xlabel("Table");
ylabel("Mean PM ratio F1");
title("Same Table comparison: PM_F1 short vs long");
legend("short_anchor", "long", "Location", "best");
exportgraphics(fig1, fullfile(outDir, "TM8_14_v4_PM_F1_short_vs_long_byTable.png"), "Resolution", 200);

% 図2：Tableごとの short vs long Tin
fig2 = figure;
bar(cats, [pairSummary.Mean_Tin_short, pairSummary.Mean_Tin_long]);
grid on; box on;
xlabel("Table");
ylabel("Mean Tin [K]");
title("Same Table comparison: Tin short vs long");
legend("short_anchor", "long", "Location", "best");
exportgraphics(fig2, fullfile(outDir, "TM8_14_v4_Tin_short_vs_long_byTable.png"), "Resolution", 200);

% 図3：Tableごとの long-short PM_F1差
fig3 = figure;
bar(cats, pairSummary.Delta_PM_F1_long_minus_short);
grid on; box on;
xlabel("Table");
ylabel("Delta PM_F1 = long - short");
title("Same Table comparison: long-short PM_F1 difference");
yline(0, "k--");
exportgraphics(fig3, fullfile(outDir, "TM8_14_v4_delta_PM_F1_byTable.png"), "Resolution", 200);

% 図4：Tin差とPM差
fig4 = figure;
scatter(pairSummary.Delta_Tin_long_minus_short, pairSummary.Delta_PM_F1_long_minus_short, 60, "filled");
grid on; box on;
xlabel("Delta Tin = long - short [K]");
ylabel("Delta PM_F1 = long - short");
title("Relation between Tin difference and PM_F1 difference");
for i = 1:height(pairSummary)
    text(pairSummary.Delta_Tin_long_minus_short(i), pairSummary.Delta_PM_F1_long_minus_short(i), ...
        " T" + string(pairSummary.TableNo(i)), "VerticalAlignment", "bottom");
end
exportgraphics(fig4, fullfile(outDir, "TM8_14_v4_delta_PM_vs_delta_Tin.png"), "Resolution", 200);

% 図5：Tin vs PM_F1（対象Tableのみ）
fig5 = figure;
hold on;
for i = 1:numel(targetBands)
    m = Tt.LD_band == targetBands(i);
    scatter(Tt.Tin(m), Tt.PM_F1(m), 40, "filled");
end
grid on; box on;
xlabel("Tin [K]");
ylabel("PM ratio F1");
title("Target tables: PM_F1 vs Tin");
legend(targetBands, "Location", "best");
exportgraphics(fig5, fullfile(outDir, "TM8_14_v4_PM_F1_vs_Tin_targetTables.png"), "Resolution", 200);

% 図6：L/D vs PM_F1（対象Tableのみ）
fig6 = figure;
hold on;
for i = 1:numel(targetBands)
    m = Tt.LD_band == targetBands(i);
    scatter(Tt.LD_geom(m), Tt.PM_F1(m), 40, "filled");
end
grid on; box on;
xlabel("L/D");
ylabel("PM ratio F1");
title("Target tables: PM_F1 vs L/D");
legend(targetBands, "Location", "best");
exportgraphics(fig6, fullfile(outDir, "TM8_14_v4_PM_F1_vs_LD_targetTables.png"), "Resolution", 200);

%% ===== 表示 =====
disp("=== short-long summary ===");
disp(pairSummary);

disp("=== simple model compare ===");
disp(modelCompare);

disp("=== Tin-only residual pair summary ===");
disp(residPairSummary);

fprintf("\nDone.\n");
fprintf("Excel output:\n  %s\n", outFile);
fprintf("PNG outputs are in:\n  %s\n", outDir);

%% ===== ローカル関数 =====

function S = makeGroupStats(tableLabel, bandLabel, X)
    S = table( ...
        string(tableLabel), string(bandLabel), height(X), ...
        mean(X.PM_noF1, "omitnan"), median(X.PM_noF1, "omitnan"), std(X.PM_noF1, "omitnan"), ...
        mean(X.PM_F1, "omitnan"), median(X.PM_F1, "omitnan"), std(X.PM_F1, "omitnan"), ...
        mean(X.LD_geom, "omitnan"), min(X.LD_geom, [], "omitnan"), max(X.LD_geom, [], "omitnan"), ...
        mean(X.Tin, "omitnan"), min(X.Tin, [], "omitnan"), max(X.Tin, [], "omitnan"), ...
        mean(X.x_Mes, "omitnan"), min(X.x_Mes, [], "omitnan"), max(X.x_Mes, [], "omitnan"), ...
        mean(X.qM_MW_m2, "omitnan"), min(X.qM_MW_m2, [], "omitnan"), max(X.qM_MW_m2, [], "omitnan"), ...
        mean(X.G, "omitnan"), min(X.G, [], "omitnan"), max(X.G, [], "omitnan"), ...
        mean(X.P_MPa, "omitnan"), min(X.P_MPa, [], "omitnan"), max(X.P_MPa, [], "omitnan"), ...
        'VariableNames', ["TableLabel", "LD_band", "N", ...
                          "Mean_PM_noF1", "Median_PM_noF1", "Std_PM_noF1", ...
                          "Mean_PM_F1", "Median_PM_F1", "Std_PM_F1", ...
                          "Mean_LD", "Min_LD", "Max_LD", ...
                          "Mean_Tin", "Min_Tin", "Max_Tin", ...
                          "Mean_xMes", "Min_xMes", "Max_xMes", ...
                          "Mean_qM_MW_m2", "Min_qM_MW_m2", "Max_qM_MW_m2", ...
                          "Mean_G", "Min_G", "Max_G", ...
                          "Mean_P_MPa", "Min_P_MPa", "Max_P_MPa"] ...
    );
end

function S = makePairSummary(tbl, Short, Long)
    S = table( ...
        tbl, height(Short), height(Long), ...
        mean(Short.PM_noF1, "omitnan"), mean(Long.PM_noF1, "omitnan"), ...
        mean(Long.PM_noF1, "omitnan") - mean(Short.PM_noF1, "omitnan"), ...
        mean(Short.PM_F1, "omitnan"), mean(Long.PM_F1, "omitnan"), ...
        mean(Long.PM_F1, "omitnan") - mean(Short.PM_F1, "omitnan"), ...
        mean(Long.PM_F1, "omitnan") / mean(Short.PM_F1, "omitnan"), ...
        mean(Short.Tin, "omitnan"), mean(Long.Tin, "omitnan"), ...
        mean(Long.Tin, "omitnan") - mean(Short.Tin, "omitnan"), ...
        mean(Short.x_Mes, "omitnan"), mean(Long.x_Mes, "omitnan"), ...
        mean(Long.x_Mes, "omitnan") - mean(Short.x_Mes, "omitnan"), ...
        mean(Short.qM_MW_m2, "omitnan"), mean(Long.qM_MW_m2, "omitnan"), ...
        mean(Long.qM_MW_m2, "omitnan") - mean(Short.qM_MW_m2, "omitnan"), ...
        mean(Short.G, "omitnan"), mean(Long.G, "omitnan"), ...
        mean(Long.G, "omitnan") - mean(Short.G, "omitnan"), ...
        mean(Short.P_MPa, "omitnan"), mean(Long.P_MPa, "omitnan"), ...
        mean(Long.P_MPa, "omitnan") - mean(Short.P_MPa, "omitnan"), ...
        mean(Short.LD_geom, "omitnan"), mean(Long.LD_geom, "omitnan"), ...
        mean(Long.LD_geom, "omitnan") - mean(Short.LD_geom, "omitnan"), ...
        'VariableNames', ["TableNo", "N_short", "N_long", ...
                          "Mean_PM_noF1_short", "Mean_PM_noF1_long", "Delta_PM_noF1_long_minus_short", ...
                          "Mean_PM_F1_short", "Mean_PM_F1_long", "Delta_PM_F1_long_minus_short", "Ratio_PM_F1_long_over_short", ...
                          "Mean_Tin_short", "Mean_Tin_long", "Delta_Tin_long_minus_short", ...
                          "Mean_xMes_short", "Mean_xMes_long", "Delta_xMes_long_minus_short", ...
                          "Mean_qM_short", "Mean_qM_long", "Delta_qM_long_minus_short", ...
                          "Mean_G_short", "Mean_G_long", "Delta_G_long_minus_short", ...
                          "Mean_P_short", "Mean_P_long", "Delta_P_long_minus_short", ...
                          "Mean_LD_short", "Mean_LD_long", "Delta_LD_long_minus_short"] ...
    );
end

function R = makeModelRow(yName, modelName, Xraw, yraw)
    Xraw = double(Xraw);
    yraw = double(yraw);

    if isvector(Xraw)
        Xraw = Xraw(:);
    end

    good = ~isnan(yraw) & ~isinf(yraw) & all(~isnan(Xraw) & ~isinf(Xraw), 2);

    X = Xraw(good, :);
    y = yraw(good);

    if numel(y) < size(X,2) + 2
        R2 = NaN;
        coefText = "";
        n = numel(y);
    else
        Xdesign = [ones(size(X,1),1), X];
        beta = Xdesign \ y;
        yhat = Xdesign * beta;

        SSE = sum((y - yhat).^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSE/SST;

        coefText = strjoin(string(beta'), ", ");
        n = numel(y);
    end

    R = table(string(yName), string(modelName), n, R2, coefText, ...
        'VariableNames', ["Y", "Model", "N", "R2", "Coefficients"]);
end

function [yhat, resid] = simplePredictResidual(xraw, yraw)
    x = double(xraw(:));
    y = double(yraw(:));

    good = ~isnan(x) & ~isinf(x) & ~isnan(y) & ~isinf(y);

    yhat = nan(size(y));
    resid = nan(size(y));

    Xdesign = [ones(sum(good),1), x(good)];
    beta = Xdesign \ y(good);

    yhat(good) = Xdesign * beta;
    resid(good) = y(good) - yhat(good);
end

function S = makeResidGroupStats(tableLabel, bandLabel, X)
    S = table( ...
        string(tableLabel), string(bandLabel), height(X), ...
        mean(X.PM_noF1_resid_TinOnly, "omitnan"), median(X.PM_noF1_resid_TinOnly, "omitnan"), ...
        mean(X.PM_F1_resid_TinOnly, "omitnan"), median(X.PM_F1_resid_TinOnly, "omitnan"), ...
        'VariableNames', ["TableLabel", "LD_band", "N", ...
                          "Mean_resid_PM_noF1_TinOnly", "Median_resid_PM_noF1_TinOnly", ...
                          "Mean_resid_PM_F1_TinOnly", "Median_resid_PM_F1_TinOnly"] ...
    );
end

function S = makeResidPairSummary(tbl, Short, Long)
    S = table( ...
        tbl, height(Short), height(Long), ...
        mean(Short.PM_noF1_resid_TinOnly, "omitnan"), mean(Long.PM_noF1_resid_TinOnly, "omitnan"), ...
        mean(Long.PM_noF1_resid_TinOnly, "omitnan") - mean(Short.PM_noF1_resid_TinOnly, "omitnan"), ...
        mean(Short.PM_F1_resid_TinOnly, "omitnan"), mean(Long.PM_F1_resid_TinOnly, "omitnan"), ...
        mean(Long.PM_F1_resid_TinOnly, "omitnan") - mean(Short.PM_F1_resid_TinOnly, "omitnan"), ...
        'VariableNames', ["TableNo", "N_short", "N_long", ...
                          "Mean_resid_noF1_short", "Mean_resid_noF1_long", "Delta_resid_noF1_long_minus_short", ...
                          "Mean_resid_F1_short", "Mean_resid_F1_long", "Delta_resid_F1_long_minus_short"] ...
    );
end