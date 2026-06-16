%% h52q_tm8_14_scope_split_report_v12.m
% H52Q / T&M Table 8-14
% v12: PWR_near と explore_low を分けて扱う判断ゲートrun
%
% 新運用:
%   主出力: run_report.md
%   保存用: summary_tables.xlsx, csv
%
% 入力:
%   out_TM8_14/TM8_14_explorelow_truehsub_v10_*.xlsx
%   out_TM8_14/TM8_14_table8_middle_decomp_v11_*.xlsx
%
% 出力:
%   out_TM8_14/run_v12_scope_split_yyyymmdd_HHMMSS/run_report.md
%   out_TM8_14/run_v12_scope_split_yyyymmdd_HHMMSS/summary_tables.xlsx
%   out_TM8_14/run_v12_scope_split_yyyymmdd_HHMMSS/csv/*.csv

clear; clc; close all;

%% ===== 出力フォルダ =====
baseOut = fullfile(pwd, "out_TM8_14");
timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
runId = "v12_scope_split_" + timestamp;

runDir = fullfile(baseOut, "run_" + runId);
csvDir = fullfile(runDir, "csv");

if ~exist(runDir, "dir"); mkdir(runDir); end
if ~exist(csvDir, "dir"); mkdir(csvDir); end

reportFile = fullfile(runDir, "run_report.md");
xlsxFile = fullfile(runDir, "summary_tables.xlsx");

%% ===== 入力ファイル取得 =====
v10Files = dir(fullfile(baseOut, "TM8_14_explorelow_truehsub_v10_*.xlsx"));
if isempty(v10Files)
    error("v10 file not found: TM8_14_explorelow_truehsub_v10_*.xlsx");
end
[~, i10] = max([v10Files.datenum]);
v10File = fullfile(v10Files(i10).folder, v10Files(i10).name);

v11Files = dir(fullfile(baseOut, "TM8_14_table8_middle_decomp_v11_*.xlsx"));
if isempty(v11Files)
    error("v11 file not found: TM8_14_table8_middle_decomp_v11_*.xlsx");
end
[~, i11] = max([v11Files.datenum]);
v11File = fullfile(v11Files(i11).folder, v11Files(i11).name);

fprintf("v10 input: %s\n", v10File);
fprintf("v11 input: %s\n", v11File);
fprintf("run dir  : %s\n", runDir);

%% ===== 読み込み =====
v10_basic = readtable(v10File, "Sheet", "basic", "VariableNamingRule", "preserve");
v10_model = readtable(v10File, "Sheet", "model_compare_by_scope", "VariableNamingRule", "preserve");
v10_scopeLD = readtable(v10File, "Sheet", "by_scope_LD", "VariableNamingRule", "preserve");
v10_pairs = readtable(v10File, "Sheet", "same_table_pairs", "VariableNamingRule", "preserve");
v10_middle = readtable(v10File, "Sheet", "Table8_middle_context", "VariableNamingRule", "preserve");
v10_direction = readtable(v10File, "Sheet", "direction_check", "VariableNamingRule", "preserve");

v11_group = readtable(v11File, "Sheet", "group_summary", "VariableNamingRule", "preserve");
v11_contrast = readtable(v11File, "Sheet", "group_contrast", "VariableNamingRule", "preserve");
v11_model = readtable(v11File, "Sheet", "model_compare_PM_F1", "VariableNamingRule", "preserve");
v11_match = readtable(v11File, "Sheet", "match_summary", "VariableNamingRule", "preserve");
v11_flags = readtable(v11File, "Sheet", "interpretation_flags", "VariableNamingRule", "preserve");

%% ===== 主要値抽出 =====

% v10 direction
pwrRow = v10_direction(string(v10_direction.Scope) == "PWR_near_T10_12", :);
lowRow = v10_direction(string(v10_direction.Scope) == "explore_low_T8_9", :);

pwr_long_minus_short = getFirst(pwrRow, "LongMinusShort");
low_long_minus_short = getFirst(lowRow, "LongMinusShort");
low_middle_minus_short = getFirst(lowRow, "MiddleMinusShort");

% v10 middle context
t9short = v10_middle(string(v10_middle.Group) == "T9_short", :);
t8mid = v10_middle(string(v10_middle.Group) == "T8_middle", :);
t9long = v10_middle(string(v10_middle.Group) == "T9_long", :);

t9short_pm = getFirst(t9short, "Mean_PM_F1");
t8mid_pm = getFirst(t8mid, "Mean_PM_F1");
t9long_pm = getFirst(t9long, "Mean_PM_F1");

t9short_res = getFirst(t9short, "Mean_resid_HsubOnly");
t8mid_res = getFirst(t8mid, "Mean_resid_HsubOnly");
t9long_res = getFirst(t9long, "Mean_resid_HsubOnly");

% v11 model R2
r2_hsub = getR2(v11_model, "Hsub_only");
r2_hsub_p = getR2(v11_model, "Hsub_P");
r2_hsub_x = getR2(v11_model, "Hsub_xMes");
r2_hsub_px = getR2(v11_model, "Hsub_P_xMes");
r2_hsub_px_t8 = getR2(v11_model, "Hsub_P_xMes_Table8Dummy");
r2_hsub_px_qm = getR2(v11_model, "Hsub_P_xMes_qM");

% v11 contrast T8 middle vs T9 all
c = v11_contrast(string(v11_contrast.GroupA) == "T8_middle" & string(v11_contrast.GroupB) == "T9_all", :);
delta_pm_t8_t9 = getFirst(c, "Delta_PM_F1_AminusB");
delta_p_t8_t9 = getFirst(c, "Delta_P_AminusB");
delta_x_t8_t9 = getFirst(c, "Delta_xMes_AminusB");
delta_hsub_t8_t9 = getFirst(c, "Delta_Hsub_AminusB");
delta_qm_t8_t9 = getFirst(c, "Delta_qM_AminusB");

%% ===== summary table =====
decision_summary = table( ...
    ["PWR_near_LongMinusShort_HsubOnly"; ...
     "ExploreLow_LongMinusShort_HsubOnly"; ...
     "ExploreLow_MiddleMinusShort_HsubOnly"; ...
     "T9_short_PM_F1"; ...
     "T8_middle_PM_F1"; ...
     "T9_long_PM_F1"; ...
     "T9_short_HsubOnlyResid"; ...
     "T8_middle_HsubOnlyResid"; ...
     "T9_long_HsubOnlyResid"; ...
     "v11_R2_HsubOnly"; ...
     "v11_R2_Hsub_P"; ...
     "v11_R2_Hsub_xMes"; ...
     "v11_R2_Hsub_P_xMes"; ...
     "v11_R2_Hsub_P_xMes_Table8Dummy"; ...
     "v11_R2_Hsub_P_xMes_qM"; ...
     "T8middle_minus_T9all_PM_F1"; ...
     "T8middle_minus_T9all_P"; ...
     "T8middle_minus_T9all_xMes"; ...
     "T8middle_minus_T9all_Hsub"; ...
     "T8middle_minus_T9all_qM"], ...
    [pwr_long_minus_short; ...
     low_long_minus_short; ...
     low_middle_minus_short; ...
     t9short_pm; ...
     t8mid_pm; ...
     t9long_pm; ...
     t9short_res; ...
     t8mid_res; ...
     t9long_res; ...
     r2_hsub; ...
     r2_hsub_p; ...
     r2_hsub_x; ...
     r2_hsub_px; ...
     r2_hsub_px_t8; ...
     r2_hsub_px_qm; ...
     delta_pm_t8_t9; ...
     delta_p_t8_t9; ...
     delta_x_t8_t9; ...
     delta_hsub_t8_t9; ...
     delta_qm_t8_t9], ...
    'VariableNames', ["Metric", "Value"]);

%% ===== 保存 =====
writetable(decision_summary, xlsxFile, "Sheet", "decision_summary");
writetable(v10_basic, xlsxFile, "Sheet", "v10_basic");
writetable(v10_direction, xlsxFile, "Sheet", "v10_direction_check");
writetable(v10_middle, xlsxFile, "Sheet", "v10_Table8_middle_context");
writetable(v11_group, xlsxFile, "Sheet", "v11_group_summary");
writetable(v11_contrast, xlsxFile, "Sheet", "v11_group_contrast");
writetable(v11_model, xlsxFile, "Sheet", "v11_model_compare_PM_F1");
writetable(v11_match, xlsxFile, "Sheet", "v11_match_summary");
writetable(v11_flags, xlsxFile, "Sheet", "v11_interpretation_flags");

writetable(decision_summary, fullfile(csvDir, "decision_summary.csv"));
writetable(v10_direction, fullfile(csvDir, "v10_direction_check.csv"));
writetable(v10_middle, fullfile(csvDir, "v10_Table8_middle_context.csv"));
writetable(v11_group, fullfile(csvDir, "v11_group_summary.csv"));
writetable(v11_contrast, fullfile(csvDir, "v11_group_contrast.csv"));
writetable(v11_model, fullfile(csvDir, "v11_model_compare_PM_F1.csv"));
writetable(v11_match, fullfile(csvDir, "v11_match_summary.csv"));

%% ===== run_report.md作成 =====
fid = fopen(reportFile, "w", "n", "UTF-8");
if fid < 0
    error("Cannot open report file: %s", reportFile);
end

fprintf(fid, "# AI_READ_THIS_FIRST\n\n");

fprintf(fid, "## run_id\n\n");
fprintf(fid, "%s\n\n", runId);

fprintf(fid, "## run_type\n\n");
fprintf(fid, "scope_split_decision_gate\n\n");

fprintf(fid, "## input_files\n\n");
fprintf(fid, "- v10: `%s`\n", v10File);
fprintf(fid, "- v11: `%s`\n\n", v11File);

fprintf(fid, "## このrunの目的\n\n");
fprintf(fid, "v10/v11までの結果を使って、PWR_near Table10-12 と explore_low Table8-9 を同じ補正式候補に混ぜてよいかを判断する。\n\n");
fprintf(fid, "特に、PWR_near Table12に残る正残差と、explore_low Table8 middle低下を同じL/D問題として扱うべきかを確認する。\n\n");

fprintf(fid, "## 前回までの判断\n\n");
fprintf(fid, "- v9では、PWR_near Table12 long側の真Hsub補正後正残差は、L/Dを入れると大きく低減した。\n");
fprintf(fid, "- v10では、explore_low Table8/9を含めると、Hsub補正後残差は同じL/D方向には並ばなかった。\n");
fprintf(fid, "- v11では、Table8 middle低下は、L/DではなくxMesとPの違いでかなり説明できる可能性が高いと整理した。\n\n");

fprintf(fid, "## QC確認\n\n");
fprintf(fid, "- v10/v11の既存出力を読み込み、主要表を再集約した。\n");
fprintf(fid, "- このrunでは新規の結合・再計算は行わず、判断ゲート用の再整理を行った。\n");
fprintf(fid, "- 元のQCはv10/v11のQC結果を前提とする。\n\n");

fprintf(fid, "## 主要結果\n\n");
fprintf(fid, "### PWR_near側\n\n");
fprintf(fid, "- PWR_nearのHsub-only補正後 long-short 残差差: %.3f\n", pwr_long_minus_short);
fprintf(fid, "- したがって、PWR_nearではlong側が上に残る傾向は維持される。\n\n");

fprintf(fid, "### explore_low側\n\n");
fprintf(fid, "- explore_lowのHsub-only補正後 long-short 残差差: %.3f\n", low_long_minus_short);
fprintf(fid, "- explore_lowのHsub-only補正後 middle-short 残差差: %.3f\n", low_middle_minus_short);
fprintf(fid, "- Table8 middle PM_F1: %.3f\n", t8mid_pm);
fprintf(fid, "- Table8 middle Hsub-only残差: %.3f\n\n", t8mid_res);

fprintf(fid, "### Table8 middle低下の分解\n\n");
fprintf(fid, "- Hsub only R2: %.3f\n", r2_hsub);
fprintf(fid, "- Hsub + P R2: %.3f\n", r2_hsub_p);
fprintf(fid, "- Hsub + xMes R2: %.3f\n", r2_hsub_x);
fprintf(fid, "- Hsub + P + xMes R2: %.3f\n", r2_hsub_px);
fprintf(fid, "- Hsub + P + xMes + Table8 dummy R2: %.3f\n", r2_hsub_px_t8);
fprintf(fid, "- Hsub + P + xMes + qM R2: %.3f\n\n", r2_hsub_px_qm);

fprintf(fid, "Table8 middle - Table9 all の差:\n\n");
fprintf(fid, "- PM_F1差: %.3f\n", delta_pm_t8_t9);
fprintf(fid, "- P差: %.3f MPa\n", delta_p_t8_t9);
fprintf(fid, "- xMes差: %.3f\n", delta_x_t8_t9);
fprintf(fid, "- Hsub差: %.3f kJ/kg\n", delta_hsub_t8_t9);
fprintf(fid, "- qM差: %.3f MW/m2\n\n", delta_qm_t8_t9);

fprintf(fid, "## MATLAB側の機械的まとめ\n\n");
fprintf(fid, "PWR_nearでは、Hsub補正後もlong側に正残差が残る。\n\n");
fprintf(fid, "一方、explore_lowでは、Table8 middleが低く、short-middle-longのL/D方向の単純な並びは出ない。\n\n");
fprintf(fid, "ただし、Table8 middleの低下はxMesとPを入れるとかなり説明でき、Table8 dummyを追加しても説明力はほとんど改善しない。\n\n");
fprintf(fid, "このため、explore_low Table8/9は、L/D補正式の支持または反証データとして単純には扱いにくい。\n\n");

fprintf(fid, "## DECISION_GATE\n\n");
fprintf(fid, "### このrunで判断を更新してよい項目\n\n");
fprintf(fid, "- PWR_near Table12の正残差と、explore_low Table8 middle低下は、いったん別問題として扱う。\n");
fprintf(fid, "- explore_low Table8/9は、L/D補正式の支持・反証データとして単純には使わない。\n");
fprintf(fid, "- explore_lowは、xMes/P依存を確認する診断データとして扱う。\n\n");

fprintf(fid, "### このrunではまだ判断してはいけない項目\n\n");
fprintf(fid, "- PWR_near Table12の正残差を純粋なL/D効果と断定すること。\n");
fprintf(fid, "- L/D補正式を採用すること。\n");
fprintf(fid, "- explore_lowを理由にPWR_near Table12の保留を否定すること。\n\n");

fprintf(fid, "### 次のrunに送るべき保留\n\n");
fprintf(fid, "- PWR_near Table12に限定して、正残差がTable12固有か、圧力・物性・xMes・qMで説明できるかをさらに整理する。\n");
fprintf(fid, "- 補正式候補に進むなら、PWR_near限定のローカル補正として扱うかを検討する。\n\n");

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
fprintf(fid, "- `csv/decision_summary.csv`\n");
fprintf(fid, "- `csv/v10_direction_check.csv`\n");
fprintf(fid, "- `csv/v10_Table8_middle_context.csv`\n");
fprintf(fid, "- `csv/v11_group_summary.csv`\n");
fprintf(fid, "- `csv/v11_group_contrast.csv`\n");
fprintf(fid, "- `csv/v11_model_compare_PM_F1.csv`\n");
fprintf(fid, "- `csv/v11_match_summary.csv`\n");

fclose(fid);

%% ===== 表示 =====
disp("=== decision_summary ===");
disp(decision_summary);

fprintf("\nDone.\n");
fprintf("Upload this file next:\n  %s\n", reportFile);
fprintf("\nSaved tables:\n  %s\n", xlsxFile);

%% ===== local functions =====

function v = getFirst(T, colName)
    if isempty(T)
        v = NaN;
        return;
    end
    if ~ismember(colName, string(T.Properties.VariableNames))
        v = NaN;
        return;
    end
    x = T.(colName);
    if isempty(x)
        v = NaN;
    else
        v = x(1);
    end
end

function r2 = getR2(T, modelName)
    if isempty(T)
        r2 = NaN;
        return;
    end
    m = string(T.Model) == string(modelName);
    if any(m)
        r2 = T.R2(find(m, 1));
    else
        r2 = NaN;
    end
end