%% h52q_tm8_14_pwrnear_v6.m
% H52Q / T&M Table 8-14
% v5統合結果をもとに、PWR近傍主解析群を Table 10-12 として再整理する。
%
% 圧力帯:
%   explore_low : 10 <= P < 13 MPa
%   PWR_near    : 13 <= P <= 17.5 MPa
%   high_check  : 17.5 < P <= 20 MPa
%
% 目的:
%   Table 10, 11, 12 をPWR近傍主解析群として扱い、
%   short_anchor と long の差が残るかを見る。
%
% 入力:
%   out_TM8_14/TM8_14_integrated_v5_*.xlsx
%   Sheet: integrated_all
%
% 出力:
%   out_TM8_14/TM8_14_pwrnear_v6_yyyymmdd_HHMMSS.xlsx
%   out_TM8_14/TM8_14_v6_*.png

clear; clc; close all;

%% ===== 入力ファイル選択 =====
outDir = fullfile(pwd, "out_TM8_14");

files = dir(fullfile(outDir, "TM8_14_integrated_v5_*.xlsx"));
if isempty(files)
    error("out_TM8_14 に TM8_14_integrated_v5_*.xlsx が見つかりません。");
end

[~, idx] = max([files.datenum]);
inFile = fullfile(files(idx).folder, files(idx).name);

timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outFile = fullfile(outDir, "TM8_14_pwrnear_v6_" + timestamp + ".xlsx");

fprintf("Input : %s\n", inFile);
fprintf("Output: %s\n\n", outFile);

%% ===== 読み込み =====
T = readtable(inFile, "Sheet", "integrated_all", "VariableNamingRule", "preserve");

T.LD_band = string(T.LD_band);
T.P_band_v6 = classifyPressureV6(T.P_MPa);
T.evidence_tier_v6 = classifyEvidenceTier(T.TableNo, T.P_MPa);

%% ===== 基本確認 =====
basic = table( ...
    ["total_rows"; ...
     "explore_low_rows"; ...
     "PWR_near_rows"; ...
     "high_check_rows"; ...
     "PWR_near_Table10_rows"; ...
     "PWR_near_Table11_rows"; ...
     "PWR_near_Table12_rows"; ...
     "high_check_Table14_rows"], ...
    [height(T); ...
     sum(T.P_band_v6 == "explore_low"); ...
     sum(T.P_band_v6 == "PWR_near"); ...
     sum(T.P_band_v6 == "high_check"); ...
     sum(T.P_band_v6 == "PWR_near" & T.TableNo == 10); ...
     sum(T.P_band_v6 == "PWR_near" & T.TableNo == 11); ...
     sum(T.P_band_v6 == "PWR_near" & T.TableNo == 12); ...
     sum(T.P_band_v6 == "high_check" & T.TableNo == 14)], ...
    'VariableNames', ["Item", "Value"]);

%% ===== 全体の再集計 =====
bands = ["explore_low"; "PWR_near"; "high_check"; "outside_pressure"; "missing"];
byPband = table();
for i = 1:numel(bands)
    m = T.P_band_v6 == bands(i);
    if any(m)
        byPband = [byPband; makeStats("P_band_v6", bands(i), T(m,:))]; %#ok<AGROW>
    end
end

tiers = ["explore_low_T8_9"; "PWR_near_T10_12"; "high_check_T13_14"; "other"];
byTier = table();
for i = 1:numel(tiers)
    m = T.evidence_tier_v6 == tiers(i);
    if any(m)
        byTier = [byTier; makeStats("evidence_tier_v6", tiers(i), T(m,:))]; %#ok<AGROW>
    end
end

%% ===== PWR近傍主解析群 =====
PWR = T(T.P_band_v6 == "PWR_near" & ismember(T.TableNo, [10;11;12]), :);
PWR = sortrows(PWR, ["TableNo", "LD_geom", "Tin"]);

pwr_by_table = table();
for tbl = [10 11 12]
    m = PWR.TableNo == tbl;
    if any(m)
        pwr_by_table = [pwr_by_table; makeStats("PWR_Table", "T" + string(tbl), PWR(m,:))]; %#ok<AGROW>
    end
end

ldBands = ["short_anchor"; "middle"; "long"];
pwr_by_LD = table();
for i = 1:numel(ldBands)
    m = PWR.LD_band == ldBands(i);
    if any(m)
        pwr_by_LD = [pwr_by_LD; makeStats("PWR_LD", ldBands(i), PWR(m,:))]; %#ok<AGROW>
    end
end

pwr_by_table_LD = table();
for tbl = [10 11 12]
    for j = 1:numel(ldBands)
        m = PWR.TableNo == tbl & PWR.LD_band == ldBands(j);
        if any(m)
            pwr_by_table_LD = [pwr_by_table_LD; makeStats("PWR_Table_LD", "T" + string(tbl) + "_" + ldBands(j), PWR(m,:))]; %#ok<AGROW>
        end
    end
end

%% ===== short-long比較 =====
% Table 11, 12 は同一Table内で short と long がある。
pwr_pair_summary = table();
for tbl = [11 12]
    S = PWR(PWR.TableNo == tbl & PWR.LD_band == "short_anchor", :);
    L = PWR(PWR.TableNo == tbl & PWR.LD_band == "long", :);

    if ~isempty(S) && ~isempty(L)
        pwr_pair_summary = [pwr_pair_summary; makePairSummary(tbl, S, L)]; %#ok<AGROW>
    end
end

% Table 10 shortを基準短管として、Table11/12 longと比較する。
T10_short = PWR(PWR.TableNo == 10 & PWR.LD_band == "short_anchor", :);
T11_long  = PWR(PWR.TableNo == 11 & PWR.LD_band == "long", :);
T12_long  = PWR(PWR.TableNo == 12 & PWR.LD_band == "long", :);

baseline_contrast = table();
if ~isempty(T10_short)
    baseline_contrast = [baseline_contrast; makeContrast("T10_short_baseline", T10_short, "T11_long", T11_long)]; %#ok<AGROW>
    baseline_contrast = [baseline_contrast; makeContrast("T10_short_baseline", T10_short, "T12_long", T12_long)]; %#ok<AGROW>
end

%% ===== 単純モデル比較 =====
% PWR_near群のみで、Tin / L-D / xMes / P の説明力を見る。
modelCompare = table();

modelCompare = [modelCompare; makeModelRow("PM_noF1", "Tin_only", PWR.Tin, PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "LD_only", PWR.LD_geom, PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "xMes_only", PWR.x_Mes, PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "P_only", PWR.P_MPa, PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "G_only", PWR.G, PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "qM_only", PWR.qM_MW_m2, PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "Tin_LD", [PWR.Tin, PWR.LD_geom], PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "Tin_P", [PWR.Tin, PWR.P_MPa], PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "Tin_LD_xMes_P", [PWR.Tin, PWR.LD_geom, PWR.x_Mes, PWR.P_MPa], PWR.PM_noF1)];

modelCompare = [modelCompare; makeModelRow("PM_F1", "Tin_only", PWR.Tin, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "LD_only", PWR.LD_geom, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "xMes_only", PWR.x_Mes, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "P_only", PWR.P_MPa, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "G_only", PWR.G, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "qM_only", PWR.qM_MW_m2, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "Tin_LD", [PWR.Tin, PWR.LD_geom], PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "Tin_P", [PWR.Tin, PWR.P_MPa], PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "Tin_LD_xMes_P", [PWR.Tin, PWR.LD_geom, PWR.x_Mes, PWR.P_MPa], PWR.PM_F1)];

%% ===== Tin-only残差 =====
PWR_resid = PWR;
[PWR_resid.PM_noF1_pred_TinOnly, PWR_resid.PM_noF1_resid_TinOnly] = simplePredictResidual(PWR.Tin, PWR.PM_noF1);
[PWR_resid.PM_F1_pred_TinOnly,   PWR_resid.PM_F1_resid_TinOnly]   = simplePredictResidual(PWR.Tin, PWR.PM_F1);

TinResid_by_table_LD = table();
for tbl = [10 11 12]
    for j = 1:numel(ldBands)
        m = PWR_resid.TableNo == tbl & PWR_resid.LD_band == ldBands(j);
        if any(m)
            TinResid_by_table_LD = [TinResid_by_table_LD; makeResidStats("T" + string(tbl), ldBands(j), PWR_resid(m,:))]; %#ok<AGROW>
        end
    end
end

TinResid_pair_summary = table();
for tbl = [11 12]
    S = PWR_resid(PWR_resid.TableNo == tbl & PWR_resid.LD_band == "short_anchor", :);
    L = PWR_resid(PWR_resid.TableNo == tbl & PWR_resid.LD_band == "long", :);

    if ~isempty(S) && ~isempty(L)
        TinResid_pair_summary = [TinResid_pair_summary; makeResidPairSummary(tbl, S, L)]; %#ok<AGROW>
    end
end

%% ===== 高圧チェック群 =====
highCheck = T(T.P_band_v6 == "high_check", :);
highCheck_by_table_LD = table();
for tbl = unique(highCheck.TableNo)'
    for j = 1:numel(ldBands)
        m = highCheck.TableNo == tbl & highCheck.LD_band == ldBands(j);
        if any(m)
            highCheck_by_table_LD = [highCheck_by_table_LD; makeStats("high_Table_LD", "T" + string(tbl) + "_" + ldBands(j), highCheck(m,:))]; %#ok<AGROW>
        end
    end
end

%% ===== Excel出力 =====
writetable(basic, outFile, "Sheet", "basic");
writetable(byPband, outFile, "Sheet", "by_P_band_v6");
writetable(byTier, outFile, "Sheet", "by_evidence_tier");
writetable(pwr_by_table, outFile, "Sheet", "PWR_by_table");
writetable(pwr_by_LD, outFile, "Sheet", "PWR_by_LD");
writetable(pwr_by_table_LD, outFile, "Sheet", "PWR_by_table_LD");
writetable(pwr_pair_summary, outFile, "Sheet", "PWR_short_long_pair");
writetable(baseline_contrast, outFile, "Sheet", "T10_baseline_contrast");
writetable(modelCompare, outFile, "Sheet", "PWR_model_compare");
writetable(TinResid_by_table_LD, outFile, "Sheet", "PWR_TinResid_by_table_LD");
writetable(TinResid_pair_summary, outFile, "Sheet", "PWR_TinResid_pair");
writetable(highCheck_by_table_LD, outFile, "Sheet", "high_check_by_table_LD");
writetable(PWR, outFile, "Sheet", "PWR_rows_T10_12");
writetable(PWR_resid, outFile, "Sheet", "PWR_rows_with_TinResid");
writetable(T, outFile, "Sheet", "all_with_v6_band");

%% ===== 図出力 =====

% 1. PWR近傍: Table-LD別PM
fig1 = figure;
bar(categorical(pwr_by_table_LD.GroupValue), pwr_by_table_LD.Mean_PM_F1);
grid on; box on;
xlabel("Table / L-D band");
ylabel("Mean PM ratio F1");
title("PWR-near main group: Mean PM_F1 by Table and L-D band");
xtickangle(45);
exportgraphics(fig1, fullfile(outDir, "TM8_14_v6_PWR_meanPM_byTableLD.png"), "Resolution", 200);

% 2. PWR近傍: Table-LD別Tin
fig2 = figure;
bar(categorical(pwr_by_table_LD.GroupValue), pwr_by_table_LD.Mean_Tin);
grid on; box on;
xlabel("Table / L-D band");
ylabel("Mean Tin [K]");
title("PWR-near main group: Mean Tin by Table and L-D band");
xtickangle(45);
exportgraphics(fig2, fullfile(outDir, "TM8_14_v6_PWR_Tin_byTableLD.png"), "Resolution", 200);

% 3. PWR近傍: PM_F1 vs L/D
fig3 = figure;
scatter(PWR.LD_geom, PWR.PM_F1, 40, "filled");
grid on; box on;
xlabel("L/D");
ylabel("PM ratio F1");
title("PWR-near main group: PM_F1 vs L/D");
exportgraphics(fig3, fullfile(outDir, "TM8_14_v6_PWR_PM_F1_vs_LD.png"), "Resolution", 200);

% 4. PWR近傍: PM_F1 vs Tin
fig4 = figure;
scatter(PWR.Tin, PWR.PM_F1, 40, "filled");
grid on; box on;
xlabel("Tin [K]");
ylabel("PM ratio F1");
title("PWR-near main group: PM_F1 vs Tin");
exportgraphics(fig4, fullfile(outDir, "TM8_14_v6_PWR_PM_F1_vs_Tin.png"), "Resolution", 200);

% 5. 同一Table short-long: Table11/12
if ~isempty(pwr_pair_summary)
    fig5 = figure;
    cats = categorical("T" + string(pwr_pair_summary.TableNo));
    bar(cats, [pwr_pair_summary.Mean_PM_F1_short, pwr_pair_summary.Mean_PM_F1_long]);
    grid on; box on;
    xlabel("Table");
    ylabel("Mean PM ratio F1");
    title("PWR-near: short vs long PM_F1");
    legend("short_anchor", "long", "Location", "best");
    exportgraphics(fig5, fullfile(outDir, "TM8_14_v6_PWR_short_vs_long_PM_F1.png"), "Resolution", 200);
end

%% ===== 表示 =====
disp("=== basic ===");
disp(basic);

disp("=== PWR by table L-D ===");
disp(pwr_by_table_LD);

disp("=== PWR short-long pair ===");
disp(pwr_pair_summary);

disp("=== PWR model compare ===");
disp(modelCompare);

disp("=== PWR Tin residual pair ===");
disp(TinResid_pair_summary);

fprintf("\nDone.\n");
fprintf("Excel output:\n  %s\n", outFile);
fprintf("PNG outputs are in:\n  %s\n", outDir);

%% ===== ローカル関数 =====

function band = classifyPressureV6(P)
    band = strings(size(P));
    band(P >= 10 & P < 13) = "explore_low";
    band(P >= 13 & P <= 17.5) = "PWR_near";
    band(P > 17.5 & P <= 20) = "high_check";
    band((P < 10 | P > 20) & ~isnan(P)) = "outside_pressure";
    band(isnan(P)) = "missing";
end

function tier = classifyEvidenceTier(tableNo, P)
    tier = strings(size(P));
    tier(ismember(tableNo, [8 9])) = "explore_low_T8_9";
    tier(ismember(tableNo, [10 11 12])) = "PWR_near_T10_12";
    tier(ismember(tableNo, [13 14])) = "high_check_T13_14";
    tier(tier == "") = "other";
end

function S = makeStats(groupType, groupValue, X)
    S = table( ...
        string(groupType), string(groupValue), height(X), ...
        mean(X.PM_noF1, "omitnan"), median(X.PM_noF1, "omitnan"), std(X.PM_noF1, "omitnan"), ...
        mean(X.PM_F1, "omitnan"), median(X.PM_F1, "omitnan"), std(X.PM_F1, "omitnan"), ...
        mean(X.dPM_percent, "omitnan"), median(X.dPM_percent, "omitnan"), ...
        mean(X.LD_geom, "omitnan"), min(X.LD_geom, [], "omitnan"), max(X.LD_geom, [], "omitnan"), ...
        mean(X.Tin, "omitnan"), min(X.Tin, [], "omitnan"), max(X.Tin, [], "omitnan"), ...
        mean(X.x_Mes, "omitnan"), min(X.x_Mes, [], "omitnan"), max(X.x_Mes, [], "omitnan"), ...
        mean(X.qM_MW_m2, "omitnan"), min(X.qM_MW_m2, [], "omitnan"), max(X.qM_MW_m2, [], "omitnan"), ...
        mean(X.G, "omitnan"), min(X.G, [], "omitnan"), max(X.G, [], "omitnan"), ...
        mean(X.P_MPa, "omitnan"), min(X.P_MPa, [], "omitnan"), max(X.P_MPa, [], "omitnan"), ...
        'VariableNames', ["GroupType", "GroupValue", "N", ...
                          "Mean_PM_noF1", "Median_PM_noF1", "Std_PM_noF1", ...
                          "Mean_PM_F1", "Median_PM_F1", "Std_PM_F1", ...
                          "Mean_dPM_percent", "Median_dPM_percent", ...
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
        mean(Short.PM_F1, "omitnan"), mean(Long.PM_F1, "omitnan"), ...
        mean(Long.PM_F1, "omitnan") - mean(Short.PM_F1, "omitnan"), ...
        mean(Long.PM_F1, "omitnan") / mean(Short.PM_F1, "omitnan"), ...
        mean(Short.PM_noF1, "omitnan"), mean(Long.PM_noF1, "omitnan"), ...
        mean(Long.PM_noF1, "omitnan") - mean(Short.PM_noF1, "omitnan"), ...
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
                          "Mean_PM_F1_short", "Mean_PM_F1_long", ...
                          "Delta_PM_F1_long_minus_short", "Ratio_PM_F1_long_over_short", ...
                          "Mean_PM_noF1_short", "Mean_PM_noF1_long", "Delta_PM_noF1_long_minus_short", ...
                          "Mean_Tin_short", "Mean_Tin_long", "Delta_Tin_long_minus_short", ...
                          "Mean_xMes_short", "Mean_xMes_long", "Delta_xMes_long_minus_short", ...
                          "Mean_qM_short", "Mean_qM_long", "Delta_qM_long_minus_short", ...
                          "Mean_G_short", "Mean_G_long", "Delta_G_long_minus_short", ...
                          "Mean_P_short", "Mean_P_long", "Delta_P_long_minus_short", ...
                          "Mean_LD_short", "Mean_LD_long", "Delta_LD_long_minus_short"] ...
    );
end

function S = makeContrast(baseName, Base, targetName, Target)
    if isempty(Target)
        S = table(string(baseName), string(targetName), height(Base), 0, ...
            NaN, NaN, NaN, NaN, NaN, NaN, ...
            'VariableNames', ["BaseGroup", "TargetGroup", "N_base", "N_target", ...
                              "Mean_PM_F1_base", "Mean_PM_F1_target", "Delta_PM_F1_target_minus_base", ...
                              "Mean_Tin_base", "Mean_Tin_target", "Delta_Tin_target_minus_base"]);
        return;
    end

    S = table( ...
        string(baseName), string(targetName), height(Base), height(Target), ...
        mean(Base.PM_F1, "omitnan"), mean(Target.PM_F1, "omitnan"), ...
        mean(Target.PM_F1, "omitnan") - mean(Base.PM_F1, "omitnan"), ...
        mean(Base.Tin, "omitnan"), mean(Target.Tin, "omitnan"), ...
        mean(Target.Tin, "omitnan") - mean(Base.Tin, "omitnan"), ...
        'VariableNames', ["BaseGroup", "TargetGroup", "N_base", "N_target", ...
                          "Mean_PM_F1_base", "Mean_PM_F1_target", "Delta_PM_F1_target_minus_base", ...
                          "Mean_Tin_base", "Mean_Tin_target", "Delta_Tin_target_minus_base"] ...
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

function S = makeResidStats(tableLabel, bandLabel, X)
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