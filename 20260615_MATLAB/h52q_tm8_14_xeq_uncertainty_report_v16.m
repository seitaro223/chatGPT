%% h52q_tm8_14_xeq_uncertainty_report_v16.m
% H52Q / T&M Table 8-14
% v16: x_eq・不確かさ・Hsub関数形QC
%
% 目的:
%   r5で仮閉じしたT&M Table8-12数値診断について、
%   source01原本確認に入る前に、内部で潰せる論点を確認する。
%
% 確認項目:
%   1. x_Mesではなく、熱平衡クオリティ x_eq で再診断する。
%   2. Table9/11/12のshort-long残差に n, SD, SE, CI を付ける。
%   3. Hsub線形だけでなく、Hsub二次・三次でテール影響を確認する。
%   4. Table9 -> Table11 -> Table12の圧力順トレンドを確認する。
%   5. Table8 middleの低下が x_eq/P でも説明されるかを見る。
%
% 注意:
%   qMは結果側の量なので補正式候補には使わない。
%   x_Mesも補正式候補には使わない。
%   補正式候補として見る軸は x_eq。
%
% 入力:
%   out_TM8_14/TM8_14_explorelow_truehsub_v10_*.xlsx
%   Sheet: target_rows_T8_12
%
% 出力:
%   out_TM8_14/run_v16_xeq_uncertainty_yyyymmdd_HHMMSS/
%     run_report_v16_xeq_uncertainty_yyyymmdd_HHMMSS.md
%     summary_tables.xlsx
%     csv/*.csv

clear; clc; close all;

%% ===== 出力フォルダ =====
baseOut = fullfile(pwd, "out_TM8_14");
timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
runId = "v16_xeq_uncertainty_" + timestamp;

runDir = fullfile(baseOut, "run_" + runId);
csvDir = fullfile(runDir, "csv");

if ~exist(runDir, "dir"); mkdir(runDir); end
if ~exist(csvDir, "dir"); mkdir(csvDir); end

reportFile = fullfile(runDir, "run_report_" + runId + ".md");
xlsxFile = fullfile(runDir, "summary_tables.xlsx");

%% ===== 入力ファイル取得 =====
v10Files = dir(fullfile(baseOut, "TM8_14_explorelow_truehsub_v10_*.xlsx"));
if isempty(v10Files)
    error("v10 file not found: TM8_14_explorelow_truehsub_v10_*.xlsx");
end
[~, i10] = max([v10Files.datenum]);
v10File = fullfile(v10Files(i10).folder, v10Files(i10).name);

fprintf("v10 input: %s\n", v10File);
fprintf("run dir  : %s\n", runDir);

%% ===== 読み込み =====
T = readtable(v10File, "Sheet", "target_rows_T8_12", "VariableNamingRule", "preserve");

T.No_TableNo = string(T.No_TableNo);
T.LD_band = string(T.LD_band);
T.P_scope = string(T.P_scope);
T.SourceID = extractSourceID(T);

% qMは診断量としてだけ保持
if ismember("qM_MW_m2", string(T.Properties.VariableNames))
    % do nothing
elseif ismember("qM", string(T.Properties.VariableNames))
    T.qM_MW_m2 = T.qM ./ 1e6;
else
    T.qM_MW_m2 = nan(height(T), 1);
end

%% ===== x_eq列の検出 =====
xeqCandidates = [
    "x_eq", "xeq", "Xeq", "xEq", "x_EQ", ...
    "x_Equ", "x_equ", "xequ", "xEqu", ...
    "x_eq_CHF", "xeq_CHF", "x_eq_Mes", ...
    "xThermalEq", "x_thermal_eq", ...
    "thermal_equilibrium_quality", "ThermalEquilibriumQuality", ...
    "EquilibriumQuality", "x_equilibrium"
];

[xeqName, hasXeq] = findColumn(T, xeqCandidates, ["xeq", "x_eq", "equil", "equilibrium"]);

if hasXeq
    T.xeq_v16 = double(T.(xeqName));
else
    T.xeq_v16 = nan(height(T), 1);
end

% x_Mesは比較用。補正式候補には使わない。
if ismember("x_Mes", string(T.Properties.VariableNames))
    T.xMes_v16 = double(T.x_Mes);
else
    T.xMes_v16 = nan(height(T), 1);
end

%% ===== 列棚卸し =====
vars = string(T.Properties.VariableNames)';
columnInventory = table((1:numel(vars))', vars, ...
    'VariableNames', ["Index", "VariableName"]);

%% ===== basic =====
basic = table( ...
    ["all_rows_T8_12"; ...
     "has_xeq"; ...
     "x_eq_column_detected"; ...
     "missing_xeq"; ...
     "missing_PM_F1"; ...
     "missing_Hsub_true"; ...
     "missing_xMes"], ...
    [height(T); ...
     double(hasXeq); ...
     string(xeqName); ...
     string(sum(isnan(T.xeq_v16))); ...
     string(sum(isnan(T.PM_F1))); ...
     string(sum(isnan(T.Hsub_true_kJkg))); ...
     string(sum(isnan(T.xMes_v16)))], ...
    'VariableNames', ["Item", "Value"]);

%% ===== 対象1: source01 Table9-12 =====
S = T( ...
    T.SourceID == "01" & ...
    ismember(T.TableNo, [9 10 11 12]), :);

S = sortrows(S, ["TableNo", "LD_geom", "Hsub_true_kJkg"]);

S.isT9  = double(S.TableNo == 9);
S.isT10 = double(S.TableNo == 10);
S.isT11 = double(S.TableNo == 11);
S.isT12 = double(S.TableNo == 12);
S.isLong = double(S.LD_band == "long");
S.isShort = double(S.LD_band == "short_anchor");

%% ===== 対象2: Table8/9 explore_low =====
E = T(ismember(T.TableNo, [8 9]), :);
E = sortrows(E, ["TableNo", "LD_geom", "Hsub_true_kJkg"]);

E.isT8 = double(E.TableNo == 8);
E.isT9 = double(E.TableNo == 9);

%% ===== Hsub標準化 =====
S.Hsub_z = standardizeVec(S.Hsub_true_kJkg);
S.Hsub_z2 = S.Hsub_z.^2;
S.Hsub_z3 = S.Hsub_z.^3;

E.Hsub_z = standardizeVec(E.Hsub_true_kJkg);
E.Hsub_z2 = E.Hsub_z.^2;
E.Hsub_z3 = E.Hsub_z.^3;

%% ===== group summary =====
byTableLD_S = makeStats(S, ["TableNo", "LD_band", "P_scope"]);
byTable_S   = makeStats(S, ["TableNo", "P_scope"]);
byTableLD_E = makeStats(E, ["SourceID", "TableNo", "LD_band", "P_scope"]);

xeqXmes_S = makeXeqXmesStats(S, ["TableNo", "LD_band"]);
xeqXmes_E = makeXeqXmesStats(E, ["SourceID", "TableNo", "LD_band"]);

%% ===== モデル定義: source01 Table9-12 =====
modelDefsS = struct([]);

modelDefsS = addModel(modelDefsS, "Hsub_linear", ...
    S.Hsub_true_kJkg, ["Hsub_true"], "candidate_axis");

modelDefsS = addModel(modelDefsS, "Hsub_quad", ...
    [S.Hsub_z, S.Hsub_z2], ["Hsub_z", "Hsub_z2"], "function_form_check");

modelDefsS = addModel(modelDefsS, "Hsub_cubic", ...
    [S.Hsub_z, S.Hsub_z2, S.Hsub_z3], ["Hsub_z", "Hsub_z2", "Hsub_z3"], "function_form_check");

modelDefsS = addModel(modelDefsS, "Hsub_P", ...
    [S.Hsub_true_kJkg, S.P_MPa], ["Hsub_true", "P_MPa"], "candidate_axis");

if hasXeq
    modelDefsS = addModel(modelDefsS, "Hsub_xeq", ...
        [S.Hsub_true_kJkg, S.xeq_v16], ["Hsub_true", "x_eq"], "candidate_axis");

    modelDefsS = addModel(modelDefsS, "Hsub_P_xeq", ...
        [S.Hsub_true_kJkg, S.P_MPa, S.xeq_v16], ["Hsub_true", "P_MPa", "x_eq"], "candidate_axis");

    modelDefsS = addModel(modelDefsS, "Hsub_LD_P_xeq", ...
        [S.Hsub_true_kJkg, S.LD_geom, S.P_MPa, S.xeq_v16], ...
        ["Hsub_true", "LD", "P_MPa", "x_eq"], "LD_diagnostic_with_xeq");
else
    % x_eqがない場合でもレポートは出す。
end

modelDefsS = addModel(modelDefsS, "Hsub_LD", ...
    [S.Hsub_true_kJkg, S.LD_geom], ["Hsub_true", "LD"], "LD_diagnostic");

modelDefsS = addModel(modelDefsS, "Hsub_T12dummy", ...
    [S.Hsub_true_kJkg, S.isT12], ["Hsub_true", "isT12"], "table_diagnostic");

modelDefsS = addModel(modelDefsS, "Hsub_LD_T12dummy", ...
    [S.Hsub_true_kJkg, S.LD_geom, S.isT12], ["Hsub_true", "LD", "isT12"], "table_diagnostic");

% qMはDIAG_ONLY
modelDefsS = addModel(modelDefsS, "Hsub_qM_DIAG_ONLY", ...
    [S.Hsub_true_kJkg, S.qM_MW_m2], ["Hsub_true", "qM_MW_m2"], "diagnostic_only_not_correction");

%% ===== モデル計算: source01 Table9-12 =====
modelCompareS = table();
coefTableS = table();
Spred = S;

for k = 1:numel(modelDefsS)
    fit = fitLinearModel(modelDefsS(k).X, S.PM_F1, modelDefsS(k).varNames);
    modelCompareS = [modelCompareS; fit.summaryRow("PM_F1", modelDefsS(k).name, modelDefsS(k).Role)]; %#ok<AGROW>
    coefTableS = [coefTableS; fit.coefTable("PM_F1", modelDefsS(k).name, modelDefsS(k).Role)]; %#ok<AGROW>

    predName = matlab.lang.makeValidName("pred_" + modelDefsS(k).name);
    residName = matlab.lang.makeValidName("resid_" + modelDefsS(k).name);

    Spred.(predName) = fit.yhat;
    Spred.(residName) = fit.resid;
end

%% ===== 不確かさ: source01 Table9/11/12 short-long =====
pairUncertaintyS = table();
for tbl = [9 11 12]
    for k = 1:numel(modelDefsS)
        mName = modelDefsS(k).name;
        residName = matlab.lang.makeValidName("resid_" + mName);

        Short = Spred(Spred.TableNo == tbl & Spred.LD_band == "short_anchor", :);
        Long  = Spred(Spred.TableNo == tbl & Spred.LD_band == "long", :);

        if ~isempty(Short) && ~isempty(Long) && ismember(residName, string(Spred.Properties.VariableNames))
            pairUncertaintyS = [pairUncertaintyS; makePairUncertainty(tbl, mName, Short.(residName), Long.(residName), Short.P_MPa, Long.P_MPa)]; %#ok<AGROW>
        end
    end
end

%% ===== 圧力順トレンド =====
pressureTrendS = table();
trendModels = ["Hsub_linear", "Hsub_quad", "Hsub_cubic", "Hsub_LD"];

if hasXeq
    trendModels = [trendModels, "Hsub_P_xeq", "Hsub_LD_P_xeq"];
end

for mName = trendModels
    tmp = pairUncertaintyS(string(pairUncertaintyS.Model) == mName, :);
    if ~isempty(tmp)
        pressureTrendS = [pressureTrendS; tmp(:, ["TableNo", "Model", "Mean_P_all", "Delta_long_minus_short", "SE_delta", "CI95_low", "CI95_high"])]; %#ok<AGROW>
    end
end

%% ===== モデル定義: Table8/9 explore_low =====
modelDefsE = struct([]);

modelDefsE = addModel(modelDefsE, "Hsub_linear", ...
    E.Hsub_true_kJkg, ["Hsub_true"], "candidate_axis");

modelDefsE = addModel(modelDefsE, "Hsub_quad", ...
    [E.Hsub_z, E.Hsub_z2], ["Hsub_z", "Hsub_z2"], "function_form_check");

modelDefsE = addModel(modelDefsE, "Hsub_P", ...
    [E.Hsub_true_kJkg, E.P_MPa], ["Hsub_true", "P_MPa"], "candidate_axis");

if hasXeq
    modelDefsE = addModel(modelDefsE, "Hsub_xeq", ...
        [E.Hsub_true_kJkg, E.xeq_v16], ["Hsub_true", "x_eq"], "candidate_axis");

    modelDefsE = addModel(modelDefsE, "Hsub_P_xeq", ...
        [E.Hsub_true_kJkg, E.P_MPa, E.xeq_v16], ["Hsub_true", "P_MPa", "x_eq"], "candidate_axis");
end

modelDefsE = addModel(modelDefsE, "Hsub_LD", ...
    [E.Hsub_true_kJkg, E.LD_geom], ["Hsub_true", "LD"], "LD_diagnostic");

%% ===== モデル計算: Table8/9 =====
modelCompareE = table();
coefTableE = table();
Epred = E;

for k = 1:numel(modelDefsE)
    fit = fitLinearModel(modelDefsE(k).X, E.PM_F1, modelDefsE(k).varNames);
    modelCompareE = [modelCompareE; fit.summaryRow("PM_F1", modelDefsE(k).name, modelDefsE(k).Role)]; %#ok<AGROW>
    coefTableE = [coefTableE; fit.coefTable("PM_F1", modelDefsE(k).name, modelDefsE(k).Role)]; %#ok<AGROW>

    predName = matlab.lang.makeValidName("pred_" + modelDefsE(k).name);
    residName = matlab.lang.makeValidName("resid_" + modelDefsE(k).name);

    Epred.(predName) = fit.yhat;
    Epred.(residName) = fit.resid;
end

%% ===== Table8 middle vs Table9 all/short/long =====
T8middle = Epred(Epred.TableNo == 8 & Epred.LD_band == "middle", :);
T9all    = Epred(Epred.TableNo == 9, :);
T9short  = Epred(Epred.TableNo == 9 & Epred.LD_band == "short_anchor", :);
T9long   = Epred(Epred.TableNo == 9 & Epred.LD_band == "long", :);

T8contrast = table();
T8contrast = [T8contrast; makeGroupContrast("T8_middle", T8middle, "T9_all", T9all, modelDefsE)]; %#ok<AGROW>
T8contrast = [T8contrast; makeGroupContrast("T8_middle", T8middle, "T9_short", T9short, modelDefsE)]; %#ok<AGROW>
T8contrast = [T8contrast; makeGroupContrast("T8_middle", T8middle, "T9_long", T9long, modelDefsE)]; %#ok<AGROW>

%% ===== 主要値抽出 =====
r2_S_Hsub = getR2(modelCompareS, "Hsub_linear");
r2_S_HsubQuad = getR2(modelCompareS, "Hsub_quad");
r2_S_HsubCubic = getR2(modelCompareS, "Hsub_cubic");
r2_S_HsubLD = getR2(modelCompareS, "Hsub_LD");
r2_S_HsubPxeq = getR2(modelCompareS, "Hsub_P_xeq");
r2_S_HsubLDPxeq = getR2(modelCompareS, "Hsub_LD_P_xeq");

d9_Hsub = getDelta(pairUncertaintyS, 9, "Hsub_linear");
d11_Hsub = getDelta(pairUncertaintyS, 11, "Hsub_linear");
d12_Hsub = getDelta(pairUncertaintyS, 12, "Hsub_linear");

d9_HsubQuad = getDelta(pairUncertaintyS, 9, "Hsub_quad");
d11_HsubQuad = getDelta(pairUncertaintyS, 11, "Hsub_quad");
d12_HsubQuad = getDelta(pairUncertaintyS, 12, "Hsub_quad");

d9_Pxeq = getDelta(pairUncertaintyS, 9, "Hsub_P_xeq");
d11_Pxeq = getDelta(pairUncertaintyS, 11, "Hsub_P_xeq");
d12_Pxeq = getDelta(pairUncertaintyS, 12, "Hsub_P_xeq");

se12_Hsub = getSE(pairUncertaintyS, 12, "Hsub_linear");
ci12_low_Hsub = getCI(pairUncertaintyS, 12, "Hsub_linear", "low");
ci12_high_Hsub = getCI(pairUncertaintyS, 12, "Hsub_linear", "high");

t8diff_Hsub = getContrastResid(T8contrast, "T8_middle", "T9_all", "Hsub_linear");
t8diff_Pxeq = getContrastResid(T8contrast, "T8_middle", "T9_all", "Hsub_P_xeq");

%% ===== decision summary =====
decisionSummary = table( ...
    ["has_xeq"; ...
     "x_eq_column"; ...
     "R2_source01_Hsub_linear"; ...
     "R2_source01_Hsub_quad"; ...
     "R2_source01_Hsub_cubic"; ...
     "R2_source01_Hsub_LD"; ...
     "R2_source01_Hsub_P_xeq"; ...
     "R2_source01_Hsub_LD_P_xeq"; ...
     "T9_delta_Hsub_linear"; ...
     "T11_delta_Hsub_linear"; ...
     "T12_delta_Hsub_linear"; ...
     "T12_SE_delta_Hsub_linear"; ...
     "T12_CI95_low_Hsub_linear"; ...
     "T12_CI95_high_Hsub_linear"; ...
     "T9_delta_Hsub_quad"; ...
     "T11_delta_Hsub_quad"; ...
     "T12_delta_Hsub_quad"; ...
     "T9_delta_Hsub_P_xeq"; ...
     "T11_delta_Hsub_P_xeq"; ...
     "T12_delta_Hsub_P_xeq"; ...
     "T8middle_minus_T9all_resid_Hsub"; ...
     "T8middle_minus_T9all_resid_Hsub_P_xeq"], ...
    [string(hasXeq); ...
     string(xeqName); ...
     string(r2_S_Hsub); ...
     string(r2_S_HsubQuad); ...
     string(r2_S_HsubCubic); ...
     string(r2_S_HsubLD); ...
     string(r2_S_HsubPxeq); ...
     string(r2_S_HsubLDPxeq); ...
     string(d9_Hsub); ...
     string(d11_Hsub); ...
     string(d12_Hsub); ...
     string(se12_Hsub); ...
     string(ci12_low_Hsub); ...
     string(ci12_high_Hsub); ...
     string(d9_HsubQuad); ...
     string(d11_HsubQuad); ...
     string(d12_HsubQuad); ...
     string(d9_Pxeq); ...
     string(d11_Pxeq); ...
     string(d12_Pxeq); ...
     string(t8diff_Hsub); ...
     string(t8diff_Pxeq)], ...
    'VariableNames', ["Metric", "Value"]);

%% ===== 保存 =====
writetable(basic, xlsxFile, "Sheet", "basic");
writetable(columnInventory, xlsxFile, "Sheet", "column_inventory");
writetable(byTableLD_S, xlsxFile, "Sheet", "S_by_table_LD");
writetable(byTable_S, xlsxFile, "Sheet", "S_by_table");
writetable(xeqXmes_S, xlsxFile, "Sheet", "S_xeq_xmes");
writetable(modelCompareS, xlsxFile, "Sheet", "S_model_compare");
writetable(coefTableS, xlsxFile, "Sheet", "S_model_coefficients");
writetable(pairUncertaintyS, xlsxFile, "Sheet", "S_pair_uncertainty");
writetable(pressureTrendS, xlsxFile, "Sheet", "S_pressure_trend");
writetable(byTableLD_E, xlsxFile, "Sheet", "E_by_table_LD");
writetable(xeqXmes_E, xlsxFile, "Sheet", "E_xeq_xmes");
writetable(modelCompareE, xlsxFile, "Sheet", "E_model_compare");
writetable(coefTableE, xlsxFile, "Sheet", "E_model_coefficients");
writetable(T8contrast, xlsxFile, "Sheet", "E_T8_contrast");
writetable(decisionSummary, xlsxFile, "Sheet", "decision_summary");
writetable(Spred, xlsxFile, "Sheet", "S_rows_with_resid");
writetable(Epred, xlsxFile, "Sheet", "E_rows_with_resid");

writetable(basic, fullfile(csvDir, "basic.csv"));
writetable(columnInventory, fullfile(csvDir, "column_inventory.csv"));
writetable(byTableLD_S, fullfile(csvDir, "S_by_table_LD.csv"));
writetable(xeqXmes_S, fullfile(csvDir, "S_xeq_xmes.csv"));
writetable(modelCompareS, fullfile(csvDir, "S_model_compare.csv"));
writetable(pairUncertaintyS, fullfile(csvDir, "S_pair_uncertainty.csv"));
writetable(pressureTrendS, fullfile(csvDir, "S_pressure_trend.csv"));
writetable(byTableLD_E, fullfile(csvDir, "E_by_table_LD.csv"));
writetable(xeqXmes_E, fullfile(csvDir, "E_xeq_xmes.csv"));
writetable(modelCompareE, fullfile(csvDir, "E_model_compare.csv"));
writetable(T8contrast, fullfile(csvDir, "E_T8_contrast.csv"));
writetable(decisionSummary, fullfile(csvDir, "decision_summary.csv"));

%% ===== report作成 =====
fid = fopen(reportFile, "w", "n", "UTF-8");
if fid < 0
    error("Cannot open report file: %s", reportFile);
end

fprintf(fid, "# AI_READ_THIS_FIRST\n\n");

fprintf(fid, "## run_id\n\n%s\n\n", runId);
fprintf(fid, "## run_type\n\nxeq_uncertainty_functionform_internal_qc\n\n");

fprintf(fid, "## input_files\n\n");
fprintf(fid, "- v10: `%s`\n\n", v10File);

fprintf(fid, "## このrunの目的\n\n");
fprintf(fid, "r5でT&M Table8-12数値診断ゲートを仮閉じしたが、Claudeレビューと櫻井コメントを受けて、source01原本確認前に内部で潰せる論点を確認する。\n\n");
fprintf(fid, "特に、x_Mesではなく、補正式候補として使える熱平衡クオリティ x_eq で再診断する。\n\n");
fprintf(fid, "あわせて、Table9/11/12の残差平均にn, SD, SE, CIを付け、Hsub線形フィットのテール影響も確認する。\n\n");

fprintf(fid, "## 前回までの判断\n\n");
fprintf(fid, "- v15では、Table8を除外し、source01 Table9-12を対象にした。\n");
fprintf(fid, "- Table9ではHsub補正後long側正残差は出ず、Table11では小さく、Table12では明確に残った。\n");
fprintf(fid, "- qMは結果側の量なので、補正式入力には使わないと整理した。\n");
fprintf(fid, "- 今回は、x_Mesも補正式入力には使わず、最終的な補正軸候補であるx_eqで確認する。\n\n");

fprintf(fid, "## QC確認\n\n");
fprintf(fid, "- x_eq列検出: %s\n", string(hasXeq));
fprintf(fid, "- 検出されたx_eq列名: `%s`\n", string(xeqName));
fprintf(fid, "- source01 Table9-12行数: %d\n", height(S));
fprintf(fid, "- Table8/9 explore_low行数: %d\n", height(E));
fprintf(fid, "- source01 Table9-12 真Hsub欠損: %d\n", sum(isnan(S.Hsub_true_kJkg)));
fprintf(fid, "- source01 Table9-12 PM_F1欠損: %d\n", sum(isnan(S.PM_F1)));
fprintf(fid, "- source01 Table9-12 x_eq欠損: %d\n\n", sum(isnan(S.xeq_v16)));

if ~hasXeq
    fprintf(fid, "## 重要警告\n\n");
    fprintf(fid, "x_eq列が検出できなかったため、x_eqを含むモデルは実行されていない。\n\n");
    fprintf(fid, "この場合は、column_inventory.csvを確認し、x_eq列名をスクリプトのxeqCandidatesに追加するか、target_rows_T8_12にx_eq列を追加して再実行する。\n\n");
end

fprintf(fid, "## 主要結果\n\n");

fprintf(fid, "### source01 Table9-12 モデル説明力\n\n");
fprintf(fid, "- Hsub linear R2: %.3f\n", r2_S_Hsub);
fprintf(fid, "- Hsub quadratic R2: %.3f\n", r2_S_HsubQuad);
fprintf(fid, "- Hsub cubic R2: %.3f\n", r2_S_HsubCubic);
fprintf(fid, "- Hsub + L/D R2: %.3f\n", r2_S_HsubLD);
fprintf(fid, "- Hsub + P + x_eq R2: %.3f\n", r2_S_HsubPxeq);
fprintf(fid, "- Hsub + L/D + P + x_eq R2: %.3f\n\n", r2_S_HsubLDPxeq);

fprintf(fid, "### same-table short-long残差差：Hsub linear\n\n");
fprintf(fid, "- Table9  long-short residual: %.3f\n", d9_Hsub);
fprintf(fid, "- Table11 long-short residual: %.3f\n", d11_Hsub);
fprintf(fid, "- Table12 long-short residual: %.3f\n", d12_Hsub);
fprintf(fid, "- Table12 SE_delta: %.3f\n", se12_Hsub);
fprintf(fid, "- Table12 CI95 approx: [%.3f, %.3f]\n\n", ci12_low_Hsub, ci12_high_Hsub);

fprintf(fid, "### same-table short-long残差差：Hsub quadratic\n\n");
fprintf(fid, "- Table9  long-short residual: %.3f\n", d9_HsubQuad);
fprintf(fid, "- Table11 long-short residual: %.3f\n", d11_HsubQuad);
fprintf(fid, "- Table12 long-short residual: %.3f\n\n", d12_HsubQuad);

fprintf(fid, "### same-table short-long残差差：Hsub + P + x_eq\n\n");
fprintf(fid, "- Table9  long-short residual: %.3f\n", d9_Pxeq);
fprintf(fid, "- Table11 long-short residual: %.3f\n", d11_Pxeq);
fprintf(fid, "- Table12 long-short residual: %.3f\n\n", d12_Pxeq);

fprintf(fid, "### Table8 middleの確認\n\n");
fprintf(fid, "- Table8 middle - Table9 all residual, Hsub linear: %.3f\n", t8diff_Hsub);
fprintf(fid, "- Table8 middle - Table9 all residual, Hsub + P + x_eq: %.3f\n\n", t8diff_Pxeq);

fprintf(fid, "## MATLAB側の機械的まとめ\n\n");
fprintf(fid, "x_eq列が検出されていれば、x_Mesではなくx_eqを使って、source01 Table9/11/12のshort-long残差を再評価した。\n\n");
fprintf(fid, "また、Hsub linearだけでなく、Hsub quadratic/cubicを用いて、高Hsub端での関数形ミスがTable12 long正残差を作っていないかを確認した。\n\n");
fprintf(fid, "Table9/11/12の残差差にはn, SD, SE, CIを付け、残差差が点推定だけでなく不確かさ込みで意味を持つかを確認できるようにした。\n\n");
fprintf(fid, "Table8 middleについても、x_eq/P軸で見たときに、Table9との差がどう変わるかを確認した。\n\n");

fprintf(fid, "## DECISION_GATE\n\n");

fprintf(fid, "### このrunで判断を更新してよい項目\n\n");
fprintf(fid, "- x_Mesではなくx_eqで見ても、Table12 long正残差が残るか。\n");
fprintf(fid, "- Hsub関数形を二次・三次にしても、Table12 long正残差が残るか。\n");
fprintf(fid, "- Table9/11/12の残差差が、圧力順に並んでいるか。\n");
fprintf(fid, "- Table12 long正残差が、SE/CI込みで信号として扱えそうか。\n");
fprintf(fid, "- Table8 middleの除外判断が、x_eq/Pに替えても維持されるか。\n\n");

fprintf(fid, "### このrunではまだ判断してはいけない項目\n\n");
fprintf(fid, "- L/D補正式を採用すること。\n");
fprintf(fid, "- Table12 long正残差を純粋なL/D効果と断定すること。\n");
fprintf(fid, "- Table12 long正残差を純粋な圧力効果と断定すること。\n");
fprintf(fid, "- x_Mesを補正式入力に使うこと。\n");
fprintf(fid, "- qMを補正式入力に使うこと。\n\n");

fprintf(fid, "### 次のrunまたは次フェーズに送るべき保留\n\n");
fprintf(fid, "- qPの定義と、qP側に既に含まれているL/D項または長さ補正の確認。\n");
fprintf(fid, "- Hsub算出経路の表間整合確認。\n");
fprintf(fid, "- source01原本で、Table9/11/12が同一装置・同一系列の長さ違いか確認すること。\n");
fprintf(fid, "- Table12 longが単一管・単一キャンペーンの系統差ではないか確認すること。\n\n");

fprintf(fid, "## ChatGPTにしてほしいこと\n\n");
fprintf(fid, "このrun_report.mdを読んで、以下を日本語で説明してください。\n\n");
fprintf(fid, "1. 今どこまで進んだか\n");
fprintf(fid, "2. このrunで新しく分かったこと\n");
fprintf(fid, "3. 前回判断から変わったこと\n");
fprintf(fid, "4. まだ言ってはいけないこと\n");
fprintf(fid, "5. 危ない解釈\n");
fprintf(fid, "6. 次にやるべきこと\n");
fprintf(fid, "7. result / internal / 保留の扱い\n");
fprintf(fid, "8. 櫻井がコメントすべき最小ポイント\n\n");

fprintf(fid, "## 添付保存物\n\n");
fprintf(fid, "- `summary_tables.xlsx`\n");
fprintf(fid, "- `csv/basic.csv`\n");
fprintf(fid, "- `csv/column_inventory.csv`\n");
fprintf(fid, "- `csv/S_by_table_LD.csv`\n");
fprintf(fid, "- `csv/S_xeq_xmes.csv`\n");
fprintf(fid, "- `csv/S_model_compare.csv`\n");
fprintf(fid, "- `csv/S_pair_uncertainty.csv`\n");
fprintf(fid, "- `csv/S_pressure_trend.csv`\n");
fprintf(fid, "- `csv/E_by_table_LD.csv`\n");
fprintf(fid, "- `csv/E_xeq_xmes.csv`\n");
fprintf(fid, "- `csv/E_model_compare.csv`\n");
fprintf(fid, "- `csv/E_T8_contrast.csv`\n");
fprintf(fid, "- `csv/decision_summary.csv`\n");

fclose(fid);

%% ===== 表示 =====
disp("=== basic ===");
disp(basic);

disp("=== decision summary ===");
disp(decisionSummary);

disp("=== source01 model compare ===");
disp(modelCompareS);

disp("=== source01 pair uncertainty ===");
disp(pairUncertaintyS);

fprintf("\nDone.\n");
fprintf("Upload this file next:\n  %s\n", reportFile);
fprintf("\nSaved tables:\n  %s\n", xlsxFile);

%% ===== local functions =====

function sid = extractSourceID(T)
    vars = string(T.Properties.VariableNames);

    cand = ["SourceID", "source_id", "SourceNo", "source_no", "Source", "source"];
    for c = cand
        if any(vars == c)
            sid = string(T.(c));
            sid = normalizeSourceText(sid);
            return;
        end
    end

    if ~any(vars == "No_TableNo")
        sid = repmat("unknown", height(T), 1);
        return;
    end

    key = string(T.No_TableNo);
    sid = strings(size(key));

    for i = 1:numel(key)
        tok = regexp(char(key(i)), '\.(\d+)_', 'tokens', 'once');
        if isempty(tok)
            sid(i) = "unknown";
        else
            sid(i) = string(tok{1});
        end
    end

    sid = normalizeSourceText(sid);
end

function sid = normalizeSourceText(sid)
    sid = string(sid);
    sid = strtrim(sid);
    for i = 1:numel(sid)
        x = sid(i);
        if x == "" || ismissing(x)
            sid(i) = "unknown";
        else
            n = str2double(x);
            if ~isnan(n)
                sid(i) = compose("%02.0f", n);
            else
                sid(i) = x;
            end
        end
    end
end

function [name, found] = findColumn(T, exactCandidates, containsPatterns)
    vars = string(T.Properties.VariableNames);
    varsLower = lower(vars);

    name = "NOT_FOUND";
    found = false;

    for c = string(exactCandidates)
        idx = find(varsLower == lower(c), 1);
        if ~isempty(idx)
            name = vars(idx);
            found = true;
            return;
        end
    end

    for p = string(containsPatterns)
        idx = find(contains(varsLower, lower(p)), 1);
        if ~isempty(idx)
            name = vars(idx);
            found = true;
            return;
        end
    end
end

function z = standardizeVec(x)
    x = double(x);
    mu = mean(x, "omitnan");
    sig = std(x, "omitnan");
    if isnan(sig) || sig == 0
        z = nan(size(x));
    else
        z = (x - mu) ./ sig;
    end
end

function defs = addModel(defs, name, X, varNames, role)
    n = numel(defs) + 1;
    defs(n).name = string(name);
    defs(n).X = X;
    defs(n).varNames = string(varNames);
    defs(n).Role = string(role);
end

function S = makeStats(T, groupVars)
    groupVars = string(groupVars);

    if isempty(T)
        S = table();
        return;
    end

    K = unique(T(:, groupVars), "rows");
    S = table();

    for i = 1:height(K)
        m = true(height(T), 1);
        for j = 1:numel(groupVars)
            gv = groupVars(j);
            m = m & string(T.(gv)) == string(K.(gv)(i));
        end

        X = T(m, :);
        row = K(i, :);
        row.N = height(X);
        row.Mean_PM_F1 = mean(X.PM_F1, "omitnan");
        row.Std_PM_F1 = std(X.PM_F1, "omitnan");
        row.Mean_HsubTrue = mean(X.Hsub_true_kJkg, "omitnan");
        row.Mean_P_MPa = mean(X.P_MPa, "omitnan");
        row.Mean_xeq = mean(X.xeq_v16, "omitnan");
        row.Mean_xMes = mean(X.xMes_v16, "omitnan");
        row.Mean_qM_MW_m2 = mean(X.qM_MW_m2, "omitnan");
        row.Mean_LD = mean(X.LD_geom, "omitnan");
        row.Min_LD = min(X.LD_geom, [], "omitnan");
        row.Max_LD = max(X.LD_geom, [], "omitnan");

        S = [S; row]; %#ok<AGROW>
    end
end

function S = makeXeqXmesStats(T, groupVars)
    groupVars = string(groupVars);

    if isempty(T)
        S = table();
        return;
    end

    K = unique(T(:, groupVars), "rows");
    S = table();

    for i = 1:height(K)
        m = true(height(T), 1);
        for j = 1:numel(groupVars)
            gv = groupVars(j);
            m = m & string(T.(gv)) == string(K.(gv)(i));
        end

        X = T(m, :);
        row = K(i, :);
        row.N = height(X);
        row.Mean_xeq = mean(X.xeq_v16, "omitnan");
        row.Std_xeq = std(X.xeq_v16, "omitnan");
        row.Mean_xMes = mean(X.xMes_v16, "omitnan");
        row.Std_xMes = std(X.xMes_v16, "omitnan");
        row.Mean_xeq_minus_xMes = mean(X.xeq_v16 - X.xMes_v16, "omitnan");
        row.Mean_HsubTrue = mean(X.Hsub_true_kJkg, "omitnan");
        row.Mean_P_MPa = mean(X.P_MPa, "omitnan");
        row.Mean_PM_F1 = mean(X.PM_F1, "omitnan");

        S = [S; row]; %#ok<AGROW>
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

    fit.summaryRow = @(yName, modelName, roleName) table( ...
        string(yName), string(modelName), string(roleName), fit.N, numel(varNames), fit.R2, fit.adjR2, fit.RMSE, ...
        'VariableNames', ["Y", "Model", "Role", "N", "NumPredictors", "R2", "AdjR2", "RMSE"]);

    fit.coefTable = @(yName, modelName, roleName) makeCoefTable(string(yName), string(modelName), string(roleName), fit.varNames, fit.beta);
end

function C = makeCoefTable(yName, modelName, roleName, names, beta)
    C = table();
    for i = 1:numel(names)
        tmp = table(yName, modelName, roleName, string(names(i)), beta(i), ...
            'VariableNames', ["Y", "Model", "Role", "Term", "Coefficient"]);
        C = [C; tmp]; %#ok<AGROW>
    end
end

function U = makePairUncertainty(tbl, modelName, residShort, residLong, Pshort, Plong)
    stS = vecStats(residShort);
    stL = vecStats(residLong);

    delta = stL.Mean - stS.Mean;
    seDelta = sqrt(stL.SE^2 + stS.SE^2);
    ciLow = delta - 1.96 * seDelta;
    ciHigh = delta + 1.96 * seDelta;

    U = table( ...
        tbl, string(modelName), ...
        stS.N, stL.N, ...
        stS.Mean, stL.Mean, delta, ...
        stS.SD, stL.SD, ...
        stS.SE, stL.SE, seDelta, ...
        ciLow, ciHigh, ...
        mean([Pshort; Plong], "omitnan"), ...
        mean(Pshort, "omitnan"), mean(Plong, "omitnan"), ...
        'VariableNames', ["TableNo", "Model", ...
                          "N_short", "N_long", ...
                          "Mean_resid_short", "Mean_resid_long", "Delta_long_minus_short", ...
                          "SD_short", "SD_long", ...
                          "SE_short", "SE_long", "SE_delta", ...
                          "CI95_low", "CI95_high", ...
                          "Mean_P_all", "Mean_P_short", "Mean_P_long"]);
end

function st = vecStats(x)
    x = double(x);
    x = x(~isnan(x) & ~isinf(x));
    n = numel(x);

    if n == 0
        st.N = 0;
        st.Mean = NaN;
        st.SD = NaN;
        st.SE = NaN;
    elseif n == 1
        st.N = 1;
        st.Mean = mean(x);
        st.SD = NaN;
        st.SE = NaN;
    else
        st.N = n;
        st.Mean = mean(x);
        st.SD = std(x);
        st.SE = st.SD / sqrt(n);
    end
end

function S = makeGroupContrast(nameA, A, nameB, B, modelDefs)
    S = table(string(nameA), string(nameB), height(A), height(B), ...
        mean(A.PM_F1, "omitnan"), mean(B.PM_F1, "omitnan"), ...
        mean(A.PM_F1, "omitnan") - mean(B.PM_F1, "omitnan"), ...
        mean(A.Hsub_true_kJkg, "omitnan") - mean(B.Hsub_true_kJkg, "omitnan"), ...
        mean(A.P_MPa, "omitnan") - mean(B.P_MPa, "omitnan"), ...
        mean(A.xeq_v16, "omitnan") - mean(B.xeq_v16, "omitnan"), ...
        mean(A.xMes_v16, "omitnan") - mean(B.xMes_v16, "omitnan"), ...
        mean(A.qM_MW_m2, "omitnan") - mean(B.qM_MW_m2, "omitnan"), ...
        mean(A.LD_geom, "omitnan") - mean(B.LD_geom, "omitnan"), ...
        'VariableNames', ["GroupA", "GroupB", "N_A", "N_B", ...
                          "Mean_PM_F1_A", "Mean_PM_F1_B", "Delta_PM_F1_AminusB", ...
                          "Delta_Hsub_AminusB", "Delta_P_AminusB", ...
                          "Delta_xeq_AminusB", "Delta_xMes_AminusB", ...
                          "Delta_qM_AminusB", "Delta_LD_AminusB"]);

    for k = 1:numel(modelDefs)
        residName = matlab.lang.makeValidName("resid_" + modelDefs(k).name);
        safeName = matlab.lang.makeValidName("Delta_" + residName + "_AminusB");
        if ismember(residName, string(A.Properties.VariableNames))
            S.(safeName) = mean(A.(residName), "omitnan") - mean(B.(residName), "omitnan");
        else
            S.(safeName) = NaN;
        end
    end
end

function r2 = getR2(modelCompare, modelName)
    m = string(modelCompare.Model) == string(modelName);
    if any(m)
        r2 = modelCompare.R2(find(m, 1));
    else
        r2 = NaN;
    end
end

function d = getDelta(U, tbl, modelName)
    m = U.TableNo == tbl & string(U.Model) == string(modelName);
    if any(m)
        d = U.Delta_long_minus_short(find(m, 1));
    else
        d = NaN;
    end
end

function se = getSE(U, tbl, modelName)
    m = U.TableNo == tbl & string(U.Model) == string(modelName);
    if any(m)
        se = U.SE_delta(find(m, 1));
    else
        se = NaN;
    end
end

function ci = getCI(U, tbl, modelName, side)
    m = U.TableNo == tbl & string(U.Model) == string(modelName);
    if any(m)
        if string(side) == "low"
            ci = U.CI95_low(find(m, 1));
        else
            ci = U.CI95_high(find(m, 1));
        end
    else
        ci = NaN;
    end
end

function d = getContrastResid(C, groupA, groupB, modelName)
    residName = matlab.lang.makeValidName("Delta_resid_" + string(modelName) + "_AminusB");
    m = string(C.GroupA) == string(groupA) & string(C.GroupB) == string(groupB);

    if any(m) && ismember(residName, string(C.Properties.VariableNames))
        d = C.(residName)(find(m, 1));
    else
        d = NaN;
    end
end