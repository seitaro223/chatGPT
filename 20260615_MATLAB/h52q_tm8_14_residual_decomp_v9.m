%% h52q_tm8_14_residual_decomp_v9.m
% H52Q / T&M Table 8-14
% v9: 真Hsub補正後にTable12 long側へ残った正残差の理由を分解する。
%
% 入力:
%   out_TM8_14/TM8_14_true_hsub_residual_v8b_*.xlsx
%   Sheet: PWR_rows_with_trueHsub
%
% 出力:
%   out_TM8_14/TM8_14_residual_decomp_v9_yyyymmdd_HHMMSS.xlsx
%   out_TM8_14/TM8_14_v9_*.png

clear; clc; close all;

%% ===== 入力ファイル選択 =====
outDir = fullfile(pwd, "out_TM8_14");

files = dir(fullfile(outDir, "TM8_14_true_hsub_residual_v8b_*.xlsx"));
if isempty(files)
    error("out_TM8_14 に TM8_14_true_hsub_residual_v8b_*.xlsx が見つかりません。");
end

[~, idx] = max([files.datenum]);
inFile = fullfile(files(idx).folder, files(idx).name);

timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outFile = fullfile(outDir, "TM8_14_residual_decomp_v9_" + timestamp + ".xlsx");

fprintf("Input : %s\n", inFile);
fprintf("Output: %s\n\n", outFile);

%% ===== 読み込み =====
T = readtable(inFile, "Sheet", "PWR_rows_with_trueHsub", "VariableNamingRule", "preserve");

T.No_TableNo = string(T.No_TableNo);
T.LD_band = string(T.LD_band);

% 念のためPWR_near Table10-12に限定
T = T(ismember(T.TableNo, [10 11 12]), :);

%% ===== 基本確認 =====
basic = table( ...
    ["total_rows"; "T10_rows"; "T11_rows"; "T12_rows"; ...
     "short_rows"; "long_rows"; ...
     "missing_Hsub_true"; "missing_PM_F1"], ...
    [height(T); sum(T.TableNo==10); sum(T.TableNo==11); sum(T.TableNo==12); ...
     sum(T.LD_band=="short_anchor"); sum(T.LD_band=="long"); ...
     sum(isnan(T.Hsub_true_kJkg)); sum(isnan(T.PM_F1))], ...
    'VariableNames', ["Item", "Value"]);

%% ===== モデル定義 =====
% 目的：
% Hsub単独で残るTable12 long残差が、
% L/D, P, x_Mes, あるいはTable効果でどこまで減るかを見る。

% Table dummy
isT11 = double(T.TableNo == 11);
isT12 = double(T.TableNo == 12);

models = struct([]);

models(end+1).name = "M1_Hsub";
models(end).X = T.Hsub_true_kJkg;
models(end).varNames = ["Hsub_true"];

models(end+1).name = "M2_Hsub_LD";
models(end).X = [T.Hsub_true_kJkg, T.LD_geom];
models(end).varNames = ["Hsub_true", "LD"];

models(end+1).name = "M3_Hsub_P";
models(end).X = [T.Hsub_true_kJkg, T.P_MPa];
models(end).varNames = ["Hsub_true", "P_MPa"];

models(end+1).name = "M4_Hsub_xMes";
models(end).X = [T.Hsub_true_kJkg, T.x_Mes];
models(end).varNames = ["Hsub_true", "x_Mes"];

models(end+1).name = "M5_Hsub_LD_P";
models(end).X = [T.Hsub_true_kJkg, T.LD_geom, T.P_MPa];
models(end).varNames = ["Hsub_true", "LD", "P_MPa"];

models(end+1).name = "M6_Hsub_LD_xMes";
models(end).X = [T.Hsub_true_kJkg, T.LD_geom, T.x_Mes];
models(end).varNames = ["Hsub_true", "LD", "x_Mes"];

models(end+1).name = "M7_Hsub_LD_xMes_P";
models(end).X = [T.Hsub_true_kJkg, T.LD_geom, T.x_Mes, T.P_MPa];
models(end).varNames = ["Hsub_true", "LD", "x_Mes", "P_MPa"];

models(end+1).name = "M8_Hsub_TableDummy";
models(end).X = [T.Hsub_true_kJkg, isT11, isT12];
models(end).varNames = ["Hsub_true", "isT11", "isT12"];

models(end+1).name = "M9_Hsub_LD_TableDummy";
models(end).X = [T.Hsub_true_kJkg, T.LD_geom, isT11, isT12];
models(end).varNames = ["Hsub_true", "LD", "isT11", "isT12"];

%% ===== モデル計算 =====
modelCompare = table();
Tpred = T;

for k = 1:numel(models)
    mname = models(k).name;
    X = models(k).X;
    y = T.PM_F1;

    fit = fitLinearModel(X, y, models(k).varNames);

    modelCompare = [modelCompare; fit.summaryRow(mname, "PM_F1")]; %#ok<AGROW>

    predName = matlab.lang.makeValidName("pred_" + mname);
    residName = matlab.lang.makeValidName("resid_" + mname);

    Tpred.(predName) = fit.yhat;
    Tpred.(residName) = fit.resid;
end

%% ===== Table/L-D別の残差平均 =====
ldBands = ["short_anchor"; "long"];

residByTableLD = table();
for tbl = [10 11 12]
    for j = 1:numel(ldBands)
        idxRows = Tpred.TableNo == tbl & Tpred.LD_band == ldBands(j);
        if any(idxRows)
            residByTableLD = [residByTableLD; makeResidByGroup("T" + string(tbl), ldBands(j), Tpred(idxRows,:), models)]; %#ok<AGROW>
        end
    end
end

%% ===== Table11/12 short-long差分 =====
pairSummary = table();
for tbl = [11 12]
    S = Tpred(Tpred.TableNo == tbl & Tpred.LD_band == "short_anchor", :);
    L = Tpred(Tpred.TableNo == tbl & Tpred.LD_band == "long", :);

    if ~isempty(S) && ~isempty(L)
        pairSummary = [pairSummary; makePairSummary(tbl, S, L, models)]; %#ok<AGROW>
    end
end

%% ===== longだけ比較：Table11 long vs Table12 long =====
L11 = Tpred(Tpred.TableNo == 11 & Tpred.LD_band == "long", :);
L12 = Tpred(Tpred.TableNo == 12 & Tpred.LD_band == "long", :);

longCompare = makeLongCompare(L11, L12, models);

%% ===== 係数表 =====
coefTable = table();
for k = 1:numel(models)
    fit = fitLinearModel(models(k).X, T.PM_F1, models(k).varNames);
    coefTable = [coefTable; fit.coefTable(models(k).name, "PM_F1")]; %#ok<AGROW>
end

%% ===== 補助：Table11/12 longの行一覧 =====
longRows = Tpred(ismember(Tpred.TableNo, [11 12]) & Tpred.LD_band == "long", :);
longRows = sortrows(longRows, ["TableNo", "Hsub_true_kJkg"]);

%% ===== Excel出力 =====
writetable(basic, outFile, "Sheet", "basic");
writetable(modelCompare, outFile, "Sheet", "model_compare");
writetable(coefTable, outFile, "Sheet", "model_coefficients");
writetable(residByTableLD, outFile, "Sheet", "resid_by_table_LD");
writetable(pairSummary, outFile, "Sheet", "short_long_resid_delta");
writetable(longCompare, outFile, "Sheet", "T11long_vs_T12long");
writetable(longRows, outFile, "Sheet", "long_rows_T11_T12");
writetable(Tpred, outFile, "Sheet", "PWR_rows_with_v9_resid");

%% ===== 図出力 =====

% 図1：モデルごとのR2
fig1 = figure;
bar(categorical(modelCompare.Model), modelCompare.R2);
grid on; box on;
ylabel("R^2");
title("v9: model comparison for PM_F1");
xtickangle(45);
exportgraphics(fig1, fullfile(outDir, "TM8_14_v9_model_R2.png"), "Resolution", 200);

% 図2：Table12 short-long residual delta by model
fig2 = figure;
if any(pairSummary.TableNo == 12)
    row12 = pairSummary(pairSummary.TableNo == 12, :);
    deltaVals = getDeltaArray(row12, models);
    bar(categorical(string({models.name})), deltaVals);
    grid on; box on;
    ylabel("long - short residual, Table 12");
    title("v9: Table12 long-short residual delta by model");
    yline(0, "k--");
    xtickangle(45);
    exportgraphics(fig2, fullfile(outDir, "TM8_14_v9_Table12_delta_resid_byModel.png"), "Resolution", 200);
end

% 図3：Hsub true vs PM_F1 by Table/L-D
fig3 = figure;
hold on;
groups = [
    10, "short_anchor"
    11, "short_anchor"
    11, "long"
    12, "short_anchor"
    12, "long"
];
leg = strings(0,1);
for i = 1:size(groups,1)
    tbl = str2double(groups(i,1));
    band = groups(i,2);
    m = Tpred.TableNo == tbl & Tpred.LD_band == band;
    if any(m)
        scatter(Tpred.Hsub_true_kJkg(m), Tpred.PM_F1(m), 40, "filled");
        leg(end+1) = "T" + string(tbl) + "_" + band; %#ok<AGROW>
    end
end
grid on; box on;
xlabel("True Hsub [kJ/kg]");
ylabel("PM_F1");
title("v9: PM_F1 vs true Hsub by Table/L-D");
legend(leg, "Location", "best");
exportgraphics(fig3, fullfile(outDir, "TM8_14_v9_PM_vs_trueHsub_byGroup.png"), "Resolution", 200);

% 図4：M1_Hsub残差 vs L/D
fig4 = figure;
scatter(Tpred.LD_geom, Tpred.resid_M1_Hsub, 40, "filled");
grid on; box on;
xlabel("L/D");
ylabel("Residual after M1 Hsub-only");
title("v9: Hsub-only residual vs L/D");
yline(0, "k--");
exportgraphics(fig4, fullfile(outDir, "TM8_14_v9_M1_resid_vs_LD.png"), "Resolution", 200);

%% ===== 表示 =====
disp("=== basic ===");
disp(basic);

disp("=== model_compare ===");
disp(modelCompare);

disp("=== short_long_resid_delta ===");
disp(pairSummary);

disp("=== T11 long vs T12 long ===");
disp(longCompare);

fprintf("\nDone.\n");
fprintf("Excel output:\n  %s\n", outFile);
fprintf("PNG outputs are in:\n  %s\n", outDir);

%% ===== ローカル関数 =====

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

    fit.summaryRow = @(modelName, yName) table( ...
        string(yName), string(modelName), fit.N, numel(varNames), fit.R2, fit.adjR2, fit.RMSE, ...
        'VariableNames', ["Y", "Model", "N", "NumPredictors", "R2", "AdjR2", "RMSE"] ...
    );

    fit.coefTable = @(modelName, yName) makeCoefTable(string(yName), string(modelName), fit.varNames, fit.beta);
end

function C = makeCoefTable(yName, modelName, names, beta)
    C = table();
    for i = 1:numel(names)
        tmp = table(yName, modelName, string(names(i)), beta(i), ...
            'VariableNames', ["Y", "Model", "Term", "Coefficient"]);
        C = [C; tmp]; %#ok<AGROW>
    end
end

function S = makeResidByGroup(tableLabel, bandLabel, X, models)
    S = table(string(tableLabel), string(bandLabel), height(X), ...
        mean(X.PM_F1, "omitnan"), mean(X.Hsub_true_kJkg, "omitnan"), ...
        mean(X.LD_geom, "omitnan"), mean(X.P_MPa, "omitnan"), mean(X.x_Mes, "omitnan"), ...
        'VariableNames', ["TableLabel", "LD_band", "N", "Mean_PM_F1", "Mean_HsubTrue", "Mean_LD", "Mean_P_MPa", "Mean_xMes"]);

    for k = 1:numel(models)
        residName = matlab.lang.makeValidName("resid_" + models(k).name);
        S.("Mean_" + residName) = mean(X.(residName), "omitnan");
        S.("Median_" + residName) = median(X.(residName), "omitnan");
    end
end

function S = makePairSummary(tbl, Short, Long, models)
    S = table(tbl, height(Short), height(Long), ...
        mean(Short.PM_F1, "omitnan"), mean(Long.PM_F1, "omitnan"), ...
        mean(Long.PM_F1, "omitnan") - mean(Short.PM_F1, "omitnan"), ...
        mean(Short.Hsub_true_kJkg, "omitnan"), mean(Long.Hsub_true_kJkg, "omitnan"), ...
        mean(Long.Hsub_true_kJkg, "omitnan") - mean(Short.Hsub_true_kJkg, "omitnan"), ...
        mean(Short.LD_geom, "omitnan"), mean(Long.LD_geom, "omitnan"), ...
        mean(Long.LD_geom, "omitnan") - mean(Short.LD_geom, "omitnan"), ...
        mean(Short.P_MPa, "omitnan"), mean(Long.P_MPa, "omitnan"), ...
        mean(Long.P_MPa, "omitnan") - mean(Short.P_MPa, "omitnan"), ...
        mean(Short.x_Mes, "omitnan"), mean(Long.x_Mes, "omitnan"), ...
        mean(Long.x_Mes, "omitnan") - mean(Short.x_Mes, "omitnan"), ...
        'VariableNames', ["TableNo", "N_short", "N_long", ...
                          "Mean_PM_F1_short", "Mean_PM_F1_long", "Delta_PM_F1_long_minus_short", ...
                          "Mean_Hsub_short", "Mean_Hsub_long", "Delta_Hsub_long_minus_short", ...
                          "Mean_LD_short", "Mean_LD_long", "Delta_LD_long_minus_short", ...
                          "Mean_P_short", "Mean_P_long", "Delta_P_long_minus_short", ...
                          "Mean_xMes_short", "Mean_xMes_long", "Delta_xMes_long_minus_short"]);

    for k = 1:numel(models)
        residName = matlab.lang.makeValidName("resid_" + models(k).name);
        d = mean(Long.(residName), "omitnan") - mean(Short.(residName), "omitnan");
        S.("Delta_" + residName + "_long_minus_short") = d;
    end
end

function S = makeLongCompare(L11, L12, models)
    S = table("T11_long", "T12_long", height(L11), height(L12), ...
        mean(L11.PM_F1, "omitnan"), mean(L12.PM_F1, "omitnan"), ...
        mean(L12.PM_F1, "omitnan") - mean(L11.PM_F1, "omitnan"), ...
        mean(L11.Hsub_true_kJkg, "omitnan"), mean(L12.Hsub_true_kJkg, "omitnan"), ...
        mean(L12.Hsub_true_kJkg, "omitnan") - mean(L11.Hsub_true_kJkg, "omitnan"), ...
        mean(L11.P_MPa, "omitnan"), mean(L12.P_MPa, "omitnan"), ...
        mean(L12.P_MPa, "omitnan") - mean(L11.P_MPa, "omitnan"), ...
        mean(L11.x_Mes, "omitnan"), mean(L12.x_Mes, "omitnan"), ...
        mean(L12.x_Mes, "omitnan") - mean(L11.x_Mes, "omitnan"), ...
        'VariableNames', ["GroupA", "GroupB", "N_A", "N_B", ...
                          "Mean_PM_F1_A", "Mean_PM_F1_B", "Delta_PM_F1_B_minus_A", ...
                          "Mean_Hsub_A", "Mean_Hsub_B", "Delta_Hsub_B_minus_A", ...
                          "Mean_P_A", "Mean_P_B", "Delta_P_B_minus_A", ...
                          "Mean_xMes_A", "Mean_xMes_B", "Delta_xMes_B_minus_A"]);

    for k = 1:numel(models)
        residName = matlab.lang.makeValidName("resid_" + models(k).name);
        d = mean(L12.(residName), "omitnan") - mean(L11.(residName), "omitnan");
        S.("Delta_" + residName + "_T12long_minus_T11long") = d;
    end
end

function vals = getDeltaArray(row, models)
    vals = nan(1, numel(models));
    for k = 1:numel(models)
        residName = matlab.lang.makeValidName("resid_" + models(k).name);
        colName = "Delta_" + residName + "_long_minus_short";
        vals(k) = row.(colName);
    end
end