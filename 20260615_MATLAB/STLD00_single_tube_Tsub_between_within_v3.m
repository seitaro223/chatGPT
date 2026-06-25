%% STLD00_single_tube_Tsub_between_within_v3.m
% ST-LD-00: single-tube PM_F1 vs Tsub between/within decomposition
%
% 目的:
%   単管F1後PM_F1に残るTsub相関を、
%   L/D group間差とgroup内Tsub傾きに分解する。
%
% 重要:
%   v1のエラー対策として、Table列を固定名で決め打ちしない。
%   全シートをスキャンし、Table9-12行が最も多く取れるシートを自動採用する。
%   No_TableNo / TableNo / Table などからTable番号をロバストに復元する。
%
% 入力候補:
%   H52Q_current_single_tube_input_v1_20260615_183839.xlsx
%
% 出力:
%   STLD00_single_tube_Tsub_between_within_v3_yyyymmdd_HHMMSS.xlsx
%   run_report_STLD00_single_tube_Tsub_between_within_v3_yyyymmdd_HHMMSS.md
%
% 判定:
%   group内Tsub傾きが小さい  -> ST-LD-01へ進む候補
%   group内Tsub傾きが残る    -> F1(Tsub)外挿取り残し疑い、ST-HSUB/ST-F1-refit優先

clear; clc;

%% ===== User settings =====
inFile = "H52Q_current_single_tube_input_v1_20260615_183839.xlsx";

if ~isfile(inFile)
    [f,p] = uigetfile("*.xlsx", "Select current_single_tube_input workbook");
    if isequal(f,0)
        error("Input file was not selected.");
    end
    inFile = fullfile(p,f);
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "STLD00_single_tube_Tsub_between_within_v3_" + timestamp + ".xlsx";
outMd   = "run_report_STLD00_single_tube_Tsub_between_within_v3_" + timestamp + ".md";

fig1 = "fig_STLD00_v3_01_PM_F1_vs_Tsub_by_LDgroup_" + timestamp + ".png";
fig2 = "fig_STLD00_v3_02_group_mean_PM_Tsub_LD_" + timestamp + ".png";
fig3 = "fig_STLD00_v3_03_within_PM_vs_within_Tsub_" + timestamp + ".png";
fig4 = "fig_STLD00_v3_04_model_R2_decomposition_" + timestamp + ".png";

targetTables_primary   = [9 10 11 12];
targetTables_reference = [8 9 10 11 12 13 14];

%% ===== Scan workbook and choose best sheet =====
sheets = sheetnames(inFile);
scan = table;
candidates = struct([]);

for si = 1:numel(sheets)
    sh = sheets(si);

    try
        opts = detectImportOptions(inFile, "Sheet", sh, "VariableNamingRule", "preserve");
        Traw = readtable(inFile, opts);
    catch ME
        row = table(string(sh), int32(0), int32(0), int32(0), string("read_error: " + ME.message), ...
            'VariableNames', {'sheet','n_rows','n_cols','primary_rows','status'});
        scan = [scan; row]; %#ok<AGROW>
        continue;
    end

    if height(Traw) < 5 || width(Traw) < 5
        row = table(string(sh), int32(height(Traw)), int32(width(Traw)), int32(0), string("too_small"), ...
            'VariableNames', {'sheet','n_rows','n_cols','primary_rows','status'});
        scan = [scan; row]; %#ok<AGROW>
        continue;
    end

    [ok, A, meta, msg] = tryBuildAnalysisTable(Traw, sh, targetTables_primary);
    if ok
        primaryRows = sum(ismember(A.TableNo, targetTables_primary));
        row = table(string(sh), int32(height(Traw)), int32(width(Traw)), int32(primaryRows), string("OK: " + msg), ...
            'VariableNames', {'sheet','n_rows','n_cols','primary_rows','status'});
        scan = [scan; row]; %#ok<AGROW>

        c.sheet = sh;
        c.A = A;
        c.meta = meta;
        c.primaryRows = primaryRows;
        candidates = [candidates; c]; %#ok<AGROW>
    else
        row = table(string(sh), int32(height(Traw)), int32(width(Traw)), int32(0), string("skip: " + msg), ...
            'VariableNames', {'sheet','n_rows','n_cols','primary_rows','status'});
        scan = [scan; row]; %#ok<AGROW>
    end
end

disp("=== Sheet scan summary ===");
disp(scan);

if isempty(candidates)
    error("No usable sheet found. Check that PM_F1/PM_ratio, Tsub, L/D and Table/No_TableNo columns exist.");
end

% Prefer F1 sheet over noF1 sheet.
% v2 sometimes selected ST_noF1_T8_14_current because it tied with ST_F1_T8_14_current
% in primary_rows. ST-LD-00 must use F1 data.
sheetNames = string({candidates.sheet});
isF1Sheet = contains(lower(sheetNames), "f1") & ~contains(lower(sheetNames), "nof1") & ~contains(lower(sheetNames), "no_f1");
if any(isF1Sheet)
    candIdx = find(isF1Sheet);
    [~,localBest] = max([candidates(candIdx).primaryRows]);
    bestIdx = candIdx(localBest);
else
    [~,bestIdx] = max([candidates.primaryRows]);
end
best = candidates(bestIdx);

if best.primaryRows == 0
    writetable(scan, "STLD00_v3_sheet_scan_failed_" + timestamp + ".xlsx", "Sheet", "sheet_scan");
    error("Primary target Table9-12 rows are zero in all usable sheets. Sheet scan was exported.");
end

if ~(contains(lower(string(best.sheet)), "f1") && ~contains(lower(string(best.sheet)), "nof1") && ~contains(lower(string(best.sheet)), "no_f1"))
    warning("Chosen sheet does not look like an F1 sheet: %s. Please confirm before interpreting.", string(best.sheet));
end

A = best.A;
meta = best.meta;
chosenSheet = string(best.sheet);

fprintf("\nChosen sheet: %s\n", chosenSheet);
fprintf("Primary Table9-12 rows: %d\n", best.primaryRows);
fprintf("Columns: table=%s, PM=%s, Tsub=%s, LD=%s\n", meta.colTable, meta.colPM, meta.colTsub, meta.colLD);

%% ===== Filter datasets =====
A.is_primary = ismember(A.TableNo, targetTables_primary);
A.is_reference = ismember(A.TableNo, targetTables_reference);

P = A(A.is_primary,:);
R = A(A.is_reference,:);

if height(P) == 0
    error("Primary target Table9-12 rows are zero after choosing best sheet. This should not happen.");
end

%% ===== Run decomposition =====
primary_result = analyzeDataset(P, "primary_Table9_12");
reference_result = analyzeDataset(R, "reference_Table8_14");

%% ===== Per-table decomposition =====
tableList = unique(P.TableNo);
perTableAll = table;
for i = 1:numel(tableList)
    Ti = P(P.TableNo == tableList(i),:);
    if height(Ti) >= 5
        ri = analyzeDataset(Ti, "Table" + string(tableList(i)));
        perTableAll = [perTableAll; ri.summary]; %#ok<AGROW>
    end
end

%% ===== Outputs =====
writetable(scan, outXlsx, "Sheet", "sheet_scan");
writetable(A, outXlsx, "Sheet", "clean_all_rows");
writetable(P, outXlsx, "Sheet", "primary_Table9_12");
writetable(R, outXlsx, "Sheet", "reference_Table8_14");
writetable(primary_result.summary, outXlsx, "Sheet", "primary_summary");
writetable(primary_result.groupStats, outXlsx, "Sheet", "primary_group_stats");
writetable(primary_result.groupSlopes, outXlsx, "Sheet", "primary_group_slopes");
writetable(primary_result.modelCompare, outXlsx, "Sheet", "primary_model_compare");
writetable(primary_result.withinData, outXlsx, "Sheet", "primary_within_data");
writetable(reference_result.summary, outXlsx, "Sheet", "reference_summary");
writetable(reference_result.groupStats, outXlsx, "Sheet", "reference_group_stats");
writetable(reference_result.groupSlopes, outXlsx, "Sheet", "reference_group_slopes");
writetable(reference_result.modelCompare, outXlsx, "Sheet", "reference_model_compare");
writetable(perTableAll, outXlsx, "Sheet", "per_table_summary");

%% ===== Figures =====
makeFigures(P, primary_result, fig1, fig2, fig3, fig4);

%% ===== Markdown report =====
writeReport(outMd, inFile, chosenSheet, meta, scan, primary_result, reference_result, perTableAll, fig1, fig2, fig3, fig4);

fprintf("\nDONE\n");
fprintf("Output xlsx: %s\n", outXlsx);
fprintf("Report md  : %s\n", outMd);
fprintf("Figures    : %s, %s, %s, %s\n", fig1, fig2, fig3, fig4);

%% ========================================================================
%% Local functions
%% ========================================================================

function [ok, A, meta, msg] = tryBuildAnalysisTable(Traw, sheetName, targetTables)
    ok = false;
    A = table;
    meta = struct;
    msg = "";

    vars = string(Traw.Properties.VariableNames);
    varsNorm = normNames(vars);

    colTable = pickColumn(vars, varsNorm, ["No_TableNo","TableNo","Table_No","Table","TNo","Tbl","No"]);
    colPM    = pickColumn(vars, varsNorm, ["PM_F1","PM_ratio","PMratio","P/M","P_M","PM","PMM"]);
    colTsub  = pickColumn(vars, varsNorm, ["Tsub","T_sub","Tsub_K","Subcooling","InletSubcooling","DeltaTsub"]);
    colLD    = pickColumn(vars, varsNorm, ["L/D","L_D","LD","LoverD","LbyD","L/DH","LDH","L_over_D"]);

    % Optional
    colSource = pickColumnOptional(vars, varsNorm, ["source","src"]);
    colBand   = pickColumnOptional(vars, varsNorm, ["LD_group","LDgroup","L/D_group","LDBand","L/Dband","lengthband","band","group"]);

    if colTable == "" || colPM == "" || colTsub == "" || colLD == ""
        msg = "missing required column(s)";
        return;
    end

    TableNo = parseTableNo(Traw.(colTable));
    PM_F1   = toNumeric(Traw.(colPM));
    Tsub    = toNumeric(Traw.(colTsub));
    LD      = toNumeric(Traw.(colLD));

    Source = strings(height(Traw),1);
    if colSource ~= ""
        Source = string(Traw.(colSource));
    else
        Source(:) = "unknown";
    end

    if colBand ~= ""
        LD_group = normalizeGroupLabels(string(Traw.(colBand)));
    else
        LD_group = makeLDGroups(LD);
    end

    valid = isfinite(TableNo) & isfinite(PM_F1) & isfinite(Tsub) & isfinite(LD) & LD_group ~= "";
    A = table;
    A.row_id = (1:height(Traw))';
    A.sheet = repmat(string(sheetName), height(Traw), 1);
    A.TableNo = round(TableNo);
    A.Source = Source;
    A.PM_F1 = PM_F1;
    A.Tsub = Tsub;
    A.LD = LD;
    A.LD_group = LD_group;
    A = A(valid,:);

    primaryRows = sum(ismember(A.TableNo, targetTables));

    % 5行未満なら解析に不向き
    if height(A) < 5
        msg = "valid rows < 5";
        return;
    end

    meta.colTable = string(colTable);
    meta.colPM = string(colPM);
    meta.colTsub = string(colTsub);
    meta.colLD = string(colLD);
    meta.colBand = string(colBand);
    meta.colSource = string(colSource);
    meta.primaryRows = primaryRows;
    ok = true;
    msg = "valid rows=" + string(height(A)) + ", primary rows=" + string(primaryRows);
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

    % exact normalized match
    for c = candNorm
        idx = find(varsNorm == c, 1);
        if ~isempty(idx)
            col = vars(idx);
            return;
        end
    end

    % contains normalized match
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
    n = numel(v);
    tableNo = nan(n,1);

    % Numeric direct
    if isnumeric(v)
        raw = double(v(:));
        direct = raw;
        direct(raw < 0) = NaN;
        direct(round(direct) ~= direct) = NaN;

        % 8〜14が直接入っている場合
        useDirect = ismember(round(direct), 8:14);
        tableNo(useDirect) = round(direct(useDirect));

        % 残りは文字列化して抽出を試す
        unresolved = isnan(tableNo);
        if any(unresolved)
            s = string(raw(unresolved));
            tableNo(unresolved) = parseTableNoFromString(s);
        end
        return;
    end

    tableNo = parseTableNoFromString(string(v));
end

function out = parseTableNoFromString(s)
    out = nan(numel(s),1);

    for i = 1:numel(s)
        si = strtrim(s(i));

        % table10, T10, Table_10 など
        tok = regexp(si, "(?i)(?:table|tbl|t)\s*[_\- ]*([0-9]{1,2})", "tokens", "once");
        if ~isempty(tok)
            val = str2double(tok{1});
            if ismember(val, 8:14)
                out(i) = val;
                continue;
            end
        end

        % 区切り文字つき： 10_003, 003_10, No10_Table12 など
        nums = regexp(si, "[0-9]+", "match");
        vals = str2double(nums);

        hit = vals(ismember(vals, 8:14));
        if ~isempty(hit)
            out(i) = hit(1);
            continue;
        end

        % 一つの数値だけで 9,10,11,12 の場合
        if numel(vals) == 1 && ismember(vals(1), 8:14)
            out(i) = vals(1);
            continue;
        end
    end
end

function g = normalizeGroupLabels(raw)
    s = lower(strtrim(string(raw)));
    g = strings(size(s));

    g(contains(s,"short")) = "short";
    g(contains(s,"middle") | contains(s,"mid")) = "middle";
    g(contains(s,"long")) = "long";

    % s/m/l だけの表記にも対応。ただし空欄は無視。
    g(s == "s") = "short";
    g(s == "m") = "middle";
    g(s == "l") = "long";

    % 数値・その他はLD値側で作るべきなので空のまま
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

    % LD値が少数の離散値なら、順位で short/middle/long
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

    % 連続値なら三分位
    q1 = quantile(x(finite), 1/3);
    q2 = quantile(x(finite), 2/3);
    g(finite & x <= q1) = "short";
    g(finite & x > q1 & x <= q2) = "middle";
    g(finite & x > q2) = "long";
end

function result = analyzeDataset(D, label)
    D = D(isfinite(D.PM_F1) & isfinite(D.Tsub) & isfinite(D.LD) & D.LD_group ~= "", :);
    n = height(D);

    [r2_tsub, slope_tsub, ~] = linRegR2(D.Tsub, D.PM_F1);
    [r2_ld, slope_ld, ~] = linRegR2(D.LD, D.PM_F1);

    groups = unique(D.LD_group, "stable");
    groupStats = table;
    withinData = D;
    withinData.PM_within = nan(height(D),1);
    withinData.Tsub_within = nan(height(D),1);
    withinData.LD_within = nan(height(D),1);

    for i = 1:numel(groups)
        idx = D.LD_group == groups(i);
        pm = D.PM_F1(idx);
        ts = D.Tsub(idx);
        ld = D.LD(idx);

        row = table;
        row.dataset = string(label);
        row.LD_group = groups(i);
        row.N = sum(idx);
        row.PM_mean = mean(pm,"omitnan");
        row.PM_sd = std(pm,"omitnan");
        row.PM_se = row.PM_sd / sqrt(max(row.N,1));
        row.Tsub_mean = mean(ts,"omitnan");
        row.Tsub_sd = std(ts,"omitnan");
        row.LD_mean = mean(ld,"omitnan");
        row.LD_sd = std(ld,"omitnan");
        groupStats = [groupStats; row]; %#ok<AGROW>

        withinData.PM_within(idx) = pm - row.PM_mean;
        withinData.Tsub_within(idx) = ts - row.Tsub_mean;
        withinData.LD_within(idx) = ld - row.LD_mean;
    end

    groupSlopes = table;
    for i = 1:numel(groups)
        Di = D(D.LD_group == groups(i),:);
        row = table;
        row.dataset = string(label);
        row.LD_group = groups(i);
        row.N = height(Di);
        if height(Di) >= 3 && numel(unique(Di.Tsub)) >= 2
            [r2i, slopei, inti] = linRegR2(Di.Tsub, Di.PM_F1);
            row.R2_PM_Tsub = r2i;
            row.slope_PM_per_K = slopei;
            row.slope_PM_per_100K = slopei * 100;
            row.intercept = inti;
        else
            row.R2_PM_Tsub = NaN;
            row.slope_PM_per_K = NaN;
            row.slope_PM_per_100K = NaN;
            row.intercept = NaN;
        end
        groupSlopes = [groupSlopes; row]; %#ok<AGROW>
    end

    if height(groupStats) >= 2
        [r2_between_tsub, slope_between_tsub, ~] = linRegR2(groupStats.Tsub_mean, groupStats.PM_mean);
        [r2_between_ld, slope_between_ld, ~] = linRegR2(groupStats.LD_mean, groupStats.PM_mean);
    else
        r2_between_tsub = NaN; slope_between_tsub = NaN;
        r2_between_ld = NaN; slope_between_ld = NaN;
    end

    [r2_within_tsub, slope_within_tsub, ~] = linRegR2(withinData.Tsub_within, withinData.PM_within);
    [r2_within_ld, slope_within_ld, ~] = linRegR2(withinData.LD_within, withinData.PM_within);

    y = D.PM_F1;
    X_tsub = [ones(n,1), D.Tsub];
    X_ld = [ones(n,1), D.LD];
    X_group = designGroup(D.LD_group);
    X_group_tsubWithin = [X_group, withinData.Tsub_within];
    X_group_ldWithin = [X_group, withinData.LD_within];
    X_group_tsub = [X_group, D.Tsub];

    modelCompare = table;
    modelCompare = addModelRow(modelCompare, label, "PM ~ Tsub", y, X_tsub);
    modelCompare = addModelRow(modelCompare, label, "PM ~ L/D", y, X_ld);
    modelCompare = addModelRow(modelCompare, label, "PM ~ LD_group", y, X_group);
    modelCompare = addModelRow(modelCompare, label, "PM ~ LD_group + Tsub_within", y, X_group_tsubWithin);
    modelCompare = addModelRow(modelCompare, label, "PM ~ LD_group + LD_within", y, X_group_ldWithin);
    modelCompare = addModelRow(modelCompare, label, "PM ~ LD_group + raw_Tsub", y, X_group_tsub);

    r2_group = getModelR2(modelCompare, "PM ~ LD_group");
    r2_group_tsubWithin = getModelR2(modelCompare, "PM ~ LD_group + Tsub_within");
    deltaR2_withinTsub_afterGroup = r2_group_tsubWithin - r2_group;

    if isnan(deltaR2_withinTsub_afterGroup)
        flag = "CHECK_MANUALLY";
        reading = "group分解の判定不能。";
    elseif deltaR2_withinTsub_afterGroup <= 0.05 && abs(slope_within_tsub*100) <= 0.10
        flag = "ST_LD01_OK_CANDIDATE";
        reading = "群内Tsub効果は小さめ。PM_F1のTsub相関は群間差由来の可能性。ST-LD-01へ進む候補。";
    elseif deltaR2_withinTsub_afterGroup >= 0.10 || abs(slope_within_tsub*100) >= 0.20
        flag = "CHECK_F1_EXTRAPOLATION";
        reading = "群内Tsub効果が残る可能性。L/D補正式前にST-HSUBまたはF1再フィット検討。";
    else
        flag = "BORDERLINE";
        reading = "群内Tsub効果は中間的。図とTable別結果を見て判断。";
    end

    summary = table;
    summary.dataset = string(label);
    summary.N = n;
    summary.R2_PM_Tsub_all = r2_tsub;
    summary.slope_PM_Tsub_per_100K_all = slope_tsub * 100;
    summary.R2_PM_LD_all = r2_ld;
    summary.slope_PM_LD_all = slope_ld;
    summary.R2_between_groupMeanPM_groupMeanTsub = r2_between_tsub;
    summary.slope_between_PM_per_100K = slope_between_tsub * 100;
    summary.R2_between_groupMeanPM_groupMeanLD = r2_between_ld;
    summary.slope_between_PM_per_LD = slope_between_ld;
    summary.R2_within_PMwithin_Tsubwithin = r2_within_tsub;
    summary.slope_within_PM_per_100K = slope_within_tsub * 100;
    summary.R2_within_PMwithin_LDwithin = r2_within_ld;
    summary.slope_within_PM_per_LD = slope_within_ld;
    summary.R2_group_only = r2_group;
    summary.R2_group_plus_Tsub_within = r2_group_tsubWithin;
    summary.delta_R2_Tsub_within_after_group = deltaR2_withinTsub_afterGroup;
    summary.tentative_flag = string(flag);
    summary.reading = string(reading);

    result = struct;
    result.summary = summary;
    result.groupStats = groupStats;
    result.groupSlopes = groupSlopes;
    result.modelCompare = modelCompare;
    result.withinData = withinData;
end

function r2 = getModelR2(modelCompare, modelName)
    idx = modelCompare.model == string(modelName);
    if any(idx)
        r2 = modelCompare.R2(find(idx,1));
    else
        r2 = NaN;
    end
end

function X = designGroup(g)
    groups = unique(g, "stable");
    n = numel(g);
    X = ones(n,1);
    for i = 2:numel(groups)
        X = [X, double(g == groups(i))]; %#ok<AGROW>
    end
end

function tbl = addModelRow(tbl, dataset, modelName, y, X)
    [r2, rmse, k] = olsR2(y, X);
    row = table;
    row.dataset = string(dataset);
    row.model = string(modelName);
    row.N = numel(y);
    row.k = k;
    row.R2 = r2;
    row.RMSE = rmse;
    tbl = [tbl; row];
end

function [r2, slope, intercept] = linRegR2(x,y)
    ok = isfinite(x) & isfinite(y);
    x = x(ok); y = y(ok);
    if numel(x) < 3 || numel(unique(x)) < 2
        r2 = NaN; slope = NaN; intercept = NaN;
        return;
    end
    X = [ones(numel(x),1), x(:)];
    if rank(X) < size(X,2)
        r2 = NaN; slope = NaN; intercept = NaN;
        return;
    end
    b = X \ y(:);
    yhat = X*b;
    ssRes = sum((y(:)-yhat).^2);
    ssTot = sum((y(:)-mean(y(:))).^2);
    if ssTot == 0
        r2 = NaN;
    else
        r2 = 1 - ssRes/ssTot;
    end
    intercept = b(1);
    slope = b(2);
end

function [r2, rmse, k] = olsR2(y, X)
    ok = all(isfinite(X),2) & isfinite(y);
    y = y(ok);
    X = X(ok,:);
    k = rank(X);
    if numel(y) < k + 1
        r2 = NaN; rmse = NaN;
        return;
    end
    if rank(X) < size(X,2)
        r2 = NaN; rmse = NaN;
        return;
    end
    b = X \ y;
    yhat = X*b;
    ssRes = sum((y-yhat).^2);
    ssTot = sum((y-mean(y)).^2);
    if ssTot == 0
        r2 = NaN;
    else
        r2 = 1 - ssRes/ssTot;
    end
    rmse = sqrt(mean((y-yhat).^2));
end

function makeFigures(P, res, fig1, fig2, fig3, fig4)
    groups = unique(P.LD_group, "stable");

    f = figure("Color","w");
    hold on; grid on; box on;
    for i = 1:numel(groups)
        idx = P.LD_group == groups(i);
        scatter(P.Tsub(idx), P.PM_F1(idx), 36, "filled", "DisplayName", groups(i));
    end
    yline(1, "--", "PM=1", "HandleVisibility","off");
    xlabel("Tsub [K]");
    ylabel("PM_F1 [-]");
    title("ST-LD-00 v3: PM_F1 vs Tsub by L/D group");
    legend("Location","best");
    saveas(f, fig1);
    close(f);

    gs = res.groupStats;
    f = figure("Color","w");
    yyaxis left;
    bar(categorical(gs.LD_group), gs.PM_mean);
    ylabel("PM_F1 mean [-]");
    yline(1, "--", "PM=1");
    yyaxis right;
    plot(categorical(gs.LD_group), gs.Tsub_mean, "o-", "LineWidth", 1.5);
    ylabel("Tsub mean [K]");
    title("Group means: PM_F1 and Tsub");
    grid on; box on;
    saveas(f, fig2);
    close(f);

    W = res.withinData;
    f = figure("Color","w");
    hold on; grid on; box on;
    for i = 1:numel(groups)
        idx = W.LD_group == groups(i);
        scatter(W.Tsub_within(idx), W.PM_within(idx), 36, "filled", "DisplayName", groups(i));
    end
    yline(0, "--", "HandleVisibility","off");
    xline(0, "--", "HandleVisibility","off");
    xlabel("Tsub within group [K]");
    ylabel("PM_F1 within group [-]");
    title("Within-group residual: PM_F1 vs Tsub");
    legend("Location","best");
    saveas(f, fig3);
    close(f);

    mc = res.modelCompare;
    f = figure("Color","w");
    bar(categorical(mc.model), mc.R2);
    ylabel("R^2");
    title("ST-LD-00 v3 model comparison");
    grid on; box on;
    xtickangle(30);
    saveas(f, fig4);
    close(f);
end

function writeReport(outMd, inFile, chosenSheet, meta, scan, primary, reference, perTableAll, fig1, fig2, fig3, fig4)
    fid = fopen(outMd, "w");
    if fid < 0
        error("Cannot open markdown file.");
    end

    fprintf(fid, "# ST-LD-00 v3 single-tube Tsub between/within decomposition\n\n");
    fprintf(fid, "作成日時: %s\n\n", string(datetime("now","Format","yyyy-MM-dd HH:mm:ss")));

    fprintf(fid, "## 1. 目的\n\n");
    fprintf(fid, "単管F1後PM_F1に残るTsub相関を、L/D group間差とgroup内Tsub傾きに分解する。\n\n");
    fprintf(fid, "ST-LD-01へ進む前の判定ゲートであり、補正式作成ではない。\n\n");

    fprintf(fid, "## 2. 入力と採用シート\n\n");
    fprintf(fid, "- input_file: `%s`\n", string(inFile));
    fprintf(fid, "- chosen_sheet: `%s`\n", string(chosenSheet));
    fprintf(fid, "- Table column: `%s`\n", string(meta.colTable));
    fprintf(fid, "- PM_F1 column: `%s`\n", string(meta.colPM));
    fprintf(fid, "- Tsub column: `%s`\n", string(meta.colTsub));
    fprintf(fid, "- L/D column: `%s`\n", string(meta.colLD));
    fprintf(fid, "- L/D band column: `%s`\n", string(meta.colBand));
    fprintf(fid, "- Source column: `%s`\n\n", string(meta.colSource));

    fprintf(fid, "## 3. Sheet scan\n\n");
    writeTableMd(fid, scan);

    fprintf(fid, "\n\n## 4. Primary result: Table9-12\n\n");
    writeTableMd(fid, primary.summary);

    fprintf(fid, "\n\n### 4.1 L/D group stats\n\n");
    writeTableMd(fid, primary.groupStats);

    fprintf(fid, "\n\n### 4.2 Group-wise PM_F1 vs Tsub slopes\n\n");
    writeTableMd(fid, primary.groupSlopes);

    fprintf(fid, "\n\n### 4.3 Model comparison\n\n");
    writeTableMd(fid, primary.modelCompare);

    fprintf(fid, "\n\n## 5. Reference result: Table8-14\n\n");
    writeTableMd(fid, reference.summary);

    fprintf(fid, "\n\n## 6. Per-table summary\n\n");
    if isempty(perTableAll)
        fprintf(fid, "_empty_\n");
    else
        writeTableMd(fid, perTableAll);
    end

    fprintf(fid, "\n\n## 7. 判断フラグ\n\n");
    flag = string(primary.summary.tentative_flag(1));
    reading = string(primary.summary.reading(1));
    fprintf(fid, "- tentative_flag: `%s`\n", flag);
    fprintf(fid, "- reading: %s\n\n", reading);

    fprintf(fid, "判定の読み方:\n\n");
    fprintf(fid, "```text\n");
    fprintf(fid, "ST_LD01_OK_CANDIDATE:\n");
    fprintf(fid, "  群内Tsub効果は小さめ。\n");
    fprintf(fid, "  PM_F1のTsub相関はshort/long群間差由来の可能性。\n");
    fprintf(fid, "  ST-LD-01へ進む候補。\n\n");
    fprintf(fid, "CHECK_F1_EXTRAPOLATION:\n");
    fprintf(fid, "  群内Tsub効果が残る可能性。\n");
    fprintf(fid, "  L/D補正式候補の前にST-HSUBまたはF1再フィットを検討。\n\n");
    fprintf(fid, "BORDERLINE:\n");
    fprintf(fid, "  中間的。図、Table別、群別傾きを見て判断。\n");
    fprintf(fid, "```\n\n");

    fprintf(fid, "## 8. Figures\n\n");
    fprintf(fid, "- `%s`\n", fig1);
    fprintf(fid, "- `%s`\n", fig2);
    fprintf(fid, "- `%s`\n", fig3);
    fprintf(fid, "- `%s`\n\n", fig4);

    fprintf(fid, "## 9. 次アクション\n\n");
    fprintf(fid, "```text\n");
    fprintf(fid, "1. primary_summary / primary_group_slopes / primary_model_compareを確認する。\n");
    fprintf(fid, "2. 群内Tsub傾きが小さければ、ST-LD-01へ進む。\n");
    fprintf(fid, "3. 群内Tsub傾きが残るなら、ST-HSUBまたはF1再フィット検討へ進む。\n");
    fprintf(fid, "4. 判断をworking_log r36へ追記する。\n");
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
            if isnumeric(v)
                vals(j) = sprintf("%.6g", v);
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
