%% BT03_bundle_108_161_164_F1_Tsub_Fform_separation.m
% BT03：F1(Tsub)、F_form、x_eq、DNB履歴長を分けて確認する診断
%
% 目的：
%   BT02で混同しやすかった以下を分けて確認する。
%
%   F1:
%     単管データに基づくTsub補正。
%     代表式：
%       F1(Tsub) = 1 + A_corr * exp( - (Tsub - 40)^2 / sigma_corr )
%
%   F_form:
%     F1ではない。
%     軸方向非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。
%
%   x_Mes:
%     バンドルでは熱平衡クオリティ x_eq として扱う。
%
%   本スクリプトでは、F1/noF1の変化量を、Tsub由来のF1指標、
%   F_form、x_eq、z_DNB/DH、z_DNB/L、L/DHに分けて見る。
%
% 重要：
%   - F2は使わない。
%   - F1F2は使わない。
%   - 比較対象は noF1 と F1 のみ。
%   - この段階では補正式を作らない。
%   - 相関・回帰は探索的診断であり、係数決定ではない。
%
% 実行方法：
%   この .m ファイルを resultブックと同じフォルダに置いて実行する。
%
% 入力ブック：
%   20260612_計算結果比較r8_result_文献追加用.xlsx
%
% 出力：
%   BT03_bundle_108_161_164_F1_Tsub_Fform_separation_yyyymmdd_HHMMSS.xlsx
%   run_report_BT03_bundle_108_161_164_F1_Tsub_Fform_separation_yyyymmdd_HHMMSS.md

clear; clc;

%% ===== Settings =====

inFile = "20260612_計算結果比較r8_result_文献追加用.xlsx";

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "BT03_bundle_108_161_164_F1_Tsub_Fform_separation_" + timestamp + ".xlsx";
outMd   = "run_report_BT03_bundle_108_161_164_F1_Tsub_Fform_separation_" + timestamp + ".md";

sheetMap = table( ...
    ["noF1"; "noF1"; "noF1"; "F1"; "F1"; "F1"], ...
    ["108";  "161";  "164";  "108"; "161"; "164"], ...
    ["tm_108"; "tm_161"; "tm_164"; "tm_F1_108"; "tm_F1_161"; "tm_F1_164"], ...
    'VariableNames', {'correction','case_id','sheet_name'} ...
);

%% ===== Read point detail =====

detail = table();

for i = 1:height(sheetMap)
    corr = sheetMap.correction(i);
    cid  = sheetMap.case_id(i);
    sh   = sheetMap.sheet_name(i);

    fprintf("Reading sheet: %s / %s / %s\n", corr, cid, sh);

    T = readSheetAsTable(inFile, sh);
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

%% ===== Pair noF1/F1 rows =====

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
        row.PM_lift_ratio_F1_over_noF1    = safeRatio(B.PM, A.PM);

        % F1側の状態量を主に採用。
        row.Tsub_K = B.Tsub_K;
        row.A_corr = B.A_corr;
        row.sigma_corr = B.sigma_corr;
        row.Fcorr = B.Fcorr;

        % F1(Tsub)を列値から再計算する。
        row.F1_formula_calc = calcF1FromTsub(B.Tsub_K, B.A_corr, B.sigma_corr);

        row.F1_formula_minus_Fcorr = row.F1_formula_calc - B.Fcorr;
        row.lift_ratio_minus_Fcorr = row.qcalc_lift_ratio_F1_over_noF1 - B.Fcorr;
        row.lift_ratio_minus_F1_formula = row.qcalc_lift_ratio_F1_over_noF1 - row.F1_formula_calc;

        % F_formはF1ではなく、非一様加熱換算係数。
        row.F_form = B.F_form;

        % x_Mes = x_eq として扱う。
        row.x_eq = B.x_eq;

        row.z_DNB_over_DH = B.z_DNB_over_DH;
        row.z_DNB_over_L  = B.z_DNB_over_L;
        row.L_over_DH     = B.L_over_DH;

        row.Tw_minus_Tsat_K = B.Tw_minus_Tsat_K;
        row.Tm_minus_Tsat_K = B.Tm_minus_Tsat_K;

        paired = [paired; row]; %#ok<AGROW>
    end
end

%% ===== Summary by case =====

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

    row.qcalc_lift_ratio_mean = mean(S.qcalc_lift_ratio_F1_over_noF1, 'omitnan');
    row.PM_lift_ratio_mean = mean(S.PM_lift_ratio_F1_over_noF1, 'omitnan');

    row.Tsub_K_mean = mean(S.Tsub_K, 'omitnan');
    row.Fcorr_mean = mean(S.Fcorr, 'omitnan');
    row.F1_formula_calc_mean = mean(S.F1_formula_calc, 'omitnan');
    row.F1_formula_minus_Fcorr_mean = mean(S.F1_formula_minus_Fcorr, 'omitnan');

    row.lift_ratio_minus_Fcorr_mean = mean(S.lift_ratio_minus_Fcorr, 'omitnan');
    row.lift_ratio_minus_F1_formula_mean = mean(S.lift_ratio_minus_F1_formula, 'omitnan');

    row.F_form_mean = mean(S.F_form, 'omitnan');
    row.x_eq_mean = mean(S.x_eq, 'omitnan');
    row.z_DNB_over_DH_mean = mean(S.z_DNB_over_DH, 'omitnan');
    row.z_DNB_over_L_mean = mean(S.z_DNB_over_L, 'omitnan');
    row.L_over_DH_mean = mean(S.L_over_DH, 'omitnan');

    row.Tw_minus_Tsat_K_mean = mean(S.Tw_minus_Tsat_K, 'omitnan');
    row.Tm_minus_Tsat_K_mean = mean(S.Tm_minus_Tsat_K, 'omitnan');

    caseSummary = [caseSummary; row]; %#ok<AGROW>
end

%% ===== 108 contrast against 161/164 =====

contrast = table();

metrics = [
    "PM_noF1_mean"
    "PM_F1_mean"
    "delta_PM_mean"
    "qcalc_lift_ratio_mean"
    "PM_lift_ratio_mean"
    "Tsub_K_mean"
    "Fcorr_mean"
    "F1_formula_calc_mean"
    "lift_ratio_minus_Fcorr_mean"
    "lift_ratio_minus_F1_formula_mean"
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
    "F1_formula_calc"
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

%% ===== Definitions / notes =====

definitions = cell2table({
    "F1", "単管データに基づくTsub補正。代表式は 1 + A_corr * exp(-(Tsub-40)^2/sigma_corr)。"
    "F_form", "F1ではない。非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。"
    "x_Mes", "バンドルでは熱平衡クオリティ x_eq として扱う。COBRA-ENクオリティとは混同しない。"
    "Fcorr", "ブック中の補正係数列。F1(Tsub)再計算値との一致を本シートで確認する。"
    "qcalc_lift_ratio", "q_calc_F1 / q_calc_noF1。最終q計算におけるF1有無の実効持ち上げ倍率。"
    "PM_lift_ratio", "PM_F1 / PM_noF1。P/Mの実効持ち上げ倍率。"
    "delta_PM", "PM_F1 - PM_noF1。"
    "z_DNB_over_DH", "DNB位置までの実効履歴長をDHで割った値。"
    "z_DNB_over_L", "DNB位置の相対位置。1に近いほど出口DNB。"
    "注意", "相関・回帰は探索的診断であり、補正式係数ではない。"
}, 'VariableNames', {'name','definition'});

notes = cell2table({
    "BT03目的", "F1(Tsub)、F_form、x_eq、DNB履歴長を混同せずに分けて確認する。"
    "重要前提", "F_formはF1ではない。"
    "重要前提", "x_Mesはバンドルではx_eqとして扱う。"
    "重要前提", "F2/F1F2は使わない。"
    "禁止", "BT03だけでF1置換やL/DH補正式化を判断しない。"
}, 'VariableNames', {'item','note'});

%% ===== Write Excel =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(caseSummary, outXlsx, 'Sheet', 'BT03_case_summary');
writetable(paired,      outXlsx, 'Sheet', 'BT03_paired_points');
writetable(contrast,    outXlsx, 'Sheet', 'BT03_108_contrast');
writetable(corrRows,    outXlsx, 'Sheet', 'BT03_correlations');
writetable(definitions, outXlsx, 'Sheet', 'BT03_definitions');
writetable(notes,       outXlsx, 'Sheet', 'BT03_notes');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Write Markdown =====

md = strings(0,1);

md(end+1) = "# BT03 bundle 108/161/164 F1-Tsub-Fform separation";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 入力と出力";
md(end+1) = "";
md(end+1) = "- 入力ブック: `" + inFile + "`";
md(end+1) = "- 出力Excel: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 2. 前提";
md(end+1) = "";
md(end+1) = "- F2は使わない。";
md(end+1) = "- F1F2は使わない。";
md(end+1) = "- F1は単管データに基づくTsub補正。";
md(end+1) = "- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。";
md(end+1) = "- バンドルでは `x_Mes = x_eq` として扱う。";
md(end+1) = "- 今回も補正式化しない。";
md(end+1) = "- 相関・回帰は探索的診断であり、係数決定ではない。";
md(end+1) = "";
md(end+1) = "## 3. Case summary";
md(end+1) = "";
showSummaryCols = {'case_id','N','q_exp_MWm2_mean','q_calc_noF1_MWm2_mean','q_calc_F1_MWm2_mean', ...
                   'PM_noF1_mean','PM_F1_mean','delta_PM_mean','qcalc_lift_ratio_mean', ...
                   'Tsub_K_mean','Fcorr_mean','F1_formula_calc_mean','F_form_mean', ...
                   'x_eq_mean','z_DNB_over_DH_mean','z_DNB_over_L_mean','L_over_DH_mean'};
md(end+1) = tableToMarkdown(caseSummary(:, showSummaryCols));

md(end+1) = "";
md(end+1) = "## 4. 108 contrast against 161/164";
md(end+1) = "";
md(end+1) = tableToMarkdown(contrast);

md(end+1) = "";
md(end+1) = "## 5. Correlation diagnostics";
md(end+1) = "";
md(end+1) = "注：探索的診断であり、補正式係数ではない。";
md(end+1) = "";
md(end+1) = tableToMarkdown(corrRows);

md(end+1) = "";
md(end+1) = "## 6. 確認したい問い";
md(end+1) = "";
md(end+1) = "- F1(Tsub)再計算値は、ブック上のFcorrと一致するか。";
md(end+1) = "- q_calc_F1/q_calc_noF1 は、単純なFcorr倍率と同じか、それとも大きく違うか。";
md(end+1) = "- 108のP/M上昇はTsub/F1由来で説明できるか。";
md(end+1) = "- F_formはF1ではなく、非一様加熱換算係数としてPMやqとどう並んでいるか。";
md(end+1) = "- x_eq、z_DNB/DH、z_DNB/L、L/DHは、108高め残差とどう並んでいるか。";

md(end+1) = "";
md(end+1) = "## 7. まだ言ってはいけないこと";
md(end+1) = "";
md(end+1) = "- F_formがF1の効き方を表している、と言わない。";
md(end+1) = "- F1(Tsub)だけで108/161/164のP/M差が説明できる、と断定しない。";
md(end+1) = "- L/DHまたはz_DNB/DHが原因である、と断定しない。";
md(end+1) = "- BT03だけでF1を置換すべき、と言わない。";
md(end+1) = "- BT03だけで補正式候補に進むとは言わない。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display quick result =====

disp("=== BT03 case summary ===");
disp(caseSummary(:, showSummaryCols));

disp("=== BT03 108 contrast ===");
disp(contrast);

%% ===== Local functions =====

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

    A_corr = getNumCol(T, ["A_corr","Acorr","A"]);
    sigma_corr = getNumCol(T, ["σ_corr","sigma_corr","sigmacorr","sigma","sigmaCorr"]);
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

    D.A_corr = A_corr;
    D.sigma_corr = sigma_corr;
    D.Fcorr = Fcorr;

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

function out = calcF1FromTsub(Tsub, A_corr, sigma_corr)
    out = NaN(size(Tsub));
    ok = isfinite(Tsub) & isfinite(A_corr) & isfinite(sigma_corr) & sigma_corr ~= 0;
    out(ok) = 1 + A_corr(ok) .* exp(-((Tsub(ok) - 40).^2) ./ sigma_corr(ok));
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
                    row(j) = string(sprintf("%.6g", val));
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
