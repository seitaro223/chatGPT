%% BT10B_FformLinear_residual_diagnostic.m
% BT10-B：FformLinear_v1再計算後の残差構造を再診断する
%
% 目的：
%   BT09-Bで再計算したFformLinear_v1版の noF1 / F1 マクロブックを読み、
%   F1後の残差構造を再診断する。
%
%   特に見るもの：
%     - PM_noF1_linear
%     - PM_F1_linear
%     - err_F1_linear = PM_F1_linear - 1
%     - delta_PM_linear = PM_F1_linear - PM_noF1_linear
%     - lift_ratio_linear = PM_F1_linear / PM_noF1_linear
%
%   説明候補：
%     - Tsub
%     - Fcorr
%     - x_eq（マクロブック上は x_Mes 列を熱平衡クオリティとして扱う）
%     - Fform_linear（tmシートのF_form列。BT09-Aでlinear_v1に差し替え済み）
%     - z_DNB/DH
%     - z_DNB/L
%     - L/DH
%     - Bundle / case_label
%
% 注意：
%   - 補正式は作らない。
%   - R2が高いモデルをそのまま採用しない。
%   - F_formはF1ではない。
%   - F_formは非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。
%   - qMは結果側量なので補正式入力には使わない。診断量に留める。
%
% 入力：
%   *F1なし_FformLinear_v1_*.xlsm
%   *F1あり_FformLinear_v1_*.xlsm
%
% 出力：
%   BT10B_FformLinear_residual_diagnostic_yyyymmdd_HHMMSS.xlsx
%   run_report_BT10B_FformLinear_residual_diagnostic_yyyymmdd_HHMMSS.md

clear; clc;

%% ===== Settings =====

inputNoF1File = "";
inputF1File = "";

if strlength(inputNoF1File) == 0
    inputNoF1File = findLatestFile("*F1なし_FformLinear_v1_*.xlsm");
end

if strlength(inputF1File) == 0
    inputF1File = findLatestFile("*F1あり_FformLinear_v1_*.xlsm");
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "BT10B_FformLinear_residual_diagnostic_" + timestamp + ".xlsx";
outMd   = "run_report_BT10B_FformLinear_residual_diagnostic_" + timestamp + ".md";

fprintf("Input noF1 FformLinear: %s\n", inputNoF1File);
fprintf("Input F1   FformLinear: %s\n", inputF1File);

%% ===== Read and normalize macro sheets =====

Tno_raw = readtable(inputNoF1File, 'Sheet', 'tm', 'VariableNamingRule', 'preserve');
Tf1_raw = readtable(inputF1File,   'Sheet', 'tm', 'VariableNamingRule', 'preserve');

Tno = normalizeTmTable(Tno_raw, "noF1", inputNoF1File);
Tf1 = normalizeTmTable(Tf1_raw, "F1", inputF1File);

joined = joinNoF1F1(Tno, Tf1);

%% ===== Derived quantities =====

joined.err_noF1_linear = joined.PM_noF1_linear - 1;
joined.err_F1_linear = joined.PM_F1_linear - 1;
joined.delta_PM_linear = joined.PM_F1_linear - joined.PM_noF1_linear;
joined.lift_ratio_linear = joined.PM_F1_linear ./ joined.PM_noF1_linear;
joined.delta_qP_MWm2_linear = joined.qP_F1_MWm2 - joined.qP_noF1_MWm2;

%% ===== Summary =====

bundleSummary = summarizeByKey(joined, "Bundle");
caseSummary = summarizeByKey(joined, "case_label");

predictors = [
    "Tsub"
    "Fcorr"
    "x_eq"
    "Fform_linear"
    "z_DNB_DH"
    "z_DNB_L"
    "L_DH"
    "qM_MWm2"
    "qP_F1_MWm2"
];

targets = [
    "PM_noF1_linear"
    "PM_F1_linear"
    "err_F1_linear"
    "delta_PM_linear"
    "lift_ratio_linear"
];

singleR2 = makeSinglePredictorR2(joined, targets, predictors);

modelSpec = makeModelSpec();
modelR2 = runModelSpecs(joined, modelSpec);

residualizedR2 = makeResidualizedR2(joined);

pairR2 = makePairR2(joined, [
    "Fform_linear"
    "z_DNB_DH"
    "z_DNB_L"
    "L_DH"
    "x_eq"
    "Tsub"
    "Fcorr"
]);

contrast = makeContrasts(bundleSummary, caseSummary);
decision = makeDecision(joined, bundleSummary, caseSummary, singleR2, modelR2, residualizedR2);
nextSteps = makeNextSteps();

%% ===== Write outputs =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(joined, outXlsx, 'Sheet', 'BT10B_joined');
writetable(bundleSummary, outXlsx, 'Sheet', 'BT10B_bundle_summary');
writetable(caseSummary, outXlsx, 'Sheet', 'BT10B_case_summary');
writetable(singleR2, outXlsx, 'Sheet', 'BT10B_single_predictor_R2');
writetable(modelR2, outXlsx, 'Sheet', 'BT10B_model_R2');
writetable(residualizedR2, outXlsx, 'Sheet', 'BT10B_residualized_R2');
writetable(pairR2, outXlsx, 'Sheet', 'BT10B_predictor_pair_R2');
writetable(contrast, outXlsx, 'Sheet', 'BT10B_contrasts');
writetable(decision, outXlsx, 'Sheet', 'BT10B_decision_flags');
writetable(nextSteps, outXlsx, 'Sheet', 'BT10B_next_steps');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Write Markdown report =====

md = strings(0,1);

md(end+1) = "# BT10-B FformLinear_v1 residual diagnostic";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT09-Bで再計算したFformLinear_v1版のnoF1/F1マクロブックを読み、F1後の残差構造を再診断する。補正式は作らず、Tsub、x_eq、Fform_linear、DNB位置、L/DH、ケース構造との対応を見る。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- noF1 FformLinear: `" + inputNoF1File + "`";
md(end+1) = "- F1 FformLinear: `" + inputF1File + "`";
md(end+1) = "";
md(end+1) = "## 3. 前提";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "- F1(Tsub)は維持する。";
md(end+1) = "- F1(Tsub)をF(x_eq)へ置換しない。";
md(end+1) = "- F_formはF1ではない。";
md(end+1) = "- F_formは非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。";
md(end+1) = "- qMは結果側量なので補正式入力には使わない。";
md(end+1) = "- R2が高いモデルを補正式として採用しない。";
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
md(end+1) = "## 6. Bundle/case contrasts";
md(end+1) = "";
md(end+1) = tableToMarkdown(contrast);
md(end+1) = "";
md(end+1) = "## 7. Single predictor R2";
md(end+1) = "";
md(end+1) = tableToMarkdown(singleR2);
md(end+1) = "";
md(end+1) = "## 8. Model R2";
md(end+1) = "";
md(end+1) = tableToMarkdown(modelR2);
md(end+1) = "";
md(end+1) = "## 9. Residualized R2";
md(end+1) = "";
md(end+1) = tableToMarkdown(residualizedR2);
md(end+1) = "";
md(end+1) = "## 10. Predictor pair R2";
md(end+1) = "";
md(end+1) = tableToMarkdown(pairR2);
md(end+1) = "";
md(end+1) = "## 11. Decision flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(decision);
md(end+1) = "";
md(end+1) = "## 12. Next steps";
md(end+1) = "";
md(end+1) = tableToMarkdown(nextSteps);
md(end+1) = "";
md(end+1) = "## 13. 判断メモ";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "- FformLinear_v1後に、164は改善し、108は過大側へ動いた。";
md(end+1) = "- BT10-Bでは、その後の残差がTsub/x_eq側に残るのか、Fform/DNB位置/L_DH側に残るのかを見る。";
md(end+1) = "- ここで得られたR2は診断であり、補正式ではない。";
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

disp("=== Single predictor R2 top rows ===");
disp(firstN(sortrows(singleR2, "R2", "descend"), 20));

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

function T = normalizeTmTable(raw, kind, sourceFile)
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

    % Unit cleanup:
    % In many macro sheets q_P is MW/m2, but q_M may be W/m2.
    % If q-like values are clearly W/m2 scale, convert to MW/m2.
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

function joined = joinNoF1F1(Tno, Tf1)
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
        row.Fform_noF1_check = Tno.F_form(idx);
        row.Fcorr = Tf1.Fcorr(i);
        row.Tsub = Tf1.Tsub(i);
        row.x_eq = Tf1.x_eq(i);
        row.L_DNB = Tf1.L_DNB(i);
        row.L = Tf1.L(i);
        row.DH = Tf1.DH(i);
        row.z_DNB_DH = Tf1.z_DNB_DH(i);
        row.z_DNB_L = Tf1.z_DNB_L(i);
        row.L_DH = Tf1.L_DH(i);

        joined = [joined; row]; %#ok<AGROW>
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

function S = summarizeByKey(T, keyVar)
    keyVar = string(keyVar);
    S = table();

    keys = unique(T.(keyVar));
    for k = keys(:)'
        if ismissing(k) || (isnumeric(k) && isnan(k))
            continue;
        end

        R = T(T.(keyVar) == k, :);

        row = table();
        row.(keyVar) = k;
        row.N = height(R);
        row.No_min = min(R.No, [], 'omitnan');
        row.No_max = max(R.No, [], 'omitnan');
        row.PM_noF1_linear_mean = mean(R.PM_noF1_linear, 'omitnan');
        row.PM_F1_linear_mean = mean(R.PM_F1_linear, 'omitnan');
        row.err_F1_linear_mean = mean(R.err_F1_linear, 'omitnan');
        row.delta_PM_linear_mean = mean(R.delta_PM_linear, 'omitnan');
        row.lift_ratio_linear_mean = mean(R.lift_ratio_linear, 'omitnan');
        row.qP_F1_MWm2_mean = mean(R.qP_F1_MWm2, 'omitnan');
        row.qM_MWm2_mean = mean(R.qM_MWm2, 'omitnan');
        row.Fform_linear_mean = mean(R.Fform_linear, 'omitnan');
        row.Tsub_mean = mean(R.Tsub, 'omitnan');
        row.Fcorr_mean = mean(R.Fcorr, 'omitnan');
        row.x_eq_mean = mean(R.x_eq, 'omitnan');
        row.z_DNB_DH_mean = mean(R.z_DNB_DH, 'omitnan');
        row.z_DNB_L_mean = mean(R.z_DNB_L, 'omitnan');
        row.L_DH_mean = mean(R.L_DH, 'omitnan');

        S = [S; row]; %#ok<AGROW>
    end
end

function R2tab = makeSinglePredictorR2(T, targets, predictors)
    R2tab = table();
    for target = string(targets(:))'
        for pred = string(predictors(:))'
            row = table();
            row.target = target;
            row.predictor = pred;
            [r2, n, slope] = simpleR2(T.(target), T.(pred));
            row.N = n;
            row.R2 = r2;
            row.slope = slope;
            row.note = predictorNote(pred);
            R2tab = [R2tab; row]; %#ok<AGROW>
        end
    end
end

function spec = makeModelSpec()
    target = strings(0,1);
    model_name = strings(0,1);
    predictors = strings(0,1);
    note = strings(0,1);

    add("PM_noF1_linear", "PM_noF1 ~ Tsub", "Tsub", "F1前の元誤差とTsub");
    add("PM_noF1_linear", "PM_noF1 ~ x_eq", "x_eq", "F1前の元誤差とx_eq");
    add("PM_noF1_linear", "PM_noF1 ~ Tsub + x_eq", "Tsub,x_eq", "x_eqの追加説明力を見る");

    add("PM_F1_linear", "PM_F1 ~ Tsub", "Tsub", "F1後残差とTsub");
    add("PM_F1_linear", "PM_F1 ~ x_eq", "x_eq", "F1後残差とx_eq");
    add("PM_F1_linear", "PM_F1 ~ Fform", "Fform_linear", "F1後残差と非一様加熱換算");
    add("PM_F1_linear", "PM_F1 ~ zDNB_DH", "z_DNB_DH", "F1後残差とDNBまでの履歴長");
    add("PM_F1_linear", "PM_F1 ~ L_DH", "L_DH", "F1後残差とL/DH");
    add("PM_F1_linear", "PM_F1 ~ Fform + zDNB_DH", "Fform_linear,z_DNB_DH", "Fformと履歴長");
    add("PM_F1_linear", "PM_F1 ~ Tsub + x_eq + Fform + zDNB_DH", "Tsub,x_eq,Fform_linear,z_DNB_DH", "探索診断。補正式ではない");
    add("PM_F1_linear", "PM_F1 ~ Tsub + x_eq + Fform + L_DH", "Tsub,x_eq,Fform_linear,L_DH", "探索診断。補正式ではない");

    add("err_F1_linear", "err_F1 ~ Fform", "Fform_linear", "F1後誤差とFform");
    add("err_F1_linear", "err_F1 ~ zDNB_DH", "z_DNB_DH", "F1後誤差と履歴長");
    add("err_F1_linear", "err_F1 ~ L_DH", "L_DH", "F1後誤差とL/DH");
    add("err_F1_linear", "err_F1 ~ Fform + zDNB_DH", "Fform_linear,z_DNB_DH", "複合診断");
    add("err_F1_linear", "err_F1 ~ Fform + zDNB_L + L_DH", "Fform_linear,z_DNB_L,L_DH", "FformとDNB位置構造");

    add("delta_PM_linear", "delta_PM ~ Tsub", "Tsub", "F1持ち上げ量とTsub");
    add("delta_PM_linear", "delta_PM ~ Fcorr", "Fcorr", "F1持ち上げ量とFcorr");
    add("delta_PM_linear", "delta_PM ~ x_eq", "x_eq", "F1持ち上げ量とx_eq");
    add("delta_PM_linear", "delta_PM ~ Tsub + x_eq", "Tsub,x_eq", "x_eq追加説明力");

    add("lift_ratio_linear", "lift_ratio ~ Tsub", "Tsub", "F1倍率とTsub");
    add("lift_ratio_linear", "lift_ratio ~ x_eq", "x_eq", "F1倍率とx_eq");
    add("lift_ratio_linear", "lift_ratio ~ Tsub + x_eq", "Tsub,x_eq", "x_eq追加説明力");

    spec = table(target, model_name, predictors, note);

    function add(a,b,c,d)
        target(end+1,1) = string(a);
        model_name(end+1,1) = string(b);
        predictors(end+1,1) = string(c);
        note(end+1,1) = string(d);
    end
end

function M = runModelSpecs(T, spec)
    M = table();

    for i = 1:height(spec)
        yName = spec.target(i);
        xNames = split(spec.predictors(i), ",");

        y = T.(yName);
        X = [];
        actualPreds = strings(0,1);

        for x = xNames(:)'
            x = strtrim(string(x));
            if strlength(x) == 0
                continue;
            end
            X = [X, T.(x)]; %#ok<AGROW>
            actualPreds(end+1,1) = x; %#ok<AGROW>
        end

        [r2, n, rmse] = multiR2(y, X);

        row = table();
        row.target = yName;
        row.model_name = spec.model_name(i);
        row.predictors = strjoin(actualPreds, "+");
        row.N = n;
        row.R2 = r2;
        row.RMSE = rmse;
        row.note = spec.note(i);
        M = [M; row]; %#ok<AGROW>
    end
end

function R = makeResidualizedR2(T)
    R = table();

    targets = ["err_F1_linear","PM_F1_linear","delta_PM_linear","lift_ratio_linear"];
    baseModels = [
        "Tsub"
        "Tsub,x_eq"
        "L_DH"
        "Fform_linear"
        "Fform_linear,z_DNB_DH"
    ];
    checkVars = ["Fform_linear","z_DNB_DH","z_DNB_L","L_DH","x_eq","Tsub","Fcorr"];

    for yName = targets(:)'
        for base = baseModels(:)'
            baseVars = split(base, ",");
            y = T.(yName);
            Xbase = [];
            for b = baseVars(:)'
                b = strtrim(string(b));
                Xbase = [Xbase, T.(b)]; %#ok<AGROW>
            end
            yRes = residualize(y, Xbase);

            for cv = checkVars(:)'
                if any(strtrim(baseVars) == cv)
                    continue;
                end
                [r2, n, slope] = simpleR2(yRes, T.(cv));
                row = table();
                row.target = yName;
                row.base_model = base;
                row.residual_checked_against = cv;
                row.N = n;
                row.R2 = r2;
                row.slope = slope;
                row.note = "base_modelで説明した後に、まだ残る対応を見る";
                R = [R; row]; %#ok<AGROW>
            end
        end
    end
end

function P = makePairR2(T, vars)
    P = table();
    vars = string(vars(:));
    for i = 1:numel(vars)
        for j = i+1:numel(vars)
            [r2, n, slope] = simpleR2(T.(vars(i)), T.(vars(j)));
            row = table();
            row.var_y = vars(i);
            row.var_x = vars(j);
            row.N = n;
            row.R2 = r2;
            row.slope = slope;
            row.note = "説明候補同士の交絡確認";
            P = [P; row]; %#ok<AGROW>
        end
    end
end

function C = makeContrasts(bundleSummary, caseSummary)
    C = table();

    addBundleContrast(108, [161,164], "108_minus_mean_161_164");
    addBundleContrast(164, [108,161], "164_minus_mean_108_161");
    addBundleContrast(161, [108,164], "161_minus_mean_108_164");

    function addBundleContrast(a, bs, name)
        RA = bundleSummary(bundleSummary.Bundle == a, :);
        RB = bundleSummary(ismember(bundleSummary.Bundle, bs), :);

        if isempty(RA) || isempty(RB)
            return;
        end

        row = table();
        row.contrast = string(name);
        row.A_bundle = a;
        row.B_bundles = strjoin(string(bs), ",");
        row.diff_PM_F1_linear = RA.PM_F1_linear_mean - mean(RB.PM_F1_linear_mean, 'omitnan');
        row.diff_err_F1_linear = RA.err_F1_linear_mean - mean(RB.err_F1_linear_mean, 'omitnan');
        row.diff_delta_PM_linear = RA.delta_PM_linear_mean - mean(RB.delta_PM_linear_mean, 'omitnan');
        row.diff_lift_ratio_linear = RA.lift_ratio_linear_mean - mean(RB.lift_ratio_linear_mean, 'omitnan');
        row.diff_Fform_linear = RA.Fform_linear_mean - mean(RB.Fform_linear_mean, 'omitnan');
        row.diff_Tsub = RA.Tsub_mean - mean(RB.Tsub_mean, 'omitnan');
        row.diff_x_eq = RA.x_eq_mean - mean(RB.x_eq_mean, 'omitnan');
        row.diff_z_DNB_DH = RA.z_DNB_DH_mean - mean(RB.z_DNB_DH_mean, 'omitnan');
        row.diff_z_DNB_L = RA.z_DNB_L_mean - mean(RB.z_DNB_L_mean, 'omitnan');
        row.diff_L_DH = RA.L_DH_mean - mean(RB.L_DH_mean, 'omitnan');
        C = [C; row]; %#ok<AGROW>
    end
end

function D = makeDecision(joined, bundleSummary, caseSummary, singleR2, modelR2, residualizedR2)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("input_rows", "OK", sprintf("%d", height(joined)), "noF1/F1をNoで結合した行数。期待値は58。");

    if height(joined) == 58
        add("join_status", "OK", "58 rows", "108/161/164の対象58行が結合された。");
    else
        add("join_status", "CHECK", sprintf("%d rows", height(joined)), "行数が58ではない。No対応を確認。");
    end

    meanFform108 = getBundleValue(bundleSummary, 108, "Fform_linear_mean");
    meanFform164 = getBundleValue(bundleSummary, 164, "Fform_linear_mean");
    pm108 = getBundleValue(bundleSummary, 108, "PM_F1_linear_mean");
    pm161 = getBundleValue(bundleSummary, 161, "PM_F1_linear_mean");
    pm164 = getBundleValue(bundleSummary, 164, "PM_F1_linear_mean");

    add("PM_F1_linear_bundle", "diagnostic", sprintf("108=%.6g, 161=%.6g, 164=%.6g", pm108, pm161, pm164), "FformLinear後のF1 P/M。");
    add("Fform_linear_bundle", "diagnostic", sprintf("108=%.6g, 164=%.6g", meanFform108, meanFform164), "FformLinear後のFform代表値。");

    add("F1_policy", "keep", "F1(Tsub)", "BT05/BT06の判断どおり、F1(Tsub)を維持する前提で読む。");
    add("Fform_policy", "diagnostic", "linear_v1", "FformLinearは定義としては正本候補。ただし残差補正式とは別。");
    add("correlation_policy", "caution", "R2 is diagnostic only", "R2が高くても補正式として採用しない。");

    add("next", "next", "BT10-C or BT11", "BT10-B結果を見て、FformLinear_v1を正本候補にするか、legacy併記感度にするか判断する。");

    D = table(item, status, value, reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function val = getBundleValue(S, bundle, varName)
    R = S(S.Bundle == bundle,:);
    if isempty(R)
        val = NaN;
    else
        val = R.(varName)(1);
    end
end

function N = makeNextSteps()
    step = (1:7)';
    action = strings(7,1);
    detail = strings(7,1);

    action(1) = "Review BT10-B";
    detail(1) = "Check bundle_summary, case_summary, and decision_flags.";

    action(2) = "Check whether 108 overprediction remains";
    detail(2) = "FformLinear is expected to improve 164 but worsen 108. Confirm magnitude.";

    action(3) = "Check residual side";
    detail(3) = "Determine whether residuals are tied to Fform/DNB/L_DH rather than Tsub/x_eq.";

    action(4) = "Avoid immediate formula";
    detail(4) = "Do not create L/DH, z_DNB/DH, or Fform correction from this alone.";

    action(5) = "Decide FformLinear status";
    detail(5) = "Choose between adopting FformLinear_v1 as current canonical input or treating it as sensitivity alongside legacy.";

    action(6) = "Update working log";
    detail(6) = "Append BT10-B results to working log after interpretation.";

    action(7) = "Next analysis";
    detail(7) = "Proceed to BT10-C or BT11 for final judgment of FformLinear impact.";

    N = table(step, action, detail);
end

function note = predictorNote(pred)
    pred = string(pred);
    switch pred
        case "qM_MWm2"
            note = "diagnostic_only_result_side";
        case "qP_F1_MWm2"
            note = "diagnostic_only_prediction_side";
        case "Fform_linear"
            note = "nonuniform_heating_conversion_not_F1";
        case {"z_DNB_DH","z_DNB_L","L_DH"}
            note = "history_or_geometry_proxy_diagnostic";
        otherwise
            note = "diagnostic";
    end
end

function [r2, n, slope] = simpleR2(y, x)
    y = double(y(:));
    x = double(x(:));
    ok = isfinite(y) & isfinite(x);
    y = y(ok);
    x = x(ok);
    n = numel(y);

    if n < 3 || std(x) == 0 || std(y) == 0
        r2 = NaN;
        slope = NaN;
        return;
    end

    X = [ones(n,1), x];
    b = X \ y;
    yhat = X*b;
    r2 = 1 - sum((y-yhat).^2) / sum((y-mean(y)).^2);
    slope = b(2);
end

function [r2, n, rmse] = multiR2(y, X)
    y = double(y(:));
    X = double(X);

    ok = isfinite(y);
    for j = 1:size(X,2)
        ok = ok & isfinite(X(:,j));
    end
    y = y(ok);
    X = X(ok,:);
    n = numel(y);

    if n < size(X,2)+2 || std(y) == 0
        r2 = NaN;
        rmse = NaN;
        return;
    end

    % Remove constant predictors
    keep = true(1,size(X,2));
    for j = 1:size(X,2)
        if std(X(:,j)) == 0
            keep(j) = false;
        end
    end
    X = X(:,keep);

    if isempty(X)
        r2 = NaN;
        rmse = NaN;
        return;
    end

    Xd = [ones(n,1), X];
    b = Xd \ y;
    yhat = Xd*b;
    resid = y-yhat;
    r2 = 1 - sum(resid.^2) / sum((y-mean(y)).^2);
    rmse = sqrt(mean(resid.^2));
end

function res = residualize(y, X)
    y = double(y(:));
    X = double(X);

    ok = isfinite(y);
    for j = 1:size(X,2)
        ok = ok & isfinite(X(:,j));
    end

    res = NaN(size(y));
    yy = y(ok);
    XX = X(ok,:);

    if numel(yy) < size(XX,2)+2
        return;
    end

    keep = true(1,size(XX,2));
    for j = 1:size(XX,2)
        if std(XX(:,j)) == 0
            keep(j) = false;
        end
    end
    XX = XX(:,keep);

    if isempty(XX)
        res(ok) = yy - mean(yy);
        return;
    end

    Xd = [ones(numel(yy),1), XX];
    b = Xd \ yy;
    res(ok) = yy - Xd*b;
end

function Tsmall = firstN(T, n)
    if height(T) <= n
        Tsmall = T;
    else
        Tsmall = T(1:n,:);
    end
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
