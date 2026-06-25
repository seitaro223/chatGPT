%% BT17_explanation_figures_decision_tables.m
% BT17:
%   BT16の「対応して残る」構造を、
%   補正式ではなく説明用図・判断表として整理する。
%
% 入力:
%   BT16_Fform_canonical_explanation_package_*.xlsx
%
% 出力:
%   BT17_explanation_figures_decision_tables_YYYYMMDD_HHMMSS.xlsx
%   run_report_BT17_explanation_figures_decision_tables_YYYYMMDD_HHMMSS.md
%   fig_BT17_*.png
%
% 注意:
%   - BT17は補正式作成ではない。
%   - R2が高い軸を補正式係数にしない。
%   - F_form原因説、DNB位置原因説、L/DH原因説に飛ばない。
%   - 「対応して残る」という説明に留める。

clear; clc;

%% ===== ユーザー設定 =====

% 必要ならファイル名だけここを変更
inputBT16 = "BT16_Fform_canonical_explanation_package_20260618_090954.xlsx";

taskId = "BT17";
taskName = "explanation_figures_decision_tables";
ts = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));

outXlsx = taskId + "_" + taskName + "_" + ts + ".xlsx";
outMd   = "run_report_" + taskId + "_" + taskName + "_" + ts + ".md";

fig1 = "fig_" + taskId + "_PM_F1_by_bundle_" + ts + ".png";
fig2 = "fig_" + taskId + "_PM_F1_R2_axes_" + ts + ".png";
fig3 = "fig_" + taskId + "_Fform_vs_zDNB_case_map_" + ts + ".png";
fig4 = "fig_" + taskId + "_story_ladder_" + ts + ".png";

%% ===== QC =====

qc = table();
qc = addQC(qc, "input_BT16_exists", isfile(inputBT16), inputBT16, ...
    "BT16の出力Excelが存在するか。");

if ~isfile(inputBT16)
    error("BT16 input Excel not found: %s", inputBT16);
end

[~, sheets] = xlsfinfo(inputBT16);
sheets = string(sheets(:));

requiredSheets = ["QC","bundle_summary","case_summary","contrast_108_vs_161164", ...
                  "corr_diagnostic_only","decision_summary","can_say","cannot_say","paired_point_data"];

for i = 1:numel(requiredSheets)
    sh = requiredSheets(i);
    qc = addQC(qc, "sheet_exists_" + sh, any(sheets == sh), sh, "BT17で読むBT16シート。");
end

%% ===== BT16出力読み込み =====

bt16_qc      = readSheetOrEmpty(inputBT16, "QC");
bundleSum    = readSheetOrEmpty(inputBT16, "bundle_summary");
caseSum      = readSheetOrEmpty(inputBT16, "case_summary");
contrast108  = readSheetOrEmpty(inputBT16, "contrast_108_vs_161164");
corrDiag     = readSheetOrEmpty(inputBT16, "corr_diagnostic_only");
decisionBT16 = readSheetOrEmpty(inputBT16, "decision_summary");
canSayBT16   = readSheetOrEmpty(inputBT16, "can_say");
cannotBT16   = readSheetOrEmpty(inputBT16, "cannot_say");
pairData     = readSheetOrEmpty(inputBT16, "paired_point_data");

qc = addQC(qc, "bundle_summary_rows", height(bundleSum) == 3, string(height(bundleSum)), ...
    "108/161/164の3行が期待値。");
qc = addQC(qc, "case_summary_rows", height(caseSum) == 5, string(height(caseSum)), ...
    "108_70/108_76/161/164_112/164_134の5行が期待値。");
qc = addQC(qc, "paired_rows", height(pairData) == 58, string(height(pairData)), ...
    "BT16でペア化された58行を読む。");

%% ===== BT17の判断表作成 =====

storyLadder = makeStoryLadder();

diagnosticAxisTable = makeDiagnosticAxisTable(corrDiag);

causeGuard = makeCauseGuardTable();

wordingTable = makeWordingTable();

figurePolicy = table( ...
    ["fig1_PM_F1_by_bundle"; ...
     "fig2_PM_F1_R2_axes"; ...
     "fig3_Fform_vs_zDNB_case_map"; ...
     "fig4_story_ladder"], ...
    ["108が過大側、161/164が過小側に残ることを示す"; ...
     "F1後残差がTsub/x_eqよりF_form・DNB位置・L/DHと対応することを示す"; ...
     "F_formがDNB位置だけではなくケース構造と絡むことを示す"; ...
     "説明の流れを一枚で固定する"], ...
    ["原因断定に使わない"; ...
     "R2を補正式係数にしない"; ...
     "F_form原因説にしない"; ...
     "結論の飛躍を避ける"], ...
    'VariableNames', {'figure','purpose','do_not_infer'} ...
);

bt17Decision = table( ...
    ["BT17 role"; ...
     "formula policy"; ...
     "safe wording"; ...
     "main message"; ...
     "forbidden jump"; ...
     "next after BT17"], ...
    ["explanation figures and decision tables"; ...
     "no new formula"; ...
     "対応して残る"; ...
     "F1後残差はTsub/x_eq側ではなく、F_form・DNB位置・L/DH・ケース構造と対応して残る"; ...
     "F_form/DNB位置/L_DHの単独原因化"; ...
     "working_logへ追記し、必要なら内部説明文またはスライド骨子へ進む"], ...
    'VariableNames', {'item','decision'} ...
);

%% ===== Excel出力 =====

writetable(qc, outXlsx, "Sheet", "QC");
writetable(storyLadder, outXlsx, "Sheet", "story_ladder");
writetable(diagnosticAxisTable, outXlsx, "Sheet", "diagnostic_axis_table");
writetable(causeGuard, outXlsx, "Sheet", "cause_guard_matrix");
writetable(wordingTable, outXlsx, "Sheet", "wording_table");
writetable(figurePolicy, outXlsx, "Sheet", "figure_policy");
writetable(bt17Decision, outXlsx, "Sheet", "BT17_decision");
writetable(bundleSum, outXlsx, "Sheet", "BT16_bundle_summary");
writetable(caseSum, outXlsx, "Sheet", "BT16_case_summary");
writetable(contrast108, outXlsx, "Sheet", "BT16_108_contrast");
writetable(corrDiag, outXlsx, "Sheet", "BT16_corr_diag");
writetable(canSayBT16, outXlsx, "Sheet", "BT16_can_say");
writetable(cannotBT16, outXlsx, "Sheet", "BT16_cannot_say");

%% ===== 図作成 =====

makeFigPMbyBundle(bundleSum, fig1);
makeFigR2Axes(diagnosticAxisTable, fig2);
makeFigFformCaseMap(caseSum, fig3);
makeFigStoryLadder(storyLadder, fig4);

%% ===== Markdown出力 =====

writeMarkdownReport(outMd, taskId, taskName, ts, inputBT16, outXlsx, ...
    fig1, fig2, fig3, fig4, ...
    qc, storyLadder, diagnosticAxisTable, causeGuard, wordingTable, ...
    figurePolicy, bt17Decision, bundleSum, caseSum, contrast108);

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

function story = makeStoryLadder()
    step = (1:7)';

    title = [
        "正本化"
        "観察"
        "残差の向き"
        "対応する軸"
        "交絡の注意"
        "安全な表現"
        "現時点の結論"
    ];

    message = [
        "F_formはlinear_v1で正本化し、BT13-B正本入力を用いる。"
        "FformLinear_v1再計算後、108は過大側、161/164は過小側に残る。"
        "F1後残差はTsub/x_eqだけでは整理しにくい。"
        "F_form、DNB位置、L/DH、ケース構造と対応して残る。"
        "F_form、DNB位置、L/DHは互いに交絡しており、単独原因にはできない。"
        "原因ではなく、対応して残る、と表現する。"
        "補正式は作らず、説明用の判断表・図として固定する。"
    ];

    evidence_type = [
        "BT15/BT16 decision"
        "bundle PM_F1 summary"
        "single predictor R2"
        "diagnostic axes"
        "cross-confounding"
        "wording guard"
        "BT17 decision"
    ];

    do_not_say = [
        "legacy F_formも同格に扱う"
        "108だけが悪い"
        "Tsub/x_eqで説明できる"
        "対応軸が原因である"
        "L/DHだけで補正式を作れる"
        "原因である"
        "BT17で係数を決める"
    ];

    story = table(step, title, message, evidence_type, do_not_say, ...
        'VariableNames', {'step','title','message','evidence_type','do_not_say'});
end

function axisTable = makeDiagnosticAxisTable(corrDiag)
    axisTable = table();

    if isempty(corrDiag)
        return;
    end

    names = string(corrDiag.Properties.VariableNames);

    % 変数名の揺れ対策
    targetCol = findFirst(names, ["target"]);
    axisCol   = findFirst(names, ["axis","predictor"]);
    R2Col     = findFirst(names, ["R2","r2"]);

    if isnan(targetCol) || isnan(axisCol) || isnan(R2Col)
        return;
    end

    target = string(corrDiag{:, targetCol});
    axisName = string(corrDiag{:, axisCol});
    R2 = toNumeric(corrDiag{:, R2Col});

    keep = target == "PM_F1";
    axisName = axisName(keep);
    R2 = R2(keep);

    % qM/qPは診断量だが、補正式入力ではないため説明主軸から外す
    isMain = ismember(axisName, ["F_form_F1","z_DNB_DH_F1","z_DNB_L_F1","L_DH_F1","Tsub_F1","x_eq_F1"]);
    axisName = axisName(isMain);
    R2 = R2(isMain);

    axis_label = strings(numel(axisName), 1);
    category = strings(numel(axisName), 1);
    safe_reading = strings(numel(axisName), 1);
    forbidden_reading = strings(numel(axisName), 1);

    for i = 1:numel(axisName)
        switch axisName(i)
            case "F_form_F1"
                axis_label(i) = "F_form";
                category(i) = "非一様加熱換算";
                safe_reading(i) = "PM_F1と対応するが、原因とは言わない。";
                forbidden_reading(i) = "F_formが残差原因である。";
            case "z_DNB_DH_F1"
                axis_label(i) = "z_DNB/DH";
                category(i) = "DNBまでの履歴長";
                safe_reading(i) = "DNB位置までの履歴長と対応する。";
                forbidden_reading(i) = "DNB位置が原因である。";
            case "z_DNB_L_F1"
                axis_label(i) = "z_DNB/L";
                category(i) = "相対DNB位置";
                safe_reading(i) = "相対DNB位置とも対応する。";
                forbidden_reading(i) = "z_DNB/Lだけで説明できる。";
            case "L_DH_F1"
                axis_label(i) = "L/DH";
                category(i) = "加熱長・ケース構造";
                safe_reading(i) = "L/DHは便利な診断軸だが複合代理である。";
                forbidden_reading(i) = "L/DH補正式を作れる。";
            case "Tsub_F1"
                axis_label(i) = "Tsub";
                category(i) = "入口サブクール";
                safe_reading(i) = "F1後残差に対する単独対応は弱い。";
                forbidden_reading(i) = "F1後残差はTsubで説明できる。";
            case "x_eq_F1"
                axis_label(i) = "x_eq";
                category(i) = "熱平衡状態量";
                safe_reading(i) = "F1後残差に対する単独対応は弱い。診断量として残す。";
                forbidden_reading(i) = "F1(Tsub)をF(x_eq)へ置換すべき。";
            otherwise
                axis_label(i) = axisName(i);
                category(i) = "unknown";
                safe_reading(i) = "診断用。";
                forbidden_reading(i) = "原因断定。";
        end
    end

    axisTable = table(axisName, axis_label, category, R2, safe_reading, forbidden_reading, ...
        'VariableNames', {'axis','axis_label','category','R2_PM_F1','safe_reading','forbidden_reading'});

    % R2降順
    [~, idx] = sort(axisTable.R2_PM_F1, "descend");
    axisTable = axisTable(idx, :);
end

function guard = makeCauseGuardTable()
    axis = [
        "F_form"
        "z_DNB/DH"
        "z_DNB/L"
        "L/DH"
        "Tsub"
        "x_eq"
        "qM/qP"
        "case structure"
    ];

    can_show = [
        "非一様加熱換算、DNB位置、出力分布形状の違いを含む診断軸"
        "入口からDNB位置までの履歴長の違い"
        "DNBが上流寄りか出口寄りかの違い"
        "全体の加熱長・ケース群差を含む整理軸"
        "F1の元変数であり、F1前の誤差やF1効果量の説明軸"
        "熱平衡状態・二相発達状態の診断量"
        "実験側・予測側のレベル確認用"
        "108/161/164のセットとして同時に変わる条件群"
    ];

    why_not_cause = [
        "DNB位置、L/DH、軸方向出力分布と交絡している"
        "L/DHと強く交絡している"
        "F_formや出力分布形状と交絡している"
        "複合代理であり、単独物理量ではない"
        "F1後残差への対応は弱い"
        "Tsubと共変し、F1後残差への対応は弱い"
        "qMは結果側量、qPは予測側量で循環しやすい"
        "3ケースだけでは一般化できない"
    ];

    allowed_phrase = [
        "F_formと対応して残る"
        "DNBまでの履歴長と対応して残る"
        "相対DNB位置とも対応する"
        "L/DHは診断軸として残る"
        "F1(Tsub)は維持する"
        "x_eqは診断量として残す"
        "qM/qPは診断用に見る"
        "ケース構造と対応して残る"
    ];

    forbidden_phrase = [
        "F_formが原因である"
        "DNB位置が原因である"
        "z_DNB/Lだけで説明できる"
        "L/DH補正式を作る"
        "F1後残差はTsubで説明できる"
        "F1をF(x_eq)へ置換する"
        "qMを補正式入力にする"
        "108/161/164だけで一般化できる"
    ];

    guard = table(axis, can_show, why_not_cause, allowed_phrase, forbidden_phrase, ...
        'VariableNames', {'axis','can_show','why_not_cause','allowed_phrase','forbidden_phrase'});
end

function wording = makeWordingTable()
    bad = [
        "F_formがPM_F1残差の原因である。"
        "L/DHで補正式を作れる。"
        "DNB位置で補正式を作れる。"
        "F1後残差はF_form・DNB位置・L/DH側に残る。"
        "x_eqでF1を置換する。"
        "108/161/164から一般的な結論が得られた。"
    ];

    good = [
        "PM_F1残差はF_formと対応して残るが、原因とは断定しない。"
        "L/DHは診断軸として有用だが、複合代理として扱う。"
        "DNB位置は診断軸であり、補正式化はしない。"
        "F1後残差はF_form・DNB位置・L/DH・ケース構造と対応して残る。"
        "F1(Tsub)は維持し、x_eqは診断量として保留する。"
        "108/161/164ではこの対応が見えるが、一般化には追加確認が必要である。"
    ];

    reason = [
        "F_formはDNB位置・L/DH・出力分布形状と交絡しているため。"
        "L/DHはケース構造をまとめて代表している可能性があるため。"
        "DNB位置はL/DHやF_formと切り分けられていないため。"
        "『側に残る』は原因に見えやすいため。"
        "BT05/BT15/BT16でx_eq置換根拠が弱いと判断済みのため。"
        "3ケース群だけでは外部一般化できないため。"
    ];

    wording = table(bad, good, reason, ...
        'VariableNames', {'avoid_phrase','recommended_phrase','reason'});
end

function idx = findFirst(names, candidates)
    idx = NaN;
    namesNorm = lower(string(names));
    candidates = lower(string(candidates));
    for i = 1:numel(candidates)
        hit = find(namesNorm == candidates(i), 1, "first");
        if ~isempty(hit)
            idx = hit;
            return;
        end
    end
end

function x = toNumeric(v)
    if isnumeric(v)
        x = double(v);
    elseif iscell(v)
        x = nan(size(v));
        for i = 1:numel(v)
            x(i) = str2double(string(v{i}));
        end
    else
        x = str2double(string(v));
    end
    x = x(:);
end

function makeFigPMbyBundle(bundleSum, figName)
    if isempty(bundleSum)
        return;
    end

    f = figure("Visible","off");
    x = categorical(string(bundleSum.group));
    y = bundleSum.PM_F1_mean;

    bar(x, y);
    hold on;
    yline(1, "--", "PM=1");
    ylabel("PM_F1 mean");
    title("BT17: PM_F1 by bundle");
    grid on;

    saveas(f, figName);
    close(f);
end

function makeFigR2Axes(axisTable, figName)
    if isempty(axisTable)
        return;
    end

    f = figure("Visible","off");

    % R2降順で表示
    axisLabels = string(axisTable.axis_label);
    R2 = axisTable.R2_PM_F1;

    bar(categorical(axisLabels), R2);
    ylabel("R^2 with PM_F1");
    title("BT17: diagnostic axes for PM_F1");
    grid on;
    xtickangle(30);

    saveas(f, figName);
    close(f);
end

function makeFigFformCaseMap(caseSum, figName)
    if isempty(caseSum)
        return;
    end

    f = figure("Visible","off");

    x = caseSum.z_DNB_L_mean;
    y = caseSum.F_form_mean;
    labels = string(caseSum.group);

    scatter(x, y, 70, "filled");
    hold on;
    for i = 1:numel(labels)
        text(x(i), y(i), "  " + labels(i), "FontSize", 9);
    end

    xlabel("z_DNB / L");
    ylabel("F_form linear_v1 mean");
    title("BT17: F_form vs relative DNB position by case");
    grid on;

    saveas(f, figName);
    close(f);
end

function makeFigStoryLadder(story, figName)
    if isempty(story)
        return;
    end

    f = figure("Visible","off", "Position", [100 100 1100 650]);
    axis off;

    title("BT17: explanation ladder", "FontSize", 14, "FontWeight", "bold");

    y0 = 0.90;
    dy = 0.12;

    for i = 1:height(story)
        y = y0 - (i-1)*dy;

        text(0.02, y, sprintf("%d. %s", story.step(i), string(story.title(i))), ...
            "FontSize", 11, "FontWeight", "bold", "Units", "normalized");

        text(0.22, y, string(story.message(i)), ...
            "FontSize", 10, "Units", "normalized", "Interpreter", "none");

        text(0.22, y-0.035, "言わない: " + string(story.do_not_say(i)), ...
            "FontSize", 9, "Units", "normalized", "Interpreter", "none");
    end

    saveas(f, figName);
    close(f);
end

function writeMarkdownReport(outMd, taskId, taskName, ts, inputBT16, outXlsx, ...
    fig1, fig2, fig3, fig4, ...
    qc, storyLadder, diagnosticAxisTable, causeGuard, wordingTable, ...
    figurePolicy, bt17Decision, bundleSum, caseSum, contrast108)

    fid = fopen(outMd, "w");
    if fid < 0
        error("Cannot open markdown output: %s", outMd);
    end
    cleanup = onCleanup(@() fclose(fid));

    fprintf(fid, "# %s %s\n\n", taskId, strrep(taskName, "_", " "));
    fprintf(fid, "作成日時: %s\n\n", ts);

    fprintf(fid, "## 1. 目的\n\n");
    fprintf(fid, "BT16の「F1後残差はF_form・DNB位置・L/DH・ケース構造と対応して残る」という整理を、補正式ではなく説明用図・判断表として固定する。\n\n");
    fprintf(fid, "BT17では新しい補正式を作らない。R2が高い軸を補正式係数として採用しない。\n\n");

    fprintf(fid, "## 2. 入力\n\n");
    fprintf(fid, "- input BT16 Excel: `%s`\n\n", inputBT16);

    fprintf(fid, "## 3. 出力\n\n");
    fprintf(fid, "- output Excel: `%s`\n", outXlsx);
    fprintf(fid, "- figure: `%s`\n", fig1);
    fprintf(fid, "- figure: `%s`\n", fig2);
    fprintf(fid, "- figure: `%s`\n", fig3);
    fprintf(fid, "- figure: `%s`\n\n", fig4);

    fprintf(fid, "## 4. 前提\n\n");
    fprintf(fid, "```text\n");
    fprintf(fid, "- BT17は説明用図・判断表の整理である。\n");
    fprintf(fid, "- F2/F1F2は使わない。\n");
    fprintf(fid, "- F1(Tsub)は維持する。\n");
    fprintf(fid, "- F1(Tsub)をF(x_eq)へ置換しない。\n");
    fprintf(fid, "- F_formはlinear_v1正本として扱う。\n");
    fprintf(fid, "- legacy F_formは今後の解析入力には使わない。\n");
    fprintf(fid, "- F_form補正式、DNB位置補正式、L/DH補正式は作らない。\n");
    fprintf(fid, "- 『原因』ではなく『対応して残る』と表現する。\n");
    fprintf(fid, "```\n\n");

    fprintf(fid, "## 5. QC\n\n");
    writeMdTable(fid, qc);

    fprintf(fid, "\n## 6. 説明ラダー\n\n");
    writeMdTable(fid, storyLadder);

    fprintf(fid, "\n## 7. 診断軸テーブル\n\n");
    writeMdTable(fid, diagnosticAxisTable);

    fprintf(fid, "\n## 8. 原因断定を避けるための判断表\n\n");
    writeMdTable(fid, causeGuard);

    fprintf(fid, "\n## 9. 表現修正表\n\n");
    writeMdTable(fid, wordingTable);

    fprintf(fid, "\n## 10. 図の役割\n\n");
    writeMdTable(fid, figurePolicy);

    fprintf(fid, "\n## 11. BT17判断\n\n");
    writeMdTable(fid, bt17Decision);

    fprintf(fid, "\n## 12. BT16 bundle summary再掲\n\n");
    writeMdTable(fid, bundleSum);

    fprintf(fid, "\n## 13. BT16 case summary再掲\n\n");
    writeMdTable(fid, caseSum);

    fprintf(fid, "\n## 14. 108 vs mean(161,164)再掲\n\n");
    writeMdTable(fid, contrast108);

    fprintf(fid, "\n## 15. 一次読み\n\n");
    fprintf(fid, "```text\n");
    fprintf(fid, "BT17では、BT16の数値結果を補正式化せず、説明用の図・判断表として整理した。\n\n");
    fprintf(fid, "説明の中心は、F1後残差がTsub/x_eq側ではなく、F_form・DNB位置・L/DH・ケース構造と対応して残る、という点である。\n");
    fprintf(fid, "ただし、F_form、DNB位置、L/DHは互いに交絡しているため、単独原因にはしない。\n");
    fprintf(fid, "したがって、BT17の安全な表現は『対応して残る』であり、『原因である』ではない。\n");
    fprintf(fid, "BT17でもF1(Tsub)は維持し、F(x_eq)置換、F_form補正式、DNB位置補正式、L/DH補正式には進まない。\n");
    fprintf(fid, "```\n\n");

    fprintf(fid, "## 16. 次アクション\n\n");
    fprintf(fid, "```text\n");
    fprintf(fid, "1. このrun_reportをチャットへアップロードする。\n");
    fprintf(fid, "2. チャット側で図・判断表の言い過ぎがないか確認する。\n");
    fprintf(fid, "3. 問題なければ、working_logへBT17追記を行う。\n");
    fprintf(fid, "4. rを上げたworking_logを再アップロードして、追記確認まで行う。\n");
    fprintf(fid, "5. その後、必要なら内部説明文またはスライド骨子に進む。\n");
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
            v = T{i,j};
            s = valueToString(v);
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
            ss = strings(numel(vv), 1);
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