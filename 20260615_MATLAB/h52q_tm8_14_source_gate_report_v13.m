%% h52q_tm8_14_source_gate_report_v13.m
% H52Q / T&M Table 8-14
% v13: source差確認ゲート
%
% 目的:
%   Table8 middle の低下について、
%   P/xMes条件差だけでなく source03 と source01 の違いが混じっている可能性を確認する。
%
% 新運用:
%   主出力: run_report_v13_source_gate_*.md
%   保存用: summary_tables.xlsx, csv
%
% 入力:
%   out_TM8_14/TM8_14_explorelow_truehsub_v10_*.xlsx
%   Sheet: target_rows_T8_12
%
% 出力:
%   out_TM8_14/run_v13_source_gate_yyyymmdd_HHMMSS/
%     run_report_v13_source_gate_yyyymmdd_HHMMSS.md
%     summary_tables.xlsx
%     csv/*.csv

clear; clc; close all;

%% ===== 出力フォルダ =====
baseOut = fullfile(pwd, "out_TM8_14");
timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
runId = "v13_source_gate_" + timestamp;

runDir = fullfile(baseOut, "run_" + runId);
csvDir = fullfile(runDir, "csv");

if ~exist(runDir, "dir"); mkdir(runDir); end
if ~exist(csvDir, "dir"); mkdir(csvDir); end

reportFile = fullfile(runDir, "run_report_" + runId + ".md");
xlsxFile = fullfile(runDir, "summary_tables.xlsx");

%% ===== 入力ファイル取得 =====
v10Files = dir(fullfile(baseOut, "TM8_14_explorelow_truehsub_v10_*.xlsx"));
if isempty(v10Files)
    error("v10 file not found: TM8_14_explorelow_truehsub_v10_*.xlsx");
end
[~, i10] = max([v10Files.datenum]);
v10File = fullfile(v10Files(i10).folder, v10Files(i10).name);

fprintf("v10 input: %s\n", v10File);
fprintf("run dir  : %s\n", runDir);

%% ===== 読み込み =====
T = readtable(v10File, "Sheet", "target_rows_T8_12", "VariableNamingRule", "preserve");

T.No_TableNo = string(T.No_TableNo);
T.LD_band = string(T.LD_band);
T.P_scope = string(T.P_scope);

% source_idを作る
T.SourceID = extractSourceID(T);

% qM単位
if ismember("qM_MW_m2", string(T.Properties.VariableNames))
    % do nothing
elseif ismember("qM", string(T.Properties.VariableNames))
    T.qM_MW_m2 = T.qM ./ 1e6;
else
    T.qM_MW_m2 = nan(height(T), 1);
end

% 対象
T8_12 = T(ismember(T.TableNo, [8 9 10 11 12]), :);
explore = T8_12(T8_12.P_scope == "explore_low_T8_9", :);
pwr = T8_12(T8_12.P_scope == "PWR_near_T10_12", :);

%% ===== 集計 =====
basic = table( ...
    ["rows_T8_12"; ...
     "rows_explore_low"; ...
     "rows_PWR_near"; ...
     "n_sources_T8_12"; ...
     "n_sources_explore"; ...
     "n_sources_PWR"], ...
    [height(T8_12); ...
     height(explore); ...
     height(pwr); ...
     numel(unique(T8_12.SourceID)); ...
     numel(unique(explore.SourceID)); ...
     numel(unique(pwr.SourceID))], ...
    'VariableNames', ["Item", "Value"]);

bySource = makeStats(T8_12, ["SourceID"]);
bySourceTable = makeStats(T8_12, ["SourceID", "TableNo"]);
bySourceTableLD = makeStats(T8_12, ["SourceID", "TableNo", "LD_band", "P_scope"]);
byTableLD = makeStats(T8_12, ["TableNo", "LD_band", "P_scope"]);

% sourceとTable/L-Dの絡み確認
sourceGate = makeSourceGate(T8_12);

% Table8 middle vs Table9 all
T8middle = T8_12(T8_12.TableNo == 8 & T8_12.LD_band == "middle", :);
T9all = T8_12(T8_12.TableNo == 9, :);
T9short = T8_12(T8_12.TableNo == 9 & T8_12.LD_band == "short_anchor", :);
T9long = T8_12(T8_12.TableNo == 9 & T8_12.LD_band == "long", :);

contrast = table();
contrast = [contrast; makeContrast("T8_middle", T8middle, "T9_all", T9all)];
contrast = [contrast; makeContrast("T8_middle", T8middle, "T9_short", T9short)];
contrast = [contrast; makeContrast("T8_middle", T8middle, "T9_long", T9long)];

% PWR_near source確認
pwrSourceTable = makeStats(pwr, ["SourceID", "TableNo", "LD_band"]);

% Decision summary
decisionSummary = table();
decisionSummary = [decisionSummary; makeDecisionRow("T8_middle_source", modeString(T8middle.SourceID), "Table8 middle の source")];
decisionSummary = [decisionSummary; makeDecisionRow("T9_source", modeString(T9all.SourceID), "Table9 の主 source")];
decisionSummary = [decisionSummary; makeDecisionRow("PWR_near_source", modeString(pwr.SourceID), "PWR_near Table10-12 の主 source")];

deltaPM_T8_T9 = getContrastValue(contrast, "T8_middle", "T9_all", "Delta_PM_F1_AminusB");
deltaP_T8_T9 = getContrastValue(contrast, "T8_middle", "T9_all", "Delta_P_AminusB");
deltaX_T8_T9 = getContrastValue(contrast, "T8_middle", "T9_all", "Delta_xMes_AminusB");

decisionSummary = [decisionSummary; makeDecisionRow("Delta_PM_F1_T8middle_minus_T9all", deltaPM_T8_T9, "Table8 middle と Table9 all の PM_F1差")];
decisionSummary = [decisionSummary; makeDecisionRow("Delta_P_T8middle_minus_T9all", deltaP_T8_T9, "Table8 middle と Table9 all の P差")];
decisionSummary = [decisionSummary; makeDecisionRow("Delta_xMes_T8middle_minus_T9all", deltaX_T8_T9, "Table8 middle と Table9 all の xMes差")];

%% ===== 保存 =====
writetable(basic, xlsxFile, "Sheet", "basic");
writetable(bySource, xlsxFile, "Sheet", "by_source");
writetable(bySourceTable, xlsxFile, "Sheet", "by_source_table");
writetable(bySourceTableLD, xlsxFile, "Sheet", "by_source_table_LD");
writetable(byTableLD, xlsxFile, "Sheet", "by_table_LD");
writetable(sourceGate, xlsxFile, "Sheet", "source_gate");
writetable(contrast, xlsxFile, "Sheet", "T8_middle_contrast");
writetable(pwrSourceTable, xlsxFile, "Sheet", "PWR_source_table");
writetable(decisionSummary, xlsxFile, "Sheet", "decision_summary");

writetable(basic, fullfile(csvDir, "basic.csv"));
writetable(bySource, fullfile(csvDir, "by_source.csv"));
writetable(bySourceTable, fullfile(csvDir, "by_source_table.csv"));
writetable(bySourceTableLD, fullfile(csvDir, "by_source_table_LD.csv"));
writetable(sourceGate, fullfile(csvDir, "source_gate.csv"));
writetable(contrast, fullfile(csvDir, "T8_middle_contrast.csv"));
writetable(decisionSummary, fullfile(csvDir, "decision_summary.csv"));

%% ===== report用の主要値 =====
t8Source = modeString(T8middle.SourceID);
t9Source = modeString(T9all.SourceID);
pwrSource = modeString(pwr.SourceID);

nT8Sources = numel(unique(T8middle.SourceID));
nT9Sources = numel(unique(T9all.SourceID));
nPwrSources = numel(unique(pwr.SourceID));

t8PM = mean(T8middle.PM_F1, "omitnan");
t9PM = mean(T9all.PM_F1, "omitnan");
t8P = mean(T8middle.P_MPa, "omitnan");
t9P = mean(T9all.P_MPa, "omitnan");
t8X = mean(T8middle.x_Mes, "omitnan");
t9X = mean(T9all.x_Mes, "omitnan");
t8H = mean(T8middle.Hsub_true_kJkg, "omitnan");
t9H = mean(T9all.Hsub_true_kJkg, "omitnan");
t8Q = mean(T8middle.qM_MW_m2, "omitnan");
t9Q = mean(T9all.qM_MW_m2, "omitnan");

% source03がTable8/middleに閉じているか
src03 = T8_12(T8_12.SourceID == "03", :);
src01 = T8_12(T8_12.SourceID == "01", :);

src03_tables = join(unique(string(src03.TableNo)), ", ");
src03_bands = join(unique(string(src03.LD_band)), ", ");
src03_scopes = join(unique(string(src03.P_scope)), ", ");

source03_only_T8 = all(src03.TableNo == 8);
source03_only_middle = all(src03.LD_band == "middle");

%% ===== run_report.md作成 =====
fid = fopen(reportFile, "w", "n", "UTF-8");
if fid < 0
    error("Cannot open report file: %s", reportFile);
end

fprintf(fid, "# AI_READ_THIS_FIRST\n\n");

fprintf(fid, "## run_id\n\n");
fprintf(fid, "%s\n\n", runId);

fprintf(fid, "## run_type\n\n");
fprintf(fid, "source_gate_decision\n\n");

fprintf(fid, "## input_files\n\n");
fprintf(fid, "- v10: `%s`\n\n", v10File);

fprintf(fid, "## このrunの目的\n\n");
fprintf(fid, "Table8 middle が低く出る理由について、P/xMes条件差だけでなく source差が混じっている可能性を確認する。\n\n");
fprintf(fid, "特に、Table8 が source03、Table9以降が source01 である場合、Table8 middleをL/D検証用の中間点として単純に扱ってよいかを判断する。\n\n");

fprintf(fid, "## 前回までの判断\n\n");
fprintf(fid, "- v12では、PWR_near Table12の正残差と explore_low Table8 middle低下を、いったん別問題として扱う方針にした。\n");
fprintf(fid, "- explore_low Table8/9は、L/D補正式の支持・反証データとして単純には使わないと整理した。\n");
fprintf(fid, "- ただし、Table8がsource03で、他がsource01であるなら、Table8 middle低下にはsource差・装置差・整理系列差も混じる可能性がある。\n\n");

fprintf(fid, "## QC確認\n\n");
fprintf(fid, "- v10の target_rows_T8_12 を読み込み、No_TableNoから SourceID を抽出した。\n");
fprintf(fid, "- SourceIDは、No_TableNo内の `.01_` や `.03_` のような部分から機械的に抽出した。\n");
fprintf(fid, "- このrunでは新規の物理量計算は行わず、source/Table/L-D/P_scope の交絡確認を行った。\n\n");

fprintf(fid, "## 主要結果\n\n");

fprintf(fid, "### source概要\n\n");
fprintf(fid, "- Table8 middle の主source: `%s`\n", t8Source);
fprintf(fid, "- Table9 の主source: `%s`\n", t9Source);
fprintf(fid, "- PWR_near Table10-12 の主source: `%s`\n", pwrSource);
fprintf(fid, "- Table8 middle のsource種類数: %d\n", nT8Sources);
fprintf(fid, "- Table9 のsource種類数: %d\n", nT9Sources);
fprintf(fid, "- PWR_near のsource種類数: %d\n\n", nPwrSources);

fprintf(fid, "### source03の分布\n\n");
fprintf(fid, "- source03のTable: %s\n", src03_tables);
fprintf(fid, "- source03のL/D band: %s\n", src03_bands);
fprintf(fid, "- source03のP_scope: %s\n", src03_scopes);
fprintf(fid, "- source03がTable8だけに閉じているか: %s\n", tfText(source03_only_T8));
fprintf(fid, "- source03がmiddleだけに閉じているか: %s\n\n", tfText(source03_only_middle));

fprintf(fid, "### Table8 middle と Table9 all の差\n\n");
fprintf(fid, "- Table8 middle PM_F1平均: %.3f\n", t8PM);
fprintf(fid, "- Table9 all PM_F1平均: %.3f\n", t9PM);
fprintf(fid, "- PM_F1差, Table8 middle - Table9 all: %.3f\n", deltaPM_T8_T9);
fprintf(fid, "- P差, Table8 middle - Table9 all: %.3f MPa\n", deltaP_T8_T9);
fprintf(fid, "- xMes差, Table8 middle - Table9 all: %.3f\n", deltaX_T8_T9);
fprintf(fid, "- Hsub平均, Table8 middle: %.3f kJ/kg\n", t8H);
fprintf(fid, "- Hsub平均, Table9 all: %.3f kJ/kg\n", t9H);
fprintf(fid, "- qM平均, Table8 middle: %.3f MW/m2\n", t8Q);
fprintf(fid, "- qM平均, Table9 all: %.3f MW/m2\n\n", t9Q);

fprintf(fid, "## MATLAB側の機械的まとめ\n\n");
fprintf(fid, "Table8 middle は Table9 と比べて PM_F1 が低い。\n\n");
fprintf(fid, "ただし、Table8 middle は P/xMes/Hsub/qM がTable9と異なるだけでなく、sourceも異なる可能性がある。\n\n");
fprintf(fid, "source03がTable8 middleにほぼ閉じている場合、source差、Table差、L/D band差、P/xMes条件差を分離できない。\n\n");
fprintf(fid, "したがって、Table8 middleはL/D検証用の中間点としてはさらに使いにくい。\n\n");

fprintf(fid, "## DECISION_GATE\n\n");

fprintf(fid, "### このrunで判断を更新してよい項目\n\n");
fprintf(fid, "- Table8 middle低下には、P/xMes条件差に加えて source差・装置差・整理系列差が混じる可能性がある。\n");
fprintf(fid, "- Table8 middleは、L/D補正式の支持・反証データとして単純には使わない。\n");
fprintf(fid, "- explore_low Table8/9は、PWR_near Table12のL/D/熱履歴保留を否定する材料にはしない。\n\n");

fprintf(fid, "### このrunではまだ判断してはいけない項目\n\n");
fprintf(fid, "- source03だからTable8 middleが低い、と断定すること。\n");
fprintf(fid, "- Table8 middle低下を純粋なsource効果と断定すること。\n");
fprintf(fid, "- Table8 middle低下を理由に、PWR_near Table12の正残差を否定すること。\n");
fprintf(fid, "- L/D補正式を採用すること。\n\n");

fprintf(fid, "### 次のrunに送るべき保留\n\n");
fprintf(fid, "- PWR_near Table10-12はsourceが揃っているなら、PWR_near内でTable12残差を再整理する。\n");
fprintf(fid, "- PWR_near限定で、Table12 long正残差がTable12固有か、P/xMes/qM/物性差か、L/D/熱履歴成分かを再確認する。\n\n");

fprintf(fid, "## ChatGPTにしてほしいこと\n\n");
fprintf(fid, "このrun_report.mdを読んで、以下を日本語で説明してください。\n\n");
fprintf(fid, "1. 今どこまで進んだか\n");
fprintf(fid, "2. このrunで新しく分かったこと\n");
fprintf(fid, "3. 前回判断から変わったこと\n");
fprintf(fid, "4. まだ言ってはいけないこと\n");
fprintf(fid, "5. 危ない解釈\n");
fprintf(fid, "6. 次にやるべきこと\n");
fprintf(fid, "7. result / internal / 保留の扱い\n");
fprintf(fid, "8. 櫻井がコメントすべき最小ポイント\n\n");

fprintf(fid, "## 添付保存物\n\n");
fprintf(fid, "- `summary_tables.xlsx`\n");
fprintf(fid, "- `csv/basic.csv`\n");
fprintf(fid, "- `csv/by_source.csv`\n");
fprintf(fid, "- `csv/by_source_table.csv`\n");
fprintf(fid, "- `csv/by_source_table_LD.csv`\n");
fprintf(fid, "- `csv/source_gate.csv`\n");
fprintf(fid, "- `csv/T8_middle_contrast.csv`\n");
fprintf(fid, "- `csv/decision_summary.csv`\n");

fclose(fid);

%% ===== 表示 =====
disp("=== basic ===");
disp(basic);

disp("=== source gate ===");
disp(sourceGate);

disp("=== contrast ===");
disp(contrast);

fprintf("\nDone.\n");
fprintf("Upload this file next:\n  %s\n", reportFile);
fprintf("\nSaved tables:\n  %s\n", xlsxFile);

%% ===== local functions =====

function sid = extractSourceID(T)
    vars = string(T.Properties.VariableNames);

    cand = ["SourceID", "source_id", "SourceNo", "source_no", "Source", "source"];
    for c = cand
        if any(vars == c)
            sid = string(T.(c));
            sid = normalizeSourceText(sid);
            return;
        end
    end

    if ~any(vars == "No_TableNo")
        sid = repmat("unknown", height(T), 1);
        return;
    end

    key = string(T.No_TableNo);
    sid = strings(size(key));

    for i = 1:numel(key)
        tok = regexp(char(key(i)), '\.(\d+)_', 'tokens', 'once');
        if isempty(tok)
            sid(i) = "unknown";
        else
            sid(i) = string(tok{1});
        end
    end

    sid = normalizeSourceText(sid);
end

function sid = normalizeSourceText(sid)
    sid = string(sid);
    sid = strtrim(sid);
    for i = 1:numel(sid)
        x = sid(i);
        if x == "" || ismissing(x)
            sid(i) = "unknown";
        else
            n = str2double(x);
            if ~isnan(n)
                sid(i) = compose("%02.0f", n);
            else
                sid(i) = x;
            end
        end
    end
end

function S = makeStats(T, groupVars)
    groupVars = string(groupVars);

    if isempty(T)
        S = table();
        return;
    end

    K = unique(T(:, groupVars), "rows");
    S = table();

    for i = 1:height(K)
        m = true(height(T), 1);
        for j = 1:numel(groupVars)
            gv = groupVars(j);
            a = string(T.(gv));
            b = string(K.(gv)(i));
            m = m & (a == b);
        end

        X = T(m, :);

        row = K(i, :);
        row.N = height(X);
        row.Mean_PM_F1 = mean(X.PM_F1, "omitnan");
        row.Median_PM_F1 = median(X.PM_F1, "omitnan");
        row.Mean_HsubTrue = mean(X.Hsub_true_kJkg, "omitnan");
        row.Mean_P_MPa = mean(X.P_MPa, "omitnan");
        row.Mean_xMes = mean(X.x_Mes, "omitnan");
        row.Mean_qM_MW_m2 = mean(X.qM_MW_m2, "omitnan");
        row.Mean_LD = mean(X.LD_geom, "omitnan");
        row.Min_LD = min(X.LD_geom, [], "omitnan");
        row.Max_LD = max(X.LD_geom, [], "omitnan");

        S = [S; row]; %#ok<AGROW>
    end
end

function S = makeSourceGate(T)
    sources = unique(T.SourceID);
    S = table();

    for i = 1:numel(sources)
        src = sources(i);
        X = T(T.SourceID == src, :);

        tableList = join(unique(string(X.TableNo)), ",");
        bandList = join(unique(string(X.LD_band)), ",");
        scopeList = join(unique(string(X.P_scope)), ",");

        row = table(src, height(X), tableList, bandList, scopeList, ...
            numel(unique(X.TableNo)), numel(unique(X.LD_band)), numel(unique(X.P_scope)), ...
            'VariableNames', ["SourceID", "N", "Tables", "LD_bands", "P_scopes", ...
                              "N_tables", "N_LD_bands", "N_P_scopes"]);

        S = [S; row]; %#ok<AGROW>
    end
end

function S = makeContrast(nameA, A, nameB, B)
    S = table(string(nameA), string(nameB), height(A), height(B), ...
        mean(A.PM_F1, "omitnan") - mean(B.PM_F1, "omitnan"), ...
        mean(A.Hsub_true_kJkg, "omitnan") - mean(B.Hsub_true_kJkg, "omitnan"), ...
        mean(A.P_MPa, "omitnan") - mean(B.P_MPa, "omitnan"), ...
        mean(A.x_Mes, "omitnan") - mean(B.x_Mes, "omitnan"), ...
        mean(A.qM_MW_m2, "omitnan") - mean(B.qM_MW_m2, "omitnan"), ...
        mean(A.LD_geom, "omitnan") - mean(B.LD_geom, "omitnan"), ...
        modeString(A.SourceID), modeString(B.SourceID), ...
        'VariableNames', ["GroupA", "GroupB", "N_A", "N_B", ...
                          "Delta_PM_F1_AminusB", "Delta_Hsub_AminusB", ...
                          "Delta_P_AminusB", "Delta_xMes_AminusB", ...
                          "Delta_qM_AminusB", "Delta_LD_AminusB", ...
                          "Source_A", "Source_B"]);
end

function v = getContrastValue(C, a, b, col)
    m = string(C.GroupA) == string(a) & string(C.GroupB) == string(b);
    if any(m)
        v = C.(col)(find(m, 1));
    else
        v = NaN;
    end
end

function s = modeString(x)
    x = string(x);
    if isempty(x)
        s = "none";
        return;
    end
    u = unique(x);
    counts = zeros(numel(u), 1);
    for i = 1:numel(u)
        counts(i) = sum(x == u(i));
    end
    [~, idx] = max(counts);
    s = u(idx);
end

function R = makeDecisionRow(metric, value, note)
    if isnumeric(value)
        v = string(value);
    else
        v = string(value);
    end

    R = table(string(metric), v, string(note), ...
        'VariableNames', ["Metric", "Value", "Note"]);
end

function t = tfText(x)
    if x
        t = "true";
    else
        t = "false";
    end
end