%% BT07_Fform_DNB_position_diagnostic_v3.m
% BT07：F_form定義・非一様加熱換算・DNB位置の扱い確認
%
% 目的：
%   BT06で、F1後のPM_F1残差はTsub/x_eq側ではなく、
%   F_form・DNB位置・L/DH・ケース構造側に残っている可能性が高いと整理した。
%
%   BT07では、F_formを補正式候補にするのではなく、
%   F_formが何を代表しているかを確認する。
%
% 確認したい問い：
%   1. F_formはDNB位置の局所熱流束基準換算として妥当な診断項になっているか。
%   2. F_formはz_DNB/Lだけで決まっているのか、それともケース別出力分布も含んでいるのか。
%   3. F_form、z_DNB/DH、L/DHはどの程度交絡しているか。
%   4. 108のF_formが小さい理由、161/164のF_formが大きい理由を、DNB位置だけで読めるか。
%   5. PM_F1残差をF_form原因説へ進めてよいか、それとも非一様加熱換算・DNB位置診断として保留すべきか。
%
% 重要：
%   - 補正式は作らない。
%   - F1(Tsub)は維持する。
%   - F1(Tsub)をF(x_eq)へ置換しない。
%   - F_formはF1ではない。
%   - F_formは、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数として扱う。
%   - current_bundle_inputだけでは軸方向出力分布の元配列を再構成できない可能性がある。
%     その場合、BT07は「F_formの挙動診断」であり、「F_form式の再計算監査」ではない。
%
% 入力：
%   H52Q_current_bundle_input_v1_*.xlsx
%
% 出力：
%   BT07_Fform_DNB_position_diagnostic_yyyymmdd_HHMMSS.xlsx
%   run_report_BT07_Fform_DNB_position_diagnostic_yyyymmdd_HHMMSS.md
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

outXlsx = "BT07_Fform_DNB_position_diagnostic_" + timestamp + ".xlsx";
outMd   = "run_report_BT07_Fform_DNB_position_diagnostic_" + timestamp + ".md";

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
inventory = table();

for i = 1:height(sheetMap)
    corr = sheetMap.correction(i);
    cid  = sheetMap.case_id(i);
    sh   = sheetMap.sheet_name(i);

    fprintf("Reading sheet: %s / %s / %s\n", corr, cid, sh);

    T = readSheetAsTable(inputFile, sh);
    D = makeDetail(T, corr, cid, sh);
    detail = [detail; D]; %#ok<AGROW>

    Inv = makeInventory(T, corr, cid, sh);
    inventory = [inventory; Inv]; %#ok<AGROW>
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
        row.err_F1 = B.PM - 1;
        row.abs_err_F1 = abs(B.PM - 1);
        row.delta_PM = B.PM - A.PM;
        row.lift_ratio = safeRatio(B.PM, A.PM);

        row.Tsub_K = B.Tsub_K;
        row.Fcorr = B.Fcorr;
        row.x_eq = B.x_eq;

        row.F_form = B.F_form;
        row.z_DNB_over_DH = B.z_DNB_over_DH;
        row.z_DNB_over_L = B.z_DNB_over_L;
        row.L_over_DH = B.L_over_DH;

        row.Tw_minus_Tsat_K = B.Tw_minus_Tsat_K;
        row.Tm_minus_Tsat_K = B.Tm_minus_Tsat_K;

        row.Fform_class = classifyFform(B.F_form);
        row.DNBpos_class = classifyDNBPosition(B.z_DNB_over_L);

        % Arithmetic-only sensitivity indices.
        % 物理的にF_formを外す計算ではない。F_formが大きい/小さいケースで
        % PMがどう並ぶかを見るだけの補助指標。
        row.PM_F1_div_Fform_DIAG_ONLY = safeRatio(B.PM, B.F_form);
        row.PM_F1_times_Fform_DIAG_ONLY = B.PM .* B.F_form;

        paired = [paired; row]; %#ok<AGROW>
    end
end

%% ===== Definitions =====

definitions = cell2table({
    "F_form", "非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。F1ではない。"
    "z_DNB_over_L", "DNB位置の相対位置。出口寄りか上流寄りかを見る。"
    "z_DNB_over_DH", "DNB位置までの水力等価直径基準の実効履歴長。"
    "L_over_DH", "全加熱長の水力等価直径基準長さ。L/DH補正式へ直行しない。"
    "PM_F1", "F1後のP/M。1に近いほど一致。"
    "err_F1", "F1後残差。PM_F1 - 1。"
    "PM_F1_div_Fform_DIAG_ONLY", "PM_F1をF_formで割った参考値。F_formを外した物理計算ではない。"
    "PM_F1_times_Fform_DIAG_ONLY", "PM_F1にF_formを掛けた参考値。F_form適用物理計算ではない。"
}, 'VariableNames', {'item','meaning'});

%% ===== Case summary =====

summaryVars = [
    "PM_noF1"
    "PM_F1"
    "err_F1"
    "abs_err_F1"
    "q_exp_MWm2"
    "q_calc_F1_MWm2"
    "delta_PM"
    "lift_ratio"
    "Tsub_K"
    "Fcorr"
    "x_eq"
    "F_form"
    "z_DNB_over_DH"
    "z_DNB_over_L"
    "L_over_DH"
    "Tw_minus_Tsat_K"
    "Tm_minus_Tsat_K"
    "PM_F1_div_Fform_DIAG_ONLY"
    "PM_F1_times_Fform_DIAG_ONLY"
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

%% ===== Fform-position map =====

fmap = makeFformPositionMap(paired);

%% ===== 108 contrast =====

contrastVars = [
    "PM_F1"
    "err_F1"
    "abs_err_F1"
    "F_form"
    "z_DNB_over_L"
    "z_DNB_over_DH"
    "L_over_DH"
    "Tsub_K"
    "x_eq"
    "q_exp_MWm2"
    "q_calc_F1_MWm2"
];

contrast = table();
for v = contrastVars'
    contrast = [contrast; make108Contrast(caseSummary, v + "_mean")]; %#ok<AGROW>
end

%% ===== Correlations =====

responseVars = [
    "PM_F1"
    "err_F1"
    "abs_err_F1"
    "q_exp_MWm2"
    "q_calc_F1_MWm2"
    "delta_PM"
    "lift_ratio"
];

axisVars = [
    "F_form"
    "z_DNB_over_L"
    "z_DNB_over_DH"
    "L_over_DH"
    "Tsub_K"
    "x_eq"
    "Tw_minus_Tsat_K"
    "Tm_minus_Tsat_K"
];

corrPoint = calcCorr(paired, responseVars, axisVars, "point_level");

axisCorr = calcAxisCorr(paired, axisVars);

withinCaseCorr = table();
for cid = ["108","161","164"]
    S = paired(paired.case_id == cid, :);
    C = calcCorr(S, ["PM_F1","err_F1","abs_err_F1"], ["F_form","z_DNB_over_L","z_DNB_over_DH","L_over_DH","Tsub_K","x_eq"], "within_case");
    C.case_id = repmat(cid, height(C), 1);
    C = movevars(C, "case_id", "After", "level");
    withinCaseCorr = [withinCaseCorr; C]; %#ok<AGROW>
end

% Case-mean correlation is N=3 only. It is included only to expose that
% the case structure itself may dominate.
caseMean = caseSummaryToCaseMean(caseSummary);
caseMeanCorr = calcCorr(caseMean, ["PM_F1","err_F1","abs_err_F1"], ["F_form","z_DNB_over_L","z_DNB_over_DH","L_over_DH","Tsub_K","x_eq"], "case_mean_N3");

%% ===== Fform class summary =====

fclassSummary = table();
classes = unique(paired.Fform_class);
for i = 1:numel(classes)
    cls = classes(i);
    S = paired(paired.Fform_class == cls, :);
    if height(S) == 0
        continue;
    end

    row = table();
    row.Fform_class = cls;
    row.N = height(S);
    row.cases = strjoin(unique(S.case_id), ",");
    for v = ["PM_F1","err_F1","F_form","z_DNB_over_L","z_DNB_over_DH","L_over_DH","q_exp_MWm2","q_calc_F1_MWm2"]
        row.(v + "_mean") = mean(S.(v), "omitnan");
        row.(v + "_sd") = std(S.(v), "omitnan");
    end
    fclassSummary = [fclassSummary; row]; %#ok<AGROW>
end

%% ===== Reconstructability check =====

reconCheck = makeReconstructabilityCheck(inventory);

%% ===== Interpretation flags =====

flags = makeFlags(caseSummary, contrast, corrPoint, axisCorr, withinCaseCorr, reconCheck);

%% ===== Write Excel =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(definitions, outXlsx, 'Sheet', 'definitions');
writetable(inventory, outXlsx, 'Sheet', 'BT07_input_inventory');
writetable(reconCheck, outXlsx, 'Sheet', 'BT07_reconstructability');
writetable(caseSummary, outXlsx, 'Sheet', 'BT07_case_summary');
writetable(fmap, outXlsx, 'Sheet', 'BT07_Fform_position_map');
writetable(contrast, outXlsx, 'Sheet', 'BT07_108_contrast');
writetable(corrPoint, outXlsx, 'Sheet', 'BT07_corr_Fform_PM');
writetable(axisCorr, outXlsx, 'Sheet', 'BT07_axis_axis_corr');
writetable(withinCaseCorr, outXlsx, 'Sheet', 'BT07_within_case_corr');
writetable(caseMeanCorr, outXlsx, 'Sheet', 'BT07_case_mean_corr_N3');
writetable(fclassSummary, outXlsx, 'Sheet', 'BT07_Fform_class_summary');
writetable(flags, outXlsx, 'Sheet', 'BT07_interpretation_flags');
writetable(paired, outXlsx, 'Sheet', 'BT07_paired_points');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Write Markdown report =====

md = strings(0,1);

md(end+1) = "# BT07 F_form / DNB position diagnostic";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT06で、F1後のPM_F1残差はTsub/x_eq側ではなく、F_form・DNB位置・L/DH・ケース構造側に残っている可能性が高いと整理した。BT07では、F_formを補正式候補にするのではなく、F_formが何を代表しているかを確認する。";
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
md(end+1) = "- BT07では補正式を作らない。";
md(end+1) = "";
md(end+1) = "## 4. Reconstructability check";
md(end+1) = "";
md(end+1) = "current_bundle_inputだけでF_formを青面積/オレンジ面積から再計算できるかを確認する。";
md(end+1) = "";
md(end+1) = tableToMarkdown(reconCheck);
md(end+1) = "";
md(end+1) = "## 5. Case summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(caseSummary);
md(end+1) = "";
md(end+1) = "## 6. F_form and DNB position map";
md(end+1) = "";
md(end+1) = tableToMarkdown(fmap);
md(end+1) = "";
md(end+1) = "## 7. 108 versus mean(161,164)";
md(end+1) = "";
md(end+1) = tableToMarkdown(contrast);
md(end+1) = "";
md(end+1) = "## 8. Point-level correlations";
md(end+1) = "";
md(end+1) = "点群相関は探索的診断であり、補正式係数ではない。";
md(end+1) = "";
md(end+1) = tableToMarkdown(corrPoint);
md(end+1) = "";
md(end+1) = "## 9. Axis-axis correlations";
md(end+1) = "";
md(end+1) = "F_form、z_DNB/L、z_DNB/DH、L/DHの交絡を確認する。";
md(end+1) = "";
md(end+1) = tableToMarkdown(axisCorr);
md(end+1) = "";
md(end+1) = "## 10. Within-case correlations";
md(end+1) = "";
md(end+1) = "ケース内の変動で同じ傾向が出るかを見る。F_formがケース固定に近い場合、点群相関はケース差を見ている可能性が高い。";
md(end+1) = "";
md(end+1) = tableToMarkdown(withinCaseCorr);
md(end+1) = "";
md(end+1) = "## 11. Case-mean correlations";
md(end+1) = "";
md(end+1) = "N=3のケース平均相関であり、採用根拠ではない。ケース構造の強さを見せるための参考値。";
md(end+1) = "";
md(end+1) = tableToMarkdown(caseMeanCorr);
md(end+1) = "";
md(end+1) = "## 12. F_form class summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(fclassSummary);
md(end+1) = "";
md(end+1) = "## 13. Interpretation flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(flags);
md(end+1) = "";
md(end+1) = "## 14. 次アクション";
md(end+1) = "";
md(end+1) = "1. BT07_interpretation_flagsを確認する。";
md(end+1) = "2. F_formを原因として採用できるかではなく、F_formがDNB位置・軸方向出力分布・L/DHのどれを代理しているかを読む。";
md(end+1) = "3. current_bundle_inputだけでF_formを再計算できない場合は、F_form作成元または軸方向出力分布データを確認する。";
md(end+1) = "4. F_form定義・DNB位置・局所熱流束基準に矛盾がなければ、PM_F1残差は補正式化せず、非一様加熱換算/DNB位置/ケース構造の診断課題として残す。";
md(end+1) = "5. 単管側ST-BT05相当は、別タスクとして後で実施する。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display quick result =====

disp("=== BT07 Fform position map ===");
disp(fmap);

disp("=== BT07 interpretation flags ===");
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

function Inv = makeInventory(T, corr, cid, sh)
    vars = string(T.Properties.VariableNames)';
    Inv = table();
    Inv.correction = repmat(string(corr), numel(vars), 1);
    Inv.case_id = repmat(string(cid), numel(vars), 1);
    Inv.sheet_name = repmat(string(sh), numel(vars), 1);
    Inv.column_index = (1:numel(vars))';
    Inv.column_name = vars;
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

    F_form = getNumCol(T, ["F_form","Fform","F_FORM"]);

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

function s = classifyFform(x)
    s = strings(size(x));
    s(:) = "unknown";
    s(isfinite(x) & x < 0.90) = "Fform_lt_0p90";
    s(isfinite(x) & x >= 0.90 & x <= 1.10) = "Fform_near_1";
    s(isfinite(x) & x > 1.10) = "Fform_gt_1p10";
end

function s = classifyDNBPosition(x)
    s = strings(size(x));
    s(:) = "unknown";
    s(isfinite(x) & x < 0.80) = "zL_lt_0p80";
    s(isfinite(x) & x >= 0.80 & x < 0.95) = "zL_0p80_to_0p95";
    s(isfinite(x) & x >= 0.95) = "zL_ge_0p95";
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
    tcrit = 1.96;
    ciL = m - tcrit * se;
    ciU = m + tcrit * se;
end

function fmap = makeFformPositionMap(paired)
    fmap = table();

    for cid = ["108","161","164"]
        S = paired(paired.case_id == cid, :);

        row = table();
        row.case_id = cid;
        row.N = height(S);

        for v = ["F_form","z_DNB_over_L","z_DNB_over_DH","L_over_DH","PM_F1","err_F1","q_exp_MWm2","q_calc_F1_MWm2","x_eq","Tsub_K"]
            row.(v + "_mean") = mean(S.(v), "omitnan");
            row.(v + "_min") = min(S.(v), [], "omitnan");
            row.(v + "_max") = max(S.(v), [], "omitnan");
        end

        row.Fform_class_mode = modeString(S.Fform_class);
        row.DNBpos_class_mode = modeString(S.DNBpos_class);

        if row.F_form_mean < 0.90
            row.Fform_physical_reading = "F_form<1: DNB位置の局所熱流束が上流平均より高い側にある可能性。出力分布形状確認が必要。";
        elseif row.F_form_mean > 1.10
            row.Fform_physical_reading = "F_form>1: DNB位置の局所熱流束が上流平均より低い側にある可能性。出口寄り/下降側か要確認。";
        else
            row.Fform_physical_reading = "F_form≈1: DNB位置局所値と上流平均が近い、または一様加熱相当。";
        end

        fmap = [fmap; row]; %#ok<AGROW>
    end
end

function s = modeString(x)
    u = unique(x);
    counts = zeros(numel(u),1);
    for i = 1:numel(u)
        counts(i) = sum(x == u(i));
    end
    [~, idx] = max(counts);
    if isempty(idx)
        s = "";
    else
        s = u(idx);
    end
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

function C = calcCorr(T, responseVars, axisVars, levelName)
    C = table();

    % MATLABのfor文は「列」単位で回るため、string配列が列ベクトルだと
    % r/a が複数要素のstring配列になり、T.(r)でエラーになる。
    % ここでは必ず行ベクトル化し、1要素ずつ明示的に回す。
    responseVars = reshape(string(responseVars), 1, []);
    axisVars = reshape(string(axisVars), 1, []);
    varNames = string(T.Properties.VariableNames);

    for ir = 1:numel(responseVars)
        r = responseVars(ir);
        for ia = 1:numel(axisVars)
            a = axisVars(ia);

            if ~ismember(r, varNames) || ~ismember(a, varNames)
                row = table();
                row.N = 0;
                row.pearson_r = NaN;
                row.slope = NaN;
                row.intercept = NaN;
                row.R2 = NaN;
            else
                row = corrOne(T.(char(r)), T.(char(a)));
            end

            row.level = string(levelName);
            row.response = r;
            row.axis = a;

            C = [C; movevars(row, ["level","response","axis"], "Before", 1)]; %#ok<AGROW>
        end
    end

    if height(C) > 0
        C = sortrows(C, ["response","R2"], ["ascend","descend"]);
    end
end

function AC = calcAxisCorr(T, axisVars)
    AC = table();

    axisVars = reshape(string(axisVars), 1, []);
    varNames = string(T.Properties.VariableNames);

    for i = 1:numel(axisVars)
        for j = i+1:numel(axisVars)
            a = axisVars(i);
            b = axisVars(j);

            if ~ismember(a, varNames) || ~ismember(b, varNames)
                row = table();
                row.N = 0;
                row.pearson_r = NaN;
                row.slope = NaN;
                row.intercept = NaN;
                row.R2 = NaN;
            else
                row = corrOne(T.(char(a)), T.(char(b)));
            end

            row.axis_1 = a;
            row.axis_2 = b;

            AC = [AC; movevars(row, ["axis_1","axis_2"], "Before", 1)]; %#ok<AGROW>
        end
    end

    if height(AC) > 0
        AC = sortrows(AC, "R2", "descend");
    end
end

function row = corrOne(y, x)
    ok = isfinite(x) & isfinite(y);
    row = table();
    row.N = sum(ok);

    row.pearson_r = NaN;
    row.slope = NaN;
    row.intercept = NaN;
    row.R2 = NaN;
    row.note = "";

    if row.N < 3
        row.note = "N<3";
        return;
    end

    xx = x(ok);
    yy = y(ok);

    xRange = max(xx) - min(xx);
    yRange = max(yy) - min(yy);
    xTol = max(1, max(abs(xx))) * 1e-10;
    yTol = max(1, max(abs(yy))) * 1e-10;

    if xRange <= xTol
        row.intercept = mean(yy, 'omitnan');
        row.note = "x_constant_or_nearly_constant";
        return;
    end

    if yRange <= yTol
        row.pearson_r = 0;
        row.slope = 0;
        row.intercept = mean(yy, 'omitnan');
        row.R2 = NaN;
        row.note = "y_constant_or_nearly_constant";
        return;
    end

    CC = corrcoef(xx, yy);
    row.pearson_r = CC(1,2);

    % polyfit warning avoidance: center/scale x explicitly.
    xMean = mean(xx, 'omitnan');
    xStd = std(xx, 'omitnan');
    xs = (xx - xMean) ./ xStd;

    pScaled = polyfit(xs, yy, 1);
    yhat = polyval(pScaled, xs);

    % Convert scaled slope/intercept back to original x basis.
    row.slope = pScaled(1) ./ xStd;
    row.intercept = pScaled(2) - row.slope .* xMean;

    ss_res = sum((yy - yhat).^2);
    ss_tot = sum((yy - mean(yy)).^2);

    if ss_tot > 0
        row.R2 = 1 - ss_res/ss_tot;
    else
        row.R2 = NaN;
    end
end

function CM = caseSummaryToCaseMean(caseSummary)
    CM = table();
    CM.case_id = caseSummary.case_id;
    for v = ["PM_F1","err_F1","abs_err_F1","F_form","z_DNB_over_L","z_DNB_over_DH","L_over_DH","Tsub_K","x_eq"]
        CM.(v) = caseSummary.(v + "_mean");
    end
end

function reconCheck = makeReconstructabilityCheck(inventory)
    allCols = lower(string(inventory.column_name));
    normCols = normalizeNames(allCols);

    rawShapeKeywords = ["axial","shape","powerdist","powerprofile","qshape","zmesh","znode","relativepower","peaking","phi"];
    hasRawShape = false;
    matched = strings(0,1);

    for k = rawShapeKeywords
        hit = contains(normCols, normalizeNames(k));
        if any(hit)
            hasRawShape = true;
            matched = [matched; unique(string(inventory.column_name(hit)))]; %#ok<AGROW>
        end
    end

    hasFform = any(normCols == "fform");
    hasZDNB = any(normCols == "ldnb" | normCols == "zdnb");
    hasL = any(normCols == "l" | normCols == "heatedlength" | normCols == "lheat");
    hasDH = any(normCols == "dh" | normCols == "dhd" | normCols == "dh");

    reconCheck = table();
    reconCheck.item = [
        "has_F_form_column"
        "has_DNB_position_column"
        "has_L_column"
        "has_DH_column"
        "has_raw_axial_power_profile_columns"
        "matched_raw_profile_like_columns"
        "BT07_reconstructability_reading"
    ]';

    reconCheck.value = [
        string(hasFform)
        string(hasZDNB)
        string(hasL)
        string(hasDH)
        string(hasRawShape)
        strjoin(unique(matched), ", ")
        ""
    ]';

    if hasRawShape
        reading = "raw axial profile-like columns may exist. F_form再計算監査に進める可能性がある。列定義を手確認する。";
    else
        reading = "current_bundle_inputにはF_form再計算に必要な軸方向出力分布元配列が見当たらない。BT07はF_form挙動診断であり、青面積/オレンジ面積の再計算監査ではない。";
    end

    reconCheck.value(end) = reading;
end

function flags = makeFlags(caseSummary, contrast, corrPoint, axisCorr, withinCaseCorr, reconCheck)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("BT07_position", "OK", "", "F_form定義・非一様加熱換算・DNB位置の扱い確認。補正式化ではない。");

    hasRaw = reconCheck.value(reconCheck.item=="has_raw_axial_power_profile_columns");
    add("Fform_reconstructability", "diagnostic", hasRaw, "current_bundle_inputだけでF_formを再計算できるかを確認。raw profileが無ければ挙動診断に留める。");

    f108 = getCase(caseSummary, "108", "F_form_mean");
    f161 = getCase(caseSummary, "161", "F_form_mean");
    f164 = getCase(caseSummary, "164", "F_form_mean");

    z108 = getCase(caseSummary, "108", "z_DNB_over_L_mean");
    z161 = getCase(caseSummary, "161", "z_DNB_over_L_mean");
    z164 = getCase(caseSummary, "164", "z_DNB_over_L_mean");

    add("Fform_case_pattern", "diagnostic", ...
        sprintf("Fform: 108=%.6g, 161=%.6g, 164=%.6g / zDNB_L: 108=%.6g, 161=%.6g, 164=%.6g", f108, f161, f164, z108, z161, z164), ...
        "F_formはケースで大きく異なる。z_DNB/Lだけでは単純に読めない可能性がある。");

    r2Fpm = getR2(corrPoint, "PM_F1", "F_form");
    r2FzL = getAxisR2(axisCorr, "F_form", "z_DNB_over_L");
    r2FzD = getAxisR2(axisCorr, "F_form", "z_DNB_over_DH");
    r2FLD = getAxisR2(axisCorr, "F_form", "L_over_DH");
    r2zLD = getAxisR2(axisCorr, "z_DNB_over_DH", "L_over_DH");

    add("Fform_PM_relation", "diagnostic", ...
        sprintf("PM_F1 vs F_form R2=%.6g", r2Fpm), ...
        "F_formはPM_F1と中程度に対応するが、原因とは断定しない。");

    add("Fform_position_confounding", "diagnostic", ...
        sprintf("Fform-zL R2=%.6g, Fform-zDNB_DH R2=%.6g, Fform-LDH R2=%.6g, zDNB_DH-LDH R2=%.6g", r2FzL, r2FzD, r2FLD, r2zLD), ...
        "F_form、DNB位置、L/DHは交絡する。特にL/DHは多くのケース構造を代表しうる。");

    add("Fform_not_F1", "hold", "", "F_formはF1ではない。F1の効き方として読まず、非一様加熱換算として読む。");

    add("Fform_cause_judgement", "hold", "", "F_form原因説には進まない。F_formはDNB位置・軸方向出力分布・局所熱流束基準換算の複合診断項として保留する。");

    add("LDH_formula_judgement", "reject_formula", "", "PM_F1残差とL/DHが対応しても、単管・BT04・BT06の流れからL/DH補正式には戻らない。");

    add("recommended_next", "next", "", "F_form作成元または軸方向出力分布を確認できるなら、青面積/オレンジ面積の再計算監査へ進む。無ければ、PM_F1残差は非一様加熱換算/DNB位置/ケース構造の診断課題として残す。");

    flags = table(item, status, value, reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function val = getCase(caseSummary, cid, varName)
    idx = find(caseSummary.case_id == cid, 1);
    if isempty(idx)
        val = NaN;
    else
        val = caseSummary.(varName)(idx);
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
            row(j) = valueToScalarString(val);
            row(j) = replace(row(j), "|", "/");
            row(j) = replace(row(j), newline, " ");
            row(j) = replace(row(j), char(10), " ");
            row(j) = replace(row(j), char(13), " ");
        end
        lines(end+1) = "| " + strjoin(row, " | ") + " |";
    end

    if height(T) > maxRows
        lines(end+1) = "| ... | " + strjoin(repmat("...", 1, numel(vars)-1), " | ") + " |";
    end

    md = strjoin(lines, newline);
end

function s = valueToScalarString(val)
    if isnumeric(val)
        if isempty(val)
            s = "";
        elseif isscalar(val)
            if isnan(val)
                s = "";
            else
                s = string(sprintf("%.6g", val));
            end
        else
            flat = val(:)';
            parts = strings(1, numel(flat));
            for kk = 1:numel(flat)
                if isnan(flat(kk))
                    parts(kk) = "";
                else
                    parts(kk) = string(sprintf("%.6g", flat(kk)));
                end
            end
            s = strjoin(parts, ", ");
        end
    elseif isstring(val)
        if isempty(val)
            s = "";
        else
            s = strjoin(reshape(val, 1, []), ", ");
        end
    elseif ischar(val)
        s = string(val);
    elseif iscell(val)
        if isempty(val)
            s = "";
        else
            parts = strings(1, numel(val));
            for kk = 1:numel(val)
                parts(kk) = valueToScalarString(val{kk});
            end
            s = strjoin(parts, ", ");
        end
    elseif islogical(val)
        if isscalar(val)
            s = string(val);
        else
            s = strjoin(string(val(:)'), ", ");
        end
    else
        try
            tmp = string(val);
            if isempty(tmp)
                s = "";
            else
                s = strjoin(reshape(tmp, 1, []), ", ");
            end
        catch
            s = "[unprintable]";
        end
    end
end
