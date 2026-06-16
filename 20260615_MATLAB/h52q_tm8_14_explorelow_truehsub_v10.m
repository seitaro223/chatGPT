%% h52q_tm8_14_explorelow_truehsub_v10.m
% H52Q / T&M Table 8-14
% v10: explore_low 10-13 MPa側を入れ、真Hsub補正後残差とL/Dの関係を確認する。
%
% 目的:
%   1. PWR_near(Table10-12)で見えた「Hsub補正後にL/D方向の残差が残る可能性」が、
%      explore_low(Table8-9)でも同じ方向に出るか確認する。
%   2. 特に Table8 middle と Table9 short/long を使い、
%      short -> middle -> long のような傾向が見えるかを確認する。
%
% 入力:
%   out_TM8_14/TM8_14_tsub_residual_v7b_*.xlsx
%   TM8_14_true_hsub_input_v8a_*_Table10_Hsub_filled.xlsx
%   ThompsonMacbeth_TM8_9_11_14_G1000_macrohandoff_TinFilled.xlsx
%
% 出力:
%   out_TM8_14/TM8_14_explorelow_truehsub_v10_yyyymmdd_HHMMSS.xlsx
%   out_TM8_14/TM8_14_v10_*.png

clear; clc; close all;

%% ===== 設定 =====
outDir = fullfile(pwd, "out_TM8_14");
if ~exist(outDir, "dir")
    mkdir(outDir);
end

% v7b出力：全224行側を読むために使う
v7bFiles = dir(fullfile(outDir, "TM8_14_tsub_residual_v7b_*.xlsx"));
if isempty(v7bFiles)
    error("out_TM8_14 に TM8_14_tsub_residual_v7b_*.xlsx が見つかりません。");
end
[~, idx] = max([v7bFiles.datenum]);
v7bFile = fullfile(v7bFiles(idx).folder, v7bFiles(idx).name);

% Table10 true Hsub filled file
filledFiles = [
    dir(fullfile(pwd,    "TM8_14_true_hsub_input_v8a_*_Table10_Hsub_filled.xlsx"))
    dir(fullfile(outDir, "TM8_14_true_hsub_input_v8a_*_Table10_Hsub_filled.xlsx"))
];

if isempty(filledFiles)
    error("TM8_14_true_hsub_input_v8a_*_Table10_Hsub_filled.xlsx が見つかりません。pwdまたはout_TM8_14に置いてください。");
end
[~, idx] = max([filledFiles.datenum]);
table10HsubFile = fullfile(filledFiles(idx).folder, filledFiles(idx).name);

% handoff workbook：Table8/9/11/12 true Hsub
handoffFile = fullfile(pwd, "ThompsonMacbeth_TM8_9_11_14_G1000_macrohandoff_TinFilled.xlsx");
if ~isfile(handoffFile)
    error("handoff workbook が見つかりません: %s", handoffFile);
end
handoffSheet = "120_MACRO_INPUT_FINAL";

timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outFile = fullfile(outDir, "TM8_14_explorelow_truehsub_v10_" + timestamp + ".xlsx");

fprintf("v7b file        : %s\n", v7bFile);
fprintf("Table10 Hsub file: %s\n", table10HsubFile);
fprintf("handoff file    : %s\n", handoffFile);
fprintf("output file     : %s\n\n", outFile);

%% ===== v7b統合データを読む =====
C = readtable(v7bFile, "Sheet", "integrated_with_Tsub", "VariableNamingRule", "preserve");

C.No_TableNo = string(C.No_TableNo);
C.LD_band = string(C.LD_band);
C.P_band_v6 = classifyPressureV10(C.P_MPa);

%% ===== true Hsub mappingを作る =====

% --- Table10 PDF由来 ---
T10map = readtable(table10HsubFile, "Sheet", "Table10_PDF_Hsub_input", "VariableNamingRule", "preserve");
T10map.No_TableNo = string(T10map.No_TableNo);

M10 = table();
M10.No_TableNo = T10map.No_TableNo;
M10.TableNo_map = T10map.TableNo;
M10.Hsub_true_kJkg = T10map.Hsub_PDF_kJkg;
M10.Hsub_true_BTUlb = T10map.Hsub_PDF_BTUlb;
M10.Hsub_source = repmat("Table10_PDF_INLET_SUB_COOLING", height(T10map), 1);

% --- Table8/9/11/12 handoff由来 ---
H = readtable(handoffFile, "Sheet", handoffSheet, "VariableNamingRule", "preserve");

Hkey = makeNoTableNoKey(H);
Htable = tonum(getcol(H, ["TableNo"]));
Hsub  = tonum(getcol(H, ["hSub_kJ_kg", "Hsub_kJ_kg", "hsub_kJ_kg"]));

Mhandoff = table();
Mhandoff.No_TableNo = Hkey;
Mhandoff.TableNo_map = Htable;
Mhandoff.Hsub_true_kJkg = Hsub;
Mhandoff.Hsub_true_BTUlb = Hsub ./ 2.326;
Mhandoff.Hsub_source = repmat("handoff_120_MACRO_INPUT_FINAL_hSub_kJ_kg", height(H), 1);

% 今回の対象はTable8-12。Table10はPDF由来を優先。
Mhandoff = Mhandoff(ismember(Mhandoff.TableNo_map, [8 9 11 12]), :);

Hmap = [M10; Mhandoff];

% 重複確認
[uniqueKeys, ~, ic] = unique(Hmap.No_TableNo);
dupCounts = accumarray(ic, 1);
dupKeys = uniqueKeys(dupCounts > 1);

if ~isempty(dupKeys)
    warning("Hsub mappingに重複キーがあります。先頭のみ使用します。");
    [~, ia] = unique(Hmap.No_TableNo, "stable");
    Hmap = Hmap(ia, :);
end

%% ===== 統合 =====
J = innerjoin(C, Hmap(:, ["No_TableNo", "Hsub_true_kJkg", "Hsub_true_BTUlb", "Hsub_source"]), ...
    "Keys", "No_TableNo");

J.Hsub_proxy_minus_true_kJkg = J.Hsub_proxy_kJkg - J.Hsub_true_kJkg;
J.Hsub_proxy_over_true = J.Hsub_proxy_kJkg ./ J.Hsub_true_kJkg;

% 対象：Table8-12のみ
T = J(ismember(J.TableNo, [8 9 10 11 12]), :);
T.P_scope = classifyScope(T.TableNo, T.P_MPa);

% 今回の主対象だけ
Ttarget = T(T.P_scope == "explore_low_T8_9" | T.P_scope == "PWR_near_T10_12", :);
Ttarget = sortrows(Ttarget, ["P_scope", "TableNo", "LD_geom", "Hsub_true_kJkg"]);

%% ===== 基本確認 =====
basic = table( ...
    ["joined_rows_all"; ...
     "target_rows_T8_12"; ...
     "explore_low_rows_T8_9"; ...
     "PWR_near_rows_T10_12"; ...
     "Table8_rows"; ...
     "Table9_rows"; ...
     "Table10_rows"; ...
     "Table11_rows"; ...
     "Table12_rows"; ...
     "missing_true_Hsub_target"; ...
     "duplicate_Hsub_keys"], ...
    [height(J); ...
     height(Ttarget); ...
     sum(Ttarget.P_scope == "explore_low_T8_9"); ...
     sum(Ttarget.P_scope == "PWR_near_T10_12"); ...
     sum(Ttarget.TableNo == 8); ...
     sum(Ttarget.TableNo == 9); ...
     sum(Ttarget.TableNo == 10); ...
     sum(Ttarget.TableNo == 11); ...
     sum(Ttarget.TableNo == 12); ...
     sum(isnan(Ttarget.Hsub_true_kJkg)); ...
     numel(dupKeys)], ...
    'VariableNames', ["Item", "Value"]);

%% ===== scope別モデル比較 =====
scopeList = ["explore_low_T8_9"; "PWR_near_T10_12"; "combined_T8_12"];

modelCompare = table();
coefTable = table();

% 残差列を先に作る
Ttarget.resid_scope_HsubOnly = nan(height(Ttarget), 1);
Ttarget.resid_scope_Hsub_LD  = nan(height(Ttarget), 1);
Ttarget.pred_scope_HsubOnly  = nan(height(Ttarget), 1);
Ttarget.pred_scope_Hsub_LD   = nan(height(Ttarget), 1);

Ttarget.resid_combined_HsubOnly = nan(height(Ttarget), 1);
Ttarget.resid_combined_Hsub_LD  = nan(height(Ttarget), 1);

for s = 1:numel(scopeList)
    scope = scopeList(s);

    if scope == "combined_T8_12"
        m = true(height(Ttarget), 1);
    else
        m = Ttarget.P_scope == scope;
    end

    Xscope = Ttarget(m, :);
    if isempty(Xscope)
        continue;
    end

    modelDefs = makeModelDefs(Xscope, scope);

    for k = 1:numel(modelDefs)
        fit = fitLinearModel(modelDefs(k).X, Xscope.PM_F1, modelDefs(k).varNames);

        modelCompare = [modelCompare; fit.summaryRow(scope, modelDefs(k).name, "PM_F1")]; %#ok<AGROW>
        coefTable = [coefTable; fit.coefTable(scope, modelDefs(k).name, "PM_F1")]; %#ok<AGROW>

        % scope別の主要2モデルの残差を保存
        if scope ~= "combined_T8_12"
            if modelDefs(k).name == "Hsub_only"
                Ttarget.pred_scope_HsubOnly(m) = fit.yhat;
                Ttarget.resid_scope_HsubOnly(m) = fit.resid;
            elseif modelDefs(k).name == "Hsub_LD"
                Ttarget.pred_scope_Hsub_LD(m) = fit.yhat;
                Ttarget.resid_scope_Hsub_LD(m) = fit.resid;
            end
        else
            if modelDefs(k).name == "Hsub_only"
                Ttarget.resid_combined_HsubOnly = fit.resid;
            elseif modelDefs(k).name == "Hsub_LD"
                Ttarget.resid_combined_Hsub_LD = fit.resid;
            end
        end
    end
end

%% ===== scope × L/D / Table × L/D 集計 =====
byScopeLD = table();
byScopeTableLD = table();

ldBands = ["short_anchor"; "middle"; "long"];

for s = 1:2
    scope = scopeList(s);
    Sdata = Ttarget(Ttarget.P_scope == scope, :);

    for j = 1:numel(ldBands)
        m = Sdata.LD_band == ldBands(j);
        if any(m)
            byScopeLD = [byScopeLD; makeGroupStats(scope, ldBands(j), Sdata(m,:))]; %#ok<AGROW>
        end
    end

    tbls = unique(Sdata.TableNo)';
    for tbl = tbls
        for j = 1:numel(ldBands)
            m = Sdata.TableNo == tbl & Sdata.LD_band == ldBands(j);
            if any(m)
                byScopeTableLD = [byScopeTableLD; makeTableLDStats(scope, tbl, ldBands(j), Sdata(m,:))]; %#ok<AGROW>
            end
        end
    end
end

%% ===== 同一Table内 short-long比較 =====
% Table9, 11, 12が対象。Table8はmiddleのみなので別扱い。
sameTablePairs = table();
for tbl = [9 11 12]
    S = Ttarget(Ttarget.TableNo == tbl & Ttarget.LD_band == "short_anchor", :);
    L = Ttarget(Ttarget.TableNo == tbl & Ttarget.LD_band == "long", :);

    if ~isempty(S) && ~isempty(L)
        sameTablePairs = [sameTablePairs; makePairSummary(tbl, S, L)]; %#ok<AGROW>
    end
end

%% ===== Table8 middleの位置確認 =====
% Table8 middle が、explore_low内でTable9 short/longの間に来るかを見る。
T8mid = Ttarget(Ttarget.TableNo == 8 & Ttarget.LD_band == "middle", :);
T9short = Ttarget(Ttarget.TableNo == 9 & Ttarget.LD_band == "short_anchor", :);
T9long = Ttarget(Ttarget.TableNo == 9 & Ttarget.LD_band == "long", :);

middleContext = table();
middleContext = [middleContext; makeContextRow("T9_short", T9short)]; %#ok<AGROW>
middleContext = [middleContext; makeContextRow("T8_middle", T8mid)]; %#ok<AGROW>
middleContext = [middleContext; makeContextRow("T9_long", T9long)]; %#ok<AGROW>

%% ===== explore_low vs PWR_nearの方向性判定 =====
directionCheck = makeDirectionCheck(byScopeLD);

%% ===== 出力 =====
writetable(basic, outFile, "Sheet", "basic");
writetable(Hmap, outFile, "Sheet", "Hsub_mapping_used");
writetable(modelCompare, outFile, "Sheet", "model_compare_by_scope");
writetable(coefTable, outFile, "Sheet", "model_coefficients");
writetable(byScopeLD, outFile, "Sheet", "by_scope_LD");
writetable(byScopeTableLD, outFile, "Sheet", "by_scope_table_LD");
writetable(sameTablePairs, outFile, "Sheet", "same_table_pairs");
writetable(middleContext, outFile, "Sheet", "Table8_middle_context");
writetable(directionCheck, outFile, "Sheet", "direction_check");
writetable(Ttarget, outFile, "Sheet", "target_rows_T8_12");

%% ===== 図出力 =====

% 図1：scope別 R2
fig1 = figure;
bar(categorical(modelCompare.Scope + "_" + modelCompare.Model), modelCompare.R2);
grid on; box on;
ylabel("R^2");
title("v10: model comparison by scope");
xtickangle(60);
exportgraphics(fig1, fullfile(outDir, "TM8_14_v10_model_R2_byScope.png"), "Resolution", 200);

% 図2：scope×LDのHsub-only残差平均
fig2 = figure;
bar(categorical(byScopeLD.Scope + "_" + byScopeLD.LD_band), byScopeLD.Mean_resid_scope_HsubOnly);
grid on; box on;
ylabel("Mean residual after scope Hsub-only fit");
title("v10: Hsub-only residual by scope and L/D band");
xtickangle(45);
yline(0, "k--");
exportgraphics(fig2, fullfile(outDir, "TM8_14_v10_resid_HsubOnly_byScopeLD.png"), "Resolution", 200);

% 図3：Hsub true vs PM_F1, scope別
fig3 = figure;
hold on;
scopes = ["explore_low_T8_9", "PWR_near_T10_12"];
leg = strings(0,1);
for i = 1:numel(scopes)
    m = Ttarget.P_scope == scopes(i);
    scatter(Ttarget.Hsub_true_kJkg(m), Ttarget.PM_F1(m), 40, "filled");
    leg(end+1) = scopes(i); %#ok<AGROW>
end
grid on; box on;
xlabel("True Hsub [kJ/kg]");
ylabel("PM_F1");
title("v10: PM_F1 vs true Hsub by pressure scope");
legend(leg, "Location", "best");
exportgraphics(fig3, fullfile(outDir, "TM8_14_v10_PM_vs_Hsub_byScope.png"), "Resolution", 200);

% 図4：L/D vs scope-fit Hsub-only residual
fig4 = figure;
hold on;
for i = 1:numel(scopes)
    m = Ttarget.P_scope == scopes(i);
    scatter(Ttarget.LD_geom(m), Ttarget.resid_scope_HsubOnly(m), 40, "filled");
end
grid on; box on;
xlabel("L/D");
ylabel("Residual after scope Hsub-only fit");
title("v10: Hsub-only residual vs L/D by scope");
yline(0, "k--");
legend(scopes, "Location", "best");
exportgraphics(fig4, fullfile(outDir, "TM8_14_v10_resid_HsubOnly_vs_LD_byScope.png"), "Resolution", 200);

%% ===== 表示 =====
disp("=== basic ===");
disp(basic);

disp("=== model compare by scope ===");
disp(modelCompare);

disp("=== by scope L/D ===");
disp(byScopeLD);

disp("=== same table pairs ===");
disp(sameTablePairs);

disp("=== middle context ===");
disp(middleContext);

disp("=== direction check ===");
disp(directionCheck);

fprintf("\nDone.\n");
fprintf("Excel output:\n  %s\n", outFile);
fprintf("PNG outputs are in:\n  %s\n", outDir);

%% ===== ローカル関数 =====

function band = classifyPressureV10(P)
    band = strings(size(P));
    band(P >= 10 & P < 13) = "explore_low";
    band(P >= 13 & P <= 17.5) = "PWR_near";
    band(P > 17.5 & P <= 20) = "high_check";
    band((P < 10 | P > 20) & ~isnan(P)) = "outside_pressure";
    band(isnan(P)) = "missing";
end

function scope = classifyScope(tableNo, P)
    scope = strings(size(P));
    scope(ismember(tableNo, [8 9]) & P >= 10 & P < 13) = "explore_low_T8_9";
    scope(ismember(tableNo, [10 11 12]) & P >= 13 & P <= 17.5) = "PWR_near_T10_12";
    scope(scope == "") = "other";
end

function defs = makeModelDefs(T, scope)
    defs = struct([]);

    defs(end+1).name = "Hsub_only";
    defs(end).X = T.Hsub_true_kJkg;
    defs(end).varNames = ["Hsub_true"];

    defs(end+1).name = "Hsub_LD";
    defs(end).X = [T.Hsub_true_kJkg, T.LD_geom];
    defs(end).varNames = ["Hsub_true", "LD"];

    defs(end+1).name = "Hsub_P";
    defs(end).X = [T.Hsub_true_kJkg, T.P_MPa];
    defs(end).varNames = ["Hsub_true", "P_MPa"];

    defs(end+1).name = "Hsub_xMes";
    defs(end).X = [T.Hsub_true_kJkg, T.x_Mes];
    defs(end).varNames = ["Hsub_true", "x_Mes"];

    defs(end+1).name = "Hsub_LD_P";
    defs(end).X = [T.Hsub_true_kJkg, T.LD_geom, T.P_MPa];
    defs(end).varNames = ["Hsub_true", "LD", "P_MPa"];

    defs(end+1).name = "Hsub_LD_xMes_P";
    defs(end).X = [T.Hsub_true_kJkg, T.LD_geom, T.x_Mes, T.P_MPa];
    defs(end).varNames = ["Hsub_true", "LD", "x_Mes", "P_MPa"];

    if scope == "combined_T8_12"
        isPWR = double(T.P_scope == "PWR_near_T10_12");

        defs(end+1).name = "Hsub_LD_scopeDummy";
        defs(end).X = [T.Hsub_true_kJkg, T.LD_geom, isPWR];
        defs(end).varNames = ["Hsub_true", "LD", "isPWRnear"];
    end
end

function key = makeNoTableNoKey(T)
    vars = string(T.Properties.VariableNames);
    norm = normalizeName(vars);

    idxKey = find(ismember(norm, ["notableno", "exptnotableno"]), 1);
    if ~isempty(idxKey)
        key = string(T.(vars(idxKey)));
        return;
    end

    expt = getcol(T, ["ExptNo", "EXPT NO", "EXPTNO"]);
    tbl  = tonum(getcol(T, ["TableNo", "TABLE NO", "Table"]));

    if isnumeric(expt)
        exptText = strings(size(expt));
        for i = 1:numel(expt)
            exptText(i) = stripZeros(compose("%.2f", expt(i)));
        end
    else
        exptText = string(expt);
    end

    key = exptText + "_" + string(tbl);
end

function s = stripZeros(s)
    s = string(s);
    s = regexprep(s, "(\.\d*?)0+$", "$1");
    s = regexprep(s, "\.$", "");
end

function v = getcol(T, candidates)
    vars = string(T.Properties.VariableNames);
    normVars = normalizeName(vars);

    for c = candidates
        idx = find(normVars == normalizeName(c), 1);
        if ~isempty(idx)
            v = T.(vars(idx));
            return;
        end
    end

    error("Required column not found. Candidates: %s\nAvailable columns:\n%s", ...
        strjoin(candidates, ", "), strjoin(vars, ", "));
end

function n = normalizeName(x)
    n = lower(string(x));
    n = regexprep(n, "[\s_()\-/\.]", "");
end

function x = tonum(v)
    if isnumeric(v)
        x = double(v);
    else
        x = str2double(string(v));
    end
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

    fit.summaryRow = @(scope, modelName, yName) table( ...
        string(scope), string(yName), string(modelName), fit.N, numel(varNames), fit.R2, fit.adjR2, fit.RMSE, ...
        'VariableNames', ["Scope", "Y", "Model", "N", "NumPredictors", "R2", "AdjR2", "RMSE"] ...
    );

    fit.coefTable = @(scope, modelName, yName) makeCoefTable(string(scope), string(yName), string(modelName), fit.varNames, fit.beta);
end

function C = makeCoefTable(scope, yName, modelName, names, beta)
    C = table();
    for i = 1:numel(names)
        tmp = table(scope, yName, modelName, string(names(i)), beta(i), ...
            'VariableNames', ["Scope", "Y", "Model", "Term", "Coefficient"]);
        C = [C; tmp]; %#ok<AGROW>
    end
end

function S = makeGroupStats(scope, band, X)
    S = table(string(scope), string(band), height(X), ...
        mean(X.PM_F1, "omitnan"), median(X.PM_F1, "omitnan"), ...
        mean(X.Hsub_true_kJkg, "omitnan"), mean(X.LD_geom, "omitnan"), ...
        mean(X.P_MPa, "omitnan"), mean(X.x_Mes, "omitnan"), ...
        mean(X.resid_scope_HsubOnly, "omitnan"), median(X.resid_scope_HsubOnly, "omitnan"), ...
        mean(X.resid_scope_Hsub_LD, "omitnan"), median(X.resid_scope_Hsub_LD, "omitnan"), ...
        mean(X.resid_combined_HsubOnly, "omitnan"), mean(X.resid_combined_Hsub_LD, "omitnan"), ...
        'VariableNames', ["Scope", "LD_band", "N", ...
                          "Mean_PM_F1", "Median_PM_F1", ...
                          "Mean_HsubTrue", "Mean_LD", "Mean_P_MPa", "Mean_xMes", ...
                          "Mean_resid_scope_HsubOnly", "Median_resid_scope_HsubOnly", ...
                          "Mean_resid_scope_Hsub_LD", "Median_resid_scope_Hsub_LD", ...
                          "Mean_resid_combined_HsubOnly", "Mean_resid_combined_Hsub_LD"]);
end

function S = makeTableLDStats(scope, tbl, band, X)
    S = makeGroupStats(scope, band, X);
    S.TableNo = tbl;
    S.GroupValue = "T" + string(tbl) + "_" + string(band);
    S = movevars(S, ["TableNo", "GroupValue"], "After", "Scope");
end

function S = makePairSummary(tbl, Short, Long)
    S = table(tbl, height(Short), height(Long), ...
        mean(Short.PM_F1, "omitnan"), mean(Long.PM_F1, "omitnan"), ...
        mean(Long.PM_F1, "omitnan") - mean(Short.PM_F1, "omitnan"), ...
        mean(Short.Hsub_true_kJkg, "omitnan"), mean(Long.Hsub_true_kJkg, "omitnan"), ...
        mean(Long.Hsub_true_kJkg, "omitnan") - mean(Short.Hsub_true_kJkg, "omitnan"), ...
        mean(Short.LD_geom, "omitnan"), mean(Long.LD_geom, "omitnan"), ...
        mean(Long.LD_geom, "omitnan") - mean(Short.LD_geom, "omitnan"), ...
        mean(Short.resid_scope_HsubOnly, "omitnan"), mean(Long.resid_scope_HsubOnly, "omitnan"), ...
        mean(Long.resid_scope_HsubOnly, "omitnan") - mean(Short.resid_scope_HsubOnly, "omitnan"), ...
        mean(Short.resid_scope_Hsub_LD, "omitnan"), mean(Long.resid_scope_Hsub_LD, "omitnan"), ...
        mean(Long.resid_scope_Hsub_LD, "omitnan") - mean(Short.resid_scope_Hsub_LD, "omitnan"), ...
        'VariableNames', ["TableNo", "N_short", "N_long", ...
                          "Mean_PM_F1_short", "Mean_PM_F1_long", "Delta_PM_F1_long_minus_short", ...
                          "Mean_Hsub_short", "Mean_Hsub_long", "Delta_Hsub_long_minus_short", ...
                          "Mean_LD_short", "Mean_LD_long", "Delta_LD_long_minus_short", ...
                          "Mean_resid_HsubOnly_short", "Mean_resid_HsubOnly_long", "Delta_resid_HsubOnly_long_minus_short", ...
                          "Mean_resid_HsubLD_short", "Mean_resid_HsubLD_long", "Delta_resid_HsubLD_long_minus_short"]);
end

function S = makeContextRow(label, X)
    if isempty(X)
        S = table(string(label), 0, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
            'VariableNames', ["Group", "N", "Mean_PM_F1", "Mean_HsubTrue", "Mean_LD", "Mean_P_MPa", ...
                              "Mean_xMes", "Mean_resid_HsubOnly", "Mean_resid_HsubLD"]);
        return;
    end

    S = table(string(label), height(X), ...
        mean(X.PM_F1, "omitnan"), ...
        mean(X.Hsub_true_kJkg, "omitnan"), ...
        mean(X.LD_geom, "omitnan"), ...
        mean(X.P_MPa, "omitnan"), ...
        mean(X.x_Mes, "omitnan"), ...
        mean(X.resid_scope_HsubOnly, "omitnan"), ...
        mean(X.resid_scope_Hsub_LD, "omitnan"), ...
        'VariableNames', ["Group", "N", "Mean_PM_F1", "Mean_HsubTrue", "Mean_LD", "Mean_P_MPa", ...
                          "Mean_xMes", "Mean_resid_HsubOnly", "Mean_resid_HsubLD"]);
end

function D = makeDirectionCheck(byScopeLD)
    D = table();

    scopes = unique(byScopeLD.Scope);
    for i = 1:numel(scopes)
        scope = scopes(i);
        X = byScopeLD(byScopeLD.Scope == scope, :);

        shortVal = getBandValue(X, "short_anchor");
        middleVal = getBandValue(X, "middle");
        longVal = getBandValue(X, "long");

        D = [D; table(scope, shortVal, middleVal, longVal, ...
            longVal - shortVal, middleVal - shortVal, ...
            'VariableNames', ["Scope", "MeanResid_short", "MeanResid_middle", "MeanResid_long", ...
                              "LongMinusShort", "MiddleMinusShort"])]; %#ok<AGROW>
    end
end

function v = getBandValue(X, band)
    m = X.LD_band == band;
    if any(m)
        v = X.Mean_resid_scope_HsubOnly(find(m,1));
    else
        v = NaN;
    end
end