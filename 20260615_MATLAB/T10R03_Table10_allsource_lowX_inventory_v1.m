%% T10R03_Table10_allsource_lowX_inventory_v1
% Purpose:
%   Inventory T&M Table10 low-X candidates across ALL sources.
%   This run does NOT decide adoption and does NOT refit F1.
%
% Main screening:
%   lowX = ExitQuality <= 0.05
%
% Then stratify by:
%   source, flag, G range, D, L/D, Hsub, x_report
%
% Expected file in the same folder as this script:
%   thompson_macbeth_table10_2000psia_r1.md
%
% Outputs:
%   T10R03_Table10_allsource_lowX_inventory_v1_YYYYMMDD_HHMMSS.xlsx
%   run_report_T10R03_Table10_allsource_lowX_inventory_v1_YYYYMMDD_HHMMSS.md
%   source-colored figures

clear; clc;

scriptName = 'T10R03_Table10_allsource_lowX_inventory_v1';
rootDir = fileparts(mfilename('fullpath'));
if isempty(rootDir); rootDir = pwd; end
cd(rootDir);

ts = datestr(now, 'yyyymmdd_HHMMSS');
outXlsx = fullfile(rootDir, sprintf('T10R03_Table10_allsource_lowX_inventory_v1_%s.xlsx', ts));
outMd   = fullfile(rootDir, sprintf('run_report_T10R03_Table10_allsource_lowX_inventory_v1_%s.md', ts));

fprintf('Parsing Table10 Markdown...\n');
mdPath = fullfile(rootDir, 'thompson_macbeth_table10_2000psia_r1.md');
assert(isfile(mdPath), 'Required file not found: %s', mdPath);
T = parseTable10Markdown(mdPath);

fprintf('Building all-source lowX inventory...\n');
T = addInventoryFlags(T);
allLowX = T(T.lowX, :);

sourceSummaryAll = summarizeByGroup(T, 'source');
sourceSummaryLowX = summarizeByGroup(allLowX, 'source');
flagSummaryLowX = summarizeByGroup(allLowX, 'flag');
GbinSummaryLowX = summarizeByGroup(allLowX, 'G_bin');
setSummary = summarizeSets(T);

fprintf('Writing Excel output: %s\n', outXlsx);
writeTableSafe(T, outXlsx, 'raw_all');
writeTableSafe(allLowX, outXlsx, 'all_lowX');
writeTableSafe(setSummary, outXlsx, 'set_summary');
writeTableSafe(sourceSummaryAll, outXlsx, 'source_summary_all');
writeTableSafe(sourceSummaryLowX, outXlsx, 'source_summary_lowX');
writeTableSafe(flagSummaryLowX, outXlsx, 'flag_summary_lowX');
writeTableSafe(GbinSummaryLowX, outXlsx, 'Gbin_summary_lowX');

fprintf('Creating source-colored figures...\n');
figFiles = createFigures(T, allLowX, ts, rootDir);

fprintf('Writing Markdown report: %s\n', outMd);
writeReport(outMd, scriptName, ts, mdPath, outXlsx, T, allLowX, setSummary, ...
    sourceSummaryAll, sourceSummaryLowX, flagSummaryLowX, GbinSummaryLowX, figFiles);

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
        if isempty(regexp(char(first), '^\d+\.\d+$', 'once')); continue; end
        rows(end+1, :) = parts(1:8); %#ok<AGROW>
    end
    if isempty(rows)
        error('No Table10 data rows were parsed from %s', mdPath);
    end

    n = size(rows,1);
    ExptNo = strings(n,1);
    Dia_in = nan(n,1);
    Len_in = nan(n,1);
    G_1e6 = nan(n,1);
    Hsub_BTUlb = nan(n,1);
    qCHF_1e6 = nan(n,1);
    x_report = nan(n,1);
    flag = strings(n,1);

    for r = 1:n
        ExptNo(r) = canonicalExptNo(rows{r,1});
        Dia_in(r) = toDouble(rows{r,2});
        Len_in(r) = toDouble(rows{r,3});
        G_1e6(r) = toDouble(rows{r,4});
        Hsub_BTUlb(r) = toDouble(rows{r,5});
        qCHF_1e6(r) = toDouble(rows{r,6});
        x_report(r) = toDouble(rows{r,7});
        fl = upper(strtrim(string(rows{r,8})));
        if fl == "" || lower(fl) == "nan" || lower(fl) == "none" || fl == "-"
            fl = "none";
        end
        flag(r) = fl;
    end

    src_no = nan(n,1);
    suffix = strings(n,1);
    for r = 1:n
        tok = regexp(char(ExptNo(r)), '^(\d+)\.(\d+)$', 'tokens', 'once');
        if ~isempty(tok)
            src_no(r) = str2double(tok{2});
            suffix(r) = string(tok{2});
        end
    end
    source = "source" + suffix;
    LD = Len_in ./ Dia_in;
    G_kgm2s = G_1e6 * 1356.23;
    Hsub_kJkg = Hsub_BTUlb * 2.326;
    qCHF_MWm2 = qCHF_1e6 * 3.15459;

    T = table(ExptNo, src_no, source, flag, Dia_in, Len_in, LD, G_1e6, G_kgm2s, ...
        Hsub_BTUlb, Hsub_kJkg, qCHF_1e6, qCHF_MWm2, x_report);
end

function T = addInventoryFlags(T)
    T.lowX = T.x_report <= 0.05;
    T.x_le_0 = T.x_report <= 0;
    T.clean_flag = T.flag == "none";
    T.G_legacy_1p6_3p0 = T.G_1e6 >= 1.6 & T.G_1e6 <= 3.0;
    T.G_PWR_1p77_2p95 = T.G_1e6 >= 1.77 & T.G_1e6 <= 2.95;
    T.G_bin = strings(height(T),1);
    T.G_bin(T.G_1e6 < 1.0) = "G_lt_1p0";
    T.G_bin(T.G_1e6 >= 1.0 & T.G_1e6 < 1.6) = "G_1p0_1p6";
    T.G_bin(T.G_1e6 >= 1.6 & T.G_1e6 <= 3.0) = "G_1p6_3p0";
    T.G_bin(T.G_1e6 > 3.0 & T.G_1e6 <= 4.0) = "G_3p0_4p0";
    T.G_bin(T.G_1e6 > 4.0) = "G_gt_4p0";
    T.G_bin(T.G_bin == "") = "G_unknown";
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

function S = summarizeSets(T)
    sets = struct();
    sets.raw_all = true(height(T),1);
    sets.all_lowX = T.lowX;
    sets.all_lowX_cleanFlag = T.lowX & T.clean_flag;
    sets.all_lowX_G_1p6_3p0 = T.lowX & T.G_legacy_1p6_3p0;
    sets.all_lowX_G_1p77_2p95 = T.lowX & T.G_PWR_1p77_2p95;
    sets.all_lowX_clean_G_1p6_3p0 = T.lowX & T.clean_flag & T.G_legacy_1p6_3p0;
    sets.source01_lowX = T.lowX & T.source == "source01";
    sets.source09_lowX = T.lowX & T.source == "source09";
    sets.other_lowX = T.lowX & ~(T.source == "source01" | T.source == "source09");

    names = fieldnames(sets);
    S = table();
    for i = 1:numel(names)
        nm = names{i};
        tmp = summarizeOneSet(T(sets.(nm), :), string(nm));
        S = [S; tmp]; %#ok<AGROW>
    end
end

function S = summarizeByGroup(T, groupVar)
    if height(T) == 0
        S = table();
        return;
    end
    g = string(T.(groupVar));
    ug = unique(g, 'stable');
    S = table();
    for i = 1:numel(ug)
        idx = g == ug(i);
        tmp = summarizeOneSet(T(idx,:), ug(i));
        S = [S; tmp]; %#ok<AGROW>
    end
    S.Properties.VariableNames{1} = groupVar;
end

function S = summarizeOneSet(T, label)
    if height(T) == 0
        S = table(label, 0, "", "", "", "", "", "", "", "", "", "", ...
            'VariableNames', {'set','N','sources','flags','D_range','L_range','LD_range','G_range','Hsub_range','x_range','frac_x_le_0','frac_lowX'});
        return;
    end
    S = table(label, height(T), join(unique(string(T.source),'stable'), ', '), join(unique(string(T.flag),'stable'), ', '), ...
        rangeText(T.Dia_in), rangeText(T.Len_in), rangeText(T.LD), rangeText(T.G_1e6), ...
        rangeText(T.Hsub_kJkg), rangeText(T.x_report), mean(T.x_le_0,'omitnan'), mean(T.lowX,'omitnan'), ...
        'VariableNames', {'set','N','sources','flags','D_range','L_range','LD_range','G_range','Hsub_range','x_range','frac_x_le_0','frac_lowX'});
end

function s = rangeText(x)
    x = x(~isnan(x));
    if isempty(x)
        s = "";
    else
        s = string(sprintf('%.4g - %.4g', min(x), max(x)));
    end
end

function writeTableSafe(T, outXlsx, sheetName)
    if isempty(T)
        T = table();
    end
    writetable(T, outXlsx, 'Sheet', sheetName, 'WriteMode', 'overwritesheet');
end

function figFiles = createFigures(T, allLowX, ts, rootDir)
    figFiles = strings(0,1);
    figFiles(end+1,1) = sourceScatter(allLowX, 'G_1e6', 'x_report', ...
        'G [10^6 lb/hr/ft^2]', 'x report', ...
        'Table10 lowX candidates: x vs G by source', ...
        fullfile(rootDir, sprintf('fig_T10R03_01_lowX_x_vs_G_by_source_%s.png', ts)));
    figFiles(end+1,1) = sourceScatter(allLowX, 'G_1e6', 'Hsub_kJkg', ...
        'G [10^6 lb/hr/ft^2]', 'Hsub [kJ/kg]', ...
        'Table10 lowX candidates: Hsub vs G by source', ...
        fullfile(rootDir, sprintf('fig_T10R03_02_lowX_Hsub_vs_G_by_source_%s.png', ts)));
    figFiles(end+1,1) = sourceScatter(allLowX, 'LD', 'G_1e6', ...
        'L/D', 'G [10^6 lb/hr/ft^2]', ...
        'Table10 lowX candidates: G vs L/D by source', ...
        fullfile(rootDir, sprintf('fig_T10R03_03_lowX_G_vs_LD_by_source_%s.png', ts)));
    figFiles(end+1,1) = sourceScatter(T, 'G_1e6', 'x_report', ...
        'G [10^6 lb/hr/ft^2]', 'x report', ...
        'Table10 raw all: x vs G by source', ...
        fullfile(rootDir, sprintf('fig_T10R03_04_raw_x_vs_G_by_source_%s.png', ts)));
end

function fpath = sourceScatter(T, xVar, yVar, xlab, ylab, ttl, fpath)
    fig = figure('Visible','off');
    hold on; box on; grid on;
    src = unique(string(T.source), 'stable');
    C = lines(max(1,numel(src)));
    for i = 1:numel(src)
        idx = string(T.source) == src(i) & ~isnan(T.(xVar)) & ~isnan(T.(yVar));
        if any(idx)
            scatter(T.(xVar)(idx), T.(yVar)(idx), 28, C(i,:), 'filled', 'DisplayName', char(src(i)), 'MarkerFaceAlpha', 0.75);
        end
    end
    xlabel(xlab, 'Interpreter','none');
    ylabel(ylab, 'Interpreter','none');
    title(ttl, 'Interpreter','none');
    legend('Location','best', 'Interpreter','none');
    set(fig, 'Color', 'w');
    exportgraphics(fig, fpath, 'Resolution', 200);
    close(fig);
end

function writeReport(outMd, scriptName, ts, mdPath, outXlsx, T, allLowX, setSummary, sourceSummaryAll, sourceSummaryLowX, flagSummaryLowX, GbinSummaryLowX, figFiles)
    fid = fopen(outMd, 'w');
    assert(fid > 0, 'Could not write report: %s', outMd);
    c = onCleanup(@() fclose(fid));

    fprintf(fid, '# %s\n\n', scriptName);
    fprintf(fid, '作成日時: `%s`\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid, '## 1. 目的\n\n');
    fprintf(fid, 'T&M Table10のlowX候補を、source01に限定せず、全sourceで棚卸しする。\n\n');
    fprintf(fid, 'このrunでは採用点を決めない。入口条件は `x_report <= 0.05` とし、その後にsource、G、flag、D、L/D、Hsubで層別する。\n\n');

    fprintf(fid, '## 2. 入力\n\n');
    fprintf(fid, '- Table10正本Markdown: `%s`\n', mdPath);
    fprintf(fid, '- 出力Excel: `%s`\n\n', outXlsx);

    fprintf(fid, '## 3. QC\n\n');
    fprintf(fid, '- Parsed Table10 rows: `%d`\n', height(T));
    fprintf(fid, '- all lowX rows (x_report <= 0.05): `%d`\n', height(allLowX));
    fprintf(fid, '- source01 lowX rows: `%d`\n', sum(allLowX.source == "source01"));
    fprintf(fid, '- source09 lowX rows: `%d`\n', sum(allLowX.source == "source09"));
    fprintf(fid, '- other-source lowX rows: `%d`\n\n', sum(~(allLowX.source == "source01" | allLowX.source == "source09")));

    fprintf(fid, '## 4. 抽出条件\n\n');
    fprintf(fid, '今回の入口条件は以下のみである。\n\n');
    fprintf(fid, '```text\n');
    fprintf(fid, 'lowX = x_report <= 0.05\n');
    fprintf(fid, '```\n\n');
    fprintf(fid, 'source、G、flagでは最初から切らない。これらは採用条件ではなく、使いやすさを見るための層別軸として扱う。\n\n');

    fprintf(fid, '## 5. Candidate set summary\n\n');
    writeMarkdownTable(fid, setSummary);

    fprintf(fid, '\n## 6. Source summary all\n\n');
    writeMarkdownTable(fid, sourceSummaryAll);

    fprintf(fid, '\n## 7. Source summary lowX\n\n');
    writeMarkdownTable(fid, sourceSummaryLowX);

    fprintf(fid, '\n## 8. Flag summary lowX\n\n');
    writeMarkdownTable(fid, flagSummaryLowX);

    fprintf(fid, '\n## 9. G-bin summary lowX\n\n');
    writeMarkdownTable(fid, GbinSummaryLowX);

    fprintf(fid, '\n## 10. 一次判断テンプレート\n\n');
    fprintf(fid, '```text\n');
    fprintf(fid, 'T10R03では、source01に限定せず、Table10 raw_allからlowX候補を広く棚卸しした。\n');
    fprintf(fid, '入口条件はx_report<=0.05のみであり、Gやsourceやflagではまだ切らない。\n');
    fprintf(fid, 'その後、source別、G範囲別、flag別に層別し、使いやすい候補と監査が必要な候補を分ける。\n');
    fprintf(fid, 'source別の色分け図により、source01とsource09などが同じ条件空間にいるかを確認する。\n');
    fprintf(fid, 'まだF1再fitや採用点決定には進まない。\n');
    fprintf(fid, '```\n\n');

    fprintf(fid, '## 11. 次アクション\n\n');
    fprintf(fid, '- source別色分け図を確認し、source01/source09/その他がG, Hsub, L/D, x_report上でどの程度重なるかを見る。\n');
    fprintf(fid, '- Gを採用条件として固定する前に、PWR-like範囲と広域範囲を分けて感度を見る。\n');
    fprintf(fid, '- まだPM計算やF1再fitへは進まない。\n\n');

    fprintf(fid, '## 12. Figures\n\n');
    for i = 1:numel(figFiles)
        fprintf(fid, '- `%s`\n', figFiles(i));
    end
end

function writeMarkdownTable(fid, T)
    if isempty(T) || height(T) == 0
        fprintf(fid, '(empty)\n');
        return;
    end
    vars = T.Properties.VariableNames;
    fprintf(fid, '| %s |\n', strjoin(vars, ' | '));
    fprintf(fid, '|%s|\n', strjoin(repmat({'---'},1,numel(vars)), '|'));
    for r = 1:height(T)
        vals = strings(1,numel(vars));
        for c = 1:numel(vars)
            v = T.(vars{c})(r);
            if isnumeric(v) || islogical(v)
                vals(c) = string(sprintf('%.6g', v));
            elseif isstring(v) || ischar(v) || iscategorical(v)
                vals(c) = string(v);
            else
                vals(c) = string(v);
            end
            vals(c) = replace(vals(c), '|', '/');
        end
        fprintf(fid, '| %s |\n', strjoin(vals, ' | '));
    end
end
