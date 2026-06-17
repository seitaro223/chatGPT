%% BT10C_FformLinear_adoption_decision_package.m
% BT10-C：FformLinear_v1の採用判断パッケージを作る
%
% 目的：
%   BT10-Bの結果を受けて、legacy F_form と FformLinear_v1 を比較し、
%   FformLinear_v1を
%
%     1. 正本候補として採用するのか
%     2. legacy併記の感度ケースとして扱うのか
%     3. 補正式化せず診断課題として残すのか
%
%   を判断するための整理表を作る。
%
% 重要：
%   - ここでも補正式は作らない。
%   - F_formはF1ではない。
%   - F1(Tsub)は維持する。
%   - F1(Tsub)をF(x_eq)へ置換しない。
%   - L/DH補正式、z_DNB/DH補正式、Fform残差補正式へ進まない。
%
% 入力：
%   - H52Q_current_bundle_input_v1_*.xlsx
%   - BT10B_FformLinear_residual_diagnostic_*.xlsx
%     または、BT09-B後の *F1なし_FformLinear_v1_*.xlsm と *F1あり_FformLinear_v1_*.xlsm
%
% 出力：
%   - BT10C_FformLinear_adoption_decision_yyyymmdd_HHMMSS.xlsx
%   - run_report_BT10C_FformLinear_adoption_decision_yyyymmdd_HHMMSS.md
%
% 次：
%   BT11：
%     FformLinear_v1の扱いを作業ログへ固定し、
%     次フェーズの論点を決める。

clear; clc;

%% ===== Settings =====

inputLegacyBundleFile = "";
inputBT10BFile = "";
inputNoF1LinearFile = "";
inputF1LinearFile = "";

if strlength(inputLegacyBundleFile) == 0
    inputLegacyBundleFile = findLatestFile("H52Q_current_bundle_input_v1_*.xlsx");
end

if strlength(inputBT10BFile) == 0
    d = dir("BT10B_FformLinear_residual_diagnostic_*.xlsx");
    if ~isempty(d)
        [~, idx] = max([d.datenum]);
        inputBT10BFile = string(d(idx).name);
    end
end

if strlength(inputBT10BFile) == 0
    if strlength(inputNoF1LinearFile) == 0
        inputNoF1LinearFile = findLatestFile("*F1なし_FformLinear_v1_*.xlsm");
    end
    if strlength(inputF1LinearFile) == 0
        inputF1LinearFile = findLatestFile("*F1あり_FformLinear_v1_*.xlsm");
    end
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "BT10C_FformLinear_adoption_decision_" + timestamp + ".xlsx";
outMd = "run_report_BT10C_FformLinear_adoption_decision_" + timestamp + ".md";

fprintf("Legacy current_bundle: %s\n", inputLegacyBundleFile);
if strlength(inputBT10BFile) > 0
    fprintf("BT10B workbook       : %s\n", inputBT10BFile);
else
    fprintf("Linear noF1 workbook : %s\n", inputNoF1LinearFile);
    fprintf("Linear F1 workbook   : %s\n", inputF1LinearFile);
end

%% ===== Read data =====

legacyJoined = readLegacyCurrentBundle(inputLegacyBundleFile);

if strlength(inputBT10BFile) > 0
    linearJoined = readtable(inputBT10BFile, 'Sheet', 'BT10B_joined', 'VariableNamingRule', 'preserve');
else
    linearJoined = readLinearFromMacroBooks(inputNoF1LinearFile, inputF1LinearFile);
end

legacyJoined = normalizeJoinedLegacy(legacyJoined);
linearJoined = normalizeJoinedLinear(linearJoined);

compareRows = joinLegacyLinear(legacyJoined, linearJoined);

%% ===== Summaries =====

bundleSummary = summarizeCompare(compareRows, "Bundle");
caseSummary = summarizeCompare(compareRows, "case_label");
metricSummary = makeMetricSummary(compareRows);
decision = makeDecision(compareRows, bundleSummary, metricSummary);
adoptionOptions = makeAdoptionOptions();
nextSteps = makeNextSteps();

%% ===== Write outputs =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(compareRows, outXlsx, 'Sheet', 'BT10C_compare_rows');
writetable(bundleSummary, outXlsx, 'Sheet', 'BT10C_bundle_summary');
writetable(caseSummary, outXlsx, 'Sheet', 'BT10C_case_summary');
writetable(metricSummary, outXlsx, 'Sheet', 'BT10C_metric_summary');
writetable(decision, outXlsx, 'Sheet', 'BT10C_decision_flags');
writetable(adoptionOptions, outXlsx, 'Sheet', 'BT10C_adoption_options');
writetable(nextSteps, outXlsx, 'Sheet', 'BT10C_next_steps');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Markdown report =====

md = strings(0,1);

md(end+1) = "# BT10-C FformLinear_v1 adoption decision package";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT10-Bの結果を受けて、legacy F_formとFformLinear_v1を比較し、FformLinear_v1を正本候補にするか、legacy併記感度として扱うかを判断する。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- legacy current_bundle: `" + inputLegacyBundleFile + "`";
if strlength(inputBT10BFile) > 0
    md(end+1) = "- BT10B workbook: `" + inputBT10BFile + "`";
else
    md(end+1) = "- noF1 linear macro: `" + inputNoF1LinearFile + "`";
    md(end+1) = "- F1 linear macro: `" + inputF1LinearFile + "`";
end
md(end+1) = "";
md(end+1) = "## 3. 前提";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "- F1(Tsub)は維持する。";
md(end+1) = "- F1(Tsub)をF(x_eq)へ置換しない。";
md(end+1) = "- F_formはF1ではない。";
md(end+1) = "- FformLinear_v1は定義の一貫化であり、残差補正式ではない。";
md(end+1) = "- 108悪化と164改善を同時に見る。";
md(end+1) = "- R2や誤差指標が良くても、ここで新補正式は作らない。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 4. Bundle summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(bundleSummary);
md(end+1) = "";
md(end+1) = "## 5. Case summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(caseSummary);
md(end+1) = "";
md(end+1) = "## 6. Metric summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(metricSummary);
md(end+1) = "";
md(end+1) = "## 7. Decision flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(decision);
md(end+1) = "";
md(end+1) = "## 8. Adoption options";
md(end+1) = "";
md(end+1) = tableToMarkdown(adoptionOptions);
md(end+1) = "";
md(end+1) = "## 9. Next steps";
md(end+1) = "";
md(end+1) = tableToMarkdown(nextSteps);
md(end+1) = "";
md(end+1) = "## 10. 判断メモ";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "- FformLinear_v1は、legacyより定義としては一貫している。";
md(end+1) = "- ただし、予測性能としては164を改善する一方、108を過大側に悪化させる。";
md(end+1) = "- したがって、FformLinear_v1を残差補正式として採用するのではなく、定義正規化・感度ケースとして扱うのが安全。";
md(end+1) = "- 最終的に正本化する場合も、legacy比較結果を併記して判断する。";
md(end+1) = "```";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display =====

disp("=== Bundle summary ===");
disp(bundleSummary);

disp("=== Metric summary ===");
disp(metricSummary);

disp("=== Decision ===");
disp(decision);

%% ===== Local functions =====

function latest = findLatestFile(pattern)
    d = dir(pattern);
    if isempty(d)
        error("No file matching pattern: %s", pattern);
    end
    [~, idx] = max([d.datenum]);
    latest = string(d(idx).name);
end

function joined = readLegacyCurrentBundle(file)
    Tno = readLegacySheets(file, ["tm_108","tm_161","tm_164"], "noF1");
    Tf1 = readLegacySheets(file, ["tm_F1_108","tm_F1_161","tm_F1_164"], "F1");

    joined = table();

    for i = 1:height(Tf1)
        no = Tf1.No(i);
        idx = find(Tno.No == no, 1);
        if isempty(idx)
            continue;
        end

        row = table();
        row.No = no;
        row.Bundle = Tf1.Bundle(i);
        row.case_label = Tf1.case_label(i);
        row.PM_noF1_legacy = Tno.PM(idx);
        row.PM_F1_legacy = Tf1.PM(i);
        row.qP_noF1_legacy_MWm2 = Tno.qP_MWm2(idx);
        row.qP_F1_legacy_MWm2 = Tf1.qP_MWm2(i);
        row.qM_MWm2 = Tf1.qM_MWm2(i);
        row.Fform_legacy = Tf1.F_form(i);
        row.Tsub = Tf1.Tsub(i);
        row.Fcorr = Tf1.Fcorr(i);
        row.x_eq = Tf1.x_eq(i);
        row.z_DNB_DH = Tf1.z_DNB_DH(i);
        row.z_DNB_L = Tf1.z_DNB_L(i);
        row.L_DH = Tf1.L_DH(i);
        joined = [joined; row]; %#ok<AGROW>
    end
end

function Tall = readLegacySheets(file, sheets, kind)
    Tall = table();

    for sh = string(sheets)
        raw = readtable(file, 'Sheet', sh, 'VariableNamingRule', 'preserve');
        T = normalizeTmLikeTable(raw, kind, file);
        Tall = [Tall; T]; %#ok<AGROW>
    end
end

function joined = readLinearFromMacroBooks(noFile, f1File)
    Tno_raw = readtable(noFile, 'Sheet', 'tm', 'VariableNamingRule', 'preserve');
    Tf1_raw = readtable(f1File, 'Sheet', 'tm', 'VariableNamingRule', 'preserve');

    Tno = normalizeTmLikeTable(Tno_raw, "noF1", noFile);
    Tf1 = normalizeTmLikeTable(Tf1_raw, "F1", f1File);

    joined = table();

    for i = 1:height(Tf1)
        no = Tf1.No(i);
        idx = find(Tno.No == no, 1);
        if isempty(idx)
            continue;
        end

        row = table();
        row.No = no;
        row.Bundle = Tf1.Bundle(i);
        row.case_label = Tf1.case_label(i);
        row.PM_noF1_linear = Tno.PM(idx);
        row.PM_F1_linear = Tf1.PM(i);
        row.qP_noF1_MWm2 = Tno.qP_MWm2(idx);
        row.qP_F1_MWm2 = Tf1.qP_MWm2(i);
        row.qM_MWm2 = Tf1.qM_MWm2(i);
        row.Fform_linear = Tf1.F_form(i);
        row.Tsub = Tf1.Tsub(i);
        row.Fcorr = Tf1.Fcorr(i);
        row.x_eq = Tf1.x_eq(i);
        row.z_DNB_DH = Tf1.z_DNB_DH(i);
        row.z_DNB_L = Tf1.z_DNB_L(i);
        row.L_DH = Tf1.L_DH(i);
        joined = [joined; row]; %#ok<AGROW>
    end
end

function T = normalizeTmLikeTable(raw, kind, sourceFile)
    n = height(raw);

    T = table();
    T.No = getNumCol(raw, ["No","NO","no"]);
    T.Bundle = NaN(n,1);
    T.case_label = strings(n,1);

    for i = 1:n
        [b, c] = inferBundleCase(T.No(i));
        T.Bundle(i) = b;
        T.case_label(i) = c;
    end

    T.target_kind = repmat(string(kind), n, 1);
    T.source_file = repmat(string(sourceFile), n, 1);

    T.PM = getNumCol(raw, ["PM_ratio","PM","P/M","PMratio"]);
    T.qP_MWm2 = getNumCol(raw, ["q_P_MW","qP_MW","q_P_MWm2","q_P"]);
    T.qM_MWm2 = getNumCol(raw, ["q_M_MW","qM_MW","q_M_MWm2","q_M"]);
    T.F_form = getNumCol(raw, ["F_form","Fform","F_FORM"]);
    T.Tsub = getNumCol(raw, ["Tsub","T_sub","Tsub_K"]);
    T.Fcorr = getNumCol(raw, ["Fcorr","F_corr"]);
    T.x_eq = getNumCol(raw, ["x_Mes","xMes","x_eq","xeq"]);
    T.L_DNB = getNumCol(raw, ["L_DNB","LDNB","z_DNB","zDNB"]);
    T.L = getNumCol(raw, ["L","HeatedLength","L_heat"]);
    T.DH = getNumCol(raw, ["DH","D_h","Dh"]);

    if mean(T.qP_MWm2, 'omitnan') > 1000
        T.qP_MWm2 = T.qP_MWm2 / 1e6;
    end
    if mean(T.qM_MWm2, 'omitnan') > 1000
        T.qM_MWm2 = T.qM_MWm2 / 1e6;
    end

    T.z_DNB_DH = T.L_DNB ./ T.DH;
    T.z_DNB_L = T.L_DNB ./ T.L;
    T.L_DH = T.L ./ T.DH;

    keep = isfinite(T.No) & ismember(T.Bundle, [108,161,164]);
    T = T(keep,:);
end

function L = normalizeJoinedLegacy(L)
    L.err_F1_legacy = L.PM_F1_legacy - 1;
    L.err_noF1_legacy = L.PM_noF1_legacy - 1;
    L.delta_PM_legacy = L.PM_F1_legacy - L.PM_noF1_legacy;
    L.lift_ratio_legacy = L.PM_F1_legacy ./ L.PM_noF1_legacy;
end

function L = normalizeJoinedLinear(L)
    vars = string(L.Properties.VariableNames);

    % BT10B_joined already has most fields. This makes aliases robust.
    if ismember("PM_noF1_linear", vars) == false && ismember("PM_noF1", vars)
        L.PM_noF1_linear = L.PM_noF1;
    end
    if ismember("PM_F1_linear", vars) == false && ismember("PM_F1", vars)
        L.PM_F1_linear = L.PM_F1;
    end
    if ismember("Fform_linear", vars) == false && ismember("F_form", vars)
        L.Fform_linear = L.F_form;
    end

    L.err_F1_linear = L.PM_F1_linear - 1;
    L.err_noF1_linear = L.PM_noF1_linear - 1;
    L.delta_PM_linear = L.PM_F1_linear - L.PM_noF1_linear;
    L.lift_ratio_linear = L.PM_F1_linear ./ L.PM_noF1_linear;
end

function C = joinLegacyLinear(A, B)
    C = table();

    for i = 1:height(A)
        no = A.No(i);
        idx = find(B.No == no, 1);
        if isempty(idx)
            continue;
        end

        row = table();
        row.No = no;
        row.Bundle = A.Bundle(i);
        row.case_label = A.case_label(i);

        row.PM_noF1_legacy = A.PM_noF1_legacy(i);
        row.PM_noF1_linear = B.PM_noF1_linear(idx);
        row.PM_F1_legacy = A.PM_F1_legacy(i);
        row.PM_F1_linear = B.PM_F1_linear(idx);

        row.err_F1_legacy = A.err_F1_legacy(i);
        row.err_F1_linear = B.err_F1_linear(idx);
        row.abs_err_F1_legacy = abs(A.err_F1_legacy(i));
        row.abs_err_F1_linear = abs(B.err_F1_linear(idx));

        row.delta_PM_legacy = A.delta_PM_legacy(i);
        row.delta_PM_linear = B.delta_PM_linear(idx);
        row.lift_ratio_legacy = A.lift_ratio_legacy(i);
        row.lift_ratio_linear = B.lift_ratio_linear(idx);

        row.Fform_legacy = A.Fform_legacy(i);
        row.Fform_linear = B.Fform_linear(idx);
        row.delta_Fform = row.Fform_linear - row.Fform_legacy;
        row.ratio_Fform_linear_to_legacy = row.Fform_linear ./ row.Fform_legacy;

        row.delta_PM_F1_linear_minus_legacy = row.PM_F1_linear - row.PM_F1_legacy;
        row.delta_abs_err_linear_minus_legacy = row.abs_err_F1_linear - row.abs_err_F1_legacy;

        row.qP_F1_legacy_MWm2 = A.qP_F1_legacy_MWm2(i);
        if ismember("qP_F1_MWm2", string(B.Properties.VariableNames))
            row.qP_F1_linear_MWm2 = B.qP_F1_MWm2(idx);
        else
            row.qP_F1_linear_MWm2 = NaN;
        end
        row.qM_MWm2 = A.qM_MWm2(i);

        row.Tsub = A.Tsub(i);
        row.Fcorr = A.Fcorr(i);
        row.x_eq = A.x_eq(i);
        row.z_DNB_DH = A.z_DNB_DH(i);
        row.z_DNB_L = A.z_DNB_L(i);
        row.L_DH = A.L_DH(i);

        C = [C; row]; %#ok<AGROW>
    end
end

function S = summarizeCompare(T, keyVar)
    S = table();
    keyVar = string(keyVar);
    keys = unique(T.(keyVar));

    for k = keys(:)'
        R = T(T.(keyVar) == k, :);

        row = table();
        row.(keyVar) = k;
        row.N = height(R);
        row.No_min = min(R.No, [], 'omitnan');
        row.No_max = max(R.No, [], 'omitnan');

        row.PM_F1_legacy_mean = mean(R.PM_F1_legacy, 'omitnan');
        row.PM_F1_linear_mean = mean(R.PM_F1_linear, 'omitnan');
        row.delta_PM_F1_linear_minus_legacy_mean = mean(R.delta_PM_F1_linear_minus_legacy, 'omitnan');

        row.abs_err_F1_legacy_mean = mean(R.abs_err_F1_legacy, 'omitnan');
        row.abs_err_F1_linear_mean = mean(R.abs_err_F1_linear, 'omitnan');
        row.delta_abs_err_linear_minus_legacy_mean = mean(R.delta_abs_err_linear_minus_legacy, 'omitnan');

        row.PM_noF1_legacy_mean = mean(R.PM_noF1_legacy, 'omitnan');
        row.PM_noF1_linear_mean = mean(R.PM_noF1_linear, 'omitnan');

        row.Fform_legacy_mean = mean(R.Fform_legacy, 'omitnan');
        row.Fform_linear_mean = mean(R.Fform_linear, 'omitnan');
        row.delta_Fform_mean = mean(R.delta_Fform, 'omitnan');

        row.Tsub_mean = mean(R.Tsub, 'omitnan');
        row.x_eq_mean = mean(R.x_eq, 'omitnan');
        row.z_DNB_DH_mean = mean(R.z_DNB_DH, 'omitnan');
        row.z_DNB_L_mean = mean(R.z_DNB_L, 'omitnan');
        row.L_DH_mean = mean(R.L_DH, 'omitnan');

        S = [S; row]; %#ok<AGROW>
    end
end

function M = makeMetricSummary(T)
    M = table();

    addMetrics("row_weighted_all", T);

    bundles = unique(T.Bundle);
    for b = bundles(:)'
        addMetrics("row_weighted_bundle_" + string(b), T(T.Bundle == b,:));
    end

    % bundle-mean metrics
    B = summarizeCompare(T, "Bundle");
    R = table();
    R.err_legacy = B.PM_F1_legacy_mean - 1;
    R.err_linear = B.PM_F1_linear_mean - 1;
    addMetricRow("bundle_mean_MAE_F1", mean(abs(R.err_legacy), 'omitnan'), mean(abs(R.err_linear), 'omitnan'), "bundle平均を同じ重みで見たMAE");
    addMetricRow("bundle_mean_RMSE_F1", sqrt(mean(R.err_legacy.^2, 'omitnan')), sqrt(mean(R.err_linear.^2, 'omitnan')), "bundle平均を同じ重みで見たRMSE");
    addMetricRow("bundle_mean_bias_F1", mean(R.err_legacy, 'omitnan'), mean(R.err_linear, 'omitnan'), "bundle平均を同じ重みで見たbias");

    function addMetrics(label, R0)
        eOld = R0.PM_F1_legacy - 1;
        eNew = R0.PM_F1_linear - 1;
        addMetricRow(label + "_MAE_F1", mean(abs(eOld), 'omitnan'), mean(abs(eNew), 'omitnan'), "row重みMAE");
        addMetricRow(label + "_RMSE_F1", sqrt(mean(eOld.^2, 'omitnan')), sqrt(mean(eNew.^2, 'omitnan')), "row重みRMSE");
        addMetricRow(label + "_bias_F1", mean(eOld, 'omitnan'), mean(eNew, 'omitnan'), "row重みbias");
    end

    function addMetricRow(metric, legacyVal, linearVal, note)
        row = table();
        row.metric = string(metric);
        row.legacy = legacyVal;
        row.linear_v1 = linearVal;
        row.delta_linear_minus_legacy = linearVal - legacyVal;
        if linearVal < legacyVal
            row.direction = "improved_if_smaller";
        elseif linearVal > legacyVal
            row.direction = "worse_if_smaller";
        else
            row.direction = "same";
        end
        row.note = string(note);
        M = [M; row]; %#ok<AGROW>
    end
end

function D = makeDecision(T, bundleSummary, metricSummary)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("row_join", "OK", sprintf("N=%d", height(T)), "legacyとlinear_v1をNoで結合。期待値は58。");

    pm108_legacy = getBundleVal(bundleSummary, 108, "PM_F1_legacy_mean");
    pm108_linear = getBundleVal(bundleSummary, 108, "PM_F1_linear_mean");
    pm164_legacy = getBundleVal(bundleSummary, 164, "PM_F1_legacy_mean");
    pm164_linear = getBundleVal(bundleSummary, 164, "PM_F1_linear_mean");
    pm161_legacy = getBundleVal(bundleSummary, 161, "PM_F1_legacy_mean");
    pm161_linear = getBundleVal(bundleSummary, 161, "PM_F1_linear_mean");

    add("108_effect", "caution", sprintf("%.6g -> %.6g", pm108_legacy, pm108_linear), "108はFformLinear_v1で過大側へ悪化。");
    add("161_effect", "neutral", sprintf("%.6g -> %.6g", pm161_legacy, pm161_linear), "161は一様加熱で変化しない。");
    add("164_effect", "improve", sprintf("%.6g -> %.6g", pm164_legacy, pm164_linear), "164はFformLinear_v1で改善。");

    add("definition_status", "adopt_candidate", "linear_v1", "FformLinear_v1はlegacyより定義が一貫している。");
    add("performance_status", "mixed", "108 worsens, 164 improves", "予測性能の改善は一様ではない。");
    add("recommended_handling", "adopt_with_caution", "canonical_candidate_plus_legacy_sensitivity", "正本候補にする場合も、legacy比較を併記する。");
    add("formula_status", "do_not_formula", "no new correction", "FformLinear_v1を残差補正式として使わない。");
    add("F1_status", "keep", "F1(Tsub)", "F1(Tsub)は維持。F(x_eq)へ置換しない。");
    add("next", "next", "BT11", "BT10-C結果をログへ固定し、FformLinear_v1の扱いを決める。");

    D = table(item, status, value, reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function A = makeAdoptionOptions()
    option = strings(0,1);
    status = strings(0,1);
    meaning = strings(0,1);
    risk = strings(0,1);
    recommendation = strings(0,1);

    add("Option 1: adopt linear_v1 as canonical", "candidate", ...
        "F_formの定義はlinear_v1へ統一し、legacyは履歴・感度比較として残す。", ...
        "108の過大化を説明できないまま正本化するリスク。", ...
        "定義の一貫性を重視するなら採用。ただし結果比較は必ず併記。");

    add("Option 2: keep legacy as main and linear_v1 as sensitivity", "safe_short_term", ...
        "従来結果を主にし、linear_v1は感度ケースとして扱う。", ...
        "F_form定義の不整合を残すリスク。", ...
        "報告前の保守的運用としては安全。");

    add("Option 3: create new residual correction", "reject_now", ...
        "FformLinear後の残差をさらにFform/L_DH/z_DNBで補正する。", ...
        "108/164の局所的都合合わせになりやすい。", ...
        "現時点では採用しない。");

    add("Option 4: revert to legacy", "reject_as_final", ...
        "FformLinear作業を戻し、legacyだけで進む。", ...
        "164低め残差の一部がlegacy定義由来だった可能性を無視する。", ...
        "完全撤回はしない。legacyは比較用に保持。");

    A = table(option, status, meaning, risk, recommendation);

    function add(a,b,c,d,e)
        option(end+1,1) = string(a);
        status(end+1,1) = string(b);
        meaning(end+1,1) = string(c);
        risk(end+1,1) = string(d);
        recommendation(end+1,1) = string(e);
    end
end

function N = makeNextSteps()
    step = (1:6)';
    action = strings(6,1);
    detail = strings(6,1);

    action(1) = "Review BT10-C package";
    detail(1) = "Check bundle_summary, metric_summary, decision_flags, and adoption_options.";

    action(2) = "Decide handling";
    detail(2) = "Choose canonical_candidate_plus_legacy_sensitivity or legacy_main_linear_sensitivity.";

    action(3) = "Do not create formula";
    detail(3) = "Do not create Fform/L_DH/z_DNB residual correction from 108/161/164 alone.";

    action(4) = "Update working log";
    detail(4) = "Append BT10-B/BT10-C interpretation to working log.";

    action(5) = "Proceed to BT11";
    detail(5) = "BT11 should fix final wording for FformLinear_v1 and residual interpretation.";

    action(6) = "Optional";
    detail(6) = "If needed, inspect axial profile/DNB geometry for 108 overprediction, but not as formula fitting.";

    N = table(step, action, detail);
end

function val = getBundleVal(S, bundle, varName)
    R = S(S.Bundle == bundle,:);
    if isempty(R)
        val = NaN;
    else
        val = R.(varName)(1);
    end
end

function [bundle, label] = inferBundleCase(no)
    if ~isfinite(no)
        bundle = NaN;
        label = "";
        return;
    end
    no = round(no);

    if no >= 229 && no <= 254
        bundle = 108;
        if no == 252 || no == 253
            label = "108_76in";
        else
            label = "108_70in";
        end
    elseif no >= 268 && no <= 317
        bundle = 161;
        label = "161_uniform";
    elseif no >= 319 && no <= 381
        bundle = 164;
        if no == 339
            label = "164_112in";
        else
            label = "164_134in_normal";
        end
    else
        bundle = NaN;
        label = "unknown";
    end
end

function v = getNumCol(T, candidates)
    name = findCol(T, candidates);
    if strlength(name) == 0
        v = NaN(height(T),1);
        return;
    end

    raw = T.(char(name));
    if isnumeric(raw)
        v = double(raw);
    elseif iscell(raw)
        v = str2double(string(raw));
    else
        v = str2double(string(raw));
    end
end

function name = findCol(T, candidates)
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
    if height(T) == 0
        md = "_empty_";
        return;
    end

    vars = string(T.Properties.VariableNames);
    lines = strings(0,1);
    lines(end+1) = "| " + strjoin(vars, " | ") + " |";
    lines(end+1) = "| " + strjoin(repmat("---", 1, numel(vars)), " | ") + " |";

    maxRows = min(height(T), 120);
    for i = 1:maxRows
        row = strings(1, numel(vars));
        for j = 1:numel(vars)
            row(j) = valueToString(T{i,j});
            row(j) = replace(row(j), "|", "/");
            row(j) = replace(row(j), newline, " ");
        end
        lines(end+1) = "| " + strjoin(row, " | ") + " |";
    end

    if height(T) > maxRows
        lines(end+1) = "| " + strjoin(repmat("...", 1, numel(vars)), " | ") + " |";
    end

    md = strjoin(lines, newline);
end

function s = valueToString(val)
    if isnumeric(val)
        if isempty(val)
            s = "";
        elseif isscalar(val)
            if isnan(val)
                s = "";
            else
                s = string(sprintf("%.8g", val));
            end
        else
            s = strjoin(string(val(:)'), ",");
        end
    elseif isstring(val)
        if isempty(val)
            s = "";
        else
            s = strjoin(val(:)', ",");
        end
    elseif iscell(val)
        parts = strings(numel(val),1);
        for k = 1:numel(val)
            parts(k) = valueToString(val{k});
        end
        s = strjoin(parts, ",");
    elseif islogical(val)
        s = strjoin(string(val(:)'), ",");
    else
        try
            s = string(val);
            if numel(s) > 1
                s = strjoin(s(:)', ",");
            end
        catch
            s = "";
        end
    end
end
