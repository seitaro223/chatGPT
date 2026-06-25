%% ST-LD-00: single-tube PM_F1 vs Tsub between/within decomposition
% 目的:
%   単管F1後PM_F1に残るTsub相関を、
%   L/D group間差とgroup内Tsub傾きに分解する。
%
% 判断:
%   group内Tsub傾きが小さい  -> ST-LD-01へ進む候補
%   group内Tsub傾きが残る    -> F1(Tsub)外挿取り残し疑い、ST-HSUB/ST-F1-refit優先
%
% 入力:
%   H52Q_current_single_tube_input_v1_20260615_183839.xlsx
%
% 出力:
%   STLD00_single_tube_Tsub_between_within_yyyymmdd_HHMMSS.xlsx
%   run_report_STLD00_single_tube_Tsub_between_within_yyyymmdd_HHMMSS.md
%   fig_STLD00_*.png

clear; clc;

%% ===== User settings =====
inFile = "H52Q_current_single_tube_input_v1_20260615_183839.xlsx";

% 入力ファイルがカレントに無ければ選択
if ~isfile(inFile)
    [f,p] = uigetfile("*.xlsx", "Select current_single_tube_input workbook");
    if isequal(f,0)
        error("Input file was not selected.");
    end
    inFile = fullfile(p,f);
end

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "STLD00_single_tube_Tsub_between_within_" + timestamp + ".xlsx";
outMd   = "run_report_STLD00_single_tube_Tsub_between_within_" + timestamp + ".md";

fig1 = "fig_STLD00_01_PM_F1_vs_Tsub_by_LDgroup_" + timestamp + ".png";
fig2 = "fig_STLD00_02_group_mean_PM_Tsub_LD_" + timestamp + ".png";
fig3 = "fig_STLD00_03_within_PM_vs_within_Tsub_" + timestamp + ".png";
fig4 = "fig_STLD00_04_model_R2_decomposition_" + timestamp + ".png";

% 主解析対象
targetTables_primary = [9 10 11 12];

% 参考解析対象。Table8/13/14は参考扱い
targetTables_reference = [8 9 10 11 12 13 14];

%% ===== Read sheet =====
sheets = sheetnames(inFile);

% F1単管シートを探す
preferredSheets = ["ST_F1_T8_14_current", "tm_r124_F1_T8_14", "F1_T8_14"];
sheet = "";
for s = preferredSheets
    if any(strcmpi(sheets, s))
        sheet = s;
        break;
    end
end

if sheet == ""
    % 名前に F1 と T8 が入るものを探す
    cand = sheets(contains(lower(sheets),"f1") & ...
                  (contains(lower(sheets),"t8") | contains(lower(sheets),"8_14") | contains(lower(sheets),"single")));
    if isempty(cand)
        disp("Available sheets:");
        disp(sheets);
        error("Could not find F1 single-tube sheet.");
    end
    sheet = cand(1);
end

opts = detectImportOptions(inFile, "Sheet", sheet, "VariableNamingRule", "preserve");
Traw = readtable(inFile, opts);

fprintf("Read sheet: %s\n", sheet);
fprintf("Rows: %d, Cols: %d\n", height(Traw), width(Traw));

%% ===== Find columns robustly =====
vars = string(Traw.Properties.VariableNames);
varsLower = lower(regexprep(vars, "[\s_\-/\(\)\[\]\.]", ""));

colTable = findCol(vars, varsLower, ["table","tableno","tablenumber","tbl"]);
colPM    = findCol(vars, varsLower, ["pm","p/m","poverm","p_m","pmf1","pmm"]);
colTsub  = findCol(vars, varsLower, ["tsub","subcoolingk","inletsubcoolingk","deltatsub"]);
colLD    = findCol(vars, varsLower, ["l/d","ld","loverd","lbyd","l_d","l/dh","ldh","l_over_d"]);
colSource = findColOptional(vars, varsLower, ["source","src"]);
colBand   = findColOptional(vars, varsLower, ["ldband","l/dband","lengthband","band","ldgroup","group"]);

% もしPM列候補が怪しい場合の補助
% qP/qM列からPMを作る処理はあえて自動化しない。
% 列名が見つからない場合は、下のfindColでエラーになり、候補列一覧を確認する。

T = Traw;

TableNo = toNumeric(T.(colTable));
PM_F1   = toNumeric(T.(colPM));
Tsub    = toNumeric(T.(colTsub));
LD      = toNumeric(T.(colLD));

Source = strings(height(T),1);
if colSource ~= ""
    Source = string(T.(colSource));
else
    Source(:) = "unknown";
end

%% ===== Build analysis table =====
A = table;
A.row_id = (1:height(T))';
A.TableNo = TableNo;
A.Source = Source;
A.PM_F1 = PM_F1;
A.Tsub = Tsub;
A.LD = LD;

% L/D group
if colBand ~= ""
    rawBand = string(T.(colBand));
    A.LD_group = normalizeGroupLabels(rawBand);
else
    A.LD_group = makeLDGroups(LD);
end

% Clean
valid = isfinite(A.TableNo) & isfinite(A.PM_F1) & isfinite(A.Tsub) & isfinite(A.LD) & A.LD_group ~= "";
A = A(valid,:);

% TableNoを整数扱いへ
A.TableNo = round(A.TableNo);

% primary/reference
A.is_primary = ismember(A.TableNo, targetTables_primary);
A.is_reference = ismember(A.TableNo, targetTables_reference);

P = A(A.is_primary,:);
R = A(A.is_reference,:);

if height(P) == 0
    error("Primary target Table9-12 rows are zero. Check Table column and target table numbers.");
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
        tmp = ri.summary;
        perTableAll = [perTableAll; tmp]; %#ok<AGROW>
    end
end

%% ===== Outputs =====
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
writeReport(outMd, inFile, sheet, colTable, colPM, colTsub, colLD, colBand, colSource, ...
    primary_result, reference_result, perTableAll, fig1, fig2, fig3, fig4);

fprintf("\nDONE\n");
fprintf("Output xlsx: %s\n", outXlsx);
fprintf("Report md  : %s\n", outMd);
fprintf("Figures    : %s, %s, %s, %s\n", fig1, fig2, fig3, fig4);

%% ===== Local functions =====

function col = findCol(vars, varsLower, candidates)
    col = findColOptional(vars, varsLower, candidates);
    if col == ""
        fprintf("\nAvailable variables:\n");
        disp(vars');
        error("Could not find required column. Candidates: %s", strjoin(candidates,", "));
    end
end

function col = findColOptional(vars, varsLower, candidates)
    col = "";
    candNorm = lower(regexprep(string(candidates), "[\s_\-/\(\)\[\]\.]", ""));
    for c = candNorm
        idx = find(varsLower == c, 1);
        if ~isempty(idx)
            col = vars(idx);
            return;
        end
    end
    for c = candNorm
        idx = find(contains(varsLower, c), 1);
        if ~isempty(idx)
            col = vars(idx);
            return;
        end
    end
end

function x = toNumeric(v)
    if isnumeric(v)
        x = double(v);
    elseif iscell(v)
        x = str2double(string(v));
    elseif isstring(v) || ischar(v) || iscategorical(v)
        x = str2double(string(v));
    else
        x = str2double(string(v));
    end
end

function g = normalizeGroupLabels(raw)
    s = lower(strtrim(string(raw)));
    g = strings(size(s));
    g(contains(s,"short") | contains(s,"s")) = "short";
    g(contains(s,"middle") | contains(s,"mid") | contains(s,"m")) = "middle";
    g(contains(s,"long") | contains(s,"l")) = "long";

    % 数字だけのgroupなどに備える
    miss = g == "";
    if any(miss)
        vals = unique(s(miss));
        for i = 1:numel(vals)
            g(s == vals(i)) = vals(i);
        end
    end
end

function g = makeLDGroups(LD)
    g = strings(size(LD));
    x = LD(:);
    finite = isfinite(x);
    ux = unique(round(x(finite),3));

    if numel(ux) <= 1
        g(finite) = "single";
        return;
    end

    % LD値が数個の離散値なら、そのまま順位でshort/middle/longへ
    if numel(ux) <= 5
        [~,ord] = sort(ux);
        sorted = ux(ord);
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

    % 連続気味なら三分位で分ける
    q1 = quantile(x(finite), 1/3);
    q2 = quantile(x(finite), 2/3);
    g(finite & x <= q1) = "short";
    g(finite & x > q1 & x <= q2) = "middle";
    g(finite & x > q2) = "long";
end

function result = analyzeDataset(D, label)
    D = D(isfinite(D.PM_F1) & isfinite(D.Tsub) & isfinite(D.LD) & D.LD_group ~= "", :);

    n = height(D);

    % 基本R2
    [r2_tsub, slope_tsub, intercept_tsub] = linRegR2(D.Tsub, D.PM_F1);
    [r2_ld, slope_ld, intercept_ld] = linRegR2(D.LD, D.PM_F1);

    % group stats
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
        row.PM_se = row.PM_sd / sqrt(row.N);
        row.Tsub_mean = mean(ts,"omitnan");
        row.Tsub_sd = std(ts,"omitnan");
        row.LD_mean = mean(ld,"omitnan");
        row.LD_sd = std(ld,"omitnan");
        groupStats = [groupStats; row]; %#ok<AGROW>

        withinData.PM_within(idx) = pm - row.PM_mean;
        withinData.Tsub_within(idx) = ts - row.Tsub_mean;
        withinData.LD_within(idx) = ld - row.LD_mean;
    end

    % group-wise slope PM ~ Tsub
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

    % between regression: group mean PM vs group mean Tsub / LD
    if height(groupStats) >= 2
        [r2_between_tsub, slope_between_tsub, ~] = linRegR2(groupStats.Tsub_mean, groupStats.PM_mean);
        [r2_between_ld, slope_between_ld, ~] = linRegR2(groupStats.LD_mean, groupStats.PM_mean);
    else
        r2_between_tsub = NaN; slope_between_tsub = NaN;
        r2_between_ld = NaN; slope_between_ld = NaN;
    end

    % within regression
    [r2_within_tsub, slope_within_tsub, ~] = linRegR2(withinData.Tsub_within, withinData.PM_within);
    [r2_within_ld, slope_within_ld, ~] = linRegR2(withinData.LD_within, withinData.PM_within);

    % model compare
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

    r2_group = modelCompare.R2(modelCompare.model == "PM ~ LD_group");
    r2_group_tsubWithin = modelCompare.R2(modelCompare.model == "PM ~ LD_group + Tsub_within");
    if isempty(r2_group), r2_group = NaN; end
    if isempty(r2_group_tsubWithin), r2_group_tsubWithin = NaN; end
    deltaR2_withinTsub_afterGroup = r2_group_tsubWithin - r2_group;

    % tentative flag
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

function X = designGroup(g)
    groups = unique(g, "stable");
    n = numel(g);
    X = ones(n,1);
    % 1列目は切片。dummyは2群目以降
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
    b = X \ y(:);
    yhat = X*b;
    ssRes = sum((y(:)-yhat).^2);
    ssTot = sum((y(:)-mean(y(:))).^2);
    r2 = 1 - ssRes/ssTot;
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
    b = X \ y;
    yhat = X*b;
    ssRes = sum((y-yhat).^2);
    ssTot = sum((y-mean(y)).^2);
    r2 = 1 - ssRes/ssTot;
    rmse = sqrt(mean((y-yhat).^2));
end

function makeFigures(P, res, fig1, fig2, fig3, fig4)
    % Fig1
    f = figure("Color","w");
    hold on; grid on; box on;
    groups = unique(P.LD_group, "stable");
    for i = 1:numel(groups)
        idx = P.LD_group == groups(i);
        scatter(P.Tsub(idx), P.PM_F1(idx), 36, "filled", "DisplayName", groups(i));
    end
    yline(1, "--", "PM=1", "HandleVisibility","off");
    xlabel("Tsub [K]");
    ylabel("PM_F1 [-]");
    title("ST-LD-00: PM_F1 vs Tsub by L/D group");
    legend("Location","best");
    saveas(f, fig1);
    close(f);

    % Fig2
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

    % Fig3
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

    % Fig4
    mc = res.modelCompare;
    f = figure("Color","w");
    bar(categorical(mc.model), mc.R2);
    ylabel("R^2");
    title("ST-LD-00 model comparison");
    grid on; box on;
    xtickangle(30);
    saveas(f, fig4);
    close(f);
end

function writeReport(outMd, inFile, sheet, colTable, colPM, colTsub, colLD, colBand, colSource, ...
    primary, reference, perTableAll, fig1, fig2, fig3, fig4)

    fid = fopen(outMd, "w");
    if fid < 0
        error("Cannot open markdown file.");
    end

    fprintf(fid, "# ST-LD-00 single-tube Tsub between/within decomposition\n\n");
    fprintf(fid, "作成日時: %s\n\n", string(datetime("now","Format","yyyy-MM-dd HH:mm:ss")));
    fprintf(fid, "## 1. 目的\n\n");
    fprintf(fid, "単管F1後PM_F1に残るTsub相関を、L/D group間差とgroup内Tsub傾きに分解する。\n\n");
    fprintf(fid, "ST-LD-01へ進む前の判定ゲートであり、補正式作成ではない。\n\n");

    fprintf(fid, "## 2. 入力\n\n");
    fprintf(fid, "- input_file: `%s`\n", string(inFile));
    fprintf(fid, "- sheet: `%s`\n", string(sheet));
    fprintf(fid, "- Table column: `%s`\n", string(colTable));
    fprintf(fid, "- PM_F1 column: `%s`\n", string(colPM));
    fprintf(fid, "- Tsub column: `%s`\n", string(colTsub));
    fprintf(fid, "- L/D column: `%s`\n", string(colLD));
    fprintf(fid, "- L/D band column: `%s`\n", string(colBand));
    fprintf(fid, "- Source column: `%s`\n\n", string(colSource));

    fprintf(fid, "## 3. Primary result: Table9-12\n\n");
    writeTableMd(fid, primary.summary);
    fprintf(fid, "\n\n### 3.1 L/D group stats\n\n");
    writeTableMd(fid, primary.groupStats);
    fprintf(fid, "\n\n### 3.2 Group-wise PM_F1 vs Tsub slopes\n\n");
    writeTableMd(fid, primary.groupSlopes);
    fprintf(fid, "\n\n### 3.3 Model comparison\n\n");
    writeTableMd(fid, primary.modelCompare);

    fprintf(fid, "\n\n## 4. Reference result: Table8-14\n\n");
    writeTableMd(fid, reference.summary);

    fprintf(fid, "\n\n## 5. Per-table summary\n\n");
    if isempty(perTableAll)
        fprintf(fid, "No per-table summary.\n");
    else
        writeTableMd(fid, perTableAll);
    end

    fprintf(fid, "\n\n## 6. 判断フラグ\n\n");
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

    fprintf(fid, "## 7. Figures\n\n");
    fprintf(fid, "- `%s`\n", fig1);
    fprintf(fid, "- `%s`\n", fig2);
    fprintf(fid, "- `%s`\n", fig3);
    fprintf(fid, "- `%s`\n\n", fig4);

    fprintf(fid, "## 8. 次アクション\n\n");
    fprintf(fid, "```text\n");
    fprintf(fid, "1. run_reportを確認する。\n");
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