%% h52q_tm8_14_true_hsub_residual_v8b.m
% H52Q / T&M Table 8-14
% v8b: 真Hsubを使ってPWR_near Table10-12のPM残差診断を行う。
%
% 入力:
%   out_TM8_14/TM8_14_tsub_residual_v7b_*.xlsx
%   TM8_14_true_hsub_input_v8a_*_Table10_Hsub_filled.xlsx
%
% 真Hsub:
%   Table10    : Table10 PDF由来 Hsub_PDF_kJkg
%   Table11/12 : handoff由来 hSub_kJ_kg
%
% 出力:
%   out_TM8_14/TM8_14_true_hsub_residual_v8b_yyyymmdd_HHMMSS.xlsx
%   out_TM8_14/TM8_14_v8b_*.png

clear; clc; close all;

%% ===== 設定 =====
outDir = fullfile(pwd, "out_TM8_14");
if ~exist(outDir, "dir")
    mkdir(outDir);
end

% v7b出力を探す
v7bFiles = dir(fullfile(outDir, "TM8_14_tsub_residual_v7b_*.xlsx"));
if isempty(v7bFiles)
    error("out_TM8_14 に TM8_14_tsub_residual_v7b_*.xlsx が見つかりません。");
end
[~, idx] = max([v7bFiles.datenum]);
v7bFile = fullfile(v7bFiles(idx).folder, v7bFiles(idx).name);

% filled済みv8a入力ファイルを探す
filledFiles = [
    dir(fullfile(pwd,    "TM8_14_true_hsub_input_v8a_*_Table10_Hsub_filled.xlsx"))
    dir(fullfile(outDir, "TM8_14_true_hsub_input_v8a_*_Table10_Hsub_filled.xlsx"))
];

if isempty(filledFiles)
    error("TM8_14_true_hsub_input_v8a_*_Table10_Hsub_filled.xlsx が見つかりません。pwdまたはout_TM8_14に置いてください。");
end
[~, idx] = max([filledFiles.datenum]);
trueHsubFile = fullfile(filledFiles(idx).folder, filledFiles(idx).name);

timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outFile = fullfile(outDir, "TM8_14_true_hsub_residual_v8b_" + timestamp + ".xlsx");

fprintf("v7b file      : %s\n", v7bFile);
fprintf("trueHsub file : %s\n", trueHsubFile);
fprintf("output file   : %s\n\n", outFile);

%% ===== v7b統合データを読む =====
C = readtable(v7bFile, "Sheet", "integrated_with_Tsub", "VariableNamingRule", "preserve");

C.No_TableNo = string(C.No_TableNo);
C.LD_band = string(C.LD_band);
C.P_band_v6 = string(C.P_band_v6);

%% ===== 真Hsub mappingを読む =====
T10map = readtable(trueHsubFile, "Sheet", "Table10_PDF_Hsub_input", "VariableNamingRule", "preserve");
T12map = readtable(trueHsubFile, "Sheet", "Table11_12_hSub_handoff", "VariableNamingRule", "preserve");

T10map.No_TableNo = string(T10map.No_TableNo);
T12map.No_TableNo = string(T12map.No_TableNo);

% Table10 mapping
M10 = table();
M10.No_TableNo = T10map.No_TableNo;
M10.TableNo_map = T10map.TableNo;
M10.Hsub_true_kJkg = T10map.Hsub_PDF_kJkg;
M10.Hsub_true_BTUlb = T10map.Hsub_PDF_BTUlb;
M10.Hsub_source = repmat("Table10_PDF_INLET_SUB_COOLING", height(T10map), 1);

% Table11/12 mapping
M12 = table();
M12.No_TableNo = T12map.No_TableNo;
M12.TableNo_map = T12map.TableNo;
M12.Hsub_true_kJkg = T12map.Hsub_true_kJkg;
M12.Hsub_true_BTUlb = T12map.Hsub_true_BTUlb;
M12.Hsub_source = repmat("handoff_120_MACRO_INPUT_FINAL_hSub_kJ_kg", height(T12map), 1);

Hmap = [M10; M12];

% 念のため重複確認
[uniqueKeys, ~, ic] = unique(Hmap.No_TableNo);
dupCounts = accumarray(ic, 1);
dupKeys = uniqueKeys(dupCounts > 1);

if ~isempty(dupKeys)
    warning("Hsub mappingに重複キーがあります。先頭のみ使用します。");
    [~, ia] = unique(Hmap.No_TableNo, "stable");
    Hmap = Hmap(ia, :);
end

%% ===== 統合 =====
% 古いMATLAB互換のため、必要列だけにしてjoinする
Cj = C;
Hj = Hmap(:, ["No_TableNo", "Hsub_true_kJkg", "Hsub_true_BTUlb", "Hsub_source"]);

J = innerjoin(Cj, Hj, "Keys", "No_TableNo");

J.Hsub_proxy_minus_true_kJkg = J.Hsub_proxy_kJkg - J.Hsub_true_kJkg;
J.Hsub_proxy_over_true = J.Hsub_proxy_kJkg ./ J.Hsub_true_kJkg;

%% ===== PWR_near Table10-12抽出 =====
PWR = J(J.P_band_v6 == "PWR_near" & ismember(J.TableNo, [10; 11; 12]), :);
PWR = sortrows(PWR, ["TableNo", "LD_geom", "Hsub_true_kJkg"]);

%% ===== 基本確認 =====
basic = table( ...
    ["joined_all_rows"; ...
     "PWR_rows"; ...
     "Table10_rows"; ...
     "Table11_rows"; ...
     "Table12_rows"; ...
     "missing_true_Hsub_PWR"; ...
     "missing_proxy_Hsub_PWR"; ...
     "duplicate_Hsub_keys"], ...
    [height(J); ...
     height(PWR); ...
     sum(PWR.TableNo == 10); ...
     sum(PWR.TableNo == 11); ...
     sum(PWR.TableNo == 12); ...
     sum(isnan(PWR.Hsub_true_kJkg)); ...
     sum(isnan(PWR.Hsub_proxy_kJkg)); ...
     numel(dupKeys)], ...
    'VariableNames', ["Item", "Value"]);

%% ===== Table/L-D別統計 =====
ldBands = ["short_anchor"; "middle"; "long"];

pwr_by_table_LD = table();
for tbl = [10 11 12]
    for j = 1:numel(ldBands)
        m = PWR.TableNo == tbl & PWR.LD_band == ldBands(j);
        if any(m)
            pwr_by_table_LD = [pwr_by_table_LD; makeStats("PWR_Table_LD", "T" + string(tbl) + "_" + ldBands(j), PWR(m,:))]; %#ok<AGROW>
        end
    end
end

pwr_by_LD = table();
for j = 1:numel(ldBands)
    m = PWR.LD_band == ldBands(j);
    if any(m)
        pwr_by_LD = [pwr_by_LD; makeStats("PWR_LD", ldBands(j), PWR(m,:))]; %#ok<AGROW>
    end
end

%% ===== raw short-long比較 =====
raw_pair_summary = table();
for tbl = [11 12]
    S = PWR(PWR.TableNo == tbl & PWR.LD_band == "short_anchor", :);
    L = PWR(PWR.TableNo == tbl & PWR.LD_band == "long", :);

    if ~isempty(S) && ~isempty(L)
        raw_pair_summary = [raw_pair_summary; makeRawPairSummary(tbl, S, L)]; %#ok<AGROW>
    end
end

%% ===== モデル比較 =====
modelCompare = table();

modelCompare = [modelCompare; makeModelRow("PM_F1", "Hsub_true_only", PWR.Hsub_true_kJkg, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "Hsub_proxy_only", PWR.Hsub_proxy_kJkg, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "Tsub_only", PWR.Tsub, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "LD_only", PWR.LD_geom, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "xMes_only", PWR.x_Mes, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "P_only", PWR.P_MPa, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "G_only", PWR.G, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "qM_only", PWR.qM, PWR.PM_F1)];

modelCompare = [modelCompare; makeModelRow("PM_F1", "HsubTrue_LD", [PWR.Hsub_true_kJkg, PWR.LD_geom], PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "HsubTrue_LD_xMes_P", [PWR.Hsub_true_kJkg, PWR.LD_geom, PWR.x_Mes, PWR.P_MPa], PWR.PM_F1)];

modelCompare = [modelCompare; makeModelRow("PM_noF1", "Hsub_true_only", PWR.Hsub_true_kJkg, PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "Hsub_proxy_only", PWR.Hsub_proxy_kJkg, PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "Tsub_only", PWR.Tsub, PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "LD_only", PWR.LD_geom, PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "HsubTrue_LD", [PWR.Hsub_true_kJkg, PWR.LD_geom], PWR.PM_noF1)];

%% ===== 真Hsub残差 =====
PWR_resid = PWR;

[PWR_resid.PM_F1_pred_HsubTrueOnly, PWR_resid.PM_F1_resid_HsubTrueOnly] = simplePredictResidual(PWR.Hsub_true_kJkg, PWR.PM_F1);
[PWR_resid.PM_F1_pred_HsubProxyOnly, PWR_resid.PM_F1_resid_HsubProxyOnly] = simplePredictResidual(PWR.Hsub_proxy_kJkg, PWR.PM_F1);
[PWR_resid.PM_F1_pred_TsubOnly, PWR_resid.PM_F1_resid_TsubOnly] = simplePredictResidual(PWR.Tsub, PWR.PM_F1);

[PWR_resid.PM_noF1_pred_HsubTrueOnly, PWR_resid.PM_noF1_resid_HsubTrueOnly] = simplePredictResidual(PWR.Hsub_true_kJkg, PWR.PM_noF1);

resid_by_table_LD = table();
for tbl = [10 11 12]
    for j = 1:numel(ldBands)
        m = PWR_resid.TableNo == tbl & PWR_resid.LD_band == ldBands(j);
        if any(m)
            resid_by_table_LD = [resid_by_table_LD; makeResidStats("T" + string(tbl), ldBands(j), PWR_resid(m,:))]; %#ok<AGROW>
        end
    end
end

resid_pair_summary = table();
for tbl = [11 12]
    S = PWR_resid(PWR_resid.TableNo == tbl & PWR_resid.LD_band == "short_anchor", :);
    L = PWR_resid(PWR_resid.TableNo == tbl & PWR_resid.LD_band == "long", :);

    if ~isempty(S) && ~isempty(L)
        resid_pair_summary = [resid_pair_summary; makeResidPairSummary(tbl, S, L)]; %#ok<AGROW>
    end
end

%% ===== Table10 baseline comparison =====
T10_short = PWR(PWR.TableNo == 10 & PWR.LD_band == "short_anchor", :);
T11_long  = PWR(PWR.TableNo == 11 & PWR.LD_band == "long", :);
T12_long  = PWR(PWR.TableNo == 12 & PWR.LD_band == "long", :);

baseline_contrast = table();
baseline_contrast = [baseline_contrast; makeContrast("T10_short_baseline", T10_short, "T11_long", T11_long)]; %#ok<AGROW>
baseline_contrast = [baseline_contrast; makeContrast("T10_short_baseline", T10_short, "T12_long", T12_long)]; %#ok<AGROW>

%% ===== proxy vs true 比較 =====
proxy_true_by_table_LD = table();
for tbl = [10 11 12]
    for j = 1:numel(ldBands)
        m = PWR.TableNo == tbl & PWR.LD_band == ldBands(j);
        if any(m)
            proxy_true_by_table_LD = [proxy_true_by_table_LD; makeProxyTrueStats("T" + string(tbl), ldBands(j), PWR(m,:))]; %#ok<AGROW>
        end
    end
end

%% ===== Excel出力 =====
writetable(basic, outFile, "Sheet", "basic");
writetable(Hmap, outFile, "Sheet", "Hsub_mapping_used");
writetable(pwr_by_LD, outFile, "Sheet", "PWR_by_LD");
writetable(pwr_by_table_LD, outFile, "Sheet", "PWR_by_table_LD");
writetable(raw_pair_summary, outFile, "Sheet", "raw_short_long_pair");
writetable(modelCompare, outFile, "Sheet", "model_compare");
writetable(resid_by_table_LD, outFile, "Sheet", "resid_by_table_LD");
writetable(resid_pair_summary, outFile, "Sheet", "resid_short_long_pair");
writetable(proxy_true_by_table_LD, outFile, "Sheet", "proxy_vs_true_by_table_LD");
writetable(baseline_contrast, outFile, "Sheet", "T10_baseline_contrast");
writetable(PWR_resid, outFile, "Sheet", "PWR_rows_with_trueHsub");
writetable(J, outFile, "Sheet", "integrated_all_trueHsub");

%% ===== 図出力 =====

% PM_F1 vs true Hsub
fig1 = figure;
scatter(PWR.Hsub_true_kJkg, PWR.PM_F1, 40, "filled");
grid on; box on;
xlabel("True Hsub [kJ/kg]");
ylabel("PM ratio F1");
title("PWR-near Table 10-12: PM_F1 vs true Hsub");
exportgraphics(fig1, fullfile(outDir, "TM8_14_v8b_PM_F1_vs_trueHsub.png"), "Resolution", 200);

% PM_F1 residual after true Hsub vs L/D
fig2 = figure;
scatter(PWR_resid.LD_geom, PWR_resid.PM_F1_resid_HsubTrueOnly, 40, "filled");
grid on; box on;
xlabel("L/D");
ylabel("PM_F1 residual after true-Hsub-only fit");
title("PWR-near: true-Hsub residual vs L/D");
yline(0, "k--");
exportgraphics(fig2, fullfile(outDir, "TM8_14_v8b_trueHsubResid_vs_LD.png"), "Resolution", 200);

% Table/L-D別 true Hsub residual
fig3 = figure;
bar(categorical(resid_by_table_LD.GroupValue), resid_by_table_LD.Mean_resid_PM_F1_HsubTrueOnly);
grid on; box on;
xlabel("Table / L-D band");
ylabel("Mean residual PM_F1 after true-Hsub fit");
title("PWR-near: true-Hsub residual by Table/L-D");
xtickangle(45);
yline(0, "k--");
exportgraphics(fig3, fullfile(outDir, "TM8_14_v8b_mean_trueHsubResid_byTableLD.png"), "Resolution", 200);

% Hsub proxy vs true
fig4 = figure;
scatter(PWR.Hsub_true_kJkg, PWR.Hsub_proxy_kJkg, 40, "filled");
grid on; box on;
xlabel("True Hsub [kJ/kg]");
ylabel("Hsub proxy = CPL*Tsub [kJ/kg]");
title("PWR-near: Hsub proxy vs true Hsub");
hold on;
minv = min([PWR.Hsub_true_kJkg; PWR.Hsub_proxy_kJkg], [], "omitnan");
maxv = max([PWR.Hsub_true_kJkg; PWR.Hsub_proxy_kJkg], [], "omitnan");
plot([minv maxv], [minv maxv], "k--");
exportgraphics(fig4, fullfile(outDir, "TM8_14_v8b_HsubProxy_vs_trueHsub.png"), "Resolution", 200);

%% ===== 表示 =====
disp("=== basic ===");
disp(basic);

disp("=== PWR by table/L-D ===");
disp(pwr_by_table_LD);

disp("=== model compare ===");
disp(modelCompare);

disp("=== residual short-long pair ===");
disp(resid_pair_summary);

disp("=== proxy vs true by table/L-D ===");
disp(proxy_true_by_table_LD);

fprintf("\nDone.\n");
fprintf("Excel output:\n  %s\n", outFile);
fprintf("PNG outputs are in:\n  %s\n", outDir);

%% ===== ローカル関数 =====

function S = makeStats(groupType, groupValue, X)
    S = table( ...
        string(groupType), string(groupValue), height(X), ...
        mean(X.PM_noF1, "omitnan"), median(X.PM_noF1, "omitnan"), std(X.PM_noF1, "omitnan"), ...
        mean(X.PM_F1, "omitnan"), median(X.PM_F1, "omitnan"), std(X.PM_F1, "omitnan"), ...
        mean(X.Hsub_true_kJkg, "omitnan"), min(X.Hsub_true_kJkg, [], "omitnan"), max(X.Hsub_true_kJkg, [], "omitnan"), ...
        mean(X.Hsub_proxy_kJkg, "omitnan"), min(X.Hsub_proxy_kJkg, [], "omitnan"), max(X.Hsub_proxy_kJkg, [], "omitnan"), ...
        mean(X.Tsub, "omitnan"), min(X.Tsub, [], "omitnan"), max(X.Tsub, [], "omitnan"), ...
        mean(X.LD_geom, "omitnan"), min(X.LD_geom, [], "omitnan"), max(X.LD_geom, [], "omitnan"), ...
        mean(X.Tin, "omitnan"), min(X.Tin, [], "omitnan"), max(X.Tin, [], "omitnan"), ...
        mean(X.x_Mes, "omitnan"), mean(X.qM, "omitnan")/1e6, mean(X.G, "omitnan"), mean(X.P_MPa, "omitnan"), ...
        'VariableNames', ["GroupType", "GroupValue", "N", ...
                          "Mean_PM_noF1", "Median_PM_noF1", "Std_PM_noF1", ...
                          "Mean_PM_F1", "Median_PM_F1", "Std_PM_F1", ...
                          "Mean_HsubTrue_kJkg", "Min_HsubTrue_kJkg", "Max_HsubTrue_kJkg", ...
                          "Mean_HsubProxy_kJkg", "Min_HsubProxy_kJkg", "Max_HsubProxy_kJkg", ...
                          "Mean_Tsub", "Min_Tsub", "Max_Tsub", ...
                          "Mean_LD", "Min_LD", "Max_LD", ...
                          "Mean_Tin", "Min_Tin", "Max_Tin", ...
                          "Mean_xMes", "Mean_qM_MW_m2", "Mean_G", "Mean_P_MPa"] ...
    );
end

function S = makeRawPairSummary(tbl, Short, Long)
    S = table( ...
        tbl, height(Short), height(Long), ...
        mean(Short.PM_F1, "omitnan"), mean(Long.PM_F1, "omitnan"), ...
        mean(Long.PM_F1, "omitnan") - mean(Short.PM_F1, "omitnan"), ...
        mean(Long.PM_F1, "omitnan") / mean(Short.PM_F1, "omitnan"), ...
        mean(Short.Hsub_true_kJkg, "omitnan"), mean(Long.Hsub_true_kJkg, "omitnan"), ...
        mean(Long.Hsub_true_kJkg, "omitnan") - mean(Short.Hsub_true_kJkg, "omitnan"), ...
        mean(Short.Tsub, "omitnan"), mean(Long.Tsub, "omitnan"), ...
        mean(Long.Tsub, "omitnan") - mean(Short.Tsub, "omitnan"), ...
        mean(Short.LD_geom, "omitnan"), mean(Long.LD_geom, "omitnan"), ...
        mean(Long.LD_geom, "omitnan") - mean(Short.LD_geom, "omitnan"), ...
        'VariableNames', ["TableNo", "N_short", "N_long", ...
                          "Mean_PM_F1_short", "Mean_PM_F1_long", ...
                          "Delta_PM_F1_long_minus_short", "Ratio_PM_F1_long_over_short", ...
                          "Mean_HsubTrue_short", "Mean_HsubTrue_long", "Delta_HsubTrue_long_minus_short", ...
                          "Mean_Tsub_short", "Mean_Tsub_long", "Delta_Tsub_long_minus_short", ...
                          "Mean_LD_short", "Mean_LD_long", "Delta_LD_long_minus_short"] ...
    );
end

function S = makeResidStats(tableLabel, bandLabel, X)
    S = table( ...
        string(tableLabel), string(bandLabel), height(X), ...
        mean(X.PM_F1_resid_HsubTrueOnly, "omitnan"), median(X.PM_F1_resid_HsubTrueOnly, "omitnan"), ...
        mean(X.PM_F1_resid_HsubProxyOnly, "omitnan"), median(X.PM_F1_resid_HsubProxyOnly, "omitnan"), ...
        mean(X.PM_F1_resid_TsubOnly, "omitnan"), median(X.PM_F1_resid_TsubOnly, "omitnan"), ...
        mean(X.PM_noF1_resid_HsubTrueOnly, "omitnan"), median(X.PM_noF1_resid_HsubTrueOnly, "omitnan"), ...
        'VariableNames', ["TableLabel", "LD_band", "N", ...
                          "Mean_resid_PM_F1_HsubTrueOnly", "Median_resid_PM_F1_HsubTrueOnly", ...
                          "Mean_resid_PM_F1_HsubProxyOnly", "Median_resid_PM_F1_HsubProxyOnly", ...
                          "Mean_resid_PM_F1_TsubOnly", "Median_resid_PM_F1_TsubOnly", ...
                          "Mean_resid_PM_noF1_HsubTrueOnly", "Median_resid_PM_noF1_HsubTrueOnly"] ...
    );
end

function S = makeResidPairSummary(tbl, Short, Long)
    S = table( ...
        tbl, height(Short), height(Long), ...
        mean(Short.PM_F1_resid_HsubTrueOnly, "omitnan"), mean(Long.PM_F1_resid_HsubTrueOnly, "omitnan"), ...
        mean(Long.PM_F1_resid_HsubTrueOnly, "omitnan") - mean(Short.PM_F1_resid_HsubTrueOnly, "omitnan"), ...
        mean(Short.PM_F1_resid_HsubProxyOnly, "omitnan"), mean(Long.PM_F1_resid_HsubProxyOnly, "omitnan"), ...
        mean(Long.PM_F1_resid_HsubProxyOnly, "omitnan") - mean(Short.PM_F1_resid_HsubProxyOnly, "omitnan"), ...
        mean(Short.PM_F1_resid_TsubOnly, "omitnan"), mean(Long.PM_F1_resid_TsubOnly, "omitnan"), ...
        mean(Long.PM_F1_resid_TsubOnly, "omitnan") - mean(Short.PM_F1_resid_TsubOnly, "omitnan"), ...
        'VariableNames', ["TableNo", "N_short", "N_long", ...
                          "Mean_resid_F1_HsubTrue_short", "Mean_resid_F1_HsubTrue_long", "Delta_resid_F1_HsubTrue_long_minus_short", ...
                          "Mean_resid_F1_HsubProxy_short", "Mean_resid_F1_HsubProxy_long", "Delta_resid_F1_HsubProxy_long_minus_short", ...
                          "Mean_resid_F1_Tsub_short", "Mean_resid_F1_Tsub_long", "Delta_resid_F1_Tsub_long_minus_short"] ...
    );
end

function S = makeProxyTrueStats(tableLabel, bandLabel, X)
    S = table( ...
        string(tableLabel), string(bandLabel), height(X), ...
        mean(X.Hsub_true_kJkg, "omitnan"), mean(X.Hsub_proxy_kJkg, "omitnan"), ...
        mean(X.Hsub_proxy_minus_true_kJkg, "omitnan"), ...
        mean(X.Hsub_proxy_over_true, "omitnan"), ...
        median(X.Hsub_proxy_over_true, "omitnan"), ...
        'VariableNames', ["TableLabel", "LD_band", "N", ...
                          "Mean_HsubTrue_kJkg", "Mean_HsubProxy_kJkg", ...
                          "Mean_ProxyMinusTrue_kJkg", "Mean_ProxyOverTrue", "Median_ProxyOverTrue"] ...
    );
end

function S = makeContrast(baseName, Base, targetName, Target)
    if isempty(Base) || isempty(Target)
        S = table(string(baseName), string(targetName), height(Base), height(Target), ...
            NaN, NaN, NaN, NaN, NaN, NaN, ...
            'VariableNames', ["BaseGroup", "TargetGroup", "N_base", "N_target", ...
                              "Mean_PM_F1_base", "Mean_PM_F1_target", "Delta_PM_F1_target_minus_base", ...
                              "Mean_HsubTrue_base", "Mean_HsubTrue_target", "Delta_HsubTrue_target_minus_base"]);
        return;
    end

    S = table( ...
        string(baseName), string(targetName), height(Base), height(Target), ...
        mean(Base.PM_F1, "omitnan"), mean(Target.PM_F1, "omitnan"), ...
        mean(Target.PM_F1, "omitnan") - mean(Base.PM_F1, "omitnan"), ...
        mean(Base.Hsub_true_kJkg, "omitnan"), mean(Target.Hsub_true_kJkg, "omitnan"), ...
        mean(Target.Hsub_true_kJkg, "omitnan") - mean(Base.Hsub_true_kJkg, "omitnan"), ...
        'VariableNames', ["BaseGroup", "TargetGroup", "N_base", "N_target", ...
                          "Mean_PM_F1_base", "Mean_PM_F1_target", "Delta_PM_F1_target_minus_base", ...
                          "Mean_HsubTrue_base", "Mean_HsubTrue_target", "Delta_HsubTrue_target_minus_base"] ...
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