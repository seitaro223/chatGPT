%% BT08A1d_Fform_linear_finalize.m
% BT08-A1d：F_formを全ケースで線形補間ルールに統一して確定する
%
% 目的：
%   Excelをこれ以上いじらず、MATLAB計算とMarkdownログでF_form定義を確定する。
%
% 背景：
%   既存F_formは、108では近傍点をほぼそのまま使用し、164ではf_DNBを線形補間し、
%   164通常ケースのBlue_areaには暫定的な -0.01 補正が混入していた可能性が高い。
%
%   そのため、BT08-A1dでは全ケースで例外をなくし、以下の統一ルールでF_formを再計算する。
%
% 統一ルール：
%   1. 軸方向出力分布 f(x) を読む。
%   2. DNB位置 x_DNB = L_DNB / L を読む。
%   3. f_DNB = interp1(x, f, x_DNB) で線形補間する。
%   4. Blue_area = integral_0^x_DNB f(x) dx を線形補間込みで計算する。
%   5. Orange_area = x_DNB * f_DNB とする。
%   6. F_form_linear = Blue_area / Orange_area とする。
%
% 方針：
%   - 既存F_formは legacy として残す。
%   - 修正版は F_form_linear として別値で出す。
%   - current_bundle_inputは更新しない。
%   - 次段階で current_bundle_input_v2 に集約すべき列をMarkdownで固定する。
%
% 入力：
%   バンドルデータ整理r3.xlsx
%   任意：H52Q_current_bundle_input_v1_*.xlsx
%
% 出力：
%   BT08A1d_Fform_linear_finalize_yyyymmdd_HHMMSS.xlsx
%   run_report_BT08A1d_Fform_linear_finalize_yyyymmdd_HHMMSS.md

clear; clc;

%% ===== Settings =====

inputR3File = "";
inputCurrentFile = "";

if strlength(inputR3File) == 0
    inputR3File = findLatestFile("バンドルデータ整理r*.xlsx");
end

if strlength(inputCurrentFile) == 0
    inputCurrentFile = findLatestFileOptional("H52Q_current_bundle_input_v1_*.xlsx");
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "BT08A1d_Fform_linear_finalize_" + timestamp + ".xlsx";
outMd   = "run_report_BT08A1d_Fform_linear_finalize_" + timestamp + ".md";

fprintf("Input r3 workbook: %s\n", inputR3File);
fprintf("Optional current_bundle input: %s\n", nullText(inputCurrentFile));

bundles = [108, 161, 164];

%% ===== Read profiles and DNB anchors from r3 =====

profilePoints = table();

for b = bundles
    shBase = "非一様加熱を一様加熱に補正" + string(b);
    sh = resolveSheetName(inputR3File, shBase);
    P = readProfileSheet(inputR3File, sh, b);
    profilePoints = [profilePoints; P]; %#ok<AGROW>
end

dnbAnchors = readXeqSummary(inputR3File);

%% ===== Compute unified linear F_form =====

linearFform = table();

for i = 1:height(dnbAnchors)
    b = dnbAnchors.Bundle(i);
    zD = dnbAnchors.z_ratio(i);

    P = profilePoints(profilePoints.Bundle == b, :);

    row = computeLinearFform(P, b, zD);
    row.r3_note = dnbAnchors.note(i);
    row.r3_blue_area_stored = dnbAnchors.numerator_r3(i);
    row.r3_total_area_stored = dnbAnchors.denominator_r3(i);
    row.r3_z_heat_ratio_stored = dnbAnchors.z_heat_ratio(i);
    row.diff_linear_blue_minus_r3_stored_blue = row.Blue_area_linear - row.r3_blue_area_stored;
    row.diff_linear_Fform_vs_r3blue_interp = row.Fform_linear - safeRatio(row.r3_blue_area_stored, row.Orange_area_linear);

    if b == 108 && abs(zD - 70/96) < 1e-4
        row.case_label = "108_70in";
    elseif b == 108 && abs(zD - 76/96) < 1e-4
        row.case_label = "108_76in";
    elseif b == 161
        row.case_label = "161_uniform";
    elseif b == 164 && abs(zD - 112/168) < 1e-4
        row.case_label = "164_112in";
    elseif b == 164 && abs(zD - 134/168) < 1e-4
        row.case_label = "164_134in_normal";
    else
        row.case_label = "unknown";
    end

    linearFform = [linearFform; row]; %#ok<AGROW>
end

% reorder columns
linearFform = movevars(linearFform, "case_label", "Before", "Bundle");

%% ===== Optional comparison with current legacy F_form =====

if strlength(inputCurrentFile) > 0 && isfile(inputCurrentFile)
    currentFform = readCurrentBundleFform(inputCurrentFile);
else
    currentFform = table();
end

legacyCompare = compareWithLegacy(linearFform, currentFform);

%% ===== Build recommended final table =====

finalFform = buildFinalFformTable(linearFform, legacyCompare);

%% ===== Decision flags =====

decision = makeDecision(linearFform, legacyCompare, finalFform);

%% ===== Fields for current_bundle_input_v2 =====

fieldsV2 = cell2table({
    "Fform_definition_version", "linear_v1", "F_form定義バージョン"
    "Fform_source_book", "バンドルデータ整理r3.xlsx", "軸方向出力分布の出典"
    "Fform_source_sheet", "非一様加熱を一様加熱に補正108/161/164", "軸方向出力分布シート"
    "Fform_case_label", "108_70in / 108_76in / 161_uniform / 164_112in / 164_134in_normal", "DNB位置別の識別"
    "Fform_DNB_z_ratio", "x_DNB = DNB位置 / 加熱長", "DNB位置"
    "Fform_q_DNB_linear", "interp1(x,f,x_DNB)", "DNB位置の軸方向係数"
    "Fform_blue_area_linear", "integral_0^xDNB f(x) dx by linear interpolation", "DNB位置までの線形補間積分面積"
    "Fform_orange_area_linear", "x_DNB * q_DNB_linear", "基準長方形面積"
    "Fform_linear", "Fform_blue_area_linear / Fform_orange_area_linear", "修正後F_form"
    "Fform_legacy", "current_bundle_input existing F_form", "既存F_form"
    "Fform_diff_linear_minus_legacy", "Fform_linear - Fform_legacy", "定義変更差"
    "Fform_ratio_linear_to_legacy", "Fform_linear / Fform_legacy", "定義変更比"
    "Fform_status", "adopt_linear / uniform / legacy_trace", "採用状態"
    "Fform_definition_note", "全ケースを線形補間・線形積分で統一", "定義メモ"
}, 'VariableNames', {'field','suggested_value_or_formula','meaning'});

%% ===== Write Excel =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(profilePoints, outXlsx, 'Sheet', 'A1d_profile_points');
writetable(dnbAnchors, outXlsx, 'Sheet', 'A1d_dnb_anchors');
writetable(linearFform, outXlsx, 'Sheet', 'A1d_Fform_linear');
writetable(currentFform, outXlsx, 'Sheet', 'A1d_current_legacy');
writetable(legacyCompare, outXlsx, 'Sheet', 'A1d_legacy_compare');
writetable(finalFform, outXlsx, 'Sheet', 'A1d_final_Fform');
writetable(decision, outXlsx, 'Sheet', 'A1d_decision_flags');
writetable(fieldsV2, outXlsx, 'Sheet', 'A1d_fields_for_v2');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Write Markdown report =====

md = strings(0,1);

md(end+1) = "# BT08-A1d F_form linear finalize";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "Excelをこれ以上手作業で編集せず、MATLAB計算とMarkdownログでF_form定義を確定する。既存F_formには、108では近傍点使用、164では線形補間、164通常ケースでは暫定的なBlue_area補正が混在していた可能性があるため、全ケースを線形補間・線形積分の統一ルールで再計算する。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- r3: `" + inputR3File + "`";
md(end+1) = "- current_bundle: `" + nullText(inputCurrentFile) + "`";
md(end+1) = "";
md(end+1) = "## 3. 統一ルール";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "x_DNB = DNB位置 / 加熱長";
md(end+1) = "f_DNB = interp1(x, f, x_DNB)";
md(end+1) = "Blue_area_linear = integral_0^x_DNB f(x) dx";
md(end+1) = "Orange_area_linear = x_DNB * f_DNB";
md(end+1) = "F_form_linear = Blue_area_linear / Orange_area_linear";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 4. F_form_linear";
md(end+1) = "";
md(end+1) = tableToMarkdown(linearFform);
md(end+1) = "";
md(end+1) = "## 5. Legacy comparison";
md(end+1) = "";
md(end+1) = tableToMarkdown(legacyCompare);
md(end+1) = "";
md(end+1) = "## 6. Final F_form table";
md(end+1) = "";
md(end+1) = tableToMarkdown(finalFform);
md(end+1) = "";
md(end+1) = "## 7. Decision flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(decision);
md(end+1) = "";
md(end+1) = "## 8. Fields for current_bundle_input_v2";
md(end+1) = "";
md(end+1) = tableToMarkdown(fieldsV2);
md(end+1) = "";
md(end+1) = "## 9. 次アクション";
md(end+1) = "";
md(end+1) = "1. このMarkdownのFform_linearを確認する。";
md(end+1) = "2. 問題なければ、F_formはlinear_v1として確定する。";
md(end+1) = "3. Excel手作業ではなく、次のBT08-A2でcurrent_bundle_input_v2へ列として集約する。";
md(end+1) = "4. 既存F_formはlegacyとして残し、Fform_linearとの差分も残す。";
md(end+1) = "5. その後、必要ならFform_linearを使ったP/M影響を別タスクで確認する。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display =====

disp("=== Final F_form table ===");
disp(finalFform);

disp("=== Decision ===");
disp(decision);

%% ===== Functions =====

function latest = findLatestFile(pattern)
    d = dir(pattern);
    if isempty(d)
        error("No file matching pattern: %s", pattern);
    end
    [~, idx] = max([d.datenum]);
    latest = string(d(idx).name);
end

function latest = findLatestFileOptional(pattern)
    d = dir(pattern);
    if isempty(d)
        latest = "";
        return;
    end
    [~, idx] = max([d.datenum]);
    latest = string(d(idx).name);
end

function s = nullText(x)
    if strlength(string(x)) == 0
        s = "なし";
    else
        s = string(x);
    end
end

function actualName = resolveSheetName(file, desiredName)
    desiredName = string(desiredName);
    try
        sheets = string(sheetnames(file));
    catch
        [~, rawSheets] = xlsfinfo(file);
        sheets = string(rawSheets);
    end

    idx = find(sheets == desiredName, 1);
    if ~isempty(idx)
        actualName = sheets(idx);
        return;
    end

    idx = find(strtrim(sheets) == strtrim(desiredName), 1);
    if ~isempty(idx)
        actualName = sheets(idx);
        return;
    end

    idx = find(contains(strtrim(sheets), strtrim(desiredName)), 1);
    if ~isempty(idx)
        actualName = sheets(idx);
        return;
    end

    fprintf("Available sheets:\n");
    disp(sheets(:));
    error("Sheet not found. desired=[%s]", desiredName);
end

function P = readProfileSheet(file, sheetName, bundle)
    C = readcell(file, 'Sheet', sheetName);

    % 優先：E/F列 = z, f(x)
    z = getNumericCol(C, 5);
    f = getNumericCol(C, 6);
    ok = isfinite(z) & isfinite(f) & z >= 0 & z <= 1.0000001;

    if sum(ok) < 3
        % 代替：A/C列
        z = getNumericCol(C, 1);
        f = getNumericCol(C, 3);
        ok = isfinite(z) & isfinite(f) & z >= 0 & z <= 1.0000001;
        source_cols = "A/C";
    else
        source_cols = "E/F";
    end

    z = z(ok);
    f = f(ok);

    [z, idx] = sort(z);
    f = f(idx);

    [zu, ~, ic] = unique(z);
    fu = accumarray(ic, f, [], @mean);
    z = zu;
    f = fu;

    P = table();
    P.Bundle = repmat(bundle, numel(z), 1);
    P.profile_sheet = repmat(string(sheetName), numel(z), 1);
    P.source_cols = repmat(string(source_cols), numel(z), 1);
    P.point_index = (1:numel(z))';
    P.z = z;
    P.f = f;
end

function X = readXeqSummary(file)
    sheetName = resolveSheetName(file, "02_xeq_recalc");
    C = readcell(file, 'Sheet', sheetName);

    X = table();
    X.Bundle = zeros(0,1);
    X.z_ratio = zeros(0,1);
    X.z_heat_ratio = zeros(0,1);
    X.note = strings(0,1);
    X.row_in_sheet = zeros(0,1);
    X.numerator_r3 = zeros(0,1);
    X.denominator_r3 = zeros(0,1);

    rows = [];
    for i = 1:size(C,1)
        b = cellToDouble(C{i,1});
        zratio = cellToDouble(C{i,2});
        zheat = cellToDouble(C{i,5});

        if ismember(round(b), [108,161,164]) && isfinite(zratio) && zratio >= 0 && zratio <= 1.2 && isfinite(zheat) && zheat >= 0 && zheat <= 1.2
            rows = [rows; i]; %#ok<AGROW>
        end
    end

    rows = rows(rows < 20);

    for k = 1:numel(rows)
        i = rows(k);
        newRow = table();
        newRow.Bundle = round(cellToDouble(C{i,1}));
        newRow.z_ratio = cellToDouble(C{i,2});
        newRow.numerator_r3 = cellToDouble(C{i,3});
        newRow.denominator_r3 = cellToDouble(C{i,4});
        newRow.z_heat_ratio = cellToDouble(C{i,5});
        newRow.note = cellToString(C{i,6});
        newRow.row_in_sheet = i;

        X = [X; newRow]; %#ok<AGROW>
    end
end

function row = computeLinearFform(P, bundle, zD)
    z = P.z(:);
    f = P.f(:);

    [z, idx] = sort(z);
    f = f(idx);

    fD = interp1(z, f, zD, 'linear', 'extrap');
    blue = integrateExactToZ(z, f, zD);
    orange = zD * fD;
    F = safeRatio(blue, orange);

    row = table();
    row.Bundle = bundle;
    row.z_DNB_ratio = zD;
    row.profile_sheet = P.profile_sheet(1);
    row.profile_source_cols = P.source_cols(1);
    row.profile_N = numel(z);
    row.z_min = min(z);
    row.z_max = max(z);
    row.f_DNB_linear = fD;
    row.Blue_area_linear = blue;
    row.Orange_area_linear = orange;
    row.Fform_linear = F;

    % reference values for diagnostics
    row.Blue_area_method = "linear_integral_0_to_xDNB";
    row.f_DNB_method = "linear_interp_at_xDNB";
    row.Orange_area_method = "xDNB_times_fDNB";
end

function val = integrateExactToZ(z, f, zD)
    z = z(:);
    f = f(:);

    [z, idx] = sort(z);
    f = f(idx);

    if zD <= z(1)
        val = 0;
        return;
    end

    val = 0;

    for i = 1:numel(z)-1
        z0 = z(i);
        z1 = z(i+1);
        f0 = f(i);
        f1 = f(i+1);

        if z0 >= zD
            break;
        end

        zz1 = min(z1, zD);
        if zz1 <= z0
            continue;
        end

        ff1 = f0 + (f1 - f0) * (zz1 - z0) / (z1 - z0);
        val = val + (f0 + ff1) / 2 * (zz1 - z0);

        if z1 >= zD
            break;
        end
    end
end

function currentFform = readCurrentBundleFform(file)
    currentFform = table();

    sheetMap = table( ...
        [108;161;164], ...
        ["tm_F1_108";"tm_F1_161";"tm_F1_164"], ...
        'VariableNames', {'Bundle','sheet'} ...
    );

    for i = 1:height(sheetMap)
        b = sheetMap.Bundle(i);
        sh = sheetMap.sheet(i);

        try
            T = readtable(file, 'Sheet', sh, 'VariableNamingRule', 'preserve');
        catch
            warning("Could not read current sheet %s", sh);
            continue;
        end

        Fform = getNumColFromTable(T, ["F_form","Fform","F_FORM"]);
        L_DNB = getNumColFromTable(T, ["L_DNB","LDNB","z_DNB","zDNB"]);
        L = getNumColFromTable(T, ["L","HeatedLength","L_heat"]);
        DH = getNumColFromTable(T, ["DH","D_h","Dh"]);
        no = getNumColFromTable(T, ["No"]);

        zL = L_DNB ./ L;
        zDH = L_DNB ./ DH;

        ok = isfinite(Fform) & isfinite(zL);

        C = table();
        C.Bundle = repmat(b, sum(ok), 1);
        C.sheet = repmat(string(sh), sum(ok), 1);
        C.No = no(ok);
        C.Fform_legacy = Fform(ok);
        C.z_DNB_over_L_current = zL(ok);
        C.z_DNB_over_DH_current = zDH(ok);

        currentFform = [currentFform; C]; %#ok<AGROW>
    end
end

function comp = compareWithLegacy(linearFform, currentFform)
    comp = table();

    for i = 1:height(linearFform)
        b = linearFform.Bundle(i);
        zD = linearFform.z_DNB_ratio(i);

        curMean = NaN; curSD = NaN; curN = 0; curZ = NaN;

        if height(currentFform) > 0
            C = currentFform(currentFform.Bundle == b, :);
            if height(C) > 0
                dz = abs(C.z_DNB_over_L_current - zD);
                near = dz < 0.015;

                if ~any(near)
                    [~, idx] = min(dz);
                    near = false(height(C),1);
                    near(idx) = true;
                end

                curMean = mean(C.Fform_legacy(near), 'omitnan');
                curSD = std(C.Fform_legacy(near), 'omitnan');
                curN = sum(isfinite(C.Fform_legacy(near)));
                curZ = mean(C.z_DNB_over_L_current(near), 'omitnan');
            end
        end

        row = table();
        row.case_label = linearFform.case_label(i);
        row.Bundle = b;
        row.z_DNB_ratio = zD;
        row.current_match_N = curN;
        row.current_z_mean = curZ;
        row.Fform_legacy_mean = curMean;
        row.Fform_legacy_sd = curSD;
        row.Fform_linear = linearFform.Fform_linear(i);
        row.diff_linear_minus_legacy = linearFform.Fform_linear(i) - curMean;
        row.ratio_linear_to_legacy = safeRatio(linearFform.Fform_linear(i), curMean);
        row.Blue_area_linear = linearFform.Blue_area_linear(i);
        row.Blue_area_legacy_stored_r3 = linearFform.r3_blue_area_stored(i);
        row.diff_Blue_linear_minus_r3stored = linearFform.Blue_area_linear(i) - linearFform.r3_blue_area_stored(i);
        row.f_DNB_linear = linearFform.f_DNB_linear(i);
        row.Orange_area_linear = linearFform.Orange_area_linear(i);

        if ~isfinite(curMean)
            row.compare_status = "not_compared";
        elseif abs(row.diff_linear_minus_legacy) < 1e-3
            row.compare_status = "same_lt_1e-3";
        elseif abs(row.diff_linear_minus_legacy) < 1e-2
            row.compare_status = "near_lt_1e-2";
        elseif abs(row.diff_linear_minus_legacy) < 5e-2
            row.compare_status = "changed_lt_5e-2";
        else
            row.compare_status = "changed_ge_5e-2";
        end

        comp = [comp; row]; %#ok<AGROW>
    end
end

function finalT = buildFinalFformTable(linearFform, legacyCompare)
    finalT = table();

    for i = 1:height(linearFform)
        lc = legacyCompare(strcmp(legacyCompare.case_label, linearFform.case_label(i)), :);

        row = table();
        row.Fform_definition_version = "linear_v1";
        row.case_label = linearFform.case_label(i);
        row.Bundle = linearFform.Bundle(i);
        row.z_DNB_ratio = linearFform.z_DNB_ratio(i);
        row.f_DNB_used = linearFform.f_DNB_linear(i);
        row.Blue_area_used = linearFform.Blue_area_linear(i);
        row.Orange_area_used = linearFform.Orange_area_linear(i);
        row.Fform_final_linear = linearFform.Fform_linear(i);

        if height(lc) > 0
            row.Fform_legacy_mean = lc.Fform_legacy_mean(1);
            row.diff_linear_minus_legacy = lc.diff_linear_minus_legacy(1);
            row.ratio_linear_to_legacy = lc.ratio_linear_to_legacy(1);
            row.compare_status = lc.compare_status(1);
        else
            row.Fform_legacy_mean = NaN;
            row.diff_linear_minus_legacy = NaN;
            row.ratio_linear_to_legacy = NaN;
            row.compare_status = "not_compared";
        end

        if linearFform.Bundle(i) == 161
            row.Fform_status = "uniform_or_nearly_uniform";
        else
            row.Fform_status = "adopt_linear_v1";
        end

        row.definition_note = "全ケースでf_DNBを線形補間し、Blue_areaを0からx_DNBまで線形補間積分したF_form。既存F_formはlegacyとして残す。";

        finalT = [finalT; row]; %#ok<AGROW>
    end
end

function decision = makeDecision(linearFform, legacyCompare, finalFform)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("definition", "adopt", "linear_v1", "F_formは全ケースで線形補間・線形積分に統一する。");
    add("excel_policy", "adopt", "no_manual_excel_edit", "Excelを直接いじり回さず、MATLAB出力とMarkdownログで定義を確定する。");
    add("legacy_policy", "adopt", "keep_legacy", "既存F_formはlegacyとして残し、Fform_linearとの差分を残す。");

    for i = 1:height(legacyCompare)
        add("case_" + legacyCompare.case_label(i), legacyCompare.compare_status(i), ...
            "legacy=" + string(sprintf("%.8g", legacyCompare.Fform_legacy_mean(i))) + ...
            ", linear=" + string(sprintf("%.8g", legacyCompare.Fform_linear(i))) + ...
            ", diff=" + string(sprintf("%.8g", legacyCompare.diff_linear_minus_legacy(i))), ...
            "定義変更によるF_form差。");
    end

    maxAbsDiff = max(abs(legacyCompare.diff_linear_minus_legacy), [], 'omitnan');
    add("max_change", "diagnostic", sprintf("%.8g", maxAbsDiff), "legacyからlinear_v1への最大変化。");

    add("next", "next", "BT08-A2", "current_bundle_input_v2へFform_linear列と出典列を集約する。P/M影響はその後の別タスクで確認する。");

    decision = table(item, status, value, reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function x = getNumericCol(C, col)
    n = size(C,1);
    x = NaN(n,1);
    for i = 1:n
        x(i) = cellToDouble(C{i,col});
    end
end

function v = cellToDouble(x)
    if isnumeric(x) && isscalar(x)
        v = double(x);
    elseif islogical(x) && isscalar(x)
        v = double(x);
    elseif ischar(x) || isstring(x)
        v = str2double(string(x));
    else
        v = NaN;
    end
end

function s = cellToString(x)
    if ismissing(x)
        s = "";
    elseif ischar(x) || isstring(x)
        s = string(x);
    elseif isnumeric(x) && isscalar(x) && isfinite(x)
        s = string(x);
    elseif islogical(x) && isscalar(x)
        s = string(x);
    else
        s = "";
    end
end

function r = safeRatio(a, b)
    r = NaN(size(a));
    ok = isfinite(a) & isfinite(b) & abs(b) > 0;
    r(ok) = a(ok) ./ b(ok);
end

function v = getNumColFromTable(T, candidates)
    name = findColumn(T, candidates);
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
