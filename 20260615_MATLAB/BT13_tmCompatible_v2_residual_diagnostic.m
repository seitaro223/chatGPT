%% BT13_tmCompatible_v2_residual_diagnostic.m
% BT13：tmCompatible v2入力による108過大化診断
%
% 位置づけ：
%   BT12-Cで、FformLinear_v1をF_form正本として反映した
%   current_bundle_input_v2_FformLinearCanonical_tmCompatible を作成した。
%
%   BT13では、そのv2正本入力だけを読み、108/161/164のF1後残差を再診断する。
%
% 目的：
%   - v1やBT12-A/Bではなく、BT12-C tmCompatible v2を入力として固定する。
%   - F_form列がFformLinear_v1正本値になった状態で、PM_noF1 / PM_F1を再整理する。
%   - 108がF1後に過大側へ残る理由を、Tsub/x_eq側ではなく、
%     F_form、DNB位置、L/DH、z_DNB/DH、z_DNB/L、qM/qPの診断軸で見る。
%   - ただし、補正式は作らない。
%
% 入力：
%   H52Q_current_bundle_input_v2_FformLinearCanonical_tmCompatible_*.xlsx
%
% 出力：
%   BT13_tmCompatible_v2_residual_diagnostic_yyyymmdd_HHMMSS.xlsx
%   run_report_BT13_tmCompatible_v2_residual_diagnostic_yyyymmdd_HHMMSS.md
%
% 前提：
%   - F2/F1F2は使わない。
%   - 比較対象は noF1 と F1 のみ。
%   - F1(Tsub)は維持する。
%   - F1(Tsub)をF(x_eq)へ置換しない。
%   - F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。
%   - BT13では補正式を作らない。
%   - qM/qPは診断量としてのみ扱い、補正式入力には使わない。

clear; clc;

%% ===== Settings =====

inputBundleFile = "";

if strlength(inputBundleFile) == 0
    inputBundleFile = findLatestFile("H52Q_current_bundle_input_v2_FformLinearCanonical_tmCompatible_*.xlsx");
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "BT13_tmCompatible_v2_residual_diagnostic_" + timestamp + ".xlsx";
outMd   = "run_report_BT13_tmCompatible_v2_residual_diagnostic_" + timestamp + ".md";

bundles = ["108","161","164"];

fprintf("Input bundle v2 : %s\n", inputBundleFile);
fprintf("Output Excel    : %s\n", outXlsx);
fprintf("Output report   : %s\n", outMd);

%% ===== Read and combine noF1/F1 sheets =====

Dall = table();

for b = bundles
    shNoF1 = "tm_" + b;
    shF1   = "tm_F1_" + b;

    T0 = readtable(inputBundleFile, 'Sheet', shNoF1, 'VariableNamingRule', 'preserve');
    T1 = readtable(inputBundleFile, 'Sheet', shF1,   'VariableNamingRule', 'preserve');

    D = makeBundlePairTable(T0, T1, str2double(b));
    Dall = [Dall; D]; %#ok<AGROW>
end

%% ===== Add diagnostics =====

Dall.err_noF1 = Dall.PM_noF1 - 1;
Dall.err_F1   = Dall.PM_F1 - 1;
Dall.abs_err_noF1 = abs(Dall.err_noF1);
Dall.abs_err_F1   = abs(Dall.err_F1);

Dall.delta_PM_F1_minus_noF1 = Dall.PM_F1 - Dall.PM_noF1;
Dall.lift_ratio_F1_noF1 = Dall.PM_F1 ./ Dall.PM_noF1;

Dall.case_group = repmat("", height(Dall), 1);
for i = 1:height(Dall)
    if Dall.Bundle(i) == 108
        if isfinite(Dall.No(i)) && (round(Dall.No(i)) == 252 || round(Dall.No(i)) == 253)
            Dall.case_group(i) = "108_76in";
        else
            Dall.case_group(i) = "108_70in";
        end
    elseif Dall.Bundle(i) == 161
        Dall.case_group(i) = "161_uniform";
    elseif Dall.Bundle(i) == 164
        if isfinite(Dall.No(i)) && round(Dall.No(i)) == 339
            Dall.case_group(i) = "164_112in";
        else
            Dall.case_group(i) = "164_134in_normal";
        end
    end
end

%% ===== Summaries =====

bundleSummary = groupSummary(Dall, "Bundle");
caseSummary   = groupSummary(Dall, "case_group");

contrast108 = makeContrast108(Dall);

corrRows = makeCorrDiagnostics(Dall);

modelRows = makeModelDiagnostics(Dall);

residRows = makeResidualizedDiagnostics(Dall);

pairRows = makePairwiseDiagnostics(Dall);

qc = makeQC(Dall, inputBundleFile);

%% ===== Write Excel =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(Dall, outXlsx, 'Sheet', 'BT13_rows');
writetable(bundleSummary, outXlsx, 'Sheet', 'bundle_summary');
writetable(caseSummary, outXlsx, 'Sheet', 'case_summary');
writetable(contrast108, outXlsx, 'Sheet', 'contrast_108_vs_161164');
writetable(corrRows, outXlsx, 'Sheet', 'simple_R2');
writetable(modelRows, outXlsx, 'Sheet', 'exploratory_models');
writetable(residRows, outXlsx, 'Sheet', 'residualized_R2');
writetable(pairRows, outXlsx, 'Sheet', 'pairwise_confounds');
writetable(qc, outXlsx, 'Sheet', 'BT13_QC');

%% ===== Markdown report =====

md = strings(0,1);

md(end+1) = "# BT13 tmCompatible v2 residual diagnostic";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT12-Cで作成したtmCompatible v2入力を用いて、FformLinear_v1正本化後の108/161/164のF1後残差を再診断する。";
md(end+1) = "BT13では補正式を作らず、108過大化がどの変数群と対応しているかを確認する。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- input bundle v2: `" + inputBundleFile + "`";
md(end+1) = "";
md(end+1) = "## 3. 出力";
md(end+1) = "";
md(end+1) = "- output Excel: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 4. 前提";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "- F2/F1F2は使わない。";
md(end+1) = "- 比較対象はnoF1とF1のみ。";
md(end+1) = "- F1(Tsub)は維持する。";
md(end+1) = "- F1(Tsub)をF(x_eq)へ置換しない。";
md(end+1) = "- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。";
md(end+1) = "- qM/qPは診断量であり、補正式入力には使わない。";
md(end+1) = "- BT13では補正式を作らない。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 5. QC";
md(end+1) = "";
md(end+1) = tableToMarkdown(qc);
md(end+1) = "";
md(end+1) = "## 6. Bundle summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(bundleSummary);
md(end+1) = "";
md(end+1) = "## 7. Case summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(caseSummary);
md(end+1) = "";
md(end+1) = "## 8. 108 vs 161/164 contrast";
md(end+1) = "";
md(end+1) = tableToMarkdown(contrast108);
md(end+1) = "";
md(end+1) = "## 9. Simple R2 diagnostics";
md(end+1) = "";
md(end+1) = tableToMarkdown(corrRows);
md(end+1) = "";
md(end+1) = "## 10. Exploratory model diagnostics";
md(end+1) = "";
md(end+1) = tableToMarkdown(modelRows);
md(end+1) = "";
md(end+1) = "## 11. Residualized diagnostics";
md(end+1) = "";
md(end+1) = tableToMarkdown(residRows);
md(end+1) = "";
md(end+1) = "## 12. Pairwise confounds";
md(end+1) = "";
md(end+1) = tableToMarkdown(pairRows);
md(end+1) = "";
md(end+1) = "## 13. 判断メモ";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "このrun_reportを確認してから判断する。";
md(end+1) = "見るべきポイント：";
md(end+1) = "  1. FformLinear_v1正本化後でも108は過大側に残るか。";
md(end+1) = "  2. 164は改善側に動いたか。";
md(end+1) = "  3. F1後残差はTsub/x_eqよりF_form・DNB位置・L/DH側に残るか。";
md(end+1) = "  4. F_form、z_DNB/DH、z_DNB/L、L/DHがどの程度交絡しているか。";
md(end+1) = "  5. L/DHやF_formを補正式化せず、診断項として残す判断でよいか。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 14. 次アクション";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "BT13結果を確認する。";
md(end+1) = "問題なければworking_logへ追記する。";
md(end+1) = "その後、BT14として必要ならDNB位置・F_form・非一様加熱分布の追加診断へ進む。";
md(end+1) = "```";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Excel: %s\n", outXlsx);
fprintf("Wrote Markdown: %s\n", outMd);

disp("=== QC ===");
disp(qc);
disp("=== Bundle summary ===");
disp(bundleSummary);
disp("=== 108 contrast ===");
disp(contrast108);

%% ===== Local functions =====

function latest = findLatestFile(pattern)
    d = dir(pattern);
    if isempty(d)
        error("No file matching pattern: %s", pattern);
    end
    [~, idx] = max([d.datenum]);
    latest = string(d(idx).name);
end

function D = makeBundlePairTable(T0, T1, bundleNo)
    no0 = getNumCol(T0, ["No","NO","no"]);
    no1 = getNumCol(T1, ["No","NO","no"]);

    [commonNo, ia, ib] = intersect(no0, no1, 'stable');
    T0 = T0(ia,:);
    T1 = T1(ib,:);

    if height(T0) ~= height(T1)
        error("NoF1/F1 row count mismatch for bundle %d", bundleNo);
    end

    D = table();
    D.Bundle = repmat(bundleNo, height(T0), 1);
    D.No = commonNo;

    D.q_exp = firstFiniteCols(T1, ["q_exp","q_M","qM","q_M_MW","qM_MW","qMes","q_Mes","M","Measured"]);
    if all(~isfinite(D.q_exp))
        D.q_exp = firstFiniteCols(T0, ["q_exp","q_M","qM","q_M_MW","qM_MW","qMes","q_Mes","M","Measured"]);
    end

    D.q_calc_noF1 = firstFiniteCols(T0, ["q_calc","q_P","qP","q_P_MW","qP_MW","qPred","P","Predicted"]);
    D.q_calc_F1   = firstFiniteCols(T1, ["q_calc","q_P","qP","q_P_MW","qP_MW","qPred","P","Predicted"]);

    D.PM_noF1 = firstFiniteCols(T0, ["PM","P_M","P/M","PM_ratio","PoverM"]);
    D.PM_F1   = firstFiniteCols(T1, ["PM","P_M","P/M","PM_ratio","PoverM"]);

    % If PM columns were not explicit, reconstruct from q_calc/q_exp.
    if all(~isfinite(D.PM_noF1)) && any(isfinite(D.q_calc_noF1)) && any(isfinite(D.q_exp))
        D.PM_noF1 = D.q_calc_noF1 ./ D.q_exp;
    end
    if all(~isfinite(D.PM_F1)) && any(isfinite(D.q_calc_F1)) && any(isfinite(D.q_exp))
        D.PM_F1 = D.q_calc_F1 ./ D.q_exp;
    end

    D.Tsub = firstFiniteCols(T1, ["Tsub","T_sub","Tsub_K","DeltaTsub","dTsub"]);
    if all(~isfinite(D.Tsub))
        D.Tsub = firstFiniteCols(T0, ["Tsub","T_sub","Tsub_K","DeltaTsub","dTsub"]);
    end

    D.Fcorr = firstFiniteCols(T1, ["Fcorr","F_corr","F1","F_1","Tsub_Fcorr"]);
    if all(~isfinite(D.Fcorr))
        D.Fcorr = firstFiniteCols(T0, ["Fcorr","F_corr","F1","F_1","Tsub_Fcorr"]);
    end

    D.F_form = firstFiniteCols(T1, ["F_form","Fform","F_FORM"]);
    if all(~isfinite(D.F_form))
        D.F_form = firstFiniteCols(T0, ["F_form","Fform","F_FORM"]);
    end

    D.x_eq = firstFiniteCols(T1, ["x_eq","xeq","x_Mes","xMes","x"]);
    if all(~isfinite(D.x_eq))
        D.x_eq = firstFiniteCols(T0, ["x_eq","xeq","x_Mes","xMes","x"]);
    end

    D.L_DNB = firstFiniteCols(T1, ["L_DNB","LDNB","z_DNB","zDNB"]);
    if all(~isfinite(D.L_DNB))
        D.L_DNB = firstFiniteCols(T0, ["L_DNB","LDNB","z_DNB","zDNB"]);
    end

    D.L = firstFiniteCols(T1, ["L","Length","HeatedLength"]);
    if all(~isfinite(D.L))
        D.L = firstFiniteCols(T0, ["L","Length","HeatedLength"]);
    end

    D.DH = firstFiniteCols(T1, ["DH","D_h","Dh","HydraulicDiameter"]);
    if all(~isfinite(D.DH))
        D.DH = firstFiniteCols(T0, ["DH","D_h","Dh","HydraulicDiameter"]);
    end

    D.z_DNB_DH = firstFiniteCols(T1, ["z_DNB_DH","LDNB_DH","L_DNB_DH"]);
    if all(~isfinite(D.z_DNB_DH))
        D.z_DNB_DH = firstFiniteCols(T0, ["z_DNB_DH","LDNB_DH","L_DNB_DH"]);
    end
    if all(~isfinite(D.z_DNB_DH)) && any(isfinite(D.L_DNB)) && any(isfinite(D.DH))
        D.z_DNB_DH = D.L_DNB ./ D.DH;
    end

    D.z_DNB_L = firstFiniteCols(T1, ["z_DNB_L","LDNB_L","L_DNB_L"]);
    if all(~isfinite(D.z_DNB_L))
        D.z_DNB_L = firstFiniteCols(T0, ["z_DNB_L","LDNB_L","L_DNB_L"]);
    end
    if all(~isfinite(D.z_DNB_L)) && any(isfinite(D.L_DNB)) && any(isfinite(D.L))
        D.z_DNB_L = D.L_DNB ./ D.L;
    end

    D.L_DH = firstFiniteCols(T1, ["L_DH","LDH","L_over_DH"]);
    if all(~isfinite(D.L_DH))
        D.L_DH = firstFiniteCols(T0, ["L_DH","LDH","L_over_DH"]);
    end
    if all(~isfinite(D.L_DH)) && any(isfinite(D.L)) && any(isfinite(D.DH))
        D.L_DH = D.L ./ D.DH;
    end
end

function S = groupSummary(D, groupVarName)
    g = string(D.(groupVarName));
    groups = unique(g, 'stable');

    S = table();
    for k = 1:numel(groups)
        idx = g == groups(k);

        row = table();
        row.group = groups(k);
        row.N = sum(idx);
        row.No_min = min(D.No(idx), [], 'omitnan');
        row.No_max = max(D.No(idx), [], 'omitnan');

        names = ["q_exp","q_calc_noF1","q_calc_F1","PM_noF1","PM_F1","err_F1","abs_err_F1", ...
                 "delta_PM_F1_minus_noF1","lift_ratio_F1_noF1","Tsub","Fcorr","F_form","x_eq", ...
                 "z_DNB_DH","z_DNB_L","L_DH"];

        for nm = names
            if any(string(D.Properties.VariableNames) == nm)
                v = D.(nm);
                row.(nm + "_mean") = mean(v(idx), 'omitnan');
                row.(nm + "_sd") = std(v(idx), 'omitnan');
            end
        end

        S = [S; row]; %#ok<AGROW>
    end
end

function C = makeContrast108(D)
    idx108 = D.Bundle == 108;
    idxOther = D.Bundle == 161 | D.Bundle == 164;

    vars = ["PM_noF1","PM_F1","err_F1","abs_err_F1","delta_PM_F1_minus_noF1", ...
            "lift_ratio_F1_noF1","q_exp","q_calc_F1","Tsub","Fcorr","F_form", ...
            "x_eq","z_DNB_DH","z_DNB_L","L_DH"];

    C = table();
    for vname = vars
        if ~any(string(D.Properties.VariableNames) == vname)
            continue;
        end
        v = D.(vname);
        row = table();
        row.variable = vname;
        row.mean_108 = mean(v(idx108), 'omitnan');
        row.mean_161164 = mean(v(idxOther), 'omitnan');
        row.delta_108_minus_161164 = row.mean_108 - row.mean_161164;
        C = [C; row]; %#ok<AGROW>
    end
end

function R = makeCorrDiagnostics(D)
    targets = ["PM_noF1","PM_F1","err_F1","abs_err_F1","delta_PM_F1_minus_noF1","lift_ratio_F1_noF1"];
    predictors = ["Tsub","Fcorr","F_form","x_eq","z_DNB_DH","z_DNB_L","L_DH","q_exp","q_calc_F1"];

    R = table();
    for y = targets
        if ~any(string(D.Properties.VariableNames) == y), continue; end
        for x = predictors
            if ~any(string(D.Properties.VariableNames) == x), continue; end
            [r2, n, slope, intercept] = simpleR2(D.(x), D.(y));
            row = table();
            row.target = y;
            row.predictor = x;
            row.N = n;
            row.R2 = r2;
            row.slope = slope;
            row.intercept = intercept;
            R = [R; row]; %#ok<AGROW>
        end
    end
end

function R = makeModelDiagnostics(D)
    specs = {
        "PM_F1", ["Tsub"]
        "PM_F1", ["x_eq"]
        "PM_F1", ["F_form"]
        "PM_F1", ["z_DNB_DH"]
        "PM_F1", ["z_DNB_L"]
        "PM_F1", ["L_DH"]
        "PM_F1", ["Tsub","x_eq"]
        "PM_F1", ["Tsub","x_eq","F_form"]
        "PM_F1", ["Tsub","x_eq","z_DNB_DH"]
        "PM_F1", ["Tsub","x_eq","F_form","z_DNB_DH"]
        "PM_F1", ["Tsub","x_eq","F_form","z_DNB_L"]
        "PM_F1", ["Tsub","x_eq","F_form","L_DH"]
        "err_F1", ["Tsub","x_eq","F_form","z_DNB_DH"]
        "err_F1", ["Tsub","x_eq","F_form","z_DNB_L"]
        "err_F1", ["Tsub","x_eq","F_form","L_DH"]
    };

    R = table();
    for i = 1:size(specs,1)
        yname = string(specs{i,1});
        xnames = string(specs{i,2});

        [r2, n, ok] = multiR2(D, yname, xnames);
        row = table();
        row.target = yname;
        row.predictors = strjoin(xnames, " + ");
        row.N = n;
        row.R2 = r2;
        row.status = ok;
        row.note = "exploratory_only_not_formula";
        R = [R; row]; %#ok<AGROW>
    end
end

function R = makeResidualizedDiagnostics(D)
    controls = {
        "Tsub", ["Tsub"]
        "Tsub_xeq", ["Tsub","x_eq"]
        "LDH", ["L_DH"]
        "Fform", ["F_form"]
        "zDNB_DH", ["z_DNB_DH"]
    };

    yname = "err_F1";
    candidates = ["Tsub","x_eq","F_form","z_DNB_DH","z_DNB_L","L_DH"];

    R = table();

    for i = 1:size(controls,1)
        controlLabel = string(controls{i,1});
        controlVars = string(controls{i,2});

        yres = residualize(D, yname, controlVars);

        for x = candidates
            if any(x == controlVars)
                continue;
            end
            if ~any(string(D.Properties.VariableNames) == x)
                continue;
            end
            [r2, n, slope, intercept] = simpleR2(D.(x), yres);
            row = table();
            row.target = yname;
            row.control = controlLabel;
            row.candidate = x;
            row.N = n;
            row.R2 = r2;
            row.slope = slope;
            row.intercept = intercept;
            R = [R; row]; %#ok<AGROW>
        end
    end
end

function R = makePairwiseDiagnostics(D)
    vars = ["Tsub","x_eq","F_form","z_DNB_DH","z_DNB_L","L_DH","q_exp","q_calc_F1"];

    R = table();
    for i = 1:numel(vars)
        for j = i+1:numel(vars)
            x = vars(i);
            y = vars(j);
            if ~any(string(D.Properties.VariableNames) == x) || ~any(string(D.Properties.VariableNames) == y)
                continue;
            end
            [r2, n, slope, intercept] = simpleR2(D.(x), D.(y));
            row = table();
            row.x = x;
            row.y = y;
            row.N = n;
            row.R2 = r2;
            row.slope = slope;
            row.intercept = intercept;
            R = [R; row]; %#ok<AGROW>
        end
    end
end

function Q = makeQC(D, inputFile)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("input_file", "info", inputFile, "BT12-C tmCompatible v2入力。");
    add("row_count", statusOK(height(D) == 58), sprintf("%d", height(D)), "108=14, 161=23, 164=21 合計58行が期待値。");
    add("bundle_count", statusOK(numel(unique(D.Bundle)) == 3), sprintf("%d", numel(unique(D.Bundle))), "108/161/164の3群。");
    add("PM_F1_missing", statusOK(sum(~isfinite(D.PM_F1)) == 0), sprintf("%d", sum(~isfinite(D.PM_F1))), "PM_F1欠損。");
    add("PM_noF1_missing", statusOK(sum(~isfinite(D.PM_noF1)) == 0), sprintf("%d", sum(~isfinite(D.PM_noF1))), "PM_noF1欠損。");
    add("F_form_missing", statusOK(sum(~isfinite(D.F_form)) == 0), sprintf("%d", sum(~isfinite(D.F_form))), "F_form欠損。");
    add("Tsub_missing", statusOK(sum(~isfinite(D.Tsub)) == 0), sprintf("%d", sum(~isfinite(D.Tsub))), "Tsub欠損。");
    add("x_eq_missing", statusOK(sum(~isfinite(D.x_eq)) == 0), sprintf("%d", sum(~isfinite(D.x_eq))), "x_eq欠損。");
    add("z_DNB_DH_missing", statusOK(sum(~isfinite(D.z_DNB_DH)) == 0), sprintf("%d", sum(~isfinite(D.z_DNB_DH))), "z_DNB/DH欠損。");
    add("L_DH_missing", statusOK(sum(~isfinite(D.L_DH)) == 0), sprintf("%d", sum(~isfinite(D.L_DH))), "L/DH欠損。");
    add("formula_policy", "OK", "no_new_formula", "BT13では補正式を作らない。");
    add("F1_policy", "OK", "keep_F1_Tsub", "F1(Tsub)を維持する。");
    add("Fform_policy", "OK", "linear_v1_canonical_input", "F_formはBT12-Cでlinear_v1正本化済み。");

    Q = table(item, status, value, reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function s = statusOK(tf)
    if tf
        s = "OK";
    else
        s = "CHECK";
    end
end

function yres = residualize(D, yname, xnames)
    y = D.(yname);
    X = [];
    ok = isfinite(y);

    for x = string(xnames)
        v = D.(x);
        X = [X, v]; %#ok<AGROW>
        ok = ok & isfinite(v);
    end

    yres = NaN(size(y));

    if sum(ok) < (size(X,2)+2)
        return;
    end

    Xok = [ones(sum(ok),1), X(ok,:)];
    beta = Xok \ y(ok);
    yhat = [ones(sum(ok),1), X(ok,:)] * beta;
    yres(ok) = y(ok) - yhat;
end

function [r2, n, slope, intercept] = simpleR2(x, y)
    x = double(x);
    y = double(y);
    ok = isfinite(x) & isfinite(y);
    n = sum(ok);

    if n < 3 || numel(unique(x(ok))) < 2
        r2 = NaN;
        slope = NaN;
        intercept = NaN;
        return;
    end

    X = [ones(n,1), x(ok)];
    beta = X \ y(ok);
    yhat = X * beta;

    ssRes = sum((y(ok) - yhat).^2);
    ssTot = sum((y(ok) - mean(y(ok))).^2);

    if ssTot == 0
        r2 = NaN;
    else
        r2 = 1 - ssRes/ssTot;
    end

    intercept = beta(1);
    slope = beta(2);
end

function [r2, n, status] = multiR2(D, yname, xnames)
    if ~any(string(D.Properties.VariableNames) == yname)
        r2 = NaN; n = 0; status = "missing_y";
        return;
    end

    y = D.(yname);
    ok = isfinite(y);
    X = [];

    for x = string(xnames)
        if ~any(string(D.Properties.VariableNames) == x)
            r2 = NaN; n = 0; status = "missing_x_" + x;
            return;
        end
        v = D.(x);
        X = [X, v]; %#ok<AGROW>
        ok = ok & isfinite(v);
    end

    n = sum(ok);
    p = size(X,2);

    if n < p + 2
        r2 = NaN;
        status = "too_few_rows";
        return;
    end

    if rank(X(ok,:)) < p
        % Rank deficient models can still be diagnostic, but mark it.
        status = "rank_deficient";
    else
        status = "OK";
    end

    Xok = [ones(n,1), X(ok,:)];
    beta = Xok \ y(ok);
    yhat = Xok * beta;

    ssRes = sum((y(ok) - yhat).^2);
    ssTot = sum((y(ok) - mean(y(ok))).^2);

    if ssTot == 0
        r2 = NaN;
    else
        r2 = 1 - ssRes/ssTot;
    end
end

function v = firstFiniteCols(T, candidates)
    v = NaN(height(T),1);

    for c = string(candidates)
        col = getNumCol(T, c);
        if any(isfinite(col))
            v = col;
            return;
        end
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
