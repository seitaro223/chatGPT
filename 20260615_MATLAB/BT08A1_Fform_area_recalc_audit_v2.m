%% BT08A1_Fform_area_recalc_audit_v2.m
% BT08-A1：バンドルデータ整理r3.xlsxを使ったF_form再計算監査
%
% 目的：
%   BT07では current_bundle_input 単体には軸方向出力分布の元配列が無く、
%   F_form = 青面積 / オレンジ面積 の再計算監査まではできなかった。
%
%   ただし、バンドルデータ整理r3.xlsx には、
%   「非一様加熱を一様加熱に補正108/161/164」シートがあり、
%   軸方向出力分布、DNB位置、DNB位置までの累積加熱比に相当する情報がある。
%
%   そこでBT08-A1では、まず r3 ブックだけを使って、
%   F_formの作成元に相当する面積計算を再現・監査する。
%
% 方針：
%   1. r3の非一様加熱補正シートから、z分布と軸方向出力分布を読む。
%   2. r3の02_xeq_recalcから、Bundle別のz_ratioおよびz_heat_ratioを読む。
%   3. DNB位置までの青面積を、複数の定義で再計算する。
%   4. オレンジ面積も、複数の局所出力定義で再計算する。
%   5. どの定義が既存F_formに近いかを、可能なら current_bundle_input と照合する。
%      ただし、ユーザーが手動で線形補間・DNB位置手前止め等を行っている可能性があるため、
%      完全自動判定ではなく、候補差分を出して人間判断できる形にする。
%   6. 目的を達成した後、current_bundle_input_v2へ集約すべき列を整理する。
%
% 重要：
%   - ここではまだ current_bundle_input を更新しない。
%   - 補正式は作らない。
%   - F1(Tsub)は維持する。
%   - F_formをF1の効き方として読まない。
%   - r3の面積計算を監査し、必要情報を後で current_bundle_input に集約する準備をする。
%
% 入力：
%   バンドルデータ整理r3.xlsx
%   任意：H52Q_current_bundle_input_v1_*.xlsx
%
% 出力：
%   BT08A1_Fform_area_recalc_audit_yyyymmdd_HHMMSS.xlsx
%   run_report_BT08A1_Fform_area_recalc_audit_yyyymmdd_HHMMSS.md
%
% 実行方法：
%   この .m ファイルを バンドルデータ整理r3.xlsx と同じフォルダに置いて実行する。
%   inputR3File を空文字 "" にしている場合は、最新の バンドルデータ整理r*.xlsx を自動探索する。

clear; clc;

%% ===== Settings =====

inputR3File = "";       % 空なら最新の バンドルデータ整理r*.xlsx を自動探索
inputCurrentFile = "";  % 空なら最新の H52Q_current_bundle_input_v1_*.xlsx を任意探索。無ければスキップ。

if strlength(inputR3File) == 0
    inputR3File = findLatestFile("バンドルデータ整理r*.xlsx");
end

if strlength(inputCurrentFile) == 0
    inputCurrentFile = findLatestFileOptional("H52Q_current_bundle_input_v1_*.xlsx");
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "BT08A1_Fform_area_recalc_audit_" + timestamp + ".xlsx";
outMd   = "run_report_BT08A1_Fform_area_recalc_audit_" + timestamp + ".md";

bundles = [108, 161, 164];

fprintf("Input r3 workbook: %s\n", inputR3File);
if strlength(inputCurrentFile) > 0
    fprintf("Optional current_bundle input: %s\n", inputCurrentFile);
else
    fprintf("Optional current_bundle input: not found. Current F_form comparison will be skipped.\n");
end

%% ===== Read r3 source =====

profilePoints = table();
qeqSheetValues = table();

for b = bundles
    shBase = "非一様加熱を一様加熱に補正" + string(b);
    sh = resolveSheetName(inputR3File, shBase);
    fprintf("Bundle %d profile sheet resolved: [%s]\n", b, sh);

    P = readProfileSheet(inputR3File, sh, b);
    profilePoints = [profilePoints; P]; %#ok<AGROW>

    Q = readQeqValues(inputR3File, sh, b);
    qeqSheetValues = [qeqSheetValues; Q]; %#ok<AGROW>
end

xeqSummary = readXeqSummary(inputR3File);

%% ===== Area audit =====

areaAudit = table();

for b = bundles
    P = profilePoints(profilePoints.Bundle == b, :);
    X = xeqSummary(xeqSummary.Bundle == b, :);

    if height(X) == 0
        warning("No z_ratio info found in 02_xeq_recalc for bundle %d", b);
        continue;
    end

    for i = 1:height(X)
        zD = X.z_ratio(i);
        row = computeAreaAudit(P, b, zD);
        row.z_heat_ratio_r3 = X.z_heat_ratio(i);
        row.z_heat_ratio_diff_inclusive_minus_r3 = row.z_heat_ratio_inclusive - row.z_heat_ratio_r3;
        row.xeq_note = X.note(i);
        areaAudit = [areaAudit; row]; %#ok<AGROW>
    end
end

%% ===== Optional comparison to current_bundle F_form =====

currentCompare = table();

if strlength(inputCurrentFile) > 0 && isfile(inputCurrentFile)
    currentFform = readCurrentBundleFform(inputCurrentFile);

    if height(currentFform) > 0
        currentCompare = compareCurrentToCandidates(currentFform, areaAudit);
    end
else
    currentFform = table();
end

%% ===== Candidate ranking =====

candidateRanking = makeCandidateRanking(areaAudit, currentCompare);

%% ===== Proposed fields for current_bundle_input_v2 =====

proposedFields = cell2table({
    "Fform_source_book", "バンドルデータ整理r3.xlsx", "F_form作成元ブック名"
    "Fform_source_sheet", "非一様加熱を一様加熱に補正108/161/164", "F_form作成元シート名"
    "Fform_source_z_profile_col", "E列またはA列", "z分布。BT08-A1ではE列を優先"
    "Fform_source_q_profile_col", "F列またはC列", "軸方向出力分布。BT08-A1ではF列を優先"
    "Fform_DNB_z_ratio", "02_xeq_recalc!z_ratio", "DNB位置のz/L"
    "Fform_blue_area_inclusive", "sum interval area where segment start z <= z_DNB", "r3のz_heat_ratioと整合する青面積候補"
    "Fform_blue_area_exact", "integral from 0 to z_DNB", "物理的にDNB位置までで切った青面積候補"
    "Fform_total_area", "full integral over 0<=z<=1", "全長積分面積"
    "Fform_z_heat_ratio", "blue_area_inclusive / total_area", "r3のz_heat_ratio確認用"
    "Fform_q_local_prev", "largest profile z <= z_DNB", "既存F_formに近い可能性がある局所出力候補"
    "Fform_q_local_interp", "linear interpolation at z_DNB", "物理的な局所出力候補"
    "Fform_orange_area_prev", "q_local_prev * z_DNB", "オレンジ面積候補"
    "Fform_orange_area_interp", "q_local_interp * z_DNB", "オレンジ面積候補"
    "Fform_recalc_prev_inclusive", "blue_area_inclusive / orange_area_prev", "既存F_form照合候補"
    "Fform_recalc_interp_inclusive", "blue_area_inclusive / orange_area_interp", "補助候補"
    "Fform_recalc_interp_exact", "blue_area_exact / orange_area_interp", "補助候補"
    "Fform_recalc_status", "match/near/diff/not_checked", "current_bundle F_formとの照合結果"
}, 'VariableNames', {'field','suggested_value_or_formula','meaning'});

%% ===== Interpretation flags =====

flags = makeFlags(inputR3File, inputCurrentFile, profilePoints, xeqSummary, areaAudit, currentCompare, candidateRanking);

%% ===== Write Excel =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(profilePoints, outXlsx, 'Sheet', 'BT08_profile_points');
writetable(xeqSummary, outXlsx, 'Sheet', 'BT08_xeq_summary');
writetable(qeqSheetValues, outXlsx, 'Sheet', 'BT08_qeq_sheet_values');
writetable(areaAudit, outXlsx, 'Sheet', 'BT08_area_audit');
writetable(currentFform, outXlsx, 'Sheet', 'BT08_current_Fform_optional');
writetable(currentCompare, outXlsx, 'Sheet', 'BT08_current_compare');
writetable(candidateRanking, outXlsx, 'Sheet', 'BT08_candidate_ranking');
writetable(proposedFields, outXlsx, 'Sheet', 'BT08_fields_for_v2');
writetable(flags, outXlsx, 'Sheet', 'BT08_interpretation_flags');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Write Markdown report =====

md = strings(0,1);

md(end+1) = "# BT08-A1 F_form area recalculation audit";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT07では、current_bundle_input単体ではF_formの青面積/オレンジ面積を再計算できないことを確認した。一方、バンドルデータ整理r3.xlsxには、F_form作成元に相当する非一様加熱補正シートがある。BT08-A1では、まずr3だけを使ってF_form面積計算を再現・監査する。";
md(end+1) = "";
md(end+1) = "## 2. 入力と出力";
md(end+1) = "";
md(end+1) = "- 入力r3: `" + inputR3File + "`";
if strlength(inputCurrentFile) > 0
    md(end+1) = "- 任意照合current_bundle: `" + inputCurrentFile + "`";
else
    md(end+1) = "- 任意照合current_bundle: なし";
end
md(end+1) = "- 出力Excel: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 3. 前提";
md(end+1) = "";
md(end+1) = "- r3でまず試す。";
md(end+1) = "- 目的を達成したら、必要最小限の情報をcurrent_bundle_input_v2へ集約する。";
md(end+1) = "- この段階ではcurrent_bundle_inputを更新しない。";
md(end+1) = "- F_formはF1ではない。";
md(end+1) = "- 補正式は作らない。";
md(end+1) = "";
md(end+1) = "## 4. x_eq summary / DNB positions from r3";
md(end+1) = "";
md(end+1) = tableToMarkdown(xeqSummary);
md(end+1) = "";
md(end+1) = "## 5. Area audit";
md(end+1) = "";
md(end+1) = tableToMarkdown(areaAudit);
md(end+1) = "";
md(end+1) = "## 6. Optional current_bundle F_form comparison";
md(end+1) = "";
if height(currentCompare) > 0
    md(end+1) = tableToMarkdown(currentCompare);
else
    md(end+1) = "current_bundle_inputが見つからない、または照合に必要な列が不足していたため、照合はスキップした。";
end
md(end+1) = "";
md(end+1) = "## 7. Candidate ranking";
md(end+1) = "";
md(end+1) = tableToMarkdown(candidateRanking);
md(end+1) = "";
md(end+1) = "## 8. Proposed fields for current_bundle_input_v2";
md(end+1) = "";
md(end+1) = tableToMarkdown(proposedFields);
md(end+1) = "";
md(end+1) = "## 9. Interpretation flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(flags);
md(end+1) = "";
md(end+1) = "## 10. 次アクション";
md(end+1) = "";
md(end+1) = "1. BT08_area_auditで、r3のz_heat_ratioが再計算できているか確認する。";
md(end+1) = "2. current_bundle照合がある場合は、どのF_form候補が既存F_formに最も近いか確認する。";
md(end+1) = "3. 定義が固まったら、BT08-A2としてcurrent_bundle_input_v2へ必要最小限のF_form再現情報を集約する。";
md(end+1) = "4. 手動の線形補間・DNB位置手前止めが入っている場合は、その判断を Fform_definition_note / interpolation_method / stop_rule として残す。";
md(end+1) = "4. ただし、F_formを補正式候補にはしない。F_formは非一様加熱換算・DNB位置・軸方向出力分布の診断項として扱う。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display quick result =====

disp("=== BT08-A1 area audit ===");
disp(areaAudit(:, ["Bundle","z_ratio","z_heat_ratio_r3","z_heat_ratio_inclusive","z_heat_ratio_diff_inclusive_minus_r3","Fform_prev_inclusive","Fform_interp_inclusive","Fform_interp_exact"]));

disp("=== BT08-A1 candidate ranking ===");
disp(candidateRanking);

disp("=== BT08-A1 interpretation flags ===");
disp(flags);

%% ===== Local functions =====

function actualName = resolveSheetName(file, desiredName)
    % Resolve sheet name robustly.
    % In r3 workbook, for example, the 161 sheet has a trailing space:
    % "非一様加熱を一様加熱に補正161 ".
    % readcell(file,'Sheet',desiredName) fails unless the trailing space is included.
    desiredName = string(desiredName);

    try
        sheets = string(sheetnames(file));
    catch
        [~, rawSheets] = xlsfinfo(file);
        sheets = string(rawSheets);
    end

    % exact
    idx = find(sheets == desiredName, 1);
    if ~isempty(idx)
        actualName = sheets(idx);
        return;
    end

    % trimmed exact
    idx = find(strtrim(sheets) == strtrim(desiredName), 1);
    if ~isempty(idx)
        actualName = sheets(idx);
        return;
    end

    % contains fallback
    idx = find(contains(strtrim(sheets), strtrim(desiredName)), 1);
    if ~isempty(idx)
        actualName = sheets(idx);
        return;
    end

    fprintf("Available sheets:\n");
    disp(sheets(:));
    error("Sheet not found. desired=[%s]", desiredName);
end

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

function P = readProfileSheet(file, sheetName, bundle)
    C = readcell(file, 'Sheet', sheetName);

    % 優先：E/F列 = z, q profile
    % 代替：A/C列 = z, q profile
    z = getNumericCol(C, 5);
    q = getNumericCol(C, 6);

    ok = isfinite(z) & isfinite(q) & z >= 0 & z <= 1.0000001;
    z = z(ok);
    q = q(ok);

    if numel(z) < 3
        z = getNumericCol(C, 1);
        q = getNumericCol(C, 3);
        ok = isfinite(z) & isfinite(q) & z >= 0 & z <= 1.0000001;
        z = z(ok);
        q = q(ok);
        source_cols = "A/C";
    else
        source_cols = "E/F";
    end

    [z, idx] = sort(z);
    q = q(idx);

    % 重複zがあれば平均化
    [zu, ~, ic] = unique(z);
    qu = accumarray(ic, q, [], @mean);

    z = zu;
    q = qu;

    % intervals
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

function Q = readQeqValues(file, sheetName, bundle)
    C = readcell(file, 'Sheet', sheetName);

    n = size(C,1);
    labels = strings(n,1);
    qeq = NaN(n,1);
    rowNum = (1:n)';

    for i = 1:n
        labels(i) = cellToString(C{i,11});
        qeq(i) = cellToDouble(C{i,12});
    end

    ok = isfinite(qeq) | strlength(strtrim(labels)) > 0;

    Q = table();
    Q.Bundle = repmat(bundle, sum(ok), 1);
    Q.profile_sheet = repmat(string(sheetName), sum(ok), 1);
    Q.row_in_sheet = rowNum(ok);
    Q.label_col_K = labels(ok);
    Q.qeq_col_L = qeq(ok);
end

function X = readXeqSummary(file)
    C = readcell(file, 'Sheet', '02_xeq_recalc');

    X = table();
    % locate first small summary table by row with Bundle, z_ratio, z_heat_ratio
    startRow = 0;
    for i = 1:size(C,1)
        rowStr = lower(strjoin(string(C(i,:)), "|"));
        if contains(rowStr, "bundle") && contains(rowStr, "z_ratio") && contains(rowStr, "z_heat_ratio")
            startRow = i + 1;
            break;
        end
    end

    if startRow == 0
        warning("02_xeq_recalc summary header not found.");
        return;
    end

    rows = [];
    for i = startRow:size(C,1)
        b = cellToDouble(C{i,1});
        zratio = cellToDouble(C{i,2});
        zheat = cellToDouble(C{i,5});
        if ~isfinite(b) || ~isfinite(zratio)
            if ~isempty(rows)
                break;
            else
                continue;
            end
        end
        rows = [rows; i]; %#ok<AGROW>
    end

    if isempty(rows)
        return;
    end

    X.Bundle = zeros(numel(rows),1);
    X.z_ratio = zeros(numel(rows),1);
    X.z_heat_ratio = NaN(numel(rows),1);
    X.note = strings(numel(rows),1);
    X.row_in_sheet = rows;

    for k = 1:numel(rows)
        i = rows(k);
        X.Bundle(k) = cellToDouble(C{i,1});
        X.z_ratio(k) = cellToDouble(C{i,2});
        X.z_heat_ratio(k) = cellToDouble(C{i,5});
        X.note(k) = cellToString(C{i,6});
    end
end

function row = computeAreaAudit(P, bundle, zD)
    z = P.z;
    q = P.q_profile;

    % Full interval areas
    intervalZ0 = z(1:end-1);
    intervalZ1 = z(2:end);
    intervalQ0 = q(1:end-1);
    intervalQ1 = q(2:end);
    intervalArea = (intervalQ0 + intervalQ1) ./ 2 .* (intervalZ1 - intervalZ0);
    totalArea = sum(intervalArea, 'omitnan');

    % r3 inclusive method:
    % 02_xeq_recalcのメモ「DNB位置を含む」に対応させるため、
    % 区間開始点 z0 <= zD の区間を足す。
    includeMask = intervalZ0 <= zD + 1e-10;
    blueInclusive = sum(intervalArea(includeMask), 'omitnan');

    % Exact method: 0 to zD with interpolation at zD
    blueExact = integrateExactToZ(z, q, zD);

    % Local q definitions
    idxPrev = find(z <= zD + 1e-10, 1, 'last');
    idxNext = find(z >= zD - 1e-10, 1, 'first');

    if isempty(idxPrev)
        idxPrev = 1;
    end
    if isempty(idxNext)
        idxNext = numel(z);
    end

    zPrev = z(idxPrev);
    qPrev = q(idxPrev);
    zNext = z(idxNext);
    qNext = q(idxNext);

    qInterp = interp1(z, q, zD, 'linear', 'extrap');
    qNearest = qPrev;
    if abs(zNext - zD) < abs(zPrev - zD)
        qNearest = qNext;
    end

    orangePrev = qPrev * zD;
    orangeInterp = qInterp * zD;
    orangeNearest = qNearest * zD;

    row = table();
    row.Bundle = bundle;
    row.z_ratio = zD;

    row.profile_z_min = min(z);
    row.profile_z_max = max(z);
    row.profile_N = numel(z);

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
    row.q_local_nearest = qNearest;

    row.orange_area_prev = orangePrev;
    row.orange_area_interp = orangeInterp;
    row.orange_area_nearest = orangeNearest;

    row.Fform_prev_inclusive = safeRatio(blueInclusive, orangePrev);
    row.Fform_interp_inclusive = safeRatio(blueInclusive, orangeInterp);
    row.Fform_nearest_inclusive = safeRatio(blueInclusive, orangeNearest);

    row.Fform_prev_exact = safeRatio(blueExact, orangePrev);
    row.Fform_interp_exact = safeRatio(blueExact, orangeInterp);
    row.Fform_nearest_exact = safeRatio(blueExact, orangeNearest);

    row.qeq_avg_inclusive = safeRatio(blueInclusive, zD);
    row.qeq_avg_exact = safeRatio(blueExact, zD);
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

function comp = compareCurrentToCandidates(currentFform, areaAudit)
    comp = table();

    for i = 1:height(areaAudit)
        b = areaAudit.Bundle(i);
        zD = areaAudit.z_ratio(i);

        C = currentFform(currentFform.Bundle == b, :);
        if height(C) == 0
            continue;
        end

        dz = abs(C.z_DNB_over_L_current - zD);
        near = dz < 0.015;  % currentの丸め・DNB位置差を許容
        if ~any(near)
            [~, idx] = min(dz);
            near = false(height(C),1);
            near(idx) = true;
        end

        fcur = C.Fform_current(near);
        curMean = mean(fcur, 'omitnan');
        curStd = std(fcur, 'omitnan');
        curN = sum(isfinite(fcur));

        candidates = [
            "Fform_prev_inclusive"
            "Fform_interp_inclusive"
            "Fform_nearest_inclusive"
            "Fform_prev_exact"
            "Fform_interp_exact"
            "Fform_nearest_exact"
        ];

        diffs = NaN(numel(candidates),1);
        values = NaN(numel(candidates),1);

        for k = 1:numel(candidates)
            values(k) = areaAudit.(candidates(k))(i);
            diffs(k) = abs(values(k) - curMean);
        end

        [bestDiff, bestIdx] = min(diffs);

        row = table();
        row.Bundle = b;
        row.z_ratio_r3 = zD;
        row.current_match_N = curN;
        row.current_z_mean = mean(C.z_DNB_over_L_current(near), 'omitnan');
        row.current_Fform_mean = curMean;
        row.current_Fform_sd = curStd;

        for k = 1:numel(candidates)
            row.(candidates(k)) = values(k);
            row.(candidates(k) + "_absdiff") = diffs(k);
        end

        row.best_candidate = candidates(bestIdx);
        row.best_absdiff = bestDiff;

        if bestDiff < 1e-3
            row.match_status = "match_lt_1e-3";
        elseif bestDiff < 1e-2
            row.match_status = "near_lt_1e-2";
        elseif bestDiff < 5e-2
            row.match_status = "rough_lt_5e-2";
        else
            row.match_status = "diff_ge_5e-2";
        end

        comp = [comp; row]; %#ok<AGROW>
    end
end

function R = makeCandidateRanking(areaAudit, currentCompare)
    candidates = [
        "Fform_prev_inclusive"
        "Fform_interp_inclusive"
        "Fform_nearest_inclusive"
        "Fform_prev_exact"
        "Fform_interp_exact"
        "Fform_nearest_exact"
    ];

    R = table();
    if height(currentCompare) == 0
        for k = 1:numel(candidates)
            row = table();
            row.candidate = candidates(k);
            row.N_compared = 0;
            row.MAE_to_current = NaN;
            row.max_absdiff_to_current = NaN;
            row.reading = "current_bundle照合なし。r3内でz_heat_ratio再現を確認する段階。";
            R = [R; row]; %#ok<AGROW>
        end
        return;
    end

    for k = 1:numel(candidates)
        c = candidates(k);
        diffName = c + "_absdiff";
        diffs = currentCompare.(diffName);
        ok = isfinite(diffs);

        row = table();
        row.candidate = c;
        row.N_compared = sum(ok);
        row.MAE_to_current = mean(diffs(ok), 'omitnan');
        row.max_absdiff_to_current = max(diffs(ok), [], 'omitnan');

        if row.MAE_to_current < 1e-3
            row.reading = "既存F_formと非常によく一致。current_bundle_input_v2へ集約する第一候補。";
        elseif row.MAE_to_current < 1e-2
            row.reading = "既存F_formと概ね一致。定義確認後に候補。";
        elseif row.MAE_to_current < 5e-2
            row.reading = "おおまかには近いが、DNB局所出力の取り方または区間含め方の確認が必要。";
        else
            row.reading = "既存F_formとの差が大きい。候補としては弱い。";
        end

        R = [R; row]; %#ok<AGROW>
    end

    R = sortrows(R, "MAE_to_current", "ascend");
end

function flags = makeFlags(inputR3File, inputCurrentFile, profilePoints, xeqSummary, areaAudit, currentCompare, candidateRanking)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("BT08A1_position", "OK", "", "r3でまずF_form面積再計算を監査する。current_bundle_input更新はまだ行わない。");

    add("r3_input", "OK", inputR3File, "バンドルデータ整理r3.xlsxをF_form作成元として扱う。");

    add("profile_sheets", "OK", sprintf("profile rows=%d", height(profilePoints)), "非一様加熱補正シートからz分布と軸方向出力分布を読んだ。");

    add("xeq_summary", "OK", sprintf("DNB positions=%d", height(xeqSummary)), "02_xeq_recalcからz_ratioとz_heat_ratioを読んだ。");

    maxZheatDiff = max(abs(areaAudit.z_heat_ratio_diff_inclusive_minus_r3), [], 'omitnan');
    add("z_heat_ratio_reproduction", "diagnostic", sprintf("max abs diff=%.6g", maxZheatDiff), "inclusive区間和でr3のz_heat_ratioを再現できるかの確認。小さければr3面積計算の再現性が高い。");

    if strlength(inputCurrentFile) > 0
        add("current_bundle_compare", "diagnostic", inputCurrentFile, "任意でcurrent_bundle_inputの既存F_formと照合した。");
    else
        add("current_bundle_compare", "skipped", "", "current_bundle_inputが見つからないため、既存F_formとの照合は未実施。");
    end

    if height(candidateRanking) > 0 && candidateRanking.N_compared(1) > 0
        add("best_candidate", "diagnostic", ...
            string(candidateRanking.candidate(1)) + ", MAE=" + string(sprintf("%.6g", candidateRanking.MAE_to_current(1))), ...
            "既存F_formに最も近い候補。採用前に定義の物理的意味を確認する。");
    else
        add("best_candidate", "not_checked", "", "current_bundle照合なし。まずr3内のz_heat_ratio再現を確認する。");
    end

    add("next_step", "next", "", "目的を達成したら、BT08-A2としてcurrent_bundle_input_v2に必要最小限のF_form再現情報を集約する。");

    flags = table(item, status, value, reading);

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
    s = replace(s, "σ", "sigma");
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
            val = T{i,j};
            row(j) = valueToString(val);
            row(j) = replace(row(j), "|", "/");
            row(j) = replace(row(j), newline, " ");
        end
        lines(end+1) = "| " + strjoin(row, " | ") + " |";
    end

    if height(T) > maxRows
        row = repmat("...", 1, numel(vars));
        lines(end+1) = "| " + strjoin(row, " | ") + " |";
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
            tmp = string(val(:)');
            s = strjoin(tmp, ",");
        end
    elseif isstring(val)
        if isempty(val)
            s = "";
        else
            s = strjoin(val(:)', ",");
        end
    elseif iscell(val)
        if isempty(val)
            s = "";
        else
            parts = strings(numel(val),1);
            for k = 1:numel(val)
                parts(k) = valueToString(val{k});
            end
            s = strjoin(parts, ",");
        end
    elseif islogical(val)
        if isscalar(val)
            s = string(val);
        else
            s = strjoin(string(val(:)'), ",");
        end
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
