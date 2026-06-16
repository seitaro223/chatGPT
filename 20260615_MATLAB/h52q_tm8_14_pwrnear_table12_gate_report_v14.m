%% h52q_tm8_14_pwrnear_table12_gate_report_v14.m
% H52Q / T&M Table 8-14
% v14: PWR_near source01限定でTable12 long正残差を再整理する。
%
% 目的:
%   explore_low Table8/9を外し、source01で揃っているPWR_near Table10-12のみを見る。
%   Table12 long側の正残差が、
%     - Table12固有差
%     - P/xMes/qM差
%     - L/D/熱履歴成分
%   のどれに近いかを再確認する。
%
% 入力:
%   out_TM8_14/TM8_14_explorelow_truehsub_v10_*.xlsx
%   Sheet: target_rows_T8_12
%
% 出力:
%   out_TM8_14/run_v14_pwrnear_table12_gate_yyyymmdd_HHMMSS/
%     run_report_v14_pwrnear_table12_gate_yyyymmdd_HHMMSS.md
%     summary_tables.xlsx
%     csv/*.csv

clear; clc; close all;

%% ===== 出力フォルダ =====
baseOut = fullfile(pwd, "out_TM8_14");
timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
runId = "v14_pwrnear_table12_gate_" + timestamp;

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

if ismember("qM_MW_m2", string(T.Properties.VariableNames))
    % do nothing
elseif ismember("qM", string(T.Properties.VariableNames))
    T.qM_MW_m2 = T.qM ./ 1e6;
else
    T.qM_MW_m2 = nan(height(T), 1);
end

%% ===== PWR_near source01 Table10-12に限定 =====
P = T( ...
    T.P_scope == "PWR_near_T10_12" & ...
    T.SourceID == "01" & ...
    ismember(T.TableNo, [10 11 12]), :);

P = sortrows(P, ["TableNo", "LD_geom", "Hsub_true_kJkg"]);

P.isT11 = double(P.TableNo == 11);
P.isT12 = double(P.TableNo == 12);
P.isLong = double(P.LD_band == "long");
P.isShort = double(P.LD_band == "short_anchor");

%% ===== basic =====
basic = table( ...
    ["PWR_source01_rows"; ...
     "Table10_rows"; ...
     "Table11_rows"; ...
     "Table12_rows"; ...
     "short_rows"; ...
     "long_rows"; ...
     "source_count"; ...
     "missing_PM_F1"; ...
     "missing_Hsub_true"; ...
     "missing_xMes"; ...
     "missing_qM"], ...
    [height(P); ...
     sum(P.TableNo == 10); ...
     sum(P.TableNo == 11); ...
     sum(P.TableNo == 12); ...
     sum(P.LD_band == "short_anchor"); ...
     sum(P.LD_band == "long"); ...
     numel(unique(P.SourceID)); ...
     sum(isnan(P.PM_F1)); ...
     sum(isnan(P.Hsub_true_kJkg)); ...
     sum(isnan(P.x_Mes)); ...
     sum(isnan(P.qM_MW_m2))], ...
    'VariableNames', ["Item", "Value"]);

%% ===== group summary =====
byTableLD = makeStats(P, ["TableNo", "LD_band"]);
byTable = makeStats(P, ["TableNo"]);
byLD = makeStats(P, ["LD_band"]);

%% ===== モデル定義 =====
modelDefs = struct([]);

modelDefs(end+1).name = "Hsub_only";
modelDefs(end).X = P.Hsub_true_kJkg;
modelDefs(end).varNames = ["Hsub_true"];

modelDefs(end+1).name = "Hsub_LD";
modelDefs(end).X = [P.Hsub_true_kJkg, P.LD_geom];
modelDefs(end).varNames = ["Hsub_true", "LD"];

modelDefs(end+1).name = "Hsub_P";
modelDefs(end).X = [P.Hsub_true_kJkg, P.P_MPa];
modelDefs(end).varNames = ["Hsub_true", "P_MPa"];

modelDefs(end+1).name = "Hsub_xMes";
modelDefs(end).X = [P.Hsub_true_kJkg, P.x_Mes];
modelDefs(end).varNames = ["Hsub_true", "x_Mes"];

modelDefs(end+1).name = "Hsub_qM";
modelDefs(end).X = [P.Hsub_true_kJkg, P.qM_MW_m2];
modelDefs(end).varNames = ["Hsub_true", "qM_MW_m2"];

modelDefs(end+1).name = "Hsub_P_xMes";
modelDefs(end).X = [P.Hsub_true_kJkg, P.P_MPa, P.x_Mes];
modelDefs(end).varNames = ["Hsub_true", "P_MPa", "x_Mes"];

modelDefs(end+1).name = "Hsub_P_xMes_qM";
modelDefs(end).X = [P.Hsub_true_kJkg, P.P_MPa, P.x_Mes, P.qM_MW_m2];
modelDefs(end).varNames = ["Hsub_true", "P_MPa", "x_Mes", "qM_MW_m2"];

modelDefs(end+1).name = "Hsub_LD_P_xMes";
modelDefs(end).X = [P.Hsub_true_kJkg, P.LD_geom, P.P_MPa, P.x_Mes];
modelDefs(end).varNames = ["Hsub_true", "LD", "P_MPa", "x_Mes"];

modelDefs(end+1).name = "Hsub_LD_P_xMes_qM";
modelDefs(end).X = [P.Hsub_true_kJkg, P.LD_geom, P.P_MPa, P.x_Mes, P.qM_MW_m2];
modelDefs(end).varNames = ["Hsub_true", "LD", "P_MPa", "x_Mes", "qM_MW_m2"];

modelDefs(end+1).name = "Hsub_T12dummy";
modelDefs(end).X = [P.Hsub_true_kJkg, P.isT12];
modelDefs(end).varNames = ["Hsub_true", "isT12"];

modelDefs(end+1).name = "Hsub_LD_T12dummy";
modelDefs(end).X = [P.Hsub_true_kJkg, P.LD_geom, P.isT12];
modelDefs(end).varNames = ["Hsub_true", "LD", "isT12"];

modelDefs(end+1).name = "Hsub_P_xMes_T12dummy";
modelDefs(end).X = [P.Hsub_true_kJkg, P.P_MPa, P.x_Mes, P.isT12];
modelDefs(end).varNames = ["Hsub_true", "P_MPa", "x_Mes", "isT12"];

modelDefs(end+1).name = "Hsub_LD_P_xMes_T12dummy";
modelDefs(end).X = [P.Hsub_true_kJkg, P.LD_geom, P.P_MPa, P.x_Mes, P.isT12];
modelDefs(end).varNames = ["Hsub_true", "LD", "P_MPa", "x_Mes", "isT12"];

%% ===== モデル計算 =====
modelCompare = table();
coefTable = table();
Ppred = P;

for k = 1:numel(modelDefs)
    fit = fitLinearModel(modelDefs(k).X, P.PM_F1, modelDefs(k).varNames);

    modelCompare = [modelCompare; fit.summaryRow("PM_F1", modelDefs(k).name)]; %#ok<AGROW>
    coefTable = [coefTable; fit.coefTable("PM_F1", modelDefs(k).name)]; %#ok<AGROW>

    predName = matlab.lang.makeValidName("pred_" + modelDefs(k).name);
    residName = matlab.lang.makeValidName("resid_" + modelDefs(k).name);

    Ppred.(predName) = fit.yhat;
    Ppred.(residName) = fit.resid;
end

%% ===== 同一Table内 short-long =====
sameTablePairs = table();
for tbl = [11 12]
    S = Ppred(Ppred.TableNo == tbl & Ppred.LD_band == "short_anchor", :);
    L = Ppred(Ppred.TableNo == tbl & Ppred.LD_band == "long", :);
    sameTablePairs = [sameTablePairs; makePairSummary(tbl, S, L, modelDefs)]; %#ok<AGROW>
end

%% ===== Table12 long vs Table11 long =====
T11long = Ppred(Ppred.TableNo == 11 & Ppred.LD_band == "long", :);
T12long = Ppred(Ppred.TableNo == 12 & Ppred.LD_band == "long", :);
longCompare = makeLongCompare(T11long, T12long, modelDefs);

%% ===== Table12 long vs baseline =====
T10short = Ppred(Ppred.TableNo == 10 & Ppred.LD_band == "short_anchor", :);
T11short = Ppred(Ppred.TableNo == 11 & Ppred.LD_band == "short_anchor", :);
T12short = Ppred(Ppred.TableNo == 12 & Ppred.LD_band == "short_anchor", :);

baselineCompare = table();
baselineCompare = [baselineCompare; makeGroupContrast("T12_long", T12long, "T10_short", T10short, modelDefs)]; %#ok<AGROW>
baselineCompare = [baselineCompare; makeGroupContrast("T12_long", T12long, "T11_short", T11short, modelDefs)]; %#ok<AGROW>
baselineCompare = [baselineCompare; makeGroupContrast("T12_long", T12long, "T12_short", T12short, modelDefs)]; %#ok<AGROW>
baselineCompare = [baselineCompare; makeGroupContrast("T12_long", T12long, "T11_long", T11long, modelDefs)]; %#ok<AGROW>

%% ===== 主要値抽出 =====
r2_Hsub = getR2(modelCompare, "Hsub_only");
r2_Hsub_LD = getR2(modelCompare, "Hsub_LD");
r2_Hsub_P = getR2(modelCompare, "Hsub_P");
r2_Hsub_xMes = getR2(modelCompare, "Hsub_xMes");
r2_Hsub_qM = getR2(modelCompare, "Hsub_qM");
r2_Hsub_P_xMes_qM = getR2(modelCompare, "Hsub_P_xMes_qM");
r2_Hsub_LD_P_xMes_qM = getR2(modelCompare, "Hsub_LD_P_xMes_qM");
r2_Hsub_T12 = getR2(modelCompare, "Hsub_T12dummy");
r2_Hsub_LD_T12 = getR2(modelCompare, "Hsub_LD_T12dummy");

d12_raw = getPairDelta(sameTablePairs, 12, "Delta_PM_F1_long_minus_short");
d12_hsub = getPairDelta(sameTablePairs, 12, "Delta_resid_Hsub_only_long_minus_short");
d12_ld = getPairDelta(sameTablePairs, 12, "Delta_resid_Hsub_LD_long_minus_short");
d12_p = getPairDelta(sameTablePairs, 12, "Delta_resid_Hsub_P_long_minus_short");
d12_x = getPairDelta(sameTablePairs, 12, "Delta_resid_Hsub_xMes_long_minus_short");
d12_qm = getPairDelta(sameTablePairs, 12, "Delta_resid_Hsub_qM_long_minus_short");
d12_pxm_qm = getPairDelta(sameTablePairs, 12, "Delta_resid_Hsub_P_xMes_qM_long_minus_short");
d12_ld_pxm_qm = getPairDelta(sameTablePairs, 12, "Delta_resid_Hsub_LD_P_xMes_qM_long_minus_short");

d11_raw = getPairDelta(sameTablePairs, 11, "Delta_PM_F1_long_minus_short");
d11_hsub = getPairDelta(sameTablePairs, 11, "Delta_resid_Hsub_only_long_minus_short");
d11_ld = getPairDelta(sameTablePairs, 11, "Delta_resid_Hsub_LD_long_minus_short");

t12_t11_raw = longCompare.Delta_PM_F1_BminusA(1);
t12_t11_hsub = longCompare.Delta_resid_Hsub_only_BminusA(1);
t12_t11_ldpxmqm = longCompare.Delta_resid_Hsub_LD_P_xMes_qM_BminusA(1);

%% ===== decision summary =====
decisionSummary = table( ...
    ["PWR_source01_rows"; ...
     "R2_Hsub_only"; ...
     "R2_Hsub_LD"; ...
     "R2_Hsub_P"; ...
     "R2_Hsub_xMes"; ...
     "R2_Hsub_qM"; ...
     "R2_Hsub_P_xMes_qM"; ...
     "R2_Hsub_LD_P_xMes_qM"; ...
     "R2_Hsub_T12dummy"; ...
     "R2_Hsub_LD_T12dummy"; ...
     "T12_raw_long_minus_short"; ...
     "T12_resid_Hsub_long_minus_short"; ...
     "T12_resid_Hsub_LD_long_minus_short"; ...
     "T12_resid_Hsub_P_long_minus_short"; ...
     "T12_resid_Hsub_xMes_long_minus_short"; ...
     "T12_resid_Hsub_qM_long_minus_short"; ...
     "T12_resid_Hsub_P_xMes_qM_long_minus_short"; ...
     "T12_resid_Hsub_LD_P_xMes_qM_long_minus_short"; ...
     "T11_raw_long_minus_short"; ...
     "T11_resid_Hsub_long_minus_short"; ...
     "T11_resid_Hsub_LD_long_minus_short"; ...
     "T12long_minus_T11long_raw"; ...
     "T12long_minus_T11long_resid_Hsub"; ...
     "T12long_minus_T11long_resid_Hsub_LD_P_xMes_qM"], ...
    [height(P); ...
     r2_Hsub; ...
     r2_Hsub_LD; ...
     r2_Hsub_P; ...
     r2_Hsub_xMes; ...
     r2_Hsub_qM; ...
     r2_Hsub_P_xMes_qM; ...
     r2_Hsub_LD_P_xMes_qM; ...
     r2_Hsub_T12; ...
     r2_Hsub_LD_T12; ...
     d12_raw; ...
     d12_hsub; ...
     d12_ld; ...
     d12_p; ...
     d12_x; ...
     d12_qm; ...
     d12_pxm_qm; ...
     d12_ld_pxm_qm; ...
     d11_raw; ...
     d11_hsub; ...
     d11_ld; ...
     t12_t11_raw; ...
     t12_t11_hsub; ...
     t12_t11_ldpxmqm], ...
    'VariableNames', ["Metric", "Value"]);

%% ===== 保存 =====
writetable(basic, xlsxFile, "Sheet", "basic");
writetable(byTableLD, xlsxFile, "Sheet", "by_table_LD");
writetable(byTable, xlsxFile, "Sheet", "by_table");
writetable(byLD, xlsxFile, "Sheet", "by_LD");
writetable(modelCompare, xlsxFile, "Sheet", "model_compare");
writetable(coefTable, xlsxFile, "Sheet", "model_coefficients");
writetable(sameTablePairs, xlsxFile, "Sheet", "same_table_pairs");
writetable(longCompare, xlsxFile, "Sheet", "T12long_vs_T11long");
writetable(baselineCompare, xlsxFile, "Sheet", "T12long_baseline_compare");
writetable(decisionSummary, xlsxFile, "Sheet", "decision_summary");
writetable(Ppred, xlsxFile, "Sheet", "PWR_rows_with_resid");

writetable(basic, fullfile(csvDir, "basic.csv"));
writetable(byTableLD, fullfile(csvDir, "by_table_LD.csv"));
writetable(modelCompare, fullfile(csvDir, "model_compare.csv"));
writetable(coefTable, fullfile(csvDir, "model_coefficients.csv"));
writetable(sameTablePairs, fullfile(csvDir, "same_table_pairs.csv"));
writetable(longCompare, fullfile(csvDir, "T12long_vs_T11long.csv"));
writetable(baselineCompare, fullfile(csvDir, "T12long_baseline_compare.csv"));
writetable(decisionSummary, fullfile(csvDir, "decision_summary.csv"));

%% ===== report作成 =====
fid = fopen(reportFile, "w", "n", "UTF-8");
if fid < 0
    error("Cannot open report file: %s", reportFile);
end

fprintf(fid, "# AI_READ_THIS_FIRST\n\n");

fprintf(fid, "## run_id\n\n%s\n\n", runId);
fprintf(fid, "## run_type\n\npwrnear_source01_table12_decision_gate\n\n");

fprintf(fid, "## input_files\n\n");
fprintf(fid, "- v10: `%s`\n\n", v10File);

fprintf(fid, "## このrunの目的\n\n");
fprintf(fid, "explore_low Table8/9を外し、source01で揃っているPWR_near Table10-12のみを対象に、Table12 long正残差を再整理する。\n\n");
fprintf(fid, "Table12 long側の正残差が、Table12固有差、P/xMes/qM差、L/D/熱履歴成分のどれに近いかを判断するためのゲートrunである。\n\n");

fprintf(fid, "## 前回までの判断\n\n");
fprintf(fid, "- v13では、Table8 middleはsource03に閉じており、L/D検証点として単純には使わないと整理した。\n");
fprintf(fid, "- explore_low Table8/9は、PWR_near Table12の正残差を否定する材料にはしない。\n");
fprintf(fid, "- したがって、今回はPWR_near Table10-12、source01限定に戻る。\n\n");

fprintf(fid, "## QC確認\n\n");
fprintf(fid, "- PWR_near Table10-12かつ source01 のみに限定した。\n");
fprintf(fid, "- 対象行数: %d\n", height(P));
fprintf(fid, "- Table10行数: %d\n", sum(P.TableNo == 10));
fprintf(fid, "- Table11行数: %d\n", sum(P.TableNo == 11));
fprintf(fid, "- Table12行数: %d\n", sum(P.TableNo == 12));
fprintf(fid, "- source種類数: %d\n", numel(unique(P.SourceID)));
fprintf(fid, "- 真Hsub欠損: %d\n", sum(isnan(P.Hsub_true_kJkg)));
fprintf(fid, "- PM_F1欠損: %d\n\n", sum(isnan(P.PM_F1)));

fprintf(fid, "## 主要結果\n\n");

fprintf(fid, "### モデル説明力\n\n");
fprintf(fid, "- Hsub only R2: %.3f\n", r2_Hsub);
fprintf(fid, "- Hsub + L/D R2: %.3f\n", r2_Hsub_LD);
fprintf(fid, "- Hsub + P R2: %.3f\n", r2_Hsub_P);
fprintf(fid, "- Hsub + xMes R2: %.3f\n", r2_Hsub_xMes);
fprintf(fid, "- Hsub + qM R2: %.3f\n", r2_Hsub_qM);
fprintf(fid, "- Hsub + P + xMes + qM R2: %.3f\n", r2_Hsub_P_xMes_qM);
fprintf(fid, "- Hsub + L/D + P + xMes + qM R2: %.3f\n", r2_Hsub_LD_P_xMes_qM);
fprintf(fid, "- Hsub + Table12 dummy R2: %.3f\n", r2_Hsub_T12);
fprintf(fid, "- Hsub + L/D + Table12 dummy R2: %.3f\n\n", r2_Hsub_LD_T12);

fprintf(fid, "### Table12 short-long差\n\n");
fprintf(fid, "- raw PM_F1 long-short: %.3f\n", d12_raw);
fprintf(fid, "- Hsub only residual long-short: %.3f\n", d12_hsub);
fprintf(fid, "- Hsub + L/D residual long-short: %.3f\n", d12_ld);
fprintf(fid, "- Hsub + P residual long-short: %.3f\n", d12_p);
fprintf(fid, "- Hsub + xMes residual long-short: %.3f\n", d12_x);
fprintf(fid, "- Hsub + qM residual long-short: %.3f\n", d12_qm);
fprintf(fid, "- Hsub + P + xMes + qM residual long-short: %.3f\n", d12_pxm_qm);
fprintf(fid, "- Hsub + L/D + P + xMes + qM residual long-short: %.3f\n\n", d12_ld_pxm_qm);

fprintf(fid, "### Table11との比較\n\n");
fprintf(fid, "- Table11 raw PM_F1 long-short: %.3f\n", d11_raw);
fprintf(fid, "- Table11 Hsub only residual long-short: %.3f\n", d11_hsub);
fprintf(fid, "- Table11 Hsub + L/D residual long-short: %.3f\n", d11_ld);
fprintf(fid, "- Table12 long - Table11 long raw PM_F1: %.3f\n", t12_t11_raw);
fprintf(fid, "- Table12 long - Table11 long Hsub only residual: %.3f\n", t12_t11_hsub);
fprintf(fid, "- Table12 long - Table11 long Hsub+LD+P+xMes+qM residual: %.3f\n\n", t12_t11_ldpxmqm);

fprintf(fid, "## MATLAB側の機械的まとめ\n\n");
fprintf(fid, "PWR_near source01に限定しても、Table12 long側の正残差が残るかを確認した。\n\n");
fprintf(fid, "Hsubのみ、Hsub+P、Hsub+xMes、Hsub+qM、Hsub+L/D、Table12 dummyのどれで残差が減るかを比較した。\n\n");
fprintf(fid, "Table11とTable12のshort-long差の違い、Table12 longとTable11 longの差も確認した。\n\n");

fprintf(fid, "## DECISION_GATE\n\n");

fprintf(fid, "### このrunで判断を更新してよい項目\n\n");
fprintf(fid, "- PWR_near source01限定で、Table12 long正残差がどの説明変数で減るか。\n");
fprintf(fid, "- Table12 long正残差を、P/xMes/qM差、Table12固有差、L/D/熱履歴成分のどれとして保留するのが妥当か。\n\n");

fprintf(fid, "### このrunではまだ判断してはいけない項目\n\n");
fprintf(fid, "- L/D補正式を採用すること。\n");
fprintf(fid, "- Table12 long正残差を純粋なL/D効果と断定すること。\n");
fprintf(fid, "- Table12固有差、圧力差、物性差のどれか一つに断定すること。\n\n");

fprintf(fid, "### 次のrunに送るべき保留\n\n");
fprintf(fid, "- 補正式候補に進むか、PWR_near限定の診断項に留めるか。\n");
fprintf(fid, "- Table12 long正残差を、文献追加やBecker到着後の検証対象として残すか。\n\n");

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
fprintf(fid, "- `csv/by_table_LD.csv`\n");
fprintf(fid, "- `csv/model_compare.csv`\n");
fprintf(fid, "- `csv/model_coefficients.csv`\n");
fprintf(fid, "- `csv/same_table_pairs.csv`\n");
fprintf(fid, "- `csv/T12long_vs_T11long.csv`\n");
fprintf(fid, "- `csv/T12long_baseline_compare.csv`\n");
fprintf(fid, "- `csv/decision_summary.csv`\n");

fclose(fid);

%% ===== 表示 =====
disp("=== basic ===");
disp(basic);

disp("=== decision summary ===");
disp(decisionSummary);

disp("=== model compare ===");
disp(modelCompare);

disp("=== same table pairs ===");
disp(sameTablePairs);

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
        row.Mean_HsubTrue = mean(X.Hsub_true_kJkg, "omitnan");
        row.Mean_P_MPa = mean(X.P_MPa, "omitnan");
        row.Mean_xMes = mean(X.x_Mes, "omitnan");
        row.Mean_qM_MW_m2 = mean(X.qM_MW_m2, "omitnan");
        row.Mean_LD = mean(X.LD_geom, "omitnan");
        row.Min_LD = min(X.LD_geom, [], "omitnan");
        row.Max_LD = max(X.LD_geom, [], "omitnan");

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

    fit.summaryRow = @(yName, modelName) table( ...
        string(yName), string(modelName), fit.N, numel(varNames), fit.R2, fit.adjR2, fit.RMSE, ...
        'VariableNames', ["Y", "Model", "N", "NumPredictors", "R2", "AdjR2", "RMSE"]);

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

function S = makePairSummary(tbl, Short, Long, modelDefs)
    S = table(tbl, height(Short), height(Long), ...
        mean(Short.PM_F1, "omitnan"), mean(Long.PM_F1, "omitnan"), ...
        mean(Long.PM_F1, "omitnan") - mean(Short.PM_F1, "omitnan"), ...
        mean(Short.Hsub_true_kJkg, "omitnan"), mean(Long.Hsub_true_kJkg, "omitnan"), ...
        mean(Long.Hsub_true_kJkg, "omitnan") - mean(Short.Hsub_true_kJkg, "omitnan"), ...
        mean(Short.P_MPa, "omitnan"), mean(Long.P_MPa, "omitnan"), ...
        mean(Long.P_MPa, "omitnan") - mean(Short.P_MPa, "omitnan"), ...
        mean(Short.x_Mes, "omitnan"), mean(Long.x_Mes, "omitnan"), ...
        mean(Long.x_Mes, "omitnan") - mean(Short.x_Mes, "omitnan"), ...
        mean(Short.qM_MW_m2, "omitnan"), mean(Long.qM_MW_m2, "omitnan"), ...
        mean(Long.qM_MW_m2, "omitnan") - mean(Short.qM_MW_m2, "omitnan"), ...
        mean(Short.LD_geom, "omitnan"), mean(Long.LD_geom, "omitnan"), ...
        mean(Long.LD_geom, "omitnan") - mean(Short.LD_geom, "omitnan"), ...
        'VariableNames', ["TableNo", "N_short", "N_long", ...
                          "Mean_PM_F1_short", "Mean_PM_F1_long", "Delta_PM_F1_long_minus_short", ...
                          "Mean_Hsub_short", "Mean_Hsub_long", "Delta_Hsub_long_minus_short", ...
                          "Mean_P_short", "Mean_P_long", "Delta_P_long_minus_short", ...
                          "Mean_xMes_short", "Mean_xMes_long", "Delta_xMes_long_minus_short", ...
                          "Mean_qM_short", "Mean_qM_long", "Delta_qM_long_minus_short", ...
                          "Mean_LD_short", "Mean_LD_long", "Delta_LD_long_minus_short"]);

    for k = 1:numel(modelDefs)
        residName = matlab.lang.makeValidName("resid_" + modelDefs(k).name);
        safeName = matlab.lang.makeValidName("Delta_" + residName + "_long_minus_short");
        S.(safeName) = mean(Long.(residName), "omitnan") - mean(Short.(residName), "omitnan");
    end
end

function S = makeLongCompare(A, B, modelDefs)
    S = table("T11_long", "T12_long", height(A), height(B), ...
        mean(A.PM_F1, "omitnan"), mean(B.PM_F1, "omitnan"), ...
        mean(B.PM_F1, "omitnan") - mean(A.PM_F1, "omitnan"), ...
        mean(A.Hsub_true_kJkg, "omitnan"), mean(B.Hsub_true_kJkg, "omitnan"), ...
        mean(B.Hsub_true_kJkg, "omitnan") - mean(A.Hsub_true_kJkg, "omitnan"), ...
        mean(A.P_MPa, "omitnan"), mean(B.P_MPa, "omitnan"), ...
        mean(B.P_MPa, "omitnan") - mean(A.P_MPa, "omitnan"), ...
        mean(A.x_Mes, "omitnan"), mean(B.x_Mes, "omitnan"), ...
        mean(B.x_Mes, "omitnan") - mean(A.x_Mes, "omitnan"), ...
        mean(A.qM_MW_m2, "omitnan"), mean(B.qM_MW_m2, "omitnan"), ...
        mean(B.qM_MW_m2, "omitnan") - mean(A.qM_MW_m2, "omitnan"), ...
        'VariableNames', ["GroupA", "GroupB", "N_A", "N_B", ...
                          "Mean_PM_F1_A", "Mean_PM_F1_B", "Delta_PM_F1_BminusA", ...
                          "Mean_Hsub_A", "Mean_Hsub_B", "Delta_Hsub_BminusA", ...
                          "Mean_P_A", "Mean_P_B", "Delta_P_BminusA", ...
                          "Mean_xMes_A", "Mean_xMes_B", "Delta_xMes_BminusA", ...
                          "Mean_qM_A", "Mean_qM_B", "Delta_qM_BminusA"]);

    for k = 1:numel(modelDefs)
        residName = matlab.lang.makeValidName("resid_" + modelDefs(k).name);
        safeName = matlab.lang.makeValidName("Delta_" + residName + "_BminusA");
        S.(safeName) = mean(B.(residName), "omitnan") - mean(A.(residName), "omitnan");
    end
end

function S = makeGroupContrast(nameA, A, nameB, B, modelDefs)
    S = table(string(nameA), string(nameB), height(A), height(B), ...
        mean(A.PM_F1, "omitnan"), mean(B.PM_F1, "omitnan"), ...
        mean(A.PM_F1, "omitnan") - mean(B.PM_F1, "omitnan"), ...
        mean(A.Hsub_true_kJkg, "omitnan") - mean(B.Hsub_true_kJkg, "omitnan"), ...
        mean(A.P_MPa, "omitnan") - mean(B.P_MPa, "omitnan"), ...
        mean(A.x_Mes, "omitnan") - mean(B.x_Mes, "omitnan"), ...
        mean(A.qM_MW_m2, "omitnan") - mean(B.qM_MW_m2, "omitnan"), ...
        mean(A.LD_geom, "omitnan") - mean(B.LD_geom, "omitnan"), ...
        'VariableNames', ["GroupA", "GroupB", "N_A", "N_B", ...
                          "Mean_PM_F1_A", "Mean_PM_F1_B", "Delta_PM_F1_AminusB", ...
                          "Delta_Hsub_AminusB", "Delta_P_AminusB", ...
                          "Delta_xMes_AminusB", "Delta_qM_AminusB", "Delta_LD_AminusB"]);

    for k = 1:numel(modelDefs)
        residName = matlab.lang.makeValidName("resid_" + modelDefs(k).name);
        safeName = matlab.lang.makeValidName("Delta_" + residName + "_AminusB");
        S.(safeName) = mean(A.(residName), "omitnan") - mean(B.(residName), "omitnan");
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

function d = getPairDelta(T, tbl, colName)
    m = T.TableNo == tbl;
    if any(m) && ismember(colName, string(T.Properties.VariableNames))
        d = T.(colName)(find(m, 1));
    else
        d = NaN;
    end
end