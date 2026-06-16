%% BT08A1b_Fform_manual_true_audit_v2.m
% BT08-A1b：164.xlsx / F_Form_108整理版.xlsx の手作業採用点を使ったF_form確認
%
% 目的：
%   BT08-A1では、r3の非一様加熱補正シートからF_form候補を再計算した。
%   ただし、164の z=134/168 側では、線形補間候補でも既存F_formと完全一致しなかった。
%
%   ユーザーコメント：
%     「164はA列とB列に長い線形補間があって、
%       C列とかに採用したものにtrueと書いている」
%
%   したがってBT08-A1bでは、
%   164r*.xlsx を優先し、TRUE 採用点を読み、
%   その q_local を用いて F_form = blue_area / (z_DNB * q_local) を再計算する。
%
%   108については、F_Form_108整理版.xlsx があれば、
%   README/確認シートに残っている F_form定義・計算値を抽出して確認する。
%
% 重要：
%   - この段階では current_bundle_input は更新しない。
%   - まず手作業採用点を確認する。
%   - 目的達成後、current_bundle_input_v2に必要最小限の情報を集約する。
%   - F_formはF1ではない。
%   - 補正式は作らない。
%
% 入力：
%   バンドルデータ整理r3.xlsx
%   164.xlsx
%   F_Form_108整理版.xlsx
%   任意：H52Q_current_bundle_input_v1_*.xlsx
%
% 出力：
%   BT08A1b_Fform_manual_true_audit_yyyymmdd_HHMMSS.xlsx
%   run_report_BT08A1b_Fform_manual_true_audit_yyyymmdd_HHMMSS.md

clear; clc;

%% ===== Settings =====

inputR3File = "";
input164File = "";
input108File = "";
inputCurrentFile = "";

if strlength(inputR3File) == 0
    inputR3File = findLatestFile("バンドルデータ整理r*.xlsx");
end

if strlength(input164File) == 0
    % TRUEを書き足した最新版を優先する。
    % 例：164r1.xlsx
    input164File = findLatestFileOptional("164r*.xlsx");
    if strlength(input164File) == 0
        input164File = findLatestFileOptional("164.xlsx");
    end
end

if strlength(input108File) == 0
    input108File = findLatestFileOptional("F_Form_108整理版.xlsx");
end

if strlength(inputCurrentFile) == 0
    inputCurrentFile = findLatestFileOptional("H52Q_current_bundle_input_v1_*.xlsx");
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "BT08A1b_Fform_manual_true_audit_" + timestamp + ".xlsx";
outMd   = "run_report_BT08A1b_Fform_manual_true_audit_" + timestamp + ".md";

fprintf("Input r3 workbook: %s\n", inputR3File);
fprintf("Input 164 workbook: %s\n", nullText(input164File));
fprintf("Input 108 workbook: %s\n", nullText(input108File));
fprintf("Optional current_bundle input: %s\n", nullText(inputCurrentFile));

%% ===== Rebuild r3 area audit for blue area =====

bundles = [108, 161, 164];

profilePoints = table();
for b = bundles
    shBase = "非一様加熱を一様加熱に補正" + string(b);
    sh = resolveSheetName(inputR3File, shBase);
    P = readProfileSheet(inputR3File, sh, b);
    profilePoints = [profilePoints; P]; %#ok<AGROW>
end

xeqSummary = readXeqSummary(inputR3File);

areaAudit = table();
for b = bundles
    P = profilePoints(profilePoints.Bundle == b, :);
    X = xeqSummary(xeqSummary.Bundle == b, :);

    for i = 1:height(X)
        zD = X.z_ratio(i);
        row = computeAreaAudit(P, b, zD);
        row.z_heat_ratio_r3 = X.z_heat_ratio(i);
        row.z_heat_ratio_diff_inclusive_minus_r3 = row.z_heat_ratio_inclusive - row.z_heat_ratio_r3;
        row.xeq_note = X.note(i);
        row.numerator_r3 = X.numerator_r3(i);
        row.denominator_r3 = X.denominator_r3(i);
        areaAudit = [areaAudit; row]; %#ok<AGROW>
    end
end

%% ===== Read current_bundle F_form if available =====

if strlength(inputCurrentFile) > 0 && isfile(inputCurrentFile)
    currentFform = readCurrentBundleFform(inputCurrentFile);
else
    currentFform = table();
end

%% ===== Read manual TRUE adopted points from 164.xlsx =====

if strlength(input164File) > 0 && isfile(input164File)
    true164 = readManualTruePoints164(input164File);
else
    true164 = table();
end

%% ===== Compare TRUE adopted 164 points with r3/current =====

manual164Compare = table();

if height(true164) > 0
    A164 = areaAudit(areaAudit.Bundle == 164, :);

    for i = 1:height(true164)
        zTrue = true164.z_from_A(i);
        qTrue = true164.q_from_B(i);

        if ~isfinite(zTrue) || ~isfinite(qTrue)
            continue;
        end

        % Match to nearest r3 DNB z_ratio for 164
        [dz, idx] = min(abs(A164.z_ratio - zTrue));
        if isempty(idx) || ~isfinite(dz)
            continue;
        end

        a = A164(idx, :);
        fManualInclusive = safeRatio(a.blue_area_inclusive, a.z_ratio * qTrue);
        fManualExact = safeRatio(a.blue_area_exact, a.z_ratio * qTrue);

        curMean = NaN;
        curN = 0;
        curZ = NaN;
        if height(currentFform) > 0
            C = currentFform(currentFform.Bundle == 164, :);
            if height(C) > 0
                dzc = abs(C.z_DNB_over_L_current - a.z_ratio);
                near = dzc < 0.015;
                if ~any(near)
                    [~, idxc] = min(dzc);
                    near = false(height(C),1);
                    near(idxc) = true;
                end
                curMean = mean(C.Fform_current(near), 'omitnan');
                curN = sum(isfinite(C.Fform_current(near)));
                curZ = mean(C.z_DNB_over_L_current(near), 'omitnan');
            end
        end

        row = table();
        row.Bundle = 164;
        row.manual_file = true164.file(i);
        row.manual_sheet = true164.sheet(i);
        row.manual_row = true164.row_in_sheet(i);
        row.true_flag_column = true164.true_col(i);
        row.true_flag_header = true164.true_header(i);
        row.z_manual_A = zTrue;
        row.q_manual_B = qTrue;
        row.matched_r3_z_ratio = a.z_ratio;
        row.match_abs_dz = abs(zTrue - a.z_ratio);
        row.blue_area_inclusive = a.blue_area_inclusive;
        row.blue_area_exact = a.blue_area_exact;
        row.orange_area_manual = a.z_ratio * qTrue;
        row.Fform_manual_inclusive = fManualInclusive;
        row.Fform_manual_exact = fManualExact;
        row.current_match_N = curN;
        row.current_z_mean = curZ;
        row.current_Fform_mean = curMean;
        row.diff_manual_inclusive_to_current = fManualInclusive - curMean;
        row.absdiff_manual_inclusive_to_current = abs(fManualInclusive - curMean);
        row.diff_manual_exact_to_current = fManualExact - curMean;
        row.absdiff_manual_exact_to_current = abs(fManualExact - curMean);

        if isfinite(row.absdiff_manual_inclusive_to_current)
            if row.absdiff_manual_inclusive_to_current < 1e-3
                row.match_status = "match_lt_1e-3";
            elseif row.absdiff_manual_inclusive_to_current < 1e-2
                row.match_status = "near_lt_1e-2";
            elseif row.absdiff_manual_inclusive_to_current < 5e-2
                row.match_status = "rough_lt_5e-2";
            else
                row.match_status = "diff_ge_5e-2";
            end
        else
            row.match_status = "not_compared";
        end

        manual164Compare = [manual164Compare; row]; %#ok<AGROW>
    end
end

%% ===== Read 108 workbook definitions/check values =====

if strlength(input108File) > 0 && isfile(input108File)
    info108 = scanWorkbookForKeywords(input108File, ["Blue_area","Orange_area","F_form","Fform","F_form_corrected","f_DNB","x_DNB"]);
else
    info108 = table();
end

%% ===== Candidate decision =====

decision = makeDecision(areaAudit, true164, manual164Compare, info108, currentFform);

%% ===== Proposed current_bundle_input_v2 fields =====

fieldsV2 = cell2table({
    "Fform_source_book", "バンドルデータ整理r3.xlsx / 164.xlsx / F_Form_108整理版.xlsx", "F_form作成元の追跡"
    "Fform_source_sheet", "非一様加熱を一様加熱に補正*, 02_xeq_recalc, 164.xlsx TRUE採用点", "F_form作成元シート"
    "Fform_DNB_z_ratio", "02_xeq_recalc z_ratio", "DNB位置 z/L"
    "Fform_blue_area", "r3 blue_area_inclusive", "DNB位置を含む区間まで足した青面積"
    "Fform_total_area", "r3 total_area", "全長積分面積"
    "Fform_z_heat_ratio", "blue_area / total_area", "r3 z_heat_ratio再現"
    "Fform_q_local_method", "manual_true / DNB直前点 / 線形補間 / 一様加熱", "オレンジ高さの決め方"
    "Fform_q_local_used", "採用したDNB局所出力", "オレンジ面積の高さ"
    "Fform_orange_area", "z_DNB * q_local_used", "オレンジ面積"
    "Fform_recalc", "blue_area / orange_area", "再計算F_form"
    "Fform_current", "current_bundle_input existing F_form", "既存F_form"
    "Fform_diff", "Fform_recalc - Fform_current", "差分"
    "Fform_match_status", "match/near/rough/diff/manual_check_required", "照合状態"
    "Fform_definition_note", "青面積inclusive、オレンジ高さは手作業採用点を優先", "定義メモ"
    "Fform_interpolation_method", "manual TRUE / linear interpolation / previous point / uniform", "補間方法"
    "Fform_stop_rule", "DNB位置を含む区間まで足す", "青面積側の止め方"
}, 'VariableNames', {'field','suggested_value_or_formula','meaning'});

%% ===== Write Excel =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(areaAudit, outXlsx, 'Sheet', 'A1b_area_audit_r3');
writetable(true164, outXlsx, 'Sheet', 'A1b_164_TRUE_points');
writetable(manual164Compare, outXlsx, 'Sheet', 'A1b_164_TRUE_compare');
writetable(info108, outXlsx, 'Sheet', 'A1b_108_keyword_scan');
writetable(currentFform, outXlsx, 'Sheet', 'A1b_current_Fform');
writetable(decision, outXlsx, 'Sheet', 'A1b_decision_flags');
writetable(fieldsV2, outXlsx, 'Sheet', 'A1b_fields_for_v2');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Write Markdown =====

md = strings(0,1);

md(end+1) = "# BT08-A1b F_form manual TRUE audit";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT08-A1で164の一部F_formが完全一致しなかったため、164.xlsxのTRUE採用点を優先してF_formを再計算する。108についてはF_Form_108整理版.xlsxから定義・計算値をキーワード抽出する。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- r3: `" + inputR3File + "`";
md(end+1) = "- 164 TRUE採用点ファイル: `" + nullText(input164File) + "`";
md(end+1) = "- 108: `" + nullText(input108File) + "`";
md(end+1) = "- current_bundle: `" + nullText(inputCurrentFile) + "`";
md(end+1) = "";
md(end+1) = "## 3. r3 area audit";
md(end+1) = "";
md(end+1) = tableToMarkdown(areaAudit);
md(end+1) = "";
md(end+1) = "## 4. 164 TRUE adopted points";
md(end+1) = "";
md(end+1) = tableToMarkdown(true164);
md(end+1) = "";
md(end+1) = "## 5. 164 TRUE comparison";
md(end+1) = "";
md(end+1) = tableToMarkdown(manual164Compare);
md(end+1) = "";
md(end+1) = "## 6. 108 keyword scan";
md(end+1) = "";
md(end+1) = tableToMarkdown(info108);
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
md(end+1) = "1. 164 TRUE採用点で既存F_formが再現できるか確認する。";
md(end+1) = "2. 再現できる場合、current_bundle_input_v2には q_local_method=manual_TRUE として残す。";
md(end+1) = "3. 再現できない場合、TRUE列の意味または採用列の読み方をユーザー確認する。";
md(end+1) = "4. 108はF_Form_108整理版の定義を優先し、DNB直前点ではなくx_DNB位置のf_DNBを用いた計算として記録する。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display quick result =====

disp("=== 164 TRUE adopted points ===");
disp(true164);

disp("=== 164 TRUE comparison ===");
disp(manual164Compare);

disp("=== decision ===");
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

function sheets = listSheets(file)
    try
        sheets = string(sheetnames(file));
    catch
        [~, rawSheets] = xlsfinfo(file);
        sheets = string(rawSheets);
    end
end

function P = readProfileSheet(file, sheetName, bundle)
    C = readcell(file, 'Sheet', sheetName);

    z = getNumericCol(C, 5);
    q = getNumericCol(C, 6);
    ok = isfinite(z) & isfinite(q) & z >= 0 & z <= 1.0000001;

    if sum(ok) < 3
        z = getNumericCol(C, 1);
        q = getNumericCol(C, 3);
        ok = isfinite(z) & isfinite(q) & z >= 0 & z <= 1.0000001;
        source_cols = "A/C";
    else
        source_cols = "E/F";
    end

    z = z(ok);
    q = q(ok);

    [z, idx] = sort(z);
    q = q(idx);

    [zu, ~, ic] = unique(z);
    qu = accumarray(ic, q, [], @mean);
    z = zu;
    q = qu;

    dz = [diff(z); NaN];
    q_next = [q(2:end); NaN];
    q_avg = (q + q_next) ./ 2;
    interval_area = q_avg .* dz;
    interval_area(~isfinite(interval_area)) = NaN;

    cum_area_exclusive = [0; cumsum(interval_area(1:end-1), 'omitnan')];
    cum_area_inclusive = cumsum(interval_area, 'omitnan');

    P = table();
    P.Bundle = repmat(bundle, numel(z), 1);
    P.profile_sheet = repmat(string(sheetName), numel(z), 1);
    P.source_cols = repmat(string(source_cols), numel(z), 1);
    P.point_index = (1:numel(z))';
    P.z = z;
    P.q_profile = q;
    P.dz_to_next = dz;
    P.q_next = q_next;
    P.q_interval_avg = q_avg;
    P.interval_area = interval_area;
    P.cum_area_exclusive = cum_area_exclusive;
    P.cum_area_inclusive = cum_area_inclusive;
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

function row = computeAreaAudit(P, bundle, zD)
    z = P.z;
    q = P.q_profile;

    intervalZ0 = z(1:end-1);
    intervalZ1 = z(2:end);
    intervalQ0 = q(1:end-1);
    intervalQ1 = q(2:end);
    intervalArea = (intervalQ0 + intervalQ1) ./ 2 .* (intervalZ1 - intervalZ0);
    totalArea = sum(intervalArea, 'omitnan');

    includeMask = intervalZ0 <= zD + 1e-10;
    blueInclusive = sum(intervalArea(includeMask), 'omitnan');

    blueExact = integrateExactToZ(z, q, zD);

    idxPrev = find(z <= zD + 1e-10, 1, 'last');
    idxNext = find(z >= zD - 1e-10, 1, 'first');

    if isempty(idxPrev); idxPrev = 1; end
    if isempty(idxNext); idxNext = numel(z); end

    zPrev = z(idxPrev);
    qPrev = q(idxPrev);
    zNext = z(idxNext);
    qNext = q(idxNext);

    qInterp = interp1(z, q, zD, 'linear', 'extrap');

    row = table();
    row.Bundle = bundle;
    row.z_ratio = zD;
    row.total_area = totalArea;
    row.blue_area_inclusive = blueInclusive;
    row.blue_area_exact = blueExact;
    row.z_heat_ratio_inclusive = safeRatio(blueInclusive, totalArea);
    row.z_heat_ratio_exact = safeRatio(blueExact, totalArea);
    row.z_prev = zPrev;
    row.q_local_prev = qPrev;
    row.z_next = zNext;
    row.q_local_next = qNext;
    row.q_local_interp = qInterp;
    row.orange_area_prev = qPrev * zD;
    row.orange_area_interp = qInterp * zD;
    row.Fform_prev_inclusive = safeRatio(blueInclusive, qPrev * zD);
    row.Fform_interp_inclusive = safeRatio(blueInclusive, qInterp * zD);
    row.Fform_prev_exact = safeRatio(blueExact, qPrev * zD);
    row.Fform_interp_exact = safeRatio(blueExact, qInterp * zD);
end

function val = integrateExactToZ(z, q, zD)
    val = 0;
    for i = 1:numel(z)-1
        z0 = z(i); z1 = z(i+1);
        q0 = q(i); q1 = q(i+1);

        if z0 >= zD
            break;
        end

        zz1 = min(z1, zD);
        if zz1 <= z0
            continue;
        end

        qq1 = q0 + (q1 - q0) * (zz1 - z0) / (z1 - z0);
        val = val + (q0 + qq1) / 2 * (zz1 - z0);

        if z1 >= zD
            break;
        end
    end
end

function T = readManualTruePoints164(file)
    sheets = listSheets(file);
    T = table();

    for s = sheets(:)'
        try
            C = readcell(file, 'Sheet', s);
        catch
            continue;
        end

        [nrow, ncol] = size(C);
        for i = 1:nrow
            zA = cellToDouble(C{i,1});
            qB = cellToDouble(C{i,2});

            if ~(isfinite(zA) && isfinite(qB))
                continue;
            end

            % A列は z または z_ratio と仮定。範囲は少し広め。
            if zA < 0 || zA > 1.2
                continue;
            end

            for j = 3:ncol
                if isTrueCell(C{i,j})
                    row = table();
                    row.file = string(file);
                    row.sheet = string(s);
                    row.row_in_sheet = i;
                    row.true_col = j;
                    row.true_header = getHeaderForColumn(C, j);
                    row.z_from_A = zA;
                    row.q_from_B = qB;
                    row.true_cell_value = cellToString(C{i,j});

                    % 周辺情報も拾う
                    row.left1 = valueCellSafe(C, i, max(1,j-1));
                    row.right1 = valueCellSafe(C, i, min(ncol,j+1));
                    row.note = "A列/B列の線形補間点で、同じ行のTRUE列を採用点として抽出";

                    T = [T; row]; %#ok<AGROW>
                end
            end
        end
    end
end

function h = getHeaderForColumn(C, col)
    h = "";
    for r = 1:min(10, size(C,1))
        s = cellToString(C{r,col});
        if strlength(strtrim(s)) > 0 && ~isTrueCell(C{r,col})
            h = s;
            return;
        end
    end
end

function tf = isTrueCell(x)
    if islogical(x) && isscalar(x)
        tf = x;
    elseif isnumeric(x) && isscalar(x)
        tf = (x == 1);
    elseif ischar(x) || isstring(x)
        ss = lower(strtrim(string(x)));
        tf = (ss == "true" || ss == "○" || ss == "採用" || ss == "use" || ss == "used");
    else
        tf = false;
    end
end

function s = valueCellSafe(C, r, c)
    if r < 1 || r > size(C,1) || c < 1 || c > size(C,2)
        s = "";
    else
        s = cellToString(C{r,c});
    end
end

function info = scanWorkbookForKeywords(file, keywords)
    sheets = listSheets(file);
    info = table();

    for sh = sheets(:)'
        try
            C = readcell(file, 'Sheet', sh);
        catch
            continue;
        end

        [nrow, ncol] = size(C);
        for i = 1:nrow
            for j = 1:ncol
                s = cellToString(C{i,j});
                if strlength(s) == 0
                    continue;
                end

                hit = false;
                hitKey = "";
                for k = string(keywords)
                    if contains(lower(s), lower(k))
                        hit = true;
                        hitKey = k;
                        break;
                    end
                end

                if hit
                    row = table();
                    row.file = string(file);
                    row.sheet = string(sh);
                    row.row_in_sheet = i;
                    row.col_in_sheet = j;
                    row.keyword = hitKey;
                    row.cell_text = s;
                    row.right1 = valueCellSafe(C, i, min(j+1,ncol));
                    row.right2 = valueCellSafe(C, i, min(j+2,ncol));
                    row.below1 = valueCellSafe(C, min(i+1,nrow), j);
                    row.below2 = valueCellSafe(C, min(i+2,nrow), j);
                    info = [info; row]; %#ok<AGROW>
                end
            end
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
        C.Fform_current = Fform(ok);
        C.z_DNB_over_L_current = zL(ok);
        C.z_DNB_over_DH_current = zDH(ok);

        currentFform = [currentFform; C]; %#ok<AGROW>
    end
end

function decision = makeDecision(areaAudit, true164, manual164Compare, info108, currentFform)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("BT08A1b_position", "OK", "", "164.xlsxのTRUE採用点を優先して、164のF_form再計算を確認する。");

    add("r3_blue_area", "OK", sprintf("rows=%d", height(areaAudit)), "青面積はr3由来のinclusive面積を使う。");

    add("164_true_points", "diagnostic", sprintf("N=%d", height(true164)), "164.xlsxからTRUE採用点を抽出した。");

    if height(manual164Compare) > 0
        minDiff = min(manual164Compare.absdiff_manual_inclusive_to_current, [], 'omitnan');
        add("164_manual_compare", "diagnostic", sprintf("min abs diff=%.6g", minDiff), "TRUE採用点を使ったF_formとcurrent F_formを照合した。");
    else
        add("164_manual_compare", "not_checked", "", "TRUE採用点またはcurrent Fformが不足し、照合できていない。");
    end

    add("108_keyword_scan", "diagnostic", sprintf("hits=%d", height(info108)), "F_Form_108整理版から定義・計算値に関するキーワード周辺を抽出した。");

    add("current_bundle_v2_policy", "next", "", "一致した定義と手作業判断をcurrent_bundle_input_v2へ列として集約する。");

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
