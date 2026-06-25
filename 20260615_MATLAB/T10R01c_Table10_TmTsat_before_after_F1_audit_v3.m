%% T10R01c_Table10_TmTsat_before_after_F1_audit_v3.m
% T&M Table10 Tm/Tsat audit separated by calculation mode (before F1 / after F1)
%
% Purpose:
%   - Treat thompson_macbeth_table10_2000psia_r1.md as Table10_raw_all.
%   - Correct the T10R01b v2 weakness: it merged Tm/Tsat rows without
%     distinguishing noF1 vs F1, and therefore could not test the user note
%     "Tm > Tsat occurs after F1, not before F1".
%   - Scan workbooks in the folder for Table10 ExptNo + Tm + Tsat columns.
%   - Classify each row by calculation mode using sheet/file names:
%       noF1, F1, F1F2, unknown.
%   - For each ExptNo and mode, keep the maximum (Tm - Tsat) as the risk value.
%   - Output audit tables only. This run does not adopt or reject points.
%
% Expected required file in the same folder:
%   thompson_macbeth_table10_2000psia_r1.md
%
% Optional files in the same folder:
%   old calculation workbooks (*.xlsx, *.xlsm) containing Table10 rows
%   Table10_legacy86_exptno.txt or .csv for exact legacy IDs
%
% Notes:
%   - Tm > Tsat after F1 is NOT automatically an exclusion criterion if F1 will be rebuilt.
%   - For fixed-F1 reproduction, it may be a QC/exclusion flag.
%   - This run keeps it as an audit flag.

clear; clc;

runName = 'T10R01c_Table10_TmTsat_before_after_F1_audit_v3';
ts = datestr(now, 'yyyymmdd_HHMMSS');
outXlsx = sprintf('T10R01c_Table10_TmTsat_before_after_F1_audit_v3_%s.xlsx', ts);
outMd   = sprintf('run_report_T10R01c_Table10_TmTsat_before_after_F1_audit_v3_%s.md', ts);

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
T.lowX_le_0 = T.ExitQuality <= 0;
T = movevars(T, {'RowID','source_code','source_label','flag_norm','L_over_D','lowX_le_005','lowX_le_0'}, 'After', 'Flag');

fprintf('Loading manual legacy IDs if present...\n');
[manualLegacyIDs, manualLegacySource] = loadManualLegacyIDs(rootDir);
if ~isempty(manualLegacyIDs)
    legacyIDs = unique(standardizeExptNo(manualLegacyIDs));
    legacyMode = "manual_legacy86_file";
else
    legacyIDs = strings(0,1);
    legacyMode = "none";
end
legacyIDs(ismissing(legacyIDs) | strlength(legacyIDs)==0) = [];
T.legacy_selected_flag = ismember(T.ExptNo, legacyIDs);

fprintf('Scanning workbooks for Tm/Tsat by mode...\n');
[tmAuditRaw, sheetScanLog, colDetectLog] = scanWorkbooksForTmTsatByMode(rootDir, T.ExptNo, outXlsx);

fprintf('Aggregating Tm/Tsat by ExptNo and mode...\n');
modeAgg = aggregateByExptMode(tmAuditRaw);
T = mergeModeAggToRaw(T, modeAgg, "noF1");
T = mergeModeAggToRaw(T, modeAgg, "F1");
T = mergeModeAggToRaw(T, modeAgg, "F1F2");
T = mergeModeAggToRaw(T, modeAgg, "unknown");

% Candidate / comparison tables.
sourceSummary = summarizeByGroup(T, 'source_label');
modeSummary = summarizeModeAgg(modeAgg);
source01LowNotLegacy = T(T.source_label=="source01" & T.lowX_le_005 & ~T.legacy_selected_flag, :);
F1Exceeded = modeAgg(modeAgg.calc_mode=="F1" & modeAgg.Tm_gt_Tsat_any, :);
noF1Exceeded = modeAgg(modeAgg.calc_mode=="noF1" & modeAgg.Tm_gt_Tsat_any, :);
F1OnlyExceededIDs = setdiff(F1Exceeded.ExptNo, noF1Exceeded.ExptNo);
F1OnlyExceeded = F1Exceeded(ismember(F1Exceeded.ExptNo, F1OnlyExceededIDs), :);

% Add Table10 metadata to exceeded rows.
F1ExceededWithMeta = joinAuditMeta(F1Exceeded, T);
noF1ExceededWithMeta = joinAuditMeta(noF1Exceeded, T);
F1OnlyExceededWithMeta = joinAuditMeta(F1OnlyExceeded, T);

fprintf('Writing Excel output: %s\n', outXlsx);
writeTableSafe(T, outXlsx, 'Table10_raw_all_mode_flags');
writeTableSafe(modeAgg, outXlsx, 'TmTsat_by_ExptNo_mode');
writeTableSafe(modeSummary, outXlsx, 'TmTsat_mode_summary');
writeTableSafe(F1ExceededWithMeta, outXlsx, 'F1_Tm_gt_Tsat_rows');
writeTableSafe(noF1ExceededWithMeta, outXlsx, 'noF1_Tm_gt_Tsat_rows');
writeTableSafe(F1OnlyExceededWithMeta, outXlsx, 'F1_only_Tm_gt_Tsat_rows');
writeTableSafe(source01LowNotLegacy, outXlsx, 'source01_lowX_not_legacy');
writeTableSafe(sourceSummary, outXlsx, 'source_summary');
writeTableSafe(tmAuditRaw, outXlsx, 'TmTsat_audit_raw');
writeTableSafe(sheetScanLog, outXlsx, 'sheet_scan_log');
writeTableSafe(colDetectLog, outXlsx, 'column_detection_log');
readme = makeReadmeTable(height(T), height(tmAuditRaw), height(modeAgg), height(F1Exceeded), height(noF1Exceeded), legacyMode, manualLegacySource);
writeTableSafe(readme, outXlsx, 'README');

fprintf('Creating figures...\n');
figFiles = strings(0,1);
try
    figFiles(end+1) = makeModeBar(modeSummary, sprintf('fig_T10R01c_01_Tm_gt_Tsat_by_mode_%s.png', ts));
catch ME
    warning('Failed to create mode bar: %s', ME.message);
end
try
    figFiles(end+1) = makeScatterMode(T, sprintf('fig_T10R01c_02_F1_TmMinusTsat_vs_G_%s.png', ts));
catch ME
    warning('Failed to create scatter: %s', ME.message);
end

fprintf('Writing Markdown report: %s\n', outMd);
writeMarkdownReport(outMd, runName, ts, mdFile, outXlsx, T, modeSummary, sourceSummary, F1ExceededWithMeta, noF1ExceededWithMeta, F1OnlyExceededWithMeta, sheetScanLog, colDetectLog, figFiles, legacyMode, manualLegacySource);

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
        error('No Table10 rows parsed from %s', mdFile);
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
            val = str2double(s);
            if isfinite(val)
                ids(k) = string(sprintf('%.2f', val));
            else
                ids(k) = missing;
            end
        else
            ids(k) = string(sprintf('%d.%02d', str2double(tok{1}), str2double(tok{2})));
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

function [tmAuditRaw, sheetScanLog, colLog] = scanWorkbooksForTmTsatByMode(rootDir, rawIDs, outXlsx)
    files = [dir(fullfile(rootDir, '*.xlsx')); dir(fullfile(rootDir, '*.xlsm'))];
    tmAuditRaw = table;
    sheetScanLog = table;
    colLog = table;
    rawSet = unique(rawIDs);
    skipNames = string(outXlsx);

    for fidx = 1:numel(files)
        fname = string(files(fidx).name);
        if any(strcmpi(fname, skipNames)); continue; end
        if startsWith(fname, '~$'); continue; end
        if startsWith(fname, "T10R00_") || startsWith(fname, "T10R01b_") || startsWith(fname, "T10R01c_"); continue; end
        fp = fullfile(rootDir, fname);
        try
            sh = sheetnames(fp);
        catch
            continue;
        end
        for sidx = 1:numel(sh)
            sheet = string(sh{sidx});
            [calcMode, contextScore, contextText] = classifyCalcMode(fname, sheet);
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
            exptCols = detectExptColumnsStrict(vars);
            [tmCols, tsatCols] = detectTmTsatColumns(vars);

            sl = table;
            sl.file = fname;
            sl.sheet = sheet;
            sl.calc_mode = calcMode;
            sl.context_score = contextScore;
            sl.context_text = contextText;
            sl.n_rows = height(tbl);
            sl.n_cols = width(tbl);
            sl.expt_cols = strjoin(vars(exptCols), ', ');
            sl.Tm_cols = strjoin(vars(tmCols), ', ');
            sl.Tsat_cols = strjoin(vars(tsatCols), ', ');
            sheetScanLog = [sheetScanLog; sl]; %#ok<AGROW>

            clog = sl(:, {'file','sheet','calc_mode','n_rows','n_cols','expt_cols','Tm_cols','Tsat_cols'});
            colLog = [colLog; clog]; %#ok<AGROW>

            if isempty(exptCols) || isempty(tmCols) || isempty(tsatCols)
                continue;
            end
            % Use all plausible combinations. This prevents accidentally selecting
            % noF1 values when F1 values exist in another sheet.
            for ec = exptCols(:)'
                exptVals = standardizeExptNo(tbl.(vars(ec)));
                for tc = tmCols(:)'
                    tmVal = toNumeric(tbl.(vars(tc)));
                    for sc = tsatCols(:)'
                        tsatVal = toNumeric(tbl.(vars(sc)));
                        n = min([numel(exptVals), numel(tmVal), numel(tsatVal)]);
                        ev = exptVals(1:n); tv = tmVal(1:n); sv = tsatVal(1:n);
                        ok = ~ismissing(ev) & strlength(ev)>0 & ismember(ev, rawSet) & isfinite(tv) & isfinite(sv);
                        if ~any(ok); continue; end
                        ta = table;
                        ta.file = repmat(fname, sum(ok), 1);
                        ta.sheet = repmat(sheet, sum(ok), 1);
                        ta.source_sheet = repmat(fname + " :: " + sheet, sum(ok), 1);
                        ta.calc_mode = repmat(calcMode, sum(ok), 1);
                        ta.context_score = repmat(contextScore, sum(ok), 1);
                        ta.context_text = repmat(contextText, sum(ok), 1);
                        ta.ExptNo = ev(ok);
                        ta.Expt_column = repmat(vars(ec), sum(ok), 1);
                        ta.Tm_column = repmat(vars(tc), sum(ok), 1);
                        ta.Tsat_column = repmat(vars(sc), sum(ok), 1);
                        ta.Tm_value = tv(ok);
                        ta.Tsat_value = sv(ok);
                        ta.Tm_minus_Tsat = ta.Tm_value - ta.Tsat_value;
                        ta.Tm_gt_Tsat_flag = ta.Tm_minus_Tsat > 0;
                        tmAuditRaw = [tmAuditRaw; ta]; %#ok<AGROW>
                    end
                end
            end
        end
    end
end

function [mode, score, text] = classifyCalcMode(fname, sheet)
    s = lower(fname + " " + sheet);
    mode = "unknown";
    score = 0;
    text = "mode_unknown";
    if contains(s, "f1f2") || contains(s, "f1_f2")
        mode = "F1F2"; score = 80; text = "sheet/file contains F1F2"; return;
    end
    if contains(s, "nof1") || contains(s, "no_f1") || contains(s, "no f1") || contains(s, "r123")
        mode = "noF1"; score = 80; text = "sheet/file contains noF1 or r123"; return;
    end
    % F1 but not F1F2 and not noF1.
    if contains(s, "f1") || contains(s, "r124")
        mode = "F1"; score = 80; text = "sheet/file contains F1 or r124"; return;
    end
    % Older table names sometimes include tm_ST only; these are usually pre-F1/raw.
    if contains(s, "tm_st") || contains(s, "st_no")
        mode = "noF1"; score = 50; text = "single tube raw/noF1-like sheet"; return;
    end
end

function exptCols = detectExptColumnsStrict(vars)
    lv = lower(vars);
    exactNames = ["exptno","expt_no","expt no","experiment_no","experiment no","no_tableno","no_table_no","t&m_expt_no","tm_expt_no","case_id"];
    exptCols = [];
    clean = regexprep(lv, '[^a-z0-9]+', '_');
    for i = 1:numel(vars)
        vi = clean(i);
        if any(strcmp(vi, exactNames)) || contains(vi, "expt") || contains(vi, "experiment") || contains(vi, "no_tableno") || contains(vi, "tm_expt") || strcmp(vi, "case_id")
            exptCols(end+1) = i; %#ok<AGROW>
        end
    end
    exptCols = unique(exptCols);
end

function [tmCols, tsatCols] = detectTmTsatColumns(vars)
    lv = lower(vars);
    clean = regexprep(lv, '[^a-z0-9]+', '_');
    tmCols = find((strcmp(clean,"tm") | strcmp(clean,"tm_k") | contains(clean,"t_m") | contains(clean,"tmean") | contains(clean,"t_mean")) & ~contains(clean,"timestamp") & ~contains(clean,"time") & ~contains(clean,"tsub"));
    tsatCols = find(strcmp(clean,"tsat") | strcmp(clean,"tsat_k") | contains(clean,"t_sat") | contains(clean,"sat_temp") | contains(clean,"saturation") | strcmp(clean,"ts"));
    tsatCols = tsatCols(~contains(clean(tsatCols), "tsub"));
end

function y = toNumeric(x)
    if isnumeric(x)
        y = double(x);
    else
        y = str2double(string(x));
    end
    y = y(:);
end

function modeAgg = aggregateByExptMode(tmAuditRaw)
    modeAgg = table;
    if isempty(tmAuditRaw); return; end
    tmAuditRaw.ExptNo = standardizeExptNo(tmAuditRaw.ExptNo);
    tmAuditRaw.calc_mode = string(tmAuditRaw.calc_mode);
    keys = unique(tmAuditRaw(:, {'ExptNo','calc_mode'}), 'rows');
    for i = 1:height(keys)
        mask = tmAuditRaw.ExptNo==keys.ExptNo(i) & tmAuditRaw.calc_mode==keys.calc_mode(i);
        sub = tmAuditRaw(mask,:);
        row = table;
        row.ExptNo = keys.ExptNo(i);
        row.calc_mode = keys.calc_mode(i);
        row.N_rows = height(sub);
        row.N_sources = numel(unique(sub.source_sheet));
        row.Tm_minus_Tsat_min = min(sub.Tm_minus_Tsat, [], 'omitnan');
        row.Tm_minus_Tsat_max = max(sub.Tm_minus_Tsat, [], 'omitnan');
        row.Tm_minus_Tsat_mean = mean(sub.Tm_minus_Tsat, 'omitnan');
        row.Tm_gt_Tsat_any = any(sub.Tm_gt_Tsat_flag);
        [~, imax] = max(sub.Tm_minus_Tsat);
        row.max_source_sheet = sub.source_sheet(imax);
        row.max_Tm_column = sub.Tm_column(imax);
        row.max_Tsat_column = sub.Tsat_column(imax);
        row.max_Tm_value = sub.Tm_value(imax);
        row.max_Tsat_value = sub.Tsat_value(imax);
        modeAgg = [modeAgg; row]; %#ok<AGROW>
    end
end

function T = mergeModeAggToRaw(T, modeAgg, mode)
    safe = matlab.lang.makeValidName("Tm_" + mode + "_available");
    safeDelta = matlab.lang.makeValidName("TmMinusTsat_" + mode + "_max");
    safeGt = matlab.lang.makeValidName("TmGtTsat_" + mode + "_any");
    safeSrc = matlab.lang.makeValidName("TmTsat_" + mode + "_source");
    T.(safe) = false(height(T),1);
    T.(safeDelta) = nan(height(T),1);
    T.(safeGt) = false(height(T),1);
    T.(safeSrc) = strings(height(T),1);
    if isempty(modeAgg); return; end
    sub = modeAgg(modeAgg.calc_mode==mode,:);
    if isempty(sub); return; end
    [tf, loc] = ismember(T.ExptNo, sub.ExptNo);
    T.(safe)(tf) = true;
    T.(safeDelta)(tf) = sub.Tm_minus_Tsat_max(loc(tf));
    T.(safeGt)(tf) = sub.Tm_gt_Tsat_any(loc(tf));
    T.(safeSrc)(tf) = sub.max_source_sheet(loc(tf));
end

function S = summarizeModeAgg(modeAgg)
    S = table;
    modes = ["noF1";"F1";"F1F2";"unknown"];
    for i = 1:numel(modes)
        m = modes(i);
        sub = modeAgg(modeAgg.calc_mode==m,:);
        row = table;
        row.calc_mode = m;
        row.N_expt = height(sub);
        if height(sub)==0
            row.N_Tm_gt_Tsat = 0;
            row.frac_Tm_gt_Tsat = NaN;
            row.TmMinusTsat_max_range = "";
            row.Expt_range = "";
        else
            row.N_Tm_gt_Tsat = sum(sub.Tm_gt_Tsat_any);
            row.frac_Tm_gt_Tsat = mean(sub.Tm_gt_Tsat_any);
            row.TmMinusTsat_max_range = rangeString(sub.Tm_minus_Tsat_max);
            nums = str2double(sub.ExptNo);
            row.Expt_range = rangeString(nums);
        end
        S = [S; row]; %#ok<AGROW>
    end
end

function J = joinAuditMeta(A, T)
    if isempty(A)
        J = A;
        return;
    end
    meta = T(:, {'ExptNo','source_label','flag_norm','Dia_in','Length_in','L_over_D','G_1e6_lb_hr_ft2','InletSubcool_BTUlb','ExitQuality','lowX_le_005','legacy_selected_flag'});
    J = outerjoin(A, meta, 'Keys', 'ExptNo', 'MergeKeys', true, 'Type', 'left');
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

function S = summarizeOne(sub)
    S = table;
    S.N = height(sub);
    if height(sub)==0
        S.sources = ""; S.flags = ""; S.D_range=""; S.L_range=""; S.LD_range=""; S.G_range=""; S.Hsub_range=""; S.x_report_range="";
        S.frac_x_le_0=NaN; S.frac_x_le_005=NaN; S.frac_legacy=NaN;
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
end

function str = rangeString(x)
    x = x(isfinite(x));
    if isempty(x)
        str = "";
    else
        str = string(sprintf('%.4g - %.4g', min(x), max(x)));
    end
end

function writeTableSafe(T, outXlsx, sheet)
    if isempty(T)
        T = table(string.empty(0,1), 'VariableNames', {'empty'});
    end
    try
        writetable(T, outXlsx, 'Sheet', sheet, 'WriteMode', 'overwritesheet');
    catch
        writetable(T, outXlsx, 'Sheet', sheet);
    end
end

function R = makeReadmeTable(nRaw, nAudit, nAgg, nF1Gt, nNoF1Gt, legacyMode, manualLegacySource)
    item = ["run_position";"raw_rows";"TmTsat_raw_rows";"TmTsat_ExptNo_mode_rows";"F1_Tm_gt_Tsat_rows";"noF1_Tm_gt_Tsat_rows";"legacy_mode";"manual_legacy_source";"important_note_1";"important_note_2";"recommended_next"];
    value = ["Audit only; separates noF1 and F1"; string(nRaw); string(nAudit); string(nAgg); string(nF1Gt); string(nNoF1Gt); legacyMode; manualLegacySource; "T10R01b v2 did not distinguish before/after F1; use this v3 for Tm>Tsat after-F1 audit"; "Do not automatically exclude F1 Tm>Tsat rows if rebuilding F1"; "Upload run_report_T10R01c_*.md for interpretation"];
    R = table(item, value);
end

function figFile = makeModeBar(modeSummary, figFile)
    f = figure('Visible','off');
    bar(modeSummary.N_Tm_gt_Tsat);
    set(gca, 'XTick', 1:height(modeSummary), 'XTickLabel', modeSummary.calc_mode);
    ylabel('N with Tm > Tsat'); xlabel('calculation mode');
    title('Tm > Tsat count by calculation mode'); grid on;
    set(f, 'Position', [100 100 900 550]);
    exportgraphics(f, figFile, 'Resolution', 180);
    close(f);
end

function figFile = makeScatterMode(T, figFile)
    f = figure('Visible','off'); hold on;
    y = T.TmMinusTsat_F1_max;
    ok = T.Tm_F1_available & isfinite(y);
    scatter(T.G_1e6_lb_hr_ft2(ok & ~T.TmGtTsat_F1_any), y(ok & ~T.TmGtTsat_F1_any), 25, 'o', 'DisplayName', 'F1 Tm<=Tsat');
    scatter(T.G_1e6_lb_hr_ft2(ok & T.TmGtTsat_F1_any), y(ok & T.TmGtTsat_F1_any), 45, '^', 'DisplayName', 'F1 Tm>Tsat');
    yline(0, '--'); xlabel('G [10^6 lb/(hr ft^2)]'); ylabel('max(Tm - Tsat) after F1');
    title('After-F1 Tm - Tsat vs G'); legend('Location','best'); grid on;
    set(f, 'Position', [100 100 1000 650]);
    exportgraphics(f, figFile, 'Resolution', 180);
    close(f);
end

function writeMarkdownReport(outMd, runName, ts, mdFile, outXlsx, T, modeSummary, sourceSummary, F1ExceededWithMeta, noF1ExceededWithMeta, F1OnlyExceededWithMeta, sheetScanLog, colDetectLog, figFiles, legacyMode, manualLegacySource)
    fid = fopen(outMd, 'w');
    assert(fid>0, 'Cannot open report file.');
    c = onCleanup(@() fclose(fid)); %#ok<NASGU>
    fprintf(fid, '# %s\n\n', runName);
    fprintf(fid, '作成日時: `%s`\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fprintf(fid, '## 1. 目的\n\n');
    fprintf(fid, 'T10R01b v2ではTm/Tsatを監査したが、F1適用前(noF1)とF1適用後(F1)を明示的に分けていなかった。\n\n');
    fprintf(fid, 'このrunでは、ユーザーコメント「F1適用後にTm>Tsat、F1適用前は該当なし」を確認するため、計算モード別にTm/Tsatを監査する。\n\n');
    fprintf(fid, 'このrunでも採用点は決めない。F1再設計時にはTm>Tsatを除外条件ではなく監査フラグとして扱う。\n\n');
    fprintf(fid, '## 2. 入力\n\n');
    fprintf(fid, '- Table10正本Markdown: `%s`\n', string(mdFile));
    fprintf(fid, '- 出力Excel: `%s`\n', outXlsx);
    fprintf(fid, '- legacy mode: `%s`\n', legacyMode);
    fprintf(fid, '- manual legacy source: `%s`\n\n', manualLegacySource);
    fprintf(fid, '## 3. QC\n\n');
    fprintf(fid, '- Parsed Table10 rows: `%d`\n', height(T));
    fprintf(fid, '- Rows with noF1 Tm/Tsat available: `%d`\n', sum(T.Tm_noF1_available));
    fprintf(fid, '- Rows with F1 Tm/Tsat available: `%d`\n', sum(T.Tm_F1_available));
    fprintf(fid, '- noF1 rows with Tm > Tsat: `%d`\n', height(noF1ExceededWithMeta));
    fprintf(fid, '- F1 rows with Tm > Tsat: `%d`\n', height(F1ExceededWithMeta));
    fprintf(fid, '- F1-only Tm > Tsat rows: `%d`\n\n', height(F1OnlyExceededWithMeta));
    fprintf(fid, '## 4. Mode summary\n\n');
    writeMdTable(fid, modeSummary);
    fprintf(fid, '\n## 5. Source summary\n\n');
    writeMdTable(fid, sourceSummary);
    fprintf(fid, '\n## 6. noF1 Tm > Tsat rows\n\n');
    writeMdTable(fid, noF1ExceededWithMeta);
    fprintf(fid, '\n## 7. F1 Tm > Tsat rows\n\n');
    writeMdTable(fid, F1ExceededWithMeta);
    fprintf(fid, '\n## 8. F1-only Tm > Tsat rows\n\n');
    writeMdTable(fid, F1OnlyExceededWithMeta);
    fprintf(fid, '\n## 9. Sheet scan log\n\n');
    writeMdTable(fid, sheetScanLog);
    fprintf(fid, '\n## 10. Column detection log\n\n');
    writeMdTable(fid, colDetectLog);
    fprintf(fid, '\n## 11. 一次判断テンプレート\n\n');
    fprintf(fid, '```text\n');
    fprintf(fid, 'T10R01b v2の「Tm>Tsat=0」は、F1前後を分けていないため、F1適用後の除外条件を再現したものとは扱わない。\n');
    fprintf(fid, 'T10R01c v3では、noF1とF1を分けてTm/Tsatを確認した。\n');
    fprintf(fid, 'F1後にのみTm>Tsatが出る場合、それは現行F1固定運用のQC条件としては意味があるが、F1再設計では自動除外せず監査フラグとして保持する。\n');
    fprintf(fid, '```\n\n');
    fprintf(fid, '## 12. 次アクション\n\n');
    fprintf(fid, '- run_report_T10R01c_*.mdを確認し、F1後Tm>Tsat点の有無とIDをログへ追記する。\n');
    fprintf(fid, '- F1固定用集合ではTm>Tsat除外あり/なしを分ける。\n');
    fprintf(fid, '- F1再設計用集合ではTm>Tsat点を除外せず、監査フラグとして保持する。\n\n');
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
        for cc = 1:numel(vars)
            v = T{r,cc};
            if isnumeric(v) || islogical(v)
                if isscalar(v)
                    if isnan(double(v))
                        vals(cc) = "";
                    else
                        vals(cc) = string(sprintf('%.5g', double(v)));
                    end
                else
                    vals(cc) = "[array]";
                end
            else
                vals(cc) = string(v);
            end
            vals(cc) = replace(vals(cc), "|", "/");
        end
        fprintf(fid, '| %s |\n', strjoin(vals, ' | '));
    end
    if height(T) > maxRows
        fprintf(fid, '\n... truncated to first %d rows ...\n', maxRows);
    end
end
