%% BT18_slide_figure_package.m
% BT18:
%   確認用スライドに必要な図パッケージを作る
%
% 主目的:
%   - バンドル noF1 / F1 の見え方の違いを図で固定する
%   - F1後残差が L/DH, z_DNB/DH, F_form と「対応して残る」ことを図示する
%   - F_form は原因ではなく診断軸であることを図示する
%   - 単管側はこの段階では要点図に留める
%
% 入力:
%   - BT16_Fform_canonical_explanation_package_20260618_090954.xlsx
%   - （任意）BT17_explanation_figures_decision_tables_20260618_091951.xlsx
%
% 出力:
%   - BT18_slide_figure_package_YYYYMMDD_HHMMSS.xlsx
%   - run_report_BT18_slide_figure_package_YYYYMMDD_HHMMSS.md
%   - fig_BT18_*.png
%
% 実行後:
%   1. run_report_BT18_*.md をアップロード
%   2. 余裕があれば fig_BT18_*.png もアップロード

clear; clc;

%% ===== ユーザー設定 =====

inputBT16 = "BT16_Fform_canonical_explanation_package_20260618_090954.xlsx";
inputBT17 = "BT17_explanation_figures_decision_tables_20260618_091951.xlsx";  % 任意

taskId = "BT18";
taskName = "slide_figure_package";
ts = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));

outXlsx = taskId + "_" + taskName + "_" + ts + ".xlsx";
outMd   = "run_report_" + taskId + "_" + taskName + "_" + ts + ".md";

fig1 = "fig_" + taskId + "_01_bundle_PM_noF1_vs_F1_" + ts + ".png";
fig2 = "fig_" + taskId + "_02_PM_noF1_vs_LDH_" + ts + ".png";
fig3 = "fig_" + taskId + "_03_PM_F1_vs_LDH_" + ts + ".png";
fig4 = "fig_" + taskId + "_04_R2_compare_PMnoF1_PM_F1_" + ts + ".png";
fig5 = "fig_" + taskId + "_05_Fform_vs_zDNBL_case_map_" + ts + ".png";
fig6 = "fig_" + taskId + "_06_safe_wording_" + ts + ".png";
fig7 = "fig_" + taskId + "_07_single_tube_takeaway_" + ts + ".png";

%% ===== QC =====

qc = table();
qc = addQC(qc, "input_BT16_exists", isfile(inputBT16), inputBT16, ...
    "BT16出力Excelが存在するか。");

if ~isfile(inputBT16)
    error("BT16 input Excel not found: %s", inputBT16);
end

hasBT17 = isfile(inputBT17);
qc = addQC(qc, "input_BT17_exists_optional", hasBT17, inputBT17, ...
    "BT17出力Excelがあれば読む。なくても実行可。");

%% ===== BT16読込 =====

bundleSum   = readSheetOrEmpty(inputBT16, "bundle_summary");
caseSum     = readSheetOrEmpty(inputBT16, "case_summary");
contrast108 = readSheetOrEmpty(inputBT16, "contrast_108_vs_161164");
pairData    = readSheetOrEmpty(inputBT16, "paired_point_data");

qc = addQC(qc, "bundle_summary_rows", height(bundleSum) == 3, string(height(bundleSum)), ...
    "108/161/164の3行が期待値。");
qc = addQC(qc, "case_summary_rows", height(caseSum) == 5, string(height(caseSum)), ...
    "108_70/108_76/161/164_112/164_134の5行が期待値。");
qc = addQC(qc, "paired_rows", height(pairData) == 58, string(height(pairData)), ...
    "BT16のペア行数が58であること。");

requiredPairCols = ["PM_noF1","PM_F1","L_DH_F1","z_DNB_DH_F1","z_DNB_L_F1","F_form_F1","Tsub_F1","x_eq_F1","Bundle"];
missingPairCols = setdiff(requiredPairCols, string(pairData.Properties.VariableNames));
qc = addQC(qc, "paired_required_columns", isempty(missingPairCols), strjoin(missingPairCols, ", "), ...
    "BT18図作成に必要なBT16 paired_point_data列。");

if ~isempty(missingPairCols)
    error("BT16 paired_point_data is missing columns: %s", strjoin(missingPairCols, ", "));
end

%% ===== BT17読込（任意） =====

if hasBT17
    wordingTable = readSheetOrEmpty(inputBT17, "wording_table");
    bt17Decision = readSheetOrEmpty(inputBT17, "BT17_decision");
else
    wordingTable = fallbackWordingTable();
    bt17Decision = fallbackBT17Decision();
end

if isempty(wordingTable)
    wordingTable = fallbackWordingTable();
end
if isempty(bt17Decision)
    bt17Decision = fallbackBT17Decision();
end

%% ===== 相関比較テーブル作成 =====

corrCompare = makeCorrCompareTable(pairData);

%% ===== スライド図マップ =====

slideFigureMap = table( ...
    ["Slide 1"; "Slide 2"; "Slide 3"; "Slide 4"; "Slide 5"; "Slide 6"; "Slide 7"], ...
    ["全体結論"; "単管側の整理"; "バンドル noF1"; "バンドル F1後"; "F_formの位置づけ"; "安全な表現"; "まとめ"], ...
    ["" + fig7; "" + fig7; "" + fig2; "" + fig3 + " + " + fig4; "" + fig5; "" + fig6; "" + fig1], ...
    ["単管は要点図"; ...
     "単管は要点図"; ...
     "PM_noF1ではL/DHが効かない"; ...
     "PM_F1ではL/DH等と対応が見える"; ...
     "F_formは原因ではなく診断軸"; ...
     "『対応して残る』を固定"; ...
     "108/161/164のPM整理"], ...
    'VariableNames', {'slide_no','slide_title','figure_file','message'} ...
);

%% ===== Excel出力 =====

writetable(qc, outXlsx, "Sheet", "QC");
writetable(bundleSum, outXlsx, "Sheet", "BT16_bundle_summary");
writetable(caseSum, outXlsx, "Sheet", "BT16_case_summary");
writetable(contrast108, outXlsx, "Sheet", "BT16_108_contrast");
writetable(corrCompare, outXlsx, "Sheet", "corr_compare");
writetable(wordingTable, outXlsx, "Sheet", "wording_table");
writetable(bt17Decision, outXlsx, "Sheet", "BT17_decision");
writetable(slideFigureMap, outXlsx, "Sheet", "slide_figure_map");

%% ===== 図作成 =====

makeFig1_bundlePM(bundleSum, fig1);
makeFig2_PMnoF1_vs_LDH(pairData, fig2);
makeFig3_PMF1_vs_LDH(pairData, fig3);
makeFig4_R2compare(corrCompare, fig4);
makeFig5_Fform_case_map(caseSum, fig5);
makeFig6_safe_wording(wordingTable, fig6);
makeFig7_single_tube_takeaway(fig7);

%% ===== Markdown出力 =====

writeMarkdownReport(outMd, taskId, taskName, ts, inputBT16, inputBT17, hasBT17, ...
    outXlsx, fig1, fig2, fig3, fig4, fig5, fig6, fig7, ...
    qc, slideFigureMap, corrCompare, bt17Decision);

fprintf("Done.\n");
fprintf("Output Excel: %s\n", outXlsx);
fprintf("Output Markdown: %s\n", outMd);

%% ===== local functions =====

function T = readSheetOrEmpty(file, sheet)
    try
        T = readtable(file, "Sheet", sheet, "VariableNamingRule", "preserve");
    catch
        T = table();
    end
end

function qc = addQC(qc, item, ok, value, reading)
    if islogical(ok)
        if ok
            status = "OK";
        else
            status = "CHECK";
        end
    else
        status = string(ok);
    end

    qc = [qc; table(string(item), string(status), string(value), string(reading), ...
        'VariableNames', {'item','status','value','reading'})];
end

function wording = fallbackWordingTable()
    avoid_phrase = [
        "F_formがPM_F1残差の原因である。"
        "L/DHで補正式を作れる。"
        "DNB位置で補正式を作れる。"
        "F1後残差はF_form・DNB位置・L/DH側に残る。"
        "F1(Tsub)をF(x_eq)へ置換する。"
        "単管でx_eqが効いたので、そのままバンドルへ持ち込む。"
    ];

    recommended_phrase = [
        "PM_F1残差はF_formと対応して残るが、原因とは断定しない。"
        "L/DHは診断軸として有用だが、複合代理として扱う。"
        "DNB位置は診断軸であり、補正式化はしない。"
        "F1後残差はF_form・DNB位置・L/DH・ケース構造と対応して残る。"
        "F1(Tsub)は維持し、F(x_eq)置換は採用しない。"
        "単管ではHsub/PでL/Dに見えた差が整理されるが、これをそのままバンドルへ移植しない。"
    ];

    reason = [
        "F_formはDNB位置・L/DH・出力分布形状と交絡しているため。"
        "L/DHはケース構造を代表している可能性があるため。"
        "DNB位置はL/DHやF_formと切り分けられていないため。"
        "『側に残る』は原因に見えやすいため。"
        "BT05/BT15/BT17でx_eq置換根拠が弱いと判断済みのため。"
        "バンドルではnoF1でL/DHが効いておらず、F1後にだけ対応が出るため。"
    ];

    wording = table(avoid_phrase, recommended_phrase, reason);
end

function T = fallbackBT17Decision()
    item = [
        "BT17 role"
        "formula policy"
        "safe wording"
        "main message"
        "forbidden jump"
    ];
    decision = [
        "explanation figures and decision tables"
        "no new formula"
        "対応して残る"
        "F1後残差はTsub/x_eq側ではなく、F_form・DNB位置・L/DH・ケース構造と対応して残る"
        "F_form/DNB位置/L_DHの単独原因化"
    ];
    T = table(item, decision);
end

function corrTable = makeCorrCompareTable(pairData)
    axisVar = ["L_DH_F1","z_DNB_DH_F1","z_DNB_L_F1","F_form_F1","Tsub_F1","x_eq_F1"];
    axisLabel = ["L/DH","z_DNB/DH","z_DNB/L","F_form","Tsub","x_eq"];

    corrTable = table();

    for i = 1:numel(axisVar)
        x = pairData.(axisVar(i));

        [r_noF1, r2_noF1, n1] = simpleCorr(x, pairData.PM_noF1);
        [r_F1,   r2_F1,   n2] = simpleCorr(x, pairData.PM_F1);

        corrTable = [corrTable; table( ...
            string(axisVar(i)), string(axisLabel(i)), n1, r_noF1, r2_noF1, n2, r_F1, r2_F1, ...
            'VariableNames', {'axis_var','axis_label','N_noF1','r_PM_noF1','R2_PM_noF1','N_F1','r_PM_F1','R2_PM_F1'})]; %#ok<AGROW>
    end
end

function [r, r2, n] = simpleCorr(x, y)
    x = double(x(:));
    y = double(y(:));
    valid = isfinite(x) & isfinite(y);
    x = x(valid);
    y = y(valid);
    n = numel(x);

    if n < 3 || numel(unique(x)) < 2 || numel(unique(y)) < 2
        r = NaN;
        r2 = NaN;
        return;
    end

    C = corrcoef(x, y);
    r = C(1,2);
    r2 = r^2;
end

function makeFig1_bundlePM(bundleSum, figName)
    f = figure("Visible","off");
    x = categorical(string(bundleSum.group));
    y = [bundleSum.PM_noF1_mean, bundleSum.PM_F1_mean];

    bar(x, y, "grouped");
    hold on;
    yline(1, "--", "PM = 1", "Interpreter", "none");
    ylabel("PM mean", "Interpreter", "none");
    title("Bundle summary: PM_noF1 and PM_F1", "Interpreter", "none");
    legend({"PM_noF1","PM_F1"}, "Location","northwest", "Interpreter","none");
    grid on;

    saveas(f, figName);
    close(f);
end

function makeFig2_PMnoF1_vs_LDH(pairData, figName)
    f = figure("Visible","off");
    gscatter(pairData.L_DH_F1, pairData.PM_noF1, pairData.Bundle);
    hold on;
    yline(1, "--", "PM = 1", "Interpreter", "none");
    xlabel("L/DH", "Interpreter", "none");
    ylabel("PM_noF1", "Interpreter", "none");
    title("PM_noF1 vs L/DH", "Interpreter", "none");
    legend("Location","best", "Interpreter","none");
    grid on;

    saveas(f, figName);
    close(f);
end

function makeFig3_PMF1_vs_LDH(pairData, figName)
    f = figure("Visible","off");
    gscatter(pairData.L_DH_F1, pairData.PM_F1, pairData.Bundle);
    hold on;
    yline(1, "--", "PM = 1", "Interpreter", "none");
    xlabel("L/DH", "Interpreter", "none");
    ylabel("PM_F1", "Interpreter", "none");
    title("PM_F1 vs L/DH", "Interpreter", "none");
    legend("Location","best", "Interpreter","none");
    grid on;

    saveas(f, figName);
    close(f);
end

function makeFig4_R2compare(corrTable, figName)
    f = figure("Visible","off");

    x = categorical(string(corrTable.axis_label));
    y = [corrTable.R2_PM_noF1, corrTable.R2_PM_F1];

    bar(x, y, "grouped");
    ylabel("R^2", "Interpreter", "none");
    title("R^2 comparison: PM_noF1 vs PM_F1", "Interpreter", "none");
    legend({"PM_noF1","PM_F1"}, "Location","northwest", "Interpreter","none");
    grid on;

    saveas(f, figName);
    close(f);
end

function makeFig5_Fform_case_map(caseSum, figName)
    f = figure("Visible","off");

    x = caseSum.z_DNB_L_mean;
    y = caseSum.F_form_mean;
    labels = string(caseSum.group);

    scatter(x, y, 80, "filled");
    hold on;

    for i = 1:numel(labels)
        text(x(i), y(i), "  " + labels(i), "Interpreter","none", "FontSize", 9);
    end

    xlabel("z_DNB / L", "Interpreter", "none");
    ylabel("F_form mean", "Interpreter", "none");
    title("F_form vs relative DNB position by case", "Interpreter", "none");
    grid on;

    saveas(f, figName);
    close(f);
end

function makeFig6_safe_wording(wordingTable, figName)
    f = figure("Visible","off", "Position", [100 100 1500 900]);
    axis off;

    title("Safe wording for explanation", "FontSize", 14, "FontWeight", "bold", "Interpreter", "none");

    n = min(height(wordingTable), 6);
    y0 = 0.92;
    dy = 0.14;

    for i = 1:n
        y = y0 - (i-1)*dy;

        text(0.02, y, "Avoid", "FontWeight","bold", "FontSize", 10, "Units","normalized", "Interpreter","none");
        text(0.10, y, string(wordingTable.avoid_phrase(i)), "FontSize", 10, "Units","normalized", "Interpreter","none");

        text(0.02, y-0.04, "Use", "FontWeight","bold", "FontSize", 10, "Units","normalized", "Interpreter","none");
        text(0.10, y-0.04, string(wordingTable.recommended_phrase(i)), "FontSize", 10, "Units","normalized", "Interpreter","none");

        text(0.02, y-0.08, "Why", "FontWeight","bold", "FontSize", 9, "Units","normalized", "Interpreter","none");
        text(0.10, y-0.08, string(wordingTable.reason(i)), "FontSize", 9, "Units","normalized", "Interpreter","none");
    end

    saveas(f, figName);
    close(f);
end

function makeFig7_single_tube_takeaway(figName)
    f = figure("Visible","off", "Position", [100 100 1400 800]);
    axis off;

    title("Single-tube takeaway (for confirmation)", "FontSize", 14, "FontWeight", "bold", "Interpreter", "none");

    lines = [
        "What we want to say now:"
        "1. In single-tube data, short/long differences looked like L/D effects at first."
        "2. However, much of that difference can be organized by Hsub and P."
        "3. Therefore, we do not move to an L/D correction formula from single-tube."
        "4. Hsub/P are inlet thermodynamic-state variables, not direct upstream-history variables."
        "5. So we should not claim that upstream effect itself has been directly explained."
        "6. Additional L/D literature is now for checking history interpretation, not for making an L/D formula."
    ];

    y0 = 0.88;
    dy = 0.10;

    for i = 1:numel(lines)
        text(0.05, y0 - (i-1)*dy, lines(i), "FontSize", 12, "Units","normalized", "Interpreter","none");
    end

    saveas(f, figName);
    close(f);
end

function writeMarkdownReport(outMd, taskId, taskName, ts, inputBT16, inputBT17, hasBT17, ...
    outXlsx, fig1, fig2, fig3, fig4, fig5, fig6, fig7, ...
    qc, slideFigureMap, corrCompare, bt17Decision)

    fid = fopen(outMd, "w");
    if fid < 0
        error("Cannot open markdown output: %s", outMd);
    end
    cleanup = onCleanup(@() fclose(fid)); %#ok<NASGU>

    fprintf(fid, "# %s %s\n\n", taskId, strrep(taskName, "_", " "));
    fprintf(fid, "作成日時: %s\n\n", ts);

    fprintf(fid, "## 1. 目的\n\n");
    fprintf(fid, "確認用スライドに必要な図を作成する。\n");
    fprintf(fid, "本タスクはPowerPoint本体の作成ではなく、図とその使い方を固定するためのもの。\n\n");

    fprintf(fid, "## 2. 入力\n\n");
    fprintf(fid, "- mandatory: `%s`\n", inputBT16);
    fprintf(fid, "- optional: `%s`\n", inputBT17);
    fprintf(fid, "- optional exists: `%s`\n\n", string(hasBT17));

    fprintf(fid, "## 3. 出力\n\n");
    fprintf(fid, "- Excel: `%s`\n", outXlsx);
    fprintf(fid, "- `%s`\n", fig1);
    fprintf(fid, "- `%s`\n", fig2);
    fprintf(fid, "- `%s`\n", fig3);
    fprintf(fid, "- `%s`\n", fig4);
    fprintf(fid, "- `%s`\n", fig5);
    fprintf(fid, "- `%s`\n", fig6);
    fprintf(fid, "- `%s`\n\n", fig7);

    fprintf(fid, "## 4. QC\n\n");
    writeMdTable(fid, qc);

    fprintf(fid, "\n## 5. Slide-Figure map\n\n");
    writeMdTable(fid, slideFigureMap);

    fprintf(fid, "\n## 6. Correlation comparison (used for Slide 3-4)\n\n");
    writeMdTable(fid, corrCompare);

    fprintf(fid, "\n## 7. BT17 decision reminder\n\n");
    writeMdTable(fid, bt17Decision);

    fprintf(fid, "\n## 8. 一次読み\n\n");
    fprintf(fid, "```text\n");
    fprintf(fid, "BT18では、確認用スライドに必要な図を作成した。\n");
    fprintf(fid, "重要なのは、noF1ではL/DHが効かない一方、F1後にはL/DH等との対応が見える、という違いを明確に見せること。\n");
    fprintf(fid, "この違いにより、L/DH補正式へ進まず、L/DHを診断軸として扱う理由を説明しやすくする。\n");
    fprintf(fid, "単管側はこの段階では生データ図を増やさず、Hsub/PでL/Dに見えた差を整理できるという要点図に留めた。\n");
    fprintf(fid, "BT18の図は確認用であり、必要なら次にラベル・凡例・注記を発表向けに整える。\n");
    fprintf(fid, "```\n\n");

    fprintf(fid, "## 9. 次アクション\n\n");
    fprintf(fid, "```text\n");
    fprintf(fid, "1. このrun_reportをチャットへアップロードする。\n");
    fprintf(fid, "2. 可能ならfig_BT18_*.pngもアップロードする。\n");
    fprintf(fid, "3. 図の採用/不採用を決める。\n");
    fprintf(fid, "4. 次に、スライド本文・箇条書き・注記を作る。\n");
    fprintf(fid, "```\n");
end

function writeMdTable(fid, T)
    if isempty(T)
        fprintf(fid, "_empty_\n");
        return;
    end

    vars = string(T.Properties.VariableNames);

    fprintf(fid, "| ");
    for j = 1:numel(vars)
        fprintf(fid, "%s | ", vars(j));
    end
    fprintf(fid, "\n");

    fprintf(fid, "| ");
    for j = 1:numel(vars)
        fprintf(fid, "--- | ");
    end
    fprintf(fid, "\n");

    for i = 1:height(T)
        fprintf(fid, "| ");
        for j = 1:numel(vars)
            s = valueToString(T{i,j});
            s = strrep(s, "|", "\|");
            s = strrep(s, newline, " ");
            fprintf(fid, "%s | ", s);
        end
        fprintf(fid, "\n");
    end
end

function s = valueToString(v)
    if isnumeric(v)
        if isempty(v)
            s = "";
        elseif isscalar(v)
            if isnan(v)
                s = "";
            elseif abs(v) >= 1e5 || (abs(v) < 1e-4 && v ~= 0)
                s = sprintf("%.6g", v);
            else
                s = sprintf("%.8g", v);
            end
        else
            vv = v(:);
            ss = strings(numel(vv),1);
            for k = 1:numel(vv)
                ss(k) = valueToString(vv(k));
            end
            s = char(strjoin(ss, ", "));
        end
    elseif isstring(v)
        if isempty(v)
            s = "";
        else
            s = char(strjoin(v(:), ", "));
        end
    elseif ischar(v)
        s = v;
    elseif iscell(v)
        if isempty(v)
            s = "";
        else
            s = valueToString(v{1});
        end
    elseif islogical(v)
        if isscalar(v)
            if v
                s = "true";
            else
                s = "false";
            end
        else
            s = mat2str(v);
        end
    else
        try
            s = char(string(v));
        catch
            s = "<unprintable>";
        end
    end
end