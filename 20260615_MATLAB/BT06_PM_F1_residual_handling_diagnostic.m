%% BT06_PM_F1_residual_handling_diagnostic.m
% BT06：F1(Tsub)維持前提でのPM_F1残差の扱い整理
%
% 目的：
%   BT05で、x_eqはTsubに対する追加説明力が小さく、
%   F1(Tsub)をF(x_eq)へ置換する根拠は弱いと判断した。
%
%   したがってBT06では、F1(Tsub)をいったん維持する。
%   そのうえで、F1後に残るPM_F1残差を、
%     - F_formを含む非一様加熱換算の問題
%     - DNB位置・z_DNB/DH・z_DNB/Lのケース構造
%     - L/DHの見かけ相関
%     - 108/161/164の適用範囲・代表性
%     - 補正式化せず診断課題として残す方針
%   のどれとして扱うべきかを整理する。
%
% 重要：
%   - 補正式は作らない。
%   - F1(Tsub)は置換しない。
%   - F_formをF1の効き方として読まない。
%   - PM_F1とL/DHの相関だけでL/DH効果と断定しない。
%   - 3ケースだけで係数を作らない。
%
% 入力：
%   H52Q_current_bundle_input_v1_*.xlsx
%
% 出力：
%   BT06_PM_F1_residual_handling_diagnostic_yyyymmdd_HHMMSS.xlsx
%   run_report_BT06_PM_F1_residual_handling_diagnostic_yyyymmdd_HHMMSS.md
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

outXlsx = "BT06_PM_F1_residual_handling_diagnostic_" + timestamp + ".xlsx";
outMd   = "run_report_BT06_PM_F1_residual_handling_diagnostic_" + timestamp + ".md";

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
        row.err_F1 = B.PM - 1;
        row.abs_err_F1 = abs(B.PM - 1);
        row.delta_PM = B.PM - A.PM;
        row.lift_ratio = safeRatio(B.PM, A.PM);

        % F1 effect normalized in two ways.
        row.delta_PM_per_Fcorr_minus1 = safeRatio(row.delta_PM, B.Fcorr - 1);
        row.lift_minus1_per_Fcorr_minus1 = safeRatio(row.lift_ratio - 1, B.Fcorr - 1);

        % axes
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

        paired = [paired; row]; %#ok<AGROW>
    end
end

%% ===== Definitions =====

responseDef = cell2table({
    "PM_F1", "F1後のP/M。1に近いほど一致。"
    "err_F1", "F1後残差。PM_F1 - 1。正なら過大、負なら過小。"
    "abs_err_F1", "F1後残差の絶対値。"
    "delta_PM", "F1による持ち上げ量。PM_F1 - PM_noF1。"
    "lift_ratio", "F1による倍率効果。PM_F1 / PM_noF1。"
    "q_exp_MWm2", "実験熱流束。結果側量であり補正式入力ではない。"
    "q_calc_F1_MWm2", "F1後計算熱流束。"
}, 'VariableNames', {'response','meaning'});

axisDef = cell2table({
    "F_form", "nonuniform_heat", "非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。F1ではない。"
    "z_DNB_over_DH", "effective_history", "DNB位置までの水力等価直径基準の実効履歴長。"
    "z_DNB_over_L", "relative_DNB_position", "DNB位置の相対位置。出口寄り/上流寄りを見る。"
    "L_over_DH", "geometry_length", "全加熱長の水力等価直径基準長さ。単純L/D補正式へ戻らないよう注意。"
    "Tsub_K", "F1_Tsub", "現行F1の元変数。BT05でx_eqより優勢だった。"
    "Fcorr", "F1_Tsub", "現行F1(Tsub)の補正係数。FcorrだけではTsub情報を完全に代表しない可能性あり。"
    "x_eq", "thermal_state", "熱平衡クオリティ。BT05ではTsubへの追加説明力は小さかった。診断項として保留。"
    "Tw_minus_Tsat_K", "model_internal", "壁面過熱度。結果側・モデル内部量。補正式入力としては注意。"
    "Tm_minus_Tsat_K", "model_internal", "平均液温と飽和温度の差。結果側・モデル内部量。補正式入力としては注意。"
}, 'VariableNames', {'axis','group','meaning'});

%% ===== Case summary with CI =====

summaryVars = [
    "PM_noF1"
    "PM_F1"
    "err_F1"
    "abs_err_F1"
    "delta_PM"
    "lift_ratio"
    "q_exp_MWm2"
    "q_calc_F1_MWm2"
    "Tsub_K"
    "Fcorr"
    "x_eq"
    "F_form"
    "z_DNB_over_DH"
    "z_DNB_over_L"
    "L_over_DH"
    "Tw_minus_Tsat_K"
    "Tm_minus_Tsat_K"
];

caseSummary = table();

for cid = ["108","161","164"]
    S = paired(paired.case_id == cid, :);

    row = table();
    row.case_id = cid;
    row.N = height(S);

    for v = summaryVars'
        [m, sd, se, ciL, ciU] = meanStats(S.(v));
        row.(v + "_mean") = m;
        row.(v + "_sd") = sd;
        row.(v + "_se") = se;
        row.(v + "_ci95_low") = ciL;
        row.(v + "_ci95_high") = ciU;
    end

    caseSummary = [caseSummary; row]; %#ok<AGROW>
end

%% ===== 108 vs 161/164 contrast =====

contrast = table();

contrastVars = [
    "PM_F1"
    "err_F1"
    "abs_err_F1"
    "delta_PM"
    "lift_ratio"
    "q_exp_MWm2"
    "q_calc_F1_MWm2"
    "F_form"
    "z_DNB_over_DH"
    "z_DNB_over_L"
    "L_over_DH"
    "Tsub_K"
    "Fcorr"
    "x_eq"
];

for v = contrastVars'
    contrast = [contrast; make108Contrast(caseSummary, v + "_mean")]; %#ok<AGROW>
end

%% ===== Correlation diagnostics =====

responseVars = [
    "PM_F1"
    "err_F1"
    "abs_err_F1"
    "delta_PM"
    "lift_ratio"
];

axisVars = [
    "F_form"
    "z_DNB_over_DH"
    "z_DNB_over_L"
    "L_over_DH"
    "Tsub_K"
    "Fcorr"
    "x_eq"
    "Tw_minus_Tsat_K"
    "Tm_minus_Tsat_K"
];

corrPoint = calcCorr(paired, responseVars, axisVars, axisDef, "point_level");

% Axis-axis correlation to expose confounding.
axisCorr = calcAxisCorr(paired, axisVars, axisDef);

%% ===== Residualized correlations =====
% F1後残差 err_F1 を、BT05で主要とされたTsub/x_eq、
% および候補軸F_form / z_DNB/DHで残差化して確認する。
%
% ここでも補正式は作らない。

residualized = table();

target = "err_F1";

baseSets = {
    "after_Tsub", ["Tsub_K"];
    "after_Tsub_xeq", ["Tsub_K","x_eq"];
    "after_Fform", ["F_form"];
    "after_zDNB_DH", ["z_DNB_over_DH"];
    "after_LDH", ["L_over_DH"];
    "after_Fform_zDNB", ["F_form","z_DNB_over_DH"];
    "after_Tsub_xeq_Fform", ["Tsub_K","x_eq","F_form"];
    "after_Tsub_xeq_zDNB", ["Tsub_K","x_eq","z_DNB_over_DH"];
};

testAxes = ["F_form","z_DNB_over_DH","z_DNB_over_L","L_over_DH","Tsub_K","x_eq"];

for i = 1:size(baseSets,1)
    baseName = string(baseSets{i,1});
    predictors = string(baseSets{i,2});
    res = residualizeResponse(paired, target, predictors);

    for a = testAxes
        row = corrOne(res, paired.(a));
        row.target = target;
        row.base_model = baseName;
        row.base_predictors = strjoin(predictors, " + ");
        row.test_axis = a;
        residualized = [residualized; movevars(row, ["target","base_model","base_predictors","test_axis"], "Before", 1)]; %#ok<AGROW>
    end
end

%% ===== Model comparison =====
% DIAG_ONLY. 係数・R2を補正式として採用しない。

modelCompare = table();

modelSpecs = {
    "PM_F1 ~ F_form", ["F_form"], "PM_F1";
    "PM_F1 ~ z_DNB/DH", ["z_DNB_over_DH"], "PM_F1";
    "PM_F1 ~ z_DNB/L", ["z_DNB_over_L"], "PM_F1";
    "PM_F1 ~ L/DH", ["L_over_DH"], "PM_F1";
    "PM_F1 ~ Tsub", ["Tsub_K"], "PM_F1";
    "PM_F1 ~ x_eq", ["x_eq"], "PM_F1";
    "PM_F1 ~ Tsub + x_eq", ["Tsub_K","x_eq"], "PM_F1";
    "PM_F1 ~ F_form + z_DNB/DH", ["F_form","z_DNB_over_DH"], "PM_F1";
    "PM_F1 ~ F_form + L/DH", ["F_form","L_over_DH"], "PM_F1";
    "PM_F1 ~ z_DNB/DH + L/DH", ["z_DNB_over_DH","L_over_DH"], "PM_F1";
    "PM_F1 ~ Tsub + x_eq + F_form", ["Tsub_K","x_eq","F_form"], "PM_F1";
    "PM_F1 ~ Tsub + x_eq + z_DNB/DH", ["Tsub_K","x_eq","z_DNB_over_DH"], "PM_F1";
    "PM_F1 ~ Tsub + x_eq + L/DH", ["Tsub_K","x_eq","L_over_DH"], "PM_F1";
    "PM_F1 ~ Tsub + x_eq + F_form + z_DNB/DH", ["Tsub_K","x_eq","F_form","z_DNB_over_DH"], "PM_F1";

    "err_F1 ~ F_form", ["F_form"], "err_F1";
    "err_F1 ~ z_DNB/DH", ["z_DNB_over_DH"], "err_F1";
    "err_F1 ~ L/DH", ["L_over_DH"], "err_F1";
    "err_F1 ~ Tsub + x_eq + F_form + z_DNB/DH", ["Tsub_K","x_eq","F_form","z_DNB_over_DH"], "err_F1";

    "abs_err_F1 ~ F_form", ["F_form"], "abs_err_F1";
    "abs_err_F1 ~ z_DNB/DH", ["z_DNB_over_DH"], "abs_err_F1";
    "abs_err_F1 ~ L/DH", ["L_over_DH"], "abs_err_F1";
    "abs_err_F1 ~ Tsub + x_eq + F_form + z_DNB/DH", ["Tsub_K","x_eq","F_form","z_DNB_over_DH"], "abs_err_F1";
};

for i = 1:size(modelSpecs,1)
    modelName = string(modelSpecs{i,1});
    predictors = string(modelSpecs{i,2});
    response = string(modelSpecs{i,3});

    row = fitLinearModelSummary(paired, response, predictors);
    row.model = modelName;
    row.response = response;
    row.predictors = strjoin(predictors, " + ");
    modelCompare = [modelCompare; row]; %#ok<AGROW>
end

modelCompare = movevars(modelCompare, ["model","response","predictors"], "Before", 1);
modelCompare = sortrows(modelCompare, ["response","R2"], ["ascend","descend"]);

%% ===== Handling candidates =====

handling = makeHandlingTable(corrPoint, residualized, modelCompare, caseSummary, contrast, axisCorr);

%% ===== Interpretation flags =====

flags = makeInterpretationFlags(caseSummary, contrast, corrPoint, residualized, modelCompare, handling);

%% ===== Write Excel =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(responseDef, outXlsx, 'Sheet', 'definitions_response');
writetable(axisDef, outXlsx, 'Sheet', 'definitions_axis');
writetable(caseSummary, outXlsx, 'Sheet', 'BT06_case_summary');
writetable(contrast, outXlsx, 'Sheet', 'BT06_108_contrast');
writetable(corrPoint, outXlsx, 'Sheet', 'BT06_corr_PM_F1_axes');
writetable(axisCorr, outXlsx, 'Sheet', 'BT06_axis_axis_corr');
writetable(residualized, outXlsx, 'Sheet', 'BT06_residualized_corr');
writetable(modelCompare, outXlsx, 'Sheet', 'BT06_model_compare_DIAG');
writetable(handling, outXlsx, 'Sheet', 'BT06_handling_candidates');
writetable(flags, outXlsx, 'Sheet', 'BT06_interpretation_flags');
writetable(paired, outXlsx, 'Sheet', 'BT06_paired_points');
writetable(detail, outXlsx, 'Sheet', 'BT06_point_detail');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Write Markdown report =====

md = strings(0,1);

md(end+1) = "# BT06 PM_F1 residual handling diagnostic";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT05で、x_eqはTsubに対する追加説明力が小さく、F1(Tsub)をF(x_eq)へ置換する根拠は弱いと判断した。BT06では、F1(Tsub)をいったん維持したうえで、F1後に残るPM_F1残差を、F_form、DNB位置、z_DNB/DH、z_DNB/L、L/DH、ケース構造、適用範囲のどれとして扱うべきかを整理した。";
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
md(end+1) = "- F1(Tsub)は維持する。";
md(end+1) = "- F1(Tsub)をF(x_eq)へ置換しない。";
md(end+1) = "- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。";
md(end+1) = "- 補正式は作らない。";
md(end+1) = "- R2が高いモデルをそのまま採用しない。";
md(end+1) = "";
md(end+1) = "## 4. Case summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(caseSummary);
md(end+1) = "";
md(end+1) = "## 5. 108 versus mean(161,164)";
md(end+1) = "";
md(end+1) = tableToMarkdown(contrast);
md(end+1) = "";
md(end+1) = "## 6. PM_F1 residual correlations";
md(end+1) = "";
md(end+1) = "点群相関は探索的診断であり、補正式係数ではない。";
md(end+1) = "";
md(end+1) = tableToMarkdown(corrPoint);
md(end+1) = "";
md(end+1) = "## 7. Axis-axis correlations";
md(end+1) = "";
md(end+1) = "F_form、z_DNB/DH、z_DNB/L、L/DHなどの交絡を確認する。";
md(end+1) = "";
md(end+1) = tableToMarkdown(axisCorr);
md(end+1) = "";
md(end+1) = "## 8. Residualized correlations";
md(end+1) = "";
md(end+1) = "err_F1 = PM_F1 - 1 を、Tsub/x_eqやF_form、z_DNB/DHで説明した後、残差がどの軸とまだ対応するかを見る。";
md(end+1) = "";
md(end+1) = tableToMarkdown(residualized);
md(end+1) = "";
md(end+1) = "## 9. Exploratory model comparison";
md(end+1) = "";
md(end+1) = "探索的線形整理であり、補正式として採用しない。";
md(end+1) = "";
md(end+1) = tableToMarkdown(modelCompare);
md(end+1) = "";
md(end+1) = "## 10. Handling candidates";
md(end+1) = "";
md(end+1) = tableToMarkdown(handling);
md(end+1) = "";
md(end+1) = "## 11. Interpretation flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(flags);
md(end+1) = "";
md(end+1) = "## 12. 次アクション";
md(end+1) = "";
md(end+1) = "1. BT06_interpretation_flagsを確認する。";
md(end+1) = "2. F1後残差を補正式化すべきか、診断課題として残すべきか判断する。";
md(end+1) = "3. F_formとDNB位置・L/DHの交絡が強い場合は、F_form原因説やL/DH原因説を避ける。";
md(end+1) = "4. 次に進む場合は、F_form定義・非一様加熱換算・DNB位置の扱いを確認する。";
md(end+1) = "5. 単管側のST-BT05相当、すなわちHsub/P/Tsubとx_eqの切り分け診断は、後で忘れずに実施する。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display quick result =====

disp("=== BT06 case summary ===");
disp(caseSummary(:, ["case_id","N","PM_F1_mean","err_F1_mean","err_F1_ci95_low","err_F1_ci95_high","F_form_mean","z_DNB_over_DH_mean","L_over_DH_mean"]));

disp("=== BT06 handling candidates ===");
disp(handling);

disp("=== BT06 interpretation flags ===");
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

function [m, sd, se, ciL, ciU] = meanStats(x)
    ok = isfinite(x);
    n = sum(ok);
    if n == 0
        m = NaN; sd = NaN; se = NaN; ciL = NaN; ciU = NaN;
        return;
    end
    m = mean(x(ok), 'omitnan');
    sd = std(x(ok), 'omitnan');
    se = sd / sqrt(n);

    % approximate t critical. For n >= 10, 1.96 is fine for diagnostic use.
    % Use conservative fixed value for simplicity.
    tcrit = 1.96;
    ciL = m - tcrit * se;
    ciU = m + tcrit * se;
end

function out = make108Contrast(caseSummary, varName)
    S108 = caseSummary(caseSummary.case_id=="108", :);
    S161 = caseSummary(caseSummary.case_id=="161", :);
    S164 = caseSummary(caseSummary.case_id=="164", :);

    base = erase(string(varName), "_mean");

    out = table();
    out.name = base;
    out.value_108 = S108.(varName);
    out.value_161 = S161.(varName);
    out.value_164 = S164.(varName);
    out.mean_161_164 = mean([S161.(varName), S164.(varName)], 'omitnan');
    out.delta_108_minus_mean_161_164 = out.value_108 - out.mean_161_164;
    out.ratio_108_over_mean_161_164 = safeRatio(out.value_108, out.mean_161_164);
end

function C = calcCorr(T, responseVars, axisVars, axisDef, levelName)
    C = table();

    for r = string(responseVars)'
        for a = string(axisVars)'
            row = corrOne(T.(r), T.(a));
            row.level = string(levelName);
            row.response = r;
            row.axis = a;

            idx = find(axisDef.axis == a, 1);
            if isempty(idx)
                row.axis_group = "";
            else
                row.axis_group = axisDef.group(idx);
            end

            C = [C; movevars(row, ["level","response","axis","axis_group"], "Before", 1)]; %#ok<AGROW>
        end
    end
end

function AC = calcAxisCorr(T, axisVars, axisDef)
    AC = table();

    for i = 1:numel(axisVars)
        for j = i+1:numel(axisVars)
            a = string(axisVars(i));
            b = string(axisVars(j));
            row = corrOne(T.(a), T.(b));
            row.axis_1 = a;
            row.axis_2 = b;

            g1 = "";
            g2 = "";
            idx1 = find(axisDef.axis == a, 1);
            idx2 = find(axisDef.axis == b, 1);
            if ~isempty(idx1); g1 = axisDef.group(idx1); end
            if ~isempty(idx2); g2 = axisDef.group(idx2); end
            row.group_1 = g1;
            row.group_2 = g2;

            AC = [AC; movevars(row, ["axis_1","axis_2","group_1","group_2"], "Before", 1)]; %#ok<AGROW>
        end
    end

    AC = sortrows(AC, "R2", "descend");
end

function row = corrOne(y, x)
    ok = isfinite(x) & isfinite(y);
    row = table();
    row.N = sum(ok);

    if row.N >= 3
        CC = corrcoef(x(ok), y(ok));
        row.pearson_r = CC(1,2);

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
end

function res = residualizeResponse(T, targetVar, predictors)
    y = T.(targetVar);
    ok = isfinite(y);
    X = [];

    for p = string(predictors)
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

function handling = makeHandlingTable(corrPoint, residualized, modelCompare, caseSummary, contrast, axisCorr)
    candidate_id = strings(0,1);
    candidate = strings(0,1);
    status = strings(0,1);
    support = strings(0,1);
    risk = strings(0,1);
    current_reading = strings(0,1);

    pm108 = caseSummary.PM_F1_mean(caseSummary.case_id=="108");
    pm161 = caseSummary.PM_F1_mean(caseSummary.case_id=="161");
    pm164 = caseSummary.PM_F1_mean(caseSummary.case_id=="164");

    r2Fform = getR2(corrPoint, "PM_F1", "F_form");
    r2z = getR2(corrPoint, "PM_F1", "z_DNB_over_DH");
    r2LDH = getR2(corrPoint, "PM_F1", "L_over_DH");
    r2xeq = getR2(corrPoint, "PM_F1", "x_eq");
    r2Tsub = getR2(corrPoint, "PM_F1", "Tsub_K");

    r2Axis_Fform_z = getAxisR2(axisCorr, "F_form", "z_DNB_over_DH");
    r2Axis_Fform_LDH = getAxisR2(axisCorr, "F_form", "L_over_DH");
    r2Axis_z_LDH = getAxisR2(axisCorr, "z_DNB_over_DH", "L_over_DH");

    add("H0", ...
        "F1(Tsub)維持・追加補正式なし", ...
        "primary_hold", ...
        sprintf("PM_F1: 108=%.3f, 161=%.3f, 164=%.3f。全体として1近傍だが系統差は残る。", pm108, pm161, pm164), ...
        "残差を放置しすぎると、108高め/161-164低めの系統差を見落とす。", ...
        "現時点の基準方針。補正式化より先に、残差の性格を診断課題として保持する。");

    add("H1", ...
        "F_form・非一様加熱換算として扱う", ...
        "possible_but_not_causal", ...
        sprintf("PM_F1 vs F_form R2=%.3f。F_formは108と161/164で大きく異なる。", r2Fform), ...
        sprintf("F_formはDNB位置やL/DHと交絡する。F_form-zDNB R2=%.3f, F_form-LDH R2=%.3f。F1の効き方として読まない。", r2Axis_Fform_z, r2Axis_Fform_LDH), ...
        "F_form定義・局所熱流束基準・DNB位置との関係を確認する価値はある。ただし原因断定しない。");

    add("H2", ...
        "DNB位置・z_DNB/DH・z_DNB/Lのケース構造として扱う", ...
        "possible_but_confounded", ...
        sprintf("PM_F1 vs z_DNB/DH R2=%.3f。DNB位置までの履歴長は108と161/164で大きく異なる。", r2z), ...
        sprintf("z_DNB/DHはL/DHやF_formと交絡する。zDNB-LDH R2=%.3f。", r2Axis_z_LDH), ...
        "単管側の熱履歴仮説とは接続しやすい。ただし3ケースだけで履歴長補正式にしない。");

    add("H3", ...
        "L/DH補正式として扱う", ...
        "reject_for_now", ...
        sprintf("PM_F1 vs L/DH R2=%.3f は見える。", r2LDH), ...
        "BT04でPM_noF1はL/DHとほぼ対応せず、単管側でもL/D単独補正式は弱い。F1後残差だけでL/DH効果とは言わない。", ...
        "L/DHは診断項として残すが、補正式候補には進めない。");

    add("H4", ...
        "x_eq置換として扱う", ...
        "reject_for_now", ...
        sprintf("PM_F1 vs x_eq R2=%.3f, PM_F1 vs Tsub R2=%.3f。BT05ではx_eqのTsub追加説明力が小さい。", r2xeq, r2Tsub), ...
        "単管ではx_eq込み診断が効いたが、バンドル108/161/164ではF1置換根拠にならない。", ...
        "x_eqは熱収支状態量・診断項として保留。F1(Tsub)をF(x_eq)へ置換しない。");

    add("H5", ...
        "ケース代表性・適用範囲の問題として扱う", ...
        "important_hold", ...
        "対象は108/161/164の3ケース群。PM_F1は1近傍だが、108は高め、161/164は低め。", ...
        "3ケースだけで一般化すると危険。F_form、DNB位置、L/DH、Tsub、x_eqが同時に変化する。", ...
        "補正式化せず、代表性・条件範囲・非一様加熱換算の診断課題として残す。");

    handling = table(candidate_id, candidate, status, support, risk, current_reading);

    function add(a,b,c,d,e,f)
        candidate_id(end+1,1) = string(a);
        candidate(end+1,1) = string(b);
        status(end+1,1) = string(c);
        support(end+1,1) = string(d);
        risk(end+1,1) = string(e);
        current_reading(end+1,1) = string(f);
    end
end

function flags = makeInterpretationFlags(caseSummary, contrast, corrPoint, residualized, modelCompare, handling)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("BT06位置づけ", "OK", "", "F1(Tsub)維持を前提に、PM_F1残差の扱いを整理する。補正式化ではない。");

    pm108 = caseSummary.PM_F1_mean(caseSummary.case_id=="108");
    pm161 = caseSummary.PM_F1_mean(caseSummary.case_id=="161");
    pm164 = caseSummary.PM_F1_mean(caseSummary.case_id=="164");

    add("PM_F1_case_pattern", "diagnostic", ...
        sprintf("108=%.6g, 161=%.6g, 164=%.6g", pm108, pm161, pm164), ...
        "F1後は108が1よりやや高く、161/164が1より低い。大外れではないが、系統差は残る。");

    r2Fform = getR2(corrPoint, "PM_F1", "F_form");
    r2z = getR2(corrPoint, "PM_F1", "z_DNB_over_DH");
    r2LDH = getR2(corrPoint, "PM_F1", "L_over_DH");
    r2xeq = getR2(corrPoint, "PM_F1", "x_eq");
    r2Tsub = getR2(corrPoint, "PM_F1", "Tsub_K");

    add("PM_F1_axis_R2", "diagnostic", ...
        sprintf("Fform=%.6g, zDNB_DH=%.6g, LDH=%.6g, xeq=%.6g, Tsub=%.6g", r2Fform, r2z, r2LDH, r2xeq, r2Tsub), ...
        "PM_F1残差はTsub/x_eqよりF_form・履歴長・L/DH側と対応しやすい。ただし原因断定しない。");

    bestPM = modelCompare(modelCompare.response=="PM_F1", :);
    if height(bestPM) > 0
        bestPM = sortrows(bestPM, "R2", "descend");
        add("best_PM_F1_model", "DIAG_ONLY", ...
            string(bestPM.model(1)) + ", R2=" + string(sprintf("%.6g", bestPM.R2(1))), ...
            "探索モデル。補正式として採用しない。");
    end

    add("F_form_reading", "hold", "", ...
        "F_formはF1ではない。非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数として読む。");

    add("L_DH_reading", "reject_formula", "", ...
        "PM_F1とL/DHに見かけ相関があっても、BT04・単管側の判断からL/DH補正式には進まない。");

    add("x_eq_reading", "reject_replacement", "", ...
        "BT05により、今回のバンドルではx_eqはTsubへの追加説明力が小さい。F1(Tsub)をF(x_eq)へ置換しない。");

    add("recommended_handling", "primary", "", ...
        "F1(Tsub)を維持し、PM_F1残差はF_form・DNB位置・L/DH・ケース構造・適用範囲の診断課題として残す。");

    add("next_step", "next", "", ...
        "BT06結果を見て、必要ならBT07としてF_form定義・非一様加熱換算・DNB位置の扱いを確認する。");

    flags = table(item, status, value, reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function r2 = getR2(corrPoint, response, axis)
    idx = find(corrPoint.response == response & corrPoint.axis == axis, 1);
    if isempty(idx)
        r2 = NaN;
    else
        r2 = corrPoint.R2(idx);
    end
end

function r2 = getAxisR2(axisCorr, a, b)
    idx = find((axisCorr.axis_1 == a & axisCorr.axis_2 == b) | (axisCorr.axis_1 == b & axisCorr.axis_2 == a), 1);
    if isempty(idx)
        r2 = NaN;
    else
        r2 = axisCorr.R2(idx);
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

    maxRows = height(T);
    if maxRows > 120
        maxRows = 120;
    end

    for i = 1:maxRows
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

    if height(T) > maxRows
        lines(end+1) = "| ... | " + strjoin(repmat("...", 1, numel(vars)-1), " | ") + " |";
    end

    md = strjoin(lines, newline);
end
