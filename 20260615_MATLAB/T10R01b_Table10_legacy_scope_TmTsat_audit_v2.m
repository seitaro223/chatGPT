%% T10R01b_Table10_legacy_scope_TmTsat_audit_v2.m
% T&M Table10 legacy-scope and Tm/Tsat audit
%
% Purpose:
%   - Treat thompson_macbeth_table10_2000psia_r1.md as Table10_raw_all.
%   - Reconstruct how narrow the old Table10 selected set was.
%   - Separate “initial strict / good-data set” from later loose L/D expansion logic.
%   - Audit possible hand-cut criteria, especially rows where F1-applied Tm exceeded Tsat,
%     if the relevant calculated workbook contains Tm/Tsat columns.
%
% Important:
%   This run does NOT decide new adopted points.
%   It only creates audit tables and candidate sets.
%
% Expected files in the same folder:
%   required:
%     thompson_macbeth_table10_2000psia_r1.md
%   optional:
%     anl_1958_chf_claude.md
%     H52Q_current_single_tube_input_*.xlsx
%     celata...xlsm or other old calculation workbooks containing Table10 rows
%     Table10_legacy86_exptno.txt  or  Table10_legacy86_exptno.csv
%
% If Table10_legacy86_exptno.txt exists, put one ExptNo per line, e.g.
%   34.01
%   35.01
%   ...
% This manual file takes priority over auto-detected legacy IDs.

clear; clc;

runName = 'T10R01b_Table10_legacy_scope_TmTsat_audit_v2';
ts = datestr(now, 'yyyymmdd_HHMMSS');
outXlsx = sprintf('T10R01b_table10_legacy_scope_TmTsat_audit_v2_%s.xlsx', ts);
outMd   = sprintf('run_report_T10R01b_table10_legacy_scope_TmTsat_audit_v2_%s.md', ts);

rootDir = pwd;
mdFile = fullfile(rootDir, 'thompson_macbeth_table10_2000psia_r1.md');
if ~isfile(mdFile)
    error('Required file not found: %s', mdFile);
end

fprintf('Parsing Table10 Markdown...\n');
T = parseTable10Markdown(mdFile);
T.RowID = (1:height(T))';
T.L_over_D = T.Length_in ./ T.Dia_in;
T.source_code = extractAfter(T.ExptNo, '.');
T.source_label = "source" + T.source_code;
T.flag_norm = T.Flag;
T.flag_norm(strlength(strtrim(T.flag_norm))==0) = "none";
T.lowX_le_005 = T.ExitQuality <= 0.05;
T.lowX_le_0   = T.ExitQuality <= 0;

% Reorder raw table columns.
T = movevars(T, {'RowID','source_code','source_label','flag_norm','L_over_D','lowX_le_005','lowX_le_0'}, 'After', 'Flag');

fprintf('Loading manual legacy IDs if present...\n');
[manualLegacyIDs, manualLegacySource] = loadManualLegacyIDs(rootDir);

fprintf('Scanning workbooks for legacy-like Table10 ExptNo and Tm/Tsat columns...\n');
[legacyScan, legacyIDsAuto, tmAudit, colDetectLog] = scanWorkbooksForLegacyAndTm(rootDir, T.ExptNo, outXlsx);

if ~isempty(manualLegacyIDs)
    legacyIDs = manualLegacyIDs;
    legacyMode = "manual_legacy86_file";
else
    legacyIDs = legacyIDsAuto;
    legacyMode = "auto_detected_from_workbooks";
end
legacyIDs = unique(standardizeExptNo(legacyIDs));
legacyIDs(ismissing(legacyIDs) | strlength(legacyIDs)==0) = [];

T.legacy_selected_flag = ismember(T.ExptNo, legacyIDs);
T.legacy_mode = repmat(legacyMode, height(T), 1);

% Merge Tm/Tsat if available. Prefer one row per ExptNo if duplicates exist.
T.Tm_value = nan(height(T),1);
T.Tsat_value = nan(height(T),1);
T.Tm_minus_Tsat = nan(height(T),1);
T.Tm_gt_Tsat_flag = false(height(T),1);
T.TmTsat_source = strings(height(T),1);
if ~isempty(tmAudit)
    tmAudit.ExptNo = standardizeExptNo(tmAudit.ExptNo);
    % Select first nonmissing Tm/Tsat per ExptNo. Keep source text.
    [uExpt, ~, g] = unique(tmAudit.ExptNo);
    selRows = zeros(numel(uExpt),1);
    for i = 1:numel(uExpt)
        idx = find(g==i & isfinite(tmAudit.Tm_value) & isfinite(tmAudit.Tsat_value), 1, 'first');
        if isempty(idx), idx = find(g==i, 1, 'first'); end
        selRows(i) = idx;
    end
    tmOne = tmAudit(selRows,:);
    [tf, loc] = ismember(T.ExptNo, tmOne.ExptNo);
    T.Tm_value(tf) = tmOne.Tm_value(loc(tf));
    T.Tsat_value(tf) = tmOne.Tsat_value(loc(tf));
    T.Tm_minus_Tsat(tf) = tmOne.Tm_minus_Tsat(loc(tf));
    T.Tm_gt_Tsat_flag(tf) = tmOne.Tm_gt_Tsat_flag(loc(tf));
    T.TmTsat_source(tf) = tmOne.source_sheet(loc(tf));
end
T.TmTsat_available_flag = isfinite(T.Tm_value) & isfinite(T.Tsat_value);

% Candidate tags.
T.selection_group = strings(height(T),1);
T.selection_group(T.legacy_selected_flag) = "legacy_selected";
T.selection_group(~T.legacy_selected_flag & T.source_label=="source01" & T.lowX_le_005) = "source01_lowX_not_legacy";
T.selection_group(T.source_label=="source09") = "source09_weatherhead_like";
T.selection_reason = strings(height(T),1);
T.selection_reason(T.legacy_selected_flag) = "old strict / initially selected Table10 set (manual or auto-detected)";
T.selection_reason(~T.legacy_selected_flag & T.source_label=="source01" & T.lowX_le_005) = "source01 and x_report <= 0.05, but not in legacy set";
T.selection_reason(T.source_label=="source09") = "source09, likely Weatherhead/ANL-derived within T&M Table10";

% Candidate set table.
fprintf('Building candidate summaries...\n');
candidateDefs = buildCandidateDefs(T);
setSummary = summarizeCandidateSets(T, candidateDefs);
sourceSummary = summarizeByGroup(T, 'source_label');
flagSummary   = summarizeByGroup(T, 'flag_norm');
legacySummary = summarizeLegacy(T);

% Extra tables.
source01LowNotLegacy = T(T.source_label=="source01" & T.lowX_le_005 & ~T.legacy_selected_flag, :);
legacyRows = T(T.legacy_selected_flag, :);
source09Rows = T(T.source_label=="source09", :);
TmExceededRows = T(T.TmTsat_available_flag & T.Tm_gt_Tsat_flag, :);
TmAvailableRows = T(T.TmTsat_available_flag, :);

% Write outputs.
fprintf('Writing Excel output: %s\n', outXlsx);
writeTableSafe(T, outXlsx, 'Table10_raw_all');
writeTableSafe(setSummary, outXlsx, 'candidate_set_summary');
writeTableSafe(sourceSummary, outXlsx, 'source_summary');
writeTableSafe(flagSummary, outXlsx, 'flag_summary');
writeTableSafe(legacySummary, outXlsx, 'legacy_summary');
writeTableSafe(legacyRows, outXlsx, 'legacy_rows');
writeTableSafe(source01LowNotLegacy, outXlsx, 'source01_lowX_not_legacy');
writeTableSafe(source09Rows, outXlsx, 'source09_weatherhead_like');
writeTableSafe(TmAvailableRows, outXlsx, 'TmTsat_available_rows');
writeTableSafe(TmExceededRows, outXlsx, 'Tm_gt_Tsat_rows');
writeTableSafe(legacyScan, outXlsx, 'legacy_scan_log');
writeTableSafe(tmAudit, outXlsx, 'TmTsat_audit_raw');
writeTableSafe(colDetectLog, outXlsx, 'column_detection_log');
readme = makeReadmeTable(legacyMode, manualLegacySource, height(T), numel(legacyIDs), height(tmAudit));
writeTableSafe(readme, outXlsx, 'README');

% Figures.
fprintf('Creating figures...\n');
figFiles = strings(0,1);
try
    figFiles(end+1) = makeBarFigure(sourceSummary.source_label, sourceSummary.N, 'Source counts', 'source', 'N', sprintf('fig_T10R01b_01_source_counts_%s.png', ts));
catch ME
    warning('Failed to create source counts figure: %s', ME.message);
end
try
    figFiles(end+1) = makeBarFigure(setSummary.candidate_set, setSummary.N, 'Candidate set counts', 'candidate set', 'N', sprintf('fig_T10R01b_02_candidate_counts_%s.png', ts));
catch ME
    warning('Failed to create candidate counts figure: %s', ME.message);
end
try
    figFiles(end+1) = makeScatterFigure(T, sprintf('fig_T10R01b_03_x_vs_G_legacy_lowX_%s.png', ts));
catch ME
    warning('Failed to create scatter figure: %s', ME.message);
end

% Markdown report.
fprintf('Writing Markdown report: %s\n', outMd);
writeMarkdownReport(outMd, runName, ts, mdFile, outXlsx, T, setSummary, sourceSummary, flagSummary, legacySummary, legacyScan, tmAudit, figFiles, legacyMode, manualLegacySource);

fprintf('\nDone.\nOutput Excel: %s\nOutput report: %s\n', outXlsx, outMd);

%% Local functions

function T = parseTable10Markdown(mdFile)
    txt = fileread(mdFile);
    lines = splitlines(string(txt));
    data = strings(0,8);
    for i = 1:numel(lines)
        line = strtrim(lines(i));
        if ~startsWith(line, "|"); continue; end
        if contains(line, "---"); continue; end
        if contains(line, "EXPT NO"); continue; end
        parts = split(line, "|");
        parts = strtrim(parts(2:end-1));
        if numel(parts) ~= 8; continue; end
        if isempty(regexp(parts(1), '^\d+\.\d+$', 'once')); continue; end
        data(end+1,:) = parts; %#ok<AGROW>
    end
    if isempty(data)
        error('No Table10 rows were parsed from %s', mdFile);
    end
    T = table;
    T.ExptNo = standardizeExptNo(data(:,1));
    T.Dia_in = str2double(data(:,2));
    T.Length_in = str2double(data(:,3));
    T.G_1e6_lb_hr_ft2 = str2double(data(:,4));
    T.InletSubcool_BTUlb = str2double(data(:,5));
    T.BurnoutHF_1e6_BTU_hr_ft2 = str2double(data(:,6));
    T.ExitQuality = str2double(data(:,7));
    T.Flag = data(:,8);
end

function ids = standardizeExptNo(x)
    if isempty(x)
        ids = strings(0,1);
        return;
    end
    if istable(x)
        x = table2array(x);
    end
    if isnumeric(x)
        ids = strings(numel(x),1);
        for k = 1:numel(x)
            if isnan(x(k))
                ids(k) = missing;
            else
                ids(k) = string(sprintf('%.2f', x(k)));
            end
        end
        return;
    end
    x = string(x);
    ids = strings(numel(x),1);
    for k = 1:numel(x)
        s = strtrim(x(k));
        if strlength(s)==0 || ismissing(s)
            ids(k) = missing;
            continue;
        end
        tok = regexp(char(s), '(\d+)\.(\d+)', 'tokens', 'once');
        if isempty(tok)
            % Try numeric string without explicit decimal only as last resort.
            val = str2double(s);
            if isfinite(val)
                ids(k) = string(sprintf('%.2f', val));
            else
                ids(k) = missing;
            end
        else
            major = str2double(tok{1});
            minor = str2double(tok{2});
            ids(k) = string(sprintf('%d.%02d', major, minor));
        end
    end
end

function [ids, src] = loadManualLegacyIDs(rootDir)
    ids = strings(0,1);
    src = "none";
    candidates = ["Table10_legacy86_exptno.txt", "Table10_legacy86_exptno.csv", "legacy_table10_86_exptno.txt", "legacy_table10_86_exptno.csv"];
    for f = candidates
        fp = fullfile(rootDir, f);
        if isfile(fp)
            raw = fileread(fp);
            toks = regexp(raw, '\d+\.\d+', 'match');
            ids = standardizeExptNo(string(toks(:)));
            ids = unique(ids(~ismissing(ids) & strlength(ids)>0));
            src = f;
            return;
        end
    end
end

function [legacyScan, legacyIDsAuto, tmAudit, colLog] = scanWorkbooksForLegacyAndTm(rootDir, rawIDs, outXlsx)
    files = [dir(fullfile(rootDir, '*.xlsx')); dir(fullfile(rootDir, '*.xlsm'))];
    skipNames = [string(outXlsx)];
    legacyScan = table;
    tmAudit = table;
    colLog = table;
    legacyIDsAuto = strings(0,1);
    rawSet = unique(rawIDs);

    for fidx = 1:numel(files)
        fname = string(files(fidx).name);
        if any(strcmpi(fname, skipNames)); continue; end
        if startsWith(fname, '~$'); continue; end
        % Avoid scanning the T10R00/T10R01 output if it exists.
        if startsWith(fname, "T10R00_") || startsWith(fname, "T10R01b_"); continue; end
        fp = fullfile(rootDir, fname);
        try
            sh = sheetnames(fp);
        catch
            continue;
        end
        for sidx = 1:numel(sh)
            sheet = string(sh{sidx});
            try
                opts = detectImportOptions(fp, 'Sheet', sheet, 'VariableNamingRule', 'preserve');
                tbl = readtable(fp, opts);
            catch
                try
                    tbl = readtable(fp, 'Sheet', sheet, 'VariableNamingRule', 'preserve');
                catch
                    continue;
                end
            end
            if isempty(tbl) || width(tbl)==0 || height(tbl)==0; continue; end

            vars = string(tbl.Properties.VariableNames);
            exptCols = detectExptColumns(tbl);
            matchedIDs = strings(0,1);
            exptColUsed = strings(0,1);
            for c = exptCols(:)'
                vals = tbl.(vars(c));
                ids = standardizeExptNo(vals);
                ids = ids(~ismissing(ids) & strlength(ids)>0);
                ids = ids(ismember(ids, rawSet));
                if ~isempty(ids)
                    matchedIDs = [matchedIDs; ids]; %#ok<AGROW>
                    exptColUsed = [exptColUsed; repmat(vars(c), numel(ids), 1)]; %#ok<AGROW>
                end
            end
            matchedIDs = unique(matchedIDs);
            if ~isempty(matchedIDs)
                tmp = table;
                tmp.file = fname;
                tmp.sheet = sheet;
                tmp.n_rows = height(tbl);
                tmp.n_cols = width(tbl);
                tmp.n_matched_unique_expt = numel(matchedIDs);
                tmp.expt_columns = strjoin(unique(exptColUsed), ', ');
                % matchedIDs are strings such as "34.01". MATLAB min/max do not
                % support string arrays in some versions, so use a numeric sort key
                % only for reporting the range. Keep ExptNo itself as standardized text.
                matchedNum = str2double(matchedIDs);
                matchedNum = matchedNum(isfinite(matchedNum));
                if isempty(matchedNum)
                    tmp.match_min_expt = "";
                    tmp.match_max_expt = "";
                else
                    tmp.match_min_expt = string(sprintf('%.2f', min(matchedNum)));
                    tmp.match_max_expt = string(sprintf('%.2f', max(matchedNum)));
                end
                legacyScan = [legacyScan; tmp]; %#ok<AGROW>
            end

            % Tm/Tsat column audit.
            [tmCols, tsatCols] = detectTmTsatColumns(vars);
            clog = table;
            clog.file = fname;
            clog.sheet = sheet;
            clog.n_rows = height(tbl);
            clog.n_cols = width(tbl);
            clog.expt_candidate_cols = strjoin(vars(exptCols), ', ');
            clog.Tm_candidate_cols = strjoin(vars(tmCols), ', ');
            clog.Tsat_candidate_cols = strjoin(vars(tsatCols), ', ');
            colLog = [colLog; clog]; %#ok<AGROW>

            if ~isempty(exptCols) && ~isempty(tmCols) && ~isempty(tsatCols)
                exptVals = standardizeExptNo(tbl.(vars(exptCols(1))));
                tmVal = toNumeric(tbl.(vars(tmCols(1))));
                tsatVal = toNumeric(tbl.(vars(tsatCols(1))));
                ok = ~ismissing(exptVals) & strlength(exptVals)>0 & ismember(exptVals, rawSet) & isfinite(tmVal) & isfinite(tsatVal);
                if any(ok)
                    ta = table;
                    ta.file = repmat(fname, sum(ok), 1);
                    ta.sheet = repmat(sheet, sum(ok), 1);
                    ta.source_sheet = repmat(fname + " :: " + sheet, sum(ok), 1);
                    ta.ExptNo = exptVals(ok);
                    ta.Tm_column = repmat(vars(tmCols(1)), sum(ok), 1);
                    ta.Tsat_column = repmat(vars(tsatCols(1)), sum(ok), 1);
                    ta.Tm_value = tmVal(ok);
                    ta.Tsat_value = tsatVal(ok);
                    ta.Tm_minus_Tsat = ta.Tm_value - ta.Tsat_value;
                    ta.Tm_gt_Tsat_flag = ta.Tm_minus_Tsat > 0;
                    tmAudit = [tmAudit; ta]; %#ok<AGROW>
                end
            end
        end
    end

    if ~isempty(legacyScan)
        % Primary auto set: use union of sheets with 50-200 matched rows, preferring names that look like current single tube / T&M current.
        candidate = legacyScan(legacyScan.n_matched_unique_expt >= 20 & legacyScan.n_matched_unique_expt <= 220, :);
        if isempty(candidate)
            candidate = legacyScan;
        end
        score = candidate.n_matched_unique_expt;
        nameText = lower(candidate.file + " " + candidate.sheet);
        score = score + 20*contains(nameText, "current") + 20*contains(nameText, "single") + 10*contains(nameText, "table10") + 10*contains(nameText, "tm");
        [~, bestIdx] = max(score);
        bestFile = candidate.file(bestIdx);
        bestSheet = candidate.sheet(bestIdx);
        % Re-read best source and extract IDs.
        try
            fp = fullfile(rootDir, bestFile);
            opts = detectImportOptions(fp, 'Sheet', bestSheet, 'VariableNamingRule', 'preserve');
            tbl = readtable(fp, opts);
            vars = string(tbl.Properties.VariableNames);
            exptCols = detectExptColumns(tbl);
            ids = strings(0,1);
            for c = exptCols(:)'
                tmpIDs = standardizeExptNo(tbl.(vars(c)));
                tmpIDs = tmpIDs(~ismissing(tmpIDs) & strlength(tmpIDs)>0 & ismember(tmpIDs, rawSet));
                ids = [ids; tmpIDs]; %#ok<AGROW>
            end
            legacyIDsAuto = unique(ids);
        catch
            legacyIDsAuto = strings(0,1);
        end
    end
end

function exptCols = detectExptColumns(tbl)
    vars = string(tbl.Properties.VariableNames);
    lowerVars = lower(vars);
    exptCols = find(contains(lowerVars, "expt") | contains(lowerVars, "experiment") | contains(lowerVars, "no_tableno") | contains(lowerVars, "no.table") | contains(lowerVars, "no_table"));
    % Add columns whose contents match many ExptNo-like values.
    for c = 1:numel(vars)
        if any(exptCols == c); continue; end
        try
            vals = tbl.(vars(c));
            ids = standardizeExptNo(vals);
            nLike = sum(~ismissing(ids) & strlength(ids)>0 & contains(ids, "."));
            if nLike >= max(10, 0.2*height(tbl))
                exptCols(end+1) = c; %#ok<AGROW>
            end
        catch
        end
    end
    exptCols = unique(exptCols);
end

function [tmCols, tsatCols] = detectTmTsatColumns(vars)
    lv = lower(vars);
    tmCols = find((contains(lv, "tm") | contains(lv, "t_m") | contains(lv, "tmean") | contains(lv, "t_mean")) & ~contains(lv, "timestamp") & ~contains(lv, "time"));
    % Avoid Tsub columns.
    tmCols = tmCols(~contains(lv(tmCols), "tsub"));
    tsatCols = find(contains(lv, "tsat") | contains(lv, "t_sat") | contains(lv, "sat_temp") | contains(lv, "saturation") | strcmp(lv, "ts"));
    tsatCols = tsatCols(~contains(lv(tsatCols), "tsub"));
end

function y = toNumeric(x)
    if isnumeric(x)
        y = double(x);
    else
        y = str2double(string(x));
    end
    y = y(:);
end

function defs = buildCandidateDefs(T)
    defs = struct('name', {}, 'mask', {});
    add('raw_all', true(height(T),1));
    add('legacy_selected', T.legacy_selected_flag);
    add('source01_all', T.source_label=="source01");
    add('source01_x_le_005', T.source_label=="source01" & T.lowX_le_005);
    add('source01_x_le_0', T.source_label=="source01" & T.lowX_le_0);
    add('source01_lowX_not_legacy', T.source_label=="source01" & T.lowX_le_005 & ~T.legacy_selected_flag);
    add('source09_all_weatherhead_like', T.source_label=="source09");
    add('source09_x_le_005', T.source_label=="source09" & T.lowX_le_005);
    add('all_x_le_005', T.lowX_le_005);
    add('all_x_le_005_source01_or09', T.lowX_le_005 & (T.source_label=="source01" | T.source_label=="source09"));
    add('all_x_le_005_no_CGH', T.lowX_le_005 & ~ismember(T.flag_norm, ["C","G","H"]));
    if any(T.legacy_selected_flag)
        gmin = min(T.G_1e6_lb_hr_ft2(T.legacy_selected_flag));
        gmax = max(T.G_1e6_lb_hr_ft2(T.legacy_selected_flag));
        add(sprintf('source01_G_legacy_range_%.3g_%.3g', gmin, gmax), T.source_label=="source01" & T.G_1e6_lb_hr_ft2>=gmin & T.G_1e6_lb_hr_ft2<=gmax);
        add(sprintf('source01_G_legacy_range_%.3g_%.3g_x_le_005', gmin, gmax), T.source_label=="source01" & T.G_1e6_lb_hr_ft2>=gmin & T.G_1e6_lb_hr_ft2<=gmax & T.lowX_le_005);
    end
    % Common PWR-G reference bands, not adoption criteria.
    add('source01_G_1p60_3p00', T.source_label=="source01" & T.G_1e6_lb_hr_ft2>=1.60 & T.G_1e6_lb_hr_ft2<=3.00);
    add('source01_G_1p60_3p00_x_le_005', T.source_label=="source01" & T.G_1e6_lb_hr_ft2>=1.60 & T.G_1e6_lb_hr_ft2<=3.00 & T.lowX_le_005);
    add('source01_G_1p77_2p95', T.source_label=="source01" & T.G_1e6_lb_hr_ft2>=1.77 & T.G_1e6_lb_hr_ft2<=2.95);
    add('source01_G_1p77_2p95_x_le_005', T.source_label=="source01" & T.G_1e6_lb_hr_ft2>=1.77 & T.G_1e6_lb_hr_ft2<=2.95 & T.lowX_le_005);
    if any(T.TmTsat_available_flag)
        add('source01_x_le_005_TmTsat_available', T.source_label=="source01" & T.lowX_le_005 & T.TmTsat_available_flag);
        add('source01_x_le_005_Tm_le_Tsat_available', T.source_label=="source01" & T.lowX_le_005 & T.TmTsat_available_flag & ~T.Tm_gt_Tsat_flag);
        add('source01_x_le_005_Tm_gt_Tsat_available', T.source_label=="source01" & T.lowX_le_005 & T.TmTsat_available_flag & T.Tm_gt_Tsat_flag);
    end

    function add(n, m)
        defs(end+1).name = string(n); %#ok<AGROW>
        defs(end).mask = m(:);
    end
end

function S = summarizeCandidateSets(T, defs)
    S = table;
    for i = 1:numel(defs)
        mask = defs(i).mask;
        sub = T(mask,:);
        row = summarizeOne(sub);
        row.candidate_set = defs(i).name;
        S = [S; row]; %#ok<AGROW>
    end
    if ~isempty(S)
        S = movevars(S, 'candidate_set', 'Before', 1);
    end
end

function S = summarizeOne(sub)
    S = table;
    S.N = height(sub);
    if height(sub)==0
        S.sources = ""; S.flags = "";
        S.D_range = ""; S.L_range = ""; S.LD_range = ""; S.G_range = ""; S.Hsub_range = ""; S.x_report_range = "";
        S.frac_x_le_0 = NaN; S.frac_x_le_005 = NaN; S.frac_legacy = NaN; S.frac_Tm_gt_Tsat_available = NaN;
        return;
    end
    S.sources = strjoin(unique(sub.source_label), ', ');
    S.flags = strjoin(unique(sub.flag_norm), ', ');
    S.D_range = rangeString(sub.Dia_in);
    S.L_range = rangeString(sub.Length_in);
    S.LD_range = rangeString(sub.L_over_D);
    S.G_range = rangeString(sub.G_1e6_lb_hr_ft2);
    S.Hsub_range = rangeString(sub.InletSubcool_BTUlb);
    S.x_report_range = rangeString(sub.ExitQuality);
    S.frac_x_le_0 = mean(sub.ExitQuality <= 0, 'omitnan');
    S.frac_x_le_005 = mean(sub.ExitQuality <= 0.05, 'omitnan');
    S.frac_legacy = mean(sub.legacy_selected_flag, 'omitnan');
    if any(sub.TmTsat_available_flag)
        S.frac_Tm_gt_Tsat_available = mean(sub.Tm_gt_Tsat_flag(sub.TmTsat_available_flag), 'omitnan');
    else
        S.frac_Tm_gt_Tsat_available = NaN;
    end
end

function str = rangeString(x)
    x = x(isfinite(x));
    if isempty(x)
        str = "";
    else
        str = string(sprintf('%.4g - %.4g', min(x), max(x)));
    end
end

function S = summarizeByGroup(T, groupVar)
    groups = unique(T.(groupVar));
    S = table;
    for i = 1:numel(groups)
        mask = T.(groupVar)==groups(i);
        row = summarizeOne(T(mask,:));
        row.(groupVar) = groups(i);
        S = [S; row]; %#ok<AGROW>
    end
    S = movevars(S, groupVar, 'Before', 1);
end

function S = summarizeLegacy(T)
    labels = ["raw_all"; "legacy_selected"; "not_legacy"; "source01_lowX_not_legacy"; "Tm_gt_Tsat_available"; "Tm_le_Tsat_available"];
    masks = {true(height(T),1), T.legacy_selected_flag, ~T.legacy_selected_flag, T.source_label=="source01" & T.lowX_le_005 & ~T.legacy_selected_flag, T.TmTsat_available_flag & T.Tm_gt_Tsat_flag, T.TmTsat_available_flag & ~T.Tm_gt_Tsat_flag};
    S = table;
    for i = 1:numel(labels)
        row = summarizeOne(T(masks{i},:));
        row.group = labels(i);
        S = [S; row]; %#ok<AGROW>
    end
    S = movevars(S, 'group', 'Before', 1);
end

function writeTableSafe(T, outXlsx, sheet)
    if isempty(T)
        T = table(string.empty(0,1), 'VariableNames', {'empty'});
    end
    try
        writetable(T, outXlsx, 'Sheet', sheet, 'WriteMode', 'overwritesheet');
    catch
        % Older MATLAB may not support WriteMode.
        writetable(T, outXlsx, 'Sheet', sheet);
    end
end

function R = makeReadmeTable(legacyMode, manualLegacySource, nRaw, nLegacyIDs, nTmAudit)
    item = [
        "run_position";
        "raw_rows";
        "legacy_mode";
        "manual_legacy_source";
        "legacy_id_count";
        "TmTsat_audit_rows";
        "important_note_1";
        "important_note_2";
        "important_note_3";
        "recommended_next"
    ];
    value = [
        "Audit only; no adopted points decided";
        string(nRaw);
        legacyMode;
        manualLegacySource;
        string(nLegacyIDs);
        string(nTmAudit);
        "Table10 legacy set is treated as initial strict/good-data set, not as universal screening rule";
        "Table11/12 were later added more loosely to obtain large L/D points";
        "If rebuilding F1, Tm>Tsat cuts should be audited but not automatically inherited";
        "Upload run_report_T10R01b_*.md for interpretation and log append"
    ];
    R = table(item, value);
end

function figFile = makeBarFigure(labels, vals, ttl, xlab, ylab, figFile)
    f = figure('Visible','off');
    bar(vals);
    set(gca, 'XTick', 1:numel(labels), 'XTickLabel', labels);
    xtickangle(35);
    ylabel(ylab); xlabel(xlab); title(ttl);
    grid on;
    set(f, 'Position', [100 100 1100 600]);
    exportgraphics(f, figFile, 'Resolution', 180);
    close(f);
end

function figFile = makeScatterFigure(T, figFile)
    f = figure('Visible','off'); hold on;
    maskLegacy = T.legacy_selected_flag;
    maskNewLow = ~T.legacy_selected_flag & T.source_label=="source01" & T.lowX_le_005;
    maskOther = ~(maskLegacy | maskNewLow);
    scatter(T.G_1e6_lb_hr_ft2(maskOther), T.ExitQuality(maskOther), 20, 'o', 'DisplayName', 'other');
    scatter(T.G_1e6_lb_hr_ft2(maskNewLow), T.ExitQuality(maskNewLow), 32, 's', 'DisplayName', 'source01 lowX not legacy');
    scatter(T.G_1e6_lb_hr_ft2(maskLegacy), T.ExitQuality(maskLegacy), 40, '^', 'DisplayName', 'legacy');
    yline(0, '--'); yline(0.05, '--');
    xlabel('G [10^6 lb/(hr ft^2)]'); ylabel('Exit quality / x report');
    title('Table10 x report vs G: legacy and low-x candidates');
    legend('Location','best'); grid on;
    set(f, 'Position', [100 100 1100 700]);
    exportgraphics(f, figFile, 'Resolution', 180);
    close(f);
end

function writeMarkdownReport(outMd, runName, ts, mdFile, outXlsx, T, setSummary, sourceSummary, flagSummary, legacySummary, legacyScan, tmAudit, figFiles, legacyMode, manualLegacySource)
    fid = fopen(outMd, 'w');
    assert(fid>0, 'Cannot open report file for writing.');
    c = onCleanup(@() fclose(fid));

    fprintf(fid, '# %s\n\n', runName);
    fprintf(fid, '作成日時: `%s`\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid, '## 1. 目的\n\n');
    fprintf(fid, 'T&M Table10の旧採用点について、初期検討用にかなり絞った「良いデータ集合」だった可能性を前提に、Table10全649行との関係を監査する。\n\n');
    fprintf(fid, 'また、後から手で切った可能性がある条件、特にF1適用時にTmが飽和温度を越した点を除外した可能性について、利用可能な計算ブック内にTm/Tsat列があれば照合する。\n\n');
    fprintf(fid, 'このrunでは採用点を決めない。F1を作り直す可能性がある場合、過去のTm>Tsat除外条件をそのまま継承するかどうかは別判断とする。\n\n');

    fprintf(fid, '## 2. 時系列認識の修正\n\n');
    fprintf(fid, '今回の前提は以下である。\n\n');
    fprintf(fid, '```text\n');
    fprintf(fid, 'Table10初期抽出:\n');
    fprintf(fid, '  初期検討だったため、まず信頼しやすい・扱いやすいデータをかなり絞った。\n');
    fprintf(fid, '  G範囲や手作業除外は、この初期厳選の結果である可能性がある。\n\n');
    fprintf(fid, 'Table11/12追加:\n');
    fprintf(fid, '  後からL/Dの大きい点が欲しくなって追加した。\n');
    fprintf(fid, '  Table10旧採用点ほど厳密な抽出思想ではない。\n');
    fprintf(fid, '```\n\n');

    fprintf(fid, '## 3. 入力\n\n');
    fprintf(fid, '- Table10正本Markdown: `%s`\n', string(mdFile));
    fprintf(fid, '- 出力Excel: `%s`\n', outXlsx);
    fprintf(fid, '- legacy mode: `%s`\n', legacyMode);
    fprintf(fid, '- manual legacy source: `%s`\n\n', manualLegacySource);

    fprintf(fid, '## 4. QC\n\n');
    fprintf(fid, '- Parsed Table10 rows: `%d`\n', height(T));
    fprintf(fid, '- legacy IDs used: `%d`\n', numel(unique(T.ExptNo(T.legacy_selected_flag))));
    fprintf(fid, '- Tm/Tsat audit raw rows: `%d`\n', height(tmAudit));
    fprintf(fid, '- Tm/Tsat available Table10 rows: `%d`\n', sum(T.TmTsat_available_flag));
    fprintf(fid, '- Tm > Tsat rows among available: `%d`\n\n', sum(T.TmTsat_available_flag & T.Tm_gt_Tsat_flag));

    fprintf(fid, '## 5. Source summary\n\n');
    writeMdTable(fid, sourceSummary);
    fprintf(fid, '\n## 6. Flag summary\n\n');
    writeMdTable(fid, flagSummary);
    fprintf(fid, '\n## 7. Candidate set summary\n\n');
    fprintf(fid, '以下は採用判断ではなく、抽出思想を比較するための候補集合である。\n\n');
    writeMdTable(fid, setSummary);

    fprintf(fid, '\n## 8. Legacy scan\n\n');
    if isempty(legacyScan)
        fprintf(fid, 'legacy-like workbook rows were not detected. If exact legacy 86 IDs are needed, create `Table10_legacy86_exptno.txt`.\n\n');
    else
        writeMdTable(fid, legacyScan);
    end

    fprintf(fid, '\n## 9. Tm/Tsat audit\n\n');
    if isempty(tmAudit)
        fprintf(fid, 'Tm/Tsat columns were not found in scanned workbooks. Therefore, the suspected manual cut `Tm > Tsat after F1` could not be reproduced in this run.\n\n');
        fprintf(fid, 'If this cut needs to be audited, place the old calculation workbook containing ExptNo, Tm and Tsat columns in this folder and rerun.\n\n');
    else
        fprintf(fid, 'Tm/Tsat candidate rows were detected. See Excel sheets `TmTsat_audit_raw`, `TmTsat_available_rows`, and `Tm_gt_Tsat_rows`.\n\n');
        tmp = legacySummary(ismember(legacySummary.group, ["Tm_gt_Tsat_available","Tm_le_Tsat_available"]), :);
        writeMdTable(fid, tmp);
    end

    fprintf(fid, '\n## 10. 一次判断\n\n');
    fprintf(fid, 'このrunでは、Table10旧採用点を絶対基準として再現するのではなく、初期検討用の厳選集合として位置づける。\n\n');
    fprintf(fid, '重要なのは、F1を作り直す場合に、過去の手作業除外条件をそのまま継承しないことである。特に、F1適用時にTmがTsatを越した点を過去に除外していたとしても、それは「現行F1を維持して使うための品質管理」だった可能性がある。F1自体を作り直すなら、これらの点は除外ではなく、まず別管理の監査対象とする。\n\n');

    fprintf(fid, '## 11. 採用・保留\n\n');
    fprintf(fid, '```text\n');
    fprintf(fid, '採用:\n');
    fprintf(fid, '  - Table10 raw_allは649点として固定する。\n');
    fprintf(fid, '  - Table10旧採用点は、初期検討用に厳選された集合として扱う。\n');
    fprintf(fid, '  - Table11/12追加時の抽出思想とは同一視しない。\n');
    fprintf(fid, '  - Tm>Tsat疑い点は、除外ではなく別管理で監査する。\n\n');
    fprintf(fid, '保留:\n');
    fprintf(fid, '  - exact legacy 86点の確実なIDリスト。\n');
    fprintf(fid, '  - Tm>Tsat除外条件の再現。\n');
    fprintf(fid, '  - F1固定運用ならTm>Tsatを切るべきか。\n');
    fprintf(fid, '  - F1再設計ならTm>Tsat点も学習候補に戻すべきか。\n');
    fprintf(fid, '```\n\n');

    fprintf(fid, '## 12. 次アクション\n\n');
    fprintf(fid, '- exact legacy 86 ID が分かる場合は `Table10_legacy86_exptno.txt` を作り、再実行する。\n');
    fprintf(fid, '- Tm/Tsatを含む旧計算ブックを同じフォルダに置き、`Tm > Tsat` 除外候補を再現する。\n');
    fprintf(fid, '- 次runでは、`source01_lowX_not_legacy` と `Tm_gt_Tsat_rows` を照合し、過去に切った理由を分類する。\n');
    fprintf(fid, '- まだPM計算やF1再fitへは進まない。\n\n');

    fprintf(fid, '## 13. Figures\n\n');
    for i = 1:numel(figFiles)
        fprintf(fid, '- `%s`\n', figFiles(i));
    end
end

function writeMdTable(fid, T)
    if isempty(T)
        fprintf(fid, '(empty)\n');
        return;
    end
    maxRows = min(height(T), 40);
    vars = string(T.Properties.VariableNames);
    fprintf(fid, '| %s |\n', strjoin(vars, ' | '));
    fprintf(fid, '|%s|\n', strjoin(repmat("---", 1, numel(vars)), '|'));
    for r = 1:maxRows
        vals = strings(1,numel(vars));
        for c = 1:numel(vars)
            v = T{r,c};
            if isnumeric(v) || islogical(v)
                if isscalar(v)
                    if isnan(double(v))
                        vals(c) = "";
                    else
                        vals(c) = string(sprintf('%.5g', double(v)));
                    end
                else
                    vals(c) = "[array]";
                end
            else
                vals(c) = string(v);
            end
            vals(c) = replace(vals(c), "|", "/");
        end
        fprintf(fid, '| %s |\n', strjoin(vals, ' | '));
    end
    if height(T) > maxRows
        fprintf(fid, '\n... truncated to first %d rows ...\n', maxRows);
    end
end
