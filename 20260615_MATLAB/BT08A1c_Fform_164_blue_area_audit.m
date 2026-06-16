%% BT08A1c_Fform_164_blue_area_audit.m
% BT08-A1c：164r1.xlsx のA/B長尺線形補間表から Blue_area を再計算する
%
% 背景：
%   BT08-A1bでは、164r1.xlsx の TRUE 採用点から q_DNB は読めた。
%   112/168側は current F_form=1.014 をほぼ再現した。
%   しかし134/168側は、
%       q_DNB = 0.85217279
%       r3由来の blue_area_inclusive = 0.9101065
%   を使ったため、
%       F_form ≈ 1.339
%   となり、current F_form=1.363に届かなかった。
%
% ユーザー確認：
%   164通常ケースでは
%       Blue_area = 0.926529
%       x_DNB = 134/168 = 0.797619
%       f_DNB = 0.8521727906
%       Orange_area = x_DNB * f_DNB ≈ 0.679709
%       F_form = 0.926529 / 0.679709 ≈ 1.363
%
%   21_164 2点目では
%       Blue_area = 0.8596465
%       x_DNB = 112/168 = 0.666667
%       f_DNB = 1.2721009174
%       F_form ≈ 1.014
%
% 目的：
%   164r1.xlsx のA列/B列にある長尺線形補間表から、
%   入口から通常DNB位置まで積分して Blue_area=0.926529 を再現できるか確認する。
%
% 方針：
%   - 164r*.xlsx を優先して読む。
%   - A列=z, B列=f(z) の数値行を長尺線形補間表として読む。
%   - C列以降に TRUE / true / 採用 がある行を採用点として読む。
%   - z=0 のヘッダー誤検出は除外する。
%   - TRUE採用点ごとに、A/B表を使って 0→z_DNB まで台形積分する。
%   - ユーザー確認値 Blue_area=0.926529 / 0.8596465 と比較する。
%   - current_bundle_input の既存F_formとも照合する。
%
% 出力：
%   BT08A1c_Fform_164_blue_area_audit_yyyymmdd_HHMMSS.xlsx
%   run_report_BT08A1c_Fform_164_blue_area_audit_yyyymmdd_HHMMSS.md

clear; clc;

%% ===== Settings =====

input164File = "";
inputCurrentFile = "";

if strlength(input164File) == 0
    input164File = findLatestFileOptional("164r*.xlsx");
    if strlength(input164File) == 0
        input164File = findLatestFileOptional("164.xlsx");
    end
end

if strlength(inputCurrentFile) == 0
    inputCurrentFile = findLatestFileOptional("H52Q_current_bundle_input_v1_*.xlsx");
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));

outXlsx = "BT08A1c_Fform_164_blue_area_audit_" + timestamp + ".xlsx";
outMd   = "run_report_BT08A1c_Fform_164_blue_area_audit_" + timestamp + ".md";

fprintf("Input 164 file: %s\n", input164File);
fprintf("Optional current_bundle input: %s\n", nullText(inputCurrentFile));

%% ===== Read profile and TRUE points =====

profile = readBestABProfile(input164File);
truePtsRaw = readManualTruePoints164(input164File);

% z=0など、ヘッダー誤検出を除外
truePts = truePtsRaw(truePtsRaw.z_from_A > 0.05 & truePtsRaw.z_from_A <= 1.05, :);

% 同じ行で true と 採用 の2列を拾うことがあるので、z/qで重複排除
truePts = uniqueRowsByZQ(truePts);

%% ===== Read current F_form =====

if strlength(inputCurrentFile) > 0 && isfile(inputCurrentFile)
    currentFform = readCurrentBundleFform(inputCurrentFile);
    current164 = currentFform(currentFform.Bundle == 164, :);
else
    currentFform = table();
    current164 = table();
end

%% ===== Compute blue area from dense A/B table =====

audit = table();

for i = 1:height(truePts)
    zManual = truePts.z_from_A(i);
    qManual = truePts.q_from_B(i);

    % 近い代表DNB位置に丸める
    nominalCandidates = [112/168, 134/168];
    [~, idxNom] = min(abs(nominalCandidates - zManual));
    zNom = nominalCandidates(idxNom);

    if idxNom == 1
        userBlue = 0.8596465;
        userCase = "21_164_112in";
        currentExpected = 1.014;
    else
        userBlue = 0.926529;
        userCase = "normal_164_134in";
        currentExpected = 1.363;
    end

    % A/B長尺表から積分
    blueExactManualZ = integrateExactToZ(profile.z, profile.f, zManual);
    blueExactNominalZ = integrateExactToZ(profile.z, profile.f, zNom);

    % 念のため、z<=zDまでの単純trapzと、次点を含めるtrapzも出す
    blueTrapzLEManual = trapzToLastLE(profile.z, profile.f, zManual);
    blueTrapzIncludeNextManual = trapzIncludeNext(profile.z, profile.f, zManual);

    orangeManualZ = zManual * qManual;
    orangeNominalZ = zNom * qManual;

    fformExactManualZ = safeRatio(blueExactManualZ, orangeManualZ);
    fformExactNominalZ = safeRatio(blueExactNominalZ, orangeNominalZ);
    fformUserBlueManualZ = safeRatio(userBlue, orangeManualZ);
    fformUserBlueNominalZ = safeRatio(userBlue, orangeNominalZ);

    % current_bundleとの照合
    curMean = NaN; curN = 0; curZ = NaN;
    if height(current164) > 0
        dz = abs(current164.z_DNB_over_L_current - zNom);
        near = dz < 0.015;
        if ~any(near)
            [~, idxCur] = min(dz);
            near = false(height(current164), 1);
            near(idxCur) = true;
        end
        curMean = mean(current164.Fform_current(near), 'omitnan');
        curN = sum(isfinite(current164.Fform_current(near)));
        curZ = mean(current164.z_DNB_over_L_current(near), 'omitnan');
    end

    % current Fformから逆算される必要Blue_area
    if isfinite(curMean)
        blueNeededCurrentManualZ = curMean * orangeManualZ;
        blueNeededCurrentNominalZ = curMean * orangeNominalZ;
    else
        blueNeededCurrentManualZ = NaN;
        blueNeededCurrentNominalZ = NaN;
    end

    row = table();
    row.case_label = userCase;
    row.manual_file = truePts.file(i);
    row.manual_sheet = truePts.sheet(i);
    row.manual_row = truePts.row_in_sheet(i);
    row.true_col = truePts.true_col(i);
    row.true_header = truePts.true_header(i);
    row.z_manual = zManual;
    row.z_nominal = zNom;
    row.q_DNB_TRUE = qManual;
    row.profile_sheet = profile.sheet(1);
    row.profile_N = height(profile);
    row.blue_exact_manual_z = blueExactManualZ;
    row.blue_exact_nominal_z = blueExactNominalZ;
    row.blue_trapz_LE_manual_z = blueTrapzLEManual;
    row.blue_trapz_include_next_manual_z = blueTrapzIncludeNextManual;
    row.user_confirmed_blue_area = userBlue;
    row.diff_blue_exact_nominal_minus_user = blueExactNominalZ - userBlue;
    row.absdiff_blue_exact_nominal_minus_user = abs(blueExactNominalZ - userBlue);
    row.orange_manual_z = orangeManualZ;
    row.orange_nominal_z = orangeNominalZ;
    row.Fform_exact_manual_z = fformExactManualZ;
    row.Fform_exact_nominal_z = fformExactNominalZ;
    row.Fform_userblue_manual_z = fformUserBlueManualZ;
    row.Fform_userblue_nominal_z = fformUserBlueNominalZ;
    row.current_match_N = curN;
    row.current_z_mean = curZ;
    row.current_Fform_mean = curMean;
    row.current_expected_from_user = currentExpected;
    row.blue_needed_from_current_manual_z = blueNeededCurrentManualZ;
    row.blue_needed_from_current_nominal_z = blueNeededCurrentNominalZ;
    row.diff_userblue_to_needed_nominal = userBlue - blueNeededCurrentNominalZ;
    row.absdiff_userblue_to_needed_nominal = abs(userBlue - blueNeededCurrentNominalZ);
    row.diff_Fform_userblue_nominal_to_current = fformUserBlueNominalZ - curMean;
    row.absdiff_Fform_userblue_nominal_to_current = abs(fformUserBlueNominalZ - curMean);

    if isfinite(row.absdiff_Fform_userblue_nominal_to_current)
        if row.absdiff_Fform_userblue_nominal_to_current < 1e-3
            row.match_status = "match_lt_1e-3";
        elseif row.absdiff_Fform_userblue_nominal_to_current < 1e-2
            row.match_status = "near_lt_1e-2";
        elseif row.absdiff_Fform_userblue_nominal_to_current < 5e-2
            row.match_status = "rough_lt_5e-2";
        else
            row.match_status = "diff_ge_5e-2";
        end
    else
        row.match_status = "not_compared";
    end

    audit = [audit; row]; %#ok<AGROW>
end

%% ===== Decision flags =====

decision = makeDecision(profile, truePtsRaw, truePts, audit);

%% ===== Fields for current_bundle_input_v2 =====

fieldsV2 = cell2table({
    "Fform_source_book", "バンドルデータ整理r3.xlsx / 164r1.xlsx / F_Form_108整理版.xlsx", "F_form作成元の追跡"
    "Fform_case_label", "normal_164_134in / 21_164_112in / 108_70in / 108_76in / uniform_161", "DNB位置・ケース識別"
    "Fform_DNB_z_ratio", "x_DNB = DNB位置 / 加熱長", "DNB位置 z/L"
    "Fform_blue_area_source", "r3 inclusive or 164r1 dense-integral/user-confirmed", "青面積の出典"
    "Fform_blue_area", "0.926529 for 164 normal, 0.8596465 for 164 112in", "採用青面積"
    "Fform_q_DNB_source", "TRUE row in 164r1 A/B table or 108 f_DNB sheet", "オレンジ高さの出典"
    "Fform_q_DNB_used", "採用したf_DNB", "DNB位置局所係数"
    "Fform_orange_area", "x_DNB * f_DNB", "オレンジ面積"
    "Fform_recalc", "Fform_blue_area / Fform_orange_area", "再計算F_form"
    "Fform_current", "current_bundle_input existing F_form", "既存F_form"
    "Fform_diff", "Fform_recalc - Fform_current", "差分"
    "Fform_match_status", "match/near/rough/diff/manual_check_required", "照合状態"
    "Fform_definition_note", "青面積とオレンジ高さの作り方を文章で残す", "定義メモ"
    "Fform_interpolation_method", "manual TRUE / dense linear interpolation / user-confirmed blue area", "補間方法"
    "Fform_stop_rule", "case-dependent: inclusive / dense-integral to DNB / user-confirmed", "青面積側の止め方"
}, 'VariableNames', {'field','suggested_value_or_formula','meaning'});

%% ===== Write Excel =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(profile, outXlsx, 'Sheet', 'A1c_164_AB_profile');
writetable(truePtsRaw, outXlsx, 'Sheet', 'A1c_TRUE_points_raw');
writetable(truePts, outXlsx, 'Sheet', 'A1c_TRUE_points_valid');
writetable(audit, outXlsx, 'Sheet', 'A1c_blue_area_audit');
writetable(currentFform, outXlsx, 'Sheet', 'A1c_current_Fform');
writetable(decision, outXlsx, 'Sheet', 'A1c_decision_flags');
writetable(fieldsV2, outXlsx, 'Sheet', 'A1c_fields_for_v2');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Write Markdown =====

md = strings(0,1);

md(end+1) = "# BT08-A1c F_form 164 Blue_area audit";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "164r1.xlsxのA列/B列にある長尺線形補間表から、164通常ケースのBlue_area=0.926529を再現できるか確認する。あわせて112/168側のBlue_area=0.8596465も確認する。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- 164: `" + input164File + "`";
md(end+1) = "- current_bundle: `" + nullText(inputCurrentFile) + "`";
md(end+1) = "";
md(end+1) = "## 3. TRUE points valid";
md(end+1) = "";
md(end+1) = tableToMarkdown(truePts);
md(end+1) = "";
md(end+1) = "## 4. Blue area audit";
md(end+1) = "";
md(end+1) = tableToMarkdown(audit);
md(end+1) = "";
md(end+1) = "## 5. Decision flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(decision);
md(end+1) = "";
md(end+1) = "## 6. Fields for current_bundle_input_v2";
md(end+1) = "";
md(end+1) = tableToMarkdown(fieldsV2);
md(end+1) = "";
md(end+1) = "## 7. 次アクション";
md(end+1) = "";
md(end+1) = "1. 164通常ケースで Blue_area=0.926529 が再現またはユーザー確認値として整合するか確認する。";
md(end+1) = "2. 164の134/168側は q_DNB ではなく Blue_area 出典がズレの原因だった、という認識でよいか確認する。";
md(end+1) = "3. 112/168側は Blue_area=0.8596465、f_DNB=1.2721009174、F_form≈1.014 として確定する。";
md(end+1) = "4. 134/168側は Blue_area=0.926529、f_DNB=0.8521727906、F_form≈1.363 として確定する。";
md(end+1) = "5. 確定後、BT08-A2として current_bundle_input_v2 に必要列を集約する。";

fid = fopen(outMd, "w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display =====

disp("=== TRUE valid points ===");
disp(truePts);

disp("=== Blue area audit ===");
disp(audit);

disp("=== Decision ===");
disp(decision);

%% ===== Functions =====

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

function sheets = listSheets(file)
    try
        sheets = string(sheetnames(file));
    catch
        [~, rawSheets] = xlsfinfo(file);
        sheets = string(rawSheets);
    end
end

function profile = readBestABProfile(file)
    sheets = listSheets(file);
    best = table();
    bestSheet = "";
    bestN = -1;

    for sh = sheets(:)'
        try
            C = readcell(file, 'Sheet', sh);
        catch
            continue;
        end

        z = getNumericCol(C, 1);
        f = getNumericCol(C, 2);

        ok = isfinite(z) & isfinite(f) & z >= 0 & z <= 1.0000001;

        if sum(ok) > bestN
            bestN = sum(ok);
            bestSheet = sh;

            zz = z(ok);
            ff = f(ok);
            rowNo = find(ok);

            [zz, idx] = sort(zz);
            ff = ff(idx);
            rowNo = rowNo(idx);

            % 重複zは平均化。ただしrow情報は最初を残す。
            [zu, ~, ic] = unique(zz);
            fu = accumarray(ic, ff, [], @mean);
            ru = accumarray(ic, rowNo, [], @min);

            best = table();
            best.sheet = repmat(string(sh), numel(zu), 1);
            best.row_in_sheet = ru;
            best.z = zu;
            best.f = fu;
        end
    end

    if height(best) < 10
        error("Could not find a dense A/B profile in %s", file);
    end

    profile = best;
    fprintf("Best A/B profile sheet: %s, N=%d\n", bestSheet, height(profile));
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
                    row.left1 = valueCellSafe(C, i, max(1,j-1));
                    row.right1 = valueCellSafe(C, i, min(ncol,j+1));
                    row.note = "A列/B列の線形補間点で、同じ行のTRUE/採用列を抽出";
                    T = [T; row]; %#ok<AGROW>
                end
            end
        end
    end
end

function T2 = uniqueRowsByZQ(T)
    if height(T) == 0
        T2 = T;
        return;
    end

    zRound = round(T.z_from_A * 1e8) / 1e8;
    qRound = round(T.q_from_B * 1e8) / 1e8;
    key = string(zRound) + "_" + string(qRound);

    [~, ia] = unique(key, 'stable');
    T2 = T(ia, :);
end

function val = integrateExactToZ(z, f, zD)
    z = z(:);
    f = f(:);

    [z, idx] = sort(z);
    f = f(idx);

    % 範囲外対策
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

function val = trapzToLastLE(z, f, zD)
    ok = z <= zD + 1e-12;
    if sum(ok) < 2
        val = NaN;
    else
        val = trapz(z(ok), f(ok));
    end
end

function val = trapzIncludeNext(z, f, zD)
    idx = find(z <= zD + 1e-12);
    if isempty(idx)
        val = NaN;
        return;
    end
    last = idx(end);
    if last < numel(z)
        use = 1:(last+1);
    else
        use = 1:last;
    end
    if numel(use) < 2
        val = NaN;
    else
        val = trapz(z(use), f(use));
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

function decision = makeDecision(profile, truePtsRaw, truePts, audit)
    item = strings(0,1);
    status = strings(0,1);
    value = strings(0,1);
    reading = strings(0,1);

    add("profile_read", "OK", sprintf("N=%d, sheet=%s", height(profile), profile.sheet(1)), "164r1.xlsxのA/B長尺線形補間表を読んだ。");
    add("true_points_raw", "diagnostic", sprintf("N=%d", height(truePtsRaw)), "TRUE/採用セルを拾った。z=0などの誤検出を含む可能性がある。");
    add("true_points_valid", "OK", sprintf("N=%d", height(truePts)), "z>0.05で有効なTRUE採用点に絞った。");

    if height(audit) > 0
        % 134側と112側それぞれのuserBlue整合
        for i = 1:height(audit)
            add("audit_" + audit.case_label(i), audit.match_status(i), ...
                "Fform_userblue_nominal=" + string(sprintf("%.8g", audit.Fform_userblue_nominal_z(i))) + ...
                ", current=" + string(sprintf("%.8g", audit.current_Fform_mean(i))) + ...
                ", blue_exact_nominal=" + string(sprintf("%.8g", audit.blue_exact_nominal_z(i))) + ...
                ", user_blue=" + string(sprintf("%.8g", audit.user_confirmed_blue_area(i))), ...
                "ユーザー確認Blue_areaを使ったF_form照合。blue_exact_nominal_zとの差も確認する。");
        end
    end

    add("interpretation", "hold", "", "134/168側のズレはq_DNBではなくBlue_area出典の差として扱う。");
    add("next", "next", "", "確定後、current_bundle_input_v2にFform_blue_area_sourceとq_DNB_sourceを追加する。");

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

function s = valueCellSafe(C, r, c)
    if r < 1 || r > size(C,1) || c < 1 || c > size(C,2)
        s = "";
    else
        s = cellToString(C{r,c});
    end
end

function tf = isTrueCell(x)
    if islogical(x) && isscalar(x)
        tf = x;
    elseif isnumeric(x) && isscalar(x)
        tf = (x == 1);
    elseif ischar(x) || isstring(x)
        ss = lower(strtrim(string(x)));
        tf = (ss == "true" || ss == "ture" || ss == "○" || ss == "採用" || ss == "use" || ss == "used");
    else
        tf = false;
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
