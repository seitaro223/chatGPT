%% BT16_Fform_canonical_explanation_package.m
% F_form正本化後の内部説明・発表用整理パッケージ
%
% 目的:
%   - BT13-B正本入力を読む
%   - FformLinear_v1再計算後の108/161/164の状態を説明用に整理する
%   - 補正式は作らない
%   - run_report Markdown と確認用Excel/図を出力する
%
% 前提:
%   - 入力正本:
%     H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx
%   - F1(Tsub)は維持
%   - F(x_eq)置換はしない
%   - F_formはlinear_v1正本
%   - legacy F_formは使わない
%
% 実行方法:
%   1. このmファイルを入力xlsxと同じフォルダに置く
%   2. MATLABで実行
%   3. 生成された run_report_BT16_*.md をChatGPTにアップロードする

clear; clc;

%% ===== ユーザー設定 =====

inputFile = "H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx";

taskId = "BT16";
taskName = "Fform_canonical_explanation_package";
ts = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));

outXlsx = taskId + "_" + taskName + "_" + ts + ".xlsx";
outMd   = "run_report_" + taskId + "_" + taskName + "_" + ts + ".md";

fig1 = "fig_" + taskId + "_PM_F1_by_bundle_" + ts + ".png";
fig2 = "fig_" + taskId + "_PM_F1_vs_LDH_" + ts + ".png";
fig3 = "fig_" + taskId + "_Fform_by_case_" + ts + ".png";

sheetMap = table( ...
    ["tm_108";    "tm_161";    "tm_164";    "tm_F1_108";    "tm_F1_161";    "tm_F1_164"], ...
    [108;         161;         164;         108;            161;            164], ...
    ["noF1";      "noF1";      "noF1";      "F1";           "F1";           "F1"], ...
    'VariableNames', {'sheet','Bundle','source_kind'} ...
);

%% ===== QC: 入力存在確認 =====

qc = table();
qc = addQC(qc, "input_file_exists", fileExists(inputFile), inputFile, "入力正本が存在するか。");

if ~fileExists(inputFile)
    error("Input file not found: %s", inputFile);
end

[~, allSheets] = xlsfinfo(inputFile);
allSheets = string(allSheets(:));

%% ===== シート読み込み =====

allData = table();
sheetReadStatus = table();

for i = 1:height(sheetMap)
    sh = sheetMap.sheet(i);
    bundle = sheetMap.Bundle(i);
    kind = sheetMap.source_kind(i);

    existsSheet = any(allSheets == sh);
    if ~existsSheet
        sheetReadStatus = [sheetReadStatus; table(sh, kind, bundle, "CHECK_sheet_not_found", 0, ...
            'VariableNames', {'sheet','source_kind','Bundle','status','N_rows'})]; %#ok<AGROW>
        continue;
    end

    Traw = readtable(inputFile, "Sheet", sh, "VariableNamingRule", "preserve");

    T = standardizeBundleTable(Traw, bundle, kind, sh);

    sheetReadStatus = [sheetReadStatus; table(sh, kind, bundle, "OK_read", height(T), ...
        'VariableNames', {'sheet','source_kind','Bundle','status','N_rows'})]; %#ok<AGROW>

    allData = [allData; T]; %#ok<AGROW>
end

expectedRows = 116;
qc = addQC(qc, "sheet_read", all(sheetReadStatus.status == "OK_read"), ...
    sprintf("%d/6", sum(sheetReadStatus.status == "OK_read")), "対象6シートが読めたか。");
qc = addQC(qc, "current_rows", height(allData) == expectedRows, ...
    string(height(allData)), "noF1 58 + F1 58 = 116行が期待値。");

%% ===== 必須列QC =====

requiredCols = ["No","Bundle","source_kind","qP","qM","PM","F_form","Tsub","x_eq","z_DNB_DH","z_DNB_L","L_DH"];
missingCols = setdiff(requiredCols, string(allData.Properties.VariableNames));

qc = addQC(qc, "required_columns", isempty(missingCols), ...
    strjoin(missingCols, ", "), "BT16説明整理に必要な標準列。");

if ~isempty(missingCols)
    disp("Missing standardized columns:");
    disp(missingCols);
    error("Required columns are missing. Check aliases in standardizeBundleTable().");
end

%% ===== noF1 / F1 ペア化 =====

noF1 = allData(allData.source_kind == "noF1", :);
F1   = allData(allData.source_kind == "F1", :);

pair = innerjoin( ...
    noF1, F1, ...
    "Keys", ["No","Bundle"], ...
    "LeftVariables",  ["No","Bundle","case_label","qP","qM","PM","F_form","Tsub","x_eq","z_DNB_DH","z_DNB_L","L_DH"], ...
    "RightVariables", ["qP","qM","PM","F_form","Tsub","x_eq","z_DNB_DH","z_DNB_L","L_DH"] ...
);

% innerjoin後の変数名を明示的に整理
pair.Properties.VariableNames = normalizePairVariableNames(pair.Properties.VariableNames);

% F1/noF1差分
pair.PM_noF1 = pair.PM_noF1;
pair.PM_F1   = pair.PM_F1;
pair.err_F1  = pair.PM_F1 - 1.0;
pair.abs_err_F1 = abs(pair.err_F1);
pair.delta_PM = pair.PM_F1 - pair.PM_noF1;
pair.lift_ratio = pair.PM_F1 ./ pair.PM_noF1;

% qP/qMは値の単位がW/m2相当ならMW/m2にもする
scale_q = 1;
if median(pair.qM_F1, "omitnan") > 1e5
    scale_q = 1e-6;
end
pair.qM_MWm2 = pair.qM_F1 * scale_q;
pair.qP_F1_MWm2 = pair.qP_F1 * scale_q;
pair.qP_noF1_MWm2 = pair.qP_noF1 * scale_q;

qc = addQC(qc, "paired_rows", height(pair) == 58, ...
    string(height(pair)), "No+BundleでnoF1/F1をペア化した行数。");
qc = addQC(qc, "F1_policy", true, "keep_F1_Tsub", "F1(Tsub)は維持する。");
qc = addQC(qc, "formula_policy", true, "no_new_formula", "BT16では補正式を作らない。");
qc = addQC(qc, "Fform_policy", true, "linear_v1_canonical", "F_formはlinear_v1正本として読む。");

%% ===== 集計 =====

bundleSummary = groupSummary(pair, "Bundle");
caseSummary   = groupSummary(pair, "case_label");

% 108 vs 161/164 contrast
contrast108 = make108Contrast(bundleSummary);

% 相関診断：説明用。補正式には使わない。
corrTargets = ["PM_F1","err_F1","abs_err_F1","delta_PM"];
corrAxes = ["F_form_F1","z_DNB_DH_F1","z_DNB_L_F1","L_DH_F1","Tsub_F1","x_eq_F1","qM_MWm2","qP_F1_MWm2"];

corrDiag = table();
for t = 1:numel(corrTargets)
    for a = 1:numel(corrAxes)
        y = pair.(corrTargets(t));
        x = pair.(corrAxes(a));
        [R, R2, slope, intercept, N] = simpleCorr(x, y);
        corrDiag = [corrDiag; table(corrTargets(t), corrAxes(a), N, R, R2, slope, intercept, "diagnostic_only_no_formula", ...
            'VariableNames', {'target','axis','N','pearson_r','R2','slope','intercept','note'})]; %#ok<AGROW>
    end
end

%% ===== 判断テーブル =====

decisionSummary = table( ...
    ["current_bundle_input"; "F_form definition"; "legacy F_form"; "F1(Tsub)"; "F(x_eq) replacement"; "F_form formula"; "DNB/L/DH formula"; "BT16 role"], ...
    ["adopt BT13-B recalc tmCompatible v2"; "adopt linear_v1"; "trace only"; "keep"; "not adopt"; "do not create"; "do not create"; "explanation package"], ...
    ["F_form/q_calc/PMが再計算後で整合"; ...
     "BT08-A1dで線形補間・線形積分として定義しBT14-B2で整合確認"; ...
     "履歴・比較用。今後の解析入力には使わない"; ...
     "BT05/BT15判断を維持"; ...
     "x_eq置換根拠は弱い"; ...
     "F_formは原因ではなく交絡した診断項"; ...
     "DNB位置・L/DHは診断軸であり補正式にはしない"; ...
     "内部説明・発表用に整理する。新規補正式は作らない"], ...
    'VariableNames', {'item','decision','reason'} ...
);

canSay = table( ...
    ["F_formはlinear_v1で正本化済み"; ...
     "BT13-B正本入力ではF_form/q_calc/PMが整合"; ...
     "BT13-Cでは108が過大側、161/164が過小側に残る"; ...
     "F1後残差はTsub/x_eq側より、F_form・DNB位置・L/DH・ケース構造側に残る"; ...
     "F_formはDNB相対位置だけで決まる量ではない"; ...
     "F1(Tsub)は維持する"], ...
    'VariableNames', {'statement'} ...
);

cannotSay = table( ...
    ["F_formがPM_F1残差の原因である"; ...
     "L/DHだけで補正式を作れる"; ...
     "DNB位置だけで補正式を作れる"; ...
     "F1(Tsub)をF(x_eq)へ置換すべき"; ...
     "108/161/164の3ケースだけで一般化できる"; ...
     "legacy F_formを今後の入力として使ってよい"], ...
    'VariableNames', {'statement'} ...
);

%% ===== Excel出力 =====

writetable(qc, outXlsx, "Sheet", "QC");
writetable(sheetReadStatus, outXlsx, "Sheet", "sheet_read_status");
writetable(bundleSummary, outXlsx, "Sheet", "bundle_summary");
writetable(caseSummary, outXlsx, "Sheet", "case_summary");
writetable(contrast108, outXlsx, "Sheet", "contrast_108_vs_161164");
writetable(corrDiag, outXlsx, "Sheet", "corr_diagnostic_only");
writetable(decisionSummary, outXlsx, "Sheet", "decision_summary");
writetable(canSay, outXlsx, "Sheet", "can_say");
writetable(cannotSay, outXlsx, "Sheet", "cannot_say");
writetable(pair, outXlsx, "Sheet", "paired_point_data");

%% ===== 図出力 =====

makeFigures(pair, bundleSummary, caseSummary, fig1, fig2, fig3);

%% ===== Markdown出力 =====

writeMarkdownReport(outMd, taskId, taskName, ts, inputFile, outXlsx, fig1, fig2, fig3, ...
    qc, bundleSummary, caseSummary, contrast108, corrDiag, decisionSummary, canSay, cannotSay);

fprintf("Done.\n");
fprintf("Output Excel: %s\n", outXlsx);
fprintf("Output Markdown: %s\n", outMd);

%% ===== local functions =====

function tf = fileExists(f)
    tf = isfile(f);
end

function qc = addQC(qc, item, ok, value, reading)
    if islogical(ok)
        if ok
            status = "OK";
        else
            status = "CHECK";
        end
    elseif isstring(ok) || ischar(ok)
        status = string(ok);
    else
        status = "CHECK";
    end

    qc = [qc; table(string(item), string(status), string(value), string(reading), ...
        'VariableNames', {'item','status','value','reading'})];
end

function T = standardizeBundleTable(Traw, bundle, source_kind, sheetName)
    names = string(Traw.Properties.VariableNames);

    idxNo     = findCol(names, ["No","No_","No_TableNo","EXPT_NO","ExptNo"]);
    idxqP     = findCol(names, ["q_P","qP","q_calc","q_calc_MWm2","qP_Wm2"]);
    idxqM     = findCol(names, ["q_M","qM","q_exp","q_exp_MWm2","qM_Wm2"]);
    idxPM     = findCol(names, ["PM_ratio","PM","P_M","PoverM","qP_over_qM"]);
    idxFform  = findCol(names, ["F_form","Fform","F_form_linear","Fform_linear"]);
    idxTsub   = findCol(names, ["Tsub","Tsub_K","T_sub","DeltaTsub","dTsub"]);
    idxxeq    = findCol(names, ["x_Mes","x_eq","xeq","x_eq_qP_F1","xMes"]);

    % 正本ブックでは、z_DNB/DH, z_DNB/L, L/DHは直接列ではなく、
    % DH, L_DNB, L から計算する。
    idxDH     = findCol(names, ["DH","D_H","hydraulic_diameter"]);
    idxLDNB   = findCol(names, ["L_DNB","LDNB","z_DNB","DNB_position","DNB_pos"]);
    idxL      = findCol(names, ["L","Length","heated_length","Heating_length"]);

    % 万一、将来版で直接列が入っている場合のためのfallback
    idxzDH_direct = findCol(names, ["z_DNB_over_DH","z_DNB_DH","z_DNB/DH","DNB_DH"]);
    idxzL_direct  = findCol(names, ["z_DNB_over_L","z_DNB_L","z_DNB/L","DNB_L"]);
    idxLDH_direct = findCol(names, ["L_over_DH","L_DH","L/DH","LoverDH"]);

    required_basic = [idxNo, idxqP, idxqM, idxPM, idxFform, idxTsub, idxxeq];
    if any(isnan(required_basic))
        disp("Column names found in sheet: " + sheetName);
        disp(names');
        error("Basic required column alias not found in sheet %s. Please add alias in standardizeBundleTable().", sheetName);
    end

    hasGeometryBase = ~any(isnan([idxDH, idxLDNB, idxL]));
    hasGeometryDirect = ~any(isnan([idxzDH_direct, idxzL_direct, idxLDH_direct]));

    if ~hasGeometryBase && ~hasGeometryDirect
        disp("Column names found in sheet: " + sheetName);
        disp(names');
        error("Geometry columns not found in sheet %s. Need either DH/L_DNB/L or z_DNB_DH/z_DNB_L/L_DH.", sheetName);
    end

    T = table();
    T.No = toNumeric(Traw{:, idxNo});
    T.Bundle = repmat(bundle, height(Traw), 1);
    T.source_kind = repmat(string(source_kind), height(Traw), 1);
    T.sheet = repmat(string(sheetName), height(Traw), 1);

    T.qP = toNumeric(Traw{:, idxqP});
    T.qM = toNumeric(Traw{:, idxqM});
    T.PM = toNumeric(Traw{:, idxPM});
    T.F_form = toNumeric(Traw{:, idxFform});
    T.Tsub = toNumeric(Traw{:, idxTsub});
    T.x_eq = toNumeric(Traw{:, idxxeq});

    if hasGeometryBase
        DH    = toNumeric(Traw{:, idxDH});
        L_DNB = toNumeric(Traw{:, idxLDNB});
        L     = toNumeric(Traw{:, idxL});

        T.DH = DH;
        T.L_DNB = L_DNB;
        T.L = L;

        T.z_DNB_DH = L_DNB ./ DH;
        T.z_DNB_L  = L_DNB ./ L;
        T.L_DH     = L ./ DH;
    else
        T.z_DNB_DH = toNumeric(Traw{:, idxzDH_direct});
        T.z_DNB_L  = toNumeric(Traw{:, idxzL_direct});
        T.L_DH     = toNumeric(Traw{:, idxLDH_direct});
        T.DH = nan(height(Traw), 1);
        T.L_DNB = nan(height(Traw), 1);
        T.L = nan(height(Traw), 1);
    end

    T.case_label = classifyCase(T.Bundle, T.z_DNB_L, T.F_form);

    % 空行除去
    valid = ~isnan(T.No) & ~isnan(T.PM);
    T = T(valid, :);
end

function idx = findCol(names, aliases)
    idx = NaN;
    names = string(names);
    aliases = string(aliases);

    namesNorm = normalizeName(names);
    aliasesNorm = normalizeName(aliases);

    % 1. 完全一致
    for a = 1:numel(aliasesNorm)
        hit = find(namesNorm == aliasesNorm(a), 1, "first");
        if ~isempty(hit)
            idx = hit;
            return;
        end
    end

    % 2. aliasが長い場合のみ部分一致
    %    L が L_DNB に誤爆するのを防ぐ。
    for a = 1:numel(aliasesNorm)
        if strlength(aliasesNorm(a)) < 3
            continue;
        end
        hit = find(contains(namesNorm, aliasesNorm(a)), 1, "first");
        if ~isempty(hit)
            idx = hit;
            return;
        end
    end
end

function s = normalizeName(s)
    s = string(s);
    s = lower(s);
    s = replace(s, " ", "");
    s = replace(s, "_", "");
    s = replace(s, "/", "");
    s = replace(s, "-", "");
    s = replace(s, "(", "");
    s = replace(s, ")", "");
    s = replace(s, "[", "");
    s = replace(s, "]", "");
end

function x = toNumeric(v)
    if isnumeric(v)
        x = double(v);
    elseif iscell(v)
        x = nan(size(v));
        for i = 1:numel(v)
            if isnumeric(v{i})
                x(i) = double(v{i});
            else
                x(i) = str2double(string(v{i}));
            end
        end
    else
        x = str2double(string(v));
    end
    x = x(:);
end

function case_label = classifyCase(Bundle, zL, Fform)
    case_label = strings(numel(Bundle), 1);

    for i = 1:numel(Bundle)
        b = Bundle(i);
        z = zL(i);
        f = Fform(i);

        if b == 108
            if abs(z - 0.729) < abs(z - 0.792)
                case_label(i) = "108_70in";
            else
                case_label(i) = "108_76in";
            end
        elseif b == 161
            case_label(i) = "161_uniform";
        elseif b == 164
            if abs(z - 0.667) < abs(z - 0.798)
                case_label(i) = "164_112in";
            else
                case_label(i) = "164_134in_normal";
            end
        else
            case_label(i) = "unknown";
        end

        if isnan(z) && ~isnan(f)
            if b == 108 && f < 0.68
                case_label(i) = "108_70in";
            elseif b == 108
                case_label(i) = "108_76in";
            elseif b == 164 && f < 1.0
                case_label(i) = "164_112in";
            elseif b == 164
                case_label(i) = "164_134in_normal";
            end
        end
    end
end

function namesOut = normalizePairVariableNames(namesIn)
    names = string(namesIn);

    % innerjoin後の名前は環境により qP_noF1/qP_F1 ではなく qP_left/qP_right 等になる場合がある。
    % ここでは出現順に基づき、想定変数へ強制的に割り当てる。
    namesOut = cellstr(names);

    % No, Bundle, case_label は先頭側に残る想定。
    % qP/qM/PM/F_form/Tsub/x_eq/z_DNB_DH/z_DNB_L/L_DH が左右で並ぶ。
    base = ["qP","qM","PM","F_form","Tsub","x_eq","z_DNB_DH","z_DNB_L","L_DH"];

    for k = 1:numel(base)
        hit = find(startsWith(names, base(k)));
        if numel(hit) >= 2
            namesOut{hit(1)} = char(base(k) + "_noF1");
            namesOut{hit(2)} = char(base(k) + "_F1");
        elseif numel(hit) == 1
            % 片側しかない場合はF1側として扱うが通常は起きない
            namesOut{hit(1)} = char(base(k) + "_F1");
        end
    end
end

function S = groupSummary(pair, groupVar)
    G = findgroups(pair.(groupVar));

    groupValues = splitapply(@(x) string(x(1)), string(pair.(groupVar)), G);
    N = splitapply(@numel, pair.PM_F1, G);

    S = table();
    S.group = groupValues;
    S.N = N;
    S.PM_noF1_mean = splitapply(@nanmean_local, pair.PM_noF1, G);
    S.PM_F1_mean = splitapply(@nanmean_local, pair.PM_F1, G);
    S.err_F1_mean = splitapply(@nanmean_local, pair.err_F1, G);
    S.abs_err_F1_mean = splitapply(@nanmean_local, pair.abs_err_F1, G);
    S.delta_PM_mean = splitapply(@nanmean_local, pair.delta_PM, G);
    S.lift_ratio_mean = splitapply(@nanmean_local, pair.lift_ratio, G);
    S.qM_MWm2_mean = splitapply(@nanmean_local, pair.qM_MWm2, G);
    S.qP_F1_MWm2_mean = splitapply(@nanmean_local, pair.qP_F1_MWm2, G);
    S.F_form_mean = splitapply(@nanmean_local, pair.F_form_F1, G);
    S.Tsub_mean = splitapply(@nanmean_local, pair.Tsub_F1, G);
    S.x_eq_mean = splitapply(@nanmean_local, pair.x_eq_F1, G);
    S.z_DNB_DH_mean = splitapply(@nanmean_local, pair.z_DNB_DH_F1, G);
    S.z_DNB_L_mean = splitapply(@nanmean_local, pair.z_DNB_L_F1, G);
    S.L_DH_mean = splitapply(@nanmean_local, pair.L_DH_F1, G);

    % 表示順を固定
    if groupVar == "Bundle"
        order = ["108","161","164"];
        [~, idx] = ismember(order, S.group);
        idx = idx(idx > 0);
        S = S(idx, :);
    else
        order = ["108_70in","108_76in","161_uniform","164_112in","164_134in_normal"];
        [~, idx] = ismember(order, S.group);
        idx = idx(idx > 0);
        S = S(idx, :);
    end
end

function m = nanmean_local(x)
    m = mean(x, "omitnan");
end

function contrast = make108Contrast(bundleSummary)
    idx108 = bundleSummary.group == "108";
    idxOther = bundleSummary.group == "161" | bundleSummary.group == "164";

    vars = ["PM_noF1_mean","PM_F1_mean","err_F1_mean","abs_err_F1_mean", ...
            "delta_PM_mean","lift_ratio_mean","qM_MWm2_mean","qP_F1_MWm2_mean", ...
            "F_form_mean","Tsub_mean","x_eq_mean","z_DNB_DH_mean","z_DNB_L_mean","L_DH_mean"];

    contrast = table();
    for i = 1:numel(vars)
        v = vars(i);
        val108 = bundleSummary{idx108, v};
        valOther = mean(bundleSummary{idxOther, v}, "omitnan");
        delta = val108 - valOther;
        ratio = val108 / valOther;
        contrast = [contrast; table(v, val108, valOther, delta, ratio, ...
            'VariableNames', {'variable','value_108','mean_161_164','delta_108_minus_161_164','ratio_108_over_161_164'})]; %#ok<AGROW>
    end
end

function [R, R2, slope, intercept, N] = simpleCorr(x, y)
    valid = isfinite(x) & isfinite(y);
    x = x(valid);
    y = y(valid);
    N = numel(x);

    if N < 3 || numel(unique(x)) < 2 || numel(unique(y)) < 2
        R = NaN; R2 = NaN; slope = NaN; intercept = NaN;
        return;
    end

    C = corrcoef(x, y);
    R = C(1,2);
    R2 = R^2;

    p = polyfit(x, y, 1);
    slope = p(1);
    intercept = p(2);
end

function makeFigures(pair, bundleSummary, caseSummary, fig1, fig2, fig3)
    % Fig1: PM_F1 by bundle
    f = figure("Visible","off");
    bar(categorical(bundleSummary.group), bundleSummary.PM_F1_mean);
    hold on;
    yline(1, "--", "PM=1");
    ylabel("PM_F1 mean");
    title("BT16 PM_F1 by bundle");
    grid on;
    saveas(f, fig1);
    close(f);

    % Fig2: PM_F1 vs L/DH
    f = figure("Visible","off");
    gscatter(pair.L_DH_F1, pair.PM_F1, pair.Bundle);
    hold on;
    yline(1, "--", "PM=1");
    xlabel("L/DH");
    ylabel("PM_F1");
    title("BT16 PM_F1 vs L/DH");
    grid on;
    saveas(f, fig2);
    close(f);

    % Fig3: F_form by case
    f = figure("Visible","off");
    bar(categorical(caseSummary.group), caseSummary.F_form_mean);
    ylabel("F_form linear_v1 mean");
    title("BT16 F_form linear_v1 by case");
    grid on;
    xtickangle(30);
    saveas(f, fig3);
    close(f);
end

function writeMarkdownReport(outMd, taskId, taskName, ts, inputFile, outXlsx, fig1, fig2, fig3, ...
    qc, bundleSummary, caseSummary, contrast108, corrDiag, decisionSummary, canSay, cannotSay)

    fid = fopen(outMd, "w");
    if fid < 0
        error("Cannot open markdown output: %s", outMd);
    end

    cleanup = onCleanup(@() fclose(fid));

    fprintf(fid, "# %s %s\n\n", taskId, strrep(taskName, "_", " "));
    fprintf(fid, "作成日時: %s\n\n", ts);

    fprintf(fid, "## 1. 目的\n\n");
    fprintf(fid, "BT15でF_formをlinear_v1として正本化した後の状態を、内部説明・発表用に整理する。\n\n");
    fprintf(fid, "本タスクは補正式作成ではない。\n\n");

    fprintf(fid, "## 2. 入力\n\n");
    fprintf(fid, "- input: `%s`\n\n", inputFile);

    fprintf(fid, "## 3. 出力\n\n");
    fprintf(fid, "- output Excel: `%s`\n", outXlsx);
    fprintf(fid, "- figure: `%s`\n", fig1);
    fprintf(fid, "- figure: `%s`\n", fig2);
    fprintf(fid, "- figure: `%s`\n\n", fig3);

    fprintf(fid, "## 4. 前提\n\n");
    fprintf(fid, "```text\n");
    fprintf(fid, "- F2/F1F2は使わない。\n");
    fprintf(fid, "- 比較対象はnoF1とF1のみ。\n");
    fprintf(fid, "- F1(Tsub)は維持する。\n");
    fprintf(fid, "- F1(Tsub)をF(x_eq)へ置換しない。\n");
    fprintf(fid, "- F_formはlinear_v1正本として扱う。\n");
    fprintf(fid, "- legacy F_formは今後の解析入力には使わない。\n");
    fprintf(fid, "- F_form補正式、DNB位置補正式、L/DH補正式は作らない。\n");
    fprintf(fid, "- BT16は説明整理であり、新補正式探索ではない。\n");
    fprintf(fid, "```\n\n");

    fprintf(fid, "## 5. QC\n\n");
    writeMdTable(fid, qc);

    fprintf(fid, "\n## 6. Bundle summary\n\n");
    writeMdTable(fid, bundleSummary);

    fprintf(fid, "\n## 7. Case summary\n\n");
    writeMdTable(fid, caseSummary);

    fprintf(fid, "\n## 8. 108 vs mean(161,164)\n\n");
    writeMdTable(fid, contrast108);

    fprintf(fid, "\n## 9. 説明用の相関診断\n\n");
    fprintf(fid, "注：これは説明用の診断であり、補正式係数として採用しない。\n\n");

    % PM_F1だけ抜粋
    corrPM = corrDiag(corrDiag.target == "PM_F1", :);
    writeMdTable(fid, corrPM);

    fprintf(fid, "\n## 10. 判断サマリ\n\n");
    writeMdTable(fid, decisionSummary);

    fprintf(fid, "\n## 11. 現時点で言ってよいこと\n\n");
    writeMdTable(fid, canSay);

    fprintf(fid, "\n## 12. まだ言ってはいけないこと\n\n");
    writeMdTable(fid, cannotSay);

    fprintf(fid, "\n## 13. 一次読み\n\n");
    fprintf(fid, "```text\n");
    fprintf(fid, "BT16では、BT13-B正本入力を読み、FformLinear_v1再計算後の状態を説明用に整理した。\n\n");
    fprintf(fid, "PM_F1平均は、108が1を超える過大側、161/164が1未満の過小側に残る。\n");
    fprintf(fid, "この残差はTsub/x_eq側だけでは整理しにくく、F_form、DNB位置、L/DH、ケース構造側に残る。\n");
    fprintf(fid, "ただし、F_form、DNB位置、L/DHは互いに交絡しているため、どれか1つを原因とは言わない。\n");
    fprintf(fid, "F_formは非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数であり、F1ではない。\n");
    fprintf(fid, "BT16では追加補正式を作らず、説明整理に留める。\n");
    fprintf(fid, "```\n\n");

    fprintf(fid, "## 14. 次アクション\n\n");
    fprintf(fid, "```text\n");
    fprintf(fid, "1. このrun_reportをチャットへアップロードする。\n");
    fprintf(fid, "2. チャット側で説明として妥当か、言い過ぎがないかを確認する。\n");
    fprintf(fid, "3. 問題なければ、全体working_logへ追記するMarkdownを作る。\n");
    fprintf(fid, "4. rを上げたworking_logを再アップロードし、1ループ完了とする。\n");
    fprintf(fid, "```\n");
end

function writeMdTable(fid, T)
    if isempty(T)
        fprintf(fid, "_empty_\n");
        return;
    end

    vars = string(T.Properties.VariableNames);

    % header
    fprintf(fid, "| ");
    for j = 1:numel(vars)
        fprintf(fid, "%s | ", vars(j));
    end
    fprintf(fid, "\n");

    % separator
    fprintf(fid, "| ");
    for j = 1:numel(vars)
        fprintf(fid, "--- | ");
    end
    fprintf(fid, "\n");

    % rows
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
            s = strjoin(ss, ", ");
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