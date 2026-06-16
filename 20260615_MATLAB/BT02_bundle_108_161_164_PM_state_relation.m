%% BT02_bundle_108_161_164_PM_state_relation.m
% BT02：バンドル108/161/164のP/M差分と状態量・履歴量の関係診断
%komen
% 目的：
%   BT01で確認した
%     - q絶対値では 108高・161/164低
%     - F1後のP/Mでは 108が相対的に高く、161/164がやや低め
%   という状態について、点ごとに x_eq, z_DNB/DH, z_DNB/L, L/DH, Tsub, F1 の関係を見る。
%
% 重要：
%   - F2は使わない。
%   - F1F2は使わない。
%   - 比較対象は noF1 と F1 のみ。
%   - バンドルでは x_Mes 列に x_eq が直接入っているため、x_Mes = x_eq として扱う。
%   - 今回も補正式は作らない。
%   - 相関・回帰は探索的な診断であり、係数決定ではない。
%
% 実行方法：
%   この .m ファイルを resultブックと同じフォルダに置いて実行する。
%
% 入力ブック：
%   20260612_計算結果比較r8_result_文献追加用.xlsx
%
% 出力：
%   BT02_bundle_108_161_164_PM_state_relation_yyyymmdd_HHMMSS.xlsx
%   run_report_BT02_bundle_108_161_164_PM_state_relation_yyyymmdd_HHMMSS.md

clear; clc;

%% ===== Settings =====

inFile = "20260612_計算結果比較r8_result_文献追加用.xlsx";

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "BT02_bundle_108_161_164_PM_state_relation_" + timestamp + ".xlsx";
outMd   = "run_report_BT02_bundle_108_161_164_PM_state_relation_" + timestamp + ".md";

% noF1 と F1 のみ。F2/F1F2は対象外。
sheetMap = table( ...
    ["noF1"; "noF1"; "noF1"; "F1"; "F1"; "F1"], ...
    ["108";  "161";  "164";  "108"; "161"; "164"], ...
    ["tm_108"; "tm_161"; "tm_164"; "tm_F1_108"; "tm_F1_161"; "tm_F1_164"], ...
    'VariableNames', {'correction','case_id','sheet_name'} ...
);

stateVars = [
    "x_eq"
    "z_DNB_over_DH"
    "z_DNB_over_L"
    "L_over_DH"
    "Tsub_K"
    "Tw_minus_Tsat_K"
    "Tm_minus_Tsat_K"
    "F_form"
    "Fcorr"
];

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

%% ===== Case summary =====

summary = makeCaseSummary(detail);

%% ===== F1 effect by case and point index =====
% noF1/F1で同じ点が同じ順序で並んでいる前提で、case内の行番号で対応付ける。
% 対応が厳密でない場合でも、平均傾向を見るinternal診断として扱う。

detail.point_index_in_case = zeros(height(detail),1);
for corr = ["noF1","F1"]
    for cid = ["108","161","164"]
        idx = find(detail.correction == corr & detail.case_id == cid);
        detail.point_index_in_case(idx) = (1:numel(idx))';
    end
end

effectRows = table();

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

        row.q_exp_MWm2 = B.q_exp_MWm2;
        row.q_calc_noF1_MWm2 = A.q_calc_MWm2;
        row.q_calc_F1_MWm2   = B.q_calc_MWm2;
        row.PM_noF1 = A.PM;
        row.PM_F1   = B.PM;
        row.delta_PM_F1_minus_noF1 = B.PM - A.PM;

        if isfinite(A.PM) && abs(A.PM) > 0
            row.PM_lift_ratio_F1_over_noF1 = B.PM / A.PM;
        else
            row.PM_lift_ratio_F1_over_noF1 = NaN;
        end

        if isfinite(A.q_calc_MWm2) && abs(A.q_calc_MWm2) > 0
            row.qcalc_lift_ratio_F1_over_noF1 = B.q_calc_MWm2 / A.q_calc_MWm2;
        else
            row.qcalc_lift_ratio_F1_over_noF1 = NaN;
        end

        row.x_eq = B.x_eq;
        row.z_DNB_over_DH = B.z_DNB_over_DH;
        row.z_DNB_over_L  = B.z_DNB_over_L;
        row.L_over_DH = B.L_over_DH;
        row.Tsub_K = B.Tsub_K;
        row.F_form = B.F_form;
        row.Fcorr  = B.Fcorr;

        effectRows = [effectRows; row]; %#ok<AGROW>
    end
end

%% ===== Correlation diagnostics =====

corrRows = table();

targetVars = [
    "PM"
    "q_exp_MWm2"
    "q_calc_MWm2"
];

for corr = ["noF1","F1"]
    S = detail(detail.correction == corr, :);

    for tv = targetVars'
        for sv = stateVars'
            row = table();
            row.correction = corr;
            row.target = tv;
            row.state_var = sv;

            x = S.(sv);
            y = S.(tv);

            ok = isfinite(x) & isfinite(y);
            row.N = sum(ok);

            if row.N >= 3
                C = corrcoef(x(ok), y(ok));
                row.pearson_r = C(1,2);

                % simple linear fit: y = a + b*x
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

%% ===== Case-level contrast for F1 =====

contrastRows = table();
F1sum = summary(summary.correction=="F1", :);

S108 = F1sum(F1sum.case_id=="108", :);
S161 = F1sum(F1sum.case_id=="161", :);
S164 = F1sum(F1sum.case_id=="164", :);

metricList = [
    "q_exp_MWm2_mean"
    "q_calc_MWm2_mean"
    "PM_mean"
    "x_eq_mean"
    "z_DNB_over_DH_mean"
    "z_DNB_over_L_mean"
    "L_over_DH_mean"
    "Tsub_K_mean"
    "Tw_minus_Tsat_K_mean"
    "Tm_minus_Tsat_K_mean"
    "F_form_mean"
    "Fcorr_mean"
];

for m = metricList'
    row = table();
    row.metric = m;

    row.value_108 = S108.(m);
    row.value_161 = S161.(m);
    row.value_164 = S164.(m);
    row.mean_161_164 = mean([S161.(m), S164.(m)], 'omitnan');
    row.delta_108_minus_mean_161_164 = row.value_108 - row.mean_161_164;

    if isfinite(row.mean_161_164) && abs(row.mean_161_164) > 0
        row.ratio_108_over_mean_161_164 = row.value_108 / row.mean_161_164;
    else
        row.ratio_108_over_mean_161_164 = NaN;
    end

    contrastRows = [contrastRows; row]; %#ok<AGROW>
end

%% ===== Notes / definitions =====

definitions = cell2table({
    "PM", "P/M = q_calc / q_exp。"
    "x_eq", "バンドルでは x_Mes 列を x_eq として扱う。"
    "z_DNB_over_DH", "DNB位置までの履歴長をDHで割ったもの。"
    "z_DNB_over_L", "DNB位置の相対位置。1に近いほど出口DNB。"
    "L_over_DH", "全加熱長/DH。"
    "F_form", "F1の形状・補正に関係する列。既存ブック定義に従う。"
    "Fcorr", "補正係数列。既存ブック定義に従う。"
    "correlation diagnostics", "探索的な相関診断であり、補正式係数の決定ではない。"
}, 'VariableNames', {'name','definition'});

notes = cell2table({
    "BT02目的", "F1後P/Mの相対差を、x_eq、DNB位置、履歴長、L/DH、F1の効き方から分解する。"
    "採用前提", "F2/F1F2は使わず、noF1/F1のみ使う。"
    "主眼", "108のP/Mが相対的に大きく、161/164がやや小さい理由を探る。"
    "禁止", "この結果だけでL/DH補正式、F1置換、原因断定はしない。"
    "次段階", "相関で候補が見えた場合のみ、BT03として候補変数を限定して再確認する。"
}, 'VariableNames', {'item','note'});

%% ===== Write Excel =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(summary,      outXlsx, 'Sheet', 'BT02_case_summary');
writetable(detail,       outXlsx, 'Sheet', 'BT02_point_detail');
writetable(effectRows,   outXlsx, 'Sheet', 'BT02_F1_effect');
writetable(corrRows,     outXlsx, 'Sheet', 'BT02_correlations');
writetable(contrastRows, outXlsx, 'Sheet', 'BT02_F1_contrast');
writetable(definitions,  outXlsx, 'Sheet', 'BT02_definitions');
writetable(notes,        outXlsx, 'Sheet', 'BT02_notes');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Write Markdown =====

md = strings(0,1);

md(end+1) = "# BT02 bundle 108/161/164 PM-state relation diagnostic";
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
md(end+1) = "- 比較対象は noF1 と F1 のみ。";
md(end+1) = "- バンドルでは `x_Mes` 列を `x_eq` として扱う。";
md(end+1) = "- 今回も補正式化しない。";
md(end+1) = "- 相関・回帰は探索的診断であり、係数決定ではない。";
md(end+1) = "";
md(end+1) = "## 3. 対象シート";
md(end+1) = "";
for i = 1:height(sheetMap)
    md(end+1) = "- " + sheetMap.correction(i) + " / " + sheetMap.case_id(i) + " : `" + sheetMap.sheet_name(i) + "`";
end

md(end+1) = "";
md(end+1) = "## 4. Case summary";
md(end+1) = "";
showCols = {'correction','case_id','N','q_exp_MWm2_mean','q_calc_MWm2_mean','PM_mean', ...
            'x_eq_mean','z_DNB_over_DH_mean','z_DNB_over_L_mean','L_over_DH_mean','Tsub_K_mean'};
md(end+1) = tableToMarkdown(summary(:, showCols));

md(end+1) = "";
md(end+1) = "## 5. F1 case-level contrast: 108 vs 161/164";
md(end+1) = "";
md(end+1) = tableToMarkdown(contrastRows);

md(end+1) = "";
md(end+1) = "## 6. F1 effect summary by case";
md(end+1) = "";
effectSummary = groupsummary(effectRows, "case_id", "mean", ...
    ["PM_noF1","PM_F1","delta_PM_F1_minus_noF1","PM_lift_ratio_F1_over_noF1", ...
     "qcalc_lift_ratio_F1_over_noF1","x_eq","z_DNB_over_DH","z_DNB_over_L","Tsub_K"]);
md(end+1) = tableToMarkdown(effectSummary);

md(end+1) = "";
md(end+1) = "## 7. Correlation diagnostics";
md(end+1) = "";
md(end+1) = "注：探索的診断であり、補正式係数ではない。";
md(end+1) = "";
md(end+1) = tableToMarkdown(corrRows);

md(end+1) = "";
md(end+1) = "## 8. 見るべき問い";
md(end+1) = "";
md(end+1) = "- F1後のP/Mが108で相対的に高く、161/164でやや低い理由は何か。";
md(end+1) = "- それは x_eq の違いで説明できるか。";
md(end+1) = "- それは z_DNB/DH の違いで説明できるか。";
md(end+1) = "- それは z_DNB/L、すなわちDNBが上流寄りか出口寄りかで説明できるか。";
md(end+1) = "- L/DH全体ではなく、DNB位置までの実効履歴長として見た方がよいか。";
md(end+1) = "- F1(Tsub)は108/161/164に対して同じ意味で効いているか。";

md(end+1) = "";
md(end+1) = "## 9. まだ言ってはいけないこと";
md(end+1) = "";
md(end+1) = "- 108のP/Mが高い原因はx_eqである、と断定しない。";
md(end+1) = "- 108のP/Mが高い原因はDNB履歴長である、と断定しない。";
md(end+1) = "- 161/164のP/Mが低い原因はL/DHである、と断定しない。";
md(end+1) = "- F1を置換すべき、と断定しない。";
md(end+1) = "- BT02だけで補正式候補に進むとは言わない。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display quick output =====

disp("=== BT02 case summary ===");
disp(summary(:, showCols));

disp("=== BT02 F1 contrast ===");
disp(contrastRows);

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

    P = getNumCol(T, ["P"]);
    G = getNumCol(T, ["G"]);

    Tin  = getNumCol(T, ["Tin"]);
    Tsat = getNumCol(T, ["Ts","Tsat"]);
    Tsub = getNumCol(T, ["Tsub"]);

    xMes = getNumCol(T, ["x_Mes","xMes","x_EQ","xeq","x_eq"]);

    L_DNB = getNumCol(T, ["L_DNB","LDNB","z_DNB","zDNB"]);
    DH    = getNumCol(T, ["DH","D_h","Dh"]);
    L     = getNumCol(T, ["L","HeatedLength","L_heat"]);

    Tm = getNumCol(T, ["Tm"]);
    Tw = getNumCol(T, ["Tw"]);

    DB    = getNumCol(T, ["DB"]);
    delta = getNumCol(T, ["delta"]);
    tauw  = getNumCol(T, ["tauw","tau","Tau"]);

    F_form = getNumCol(T, ["F_form","F1"]);
    Fcorr  = getNumCol(T, ["Fcorr"]);

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

    D.P_Pa  = P;
    D.P_MPa = P ./ 1e6;
    D.G = G;

    D.Tin_K  = Tin;
    D.Tsat_K = Tsat;
    D.Tsub_K = Tsub;

    % バンドルでは x_Mes = x_eq
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

    D.DB_m    = DB;
    D.delta_m = delta;
    D.tauw    = tauw;

    D.F_form = F_form;
    D.Fcorr  = Fcorr;
end

function summary = makeCaseSummary(detail)
    summary = table();

    for corr = ["noF1","F1"]
        for cid = ["108","161","164"]
            S = detail(detail.correction == corr & detail.case_id == cid, :);

            row = table();
            row.correction = corr;
            row.case_id = cid;
            row.N = height(S);

            row.q_exp_MWm2_mean  = mean(S.q_exp_MWm2, 'omitnan');
            row.q_calc_MWm2_mean = mean(S.q_calc_MWm2, 'omitnan');
            row.PM_mean = mean(S.PM, 'omitnan');

            row.q_exp_MWm2_min  = min(S.q_exp_MWm2, [], 'omitnan');
            row.q_exp_MWm2_max  = max(S.q_exp_MWm2, [], 'omitnan');
            row.q_calc_MWm2_min = min(S.q_calc_MWm2, [], 'omitnan');
            row.q_calc_MWm2_max = max(S.q_calc_MWm2, [], 'omitnan');
            row.PM_min = min(S.PM, [], 'omitnan');
            row.PM_max = max(S.PM, [], 'omitnan');

            row.x_eq_mean = mean(S.x_eq, 'omitnan');
            row.x_eq_min  = min(S.x_eq, [], 'omitnan');
            row.x_eq_max  = max(S.x_eq, [], 'omitnan');

            row.z_DNB_over_DH_mean = mean(S.z_DNB_over_DH, 'omitnan');
            row.z_DNB_over_DH_min  = min(S.z_DNB_over_DH, [], 'omitnan');
            row.z_DNB_over_DH_max  = max(S.z_DNB_over_DH, [], 'omitnan');

            row.z_DNB_over_L_mean = mean(S.z_DNB_over_L, 'omitnan');
            row.z_DNB_over_L_min  = min(S.z_DNB_over_L, [], 'omitnan');
            row.z_DNB_over_L_max  = max(S.z_DNB_over_L, [], 'omitnan');

            row.L_over_DH_mean = mean(S.L_over_DH, 'omitnan');
            row.Tsub_K_mean = mean(S.Tsub_K, 'omitnan');
            row.Tw_minus_Tsat_K_mean = mean(S.Tw_minus_Tsat_K, 'omitnan');
            row.Tm_minus_Tsat_K_mean = mean(S.Tm_minus_Tsat_K, 'omitnan');

            row.F_form_mean = mean(S.F_form, 'omitnan');
            row.Fcorr_mean  = mean(S.Fcorr, 'omitnan');

            summary = [summary; row]; %#ok<AGROW>
        end
    end
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
