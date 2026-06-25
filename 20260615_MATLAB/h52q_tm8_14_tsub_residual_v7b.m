%% h52q_tm8_14_tsub_residual_v7b.m
% H52Q / T&M Table 8-14
% v7b: TsubでPMを正規化・残差診断する。
%
% 目的:
%   PWR_near = Table 10-12 に対して、
%   Tsubで説明できるPM差を取り除いたあとも
%   long側に正残差が残るかを確認する。
%
% 入力:
%   20260612_計算結果比較r8_staging_TM8_14_v1.xlsx
%
% 出力:
%   out_TM8_14/TM8_14_tsub_residual_v7b_yyyymmdd_HHMMSS.xlsx
%   out_TM8_14/TM8_14_v7b_*.png

clear; clc; close all;

%% ===== 設定 =====
inFile = fullfile(pwd, "20260612_計算結果比較r8_staging_TM8_14_v1.xlsx");

sheetNoF1 = "SRC_tm_r123_noF1_T8_14";
sheetF1   = "SRC_tm_r124_F1_T8_14";

outDir = fullfile(pwd, "out_TM8_14");
if ~exist(outDir, "dir")
    mkdir(outDir);
end

timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outFile = fullfile(outDir, "TM8_14_tsub_residual_v7b_" + timestamp + ".xlsx");

fprintf("Input : %s\n", inFile);
fprintf("Output: %s\n\n", outFile);

%% ===== 読み込み =====
opts0 = detectImportOptions(inFile, "Sheet", sheetNoF1, "VariableNamingRule", "preserve");
opts1 = detectImportOptions(inFile, "Sheet", sheetF1,   "VariableNamingRule", "preserve");

R0 = readtable(inFile, opts0);
R1 = readtable(inFile, opts1);

T0 = standardizeTmTable(R0, "noF1");
T1 = standardizeTmTable(R1, "F1");

T0 = T0(~ismissing(T0.No_TableNo) & ~isnan(T0.TableNo), :);
T1 = T1(~ismissing(T1.No_TableNo) & ~isnan(T1.TableNo), :);

%% ===== noF1/F1結合 =====
T0j = T0(:, ["No_TableNo", "source_row_in_tm", "data_origin", ...
             "TableNo", "P_Pa", "P_MPa", "G", "DH", "L", ...
             "LD_geom", "LD_band", "P_band_v6", ...
             "Ts", "Tin", "Tsub", "Tsub2", "CPL", "Hsub_proxy_kJkg", ...
             "x_Mes", "qM", "qP", "PM"]);

T1j = T1(:, ["No_TableNo", "source_row_in_tm", "data_origin", ...
             "qP", "PM"]);

T0j.Properties.VariableNames = { ...
    'No_TableNo', ...
    'source_row_in_tm_noF1', ...
    'data_origin_noF1', ...
    'TableNo', ...
    'P_Pa', ...
    'P_MPa', ...
    'G', ...
    'DH', ...
    'L', ...
    'LD_geom', ...
    'LD_band', ...
    'P_band_v6', ...
    'Ts', ...
    'Tin', ...
    'Tsub', ...
    'Tsub2', ...
    'CPL', ...
    'Hsub_proxy_kJkg', ...
    'x_Mes', ...
    'qM', ...
    'qP_noF1', ...
    'PM_noF1'};

T1j.Properties.VariableNames = { ...
    'No_TableNo', ...
    'source_row_in_tm_F1', ...
    'data_origin_F1', ...
    'qP_F1', ...
    'PM_F1'};

C = innerjoin(T0j, T1j, "Keys", "No_TableNo");

C.dPM = C.PM_F1 - C.PM_noF1;
C.dPM_percent = 100 * C.dPM ./ C.PM_noF1;

%% ===== PWR近傍主解析群 =====
PWR = C(C.P_band_v6 == "PWR_near" & ismember(C.TableNo, [10; 11; 12]), :);
PWR = sortrows(PWR, ["TableNo", "LD_geom", "Tsub"]);

%% ===== 基本確認 =====
basic = table( ...
    ["total_joined"; ...
     "PWR_rows"; ...
     "PWR_Table10_rows"; ...
     "PWR_Table11_rows"; ...
     "PWR_Table12_rows"; ...
     "Tsub_missing_PWR"; ...
     "Hsub_proxy_missing_PWR"], ...
    [height(C); ...
     height(PWR); ...
     sum(PWR.TableNo == 10); ...
     sum(PWR.TableNo == 11); ...
     sum(PWR.TableNo == 12); ...
     sum(isnan(PWR.Tsub)); ...
     sum(isnan(PWR.Hsub_proxy_kJkg))], ...
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

%% ===== short-long生比較 =====
raw_pair_summary = table();
for tbl = [11 12]
    S = PWR(PWR.TableNo == tbl & PWR.LD_band == "short_anchor", :);
    L = PWR(PWR.TableNo == tbl & PWR.LD_band == "long", :);

    if ~isempty(S) && ~isempty(L)
        raw_pair_summary = [raw_pair_summary; makeRawPairSummary(tbl, S, L)]; %#ok<AGROW>
    end
end

%% ===== 単純モデル比較 =====
modelCompare = table();

modelCompare = [modelCompare; makeModelRow("PM_F1", "Tsub_only", PWR.Tsub, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "Hsub_proxy_only", PWR.Hsub_proxy_kJkg, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "LD_only", PWR.LD_geom, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "xMes_only", PWR.x_Mes, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "P_only", PWR.P_MPa, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "G_only", PWR.G, PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "qM_only", PWR.qM, PWR.PM_F1)];

modelCompare = [modelCompare; makeModelRow("PM_F1", "Tsub_LD", [PWR.Tsub, PWR.LD_geom], PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "HsubProxy_LD", [PWR.Hsub_proxy_kJkg, PWR.LD_geom], PWR.PM_F1)];
modelCompare = [modelCompare; makeModelRow("PM_F1", "Tsub_LD_xMes_P", [PWR.Tsub, PWR.LD_geom, PWR.x_Mes, PWR.P_MPa], PWR.PM_F1)];

modelCompare = [modelCompare; makeModelRow("PM_noF1", "Tsub_only", PWR.Tsub, PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "Hsub_proxy_only", PWR.Hsub_proxy_kJkg, PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "LD_only", PWR.LD_geom, PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "Tsub_LD", [PWR.Tsub, PWR.LD_geom], PWR.PM_noF1)];
modelCompare = [modelCompare; makeModelRow("PM_noF1", "HsubProxy_LD", [PWR.Hsub_proxy_kJkg, PWR.LD_geom], PWR.PM_noF1)];

%% ===== Tsub/Hsub_proxy 残差 =====
PWR_resid = PWR;

[PWR_resid.PM_F1_pred_TsubOnly, PWR_resid.PM_F1_resid_TsubOnly] = simplePredictResidual(PWR.Tsub, PWR.PM_F1);
[PWR_resid.PM_F1_pred_HsubProxyOnly, PWR_resid.PM_F1_resid_HsubProxyOnly] = simplePredictResidual(PWR.Hsub_proxy_kJkg, PWR.PM_F1);

[PWR_resid.PM_noF1_pred_TsubOnly, PWR_resid.PM_noF1_resid_TsubOnly] = simplePredictResidual(PWR.Tsub, PWR.PM_noF1);
[PWR_resid.PM_noF1_pred_HsubProxyOnly, PWR_resid.PM_noF1_resid_HsubProxyOnly] = simplePredictResidual(PWR.Hsub_proxy_kJkg, PWR.PM_noF1);

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

%% ===== T10 short基準との比較 =====
T10_short = PWR(PWR.TableNo == 10 & PWR.LD_band == "short_anchor", :);
T11_long  = PWR(PWR.TableNo == 11 & PWR.LD_band == "long", :);
T12_long  = PWR(PWR.TableNo == 12 & PWR.LD_band == "long", :);

baseline_contrast = table();
baseline_contrast = [baseline_contrast; makeContrast("T10_short_baseline", T10_short, "T11_long", T11_long)]; %#ok<AGROW>
baseline_contrast = [baseline_contrast; makeContrast("T10_short_baseline", T10_short, "T12_long", T12_long)]; %#ok<AGROW>

%% ===== Excel出力 =====
writetable(basic, outFile, "Sheet", "basic");
writetable(pwr_by_LD, outFile, "Sheet", "PWR_by_LD");
writetable(pwr_by_table_LD, outFile, "Sheet", "PWR_by_table_LD");
writetable(raw_pair_summary, outFile, "Sheet", "raw_short_long_pair");
writetable(modelCompare, outFile, "Sheet", "model_compare");
writetable(resid_by_table_LD, outFile, "Sheet", "resid_by_table_LD");
writetable(resid_pair_summary, outFile, "Sheet", "resid_short_long_pair");
writetable(baseline_contrast, outFile, "Sheet", "T10_baseline_contrast");
writetable(PWR_resid, outFile, "Sheet", "PWR_rows_with_resid");
writetable(C, outFile, "Sheet", "integrated_with_Tsub");

%% ===== 図出力 =====

% 1. PM_F1 vs Tsub
fig1 = figure;
scatter(PWR.Tsub, PWR.PM_F1, 40, "filled");
grid on; box on;
xlabel("Tsub = Ts - Tin [K]");
ylabel("PM ratio F1");
title("PWR-near Table 10-12: PM_F1 vs Tsub");
exportgraphics(fig1, fullfile(outDir, "TM8_14_v7b_PM_F1_vs_Tsub.png"), "Resolution", 200);

% 2. PM_F1 vs Hsub_proxy
fig2 = figure;
scatter(PWR.Hsub_proxy_kJkg, PWR.PM_F1, 40, "filled");
grid on; box on;
xlabel("Hsub proxy = CPL*Tsub [kJ/kg]");
ylabel("PM ratio F1");
title("PWR-near Table 10-12: PM_F1 vs Hsub proxy");
exportgraphics(fig2, fullfile(outDir, "TM8_14_v7b_PM_F1_vs_HsubProxy.png"), "Resolution", 200);

% 3. Tsub-only residual vs L/D
fig3 = figure;
scatter(PWR_resid.LD_geom, PWR_resid.PM_F1_resid_TsubOnly, 40, "filled");
grid on; box on;
xlabel("L/D");
ylabel("PM_F1 residual after Tsub-only fit");
title("PWR-near: Tsub-only residual vs L/D");
yline(0, "k--");
exportgraphics(fig3, fullfile(outDir, "TM8_14_v7b_TsubResid_vs_LD.png"), "Resolution", 200);

% 4. Hsub proxy residual vs L/D
fig4 = figure;
scatter(PWR_resid.LD_geom, PWR_resid.PM_F1_resid_HsubProxyOnly, 40, "filled");
grid on; box on;
xlabel("L/D");
ylabel("PM_F1 residual after Hsub-proxy-only fit");
title("PWR-near: Hsub proxy residual vs L/D");
yline(0, "k--");
exportgraphics(fig4, fullfile(outDir, "TM8_14_v7b_HsubProxyResid_vs_LD.png"), "Resolution", 200);

% 5. Table/L-D別 残差平均
fig5 = figure;
bar(categorical(resid_by_table_LD.GroupValue), resid_by_table_LD.Mean_resid_PM_F1_TsubOnly);
grid on; box on;
xlabel("Table / L-D band");
ylabel("Mean PM_F1 residual after Tsub-only fit");
title("PWR-near: Mean Tsub-only residual by Table/L-D");
xtickangle(45);
yline(0, "k--");
exportgraphics(fig5, fullfile(outDir, "TM8_14_v7b_mean_TsubResid_byTableLD.png"), "Resolution", 200);

%% ===== 表示 =====
disp("=== basic ===");
disp(basic);

disp("=== PWR by table/L-D ===");
disp(pwr_by_table_LD);

disp("=== model compare ===");
disp(modelCompare);

disp("=== residual short-long pair ===");
disp(resid_pair_summary);

fprintf("\nDone.\n");
fprintf("Excel output:\n  %s\n", outFile);
fprintf("PNG outputs are in:\n  %s\n", outDir);

%% ===== ローカル関数 =====

function T = standardizeTmTable(R, variant)
    key  = string(getcol(R, ["No_TableNo", "No TableNo", "NoTableNo", "ExptNo_TableNo"]));
    P    = tonum(getcol(R, ["P"]));
    G    = tonum(getcol(R, ["G"]));
    DH   = tonum(getcol(R, ["DH", "D", "D_m"]));
    L    = tonum(getcol(R, ["L", "L_DNB"]));
    Ts   = tonum(getcol(R, ["Ts", "T_sat", "Tsat"]));
    Tin  = tonum(getcol(R, ["Tin"]));
    Tsub = tonum(getcol(R, ["Tsub"]));
    Tsub2 = tonum(getcol(R, ["Tsub2"]));
    CPL  = tonum(getcol(R, ["CPL", "CpL", "cpL"]));
    xMes = tonum(getcol(R, ["x_Mes", "x Mes", "xMes"]));
    qM   = tonum(getcol(R, ["q_M", "qM"]));
    qP   = tonum(getcol(R, ["q_P", "qP"]));
    PM   = tonum(getcol(R, ["PM_ratio", "PM ratio", "PM"]));

    n = height(R);

    T = table();
    T.No_TableNo = key;
    T.source_row_in_tm = (1:n)' + 1;
    T.variant = repmat(string(variant), n, 1);
    T.data_origin = strings(n,1);

    T.TableNo = parseTableNo(key);
    T.P_Pa = P;
    T.P_MPa = P ./ 1e6;
    T.P_band_v6 = classifyPressureV6(T.P_MPa);
    T.G = G;
    T.DH = DH;
    T.L = L;
    T.LD_geom = L ./ DH;
    T.LD_band = classifyLD(T.LD_geom);

    T.Ts = Ts;
    T.Tin = Tin;
    T.Tsub = Tsub;
    T.Tsub2 = Tsub2;
    T.CPL = CPL;

    % Hsub明示列が無いため、暫定proxyとして CPL*Tsub を使う。
    % CPL[J/kg/K] * Tsub[K] = J/kg → kJ/kg
    T.Hsub_proxy_kJkg = CPL .* Tsub ./ 1000;

    T.x_Mes = xMes;
    T.qM = qM;
    T.qP = qP;
    T.PM = PM;

    T.data_origin(T.source_row_in_tm >= 88 & T.source_row_in_tm <= 225) = "added_138";
    T.data_origin(T.data_origin == "") = "existing_pre_add";
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

function s = normalizeName(x)
    s = lower(string(x));
    s = regexprep(s, "[\s_()\-/\.]", "");
end

function x = tonum(v)
    if isnumeric(v)
        x = double(v);
    elseif iscell(v)
        x = str2double(string(v));
    elseif isstring(v) || ischar(v)
        x = str2double(string(v));
    else
        x = str2double(string(v));
    end
end

function tableNo = parseTableNo(key)
    tableNo = nan(size(key));
    for i = 1:numel(key)
        token = regexp(key(i), "_(\d+)$", "tokens", "once");
        if ~isempty(token)
            tableNo(i) = str2double(token{1});
        end
    end
end

function band = classifyLD(LD)
    band = strings(size(LD));

    band(LD < 40) = "outside_low";
    band(LD >= 40 & LD <= 100) = "short_anchor";
    band(LD > 100 & LD < 250) = "middle";
    band(LD >= 250 & LD <= 400) = "long";
    band(LD > 400) = "outside_high";
    band(isnan(LD)) = "missing";
end

function band = classifyPressureV6(P)
    band = strings(size(P));
    band(P >= 10 & P < 13) = "explore_low";
    band(P >= 13 & P <= 17.5) = "PWR_near";
    band(P > 17.5 & P <= 20) = "high_check";
    band((P < 10 | P > 20) & ~isnan(P)) = "outside_pressure";
    band(isnan(P)) = "missing";
end

function S = makeStats(groupType, groupValue, X)
    S = table( ...
        string(groupType), string(groupValue), height(X), ...
        mean(X.PM_noF1, "omitnan"), median(X.PM_noF1, "omitnan"), std(X.PM_noF1, "omitnan"), ...
        mean(X.PM_F1, "omitnan"), median(X.PM_F1, "omitnan"), std(X.PM_F1, "omitnan"), ...
        mean(X.Tsub, "omitnan"), min(X.Tsub, [], "omitnan"), max(X.Tsub, [], "omitnan"), ...
        mean(X.Hsub_proxy_kJkg, "omitnan"), min(X.Hsub_proxy_kJkg, [], "omitnan"), max(X.Hsub_proxy_kJkg, [], "omitnan"), ...
        mean(X.LD_geom, "omitnan"), min(X.LD_geom, [], "omitnan"), max(X.LD_geom, [], "omitnan"), ...
        mean(X.Tin, "omitnan"), min(X.Tin, [], "omitnan"), max(X.Tin, [], "omitnan"), ...
        mean(X.x_Mes, "omitnan"), min(X.x_Mes, [], "omitnan"), max(X.x_Mes, [], "omitnan"), ...
        mean(X.qM, "omitnan")/1e6, min(X.qM, [], "omitnan")/1e6, max(X.qM, [], "omitnan")/1e6, ...
        mean(X.G, "omitnan"), mean(X.P_MPa, "omitnan"), ...
        'VariableNames', ["GroupType", "GroupValue", "N", ...
                          "Mean_PM_noF1", "Median_PM_noF1", "Std_PM_noF1", ...
                          "Mean_PM_F1", "Median_PM_F1", "Std_PM_F1", ...
                          "Mean_Tsub", "Min_Tsub", "Max_Tsub", ...
                          "Mean_HsubProxy_kJkg", "Min_HsubProxy_kJkg", "Max_HsubProxy_kJkg", ...
                          "Mean_LD", "Min_LD", "Max_LD", ...
                          "Mean_Tin", "Min_Tin", "Max_Tin", ...
                          "Mean_xMes", "Min_xMes", "Max_xMes", ...
                          "Mean_qM_MW_m2", "Min_qM_MW_m2", "Max_qM_MW_m2", ...
                          "Mean_G", "Mean_P_MPa"] ...
    );
end

function S = makeRawPairSummary(tbl, Short, Long)
    S = table( ...
        tbl, height(Short), height(Long), ...
        mean(Short.PM_F1, "omitnan"), mean(Long.PM_F1, "omitnan"), ...
        mean(Long.PM_F1, "omitnan") - mean(Short.PM_F1, "omitnan"), ...
        mean(Long.PM_F1, "omitnan") / mean(Short.PM_F1, "omitnan"), ...
        mean(Short.Tsub, "omitnan"), mean(Long.Tsub, "omitnan"), ...
        mean(Long.Tsub, "omitnan") - mean(Short.Tsub, "omitnan"), ...
        mean(Short.Hsub_proxy_kJkg, "omitnan"), mean(Long.Hsub_proxy_kJkg, "omitnan"), ...
        mean(Long.Hsub_proxy_kJkg, "omitnan") - mean(Short.Hsub_proxy_kJkg, "omitnan"), ...
        mean(Short.LD_geom, "omitnan"), mean(Long.LD_geom, "omitnan"), ...
        mean(Long.LD_geom, "omitnan") - mean(Short.LD_geom, "omitnan"), ...
        'VariableNames', ["TableNo", "N_short", "N_long", ...
                          "Mean_PM_F1_short", "Mean_PM_F1_long", ...
                          "Delta_PM_F1_long_minus_short", "Ratio_PM_F1_long_over_short", ...
                          "Mean_Tsub_short", "Mean_Tsub_long", "Delta_Tsub_long_minus_short", ...
                          "Mean_HsubProxy_short", "Mean_HsubProxy_long", "Delta_HsubProxy_long_minus_short", ...
                          "Mean_LD_short", "Mean_LD_long", "Delta_LD_long_minus_short"] ...
    );
end

function S = makeContrast(baseName, Base, targetName, Target)
    if isempty(Base) || isempty(Target)
        S = table(string(baseName), string(targetName), height(Base), height(Target), ...
            NaN, NaN, NaN, NaN, NaN, NaN, ...
            'VariableNames', ["BaseGroup", "TargetGroup", "N_base", "N_target", ...
                              "Mean_PM_F1_base", "Mean_PM_F1_target", "Delta_PM_F1_target_minus_base", ...
                              "Mean_Tsub_base", "Mean_Tsub_target", "Delta_Tsub_target_minus_base"]);
        return;
    end

    S = table( ...
        string(baseName), string(targetName), height(Base), height(Target), ...
        mean(Base.PM_F1, "omitnan"), mean(Target.PM_F1, "omitnan"), ...
        mean(Target.PM_F1, "omitnan") - mean(Base.PM_F1, "omitnan"), ...
        mean(Base.Tsub, "omitnan"), mean(Target.Tsub, "omitnan"), ...
        mean(Target.Tsub, "omitnan") - mean(Base.Tsub, "omitnan"), ...
        'VariableNames', ["BaseGroup", "TargetGroup", "N_base", "N_target", ...
                          "Mean_PM_F1_base", "Mean_PM_F1_target", "Delta_PM_F1_target_minus_base", ...
                          "Mean_Tsub_base", "Mean_Tsub_target", "Delta_Tsub_target_minus_base"] ...
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
        mean(X.PM_F1_resid_TsubOnly, "omitnan"), median(X.PM_F1_resid_TsubOnly, "omitnan"), ...
        mean(X.PM_F1_resid_HsubProxyOnly, "omitnan"), median(X.PM_F1_resid_HsubProxyOnly, "omitnan"), ...
        mean(X.PM_noF1_resid_TsubOnly, "omitnan"), median(X.PM_noF1_resid_TsubOnly, "omitnan"), ...
        'VariableNames', ["TableLabel", "LD_band", "N", ...
                          "Mean_resid_PM_F1_TsubOnly", "Median_resid_PM_F1_TsubOnly", ...
                          "Mean_resid_PM_F1_HsubProxyOnly", "Median_resid_PM_F1_HsubProxyOnly", ...
                          "Mean_resid_PM_noF1_TsubOnly", "Median_resid_PM_noF1_TsubOnly"] ...
    );
end

function S = makeResidPairSummary(tbl, Short, Long)
    S = table( ...
        tbl, height(Short), height(Long), ...
        mean(Short.PM_F1_resid_TsubOnly, "omitnan"), mean(Long.PM_F1_resid_TsubOnly, "omitnan"), ...
        mean(Long.PM_F1_resid_TsubOnly, "omitnan") - mean(Short.PM_F1_resid_TsubOnly, "omitnan"), ...
        mean(Short.PM_F1_resid_HsubProxyOnly, "omitnan"), mean(Long.PM_F1_resid_HsubProxyOnly, "omitnan"), ...
        mean(Long.PM_F1_resid_HsubProxyOnly, "omitnan") - mean(Short.PM_F1_resid_HsubProxyOnly, "omitnan"), ...
        'VariableNames', ["TableNo", "N_short", "N_long", ...
                          "Mean_resid_F1_Tsub_short", "Mean_resid_F1_Tsub_long", "Delta_resid_F1_Tsub_long_minus_short", ...
                          "Mean_resid_F1_HsubProxy_short", "Mean_resid_F1_HsubProxy_long", "Delta_resid_F1_HsubProxy_long_minus_short"] ...
    );
end