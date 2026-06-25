%% T10R02_Table10_source01_lowX_F1TmTsat_classify_v1
% Purpose:
%   Audit T&M Table10 source01 low-quality candidates after T10R01c.
%   Separate old/legacy-like Table10 set, source01 low-X candidates, and
%   F1-after-only Tm>Tsat flags. This run DOES NOT decide adoption.
%
% Expected files in the same folder as this script:
%   required: thompson_macbeth_table10_2000psia_r1.md
%   optional: Table10_legacy86_exptno.txt
%   optional: old calculation workbooks (*.xlsx, *.xlsm) containing tm_ST / tm_F1_ST etc.
%
% Outputs:
%   T10R02_Table10_source01_lowX_F1TmTsat_classify_v1_YYYYMMDD_HHMMSS.xlsx
%   run_report_T10R02_Table10_source01_lowX_F1TmTsat_classify_v1_YYYYMMDD_HHMMSS.md
%
% Notes:
%   - F1後 Tm>Tsat is treated as a QC/audit flag, not an automatic exclusion.
%   - For F1-fixed reproduction, F1後 Tm>Tsat can be excluded/split.
%   - For F1 refit, these points should generally be retained with audit flags.

clear; clc;

scriptName = 'T10R02_Table10_source01_lowX_F1TmTsat_classify_v1';
rootDir = fileparts(mfilename('fullpath'));
if isempty(rootDir); rootDir = pwd; end
cd(rootDir);

ts = datestr(now, 'yyyymmdd_HHMMSS');
outXlsx = fullfile(rootDir, sprintf('T10R02_Table10_source01_lowX_F1TmTsat_classify_v1_%s.xlsx', ts));
outMd   = fullfile(rootDir, sprintf('run_report_T10R02_Table10_source01_lowX_F1TmTsat_classify_v1_%s.md', ts));

fprintf('Parsing Table10 Markdown...\n');
mdPath = fullfile(rootDir, 'thompson_macbeth_table10_2000psia_r1.md');
assert(isfile(mdPath), 'Required file not found: %s', mdPath);
T = parseTable10Markdown(mdPath);
rawIDs = string(T.ExptNo);

fprintf('Loading manual legacy IDs if present...\n');
manualPath = fullfile(rootDir, 'Table10_legacy86_exptno.txt');
manualIDs = strings(0,1);
manualMode = "none";
if isfile(manualPath)
    manualIDs = readLegacyIdList(manualPath, rawIDs);
    manualMode = "Table10_legacy86_exptno.txt";
end

fprintf('Scanning workbooks for legacy anchor sheets and Tm/Tsat by mode...\n');
[legacyScan, legacyIDsAnchor, tmByMode, sheetScanLog, colDetectLog] = scanWorkbooks(rootDir, rawIDs, outXlsx);

if numel(manualIDs) > 0
    legacyIDsUsed = manualIDs;
    legacyMode = "manual_legacy86";
else
    legacyIDsUsed = legacyIDsAnchor;
    legacyMode = "anchor_from_tm_ST_like_sheets";
end
legacyIDsUsed = unique(legacyIDsUsed(:), 'stable');
legacyIDsUsed = legacyIDsUsed(ismember(legacyIDsUsed, rawIDs));

fprintf('Building audit flags...\n');
T = addAuditFlags(T, legacyIDsUsed, tmByMode);

fprintf('Building candidate subsets and summaries...\n');
sets = buildCandidateSets(T);
setSummary = summarizeSets(T, sets);
sourceSummary = summarizeByGroup(T, 'source_label');
flagSummary = summarizeByGroup(T, 'flag_norm');
classSummary = summarizeByGroup(T, 'class_T10R02');

overlapSummary = buildOverlapSummary(T);
legacyIDsTable = table(legacyIDsUsed(:), 'VariableNames', {'ExptNo'});
manualIDsTable = table(manualIDs(:), 'VariableNames', {'ExptNo'});
anchorIDsTable = table(legacyIDsAnchor(:), 'VariableNames', {'ExptNo'});

fprintf('Writing Excel output: %s\n', erase(outXlsx, rootDir + filesep));
writeOutputs(outXlsx, T, sets, setSummary, sourceSummary, flagSummary, classSummary, ...
    overlapSummary, legacyIDsTable, manualIDsTable, anchorIDsTable, legacyScan, tmByMode, sheetScanLog, colDetectLog);

fprintf('Creating figures...\n');
figFiles = createFigures(T, setSummary, ts, rootDir);

fprintf('Writing Markdown report: %s\n', erase(outMd, rootDir + filesep));
writeReport(outMd, scriptName, ts, mdPath, outXlsx, legacyMode, manualMode, ...
    T, setSummary, sourceSummary, flagSummary, classSummary, overlapSummary, ...
    legacyIDsUsed, legacyIDsAnchor, manualIDs, tmByMode, figFiles);

fprintf('\nDone.\nOutput Excel: %s\nOutput report: %s\n', outXlsx, outMd);

%% Local functions

function T = parseTable10Markdown(mdPath)
    txt = fileread(mdPath);
    lines = regexp(txt, '\r\n|\n|\r', 'split')';
    rows = {};
    for i = 1:numel(lines)
        line = strtrim(lines{i});
        if ~startsWith(line, '|'); continue; end
        if contains(line, '---'); continue; end
        parts = regexp(line, '\|', 'split');
        parts = strtrim(parts);
        if numel(parts) >= 2 && strlength(string(parts{1})) == 0
            parts = parts(2:end);
        end
        if numel(parts) >= 1 && strlength(string(parts{end})) == 0
            parts = parts(1:end-1);
        end
        if numel(parts) < 8; continue; end
        first = string(strtrim(parts{1}));
        if ~contains(first, '.'); continue; end
        if isempty(regexp(first, '^\d+\.\d+$', 'once')); continue; end
        rows(end+1, :) = parts(1:8); %#ok<AGROW>
    end
    if isempty(rows)
        error('No Table10 data rows were parsed from %s', mdPath);
    end
    ExptNo = strings(size(rows,1),1);
    Dia_in = nan(size(rows,1),1);
    Length_in = nan(size(rows,1),1);
    G_1e6_lb_hr_ft2 = nan(size(rows,1),1);
    InletSubcool_BTUlb = nan(size(rows,1),1);
    BurnoutHF_1e6 = nan(size(rows,1),1);
    ExitQuality = nan(size(rows,1),1);
    flag_norm = strings(size(rows,1),1);
    for r = 1:size(rows,1)
        ExptNo(r) = canonicalExptNo(rows{r,1});
        Dia_in(r) = toDouble(rows{r,2});
        Length_in(r) = toDouble(rows{r,3});
        G_1e6_lb_hr_ft2(r) = toDouble(rows{r,4});
        InletSubcool_BTUlb(r) = toDouble(rows{r,5});
        BurnoutHF_1e6(r) = toDouble(rows{r,6});
        ExitQuality(r) = toDouble(rows{r,7});
        fl = upper(strtrim(string(rows{r,8})));
        if fl == "" || lower(fl) == "nan" || lower(fl) == "none" || fl == "-"
            fl = "none";
        end
        flag_norm(r) = fl;
    end
    suffix = strings(size(ExptNo));
    table_no = nan(size(ExptNo));
    for r = 1:numel(ExptNo)
        tok = regexp(char(ExptNo(r)), '^(\d+)\.(\d+)$', 'tokens', 'once');
        if ~isempty(tok)
            table_no(r) = str2double(tok{2});
            suffix(r) = string(tok{2});
        end
    end
    source_label = "source" + suffix;
    L_over_D = Length_in ./ Dia_in;
    G_kg_m2s = G_1e6_lb_hr_ft2 * 1356.23;
    Hsub_kJkg = InletSubcool_BTUlb * 2.326;
    q_MW_m2 = BurnoutHF_1e6 * 3.15459;
    lowX_le_005 = ExitQuality <= 0.05;
    x_le_0 = ExitQuality <= 0;
    source01_flag = source_label == "source01";
    source09_flag = source_label == "source09";
    T = table(ExptNo, table_no, source_label, flag_norm, Dia_in, Length_in, L_over_D, ...
        G_1e6_lb_hr_ft2, G_kg_m2s, InletSubcool_BTUlb, Hsub_kJkg, BurnoutHF_1e6, q_MW_m2, ...
        ExitQuality, lowX_le_005, x_le_0, source01_flag, source09_flag);
end

function x = toDouble(v)
    s = strtrim(string(v));
    s = erase(s, ',');
    s = regexprep(s, '^\+', '');
    if s == "" || lower(s) == "nan" || s == "-"
        x = NaN;
    else
        x = str2double(s);
    end
end

function id = canonicalExptNo(v)
    s = strtrim(string(v));
    s = erase(s, ',');
    tok = regexp(char(s), '(\d+)\.(\d+)', 'tokens', 'once');
    if isempty(tok)
        id = "";
        return;
    end
    a = str2double(tok{1});
    b = str2double(tok{2});
    id = string(sprintf('%d.%02d', a, b));
end

function ids = readLegacyIdList(path, rawIDs)
    txt = fileread(path);
    toks = regexp(txt, '\d+\.\d+', 'match');
    ids = strings(numel(toks),1);
    for i = 1:numel(toks)
        ids(i) = canonicalExptNo(toks{i});
    end
    ids = unique(ids(ids ~= ""), 'stable');
    ids = ids(ismember(ids, rawIDs));
end

function [legacyScan, legacyIDsAnchor, tmByMode, sheetScanLog, colDetectLog] = scanWorkbooks(rootDir, rawIDs, outXlsx)
    files1 = dir(fullfile(rootDir, '*.xlsx'));
    files2 = dir(fullfile(rootDir, '*.xlsm'));
    files = [files1; files2];
    legacyScan = table();
    legacyIDsAnchor = strings(0,1);
    tmRows = table();
    sheetRows = table();
    colRows = table();

    rawSet = rawIDs(:);
    for f = 1:numel(files)
        fp = fullfile(files(f).folder, files(f).name);
        [~, nm, ext] = fileparts(fp);
        if startsWith(nm, '~$'); continue; end
        if strcmpi(fp, outXlsx); continue; end
        if startsWith(nm, 'T10R02_Table10_source01_lowX_F1TmTsat_classify_v1_'); continue; end
        try
            shs = sheetnames(fp);
        catch
            continue;
        end
        for si = 1:numel(shs)
            sh = string(shs(si));
            mode = detectCalcMode(files(f).name, sh);
            isAnchor = isLegacyAnchorSheet(sh);
            try
                opts = detectImportOptions(fp, 'Sheet', sh, 'VariableNamingRule', 'preserve');
                X = readtable(fp, opts, 'Sheet', sh, 'VariableNamingRule', 'preserve');
            catch
                try
                    X = readtable(fp, 'Sheet', sh, 'VariableNamingRule', 'preserve');
                catch
                    continue;
                end
            end
            nRows = height(X); nCols = width(X);
            varNames = string(X.Properties.VariableNames);
            exptCols = findExptColumns(varNames, isAnchor);
            tmCols = findTmColumns(varNames);
            tsCols = findTsatColumns(varNames);

            sheetRows = [sheetRows; table(string(files(f).name), sh, mode, isAnchor, nRows, nCols, ...
                join(varNames(exptCols), ', '), join(varNames(tmCols), ', '), join(varNames(tsCols), ', '), ...
                'VariableNames', {'file','sheet','calc_mode','is_legacy_anchor','n_rows','n_cols','expt_cols','Tm_cols','Tsat_cols'})]; %#ok<AGROW>

            if isempty(exptCols)
                continue;
            end

            % Legacy anchor IDs from exact old ST sheets only.
            if isAnchor
                idsHere = strings(0,1);
                for c = exptCols(:)'
                    idsHere = [idsHere; parseIdsFromColumn(X.(varNames(c)), rawSet)]; %#ok<AGROW>
                end
                idsHere = unique(idsHere(idsHere ~= ""), 'stable');
                legacyIDsAnchor = [legacyIDsAnchor; idsHere]; %#ok<AGROW>
                if ~isempty(idsHere)
                    legacyScan = [legacyScan; table(string(files(f).name), sh, nRows, nCols, numel(idsHere), ...
                        join(varNames(exptCols), ', '), minStrNumeric(idsHere), maxStrNumeric(idsHere), ...
                        'VariableNames', {'file','sheet','n_rows','n_cols','n_anchor_ids','expt_columns','min_expt','max_expt'})]; %#ok<AGROW>
                end
            end

            % Tm/Tsat mode audit from mode-known sheets only.
            if mode == "unknown" || isempty(tmCols) || isempty(tsCols)
                continue;
            end

            for ec = exptCols(:)'
                ids = parseIdsFromColumn(X.(varNames(ec)), rawSet);
                if isempty(ids); continue; end
                for tc = tmCols(:)'
                    tmv = colToDouble(X.(varNames(tc)));
                    for sc = tsCols(:)'
                        tsv = colToDouble(X.(varNames(sc)));
                        n = min([numel(ids), numel(tmv), numel(tsv)]);
                        if n == 0; continue; end
                        valid = ids(1:n) ~= "" & ismember(ids(1:n), rawSet) & isfinite(tmv(1:n)) & isfinite(tsv(1:n));
                        if ~any(valid); continue; end
                        tmp = table(repmat(string(files(f).name), sum(valid),1), repmat(sh, sum(valid),1), repmat(mode, sum(valid),1), ...
                            ids(valid), tmv(valid), tsv(valid), tmv(valid)-tsv(valid), repmat(string(varNames(tc)), sum(valid),1), repmat(string(varNames(sc)), sum(valid),1), ...
                            'VariableNames', {'file','sheet','calc_mode','ExptNo','Tm','Tsat','Tm_minus_Tsat','Tm_column','Tsat_column'});
                        tmRows = [tmRows; tmp]; %#ok<AGROW>
                    end
                end
            end

            colRows = [colRows; table(string(files(f).name), sh, mode, nRows, nCols, ...
                join(varNames(exptCols), ', '), join(varNames(tmCols), ', '), join(varNames(tsCols), ', '), ...
                'VariableNames', {'file','sheet','calc_mode','n_rows','n_cols','expt_cols','Tm_cols','Tsat_cols'})]; %#ok<AGROW>
        end
    end

    legacyIDsAnchor = unique(legacyIDsAnchor(legacyIDsAnchor ~= ""), 'stable');
    sheetScanLog = sheetRows;
    colDetectLog = colRows;
    tmByMode = aggregateTmRows(tmRows);
end

function tf = isLegacyAnchorSheet(sh)
    s = lower(string(sh));
    % Exact old Table10/ST calculation sheets. These usually hold 86 rows.
    tf = ismember(s, ["tm_st", "tm_f1_st", "tm_f1f2_st"]);
end

function mode = detectCalcMode(fileName, sheetName)
    s = lower(string(fileName) + " " + string(sheetName));
    if contains(s, "f1f2")
        mode = "F1F2";
    elseif contains(s, "nof1") || contains(s, "r123") || regexp(char(lower(string(sheetName))), '^tm_st$', 'once')
        mode = "noF1";
    elseif contains(s, "f1") || contains(s, "r124")
        mode = "F1";
    else
        mode = "unknown";
    end
end

function idx = findExptColumns(varNames, isAnchor)
    v = lower(varNames);
    idx = find(contains(v, "no_tableno") | contains(v, "t&m_expt") | contains(v, "tm_expt") | contains(v, "expt") | contains(v, "case_id"));
    if isAnchor
        % In anchor sheets, prefer explicit No_TableNo/case keys; do not use arbitrary numeric columns.
        idx2 = find(contains(v, "no_tableno") | contains(v, "case_id") | contains(v, "t&m_expt") | contains(v, "tm_expt"));
        if ~isempty(idx2); idx = idx2; end
    end
end

function idx = findTmColumns(varNames)
    v = lower(varNames);
    idx = find(strcmp(v, "tm") | strcmp(v, "tm_k") | contains(v, "tm_k") | strcmp(v, "tm_k_"));
    % Avoid Delta_PM etc.
    idx = idx(~contains(v(idx), "delta") & ~contains(v(idx), "mean") & ~contains(v(idx), "max") & ~contains(v(idx), "min"));
end

function idx = findTsatColumns(varNames)
    v = lower(varNames);
    idx = find(strcmp(v, "ts") | strcmp(v, "tsat") | strcmp(v, "tsat_k") | contains(v, "tsat"));
    idx = idx(~contains(v(idx), "delta") & ~contains(v(idx), "mean") & ~contains(v(idx), "max") & ~contains(v(idx), "min"));
end

function ids = parseIdsFromColumn(col, rawIDs)
    n = numel(col);
    ids = strings(n,1);
    if isnumeric(col)
        vals = col(:);
        for i = 1:n
            if isfinite(vals(i))
                ids(i) = canonicalExptNo(sprintf('%.2f', vals(i)));
            end
        end
    else
        c = string(col);
        for i = 1:n
            tok = regexp(char(c(i)), '\d+\.\d+', 'match', 'once');
            if ~isempty(tok)
                ids(i) = canonicalExptNo(tok);
            end
        end
    end
    ids(~ismember(ids, rawIDs)) = "";
end

function x = colToDouble(col)
    if isnumeric(col)
        x = double(col(:));
    else
        s = string(col);
        s = erase(s, ',');
        x = nan(numel(s),1);
        for i = 1:numel(s)
            x(i) = str2double(s(i));
        end
    end
end

function s = minStrNumeric(ids)
    nums = str2double(ids);
    if isempty(nums) || all(isnan(nums)); s = NaN; else; s = min(nums, [], 'omitnan'); end
end

function s = maxStrNumeric(ids)
    nums = str2double(ids);
    if isempty(nums) || all(isnan(nums)); s = NaN; else; s = max(nums, [], 'omitnan'); end
end

function A = aggregateTmRows(tmRows)
    if isempty(tmRows)
        A = table(strings(0,1), strings(0,1), zeros(0,1), nan(0,1), nan(0,1), nan(0,1), false(0,1), strings(0,1), strings(0,1), strings(0,1), ...
            'VariableNames', {'ExptNo','calc_mode','N_rows','Tm_minus_Tsat_min','Tm_minus_Tsat_max','Tm_minus_Tsat_mean','Tm_gt_Tsat_any','max_source_sheet','max_Tm_column','max_Tsat_column'});
        return;
    end
    [G, ex, mode] = findgroups(tmRows.ExptNo, tmRows.calc_mode);
    nG = max(G);
    ExptNo = strings(nG,1); calc_mode = strings(nG,1); N_rows = zeros(nG,1);
    mn = nan(nG,1); mx = nan(nG,1); av = nan(nG,1); anygt = false(nG,1);
    maxsheet = strings(nG,1); maxTmCol = strings(nG,1); maxTsCol = strings(nG,1);
    for g = 1:nG
        idx = G == g;
        vals = tmRows.Tm_minus_Tsat(idx);
        ExptNo(g) = ex(g); calc_mode(g) = mode(g); N_rows(g) = sum(idx);
        mn(g) = min(vals, [], 'omitnan'); mx(g) = max(vals, [], 'omitnan'); av(g) = mean(vals, 'omitnan');
        anygt(g) = any(vals > 0);
        [~, loc] = max(vals);
        rows = find(idx);
        rmax = rows(loc);
        maxsheet(g) = string(tmRows.file(rmax)) + " :: " + string(tmRows.sheet(rmax));
        maxTmCol(g) = string(tmRows.Tm_column(rmax));
        maxTsCol(g) = string(tmRows.Tsat_column(rmax));
    end
    A = table(ExptNo, calc_mode, N_rows, mn, mx, av, anygt, maxsheet, maxTmCol, maxTsCol, ...
        'VariableNames', {'ExptNo','calc_mode','N_rows','Tm_minus_Tsat_min','Tm_minus_Tsat_max','Tm_minus_Tsat_mean','Tm_gt_Tsat_any','max_source_sheet','max_Tm_column','max_Tsat_column'});
end

function T = addAuditFlags(T, legacyIDsUsed, tmByMode)
    T.legacy_selected_flag = ismember(T.ExptNo, legacyIDsUsed);
    T.flag_problem_CGH_DJ = ismember(T.flag_norm, ["C","G","H","DJ"]);
    T.flag_J = T.flag_norm == "J";
    T.source01_lowX = T.source01_flag & T.lowX_le_005;
    T.source01_lowX_not_legacy = T.source01_lowX & ~T.legacy_selected_flag;

    % Initialize Tm/Tsat mode fields.
    T.noF1_TmTsat_available = false(height(T),1);
    T.noF1_Tm_gt_Tsat = false(height(T),1);
    T.noF1_TmMinusTsat_max = nan(height(T),1);
    T.F1_TmTsat_available = false(height(T),1);
    T.F1_Tm_gt_Tsat = false(height(T),1);
    T.F1_TmMinusTsat_max = nan(height(T),1);
    T.F1F2_TmTsat_available = false(height(T),1);
    T.F1F2_Tm_gt_Tsat = false(height(T),1);
    T.F1F2_TmMinusTsat_max = nan(height(T),1);
    T.F1_only_Tm_gt_Tsat = false(height(T),1);

    if ~isempty(tmByMode)
        modes = ["noF1", "F1", "F1F2"];
        for m = 1:numel(modes)
            mode = modes(m);
            idxMode = string(tmByMode.calc_mode) == mode;
            ids = string(tmByMode.ExptNo(idxMode));
            for i = 1:numel(ids)
                row = find(T.ExptNo == ids(i), 1);
                if isempty(row); continue; end
                switch mode
                    case "noF1"
                        T.noF1_TmTsat_available(row) = true;
                        T.noF1_Tm_gt_Tsat(row) = tmByMode.Tm_gt_Tsat_any(find(idxMode, i, 'first')); %#ok<FNDSB>
                    case "F1"
                        T.F1_TmTsat_available(row) = true;
                        T.F1_Tm_gt_Tsat(row) = tmByMode.Tm_gt_Tsat_any(find(idxMode, i, 'first')); %#ok<FNDSB>
                    case "F1F2"
                        T.F1F2_TmTsat_available(row) = true;
                        T.F1F2_Tm_gt_Tsat(row) = tmByMode.Tm_gt_Tsat_any(find(idxMode, i, 'first')); %#ok<FNDSB>
                end
            end
            sub = tmByMode(idxMode,:);
            for i = 1:height(sub)
                row = find(T.ExptNo == string(sub.ExptNo(i)), 1);
                if isempty(row); continue; end
                switch mode
                    case "noF1"; T.noF1_TmMinusTsat_max(row) = sub.Tm_minus_Tsat_max(i);
                    case "F1"; T.F1_TmMinusTsat_max(row) = sub.Tm_minus_Tsat_max(i);
                    case "F1F2"; T.F1F2_TmMinusTsat_max(row) = sub.Tm_minus_Tsat_max(i);
                end
            end
        end
    end
    T.F1_only_Tm_gt_Tsat = T.F1_Tm_gt_Tsat & ~T.noF1_Tm_gt_Tsat;

    % Classification for Table10 source01 low-X audit.
    cls = strings(height(T),1);
    for i = 1:height(T)
        if ~T.source01_flag(i)
            cls(i) = "not_source01";
        elseif ~T.lowX_le_005(i)
            cls(i) = "source01_x_gt_005";
        elseif T.legacy_selected_flag(i) && T.F1_only_Tm_gt_Tsat(i)
            cls(i) = "source01_lowX_legacy_F1_TmGt";
        elseif T.legacy_selected_flag(i) && ~T.F1_only_Tm_gt_Tsat(i)
            cls(i) = "source01_lowX_legacy_F1_TmOK_or_unknown";
        elseif ~T.legacy_selected_flag(i) && T.F1_only_Tm_gt_Tsat(i)
            cls(i) = "source01_lowX_notLegacy_F1_TmGt";
        elseif ~T.legacy_selected_flag(i) && T.F1_TmTsat_available(i) && ~T.F1_only_Tm_gt_Tsat(i)
            cls(i) = "source01_lowX_notLegacy_F1_TmOK";
        elseif ~T.legacy_selected_flag(i) && ~T.F1_TmTsat_available(i)
            cls(i) = "source01_lowX_notLegacy_F1_TmUnknown";
        else
            cls(i) = "source01_lowX_other";
        end
    end
    T.class_T10R02 = cls;

    % Suggested role flags, not adoption.
    T.F1_fixed_candidate_strict = T.legacy_selected_flag & ~T.F1_only_Tm_gt_Tsat;
    T.F1_fixed_candidate_with_TmFlag = T.legacy_selected_flag;
    T.F1_refit_candidate_source01_lowX = T.source01_lowX;
    T.audit_flag_keep_for_refit = T.F1_only_Tm_gt_Tsat;
end

function sets = buildCandidateSets(T)
    sets = struct();
    sets.raw_all = true(height(T),1);
    sets.source01_all = T.source01_flag;
    sets.source01_x_le_005 = T.source01_lowX;
    sets.legacy_selected_anchor = T.legacy_selected_flag;
    sets.legacy_F1_TmGt = T.legacy_selected_flag & T.F1_only_Tm_gt_Tsat;
    sets.legacy_F1_TmOK_or_unknown = T.legacy_selected_flag & ~T.F1_only_Tm_gt_Tsat;
    sets.source01_lowX_not_legacy = T.source01_lowX_not_legacy;
    sets.source01_lowX_notLegacy_F1_TmGt = T.source01_lowX_not_legacy & T.F1_only_Tm_gt_Tsat;
    sets.source01_lowX_notLegacy_F1_TmOK = T.source01_lowX_not_legacy & T.F1_TmTsat_available & ~T.F1_only_Tm_gt_Tsat;
    sets.source01_lowX_notLegacy_F1_TmUnknown = T.source01_lowX_not_legacy & ~T.F1_TmTsat_available;
    sets.source01_G_1p60_3p00_x_le_005 = T.source01_flag & T.lowX_le_005 & T.G_1e6_lb_hr_ft2 >= 1.60 & T.G_1e6_lb_hr_ft2 <= 3.00;
    sets.source01_G_1p77_2p95_x_le_005 = T.source01_flag & T.lowX_le_005 & T.G_1e6_lb_hr_ft2 >= 1.77 & T.G_1e6_lb_hr_ft2 <= 2.95;
    sets.source09_weatherhead_like = T.source09_flag;
    sets.source09_x_le_005 = T.source09_flag & T.lowX_le_005;
    sets.F1_fixed_strict_legacy_without_TmGt = T.F1_fixed_candidate_strict;
    sets.F1_refit_source01_lowX_with_TmFlag = T.F1_refit_candidate_source01_lowX;
end

function S = summarizeSets(T, sets)
    names = string(fieldnames(sets));
    S = table();
    for i = 1:numel(names)
        mask = sets.(names(i));
        row = summarizeMask(T, mask, names(i));
        S = [S; row]; %#ok<AGROW>
    end
end

function S = summarizeByGroup(T, groupVar)
    vals = unique(string(T.(groupVar)), 'stable');
    S = table();
    for i = 1:numel(vals)
        mask = string(T.(groupVar)) == vals(i);
        S = [S; summarizeMask(T, mask, vals(i))]; %#ok<AGROW>
    end
    S.Properties.VariableNames{1} = groupVar;
end

function row = summarizeMask(T, mask, name)
    n = sum(mask);
    if n == 0
        row = table(string(name), 0, "", "", "", "", "", "", "", NaN, NaN, NaN, NaN, NaN, NaN, ...
            'VariableNames', {'candidate_set','N','sources','flags','D_range','L_range','LD_range','G_range','Hsub_range','frac_x_le_0','frac_x_le_005','frac_legacy','frac_F1_TmGt','frac_noF1_TmGt','frac_F1_TmTsat_available'});
        return;
    end
    row = table(string(name), n, join(unique(string(T.source_label(mask))), ', '), join(unique(string(T.flag_norm(mask))), ', '), ...
        rangeStr(T.Dia_in(mask)), rangeStr(T.Length_in(mask)), rangeStr(T.L_over_D(mask)), rangeStr(T.G_1e6_lb_hr_ft2(mask)), rangeStr(T.Hsub_kJkg(mask)), ...
        mean(T.x_le_0(mask), 'omitnan'), mean(T.lowX_le_005(mask), 'omitnan'), mean(T.legacy_selected_flag(mask), 'omitnan'), ...
        mean(T.F1_only_Tm_gt_Tsat(mask), 'omitnan'), mean(T.noF1_Tm_gt_Tsat(mask), 'omitnan'), mean(T.F1_TmTsat_available(mask), 'omitnan'), ...
        'VariableNames', {'candidate_set','N','sources','flags','D_range','L_range','LD_range','G_range','Hsub_range','frac_x_le_0','frac_x_le_005','frac_legacy','frac_F1_TmGt','frac_noF1_TmGt','frac_F1_TmTsat_available'});
end

function s = rangeStr(x)
    x = x(isfinite(x));
    if isempty(x)
        s = "";
    else
        s = string(sprintf('%.4g - %.4g', min(x), max(x)));
    end
end

function O = buildOverlapSummary(T)
    labels = [
        "source01_lowX"
        "legacy_selected"
        "F1_only_Tm_gt_Tsat"
        "source01_lowX_and_legacy"
        "source01_lowX_and_not_legacy"
        "source01_lowX_and_F1_TmGt"
        "source01_lowX_notLegacy_and_F1_TmGt"
        "source01_lowX_notLegacy_and_F1_TmOK"
        "source01_lowX_notLegacy_and_F1_TmUnknown"
        "legacy_and_F1_TmGt"
        "legacy_and_F1_TmOK_or_unknown"
        ];
    masks = {
        T.source01_lowX
        T.legacy_selected_flag
        T.F1_only_Tm_gt_Tsat
        T.source01_lowX & T.legacy_selected_flag
        T.source01_lowX & ~T.legacy_selected_flag
        T.source01_lowX & T.F1_only_Tm_gt_Tsat
        T.source01_lowX & ~T.legacy_selected_flag & T.F1_only_Tm_gt_Tsat
        T.source01_lowX & ~T.legacy_selected_flag & T.F1_TmTsat_available & ~T.F1_only_Tm_gt_Tsat
        T.source01_lowX & ~T.legacy_selected_flag & ~T.F1_TmTsat_available
        T.legacy_selected_flag & T.F1_only_Tm_gt_Tsat
        T.legacy_selected_flag & ~T.F1_only_Tm_gt_Tsat
        };
    N = zeros(numel(labels),1);
    ids = strings(numel(labels),1);
    for i = 1:numel(labels)
        N(i) = sum(masks{i});
        tmp = T.ExptNo(masks{i});
        if numel(tmp) <= 40
            ids(i) = join(tmp, ', ');
        else
            ids(i) = join(tmp(1:40), ', ') + " ...";
        end
    end
    O = table(labels, N, ids, 'VariableNames', {'overlap_group','N','ExptNo_preview'});
end

function writeOutputs(outXlsx, T, sets, setSummary, sourceSummary, flagSummary, classSummary, overlapSummary, legacyIDsTable, manualIDsTable, anchorIDsTable, legacyScan, tmByMode, sheetScanLog, colDetectLog)
    if isfile(outXlsx); delete(outXlsx); end
    writetable(T, outXlsx, 'Sheet', 'raw_all_with_flags');
    writetable(setSummary, outXlsx, 'Sheet', 'set_summary');
    writetable(sourceSummary, outXlsx, 'Sheet', 'source_summary');
    writetable(flagSummary, outXlsx, 'Sheet', 'flag_summary');
    writetable(classSummary, outXlsx, 'Sheet', 'class_summary');
    writetable(overlapSummary, outXlsx, 'Sheet', 'overlap_summary');
    writetable(legacyIDsTable, outXlsx, 'Sheet', 'legacy_ids_used');
    writetable(anchorIDsTable, outXlsx, 'Sheet', 'legacy_anchor_ids');
    writetable(manualIDsTable, outXlsx, 'Sheet', 'legacy_manual_ids');
    if ~isempty(legacyScan); writetable(legacyScan, outXlsx, 'Sheet', 'legacy_scan'); end
    if ~isempty(tmByMode); writetable(tmByMode, outXlsx, 'Sheet', 'TmTsat_by_mode'); end
    if ~isempty(sheetScanLog); writetable(sheetScanLog, outXlsx, 'Sheet', 'sheet_scan_log'); end
    if ~isempty(colDetectLog); writetable(colDetectLog, outXlsx, 'Sheet', 'column_detect_log'); end

    fn = string(fieldnames(sets));
    for i = 1:numel(fn)
        mask = sets.(fn(i));
        sheet = char(fn(i));
        sheet = regexprep(sheet, '[^A-Za-z0-9_]', '_');
        if strlength(string(sheet)) > 31
            sheet = char(extractBefore(string(sheet), 32));
        end
        writetable(T(mask,:), outXlsx, 'Sheet', sheet);
    end
end

function figFiles = createFigures(T, setSummary, ts, rootDir)
    figFiles = strings(0,1);
    try
        f = figure('Visible','off','Color','w','Position',[100 100 1000 420]);
        names = string(setSummary.candidate_set);
        N = setSummary.N;
        bar(N);
        xticks(1:numel(N)); xticklabels(names); xtickangle(45);
        ylabel('N'); title('T10R02 candidate set counts'); grid on;
        fn = fullfile(rootDir, sprintf('fig_T10R02_01_candidate_counts_%s.png', ts));
        exportgraphics(f, fn, 'Resolution', 180); close(f);
        figFiles(end+1,1) = string(fn);
    catch
    end
    try
        f = figure('Visible','off','Color','w','Position',[100 100 850 560]);
        hold on;
        m1 = T.source01_lowX & ~T.legacy_selected_flag & ~T.F1_only_Tm_gt_Tsat;
        m2 = T.source01_lowX & ~T.legacy_selected_flag & T.F1_only_Tm_gt_Tsat;
        m3 = T.source01_lowX & T.legacy_selected_flag & ~T.F1_only_Tm_gt_Tsat;
        m4 = T.source01_lowX & T.legacy_selected_flag & T.F1_only_Tm_gt_Tsat;
        scatter(T.G_1e6_lb_hr_ft2(m1), T.ExitQuality(m1), 36, 'o', 'DisplayName','lowX not legacy TmOK/unknown');
        scatter(T.G_1e6_lb_hr_ft2(m2), T.ExitQuality(m2), 50, 'x', 'DisplayName','lowX not legacy F1 Tm>Tsat');
        scatter(T.G_1e6_lb_hr_ft2(m3), T.ExitQuality(m3), 36, 's', 'DisplayName','lowX legacy TmOK/unknown');
        scatter(T.G_1e6_lb_hr_ft2(m4), T.ExitQuality(m4), 60, 'd', 'DisplayName','lowX legacy F1 Tm>Tsat');
        yline(0.05, '--', 'x=0.05');
        xlabel('G [10^6 lb/(hr ft^2)]'); ylabel('Exit quality x_report');
        title('Table10 source01 low-X audit: legacy and F1 Tm>Tsat flags');
        legend('Location','best'); grid on; hold off;
        fn = fullfile(rootDir, sprintf('fig_T10R02_02_source01_lowX_G_x_TmFlag_%s.png', ts));
        exportgraphics(f, fn, 'Resolution', 180); close(f);
        figFiles(end+1,1) = string(fn);
    catch
    end
end

function writeReport(outMd, scriptName, ts, mdPath, outXlsx, legacyMode, manualMode, T, setSummary, sourceSummary, flagSummary, classSummary, overlapSummary, legacyIDsUsed, legacyIDsAnchor, manualIDs, tmByMode, figFiles)
    fid = fopen(outMd, 'w');
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid, '# %s\n\n', scriptName);
    fprintf(fid, '作成日時: `%s`\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fprintf(fid, '## 1. 目的\n\n');
    fprintf(fid, ['T10R01cで確認された「noF1ではTm>Tsatがなく、F1後だけTm>Tsatが出る」結果を踏まえ、' ...
        'T&M Table10のsource01低クオリティ候補を棚卸しする。\n\n']);
    fprintf(fid, 'このrunでは採用点を決めない。旧採用点、旧採用外source01低X候補、F1後Tm>Tsat点の重なりを監査する。\n\n');

    fprintf(fid, '## 2. 入力\n\n');
    fprintf(fid, '- Table10正本Markdown: `%s`\n', mdPath);
    fprintf(fid, '- 出力Excel: `%s`\n', outXlsx);
    fprintf(fid, '- legacy mode: `%s`\n', legacyMode);
    fprintf(fid, '- manual legacy source: `%s`\n\n', manualMode);

    fprintf(fid, '## 3. QC\n\n');
    fprintf(fid, '- Parsed Table10 rows: `%d`\n', height(T));
    fprintf(fid, '- legacy IDs used: `%d`\n', numel(legacyIDsUsed));
    fprintf(fid, '- legacy anchor IDs detected: `%d`\n', numel(legacyIDsAnchor));
    fprintf(fid, '- manual legacy IDs: `%d`\n', numel(manualIDs));
    fprintf(fid, '- source01 rows: `%d`\n', sum(T.source01_flag));
    fprintf(fid, '- source01 x_report <= 0.05 rows: `%d`\n', sum(T.source01_lowX));
    fprintf(fid, '- source01 lowX not legacy rows: `%d`\n', sum(T.source01_lowX_not_legacy));
    fprintf(fid, '- noF1 Tm>Tsat rows: `%d`\n', sum(T.noF1_Tm_gt_Tsat));
    fprintf(fid, '- F1-only Tm>Tsat rows: `%d`\n', sum(T.F1_only_Tm_gt_Tsat));
    fprintf(fid, '- source01 lowX and F1-only Tm>Tsat rows: `%d`\n\n', sum(T.source01_lowX & T.F1_only_Tm_gt_Tsat));

    fprintf(fid, '## 4. Source summary\n\n'); writeMarkdownTable(fid, sourceSummary);
    fprintf(fid, '\n## 5. Flag summary\n\n'); writeMarkdownTable(fid, flagSummary);
    fprintf(fid, '\n## 6. Candidate set summary\n\n'); writeMarkdownTable(fid, setSummary);
    fprintf(fid, '\n## 7. Overlap summary\n\n'); writeMarkdownTable(fid, overlapSummary);
    fprintf(fid, '\n## 8. Class summary\n\n'); writeMarkdownTable(fid, classSummary);

    fprintf(fid, '\n## 9. Tm/Tsat mode summary\n\n');
    if isempty(tmByMode)
        fprintf(fid, '(empty)\n\n');
    else
        modeSummary = summarizeTmMode(tmByMode);
        writeMarkdownTable(fid, modeSummary);
    end

    fprintf(fid, '\n## 10. 一次判断テンプレート\n\n');
    fprintf(fid, '```text\n');
    fprintf(fid, 'T10R02は、Table10旧採用点を絶対基準として採用点を決めるrunではない。\n');
    fprintf(fid, '旧採用点は初期検討用の厳選集合として扱い、source01低X候補全体を再監査する。\n');
    fprintf(fid, 'F1後Tm>Tsat点は、元データ異常ではなく、現行F1適用後に生じるQCフラグとして扱う。\n');
    fprintf(fid, 'F1固定用集合では除外/別管理の候補とし、F1再設計用集合では自動除外せず監査フラグ付きで保持する。\n');
    fprintf(fid, '```\n\n');

    fprintf(fid, '## 11. 次アクション\n\n');
    fprintf(fid, '- `source01_lowX_not_legacy` のうち、F1後Tm>Tsatあり/なし/未確認を分けて見る。\n');
    fprintf(fid, '- F1固定用集合とF1再設計用集合を分けて定義する。\n');
    fprintf(fid, '- まだPM計算やF1再fitへは進まない。\n\n');

    fprintf(fid, '## 12. Figures\n\n');
    for i = 1:numel(figFiles)
        fprintf(fid, '- `%s`\n', char(figFiles(i)));
    end
end

function M = summarizeTmMode(tmByMode)
    modes = unique(string(tmByMode.calc_mode), 'stable');
    M = table();
    for i = 1:numel(modes)
        mask = string(tmByMode.calc_mode) == modes(i);
        vals = tmByMode.Tm_minus_Tsat_max(mask);
        row = table(modes(i), sum(mask), sum(tmByMode.Tm_gt_Tsat_any(mask)), mean(tmByMode.Tm_gt_Tsat_any(mask)), ...
            rangeStr(vals), join(tmByMode.ExptNo(mask & tmByMode.Tm_gt_Tsat_any), ', '), ...
            'VariableNames', {'calc_mode','N_expt','N_Tm_gt_Tsat','frac_Tm_gt_Tsat','TmMinusTsat_max_range','ExptNo_TmGt'});
        M = [M; row]; %#ok<AGROW>
    end
end

function writeMarkdownTable(fid, T)
    if isempty(T) || height(T)==0
        fprintf(fid, '(empty)\n');
        return;
    end
    vars = string(T.Properties.VariableNames);
    fprintf(fid, '| %s |\n', strjoin(cellstr(vars), ' | '));
    fprintf(fid, '|%s|\n', strjoin(repmat({'---'}, 1, numel(vars)), '|'));
    maxRows = min(height(T), 80);
    for r = 1:maxRows
        cells = strings(1, numel(vars));
        for c = 1:numel(vars)
            val = T{r,c};
            if iscell(val); val = val{1}; end
            if isnumeric(val) || islogical(val)
                if isscalar(val)
                    if isnan(double(val))
                        cells(c) = "";
                    else
                        cells(c) = string(sprintf('%.6g', double(val)));
                    end
                else
                    cells(c) = string(mat2str(val));
                end
            else
                cells(c) = string(val);
            end
            cells(c) = replace(cells(c), '|', '\|');
            cells(c) = replace(cells(c), newline, ' ');
        end
        fprintf(fid, '| %s |\n', strjoin(cellstr(cells), ' | '));
    end
    if height(T) > maxRows
        fprintf(fid, '\n... truncated to first %d rows ...\n', maxRows);
    end
end
