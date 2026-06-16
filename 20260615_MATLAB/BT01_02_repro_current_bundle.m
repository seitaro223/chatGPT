%% BT01_02_repro_current_bundle.m
% BT01/BT02：current_bundle入力で再現確認
%
% 目的：
%   r8 resultブックを直接読まず、BT00-1で作成した current_bundle_input を使って、
%   バンドル108/161/164の noF1/F1 比較が再現できることを確認する。
%
% 位置づけ：
%   - BT03へ進む前の入力切替QC。
%   - r8 resultブックではなく、current_bundleを正式入力にするための再現確認。
%   - 補正式は作らない。
%
% 重要前提：
%   - F2は使わない。
%   - F1F2は使わない。
%   - 比較対象は noF1 と F1 のみ。
%   - バンドルでは x_Mes = x_eq として扱う。
%   - F1は単管基準のTsub補正。
%   - F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。
%
% 入力：
%   H52Q_current_bundle_input_v1_*.xlsx
%
% 出力：
%   BT01_02_current_bundle_repro_yyyymmdd_HHMMSS.xlsx
%   run_report_BT01_02_current_bundle_repro_yyyymmdd_HHMMSS.md
%
% 実行方法：
%   この .m ファイルを current_bundle_input ブックと同じフォルダに置いて実行する。
%   inputFile を空文字 "" にしている場合は、最新の
%   H52Q_current_bundle_input_v1_*.xlsx を自動探索する。

clear; clc;

%% ===== Settings =====

inputFile = "";  % 空なら自動探索。例: "H52Q_current_bundle_input_v1_20260615_180822.xlsx"

if strlength(inputFile) == 0
    inputFile = findLatestFile("H52Q_current_bundle_input_v1_*.xlsx");
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "BT01_02_current_bundle_repro_" + timestamp + ".xlsx";
outMd   = "run_report_BT01_02_current_bundle_repro_" + timestamp + ".md";

sheetMap = table( ...
    ["noF1"; "noF1"; "noF1"; "F1"; "F1"; "F1"], ...
    ["108";  "161";  "164";  "108"; "161"; "164"], ...
    ["tm_108"; "tm_161"; "tm_164"; "tm_F1_108"; "tm_F1_161"; "tm_F1_164"], ...
    'VariableNames', {'correction','case_id','sheet_name'} ...
);

%% ===== Validate input =====

if ~isfile(inputFile)
    error("current_bundle input file not found: %s", inputFile);
end

fprintf("Input current_bundle: %s\n", inputFile);

%% ===== Read point detail =====

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

% case内行番号で noF1/F1 を対応付ける。
detail.point_index_in_case = zeros(height(detail),1);
for corr = ["noF1","F1"]
    for cid = ["108","161","164"]
        idx = find(detail.correction == corr & detail.case_id == cid);
        detail.point_index_in_case(idx) = (1:numel(idx))';
    end
end

%% ===== BT01 case summary =====

caseSummary = table();

for corr = ["noF1","F1"]
    for cid = ["108","161","164"]
        S = detail(detail.correction == corr & detail.case_id == cid, :);

        row = table();
        row.correction = corr;
        row.case_id = cid;
        row.N = height(S);

        row.q_exp_MWm2_mean = mean(S.q_exp_MWm2, 'omitnan');
        row.q_calc_MWm2_mean = mean(S.q_calc_MWm2, 'omitnan');
        row.PM_mean = mean(S.PM, 'omitnan');

        row.x_eq_mean = mean(S.x_eq, 'omitnan');
        row.Tsub_K_mean = mean(S.Tsub_K, 'omitnan');
        row.Fcorr_mean = mean(S.Fcorr, 'omitnan');
        row.F_form_mean = mean(S.F_form, 'omitnan');

        row.z_DNB_over_DH_mean = mean(S.z_DNB_over_DH, 'omitnan');
        row.z_DNB_over_L_mean  = mean(S.z_DNB_over_L, 'omitnan');
        row.L_over_DH_mean     = mean(S.L_over_DH, 'omitnan');

        row.Tw_minus_Tsat_K_mean = mean(S.Tw_minus_Tsat_K, 'omitnan');
        row.Tm_minus_Tsat_K_mean = mean(S.Tm_minus_Tsat_K, 'omitnan');

        caseSummary = [caseSummary; row]; %#ok<AGROW>
    end
end

%% ===== Pair noF1/F1 and BT02 lift summary =====

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
        row.qcalc_lift_ratio_F1_over_noF1 = safeRatio(B.q_calc_MWm2, A.q_calc_MWm2);
        row.PM_lift_ratio_F1_over_noF1 = safeRatio(B.PM, A.PM);

        row.Tsub_K = B.Tsub_K;
        row.Fcorr = B.Fcorr;
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

liftSummary = table();

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

    row.qcalc_lift_ratio_mean = mean(S.qcalc_lift_ratio_F1_over_noF1, 'omitnan');
    row.PM_lift_ratio_mean = mean(S.PM_lift_ratio_F1_over_noF1, 'omitnan');

    row.Tsub_K_mean = mean(S.Tsub_K, 'omitnan');
    row.Fcorr_mean = mean(S.Fcorr, 'omitnan');
    row.F_form_mean = mean(S.F_form, 'omitnan');
    row.x_eq_mean = mean(S.x_eq, 'omitnan');

    row.z_DNB_over_DH_mean = mean(S.z_DNB_over_DH, 'omitnan');
    row.z_DNB_over_L_mean = mean(S.z_DNB_over_L, 'omitnan');
    row.L_over_DH_mean = mean(S.L_over_DH, 'omitnan');

    row.Tw_minus_Tsat_K_mean = mean(S.Tw_minus_Tsat_K, 'omitnan');
    row.Tm_minus_Tsat_K_mean = mean(S.Tm_minus_Tsat_K, 'omitnan');

    liftSummary = [liftSummary; row]; %#ok<AGROW>
end

%% ===== 108 contrast against 161/164 =====

contrast = table();

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
    "F_form_mean"
    "x_eq_mean"
    "z_DNB_over_DH_mean"
    "z_DNB_over_L_mean"
    "L_over_DH_mean"
    "Tw_minus_Tsat_K_mean"
    "Tm_minus_Tsat_K_mean"
];

S108 = liftSummary(liftSummary.case_id=="108", :);
S161 = liftSummary(liftSummary.case_id=="161", :);
S164 = liftSummary(liftSummary.case_id=="164", :);

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

%% ===== Correlation diagnostics =====

targetVars = [
    "PM_F1"
    "delta_PM"
    "qcalc_lift_ratio_F1_over_noF1"
    "PM_lift_ratio_F1_over_noF1"
];

stateVars = [
    "Tsub_K"
    "Fcorr"
    "F_form"
    "x_eq"
    "z_DNB_over_DH"
    "z_DNB_over_L"
    "L_over_DH"
    "Tw_minus_Tsat_K"
    "Tm_minus_Tsat_K"
];

corrRows = table();

for tv = targetVars'
    for sv = stateVars'
        row = table();
        row.target = tv;
        row.state_var = sv;

        x = paired.(sv);
        y = paired.(tv);

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

%% ===== Reproduction check against expected BT01/BT02 values =====
% 既知のBT01/BT02値をQCとして保持する。
% 厳密一致ではなく、current入力で同じオーダー・同じ平均値になっているかを確認する。

expected = table( ...
    ["108"; "161"; "164"], ...
    [3.03625; 1.41360; 1.18876], ...
    [1.90032; 0.911914; 0.702336], ...
    [3.23576; 1.29514; 1.06698], ...
    [0.621831; 0.620980; 0.570923], ...
    [1.06679; 0.908841; 0.892018], ...
    'VariableNames', {'case_id','q_exp_MWm2_expected','q_calc_noF1_MWm2_expected','q_calc_F1_MWm2_expected','PM_noF1_expected','PM_F1_expected'} ...
);

reproCheck = table();

for i = 1:height(expected)
    cid = expected.case_id(i);
    S = liftSummary(liftSummary.case_id == cid, :);

    row = table();
    row.case_id = cid;

    row.q_exp_MWm2_actual = S.q_exp_MWm2_mean;
    row.q_exp_MWm2_expected = expected.q_exp_MWm2_expected(i);
    row.q_exp_MWm2_diff = row.q_exp_MWm2_actual - row.q_exp_MWm2_expected;

    row.q_calc_noF1_MWm2_actual = S.q_calc_noF1_MWm2_mean;
    row.q_calc_noF1_MWm2_expected = expected.q_calc_noF1_MWm2_expected(i);
    row.q_calc_noF1_MWm2_diff = row.q_calc_noF1_MWm2_actual - row.q_calc_noF1_MWm2_expected;

    row.q_calc_F1_MWm2_actual = S.q_calc_F1_MWm2_mean;
    row.q_calc_F1_MWm2_expected = expected.q_calc_F1_MWm2_expected(i);
    row.q_calc_F1_MWm2_diff = row.q_calc_F1_MWm2_actual - row.q_calc_F1_MWm2_expected;

    row.PM_noF1_actual = S.PM_noF1_mean;
    row.PM_noF1_expected = expected.PM_noF1_expected(i);
    row.PM_noF1_diff = row.PM_noF1_actual - row.PM_noF1_expected;

    row.PM_F1_actual = S.PM_F1_mean;
    row.PM_F1_expected = expected.PM_F1_expected(i);
    row.PM_F1_diff = row.PM_F1_actual - row.PM_F1_expected;

    reproCheck = [reproCheck; row]; %#ok<AGROW>
end

%% ===== Definitions / notes =====

definitions = cell2table({
    "current_bundle", "BT00-1で作成したバンドル側の現行入力。r8 resultブックではない。"
    "F1", "単管データに基づくTsub補正。"
    "F_form", "F1ではない。非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。"
    "x_Mes", "バンドル側では熱平衡クオリティx_eqとして扱う。"
    "F2/F1F2", "使用しない。"
    "BT01 purpose", "108/161/164のq絶対値とP/Mの横並び再現確認。"
    "BT02 purpose", "F1後P/M差、F1/noF1リフト、x_eq、DNB履歴長、F_formの並びを確認。"
}, 'VariableNames', {'name','definition'});

%% ===== Write Excel =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(definitions, outXlsx, 'Sheet', 'definitions');
writetable(caseSummary, outXlsx, 'Sheet', 'BT01_case_summary');
writetable(liftSummary, outXlsx, 'Sheet', 'BT02_lift_summary');
writetable(contrast, outXlsx, 'Sheet', 'BT02_108_contrast');
writetable(corrRows, outXlsx, 'Sheet', 'BT02_correlations');
writetable(reproCheck, outXlsx, 'Sheet', 'reproduction_check');
writetable(paired, outXlsx, 'Sheet', 'paired_points');
writetable(detail, outXlsx, 'Sheet', 'point_detail');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Write Markdown =====

md = strings(0,1);

md(end+1) = "# BT01/BT02 current_bundle reproduction";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "r8 resultブックではなく、BT00-1で作成した current_bundle_input を使って、BT01/BT02の主要結果が再現できるか確認した。";
md(end+1) = "";
md(end+1) = "## 2. 入力と出力";
md(end+1) = "";
md(end+1) = "- 入力: `" + inputFile + "`";
md(end+1) = "- 出力Excel: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 3. 前提";
md(end+1) = "";
md(end+1) = "- F2は使わない。";
md(end+1) = "- F1F2は使わない。";
md(end+1) = "- 比較対象は noF1 と F1 のみ。";
md(end+1) = "- バンドルでは `x_Mes = x_eq` として扱う。";
md(end+1) = "- F1は単管基準のTsub補正。";
md(end+1) = "- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。";
md(end+1) = "- 補正式は作らない。";
md(end+1) = "";
md(end+1) = "## 4. BT01 case summary";
md(end+1) = "";
showCaseCols = {'correction','case_id','N','q_exp_MWm2_mean','q_calc_MWm2_mean','PM_mean','x_eq_mean','Tsub_K_mean','F_form_mean','z_DNB_over_DH_mean','z_DNB_over_L_mean','L_over_DH_mean'};
md(end+1) = tableToMarkdown(caseSummary(:, showCaseCols));
md(end+1) = "";
md(end+1) = "## 5. BT02 lift summary";
md(end+1) = "";
showLiftCols = {'case_id','N','q_exp_MWm2_mean','q_calc_noF1_MWm2_mean','q_calc_F1_MWm2_mean','PM_noF1_mean','PM_F1_mean','delta_PM_mean','qcalc_lift_ratio_mean','Tsub_K_mean','Fcorr_mean','F_form_mean','x_eq_mean','z_DNB_over_DH_mean','z_DNB_over_L_mean','L_over_DH_mean'};
md(end+1) = tableToMarkdown(liftSummary(:, showLiftCols));
md(end+1) = "";
md(end+1) = "## 6. Reproduction check";
md(end+1) = "";
md(end+1) = "既知のBT01/BT02平均値との差分を確認する。差分が十分小さければ、current_bundle入力への切替は成立とみなす。";
md(end+1) = "";
md(end+1) = tableToMarkdown(reproCheck);
md(end+1) = "";
md(end+1) = "## 7. 108 contrast against 161/164";
md(end+1) = "";
md(end+1) = tableToMarkdown(contrast);
md(end+1) = "";
md(end+1) = "## 8. Correlation diagnostics";
md(end+1) = "";
md(end+1) = "注：相関は探索的診断であり、補正式係数ではない。";
md(end+1) = "";
md(end+1) = tableToMarkdown(corrRows);
md(end+1) = "";
md(end+1) = "## 9. 次アクション";
md(end+1) = "";
md(end+1) = "1. reproduction_checkで差分を確認する。";
md(end+1) = "2. 問題なければ、working logへBT01/BT02 current_bundle再現完了を追記する。";
md(end+1) = "3. その後、BT03へ進む。";
md(end+1) = "4. BT03では、F1(Tsub)、F_form、x_eq、z_DNB/DH、z_DNB/Lを分けて、108高めP/M残差の対応関係を確認する。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display quick result =====

disp("=== BT01 case summary ===");
disp(caseSummary(:, showCaseCols));

disp("=== BT02 lift summary ===");
disp(liftSummary(:, showLiftCols));

disp("=== reproduction check ===");
disp(reproCheck);

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
