%% BT05_Tsub_xeq_separation_diagnostic.m
% BT05：Tsubとx_eqの切り分け診断
%
% 目的：
%   BT04では、F1なし誤差 PM_noF1 と F1効果量 delta_PM / lift_ratio が、
%   L/DHやz_DNB/DHよりも Tsub と x_eq に強く対応することを確認した。
%
%   ただし、Tsubとx_eqは共変している可能性がある。
%   そこでBT05では、x_eqがTsubの単なる代理なのか、
%   Tsubにない追加説明力を持つのかを確認する。
%
% 重要：
%   - このrunでは補正式を作らない。
%   - F1(Tsub)を置換しない。
%   - R2が高いモデルをそのまま採用しない。
%   - x_eqは候補状態量として診断するだけである。
%
% 入力：
%   H52Q_current_bundle_input_v1_*.xlsx
%
% 出力：
%   BT05_Tsub_xeq_separation_diagnostic_yyyymmdd_HHMMSS.xlsx
%   run_report_BT05_Tsub_xeq_separation_diagnostic_yyyymmdd_HHMMSS.md
%
% 実行方法：
%   この .m ファイルを current_bundle_input ブックと同じフォルダに置いて実行する。
%   inputFile を空文字 "" にしている場合は、最新の
%   H52Q_current_bundle_input_v1_*.xlsx を自動探索する。

clear; clc;

%% ===== Settings =====

inputFile = "";  % 空なら最新の current_bundle_input を自動探索

if strlength(inputFile) == 0
    inputFile = findLatestFile("H52Q_current_bundle_input_v1_*.xlsx");
end

if ~isfile(inputFile)
    error("current_bundle input file not found: %s", inputFile);
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "BT05_Tsub_xeq_separation_diagnostic_" + timestamp + ".xlsx";
outMd   = "run_report_BT05_Tsub_xeq_separation_diagnostic_" + timestamp + ".md";

sheetMap = table( ...
    ["noF1"; "noF1"; "noF1"; "F1"; "F1"; "F1"], ...
    ["108";  "161";  "164";  "108"; "161"; "164"], ...
    ["tm_108"; "tm_161"; "tm_164"; "tm_F1_108"; "tm_F1_161"; "tm_F1_164"], ...
    'VariableNames', {'correction','case_id','sheet_name'} ...
);

fprintf("Input current_bundle: %s\n", inputFile);

%% ===== Read sheets =====

detail = table();

for i = 1:height(sheetMap)
    corr = sheetMap.correction(i);
    cid  = sheetMap.case_id(i);
    sh   = sheetMap.sheet_name(i);

    fprintf("Reading sheet: %s / %s / %s\n", corr, cid, sh);

    T = readSheetAsTable(inputFile, sh);
    D = makeDetail(T, corr, cid, sh);
    detail = [detail; D]; %#ok<AGROW>
end

detail.point_index_in_case = zeros(height(detail),1);
for corr = ["noF1","F1"]
    for cid = ["108","161","164"]
        idx = find(detail.correction == corr & detail.case_id == cid);
        detail.point_index_in_case(idx) = (1:numel(idx))';
    end
end

%% ===== Pair noF1 and F1 =====

paired = table();

for cid = ["108","161","164"]
    N_no = sum(detail.correction=="noF1" & detail.case_id==cid);
    N_f1 = sum(detail.correction=="F1"   & detail.case_id==cid);
    N = min(N_no, N_f1);

    for k = 1:N
        A = detail(detail.correction=="noF1" & detail.case_id==cid & detail.point_index_in_case==k, :);
        B = detail(detail.correction=="F1"   & detail.case_id==cid & detail.point_index_in_case==k, :);

        row = table();
        row.case_id = cid;
        row.point_index_in_case = k;
        row.No_TableNo = B.No_TableNo;
        row.No = B.No;

        % responses
        row.q_exp_MWm2 = B.q_exp_MWm2;
        row.q_calc_noF1_MWm2 = A.q_calc_MWm2;
        row.q_calc_F1_MWm2   = B.q_calc_MWm2;
        row.PM_noF1 = A.PM;
        row.PM_F1   = B.PM;
        row.delta_PM = B.PM - A.PM;
        row.lift_ratio = safeRatio(B.PM, A.PM);

        % F1 effect normalized by Fcorr-1.
        row.delta_PM_per_Fcorr_minus1 = safeRatio(row.delta_PM, B.Fcorr - 1);
        row.lift_minus1_per_Fcorr_minus1 = safeRatio(row.lift_ratio - 1, B.Fcorr - 1);

        % candidate state variables / context axes
        row.Tsub_K = B.Tsub_K;
        row.x_eq = B.x_eq;
        row.Fcorr = B.Fcorr;
        row.F_form = B.F_form;
        row.z_DNB_over_DH = B.z_DNB_over_DH;
        row.z_DNB_over_L  = B.z_DNB_over_L;
        row.L_over_DH     = B.L_over_DH;
        row.Tw_minus_Tsat_K = B.Tw_minus_Tsat_K;
        row.Tm_minus_Tsat_K = B.Tm_minus_Tsat_K;

        paired = [paired; row]; %#ok<AGROW>
    end
end

%% ===== Definitions =====

responseDef = cell2table({
    "PM_noF1", "F1なしの元モデル誤差。x_eqがTsubに対して追加説明力を持つかを最初に見る応答量。"
    "PM_F1", "F1後に残る誤差。BT03/BT04でL/DHとの見かけ相関が出たが、過読しない。"
    "delta_PM", "F1による絶対的な持ち上げ量。Tsub/Fcorrとx_eqの切り分け対象。"
    "lift_ratio", "F1による倍率効果。Tsub/Fcorrとx_eqの切り分け対象。"
    "delta_PM_per_Fcorr_minus1", "F1係数差で割った見かけの効きやすさ。Fcorrが1に近いため参考扱い。"
    "lift_minus1_per_Fcorr_minus1", "倍率効果をFcorr-1で割った見かけの効きやすさ。参考扱い。"
}, 'VariableNames', {'response','meaning'});

predictorDef = cell2table({
    "Tsub_K", "入口サブクール度。現行F1(Tsub)の元変数。"
    "x_eq", "熱平衡クオリティ。前向き計算可能な熱収支状態量候補。"
    "Fcorr", "現行F1(Tsub)の補正係数。Tsubの関数に近い。"
    "F_form", "非一様加熱分布をDNB位置局所熱流束基準へ換算する係数。F1ではない。"
    "z_DNB_over_DH", "DNB位置までの水力等価直径基準履歴長。"
    "L_over_DH", "全加熱長の水力等価直径基準長さ。"
}, 'VariableNames', {'predictor','meaning'});

%% ===== Case summary =====

caseSummary = table();
summaryVars = [
    "PM_noF1"
    "PM_F1"
    "delta_PM"
    "lift_ratio"
    "delta_PM_per_Fcorr_minus1"
    "lift_minus1_per_Fcorr_minus1"
    "Tsub_K"
    "x_eq"
    "Fcorr"
    "F_form"
    "z_DNB_over_DH"
    "z_DNB_over_L"
    "L_over_DH"
];

for cid = ["108","161","164"]
    S = paired(paired.case_id == cid, :);
    row = table();
    row.case_id = cid;
    row.N = height(S);
    for v = summaryVars'
        row.(v + "_mean") = mean(S.(v), 'omitnan');
        row.(v + "_sd") = std(S.(v), 'omitnan');
    end
    caseSummary = [caseSummary; row]; %#ok<AGROW>
end

%% ===== Tsub-xeq relation =====

Tsub_xeq_relation = table();
Tsub_xeq_relation.relation = "x_eq ~ Tsub_K";
Tsub_xeq_relation.N = sum(isfinite(paired.Tsub_K) & isfinite(paired.x_eq));
fitTX = fitLinearModelSummary(paired, "x_eq", ["Tsub_K"]);
Tsub_xeq_relation.R2 = fitTX.R2;
Tsub_xeq_relation.RMSE = fitTX.RMSE;
Tsub_xeq_relation.slope = fitTX.beta_1;
Tsub_xeq_relation.intercept = fitTX.beta_0;
Tsub_xeq_relation.pearson_r = corrOne(paired.Tsub_K, paired.x_eq);
Tsub_xeq_relation.reading = "Tsubとx_eqがどの程度共変しているか。強い場合、x_eq相関はTsub代理の可能性がある。";

%% ===== Model comparison =====

responseVars = [
    "PM_noF1"
    "PM_F1"
    "delta_PM"
    "lift_ratio"
    "delta_PM_per_Fcorr_minus1"
    "lift_minus1_per_Fcorr_minus1"
];

modelCompare = table();

for y = responseVars'
    specs = {
        "Tsub only", ["Tsub_K"];
        "x_eq only", ["x_eq"];
        "Tsub + x_eq", ["Tsub_K","x_eq"];
        "Fcorr only", ["Fcorr"];
        "Fcorr + x_eq", ["Fcorr","x_eq"];
        "Tsub + Fcorr", ["Tsub_K","Fcorr"];
        "Tsub + Fcorr + x_eq", ["Tsub_K","Fcorr","x_eq"];
        "context: Tsub + x_eq + F_form + z_DNB/DH", ["Tsub_K","x_eq","F_form","z_DNB_over_DH"];
    };

    for i = 1:size(specs,1)
        row = fitLinearModelSummary(paired, y, string(specs{i,2}));
        row.response = y;
        row.model = string(specs{i,1});
        row.predictors = strjoin(string(specs{i,2}), " + ");
        modelCompare = [modelCompare; row]; %#ok<AGROW>
    end
end

modelCompare = movevars(modelCompare, ["response","model","predictors"], "Before", 1);
modelCompare = sortrows(modelCompare, ["response","R2"], ["ascend","descend"]);

%% ===== Incremental R2 and residualized diagnostics =====

incremental = table();
residCorr = table();
residPoints = paired(:, {'case_id','point_index_in_case','No_TableNo','No','PM_noF1','PM_F1','delta_PM','lift_ratio','Tsub_K','x_eq','Fcorr'});

for y = responseVars'
    % Incremental R2: x_eq after Tsub, and Tsub after x_eq
    incremental = [incremental; makeIncrementRow(paired, y, ["Tsub_K"], ["Tsub_K","x_eq"], "x_eq_after_Tsub")]; %#ok<AGROW>
    incremental = [incremental; makeIncrementRow(paired, y, ["x_eq"], ["x_eq","Tsub_K"], "Tsub_after_x_eq")]; %#ok<AGROW>
    incremental = [incremental; makeIncrementRow(paired, y, ["Fcorr"], ["Fcorr","x_eq"], "x_eq_after_Fcorr")]; %#ok<AGROW>
    incremental = [incremental; makeIncrementRow(paired, y, ["Tsub_K","Fcorr"], ["Tsub_K","Fcorr","x_eq"], "x_eq_after_Tsub_and_Fcorr")]; %#ok<AGROW>

    % Residualized correlations
    [resAfterTsub, ok1] = modelResidual(paired, y, ["Tsub_K"]);
    [resAfterXeq, ok2]  = modelResidual(paired, y, ["x_eq"]);
    [resAfterFcorr, ok3] = modelResidual(paired, y, ["Fcorr"]);
    [resAfterTsubFcorr, ok4] = modelResidual(paired, y, ["Tsub_K","Fcorr"]);

    residPoints.("res_" + y + "_after_Tsub") = resAfterTsub;
    residPoints.("res_" + y + "_after_xeq") = resAfterXeq;
    residPoints.("res_" + y + "_after_Fcorr") = resAfterFcorr;
    residPoints.("res_" + y + "_after_Tsub_Fcorr") = resAfterTsubFcorr;

    residCorr = [residCorr; makeResidualCorrRow(y, "res_after_Tsub_vs_x_eq", resAfterTsub, paired.x_eq, ok1)]; %#ok<AGROW>
    residCorr = [residCorr; makeResidualCorrRow(y, "res_after_x_eq_vs_Tsub", resAfterXeq, paired.Tsub_K, ok2)]; %#ok<AGROW>
    residCorr = [residCorr; makeResidualCorrRow(y, "res_after_Fcorr_vs_x_eq", resAfterFcorr, paired.x_eq, ok3)]; %#ok<AGROW>
    residCorr = [residCorr; makeResidualCorrRow(y, "res_after_Tsub_Fcorr_vs_x_eq", resAfterTsubFcorr, paired.x_eq, ok4)]; %#ok<AGROW>
end

incremental = sortrows(incremental, ["response","test"], ["ascend","ascend"]);
residCorr = sortrows(residCorr, ["response","test"], ["ascend","ascend"]);

%% ===== Focus tables =====

PM_noF1_focus = incremental(incremental.response == "PM_noF1", :);
F1_effect_focus = incremental(ismember(incremental.response, ["delta_PM","lift_ratio"]), :);

%% ===== Interpretation flags =====

flags = makeInterpretationFlags(Tsub_xeq_relation, modelCompare, incremental, residCorr);

%% ===== Write Excel =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(responseDef, outXlsx, 'Sheet', 'definitions_response');
writetable(predictorDef, outXlsx, 'Sheet', 'definitions_predictor');
writetable(caseSummary, outXlsx, 'Sheet', 'BT05_case_summary');
writetable(Tsub_xeq_relation, outXlsx, 'Sheet', 'BT05_Tsub_xeq_relation');
writetable(modelCompare, outXlsx, 'Sheet', 'BT05_model_compare_DIAG');
writetable(incremental, outXlsx, 'Sheet', 'BT05_incremental_R2');
writetable(residCorr, outXlsx, 'Sheet', 'BT05_residualized_corr');
writetable(PM_noF1_focus, outXlsx, 'Sheet', 'BT05_PM_noF1_focus');
writetable(F1_effect_focus, outXlsx, 'Sheet', 'BT05_F1_effect_focus');
writetable(flags, outXlsx, 'Sheet', 'BT05_interpretation_flags');
writetable(residPoints, outXlsx, 'Sheet', 'BT05_residual_points');
writetable(paired, outXlsx, 'Sheet', 'BT05_paired_points');
writetable(detail, outXlsx, 'Sheet', 'BT05_point_detail');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Write Markdown report =====

md = strings(0,1);

md(end+1) = "# BT05 Tsub-x_eq separation diagnostic";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT04では、PM_noF1およびF1効果量がL/DHやz_DNB/DHよりもTsub/x_eq側と対応することを確認した。BT05では、x_eqがTsubの単なる代理なのか、それともTsubにない追加説明力を持つのかを確認する。";
md(end+1) = "";
md(end+1) = "## 2. 入力と出力";
md(end+1) = "";
md(end+1) = "- 入力: `" + inputFile + "`";
md(end+1) = "- 出力Excel: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 3. 前提";
md(end+1) = "";
md(end+1) = "- r8 resultブックは直接読まない。";
md(end+1) = "- current_bundle_inputを読む。";
md(end+1) = "- F2/F1F2は使わない。";
md(end+1) = "- 比較対象はnoF1とF1のみ。";
md(end+1) = "- バンドルでは `x_Mes = x_eq` として扱う。";
md(end+1) = "- F1は単管基準のTsub補正である。";
md(end+1) = "- BT05では補正式を作らず、F1(Tsub)も置換しない。";
md(end+1) = "";
md(end+1) = "## 4. Case summary";
md(end+1) = "";
showCase = {'case_id','N','PM_noF1_mean','PM_F1_mean','delta_PM_mean','lift_ratio_mean','Tsub_K_mean','x_eq_mean','Fcorr_mean','F_form_mean','z_DNB_over_DH_mean','L_over_DH_mean'};
md(end+1) = tableToMarkdown(caseSummary(:, showCase));
md(end+1) = "";
md(end+1) = "## 5. Tsub-x_eq relation";
md(end+1) = "";
md(end+1) = tableToMarkdown(Tsub_xeq_relation);
md(end+1) = "";
md(end+1) = "## 6. Model comparison";
md(end+1) = "";
md(end+1) = "注：探索的診断であり、係数・R2を補正式として採用しない。";
md(end+1) = "";
md(end+1) = tableToMarkdown(modelCompare);
md(end+1) = "";
md(end+1) = "## 7. Incremental R2";
md(end+1) = "";
md(end+1) = "x_eq after Tsub が大きければ、x_eqはTsubにない追加説明力を持つ可能性がある。Tsub after x_eq が大きければ、Tsub側に残る説明力が大きい。";
md(end+1) = "";
md(end+1) = tableToMarkdown(incremental);
md(end+1) = "";
md(end+1) = "## 8. Residualized correlations";
md(end+1) = "";
md(end+1) = "Tsubで説明した後の残差がx_eqとまだ対応するか、またはx_eqで説明した後の残差がTsubとまだ対応するかを確認する。";
md(end+1) = "";
md(end+1) = tableToMarkdown(residCorr);
md(end+1) = "";
md(end+1) = "## 9. PM_noF1 focus";
md(end+1) = "";
md(end+1) = tableToMarkdown(PM_noF1_focus);
md(end+1) = "";
md(end+1) = "## 10. F1 effect focus";
md(end+1) = "";
md(end+1) = tableToMarkdown(F1_effect_focus);
md(end+1) = "";
md(end+1) = "## 11. Interpretation flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(flags);
md(end+1) = "";
md(end+1) = "## 12. 次アクション";
md(end+1) = "";
md(end+1) = "1. BT05_interpretation_flagsを確認する。";
md(end+1) = "2. PM_noF1で、x_eq after Tsub がどの程度残るか確認する。";
md(end+1) = "3. delta_PM / lift_ratioで、x_eq after Tsub または x_eq after Fcorr がどの程度残るか確認する。";
md(end+1) = "4. x_eqがTsubの代理に近いなら、F1(Tsub)置換は急がない。";
md(end+1) = "5. x_eqに追加説明力があるなら、BT06でF1(Tsub)を維持したままx_eqを診断項としてどう扱うか設計する。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display quick result =====

disp("=== BT05 Tsub-xeq relation ===");
disp(Tsub_xeq_relation);

disp("=== BT05 incremental R2 ===");
disp(incremental);

disp("=== BT05 interpretation flags ===");
disp(flags);

%% ===== Local functions =====

function latest = findLatestFile(pattern)
    d = dir(pattern);
    if isempty(d)
        error("No file matching pattern: %s", pattern);
    end
    [~, idx] = max([d.datenum]);
    latest = string(d(idx).name);
end

function T = readSheetAsTable(inFile, sheetName)
    opts = detectImportOptions(inFile, 'Sheet', sheetName);
    opts.VariableNamingRule = 'preserve';
    T = readtable(inFile, opts);
end

function D = makeDetail(T, corr, cid, sh)

    n = height(T);

    qP = getNumCol(T, ["q_P","qP","q_calc","qCalc"]);
    qM = getNumCol(T, ["q_M","qM","q_exp","qExp"]);

    Tin  = getNumCol(T, ["Tin"]);
    Tsat = getNumCol(T, ["Ts","Tsat"]);
    Tsub = getNumCol(T, ["Tsub"]);

    Fcorr = getNumCol(T, ["Fcorr","F_corr","F1corr"]);

    xMes = getNumCol(T, ["x_Mes","xMes","x_EQ","xeq","x_eq"]);

    L_DNB = getNumCol(T, ["L_DNB","LDNB","z_DNB","zDNB"]);
    DH    = getNumCol(T, ["DH","D_h","Dh"]);
    L     = getNumCol(T, ["L","HeatedLength","L_heat"]);

    Tm = getNumCol(T, ["Tm"]);
    Tw = getNumCol(T, ["Tw"]);

    F_form = getNumCol(T, ["F_form"]);

    No = getNumCol(T, ["No"]);
    No_TableNo = getTextCol(T, ["No_TableNo","Case","case"]);

    D = table();
    D.correction = repmat(string(corr), n, 1);
    D.case_id    = repmat(string(cid), n, 1);
    D.sheet_name = repmat(string(sh), n, 1);

    D.No_TableNo = No_TableNo;
    D.No = No;

    D.q_exp_Wm2 = qM;
    D.q_calc_Wm2 = qP;
    D.q_exp_MWm2 = qM ./ 1e6;
    D.q_calc_MWm2 = qP ./ 1e6;
    D.PM = qP ./ qM;

    D.Tin_K  = Tin;
    D.Tsat_K = Tsat;
    D.Tsub_K = Tsub;

    D.Fcorr = Fcorr;

    % バンドル側では x_Mes = x_eq として扱う。
    D.x_eq = xMes;

    D.DH_m = DH;
    D.L_m = L;
    D.L_over_DH = L ./ DH;

    D.z_DNB_m = L_DNB;
    D.z_DNB_over_L  = L_DNB ./ L;
    D.z_DNB_over_DH = L_DNB ./ DH;

    D.Tm_K = Tm;
    D.Tw_K = Tw;
    D.Tw_minus_Tsat_K = Tw - Tsat;
    D.Tm_minus_Tsat_K = Tm - Tsat;

    D.F_form = F_form;
end

function row = fitLinearModelSummary(T, targetVar, predictors)
    row = table();

    y = T.(targetVar);
    X = [];
    ok = isfinite(y);

    for p = string(predictors)
        if ~ismember(p, string(T.Properties.VariableNames))
            ok(:) = false;
            continue;
        end
        x = T.(p);
        ok = ok & isfinite(x);
        X = [X, x]; %#ok<AGROW>
    end

    row.N = sum(ok);
    row.k_predictors = numel(predictors);

    if row.N <= numel(predictors) + 1
        row.R2 = NaN;
        row.RMSE = NaN;
        row.beta_0 = NaN;
        row.beta_1 = NaN;
        row.note = "N不足または自由度不足";
        return;
    end

    Xok = X(ok,:);
    yok = y(ok);

    Xdesign = [ones(size(Xok,1),1), Xok];
    beta = Xdesign \ yok;
    yhat = Xdesign * beta;

    ss_res = sum((yok - yhat).^2);
    ss_tot = sum((yok - mean(yok)).^2);

    if ss_tot > 0
        row.R2 = 1 - ss_res/ss_tot;
    else
        row.R2 = NaN;
    end
    row.RMSE = sqrt(mean((yok - yhat).^2));
    row.beta_0 = beta(1);
    if numel(beta) >= 2
        row.beta_1 = beta(2);
    else
        row.beta_1 = NaN;
    end
    row.note = "DIAG_ONLY: 補正式係数として採用しない";
end

function row = makeIncrementRow(T, response, basePredictors, fullPredictors, testName)
    base = fitLinearModelSummary(T, response, basePredictors);
    full = fitLinearModelSummary(T, response, fullPredictors);

    row = table();
    row.response = response;
    row.test = string(testName);
    row.base_predictors = strjoin(string(basePredictors), " + ");
    row.full_predictors = strjoin(string(fullPredictors), " + ");
    row.N = full.N;
    row.R2_base = base.R2;
    row.R2_full = full.R2;
    row.delta_R2 = full.R2 - base.R2;
    row.RMSE_base = base.RMSE;
    row.RMSE_full = full.RMSE;
    row.delta_RMSE = full.RMSE - base.RMSE;
    row.note = "DIAG_ONLY: 追加説明力の確認であり補正式ではない";
end

function [res, ok] = modelResidual(T, response, predictors)
    y = T.(response);
    X = [];
    ok = isfinite(y);

    for p = string(predictors)
        if ~ismember(p, string(T.Properties.VariableNames))
            ok(:) = false;
            continue;
        end
        x = T.(p);
        ok = ok & isfinite(x);
        X = [X, x]; %#ok<AGROW>
    end

    res = NaN(height(T),1);
    if sum(ok) <= numel(predictors) + 1
        return;
    end

    Xok = X(ok,:);
    yok = y(ok);
    Xdesign = [ones(size(Xok,1),1), Xok];
    beta = Xdesign \ yok;
    yhat = Xdesign * beta;
    res(ok) = yok - yhat;
end

function row = makeResidualCorrRow(response, testName, residual, predictor, okModel)
    ok = okModel & isfinite(residual) & isfinite(predictor);

    row = table();
    row.response = string(response);
    row.test = string(testName);
    row.N = sum(ok);

    if row.N >= 3
        C = corrcoef(residual(ok), predictor(ok));
        row.pearson_r = C(1,2);
        p = polyfit(predictor(ok), residual(ok), 1);
        yhat = polyval(p, predictor(ok));
        ss_res = sum((residual(ok) - yhat).^2);
        ss_tot = sum((residual(ok) - mean(residual(ok))).^2);
        row.slope = p(1);
        row.intercept = p(2);
        if ss_tot > 0
            row.R2 = 1 - ss_res/ss_tot;
        else
            row.R2 = NaN;
        end
    else
        row.pearson_r = NaN;
        row.slope = NaN;
        row.intercept = NaN;
        row.R2 = NaN;
    end
    row.note = "residualized diagnostic only";
end

function flags = makeInterpretationFlags(Tsub_xeq_relation, modelCompare, incremental, residCorr)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("BT05位置づけ", "OK", "", "Tsubとx_eqの切り分け診断。F1置換や補正式化ではない。");
    add("Tsub_xeq_relation", "diagnostic", sprintf("R2=%.6g", Tsub_xeq_relation.R2), "Tsubとx_eqの共変が強いほど、x_eq相関はTsub代理の可能性がある。");

    for resp = ["PM_noF1","delta_PM","lift_ratio","PM_F1"]
        rT = getModelR2(modelCompare, resp, "Tsub only");
        rX = getModelR2(modelCompare, resp, "x_eq only");
        rTX = getModelR2(modelCompare, resp, "Tsub + x_eq");
        dXafterT = getIncR2(incremental, resp, "x_eq_after_Tsub");
        dTafterX = getIncR2(incremental, resp, "Tsub_after_x_eq");
        rResAfterT = getResR2(residCorr, resp, "res_after_Tsub_vs_x_eq");
        rResAfterX = getResR2(residCorr, resp, "res_after_x_eq_vs_Tsub");

        add("compare_" + resp, "diagnostic", ...
            sprintf("R2_Tsub=%.6g, R2_xeq=%.6g, R2_Tsub_xeq=%.6g", rT, rX, rTX), ...
            "Tsub単独、x_eq単独、両者併用の説明力を比較する。");

        add("increment_" + resp, "diagnostic", ...
            sprintf("dR2_xeq_after_Tsub=%.6g, dR2_Tsub_after_xeq=%.6g", dXafterT, dTafterX), ...
            "x_eqがTsub後に残るか、Tsubがx_eq後に残るかを見る。");

        add("residualized_" + resp, "diagnostic", ...
            sprintf("resAfterTsub_vs_xeq_R2=%.6g, resAfterXeq_vs_Tsub_R2=%.6g", rResAfterT, rResAfterX), ...
            "残差化しても相関が残るかを見る。これも補正式ではない。");
    end

    for resp = ["delta_PM","lift_ratio"]
        dXafterF = getIncR2(incremental, resp, "x_eq_after_Fcorr");
        dXafterTF = getIncR2(incremental, resp, "x_eq_after_Tsub_and_Fcorr");
        add("F1_effect_xeq_after_Fcorr_" + resp, "diagnostic", ...
            sprintf("dR2_xeq_after_Fcorr=%.6g, dR2_xeq_after_Tsub_Fcorr=%.6g", dXafterF, dXafterTF), ...
            "F1効果量について、現行FcorrまたはTsub+Fcorrで説明した後にx_eqが残るかを見る。");
    end

    add("BT05判断ゲート", "hold", "", "x_eqに追加説明力が小さければ、F1(Tsub)置換は急がない。追加説明力が残る場合のみ、BT06で診断項としての扱いを設計する。");

    flags = table(item, status, value, reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function r2 = getModelR2(T, response, model)
    idx = find(T.response == response & T.model == model, 1);
    if isempty(idx)
        r2 = NaN;
    else
        r2 = T.R2(idx);
    end
end

function d = getIncR2(T, response, test)
    idx = find(T.response == response & T.test == test, 1);
    if isempty(idx)
        d = NaN;
    else
        d = T.delta_R2(idx);
    end
end

function r2 = getResR2(T, response, test)
    idx = find(T.response == response & T.test == test, 1);
    if isempty(idx)
        r2 = NaN;
    else
        r2 = T.R2(idx);
    end
end

function r = corrOne(a,b)
    ok = isfinite(a) & isfinite(b);
    if sum(ok) < 3
        r = NaN;
    else
        C = corrcoef(a(ok), b(ok));
        r = C(1,2);
    end
end

function r = safeRatio(a, b)
    r = NaN(size(a));
    ok = isfinite(a) & isfinite(b) & abs(b) > 0;
    r(ok) = a(ok) ./ b(ok);
end

function v = getNumCol(T, candidates)
    name = findColumn(T, candidates);
    if strlength(name) == 0
        v = NaN(height(T),1);
        return;
    end

    raw = T.(name);
    if isnumeric(raw)
        v = raw;
    elseif iscell(raw)
        v = str2double(string(raw));
    else
        v = str2double(string(raw));
    end

    v = double(v);
end

function v = getTextCol(T, candidates)
    name = findColumn(T, candidates);
    if strlength(name) == 0
        v = strings(height(T),1);
        return;
    end
    v = string(T.(name));
end

function name = findColumn(T, candidates)
    vars = string(T.Properties.VariableNames);

    for c = string(candidates)
        idx = find(vars == c, 1);
        if ~isempty(idx)
            name = vars(idx);
            return;
        end
    end

    normVars = normalizeNames(vars);
    for c = string(candidates)
        nc = normalizeNames(c);
        idx = find(normVars == nc, 1);
        if ~isempty(idx)
            name = vars(idx);
            return;
        end
    end

    name = "";
end

function s = normalizeNames(s)
    s = lower(string(s));
    s = replace(s, "σ", "sigma");
    s = regexprep(s, "[^a-z0-9]", "");
end

function md = tableToMarkdown(T)
    vars = string(T.Properties.VariableNames);

    lines = strings(0,1);
    lines(end+1) = "| " + strjoin(vars, " | ") + " |";
    lines(end+1) = "| " + strjoin(repmat("---", 1, numel(vars)), " | ") + " |";

    for i = 1:height(T)
        row = strings(1, numel(vars));
        for j = 1:numel(vars)
            val = T{i,j};

            if isnumeric(val)
                if isscalar(val)
                    if isnan(val)
                        row(j) = "";
                    else
                        row(j) = string(sprintf("%.6g", val));
                    end
                else
                    row(j) = "[array]";
                end
            elseif islogical(val)
                row(j) = string(val);
            elseif isstring(val)
                row(j) = val;
            elseif iscell(val)
                row(j) = string(val{1});
            else
                row(j) = string(val);
            end

            row(j) = replace(row(j), "|", "/");
            row(j) = replace(row(j), newline, " ");
        end
        lines(end+1) = "| " + strjoin(row, " | ") + " |";
    end

    md = strjoin(lines, newline);
end
