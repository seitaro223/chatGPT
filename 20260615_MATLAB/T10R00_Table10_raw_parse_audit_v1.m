%% T10R00 / T10R01: Thompson & Macbeth Table 10 raw parse + legacy extraction audit
% Purpose:
%   - Parse thompson_macbeth_table10_2000psia_r1.md as the canonical raw Table 10.
%   - Build Table10_raw_all (all 649 rows if the markdown is complete).
%   - Summarize source codes, flags, diameter/length groups, report quality ranges.
%   - Create candidate-set flags, but DO NOT decide final adoption.
%   - Optionally compare with a legacy-selected workbook if available in the same folder.
%
% Inputs expected in the same folder:
%   required:
%     thompson_macbeth_table10_2000psia_r1.md
%   optional:
%     anl_1958_chf_claude.md
%     H52Q_current_single_tube_input_v1_20260615_183839.xlsx
%     or another workbook whose sheets contain Table10 / ExptNo columns.
%
% Outputs:
%   T10R00_table10_raw_parse_audit_v1_YYYYMMDD_HHMMSS.xlsx
%   run_report_T10R00_table10_raw_parse_audit_v1_YYYYMMDD_HHMMSS.md
%   fig_T10R00_01_source_counts_*.png
%   fig_T10R00_02_x_report_vs_G_by_source_*.png
%   fig_T10R00_03_Hsub_vs_G_by_source_*.png
%   fig_T10R00_04_candidate_set_counts_*.png
%
% Notes:
%   This run is an audit gate. Candidate sets are labels, not final adopted data.
%   qM / qP / PM calculations are intentionally not performed here.

clear; clc;

%% User settings
mdFile = 'thompson_macbeth_table10_2000psia_r1.md';
anlFile = 'anl_1958_chf_claude.md';

% Optional legacy workbook search. Put the old selected workbook in this folder if you want matching.
legacyWorkbookCandidates = { ...
    'H52Q_current_single_tube_input_v1_20260615_183839.xlsx', ...
    'H52Q_current_single_tube_input_v2_20260615_183839.xlsx', ...
    'H52Q_current_single_tube_input.xlsx'};

% Candidate-set thresholds for audit only.
xLowLimit = 0.05;        % low-quality / near-subcooled threshold
xSubcooledLimit = 0.0;   % subcooled threshold
G_min_PWRlike = 1.0;     % loose diagnostic only: not final screening
G_max_PWRlike = 8.0;     % loose diagnostic only: not final screening

%% Output names
stamp = datestr(now,'yyyymmdd_HHMMSS');
outXlsx = ['T10R00_table10_raw_parse_audit_v1_' stamp '.xlsx'];
outMd   = ['run_report_T10R00_table10_raw_parse_audit_v1_' stamp '.md'];
fig1 = ['fig_T10R00_01_source_counts_' stamp '.png'];
fig2 = ['fig_T10R00_02_x_report_vs_G_by_source_' stamp '.png'];
fig3 = ['fig_T10R00_03_Hsub_vs_G_by_source_' stamp '.png'];
fig4 = ['fig_T10R00_04_candidate_set_counts_' stamp '.png'];

%% Locate input
if ~isfile(mdFile)
    error('Required markdown file not found: %s', mdFile);
end

%% Parse T&M Table 10 markdown
rawText = fileread(mdFile);
T = local_parse_tm_table10_markdown(rawText);

% Derived variables
T.SourceCode = local_source_from_expt(T.ExptNo_str);
T.ExptRunNo  = local_run_from_expt(T.ExptNo_str);
T.L_over_D   = T.Length_in ./ T.Dia_in;
T.flag_norm  = string(T.flag);
T.flag_norm(strlength(T.flag_norm)==0) = "none";
T.source_label = "source" + compose('%02.0f', T.SourceCode);
T.dia_len_group = "D=" + compose('%.4g',T.Dia_in) + "in, L=" + compose('%.4g',T.Length_in) + "in";

% Candidate audit flags. These are NOT final adoption decisions.
T.is_source01 = T.SourceCode == 1;
T.is_source09 = T.SourceCode == 9;
T.is_source11 = T.SourceCode == 11;
T.is_flag_none = T.flag_norm == "none";
T.is_flag_J = T.flag_norm == "J";
T.is_flag_DJ = T.flag_norm == "DJ";
T.is_flag_CGH = ismember(T.flag_norm, ["C","G","H"]);
T.is_x_le_0 = T.ExitQuality <= xSubcooledLimit;
T.is_x_le_005 = T.ExitQuality <= xLowLimit;
T.is_G_loose_PWRlike = T.G_Mlb_hr_ft2 >= G_min_PWRlike & T.G_Mlb_hr_ft2 <= G_max_PWRlike;
T.is_candidate_source01_lowX = T.is_source01 & T.is_x_le_005;
T.is_candidate_source09_lowX = T.is_source09 & T.is_x_le_005;
T.is_candidate_all_lowX_no_CGH = T.is_x_le_005 & ~T.is_flag_CGH;
T.is_candidate_all_lowX_flag_none_or_J = T.is_x_le_005 & (T.is_flag_none | T.is_flag_J | T.is_flag_DJ);
T.is_candidate_source01_or09_lowX = (T.is_source01 | T.is_source09) & T.is_x_le_005;

%% Optional ANL markdown coarse source summary
anlSummary = table();
if isfile(anlFile)
    anlText = fileread(anlFile);
    anlSummary = local_parse_anl_summary(anlText);
end

%% Optional legacy match
[legacyExpt, legacySource, legacySheetSummary] = local_find_legacy_expt_keys(legacyWorkbookCandidates);
T.is_legacy_selected = false(height(T),1);
if ~isempty(legacyExpt)
    T.is_legacy_selected = ismember(T.ExptNo_str, legacyExpt);
end

%% Summaries
summary_by_source = local_group_summary(T, "source_label");
summary_by_flag = local_group_summary(T, "flag_norm");
summary_by_dia_len_source = local_group_summary(T, ["source_label","dia_len_group"]);
summary_legacy = local_legacy_summary(T);
summary_candidates = local_candidate_summary(T);

% Convenience tables for inspection
legacy_rows = T(T.is_legacy_selected,:);
new_source01_lowX_not_legacy = T(T.is_candidate_source01_lowX & ~T.is_legacy_selected,:);
source09_rows = T(T.is_source09,:);
source09_lowX = T(T.is_source09 & T.is_x_le_005,:);
flagged_rows = T(~T.is_flag_none,:);

%% Write Excel
if isfile(outXlsx), delete(outXlsx); end
writetable(T, outXlsx, 'Sheet','Table10_raw_all');
writetable(summary_by_source, outXlsx, 'Sheet','summary_by_source');
writetable(summary_by_flag, outXlsx, 'Sheet','summary_by_flag');
writetable(summary_by_dia_len_source, outXlsx, 'Sheet','summary_by_dia_len_src');
writetable(summary_candidates, outXlsx, 'Sheet','summary_candidate_sets');
writetable(summary_legacy, outXlsx, 'Sheet','legacy_match_summary');
writetable(legacySheetSummary, outXlsx, 'Sheet','legacy_sheet_scan');
if ~isempty(legacy_rows), writetable(legacy_rows, outXlsx, 'Sheet','legacy_rows'); end
if ~isempty(new_source01_lowX_not_legacy), writetable(new_source01_lowX_not_legacy, outXlsx, 'Sheet','new_src01_lowX_not_legacy'); end
if ~isempty(source09_rows), writetable(source09_rows, outXlsx, 'Sheet','source09_rows'); end
if ~isempty(source09_lowX), writetable(source09_lowX, outXlsx, 'Sheet','source09_lowX'); end
if ~isempty(flagged_rows), writetable(flagged_rows, outXlsx, 'Sheet','flagged_rows'); end
if ~isempty(anlSummary), writetable(anlSummary, outXlsx, 'Sheet','ANL_md_coarse_summary'); end

%% Figures
local_plot_source_counts(summary_by_source, fig1);
local_plot_x_vs_G(T, fig2);
local_plot_Hsub_vs_G(T, fig3);
local_plot_candidate_counts(summary_candidates, fig4);

%% Markdown report
fid = fopen(outMd,'w');
assert(fid>0, 'Could not open report file.');

fprintf(fid, '# T10R00/T10R01 Table10 raw parse and extraction audit\n\n');
fprintf(fid, '作成日時: `%s`\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

fprintf(fid, '## 1. 目的\n\n');
fprintf(fid, ['Weatherhead/ANLデータ確認により、T&M Table10の `.09` 系列がANL/Weatherhead由来である可能性が高くなった。\n' ...
    'そのため、旧Table10抽出86点が厳しすぎた可能性を確認するため、まずT&M Table10正本Markdown全体を構造化し、抽出基準の監査を行う。\n\n']);

fprintf(fid, 'このrunでは、採用点は決めない。目的は `raw_all`、旧採用点、新規候補集合の見える化である。\n\n');

fprintf(fid, '## 2. 入力\n\n');
fprintf(fid, '- Table10正本Markdown: `%s`\n', mdFile);
if isfile(anlFile)
    fprintf(fid, '- ANL/Weatherhead抽出Markdown: `%s`\n', anlFile);
else
    fprintf(fid, '- ANL/Weatherhead抽出Markdown: not found\n');
end
if isempty(legacyExpt)
    fprintf(fid, '- legacy selected workbook: not found or no usable ExptNo keys detected\n\n');
else
    fprintf(fid, '- legacy selected workbook keys detected: %d unique ExptNo\n\n', numel(legacyExpt));
end

fprintf(fid, '## 3. QC\n\n');
fprintf(fid, '- Parsed Table10 rows: `%d`\n', height(T));
fprintf(fid, '- Unique source codes: `%s`\n', local_join_unique(T.source_label));
fprintf(fid, '- Unique flag values: `%s`\n', local_join_unique(T.flag_norm));
fprintf(fid, '- Exit quality range: `%.3f` to `%.3f`\n', min(T.ExitQuality), max(T.ExitQuality));
fprintf(fid, '- G range [10^6 lb/(hr ft^2)]: `%.3g` to `%.3g`\n', min(T.G_Mlb_hr_ft2), max(T.G_Mlb_hr_ft2));
fprintf(fid, '- Diameter range [in]: `%.4g` to `%.4g`\n', min(T.Dia_in), max(T.Dia_in));
fprintf(fid, '- Length range [in]: `%.4g` to `%.4g`\n\n', min(T.Length_in), max(T.Length_in));

fprintf(fid, '## 4. Source summary\n\n');
local_write_table_md(fid, summary_by_source, 20);
fprintf(fid, '\n');

fprintf(fid, '## 5. Flag summary\n\n');
local_write_table_md(fid, summary_by_flag, 20);
fprintf(fid, '\n');

fprintf(fid, '## 6. Candidate set counts (audit only)\n\n');
fprintf(fid, '以下は採用判断ではなく、抽出基準を比較するための候補集合である。\n\n');
local_write_table_md(fid, summary_candidates, 30);
fprintf(fid, '\n');

fprintf(fid, '## 7. Legacy match\n\n');
if isempty(legacyExpt)
    fprintf(fid, '旧採用86点に相当するExptNoキーは、このrunでは自動検出できなかった。\n');
    fprintf(fid, '次runでは、旧採用点のExptNoリストまたはcurrent_single_tube_inputブックを同じフォルダに置いて再実行する。\n\n');
else
    fprintf(fid, '- Legacy unique ExptNo detected: `%d`\n', numel(legacyExpt));
    fprintf(fid, '- Matched to raw Table10: `%d`\n', sum(T.is_legacy_selected));
    fprintf(fid, '- Source01 low-x not legacy: `%d`\n\n', height(new_source01_lowX_not_legacy));
    local_write_table_md(fid, summary_legacy, 20);
    fprintf(fid, '\n');
end

fprintf(fid, '## 8. ANL/Weatherhead coarse check\n\n');
if isempty(anlSummary)
    fprintf(fid, 'ANL/Weatherhead抽出Markdownは未検出、または粗集計できなかった。\n\n');
else
    fprintf(fid, 'ANL/Weatherhead抽出Markdown内のTable見出しから粗く読んだ件数である。T&Mとの完全照合は次runで行う。\n\n');
    local_write_table_md(fid, anlSummary, 20);
    fprintf(fid, '\n');
end

fprintf(fid, '## 9. Figures\n\n');
fprintf(fid, '- `%s`\n', fig1);
fprintf(fid, '- `%s`\n', fig2);
fprintf(fid, '- `%s`\n', fig3);
fprintf(fid, '- `%s`\n\n', fig4);

fprintf(fid, '## 10. 一次判断\n\n');
fprintf(fid, ['このrunはTable10抽出監査の入口であり、まだ採用点を増やす判断はしない。\n' ...
    'まず、Table10全649行に対して、source、flag、D/L、G、Hsub、報告書転記クオリティの分布を固定する。\n' ...
    '次runでは、旧採用86点がどの範囲を拾っていたか、また `.09` / Weatherhead相当系列を独立文献として足すのではなくT&M内出典系列としてどう扱うかを確認する。\n\n']);

fprintf(fid, '## 11. 次アクション案\n\n');
fprintf(fid, ['- T10R01b: 旧採用86点ExptNoとの確実な照合。\n' ...
    '- T10R02: ANL/Weatherhead Table I/II と T&M `.09` 系列のキー照合。\n' ...
    '- T10R03: 抽出基準候補 set_A〜set_F の条件範囲比較。\n' ...
    '- T10R04: 候補点のPM計算へ進むか判断。ただしこの段階でも採用は急がない。\n']);

fclose(fid);

fprintf('\nT10R00/T10R01 audit complete.\n');
fprintf('Output Excel : %s\n', outXlsx);
fprintf('Output report: %s\n', outMd);

%% Local functions
function T = local_parse_tm_table10_markdown(txt)
    lines = regexp(txt, '\r\n|\n|\r', 'split')';
    rows = {};
    for i = 1:numel(lines)
        line = strtrim(lines{i});
        if startsWith(line,'|') && contains(line,'|')
            if contains(line,'EXPT NO') || contains(line,'---')
                continue;
            end
            parts = regexp(line, '\|', 'split');
            parts = strtrim(parts);
            if numel(parts) >= 10
                cells = parts(2:end-1); % remove empty before first and after last
                if numel(cells) == 8 && ~isempty(regexp(cells{1}, '^\d+\.\d+', 'once'))
                    rows(end+1,:) = cells; %#ok<AGROW>
                end
            end
        end
    end
    if isempty(rows)
        error('No markdown table rows were parsed.');
    end
    T = cell2table(rows, 'VariableNames', {'ExptNo_str','Dia_in_raw','Length_in_raw','G_raw','Hsub_raw','qM_raw','ExitQuality_raw','flag'});
    T.Dia_in = local_to_double(T.Dia_in_raw);
    T.Length_in = local_to_double(T.Length_in_raw);
    T.G_Mlb_hr_ft2 = local_to_double(T.G_raw);
    T.Hsub_BTUlb = local_to_double(T.Hsub_raw);
    T.qM_MBTU_hr_ft2 = local_to_double(T.qM_raw);
    T.ExitQuality = local_to_double(T.ExitQuality_raw);
    T.flag = string(T.flag);
    T = removevars(T, {'Dia_in_raw','Length_in_raw','G_raw','Hsub_raw','qM_raw','ExitQuality_raw'});
end

function x = local_to_double(c)
    if isnumeric(c)
        x = double(c);
        return;
    end
    if iscell(c)
        s = string(c);
    else
        s = string(c);
    end
    s = strtrim(s);
    s = erase(s, ',');
    s = replace(s, char(8722), '-'); % unicode minus
    x = str2double(s);
end

function src = local_source_from_expt(expt)
    s = string(expt);
    src = nan(numel(s),1);
    for k = 1:numel(s)
        parts = regexp(s(k), '\.', 'split');
        if numel(parts) >= 2
            src(k) = str2double(parts{2});
        end
    end
end

function runno = local_run_from_expt(expt)
    s = string(expt);
    runno = nan(numel(s),1);
    for k = 1:numel(s)
        parts = regexp(s(k), '\.', 'split');
        if numel(parts) >= 1
            runno(k) = str2double(parts{1});
        end
    end
end

function S = local_group_summary(T, groupVars)
    if isstring(groupVars) || ischar(groupVars)
        groupVars = cellstr(groupVars);
    end
    [G, keys] = findgroups(T(:,groupVars));
    N = splitapply(@numel, T.ExitQuality, G);
    x_mean = splitapply(@(x) mean(x,'omitnan'), T.ExitQuality, G);
    x_min  = splitapply(@(x) min(x,[],'omitnan'), T.ExitQuality, G);
    x_max  = splitapply(@(x) max(x,[],'omitnan'), T.ExitQuality, G);
    frac_x_le_0 = splitapply(@(x) mean(x<=0,'omitnan'), T.ExitQuality, G);
    frac_x_le_005 = splitapply(@(x) mean(x<=0.05,'omitnan'), T.ExitQuality, G);
    G_min = splitapply(@(x) min(x,[],'omitnan'), T.G_Mlb_hr_ft2, G);
    G_max = splitapply(@(x) max(x,[],'omitnan'), T.G_Mlb_hr_ft2, G);
    Hsub_min = splitapply(@(x) min(x,[],'omitnan'), T.Hsub_BTUlb, G);
    Hsub_max = splitapply(@(x) max(x,[],'omitnan'), T.Hsub_BTUlb, G);
    D_min = splitapply(@(x) min(x,[],'omitnan'), T.Dia_in, G);
    D_max = splitapply(@(x) max(x,[],'omitnan'), T.Dia_in, G);
    L_min = splitapply(@(x) min(x,[],'omitnan'), T.Length_in, G);
    L_max = splitapply(@(x) max(x,[],'omitnan'), T.Length_in, G);
    S = keys;
    S.N = N;
    S.x_mean = x_mean;
    S.x_min = x_min;
    S.x_max = x_max;
    S.frac_x_le_0 = frac_x_le_0;
    S.frac_x_le_005 = frac_x_le_005;
    S.G_min = G_min;
    S.G_max = G_max;
    S.Hsub_min = Hsub_min;
    S.Hsub_max = Hsub_max;
    S.D_min = D_min;
    S.D_max = D_max;
    S.L_min = L_min;
    S.L_max = L_max;
end

function S = local_candidate_summary(T)
    names = { ...
        'raw_all', ...
        'legacy_selected_detected', ...
        'source01_all', ...
        'source01_x_le_005', ...
        'source09_all_weatherhead_like', ...
        'source09_x_le_005', ...
        'all_x_le_005', ...
        'all_x_le_005_no_CGH', ...
        'all_x_le_005_flag_none_or_J_DJ', ...
        'source01_or09_x_le_005', ...
        'all_x_le_0', ...
        'loose_G_1_to_8_and_x_le_005'};
    masks = { ...
        true(height(T),1), ...
        T.is_legacy_selected, ...
        T.is_source01, ...
        T.is_candidate_source01_lowX, ...
        T.is_source09, ...
        T.is_candidate_source09_lowX, ...
        T.is_x_le_005, ...
        T.is_candidate_all_lowX_no_CGH, ...
        T.is_candidate_all_lowX_flag_none_or_J, ...
        T.is_candidate_source01_or09_lowX, ...
        T.is_x_le_0, ...
        T.is_G_loose_PWRlike & T.is_x_le_005};
    N = zeros(numel(names),1);
    source_list = strings(numel(names),1);
    D_range = strings(numel(names),1);
    L_range = strings(numel(names),1);
    G_range = strings(numel(names),1);
    x_range = strings(numel(names),1);
    for i = 1:numel(names)
        m = masks{i};
        N(i) = sum(m);
        if N(i) > 0
            source_list(i) = local_join_unique(T.source_label(m));
            D_range(i) = sprintf('%.4g - %.4g', min(T.Dia_in(m)), max(T.Dia_in(m)));
            L_range(i) = sprintf('%.4g - %.4g', min(T.Length_in(m)), max(T.Length_in(m)));
            G_range(i) = sprintf('%.3g - %.3g', min(T.G_Mlb_hr_ft2(m)), max(T.G_Mlb_hr_ft2(m)));
            x_range(i) = sprintf('%.3g - %.3g', min(T.ExitQuality(m)), max(T.ExitQuality(m)));
        end
    end
    S = table(string(names(:)), N, source_list, D_range, L_range, G_range, x_range, ...
        'VariableNames', {'candidate_set','N','sources','D_in_range','L_in_range','G_range','x_report_range'});
end

function S = local_legacy_summary(T)
    names = {'raw_all'; 'legacy_selected'; 'not_legacy'; 'source01_lowX_not_legacy'; 'source09_not_legacy'};
    masks = {true(height(T),1); T.is_legacy_selected; ~T.is_legacy_selected; T.is_candidate_source01_lowX & ~T.is_legacy_selected; T.is_source09 & ~T.is_legacy_selected};
    N = zeros(numel(names),1);
    x_mean = nan(numel(names),1);
    G_range = strings(numel(names),1);
    x_range = strings(numel(names),1);
    for i=1:numel(names)
        m = masks{i};
        N(i)=sum(m);
        if N(i)>0
            x_mean(i)=mean(T.ExitQuality(m),'omitnan');
            G_range(i)=sprintf('%.3g - %.3g', min(T.G_Mlb_hr_ft2(m)), max(T.G_Mlb_hr_ft2(m)));
            x_range(i)=sprintf('%.3g - %.3g', min(T.ExitQuality(m)), max(T.ExitQuality(m)));
        end
    end
    S = table(string(names), N, x_mean, G_range, x_range, 'VariableNames', {'group','N','x_mean','G_range','x_report_range'});
end

function [legacyExpt, sourceWorkbook, sheetSummary] = local_find_legacy_expt_keys(candidates)
    legacyExpt = string.empty(0,1);
    sourceWorkbook = '';
    sheetSummary = table(string.empty(0,1), string.empty(0,1), zeros(0,1), zeros(0,1), string.empty(0,1), ...
        'VariableNames', {'workbook','sheet','nRows','nDetectedKeys','note'});
    for c = 1:numel(candidates)
        f = candidates{c};
        if ~isfile(f), continue; end
        sourceWorkbook = f;
        try
            sh = sheetnames(f);
        catch
            sh = {};
        end
        allKeys = string.empty(0,1);
        for i = 1:numel(sh)
            note = "";
            nRows = 0; nKeys = 0;
            try
                T = readtable(f, 'Sheet', sh{i}, 'VariableNamingRule','preserve');
                nRows = height(T);
                keys = local_extract_expt_keys_from_table(T);
                nKeys = numel(keys);
                if nKeys > 0
                    allKeys = [allKeys; keys(:)]; %#ok<AGROW>
                    note = "keys detected";
                else
                    note = "no expt keys";
                end
            catch ME
                note = "read failed: " + string(ME.message);
            end
            sheetSummary = [sheetSummary; {string(f), string(sh{i}), nRows, nKeys, note}]; %#ok<AGROW>
        end
        legacyExpt = unique(allKeys);
        if ~isempty(legacyExpt)
            break;
        end
    end
end

function keys = local_extract_expt_keys_from_table(T)
    keys = string.empty(0,1);
    vn = string(T.Properties.VariableNames);
    % Find likely expt columns
    exptIdx = find(contains(lower(vn), 'expt') | contains(lower(vn), 'no_tableno') | contains(lower(vn), 'no_table'), 1);
    if isempty(exptIdx), return; end
    v = T{:, exptIdx};
    s = string(v);
    s = strtrim(s);
    % If there is a TableNo column, filter to Table 10 when possible.
    tableMask = true(numel(s),1);
    tIdx = find(contains(lower(vn), 'tableno') | strcmpi(vn,'Table'), 1);
    if ~isempty(tIdx)
        tno = local_to_double(T{:,tIdx});
        if any(tno == 10)
            tableMask = tno == 10;
        end
    end
    % Accept keys like 123.01 or numeric strings.
    m = ~ismissing(s) & strlength(s)>0 & tableMask;
    s = s(m);
    % Normalize numeric output like 123.0100 to 123.01
    out = strings(numel(s),1);
    for i=1:numel(s)
        num = str2double(s(i));
        if ~isnan(num)
            run = floor(num);
            src = round((num-run)*100);
            out(i) = sprintf('%d.%02d', run, src);
        else
            tok = regexp(s(i), '(\d+)\.(\d+)', 'tokens', 'once');
            if ~isempty(tok)
                out(i) = sprintf('%d.%02d', str2double(tok{1}), str2double(tok{2}));
            end
        end
    end
    keys = unique(out(strlength(out)>0));
end

function anlSummary = local_parse_anl_summary(txt)
    % Coarse parse only: count markdown data rows under Table I / Table II.
    lines = regexp(txt, '\r\n|\n|\r', 'split')';
    currentTable = "unknown";
    tableName = strings(0,1); nRows = [];
    counts = containers.Map('KeyType','char','ValueType','double');
    for i=1:numel(lines)
        line = strtrim(lines{i});
        if startsWith(line,'## Table I')
            currentTable = "Table I 0.304 in";
            if ~isKey(counts,char(currentTable)), counts(char(currentTable)) = 0; end
        elseif startsWith(line,'## Table II')
            currentTable = "Table II 0.436 in";
            if ~isKey(counts,char(currentTable)), counts(char(currentTable)) = 0; end
        elseif startsWith(line,'|') && ~contains(line,'Run |') && ~contains(line,'---')
            parts = regexp(line,'\|','split');
            parts = strtrim(parts);
            cells = parts(2:end-1);
            if numel(cells) >= 5 && ~isempty(regexp(cells{1}, '^\d', 'once'))
                if ~isKey(counts,char(currentTable)), counts(char(currentTable)) = 0; end
                counts(char(currentTable)) = counts(char(currentTable)) + 1;
            end
        end
    end
    ks = keys(counts);
    for i=1:numel(ks)
        tableName(end+1,1) = string(ks{i}); %#ok<AGROW>
        nRows(end+1,1) = counts(ks{i}); %#ok<AGROW>
    end
    anlSummary = table(tableName, nRows, 'VariableNames', {'ANL_table','N_rows'});
end

function s = local_join_unique(x)
    u = unique(string(x));
    u = u(~ismissing(u) & strlength(u)>0);
    s = strjoin(cellstr(u), ', ');
end

function local_plot_source_counts(S, fn)
    try
        figure('Visible','off');
        bar(categorical(S.source_label), S.N);
        ylabel('N');
        title('T&M Table10 row counts by source code');
        grid on;
        set(gcf,'Position',[100 100 900 550]);
        exportgraphics(gcf, fn, 'Resolution', 200);
        close(gcf);
    catch
    end
end

function local_plot_x_vs_G(T, fn)
    try
        figure('Visible','off'); hold on;
        srcs = unique(T.source_label);
        for i=1:numel(srcs)
            m = T.source_label == srcs(i);
            scatter(T.G_Mlb_hr_ft2(m), T.ExitQuality(m), 22, 'filled', 'DisplayName', char(srcs(i)));
        end
        yline(0,'--'); yline(0.05,':');
        xlabel('G [10^6 lb/(hr ft^2)]');
        ylabel('Report-based exit quality');
        title('T&M Table10 report quality vs G');
        legend('Location','best'); grid on;
        set(gcf,'Position',[100 100 950 600]);
        exportgraphics(gcf, fn, 'Resolution', 200);
        close(gcf);
    catch
    end
end

function local_plot_Hsub_vs_G(T, fn)
    try
        figure('Visible','off'); hold on;
        srcs = unique(T.source_label);
        for i=1:numel(srcs)
            m = T.source_label == srcs(i);
            scatter(T.G_Mlb_hr_ft2(m), T.Hsub_BTUlb(m), 22, 'filled', 'DisplayName', char(srcs(i)));
        end
        xlabel('G [10^6 lb/(hr ft^2)]');
        ylabel('Inlet subcooling [Btu/lb]');
        title('T&M Table10 inlet subcooling vs G');
        legend('Location','best'); grid on;
        set(gcf,'Position',[100 100 950 600]);
        exportgraphics(gcf, fn, 'Resolution', 200);
        close(gcf);
    catch
    end
end

function local_plot_candidate_counts(S, fn)
    try
        figure('Visible','off');
        bar(categorical(S.candidate_set), S.N);
        ylabel('N');
        title('Candidate set counts (audit only)');
        grid on;
        xtickangle(45);
        set(gcf,'Position',[100 100 1200 650]);
        exportgraphics(gcf, fn, 'Resolution', 200);
        close(gcf);
    catch
    end
end

function local_write_table_md(fid, T, maxRows)
    if nargin < 3, maxRows = height(T); end
    n = min(height(T), maxRows);
    if n == 0
        fprintf(fid, '(empty)\n');
        return;
    end
    vn = string(T.Properties.VariableNames);
    fprintf(fid, '| %s |\n', strjoin(cellstr(vn), ' | '));
    fprintf(fid, '|%s|\n', strjoin(repmat({'---'},1,numel(vn)), '|'));
    for i=1:n
        vals = strings(1,numel(vn));
        for j=1:numel(vn)
            v = T{i,j};
            if isnumeric(v)
                if isscalar(v)
                    vals(j) = sprintf('%.4g', v);
                else
                    vals(j) = mat2str(v);
                end
            elseif islogical(v)
                vals(j) = string(v);
            elseif iscell(v)
                vals(j) = string(v{1});
            else
                vals(j) = string(v);
            end
            vals(j) = replace(vals(j), '|', '/');
        end
        fprintf(fid, '| %s |\n', strjoin(cellstr(vals), ' | '));
    end
    if height(T) > n
        fprintf(fid, '\n... %d more rows omitted ...\n', height(T)-n);
    end
end
