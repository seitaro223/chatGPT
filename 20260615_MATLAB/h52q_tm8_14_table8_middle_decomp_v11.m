%% h52q_tm8_14_table8_middle_decomp_v11.m
% H52Q / T&M Table 8-14
% v11: explore_lowでTable8 middleが低く出る理由を分解する。
%
% 入力:
%   out_TM8_14/TM8_14_explorelow_truehsub_v10_*.xlsx
%   Sheet: target_rows_T8_12
%
% 対象:
%   explore_low Table8/9
%   - Table8 middle
%   - Table9 short
%   - Table9 long
%
% 出力:
%   out_TM8_14/TM8_14_table8_middle_decomp_v11_yyyymmdd_HHMMSS.xlsx
%   out_TM8_14/TM8_14_v11_*.png

clear; clc; close all;

%% ===== 入力ファイル =====
outDir = fullfile(pwd, "out_TM8_14");

files = dir(fullfile(outDir, "TM8_14_explorelow_truehsub_v10_*.xlsx"));
if isempty(files)
    error("out_TM8_14 に TM8_14_explorelow_truehsub_v10_*.xlsx が見つかりません。");
end

[~, idx] = max([files.datenum]);
inFile = fullfile(files(idx).folder, files(idx).name);

timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outFile = fullfile(outDir, "TM8_14_table8_middle_decomp_v11_" + timestamp + ".xlsx");

fprintf("Input : %s\n", inFile);
fprintf("Output: %s\n\n", outFile);

%% ===== 読み込み =====
T = readtable(inFile, "Sheet", "target_rows_T8_12", "VariableNamingRule", "preserve");

T.No_TableNo = string(T.No_TableNo);
T.LD_band = string(T.LD_band);
T.P_scope = string(T.P_scope);

E = T(T.P_scope == "explore_low_T8_9" & ismember(T.TableNo, [8 9]), :);
E.Group3 = makeExploreGroup(E.TableNo, E.LD_band);

% F1影響
E.F1_delta_PM = E.PM_F1 - E.PM_noF1;
E.F1_ratio_PM = E.PM_F1 ./ E.PM_noF1;

% qM単位を見やすくする
E.qM_MW_m2 = E.qM ./ 1e6;

%% ===== basic =====
basic = table( ...
    ["explore_rows"; ...
     "T8_rows"; ...
     "T9_rows"; ...
     "T8_middle_rows"; ...
     "T9_short_rows"; ...
     "T9_long_rows"; ...
     "missing_PM_F1"; ...
     "missing_Hsub_true"; ...
     "missing_xMes"; ...
     "missing_qM"], ...
    [height(E); ...
     sum(E.TableNo == 8); ...
     sum(E.TableNo == 9); ...
     sum(E.Group3 == "T8_middle"); ...
     sum(E.Group3 == "T9_short"); ...
     sum(E.Group3 == "T9_long"); ...
     sum(isnan(E.PM_F1)); ...
     sum(isnan(E.Hsub_true_kJkg)); ...
     sum(isnan(E.x_Mes)); ...
     sum(isnan(E.qM))], ...
    'VariableNames', ["Item", "Value"]);

%% ===== グループ統計 =====
groups = ["T9_short"; "T8_middle"; "T9_long"; "T8_all"; "T9_all"];
groupSummary = table();

for i = 1:numel(groups)
    g = groups(i);

    if g == "T8_all"
        X = E(E.TableNo == 8, :);
    elseif g == "T9_all"
        X = E(E.TableNo == 9, :);
    else
        X = E(E.Group3 == g, :);
    end

    if ~isempty(X)
        groupSummary = [groupSummary; makeGroupSummary(g, X)]; %#ok<AGROW>
    end
end

%% ===== 差分比較 =====
contrast = table();
contrast = [contrast; makeContrast("T8_middle", E(E.Group3=="T8_middle",:), "T9_short", E(E.Group3=="T9_short",:))]; %#ok<AGROW>
contrast = [contrast; makeContrast("T8_middle", E(E.Group3=="T8_middle",:), "T9_long", E(E.Group3=="T9_long",:))]; %#ok<AGROW>
contrast = [contrast; makeContrast("T8_middle", E(E.Group3=="T8_middle",:), "T9_all", E(E.TableNo==9,:))]; %#ok<AGROW>
contrast = [contrast; makeContrast("T9_long", E(E.Group3=="T9_long",:), "T9_short", E(E.Group3=="T9_short",:))]; %#ok<AGROW>

%% ===== モデル比較：explore_low内 =====
% Table8 middle低下を説明できるかを見る。
% Table8 dummyを入れてR2や残差がどれだけ改善するかを見る。
isT8 = double(E.TableNo == 8);
isLong = double(E.LD_band == "long");
isMiddle = double(E.LD_band == "middle");

modelDefs = struct([]);

modelDefs(end+1).name = "Hsub_only";
modelDefs(end).X = E.Hsub_true_kJkg;
modelDefs(end).varNames = ["Hsub_true"];

modelDefs(end+1).name = "Hsub_P";
modelDefs(end).X = [E.Hsub_true_kJkg, E.P_MPa];
modelDefs(end).varNames = ["Hsub_true", "P_MPa"];

modelDefs(end+1).name = "Hsub_xMes";
modelDefs(end).X = [E.Hsub_true_kJkg, E.x_Mes];
modelDefs(end).varNames = ["Hsub_true", "x_Mes"];

modelDefs(end+1).name = "Hsub_qM";
modelDefs(end).X = [E.Hsub_true_kJkg, E.qM_MW_m2];
modelDefs(end).varNames = ["Hsub_true", "qM_MW_m2"];

modelDefs(end+1).name = "Hsub_F1delta";
modelDefs(end).X = [E.Hsub_true_kJkg, E.F1_delta_PM];
modelDefs(end).varNames = ["Hsub_true", "F1_delta_PM"];

modelDefs(end+1).name = "Hsub_P_xMes";
modelDefs(end).X = [E.Hsub_true_kJkg, E.P_MPa, E.x_Mes];
modelDefs(end).varNames = ["Hsub_true", "P_MPa", "x_Mes"];

modelDefs(end+1).name = "Hsub_P_xMes_qM";
modelDefs(end).X = [E.Hsub_true_kJkg, E.P_MPa, E.x_Mes, E.qM_MW_m2];
modelDefs(end).varNames = ["Hsub_true", "P_MPa", "x_Mes", "qM_MW_m2"];

modelDefs(end+1).name = "Hsub_P_xMes_F1delta";
modelDefs(end).X = [E.Hsub_true_kJkg, E.P_MPa, E.x_Mes, E.F1_delta_PM];
modelDefs(end).varNames = ["Hsub_true", "P_MPa", "x_Mes", "F1_delta_PM"];

modelDefs(end+1).name = "Hsub_Table8Dummy";
modelDefs(end).X = [E.Hsub_true_kJkg, isT8];
modelDefs(end).varNames = ["Hsub_true", "isT8"];

modelDefs(end+1).name = "Hsub_P_xMes_Table8Dummy";
modelDefs(end).X = [E.Hsub_true_kJkg, E.P_MPa, E.x_Mes, isT8];
modelDefs(end).varNames = ["Hsub_true", "P_MPa", "x_Mes", "isT8"];

modelDefs(end+1).name = "Hsub_P_xMes_qM_Table8Dummy";
modelDefs(end).X = [E.Hsub_true_kJkg, E.P_MPa, E.x_Mes, E.qM_MW_m2, isT8];
modelDefs(end).varNames = ["Hsub_true", "P_MPa", "x_Mes", "qM_MW_m2", "isT8"];

modelDefs(end+1).name = "Hsub_LDbandDummy";
modelDefs(end).X = [E.Hsub_true_kJkg, isMiddle, isLong];
modelDefs(end).varNames = ["Hsub_true", "isMiddle", "isLong"];

modelCompare = table();
coefTable = table();
Epred = E;

for k = 1:numel(modelDefs)
    fit = fitLinearModel(modelDefs(k).X, E.PM_F1, modelDefs(k).varNames);

    modelCompare = [modelCompare; fit.summaryRow("PM_F1", modelDefs(k).name)]; %#ok<AGROW>
    coefTable = [coefTable; fit.coefTable("PM_F1", modelDefs(k).name)]; %#ok<AGROW>

    predName = matlab.lang.makeValidName("pred_" + modelDefs(k).name);
    residName = matlab.lang.makeValidName("resid_" + modelDefs(k).name);

    Epred.(predName) = fit.yhat;
    Epred.(residName) = fit.resid;
end

%% ===== PM_noF1でも同じことを見る =====
modelCompare_noF1 = table();
coefTable_noF1 = table();

for k = 1:numel(modelDefs)
    fit = fitLinearModel(modelDefs(k).X, E.PM_noF1, modelDefs(k).varNames);

    modelCompare_noF1 = [modelCompare_noF1; fit.summaryRow("PM_noF1", modelDefs(k).name)]; %#ok<AGROW>
    coefTable_noF1 = [coefTable_noF1; fit.coefTable("PM_noF1", modelDefs(k).name)]; %#ok<AGROW>
end

%% ===== モデル別にT8 middle残差が残るか =====
residByGroup = table();
for i = 1:3
    g = groups(i);
    X = Epred(Epred.Group3 == g, :);
    residByGroup = [residByGroup; makeResidByGroup(g, X, modelDefs)]; %#ok<AGROW>
end

%% ===== 近傍マッチング =====
% Table8 middle各点に対して、Table9内で Hsub/P/xMes が近い点を探す。
T8mid = Epred(Epred.Group3 == "T8_middle", :);
T9all = Epred(Epred.TableNo == 9, :);

match_Hsub_P_xMes = nearestMatch(T8mid, T9all, ["Hsub_true_kJkg", "P_MPa", "x_Mes"], "match_Hsub_P_xMes");
match_Hsub_xMes   = nearestMatch(T8mid, T9all, ["Hsub_true_kJkg", "x_Mes"], "match_Hsub_xMes");
match_P_xMes      = nearestMatch(T8mid, T9all, ["P_MPa", "x_Mes"], "match_P_xMes");

matchSummary = table();
matchSummary = [matchSummary; makeMatchSummary("Hsub_P_xMes", match_Hsub_P_xMes)]; %#ok<AGROW>
matchSummary = [matchSummary; makeMatchSummary("Hsub_xMes", match_Hsub_xMes)]; %#ok<AGROW>
matchSummary = [matchSummary; makeMatchSummary("P_xMes", match_P_xMes)]; %#ok<AGROW>

%% ===== 簡易判定 =====
interpretation = makeInterpretation(modelCompare, contrast, residByGroup, matchSummary);

%% ===== 出力 =====
writetable(basic, outFile, "Sheet", "basic");
writetable(groupSummary, outFile, "Sheet", "group_summary");
writetable(contrast, outFile, "Sheet", "group_contrast");
writetable(modelCompare, outFile, "Sheet", "model_compare_PM_F1");
writetable(coefTable, outFile, "Sheet", "model_coefficients_PM_F1");
writetable(modelCompare_noF1, outFile, "Sheet", "model_compare_PM_noF1");
writetable(coefTable_noF1, outFile, "Sheet", "model_coefficients_PM_noF1");
writetable(residByGroup, outFile, "Sheet", "resid_by_group");
writetable(match_Hsub_P_xMes, outFile, "Sheet", "match_Hsub_P_xMes");
writetable(match_Hsub_xMes, outFile, "Sheet", "match_Hsub_xMes");
writetable(match_P_xMes, outFile, "Sheet", "match_P_xMes");
writetable(matchSummary, outFile, "Sheet", "match_summary");
writetable(interpretation, outFile, "Sheet", "interpretation_flags");
writetable(Epred, outFile, "Sheet", "explore_rows_with_resid");

%% ===== 図出力 =====

% 図1：グループ別PM_F1
fig1 = figure;
bar(categorical(groupSummary.Group), groupSummary.Mean_PM_F1);
grid on; box on;
ylabel("Mean PM_F1");
title("v11: PM_F1 by explore_low group");
xtickangle(45);
exportgraphics(fig1, fullfile(outDir, "TM8_14_v11_PM_F1_byGroup.png"), "Resolution", 200);

% 図2：Hsub-only残差
fig2 = figure;
bar(categorical(residByGroup.Group), residByGroup.Mean_resid_Hsub_only);
grid on; box on;
ylabel("Mean residual after Hsub-only fit");
title("v11: Hsub-only residual by group");
yline(0, "k--");
xtickangle(45);
exportgraphics(fig2, fullfile(outDir, "TM8_14_v11_HsubOnlyResid_byGroup.png"), "Resolution", 200);

% 図3：モデルR2
fig3 = figure;
bar(categorical(modelCompare.Model), modelCompare.R2);
grid on; box on;
ylabel("R^2");
title("v11: model comparison for explore_low PM_F1");
xtickangle(60);
exportgraphics(fig3, fullfile(outDir, "TM8_14_v11_model_R2_PM_F1.png"), "Resolution", 200);

% 図4：xMes vs PM_F1
fig4 = figure;
hold on;
plotGroupScatter(Epred, "x_Mes", "PM_F1");
grid on; box on;
xlabel("x_Mes");
ylabel("PM_F1");
title("v11: PM_F1 vs x_Mes by group");
legend("Location", "best");
exportgraphics(fig4, fullfile(outDir, "TM8_14_v11_PM_F1_vs_xMes.png"), "Resolution", 200);

% 図5：P vs PM_F1
fig5 = figure;
hold on;
plotGroupScatter(Epred, "P_MPa", "PM_F1");
grid on; box on;
xlabel("P [MPa]");
ylabel("PM_F1");
title("v11: PM_F1 vs P by group");
legend("Location", "best");
exportgraphics(fig5, fullfile(outDir, "TM8_14_v11_PM_F1_vs_P.png"), "Resolution", 200);

%% ===== 表示 =====
disp("=== basic ===");
disp(basic);

disp("=== group summary ===");
disp(groupSummary);

disp("=== contrast ===");
disp(contrast);

disp("=== model compare PM_F1 ===");
disp(modelCompare);

disp("=== resid by group ===");
disp(residByGroup);

disp("=== match summary ===");
disp(matchSummary);

disp("=== interpretation flags ===");
disp(interpretation);

fprintf("\nDone.\n");
fprintf("Excel output:\n  %s\n", outFile);
fprintf("PNG outputs are in:\n  %s\n", outDir);

%% ===== ローカル関数 =====

function g = makeExploreGroup(tableNo, ldBand)
    g = strings(size(tableNo));
    g(tableNo == 8 & ldBand == "middle") = "T8_middle";
    g(tableNo == 9 & ldBand == "short_anchor") = "T9_short";
    g(tableNo == 9 & ldBand == "long") = "T9_long";
    g(g == "") = "other";
end

function S = makeGroupSummary(label, X)
    S = table(string(label), height(X), ...
        mean(X.PM_noF1, "omitnan"), median(X.PM_noF1, "omitnan"), std(X.PM_noF1, "omitnan"), ...
        mean(X.PM_F1, "omitnan"), median(X.PM_F1, "omitnan"), std(X.PM_F1, "omitnan"), ...
        mean(X.F1_delta_PM, "omitnan"), median(X.F1_delta_PM, "omitnan"), ...
        mean(X.F1_ratio_PM, "omitnan"), median(X.F1_ratio_PM, "omitnan"), ...
        mean(X.Hsub_true_kJkg, "omitnan"), min(X.Hsub_true_kJkg, [], "omitnan"), max(X.Hsub_true_kJkg, [], "omitnan"), ...
        mean(X.P_MPa, "omitnan"), min(X.P_MPa, [], "omitnan"), max(X.P_MPa, [], "omitnan"), ...
        mean(X.x_Mes, "omitnan"), min(X.x_Mes, [], "omitnan"), max(X.x_Mes, [], "omitnan"), ...
        mean(X.qM_MW_m2, "omitnan"), mean(X.G, "omitnan"), mean(X.LD_geom, "omitnan"), ...
        mean(X.Tin, "omitnan"), mean(X.Tsub, "omitnan"), ...
        'VariableNames', ["Group", "N", ...
                          "Mean_PM_noF1", "Median_PM_noF1", "Std_PM_noF1", ...
                          "Mean_PM_F1", "Median_PM_F1", "Std_PM_F1", ...
                          "Mean_F1_delta_PM", "Median_F1_delta_PM", ...
                          "Mean_F1_ratio_PM", "Median_F1_ratio_PM", ...
                          "Mean_HsubTrue", "Min_HsubTrue", "Max_HsubTrue", ...
                          "Mean_P_MPa", "Min_P_MPa", "Max_P_MPa", ...
                          "Mean_xMes", "Min_xMes", "Max_xMes", ...
                          "Mean_qM_MW_m2", "Mean_G", "Mean_LD", ...
                          "Mean_Tin", "Mean_Tsub"]);
end

function S = makeContrast(nameA, A, nameB, B)
    S = table(string(nameA), string(nameB), height(A), height(B), ...
        mean(A.PM_F1, "omitnan") - mean(B.PM_F1, "omitnan"), ...
        mean(A.PM_noF1, "omitnan") - mean(B.PM_noF1, "omitnan"), ...
        mean(A.F1_delta_PM, "omitnan") - mean(B.F1_delta_PM, "omitnan"), ...
        mean(A.Hsub_true_kJkg, "omitnan") - mean(B.Hsub_true_kJkg, "omitnan"), ...
        mean(A.P_MPa, "omitnan") - mean(B.P_MPa, "omitnan"), ...
        mean(A.x_Mes, "omitnan") - mean(B.x_Mes, "omitnan"), ...
        mean(A.qM_MW_m2, "omitnan") - mean(B.qM_MW_m2, "omitnan"), ...
        mean(A.LD_geom, "omitnan") - mean(B.LD_geom, "omitnan"), ...
        'VariableNames', ["GroupA", "GroupB", "N_A", "N_B", ...
                          "Delta_PM_F1_AminusB", "Delta_PM_noF1_AminusB", ...
                          "Delta_F1_delta_AminusB", ...
                          "Delta_Hsub_AminusB", "Delta_P_AminusB", ...
                          "Delta_xMes_AminusB", "Delta_qM_AminusB", "Delta_LD_AminusB"]);
end

function fit = fitLinearModel(Xraw, yraw, varNames)
    Xraw = double(Xraw);
    yraw = double(yraw);

    if isvector(Xraw)
        Xraw = Xraw(:);
    end

    good = ~isnan(yraw) & ~isinf(yraw) & all(~isnan(Xraw) & ~isinf(Xraw), 2);

    X = Xraw(good, :);
    y = yraw(good);

    yhat = nan(size(yraw));
    resid = nan(size(yraw));

    p = size(X,2);

    if numel(y) < p + 2
        beta = nan(p+1,1);
        R2 = NaN;
        adjR2 = NaN;
        RMSE = NaN;
    else
        Xdesign = [ones(size(X,1),1), X];
        beta = Xdesign \ y;
        yhatGood = Xdesign * beta;

        SSE = sum((y - yhatGood).^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSE/SST;
        adjR2 = 1 - (1-R2)*(numel(y)-1)/(numel(y)-p-1);
        RMSE = sqrt(mean((y - yhatGood).^2));

        yhat(good) = yhatGood;
        resid(good) = y - yhatGood;
    end

    fit.beta = beta;
    fit.R2 = R2;
    fit.adjR2 = adjR2;
    fit.RMSE = RMSE;
    fit.N = sum(good);
    fit.yhat = yhat;
    fit.resid = resid;
    fit.varNames = ["Intercept", string(varNames(:)')];

    fit.summaryRow = @(yName, modelName) table( ...
        string(yName), string(modelName), fit.N, numel(varNames), fit.R2, fit.adjR2, fit.RMSE, ...
        'VariableNames', ["Y", "Model", "N", "NumPredictors", "R2", "AdjR2", "RMSE"] ...
    );

    fit.coefTable = @(yName, modelName) makeCoefTable(string(yName), string(modelName), fit.varNames, fit.beta);
end

function C = makeCoefTable(yName, modelName, names, beta)
    C = table();
    for i = 1:numel(names)
        tmp = table(yName, modelName, string(names(i)), beta(i), ...
            'VariableNames', ["Y", "Model", "Term", "Coefficient"]);
        C = [C; tmp]; %#ok<AGROW>
    end
end

function S = makeResidByGroup(label, X, modelDefs)
    S = table(string(label), height(X), mean(X.PM_F1, "omitnan"), ...
        'VariableNames', ["Group", "N", "Mean_PM_F1"]);

    for k = 1:numel(modelDefs)
        residName = matlab.lang.makeValidName("resid_" + modelDefs(k).name);
        shortName = matlab.lang.makeValidName("Mean_resid_" + modelDefs(k).name);
        S.(shortName) = mean(X.(residName), "omitnan");
    end
end

function M = nearestMatch(A, B, featureNames, label)
    if isempty(A) || isempty(B)
        M = table();
        return;
    end

    XA = table2array(A(:, featureNames));
    XB = table2array(B(:, featureNames));

    allX = [XA; XB];
    mu = mean(allX, 1, "omitnan");
    sig = std(allX, 0, 1, "omitnan");
    sig(sig == 0 | isnan(sig)) = 1;

    ZA = (XA - mu) ./ sig;
    ZB = (XB - mu) ./ sig;

    M = table();

    for i = 1:height(A)
        d = sqrt(sum((ZB - ZA(i,:)).^2, 2));
        [dmin, j] = min(d);

        tmp = table( ...
            string(label), ...
            A.No_TableNo(i), B.No_TableNo(j), ...
            A.Group3(i), B.Group3(j), ...
            dmin, ...
            A.PM_F1(i), B.PM_F1(j), A.PM_F1(i) - B.PM_F1(j), ...
            A.PM_noF1(i), B.PM_noF1(j), A.PM_noF1(i) - B.PM_noF1(j), ...
            A.Hsub_true_kJkg(i), B.Hsub_true_kJkg(j), A.Hsub_true_kJkg(i) - B.Hsub_true_kJkg(j), ...
            A.P_MPa(i), B.P_MPa(j), A.P_MPa(i) - B.P_MPa(j), ...
            A.x_Mes(i), B.x_Mes(j), A.x_Mes(i) - B.x_Mes(j), ...
            A.qM_MW_m2(i), B.qM_MW_m2(j), A.qM_MW_m2(i) - B.qM_MW_m2(j), ...
            A.LD_geom(i), B.LD_geom(j), A.LD_geom(i) - B.LD_geom(j), ...
            'VariableNames', ["MatchType", ...
                              "A_No_TableNo", "B_No_TableNo", ...
                              "A_Group", "B_Group", ...
                              "Distance", ...
                              "A_PM_F1", "B_PM_F1", "Delta_PM_F1_AminusB", ...
                              "A_PM_noF1", "B_PM_noF1", "Delta_PM_noF1_AminusB", ...
                              "A_Hsub", "B_Hsub", "Delta_Hsub_AminusB", ...
                              "A_P", "B_P", "Delta_P_AminusB", ...
                              "A_xMes", "B_xMes", "Delta_xMes_AminusB", ...
                              "A_qM", "B_qM", "Delta_qM_AminusB", ...
                              "A_LD", "B_LD", "Delta_LD_AminusB"]);
        M = [M; tmp]; %#ok<AGROW>
    end
end

function S = makeMatchSummary(label, M)
    if isempty(M)
        S = table(string(label), 0, NaN, NaN, NaN, NaN, ...
            'VariableNames', ["MatchType", "N", "Mean_Distance", "Mean_Delta_PM_F1", "Mean_Delta_PM_noF1", "Mean_Delta_xMes"]);
        return;
    end

    S = table(string(label), height(M), ...
        mean(M.Distance, "omitnan"), ...
        mean(M.Delta_PM_F1_AminusB, "omitnan"), ...
        mean(M.Delta_PM_noF1_AminusB, "omitnan"), ...
        mean(M.Delta_xMes_AminusB, "omitnan"), ...
        'VariableNames', ["MatchType", "N", "Mean_Distance", "Mean_Delta_PM_F1", "Mean_Delta_PM_noF1", "Mean_Delta_xMes"]);
end

function I = makeInterpretation(modelCompare, contrast, residByGroup, matchSummary)
    I = table();

    rH = getR2(modelCompare, "Hsub_only");
    rPx = getR2(modelCompare, "Hsub_P_xMes");
    rPxT = getR2(modelCompare, "Hsub_P_xMes_Table8Dummy");
    rFullT = getR2(modelCompare, "Hsub_P_xMes_qM_Table8Dummy");

    cT8T9all = contrast(contrast.GroupA=="T8_middle" & contrast.GroupB=="T9_all", :);
    if ~isempty(cT8T9all)
        deltaPM = cT8T9all.Delta_PM_F1_AminusB(1);
        deltaX  = cT8T9all.Delta_xMes_AminusB(1);
        deltaP  = cT8T9all.Delta_P_AminusB(1);
    else
        deltaPM = NaN; deltaX = NaN; deltaP = NaN;
    end

    m1 = matchSummary(matchSummary.MatchType=="Hsub_P_xMes", :);
    if ~isempty(m1)
        matchedDeltaPM = m1.Mean_Delta_PM_F1(1);
    else
        matchedDeltaPM = NaN;
    end

    I = [I; table("R2_Hsub_only", rH, "basic Hsub-only explanation", ...
        'VariableNames', ["Item", "Value", "Note"])]; %#ok<AGROW>
    I = [I; table("R2_Hsub_P_xMes", rPx, "improvement by P and xMes", ...
        'VariableNames', ["Item", "Value", "Note"])]; %#ok<AGROW>
    I = [I; table("R2_Hsub_P_xMes_Table8Dummy", rPxT, "additional improvement by Table8 dummy", ...
        'VariableNames', ["Item", "Value", "Note"])]; %#ok<AGROW>
    I = [I; table("R2_Hsub_P_xMes_qM_Table8Dummy", rFullT, "additional improvement by qM and Table8 dummy", ...
        'VariableNames', ["Item", "Value", "Note"])]; %#ok<AGROW>
    I = [I; table("Delta_PM_F1_T8middle_minus_T9all", deltaPM, "negative means Table8 middle is lower than Table9 all", ...
        'VariableNames', ["Item", "Value", "Note"])]; %#ok<AGROW>
    I = [I; table("Delta_xMes_T8middle_minus_T9all", deltaX, "xMes difference between Table8 middle and Table9 all", ...
        'VariableNames', ["Item", "Value", "Note"])]; %#ok<AGROW>
    I = [I; table("Delta_P_T8middle_minus_T9all", deltaP, "pressure difference between Table8 middle and Table9 all", ...
        'VariableNames', ["Item", "Value", "Note"])]; %#ok<AGROW>
    I = [I; table("Matched_Delta_PM_F1_T8minusT9_HsubPxMes", matchedDeltaPM, "if still negative after matching, Table8-specific low remains", ...
        'VariableNames', ["Item", "Value", "Note"])]; %#ok<AGROW>
end

function r = getR2(modelCompare, modelName)
    m = modelCompare.Model == modelName;
    if any(m)
        r = modelCompare.R2(find(m,1));
    else
        r = NaN;
    end
end

function plotGroupScatter(T, xvar, yvar)
    gs = ["T9_short", "T8_middle", "T9_long"];
    for i = 1:numel(gs)
        m = T.Group3 == gs(i);
        if any(m)
            scatter(T.(xvar)(m), T.(yvar)(m), 45, "filled", "DisplayName", gs(i));
        end
    end
end