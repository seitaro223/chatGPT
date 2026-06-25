%% STF100_F1_fixed_audit_v1.m
% ST-F1-00: F1_fixed audit for single-tube T&M/BMI current data
%
% 目的:
%   F1_fixedを再フィットせず固定したまま、
%   その効き幅・張り付き・改善/悪化方向を監査する。
%
% r36で固定した前提:
%   F1_fixed(Tsub) = 1 + A * exp( - (Tsub - T0)^2 / sigma )
%   A     = 0.053
%   T0    = 40 [K]
%   sigma = 5625
%
% 重要:
%   F1_fixed >= 1 なので、計算値を上げる方向にしか働かない。
%   PM_noF1 > 1 の点では、誤差を悪化させる可能性がある。
%
% 入力:
%   H52Q_current_single_tube_input_v1_20260615_183839.xlsx
%
% 出力:
%   STF100_F1_fixed_audit_v1_yyyymmdd_HHMMSS.xlsx
%   run_report_STF100_F1_fixed_audit_v1_yyyymmdd_HHMMSS.md
%   fig_STF100_v1_*.png

clear; clc;

%% ===== User settings =====
inFile = "H52Q_current_single_tube_input_v1_20260615_183839.xlsx";

% F1_fixed coefficients
Acoef = 0.053;
T0 = 40.0;
sigma = 5625.0;

% Effective / sticking thresholds
thr_effect_001 = 0.001;  % F1-1 <= 0.001: almost no correction
thr_effect_005 = 0.005;
thr_effect_010 = 0.010;

if ~isfile(inFile)
    [f,p] = uigetfile("*.xlsx", "Select current_single_tube_input workbook");
    if isequal(f,0)
        error("Input file was not selected.");
    end
    inFile = fullfile(p,f);
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "STF100_F1_fixed_audit_v1_" + timestamp + ".xlsx";
outMd   = "run_report_STF100_F1_fixed_audit_v1_" + timestamp + ".md";

fig1 = "fig_STF100_v1_01_F1_fixed_vs_Tsub_" + timestamp + ".png";
fig2 = "fig_STF100_v1_02_PM_noF1_vs_PM_F1_" + timestamp + ".png";
fig3 = "fig_STF100_v1_03_abs_error_before_after_by_table_" + timestamp + ".png";
fig4 = "fig_STF100_v1_04_improve_worsen_by_table_" + timestamp + ".png";
fig5 = "fig_STF100_v1_05_F1_fixed_by_table_group_" + timestamp + ".png";

%% ===== Read sheets =====
sheets = sheetnames(inFile);

sheetNoF1 = chooseSheet(sheets, ["ST_noF1_T8_14_current","tm_r123_noF1_T8_14"], "nof1");
sheetF1   = chooseSheet(sheets, ["ST_F1_T8_14_current","tm_r124_F1_T8_14"], "f1");

fprintf("NoF1 sheet: %s\n", sheetNoF1);
fprintf("F1 sheet  : %s\n", sheetF1);

optsNo = detectImportOptions(inFile, "Sheet", sheetNoF1, "VariableNamingRule", "preserve");
optsF1 = detectImportOptions(inFile, "Sheet", sheetF1, "VariableNamingRule", "preserve");
TnoRaw = readtable(inFile, optsNo);
Tf1Raw = readtable(inFile, optsF1);

[Tno, metaNo] = buildSingleTubeTable(TnoRaw, sheetNoF1, "noF1");
[Tf1, metaF1] = buildSingleTubeTable(Tf1Raw, sheetF1, "F1");

%% ===== Pair rows =====
% Prefer original row_id pairing because current sheets preserve row order.
P = innerjoin(Tno, Tf1, "Keys", "row_id", ...
    "LeftVariables", ["row_id","TableNo","Tsub","LD_raw","LD_group","PM_noF1"], ...
    "RightVariables", ["TableNo","Tsub","LD_raw","LD_group","PM_F1","F_actual"]);

% Rename duplicate fields from join
P.Properties.VariableNames = matlab.lang.makeUniqueStrings(P.Properties.VariableNames);

% Resolve names robustly after join
tableNoCol = pickExisting(P.Properties.VariableNames, ["TableNo_Tno","TableNo_left","TableNo"]);
if tableNoCol == ""
    tableNoCol = pickExisting(P.Properties.VariableNames, ["TableNo"]);
end

% Manual clean because innerjoin names depend on MATLAB version
varsP = string(P.Properties.VariableNames);

% If join created TableNo_Tf1 etc., keep noF1-side as primary.
P.TableNo_use = pickVector(P, ["TableNo_Tno","TableNo_left","TableNo"]);
P.Tsub_noF1 = pickVector(P, ["Tsub_Tno","Tsub_left","Tsub"]);
P.Tsub_F1   = pickVector(P, ["Tsub_Tf1","Tsub_right","Tsub_1"]);
P.LD_noF1   = pickVector(P, ["LD_raw_Tno","LD_raw_left","LD_raw"]);
P.LD_F1     = pickVector(P, ["LD_raw_Tf1","LD_raw_right","LD_raw_1"]);
P.LD_group_use = string(pickTextVector(P, ["LD_group_Tno","LD_group_left","LD_group"]));
P.PM_noF1_use = pickVector(P, ["PM_noF1"]);
P.PM_F1_use   = pickVector(P, ["PM_F1"]);
P.F_actual_use = pickVectorOptional(P, ["F_actual"]);

% Consistency check columns
P.delta_Tsub_pair = P.Tsub_F1 - P.Tsub_noF1;
P.delta_LD_pair = P.LD_F1 - P.LD_noF1;

% Use F1-side Tsub as standard if available. Usually identical.
P.Tsub_use = P.Tsub_F1;
idxMissingTsub = ~isfinite(P.Tsub_use);
P.Tsub_use(idxMissingTsub) = P.Tsub_noF1(idxMissingTsub);

P.LD_use = P.LD_F1;
idxMissingLD = ~isfinite(P.LD_use);
P.LD_use(idxMissingLD) = P.LD_noF1(idxMissingLD);

% Final clean table
C = table;
C.row_id = P.row_id;
C.TableNo = round(P.TableNo_use);
C.Tsub = P.Tsub_use;
C.LD_raw = P.LD_use;
C.LD_group = P.LD_group_use;
C.PM_noF1 = P.PM_noF1_use;
C.PM_F1 = P.PM_F1_use;
C.F_actual = P.F_actual_use;
C.delta_Tsub_pair = P.delta_Tsub_pair;
C.delta_LD_pair = P.delta_LD_pair;

valid = isfinite(C.TableNo) & isfinite(C.Tsub) & isfinite(C.LD_raw) & ...
        isfinite(C.PM_noF1) & isfinite(C.PM_F1) & C.LD_group ~= "";
C = C(valid,:);

if height(C) == 0
    error("No paired valid rows. Check PM/Tsub/Table columns.");
end

%% ===== Compute F1_fixed and diagnostics =====
C.F1_fixed_calc = 1 + Acoef .* exp(-((C.Tsub - T0).^2) ./ sigma);
C.F1_minus_1 = C.F1_fixed_calc - 1;
C.F1_pct = 100 * C.F1_minus_1;

C.PM_lift_ratio = C.PM_F1 ./ C.PM_noF1;
C.PM_delta = C.PM_F1 - C.PM_noF1;

C.err_noF1 = C.PM_noF1 - 1;
C.err_F1 = C.PM_F1 - 1;
C.abs_err_noF1 = abs(C.err_noF1);
C.abs_err_F1 = abs(C.err_F1);
C.abs_err_delta = C.abs_err_F1 - C.abs_err_noF1; % negative = improved
C.improved = C.abs_err_F1 < C.abs_err_noF1 - 1e-12;
C.worsened = C.abs_err_F1 > C.abs_err_noF1 + 1e-12;
C.unchanged = ~(C.improved | C.worsened);

C.before_under = C.PM_noF1 < 1;
C.before_over = C.PM_noF1 > 1;
C.after_under = C.PM_F1 < 1;
C.after_over = C.PM_F1 > 1;

C.over_before_and_lifted = C.before_over & C.PM_delta > 0;
C.under_before_and_lifted = C.before_under & C.PM_delta > 0;

C.stick_001 = C.F1_minus_1 <= thr_effect_001;
C.stick_005 = C.F1_minus_1 <= thr_effect_005;
C.stick_010 = C.F1_minus_1 <= thr_effect_010;

C.Tsub_bin = makeTsubBins(C.Tsub);

% Compare actual F column if available
if any(isfinite(C.F_actual))
    C.F_actual_minus_calc = C.F_actual - C.F1_fixed_calc;
    C.F_actual_rel_diff_pct = 100 * C.F_actual_minus_calc ./ C.F1_fixed_calc;
else
    C.F_actual_minus_calc = nan(height(C),1);
    C.F_actual_rel_diff_pct = nan(height(C),1);
end

%% ===== Summaries =====
overall = summarizeGroup(C, "overall", repmat("all", height(C), 1));
byTable = summarizeGroup(C, "Table", "T" + string(C.TableNo));
byLDGroup = summarizeGroup(C, "LD_group", C.LD_group);
byTsubBin = summarizeGroup(C, "Tsub_bin", C.Tsub_bin);
byTableLD = summarizeGroup(C, "Table_LD_group", "T" + string(C.TableNo) + "_" + C.LD_group);
byTableTsubBin = summarizeGroup(C, "Table_Tsub_bin", "T" + string(C.TableNo) + "_" + C.Tsub_bin);

directionSummary = summarizeDirection(C);
fcorrConsistency = summarizeFcorrConsistency(C);

%% ===== Write workbook =====
writetable(C, outXlsx, "Sheet", "paired_rows");
writetable(overall, outXlsx, "Sheet", "overall_summary");
writetable(byTable, outXlsx, "Sheet", "by_table");
writetable(byLDGroup, outXlsx, "Sheet", "by_LD_group");
writetable(byTsubBin, outXlsx, "Sheet", "by_Tsub_bin");
writetable(byTableLD, outXlsx, "Sheet", "by_table_LD");
writetable(byTableTsubBin, outXlsx, "Sheet", "by_table_Tsubbin");
writetable(directionSummary, outXlsx, "Sheet", "direction_summary");
writetable(fcorrConsistency, outXlsx, "Sheet", "F_actual_check");

metaTbl = table;
metaTbl.item = ["input_file";"noF1_sheet";"F1_sheet";"A";"T0";"sigma";"NoF1_Table_col";"NoF1_PM_col";"NoF1_Tsub_col";"NoF1_LD_col";"F1_Table_col";"F1_PM_col";"F1_Tsub_col";"F1_LD_col";"F1_Factual_col"];
metaTbl.value = [string(inFile); string(sheetNoF1); string(sheetF1); string(Acoef); string(T0); string(sigma); ...
    string(metaNo.colTable); string(metaNo.colPM); string(metaNo.colTsub); string(metaNo.colLD); ...
    string(metaF1.colTable); string(metaF1.colPM); string(metaF1.colTsub); string(metaF1.colLD); string(metaF1.colFactual)];
writetable(metaTbl, outXlsx, "Sheet", "metadata");

%% ===== Figures =====
makeFigures(C, byTable, byTableLD, fig1, fig2, fig3, fig4, fig5);

%% ===== Markdown report =====
writeReport(outMd, inFile, sheetNoF1, sheetF1, metaNo, metaF1, ...
    Acoef, T0, sigma, C, overall, byTable, byLDGroup, byTsubBin, byTableLD, ...
    directionSummary, fcorrConsistency, fig1, fig2, fig3, fig4, fig5);

fprintf("\nDONE\n");
fprintf("Output xlsx: %s\n", outXlsx);
fprintf("Report md  : %s\n", outMd);
fprintf("Figures    : %s, %s, %s, %s, %s\n", fig1, fig2, fig3, fig4, fig5);

%% ========================================================================
%% Local functions
%% ========================================================================

function sheet = chooseSheet(sheets, preferred, mode)
    sheet = "";
    for s = string(preferred)
        idx = find(strcmpi(sheets, s), 1);
        if ~isempty(idx)
            sheet = string(sheets(idx));
            return;
        end
    end

    low = lower(string(sheets));
    if mode == "nof1"
        cand = string(sheets(contains(low,"nof1") | contains(low,"no_f1")));
    else
        cand = string(sheets(contains(low,"f1") & ~contains(low,"nof1") & ~contains(low,"no_f1")));
    end

    if isempty(cand)
        disp("Available sheets:");
        disp(sheets);
        error("Could not find %s sheet.", mode);
    end
    sheet = cand(1);
end

function [S, meta] = buildSingleTubeTable(Traw, sheetName, label)
    vars = string(Traw.Properties.VariableNames);
    varsNorm = normNames(vars);

    colTable = pickColumn(vars, varsNorm, ["No_TableNo","TableNo","Table_No","Table","TNo","Tbl","No"]);
    colPM    = pickColumn(vars, varsNorm, ["PM_ratio","PM_F1","PM_noF1","PMratio","P/M","P_M","PM"]);
    colTsub  = pickColumn(vars, varsNorm, ["Tsub","T_sub","Tsub_K","Subcooling","InletSubcooling","DeltaTsub"]);
    colLD    = pickColumn(vars, varsNorm, ["L_DNB","L/D","L_D","LD","LoverD","LbyD","L/DH","LDH","L_over_D"]);

    colBand = pickColumnOptional(vars, varsNorm, ["LD_group","LDgroup","L/D_group","LDBand","L/Dband","lengthband","band","group"]);

    % Actual F correction column, if it exists.
    % Do not use generic "F1" here because it may pick unintended columns.
    colFactual = pickColumnOptional(vars, varsNorm, ["補正式F","補正式Ｆ","Fcorr","F_corr","FCorrection","CorrectionF","F補正"]);

    if colTable == "" || colPM == "" || colTsub == "" || colLD == ""
        fprintf("\nAvailable variables in sheet %s:\n", sheetName);
        disp(vars');
        error("Missing required column in %s sheet.", label);
    end

    TableNo = parseTableNo(Traw.(colTable));
    PM = toNumeric(Traw.(colPM));
    Tsub = toNumeric(Traw.(colTsub));
    LD = toNumeric(Traw.(colLD));

    if colBand ~= ""
        LD_group = normalizeGroupLabels(string(Traw.(colBand)));
    else
        LD_group = makeLDGroups(LD);
    end

    Factual = nan(height(Traw),1);
    if colFactual ~= ""
        Factual = toNumeric(Traw.(colFactual));
    end

    S = table;
    S.row_id = (1:height(Traw))';
    S.TableNo = round(TableNo);
    S.Tsub = Tsub;
    S.LD_raw = LD;
    S.LD_group = LD_group;

    if label == "noF1"
        S.PM_noF1 = PM;
    else
        S.PM_F1 = PM;
        S.F_actual = Factual;
    end

    meta = struct;
    meta.sheet = string(sheetName);
    meta.colTable = string(colTable);
    meta.colPM = string(colPM);
    meta.colTsub = string(colTsub);
    meta.colLD = string(colLD);
    meta.colBand = string(colBand);
    meta.colFactual = string(colFactual);
end

function varsNorm = normNames(vars)
    varsNorm = lower(regexprep(string(vars), "[\s_\-/\(\)\[\]\.]", ""));
end

function col = pickColumn(vars, varsNorm, candidates)
    col = pickColumnOptional(vars, varsNorm, candidates);
end

function col = pickColumnOptional(vars, varsNorm, candidates)
    col = "";
    cand = string(candidates);
    candNorm = lower(regexprep(cand, "[\s_\-/\(\)\[\]\.]", ""));

    for c = candNorm
        idx = find(varsNorm == c, 1);
        if ~isempty(idx)
            col = vars(idx);
            return;
        end
    end

    for c = candNorm
        idx = find(contains(varsNorm, c), 1);
        if ~isempty(idx)
            col = vars(idx);
            return;
        end
    end
end

function x = toNumeric(v)
    if isnumeric(v)
        x = double(v);
    elseif islogical(v)
        x = double(v);
    else
        s = string(v);
        s = replace(s, ",", "");
        x = str2double(s);
    end
end

function tableNo = parseTableNo(v)
    if isnumeric(v)
        raw = double(v(:));
        tableNo = nan(size(raw));
        useDirect = ismember(round(raw), 8:14);
        tableNo(useDirect) = round(raw(useDirect));
        unresolved = isnan(tableNo);
        if any(unresolved)
            tableNo(unresolved) = parseTableNoFromString(string(raw(unresolved)));
        end
        return;
    end
    tableNo = parseTableNoFromString(string(v));
end

function out = parseTableNoFromString(s)
    out = nan(numel(s),1);
    for i = 1:numel(s)
        si = strtrim(s(i));
        tok = regexp(si, "(?i)(?:table|tbl|t)\s*[_\- ]*([0-9]{1,2})", "tokens", "once");
        if ~isempty(tok)
            val = str2double(tok{1});
            if ismember(val, 8:14)
                out(i) = val;
                continue;
            end
        end
        nums = regexp(si, "[0-9]+", "match");
        vals = str2double(nums);
        hit = vals(ismember(vals, 8:14));
        if ~isempty(hit)
            out(i) = hit(1);
        end
    end
end

function g = normalizeGroupLabels(raw)
    s = lower(strtrim(string(raw)));
    g = strings(size(s));

    g(contains(s,"short")) = "short";
    g(contains(s,"middle") | contains(s,"mid")) = "middle";
    g(contains(s,"long")) = "long";

    g(s == "s") = "short";
    g(s == "m") = "middle";
    g(s == "l") = "long";
end

function g = makeLDGroups(LD)
    g = strings(size(LD));
    x = LD(:);
    finite = isfinite(x);
    if ~any(finite)
        return;
    end

    ux = unique(round(x(finite),3));

    if numel(ux) <= 1
        g(finite) = "single";
        return;
    end

    % For current single-tube sheets, L_DNB is usually a few discrete lengths.
    if numel(ux) <= 6
        sorted = sort(ux);
        for i = 1:numel(sorted)
            if i == 1
                label = "short";
            elseif i == numel(sorted)
                label = "long";
            else
                label = "middle";
            end
            g(abs(round(x,3)-sorted(i)) < 1e-9) = label;
        end
        return;
    end

    q1 = quantile(x(finite), 1/3);
    q2 = quantile(x(finite), 2/3);
    g(finite & x <= q1) = "short";
    g(finite & x > q1 & x <= q2) = "middle";
    g(finite & x > q2) = "long";
end

function bins = makeTsubBins(Tsub)
    bins = strings(size(Tsub));
    bins(Tsub < 40) = "Tsub_lt_40";
    bins(Tsub >= 40 & Tsub < 80) = "Tsub_40_80";
    bins(Tsub >= 80 & Tsub < 120) = "Tsub_80_120";
    bins(Tsub >= 120 & Tsub < 160) = "Tsub_120_160";
    bins(Tsub >= 160 & Tsub < 220) = "Tsub_160_220";
    bins(Tsub >= 220) = "Tsub_ge_220";
    bins(~isfinite(Tsub)) = "";
end

function summary = summarizeGroup(C, groupType, groupLabels)
    g = string(groupLabels);
    groups = unique(g, "stable");
    summary = table;

    for i = 1:numel(groups)
        idx = g == groups(i);
        D = C(idx,:);
        row = summarizeOne(D);
        row.group_type = string(groupType);
        row.group = groups(i);
        summary = [summary; row]; %#ok<AGROW>
    end

    % Put group columns first
    summary = movevars(summary, ["group_type","group"], "Before", 1);
end

function row = summarizeOne(D)
    n = height(D);
    row = table;
    row.N = n;

    row.PM_noF1_mean = mean(D.PM_noF1,"omitnan");
    row.PM_F1_mean = mean(D.PM_F1,"omitnan");
    row.abs_err_noF1_mean = mean(D.abs_err_noF1,"omitnan");
    row.abs_err_F1_mean = mean(D.abs_err_F1,"omitnan");
    row.delta_abs_err_mean = mean(D.abs_err_delta,"omitnan");

    row.improved_N = sum(D.improved);
    row.worsened_N = sum(D.worsened);
    row.unchanged_N = sum(D.unchanged);
    row.improved_frac = row.improved_N / max(n,1);
    row.worsened_frac = row.worsened_N / max(n,1);

    row.before_under_N = sum(D.before_under);
    row.before_over_N = sum(D.before_over);
    row.before_under_improved_N = sum(D.before_under & D.improved);
    row.before_under_worsened_N = sum(D.before_under & D.worsened);
    row.before_over_improved_N = sum(D.before_over & D.improved);
    row.before_over_worsened_N = sum(D.before_over & D.worsened);

    row.over_before_and_lifted_N = sum(D.over_before_and_lifted);

    row.F1_fixed_mean = mean(D.F1_fixed_calc,"omitnan");
    row.F1_fixed_min = min(D.F1_fixed_calc,[],"omitnan");
    row.F1_fixed_max = max(D.F1_fixed_calc,[],"omitnan");
    row.F1_minus_1_mean = mean(D.F1_minus_1,"omitnan");
    row.F1_pct_mean = mean(D.F1_pct,"omitnan");

    row.stick_001_N = sum(D.stick_001);
    row.stick_005_N = sum(D.stick_005);
    row.stick_010_N = sum(D.stick_010);
    row.stick_001_frac = row.stick_001_N / max(n,1);
    row.stick_005_frac = row.stick_005_N / max(n,1);
    row.stick_010_frac = row.stick_010_N / max(n,1);

    row.Tsub_mean = mean(D.Tsub,"omitnan");
    row.Tsub_min = min(D.Tsub,[],"omitnan");
    row.Tsub_max = max(D.Tsub,[],"omitnan");
    row.LD_mean = mean(D.LD_raw,"omitnan");

    row.PM_lift_ratio_mean = mean(D.PM_lift_ratio,"omitnan");
    row.PM_delta_mean = mean(D.PM_delta,"omitnan");

    if any(isfinite(D.F_actual))
        row.F_actual_mean = mean(D.F_actual,"omitnan");
        row.F_actual_minus_calc_absmax = max(abs(D.F_actual_minus_calc),[],"omitnan");
        row.F_actual_minus_calc_mean = mean(D.F_actual_minus_calc,"omitnan");
    else
        row.F_actual_mean = NaN;
        row.F_actual_minus_calc_absmax = NaN;
        row.F_actual_minus_calc_mean = NaN;
    end
end

function directionSummary = summarizeDirection(C)
    labels = strings(height(C),1);
    labels(C.before_under) = "PM_noF1_under_1";
    labels(C.before_over) = "PM_noF1_over_1";
    labels(~C.before_under & ~C.before_over) = "PM_noF1_equal_1";
    directionSummary = summarizeGroup(C, "before_direction", labels);
end

function fcorrConsistency = summarizeFcorrConsistency(C)
    fcorrConsistency = table;
    if ~any(isfinite(C.F_actual))
        fcorrConsistency.note = "No actual F/Fcorr column found in F1 sheet.";
        return;
    end

    labels = "T" + string(C.TableNo);
    fcorrConsistency = summarizeGroup(C, "F_actual_by_table", labels);
end

function v = pickVector(T, candidates)
    vars = string(T.Properties.VariableNames);
    for c = string(candidates)
        idx = find(vars == c, 1);
        if ~isempty(idx)
            v = T.(vars(idx));
            return;
        end
    end
    % fallback contains
    for c = string(candidates)
        idx = find(contains(vars, c), 1);
        if ~isempty(idx)
            v = T.(vars(idx));
            return;
        end
    end
    error("Could not pick vector from candidates: %s", strjoin(string(candidates),", "));
end

function v = pickVectorOptional(T, candidates)
    vars = string(T.Properties.VariableNames);
    v = nan(height(T),1);
    for c = string(candidates)
        idx = find(vars == c, 1);
        if ~isempty(idx)
            v = T.(vars(idx));
            return;
        end
    end
end

function v = pickTextVector(T, candidates)
    vars = string(T.Properties.VariableNames);
    for c = string(candidates)
        idx = find(vars == c, 1);
        if ~isempty(idx)
            v = string(T.(vars(idx)));
            return;
        end
    end
    for c = string(candidates)
        idx = find(contains(vars, c), 1);
        if ~isempty(idx)
            v = string(T.(vars(idx)));
            return;
        end
    end
    v = repmat("", height(T), 1);
end

function name = pickExisting(varNames, candidates)
    name = "";
    vars = string(varNames);
    for c = string(candidates)
        if any(vars == c)
            name = c;
            return;
        end
    end
end

function makeFigures(C, byTable, byTableLD, fig1, fig2, fig3, fig4, fig5)
    % Fig1: F1_fixed vs Tsub
    f = figure("Color","w");
    hold on; grid on; box on;
    groups = unique(C.LD_group, "stable");
    for i = 1:numel(groups)
        idx = C.LD_group == groups(i);
        scatter(C.Tsub(idx), C.F1_fixed_calc(idx), 28, "filled", "DisplayName", groups(i));
    end
    xlabel("Tsub [K]");
    ylabel("F1 fixed [-]");
    title("ST-F1-00: F1 fixed vs Tsub");
    yline(1.001, "--", "F=1.001", "HandleVisibility","off");
    yline(1.005, "--", "F=1.005", "HandleVisibility","off");
    yline(1.010, "--", "F=1.010", "HandleVisibility","off");
    legend("Location","best");
    saveas(f, fig1);
    close(f);

    % Fig2: PM before/after
    f = figure("Color","w");
    hold on; grid on; box on;
    idxI = C.improved;
    idxW = C.worsened;
    idxU = C.unchanged;
    scatter(C.PM_noF1(idxI), C.PM_F1(idxI), 30, "filled", "DisplayName", "improved");
    scatter(C.PM_noF1(idxW), C.PM_F1(idxW), 30, "filled", "DisplayName", "worsened");
    scatter(C.PM_noF1(idxU), C.PM_F1(idxU), 30, "DisplayName", "unchanged");
    xline(1, "--", "HandleVisibility","off");
    yline(1, "--", "HandleVisibility","off");
    xlabel("PM noF1 [-]");
    ylabel("PM F1 [-]");
    title("PM before and after F1 fixed");
    legend("Location","best");
    saveas(f, fig2);
    close(f);

    % Fig3: abs error by table before/after
    Ttab = byTable(contains(byTable.group, "T"), :);
    f = figure("Color","w");
    X = categorical(Ttab.group);
    bar(X, [Ttab.abs_err_noF1_mean, Ttab.abs_err_F1_mean]);
    ylabel("Mean absolute error |PM-1|");
    title("Mean absolute error before/after by Table");
    legend(["noF1","F1"], "Location","best");
    grid on; box on;
    saveas(f, fig3);
    close(f);

    % Fig4: improve/worsen counts
    f = figure("Color","w");
    bar(X, [Ttab.improved_N, Ttab.worsened_N, Ttab.unchanged_N], "stacked");
    ylabel("Count");
    title("Improved / worsened / unchanged by Table");
    legend(["improved","worsened","unchanged"], "Location","best");
    grid on; box on;
    saveas(f, fig4);
    close(f);

    % Fig5: F1 fixed by table-LD group
    f = figure("Color","w");
    b = byTableLD;
    bar(categorical(b.group), b.F1_fixed_mean);
    ylabel("Mean F1 fixed [-]");
    title("F1 fixed mean by Table and L/D group");
    xtickangle(45);
    grid on; box on;
    saveas(f, fig5);
    close(f);
end

function writeReport(outMd, inFile, sheetNoF1, sheetF1, metaNo, metaF1, ...
    Acoef, T0, sigma, C, overall, byTable, byLDGroup, byTsubBin, byTableLD, ...
    directionSummary, fcorrConsistency, fig1, fig2, fig3, fig4, fig5)

    fid = fopen(outMd, "w");
    if fid < 0
        error("Cannot open markdown file.");
    end

    fprintf(fid, "# ST-F1-00 F1_fixed audit\n\n");
    fprintf(fid, "作成日時: %s\n\n", string(datetime("now","Format","yyyy-MM-dd HH:mm:ss")));

    fprintf(fid, "## 1. 目的\n\n");
    fprintf(fid, "F1_fixedを再フィットせず固定したまま、効き幅、張り付き、改善/悪化方向を監査する。\n\n");
    fprintf(fid, "F1_fixedは最適補正式ではなく、F1後残差診断のための固定基準として扱う。\n\n");

    fprintf(fid, "## 2. 入力\n\n");
    fprintf(fid, "- input_file: `%s`\n", string(inFile));
    fprintf(fid, "- noF1_sheet: `%s`\n", string(sheetNoF1));
    fprintf(fid, "- F1_sheet: `%s`\n\n", string(sheetF1));

    fprintf(fid, "### 2.1 読み取り列\n\n");
    fprintf(fid, "| item | noF1 | F1 |\n");
    fprintf(fid, "| --- | --- | --- |\n");
    fprintf(fid, "| Table | `%s` | `%s` |\n", string(metaNo.colTable), string(metaF1.colTable));
    fprintf(fid, "| PM | `%s` | `%s` |\n", string(metaNo.colPM), string(metaF1.colPM));
    fprintf(fid, "| Tsub | `%s` | `%s` |\n", string(metaNo.colTsub), string(metaF1.colTsub));
    fprintf(fid, "| L/D or L_DNB | `%s` | `%s` |\n", string(metaNo.colLD), string(metaF1.colLD));
    fprintf(fid, "| actual F column | - | `%s` |\n\n", string(metaF1.colFactual));

    fprintf(fid, "## 3. F1_fixed definition\n\n");
    fprintf(fid, "```text\n");
    fprintf(fid, "F1_fixed(Tsub) = 1 + A * exp( - (Tsub - T0)^2 / sigma )\n");
    fprintf(fid, "A     = %.8g\n", Acoef);
    fprintf(fid, "T0    = %.8g K\n", T0);
    fprintf(fid, "sigma = %.8g\n", sigma);
    fprintf(fid, "```\n\n");
    fprintf(fid, "この式は A > 0 のため常に F1_fixed >= 1 であり、計算値を上げる方向にしか補正できない。\n\n");

    fprintf(fid, "## 4. Overall summary\n\n");
    writeTableMd(fid, overall);

    fprintf(fid, "\n\n## 5. By Table\n\n");
    writeTableMd(fid, byTable);

    fprintf(fid, "\n\n## 6. By L/D group\n\n");
    writeTableMd(fid, byLDGroup);

    fprintf(fid, "\n\n## 7. By Tsub bin\n\n");
    writeTableMd(fid, byTsubBin);

    fprintf(fid, "\n\n## 8. By Table and L/D group\n\n");
    writeTableMd(fid, byTableLD);

    fprintf(fid, "\n\n## 9. Direction summary\n\n");
    writeTableMd(fid, directionSummary);

    fprintf(fid, "\n\n## 10. F_actual / Fcorr consistency check\n\n");
    writeTableMd(fid, fcorrConsistency);

    fprintf(fid, "\n\n## 11. Key automatic reading\n\n");
    N = height(C);
    improvedN = sum(C.improved);
    worsenedN = sum(C.worsened);
    beforeOverN = sum(C.before_over);
    beforeOverWorseN = sum(C.before_over & C.worsened);
    stick001N = sum(C.stick_001);
    stick005N = sum(C.stick_005);
    stick010N = sum(C.stick_010);

    fprintf(fid, "```text\n");
    fprintf(fid, "N = %d\n", N);
    fprintf(fid, "improved_N = %d\n", improvedN);
    fprintf(fid, "worsened_N = %d\n", worsenedN);
    fprintf(fid, "PM_noF1 > 1 points = %d\n", beforeOverN);
    fprintf(fid, "PM_noF1 > 1 and worsened points = %d\n", beforeOverWorseN);
    fprintf(fid, "F1-1 <= 0.001 points = %d\n", stick001N);
    fprintf(fid, "F1-1 <= 0.005 points = %d\n", stick005N);
    fprintf(fid, "F1-1 <= 0.010 points = %d\n", stick010N);
    fprintf(fid, "```\n\n");

    fprintf(fid, "読み方:\n\n");
    fprintf(fid, "```text\n");
    fprintf(fid, "- improved_N が多い場合でも、PM_noF1 > 1 の点で悪化していないかを必ず見る。\n");
    fprintf(fid, "- F1-1 <= 0.001 または 0.005 が多いTable/groupでは、F1_fixedは実質的に張り付いている。\n");
    fprintf(fid, "- Table11/12 long側でF1が張り付く場合、そこでの残差をF1が補正した結果とは読まない。\n");
    fprintf(fid, "- F1_fixedは片方向の持ち上げ補正であり、最適なTsub補正式ではない。\n");
    fprintf(fid, "```\n\n");

    fprintf(fid, "## 12. Figures\n\n");
    fprintf(fid, "- `%s`\n", fig1);
    fprintf(fid, "- `%s`\n", fig2);
    fprintf(fid, "- `%s`\n", fig3);
    fprintf(fid, "- `%s`\n", fig4);
    fprintf(fid, "- `%s`\n\n", fig5);

    fprintf(fid, "## 13. 次アクション\n\n");
    fprintf(fid, "```text\n");
    fprintf(fid, "1. overall_summary / by_table / by_LD_group / by_Tsub_binを確認する。\n");
    fprintf(fid, "2. F1_fixedがどのTsub領域で実質的に効いているか確認する。\n");
    fprintf(fid, "3. PM_noF1 > 1 の点でF1が悪化させていないか確認する。\n");
    fprintf(fid, "4. Table11/12 long側でF1が1に張り付いているか確認する。\n");
    fprintf(fid, "5. この結果を踏まえ、ST-LD-00を再解釈する。\n");
    fprintf(fid, "6. 判断をworking_log r37へ追記する。\n");
    fprintf(fid, "```\n");

    fclose(fid);
end

function writeTableMd(fid, T)
    if isempty(T)
        fprintf(fid, "_empty_\n");
        return;
    end

    vars = string(T.Properties.VariableNames);
    fprintf(fid, "| %s |\n", strjoin(vars, " | "));
    fprintf(fid, "| %s |\n", strjoin(repmat("---", size(vars)), " | "));

    for i = 1:height(T)
        vals = strings(1, numel(vars));
        for j = 1:numel(vars)
            v = T.(vars(j))(i);
            if isnumeric(v) || islogical(v)
                vals(j) = sprintf("%.6g", double(v));
            elseif isstring(v)
                vals(j) = v;
            elseif iscategorical(v)
                vals(j) = string(v);
            else
                vals(j) = string(v);
            end
            vals(j) = replace(vals(j), "|", "/");
        end
        fprintf(fid, "| %s |\n", strjoin(vals, " | "));
    end
end
