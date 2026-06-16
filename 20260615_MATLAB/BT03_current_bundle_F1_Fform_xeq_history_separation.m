%% BT03_current_bundle_F1_Fform_xeq_history_separation.m
% BT03：current_bundle入力で、F1(Tsub)・F_form・x_eq・履歴長を分けて見る
%
% 目的：
%   BT01/BT02で確認した
%     「F1後のP/Mは108が相対的に高く、161/164がやや低い」
%   という状態について、次の要素を分離して確認する。
%
%   1. F1(Tsub)そのもの
%   2. Fcorr
%   3. F_form
%   4. x_eq
%   5. z_DNB/DH
%   6. z_DNB/L
%   7. L/DH
%
% 重要前提：
%   - r8 resultブックは直接読まない。
%   - BT00-1で作成した current_bundle_input を読む。
%   - F2は使わない。
%   - F1F2は使わない。
%   - 比較対象は noF1 と F1 のみ。
%   - バンドルでは x_Mes = x_eq として扱う。
%   - F1は単管基準のTsub補正。
%   - F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。
%   - このrunでは補正式を作らない。対応関係の分離診断に限定する。
%
% 入力：
%   H52Q_current_bundle_input_v1_*.xlsx
%
% 出力：
%   BT03_current_bundle_F1_Fform_xeq_history_separation_yyyymmdd_HHMMSS.xlsx
%   run_report_BT03_current_bundle_F1_Fform_xeq_history_separation_yyyymmdd_HHMMSS.md
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

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "BT03_current_bundle_F1_Fform_xeq_history_separation_" + timestamp + ".xlsx";
outMd   = "run_report_BT03_current_bundle_F1_Fform_xeq_history_separation_" + timestamp + ".md";

sheetMap = table( ...
    ["noF1"; "noF1"; "noF1"; "F1"; "F1"; "F1"], ...
    ["108";  "161";  "164";  "108"; "161"; "164"], ...
    ["tm_108"; "tm_161"; "tm_164"; "tm_F1_108"; "tm_F1_161"; "tm_F1_164"], ...
    'VariableNames', {'correction','case_id','sheet_name'} ...
);

if ~isfile(inputFile)
    error("current_bundle input file not found: %s", inputFile);
end

fprintf("Input current_bundle: %s\n", inputFile);

%% ===== Read and normalize point detail =====

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

        row.q_exp_MWm2 = B.q_exp_MWm2;

        row.q_calc_noF1_MWm2 = A.q_calc_MWm2;
        row.q_calc_F1_MWm2   = B.q_calc_MWm2;

        row.PM_noF1 = A.PM;
        row.PM_F1   = B.PM;
        row.delta_PM = B.PM - A.PM;

        row.qcalc_lift_ratio = safeRatio(B.q_calc_MWm2, A.q_calc_MWm2);
        row.PM_lift_ratio = safeRatio(B.PM, A.PM);

        row.Tsub_K = B.Tsub_K;
        row.Fcorr = B.Fcorr;
        row.A_corr = B.A_corr;
        row.sigma_corr = B.sigma_corr;
        row.F1_formula_from_Tsub = B.F1_formula_from_Tsub;

        row.F_form = B.F_form;
        row.x_eq = B.x_eq;

        row.z_DNB_over_DH = B.z_DNB_over_DH;
        row.z_DNB_over_L = B.z_DNB_over_L;
        row.L_over_DH = B.L_over_DH;

        row.Tw_minus_Tsat_K = B.Tw_minus_Tsat_K;
        row.Tm_minus_Tsat_K = B.Tm_minus_Tsat_K;

        row.has_formula_F1 = isfinite(B.F1_formula_from_Tsub);

        paired = [paired; row]; %#ok<AGROW>
    end
end

%% ===== Case-level summary =====

caseSummary = table();

for cid = ["108","161","164"]
    S = paired(paired.case_id == cid, :);

    row = table();
    row.case_id = cid;
    row.N = height(S);

    row.q_exp_MWm2_mean = mean(S.q_exp_MWm2, 'omitnan');
    row.q_calc_noF1_MWm2_mean = mean(S.q_calc_noF1_MWm2, 'omitnan');
    row.q_calc_F1_MWm2_mean = mean(S.q_calc_F1_MWm2, 'omitnan');

    row.PM_noF1_mean = mean(S.PM_noF1, 'omitnan');
    row.PM_F1_mean = mean(S.PM_F1, 'omitnan');
    row.delta_PM_mean = mean(S.delta_PM, 'omitnan');

    row.qcalc_lift_ratio_mean = mean(S.qcalc_lift_ratio, 'omitnan');
    row.PM_lift_ratio_mean = mean(S.PM_lift_ratio, 'omitnan');

    row.Tsub_K_mean = mean(S.Tsub_K, 'omitnan');
    row.Fcorr_mean = mean(S.Fcorr, 'omitnan');
    row.F1_formula_from_Tsub_mean = mean(S.F1_formula_from_Tsub, 'omitnan');
    row.F_form_mean = mean(S.F_form, 'omitnan');
    row.x_eq_mean = mean(S.x_eq, 'omitnan');

    row.z_DNB_over_DH_mean = mean(S.z_DNB_over_DH, 'omitnan');
    row.z_DNB_over_L_mean = mean(S.z_DNB_over_L, 'omitnan');
    row.L_over_DH_mean = mean(S.L_over_DH, 'omitnan');

    row.Tw_minus_Tsat_K_mean = mean(S.Tw_minus_Tsat_K, 'omitnan');
    row.Tm_minus_Tsat_K_mean = mean(S.Tm_minus_Tsat_K, 'omitnan');

    caseSummary = [caseSummary; row]; %#ok<AGROW>
end

%% ===== 108 contrast vs mean(161,164) =====

contrast = makeContrast(caseSummary);

%% ===== Ranked variables by 108 contrast magnitude =====

rankedContrast = contrast;
rankedContrast.abs_relative_delta = abs(rankedContrast.delta_108_minus_mean_161_164) ./ max(abs(rankedContrast.mean_161_164), eps);
rankedContrast = sortrows(rankedContrast, "abs_relative_delta", "descend");

%% ===== Bucket summary =====

bucketSummary = makeBucketSummary(contrast);

%% ===== Point-level and case-level correlation diagnostics =====

targetVars = [
    "PM_F1"
    "delta_PM"
    "qcalc_lift_ratio"
    "PM_lift_ratio"
];

stateVars = [
    "Tsub_K"
    "Fcorr"
    "F1_formula_from_Tsub"
    "F_form"
    "x_eq"
    "z_DNB_over_DH"
    "z_DNB_over_L"
    "L_over_DH"
    "Tw_minus_Tsat_K"
    "Tm_minus_Tsat_K"
];

pointCorr = calcCorrTable(paired, targetVars, stateVars, "point_level");

% case平均相関はN=3のため参考のみ。
caseCorrInput = caseSummary;
caseCorrInput.PM_F1 = caseCorrInput.PM_F1_mean;
caseCorrInput.delta_PM = caseCorrInput.delta_PM_mean;
caseCorrInput.qcalc_lift_ratio = caseCorrInput.qcalc_lift_ratio_mean;
caseCorrInput.PM_lift_ratio = caseCorrInput.PM_lift_ratio_mean;
caseCorrInput.Tsub_K = caseCorrInput.Tsub_K_mean;
caseCorrInput.Fcorr = caseCorrInput.Fcorr_mean;
caseCorrInput.F1_formula_from_Tsub = caseCorrInput.F1_formula_from_Tsub_mean;
caseCorrInput.F_form = caseCorrInput.F_form_mean;
caseCorrInput.x_eq = caseCorrInput.x_eq_mean;
caseCorrInput.z_DNB_over_DH = caseCorrInput.z_DNB_over_DH_mean;
caseCorrInput.z_DNB_over_L = caseCorrInput.z_DNB_over_L_mean;
caseCorrInput.L_over_DH = caseCorrInput.L_over_DH_mean;
caseCorrInput.Tw_minus_Tsat_K = caseCorrInput.Tw_minus_Tsat_K_mean;
caseCorrInput.Tm_minus_Tsat_K = caseCorrInput.Tm_minus_Tsat_K_mean;

caseCorr = calcCorrTable(caseCorrInput, targetVars, stateVars, "case_mean_N3");

%% ===== Simple two-step residual diagnostics =====
% BT03では補正式を作らないが、
% 「F1(Tsub)だけでPM_F1が説明できるか」
% 「F_formや履歴長を追加すると見かけ上どれだけ整理されるか」
% を探索的に見る。
%
% Nが少なくケース構造が強いので、係数は採用しない。

modelCompare = table();

candidateModels = {
    "PM_F1 ~ Tsub",                 ["Tsub_K"];
    "PM_F1 ~ Fcorr",                ["Fcorr"];
    "PM_F1 ~ F_form",               ["F_form"];
    "PM_F1 ~ x_eq",                 ["x_eq"];
    "PM_F1 ~ z_DNB/DH",             ["z_DNB_over_DH"];
    "PM_F1 ~ z_DNB/L",              ["z_DNB_over_L"];
    "PM_F1 ~ L/DH",                 ["L_over_DH"];
    "PM_F1 ~ Tsub + F_form",        ["Tsub_K","F_form"];
    "PM_F1 ~ Tsub + x_eq",          ["Tsub_K","x_eq"];
    "PM_F1 ~ Tsub + z_DNB/DH",      ["Tsub_K","z_DNB_over_DH"];
    "PM_F1 ~ Fcorr + F_form",       ["Fcorr","F_form"];
    "PM_F1 ~ Fcorr + x_eq",         ["Fcorr","x_eq"];
    "PM_F1 ~ Fcorr + z_DNB/DH",     ["Fcorr","z_DNB_over_DH"];
    "PM_F1 ~ F_form + x_eq",        ["F_form","x_eq"];
    "PM_F1 ~ F_form + z_DNB/DH",    ["F_form","z_DNB_over_DH"];
    "PM_F1 ~ x_eq + z_DNB/DH",      ["x_eq","z_DNB_over_DH"];
    "PM_F1 ~ Tsub + F_form + x_eq + z_DNB/DH", ["Tsub_K","F_form","x_eq","z_DNB_over_DH"];
};

for i = 1:size(candidateModels,1)
    name = string(candidateModels{i,1});
    predictors = string(candidateModels{i,2});
    row = fitLinearModelSummary(paired, "PM_F1", predictors);
    row.model = name;
    row.predictors = strjoin(predictors, " + ");
    modelCompare = [modelCompare; row]; %#ok<AGROW>
end

% 列順を整える
modelCompare = movevars(modelCompare, ["model","predictors"], "Before", 1);
modelCompare = sortrows(modelCompare, "R2", "descend");

%% ===== Interpretation flags =====

flags = makeInterpretationFlags(contrast, pointCorr, modelCompare);

%% ===== Definitions =====

definitions = cell2table({
    "BT03", "BT01/BT02の再現確認後、F1(Tsub)・F_form・x_eq・履歴長を分ける診断。補正式は作らない。"
    "F1", "単管データに基づくTsub補正。"
    "Fcorr", "F1(Tsub)の補正係数として使われている列。"
    "F1_formula_from_Tsub", "A_corrとsigma_corrが存在する場合に、1 + A_corr*exp(-(Tsub-40)^2/sigma_corr)で再計算した値。"
    "F_form", "F1ではない。非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。"
    "x_eq", "バンドル側ではx_Mes列を熱平衡クオリティx_eqとして扱う。"
    "z_DNB/DH", "DNB位置までの水力等価直径基準の履歴長。"
    "z_DNB/L", "加熱長に対するDNB位置の相対位置。"
    "L/DH", "全加熱長の水力等価直径基準長さ。"
    "modelCompare", "探索的な線形整理。係数やR2を補正式として採用しない。"
}, 'VariableNames', {'name','definition'});

%% ===== Write Excel =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(definitions, outXlsx, 'Sheet', 'definitions');
writetable(caseSummary, outXlsx, 'Sheet', 'BT03_case_summary');
writetable(contrast, outXlsx, 'Sheet', 'BT03_108_contrast');
writetable(rankedContrast, outXlsx, 'Sheet', 'BT03_ranked_contrast');
writetable(bucketSummary, outXlsx, 'Sheet', 'BT03_bucket_summary');
writetable(pointCorr, outXlsx, 'Sheet', 'BT03_point_correlations');
writetable(caseCorr, outXlsx, 'Sheet', 'BT03_case_mean_corr_N3');
writetable(modelCompare, outXlsx, 'Sheet', 'BT03_model_compare_DIAG');
writetable(flags, outXlsx, 'Sheet', 'BT03_interpretation_flags');
writetable(paired, outXlsx, 'Sheet', 'BT03_paired_points');
writetable(detail, outXlsx, 'Sheet', 'BT03_point_detail');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Write Markdown report =====

md = strings(0,1);

md(end+1) = "# BT03 current_bundle: F1 / F_form / x_eq / history separation";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT01/BT02で確認した「F1後のP/Mは108が相対的に高く、161/164がやや低い」という状態について、F1(Tsub)、Fcorr、F_form、x_eq、z_DNB/DH、z_DNB/L、L/DHを分けて確認した。";
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
md(end+1) = "- F1は単管基準のTsub補正。";
md(end+1) = "- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。";
md(end+1) = "- 補正式は作らない。";
md(end+1) = "";
md(end+1) = "## 4. Case summary";
md(end+1) = "";
showCaseCols = {'case_id','N','q_exp_MWm2_mean','q_calc_noF1_MWm2_mean','q_calc_F1_MWm2_mean','PM_noF1_mean','PM_F1_mean','delta_PM_mean','qcalc_lift_ratio_mean','Tsub_K_mean','Fcorr_mean','F1_formula_from_Tsub_mean','F_form_mean','x_eq_mean','z_DNB_over_DH_mean','z_DNB_over_L_mean','L_over_DH_mean'};
md(end+1) = tableToMarkdown(caseSummary(:, showCaseCols));
md(end+1) = "";
md(end+1) = "## 5. 108 contrast against mean(161,164)";
md(end+1) = "";
md(end+1) = tableToMarkdown(contrast);
md(end+1) = "";
md(end+1) = "## 6. Bucket summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(bucketSummary);
md(end+1) = "";
md(end+1) = "## 7. Point-level correlation diagnostics";
md(end+1) = "";
md(end+1) = "注：相関は探索的診断であり、補正式係数ではない。";
md(end+1) = "";
md(end+1) = tableToMarkdown(pointCorr);
md(end+1) = "";
md(end+1) = "## 8. Case-mean correlation diagnostics";
md(end+1) = "";
md(end+1) = "注：ケース平均相関はN=3なので、順位や符号を強く読まない。";
md(end+1) = "";
md(end+1) = tableToMarkdown(caseCorr);
md(end+1) = "";
md(end+1) = "## 9. Exploratory model comparison";
md(end+1) = "";
md(end+1) = "注：探索的な線形整理であり、係数・R2を補正式として採用しない。";
md(end+1) = "";
md(end+1) = tableToMarkdown(modelCompare);
md(end+1) = "";
md(end+1) = "## 10. Interpretation flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(flags);
md(end+1) = "";
md(end+1) = "## 11. 次アクション";
md(end+1) = "";
md(end+1) = "1. BT03_interpretation_flagsを確認する。";
md(end+1) = "2. Fcorr/F1(Tsub)だけで108高めP/Mを説明できるかを見る。";
md(end+1) = "3. F_formはF1ではないため、非一様加熱・DNB位置・局所熱流束換算として読む。";
md(end+1) = "4. z_DNB/DH、z_DNB/L、L/DHは履歴長・ケース構造として読む。";
md(end+1) = "5. x_eqは単独因子ではなく、熱収支状態量としてF1(Tsub)見直し候補にする。";
md(end+1) = "6. BT03の結果をworking logへ追記してから、必要ならBT04でF1(Tsub)代替候補の設計に進む。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display quick result =====

disp("=== BT03 case summary ===");
disp(caseSummary(:, showCaseCols));

disp("=== BT03 108 contrast ===");
disp(contrast);

disp("=== BT03 bucket summary ===");
disp(bucketSummary);

disp("=== BT03 interpretation flags ===");
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

    A_corr = getNumCol(T, ["A_corr","Acorr","A"]);
    sigma_corr = getNumCol(T, ["σ_corr","sigma_corr","sigmacorr","sigma"]);

    F1_formula = NaN(n,1);
    okF1 = isfinite(A_corr) & isfinite(sigma_corr) & isfinite(Tsub) & sigma_corr ~= 0;
    F1_formula(okF1) = 1 + A_corr(okF1) .* exp(-((Tsub(okF1) - 40).^2) ./ sigma_corr(okF1));

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
    D.A_corr = A_corr;
    D.sigma_corr = sigma_corr;
    D.F1_formula_from_Tsub = F1_formula;

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

function contrast = makeContrast(caseSummary)

    metrics = [
        "q_exp_MWm2_mean"
        "q_calc_noF1_MWm2_mean"
        "q_calc_F1_MWm2_mean"
        "PM_noF1_mean"
        "PM_F1_mean"
        "delta_PM_mean"
        "qcalc_lift_ratio_mean"
        "PM_lift_ratio_mean"
        "Tsub_K_mean"
        "Fcorr_mean"
        "F1_formula_from_Tsub_mean"
        "F_form_mean"
        "x_eq_mean"
        "z_DNB_over_DH_mean"
        "z_DNB_over_L_mean"
        "L_over_DH_mean"
        "Tw_minus_Tsat_K_mean"
        "Tm_minus_Tsat_K_mean"
    ];

    S108 = caseSummary(caseSummary.case_id=="108", :);
    S161 = caseSummary(caseSummary.case_id=="161", :);
    S164 = caseSummary(caseSummary.case_id=="164", :);

    contrast = table();

    for m = metrics'
        row = table();
        row.metric = m;
        row.value_108 = S108.(m);
        row.value_161 = S161.(m);
        row.value_164 = S164.(m);
        row.mean_161_164 = mean([S161.(m), S164.(m)], 'omitnan');
        row.delta_108_minus_mean_161_164 = row.value_108 - row.mean_161_164;
        row.ratio_108_over_mean_161_164 = safeRatio(row.value_108, row.mean_161_164);

        contrast = [contrast; row]; %#ok<AGROW>
    end
end

function bucketSummary = makeBucketSummary(contrast)

    bucket = strings(0,1);
    variable = strings(0,1);
    value_108 = [];
    mean_161_164 = [];
    delta = [];
    ratio = [];
    reading = strings(0,1);

    add("F1_Tsub", "Tsub_K_mean", "108は161/164よりTsubが低い。F1(Tsub)上は差がある。");
    add("F1_Tsub", "Fcorr_mean", "Fcorr差は小さい。F1(Tsub)係数だけでPM差を説明しにくい可能性。");
    add("F1_Tsub", "F1_formula_from_Tsub_mean", "A_corrとsigma_corrが取得できた場合のF1再計算値。Fcorrと一致するかを確認する。");
    add("nonuniform_heat", "F_form_mean", "F_form差は大きい。ただしF_formはF1ではなく非一様加熱換算である。");
    add("thermal_state", "x_eq_mean", "108はx_eqが0に近い。ただしx_eq単独でPM差を説明できるとは限らない。");
    add("history", "z_DNB_over_DH_mean", "108はDNB位置までの履歴長が短い。履歴長候補として見る。");
    add("history", "z_DNB_over_L_mean", "108は相対的に上流側DNB寄り。z_DNB/DHとは別に見る。");
    add("history", "L_over_DH_mean", "108は全体L/DHが小さい。DNBまでの実効長と分けて読む。");
    add("wall_thermal", "Tw_minus_Tsat_K_mean", "108は壁面過熱が大きい。結果側・モデル内部量として読む。");
    add("wall_thermal", "Tm_minus_Tsat_K_mean", "108はTm-Tsatが低い。温度場・モデル内部量として読む。");

    bucketSummary = table(bucket, variable, value_108, mean_161_164, delta, ratio, reading);

    function add(b, varName, txt)
        idx = find(contrast.metric == varName, 1);
        bucket(end+1,1) = string(b);
        variable(end+1,1) = string(varName);

        if ~isempty(idx)
            value_108(end+1,1) = contrast.value_108(idx);
            mean_161_164(end+1,1) = contrast.mean_161_164(idx);
            delta(end+1,1) = contrast.delta_108_minus_mean_161_164(idx);
            ratio(end+1,1) = contrast.ratio_108_over_mean_161_164(idx);
        else
            value_108(end+1,1) = NaN;
            mean_161_164(end+1,1) = NaN;
            delta(end+1,1) = NaN;
            ratio(end+1,1) = NaN;
        end

        reading(end+1,1) = string(txt);
    end
end

function corrRows = calcCorrTable(T, targetVars, stateVars, levelName)

    corrRows = table();

    for tv = string(targetVars)'
        for sv = string(stateVars)'
            row = table();
            row.level = string(levelName);
            row.target = tv;
            row.state_var = sv;

            if ~ismember(tv, string(T.Properties.VariableNames)) || ~ismember(sv, string(T.Properties.VariableNames))
                row.N = 0;
                row.pearson_r = NaN;
                row.slope = NaN;
                row.intercept = NaN;
                row.R2 = NaN;
                corrRows = [corrRows; row]; %#ok<AGROW>
                continue;
            end

            x = T.(sv);
            y = T.(tv);

            ok = isfinite(x) & isfinite(y);
            row.N = sum(ok);

            if row.N >= 3
                C = corrcoef(x(ok), y(ok));
                row.pearson_r = C(1,2);

                p = polyfit(x(ok), y(ok), 1);
                yhat = polyval(p, x(ok));
                ss_res = sum((y(ok) - yhat).^2);
                ss_tot = sum((y(ok) - mean(y(ok))).^2);

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

            corrRows = [corrRows; row]; %#ok<AGROW>
        end
    end
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

    row.R2 = 1 - ss_res/ss_tot;
    row.RMSE = sqrt(mean((yok - yhat).^2));
    row.note = "DIAG_ONLY: 補正式係数として採用しない";
end

function flags = makeInterpretationFlags(contrast, pointCorr, modelCompare)

    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("current_bundle切替", "OK", "", "BT01/BT02はcurrent_bundleで再現済みなので、BT03もcurrent_bundle入力で進める。");

    pmDelta = getContrastDelta(contrast, "PM_F1_mean");
    fcorrDelta = getContrastDelta(contrast, "Fcorr_mean");
    fformDelta = getContrastDelta(contrast, "F_form_mean");
    xeqDelta = getContrastDelta(contrast, "x_eq_mean");
    zdhDelta = getContrastDelta(contrast, "z_DNB_over_DH_mean");
    ldhDelta = getContrastDelta(contrast, "L_over_DH_mean");

    add("PM_F1_108差", "observed", sprintf("delta108-mean161164=%.6g", pmDelta), "108のF1後P/Mは161/164平均より高い。");

    add("Fcorr差", "small", sprintf("delta=%.6g", fcorrDelta), "Fcorr差はPM差に比べて小さい。F1(Tsub)係数だけで108高めP/Mを説明するのは弱そう。");

    add("F_form差", "large_but_not_F1", sprintf("delta=%.6g", fformDelta), "F_form差は大きいが、F_formはF1ではない。非一様加熱・DNB位置・局所熱流束換算として読む。");

    add("x_eq差", "state_difference", sprintf("delta=%.6g", xeqDelta), "108はx_eqが0に近い。熱収支状態量として重要だが、単独原因とは断定しない。");

    add("z_DNB/DH差", "history_candidate", sprintf("delta=%.6g", zdhDelta), "108はDNB位置までの履歴長が短い。履歴長候補として見る。");

    add("L/DH差", "history_or_geometry_candidate", sprintf("delta=%.6g", ldhDelta), "108は全体L/DHも小さい。ただしz_DNB/DHと分けて読む。");

    rFcorr = getCorrR2(pointCorr, "PM_F1", "Fcorr");
    rFform = getCorrR2(pointCorr, "PM_F1", "F_form");
    rXeq = getCorrR2(pointCorr, "PM_F1", "x_eq");
    rZdh = getCorrR2(pointCorr, "PM_F1", "z_DNB_over_DH");
    rLdh = getCorrR2(pointCorr, "PM_F1", "L_over_DH");

    add("PM_F1_vs_Fcorr_R2", "diagnostic", sprintf("R2=%.6g", rFcorr), "PM_F1とFcorrの点群相関は弱い。");
    add("PM_F1_vs_F_form_R2", "diagnostic", sprintf("R2=%.6g", rFform), "PM_F1とF_formには中程度の対応があるが、原因とは断定しない。");
    add("PM_F1_vs_x_eq_R2", "diagnostic", sprintf("R2=%.6g", rXeq), "PM_F1とx_eqの点群相関は弱い。x_eq単独説明は弱い。");
    add("PM_F1_vs_z_DNB/DH_R2", "diagnostic", sprintf("R2=%.6g", rZdh), "PM_F1とDNB履歴長には中程度の対応がある。");
    add("PM_F1_vs_L/DH_R2", "diagnostic", sprintf("R2=%.6g", rLdh), "PM_F1とL/DHには比較的大きい対応があるが、ケース構造との交絡に注意。");

    if height(modelCompare) > 0
        best = modelCompare(1,:);
        add("model_compare_best_DIAG_ONLY", "diagnostic", "best=" + string(best.model) + ", R2=" + string(sprintf("%.6g", best.R2)), "探索的整理。補正式として採用しない。");
    end

    add("BT03判断", "hold", "", "BT03では、F1(Tsub)だけでなく、F_form、x_eq、DNB履歴長、L/DHが同時に変化していることを確認する。単独原因の断定はしない。");

    flags = table(item, status, value, reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function d = getContrastDelta(contrast, metricName)
    idx = find(contrast.metric == metricName, 1);
    if isempty(idx)
        d = NaN;
    else
        d = contrast.delta_108_minus_mean_161_164(idx);
    end
end

function r2 = getCorrR2(pointCorr, target, state)
    idx = find(pointCorr.target == target & pointCorr.state_var == state, 1);
    if isempty(idx)
        r2 = NaN;
    else
        r2 = pointCorr.R2(idx);
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
