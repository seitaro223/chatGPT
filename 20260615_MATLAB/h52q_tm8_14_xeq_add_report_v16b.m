%% h52q_tm8_14_xeq_add_report_v16b.m
% v16b: resultブックAZ列(HG-HL)からhlgを結合し、xeq_qM / xeq_qP_F1を計算する

clear; clc;

baseOut = fullfile(pwd, "out_TM8_14");
ts = string(datetime("now","Format","yyyyMMdd_HHmmss"));
runId = "v16b_xeq_added_" + ts;
runDir = fullfile(baseOut, "run_" + runId);
if ~exist(runDir,"dir"); mkdir(runDir); end

reportFile = fullfile(runDir, "run_report_" + runId + ".md");
xlsxFile   = fullfile(runDir, "summary_tables.xlsx");

%% 入力
v10 = latestFile(baseOut, "TM8_14_explorelow_truehsub_v10_*.xlsx");
resultBook = "20260612_計算結果比較r8_result_文献追加用.xlsx";

T = readtable(v10, "Sheet","target_rows_T8_12", "VariableNamingRule","preserve");
F = readtable(resultBook, "Sheet","tm_r124_F1_T8_14", "VariableNamingRule","preserve");

T.No_TableNo = string(T.No_TableNo);
F.No_TableNo = string(F.No_TableNo);

%% AZ列 = 52列目を hlg として取得
hlg_raw = double(F{:,52});  % AZ列: HG-HL
H = table(F.No_TableNo, hlg_raw, 'VariableNames', ["No_TableNo","hlg_raw"]);
H = groupsummary(H, "No_TableNo", "mean", "hlg_raw");
H.Properties.VariableNames(end) = "hlg_raw";

T = outerjoin(T, H(:,["No_TableNo","hlg_raw"]), ...
    "Keys","No_TableNo", "MergeKeys",true, "Type","left");

%% 単位自動判定
% hlgが10000未満なら kJ/kg とみなし、J/kgへ変換
if median(T.hlg_raw, "omitnan") < 10000
    T.hlg_Jkg = T.hlg_raw * 1000;
    hlgUnit = "kJ/kg -> J/kg";
else
    T.hlg_Jkg = T.hlg_raw;
    hlgUnit = "J/kg";
end

%% 必要列
G    = double(T.(pick(T, ["G","G_kg_m2s","G_kg_m2_s","MassFlux"])));
LD   = double(T.LD_geom);
Hsub = double(T.Hsub_true_kJkg) * 1000;

if any(strcmp("qM_MW_m2", T.Properties.VariableNames))
    qM = double(T.qM_MW_m2) * 1e6;
else
    qM = double(T.qM);
end

qP_F1 = double(T.PM_F1) .* qM;

%% xeq計算
T.xeq_qM     = (4 .* qM    .* LD ./ G - Hsub) ./ T.hlg_Jkg;
T.xeq_qP_F1 = (4 .* qP_F1 .* LD ./ G - Hsub) ./ T.hlg_Jkg;

%% source01 Table9-12
T.SourceID = extractSource(T.No_TableNo);
S = T(T.SourceID=="01" & ismember(T.TableNo,[9 10 11 12]), :);

%% 残差モデル
S.Hsub_z = zscore_nan(S.Hsub_true_kJkg);

models = {};
models{end+1} = struct("name","Hsub_linear",    "X",double(S.Hsub_true_kJkg));
models{end+1} = struct("name","Hsub_quad",      "X",[S.Hsub_z, S.Hsub_z.^2]);
models{end+1} = struct("name","Hsub_cubic",     "X",[S.Hsub_z, S.Hsub_z.^2, S.Hsub_z.^3]);
models{end+1} = struct("name","Hsub_P_xeq",    "X",[double(S.Hsub_true_kJkg), double(S.P_MPa), double(S.xeq_qP_F1)]);
models{end+1} = struct("name","Hsub_LD_P_xeq", "X",[double(S.Hsub_true_kJkg), double(S.LD_geom), double(S.P_MPa), double(S.xeq_qP_F1)]);

modelCompare = table();
pairSummary = table();

for i = 1:numel(models)
    m = models{i};
    [resid, R2, RMSE] = fitResid(m.X, double(S.PM_F1));
    S.("resid_" + m.name) = resid;

    modelCompare = [modelCompare; table(string(m.name), R2, RMSE, ...
        'VariableNames',["Model","R2","RMSE"])];

    for tbl = [9 11 12]
        sh = resid(S.TableNo==tbl & string(S.LD_band)=="short_anchor");
        lo = resid(S.TableNo==tbl & string(S.LD_band)=="long");
        pairSummary = [pairSummary; deltaRow(tbl, string(m.name), sh, lo)];
    end
end

%% Table8 middle確認
E = T(ismember(T.TableNo,[8 9]), :);
[Eres, R2_E, ~] = fitResid([double(E.Hsub_true_kJkg), double(E.P_MPa), double(E.xeq_qP_F1)], double(E.PM_F1));
E.resid_Hsub_P_xeq = Eres;

t8 = E(E.TableNo==8 & string(E.LD_band)=="middle", :);
t9 = E(E.TableNo==9, :);
T8contrast = table( ...
    mean(t8.PM_F1,"omitnan") - mean(t9.PM_F1,"omitnan"), ...
    mean(t8.resid_Hsub_P_xeq,"omitnan") - mean(t9.resid_Hsub_P_xeq,"omitnan"), ...
    R2_E, ...
    'VariableNames',["Delta_PM_F1_T8middle_minus_T9all","Delta_resid_Hsub_P_xeq","R2_Hsub_P_xeq"]);

%% 保存
writetable(T, xlsxFile, "Sheet","T8_12_with_xeq");
writetable(S, xlsxFile, "Sheet","S_source01_9_12");
writetable(modelCompare, xlsxFile, "Sheet","model_compare");
writetable(pairSummary, xlsxFile, "Sheet","pair_summary");
writetable(T8contrast, xlsxFile, "Sheet","T8_contrast");

%% report
fid = fopen(reportFile, "w", "n", "UTF-8");

fprintf(fid, "# AI_READ_THIS_FIRST\n\n");
fprintf(fid, "## run_id\n\n%s\n\n", runId);
fprintf(fid, "## run_type\n\nxeq_added_from_result_book\n\n");
fprintf(fid, "## input_files\n\n- v10: `%s`\n- result: `%s`\n\n", v10, resultBook);

fprintf(fid, "## 目的\n\n");
fprintf(fid, "resultブック `tm_r124_F1_T8_14` のAZ列 `HG-HL` を hlg として読み、xeq_qM と xeq_qP_F1 を計算した。\n\n");
fprintf(fid, "xeq_qM は実験DNB点確認用、xeq_qP_F1 は予測側・補正候補診断用である。\n\n");

fprintf(fid, "## QC\n\n");
fprintf(fid, "- hlg unit判定: %s\n", hlgUnit);
fprintf(fid, "- hlg欠損: %d\n", sum(isnan(T.hlg_Jkg)));
fprintf(fid, "- xeq_qM欠損: %d\n", sum(isnan(T.xeq_qM)));
fprintf(fid, "- xeq_qP_F1欠損: %d\n", sum(isnan(T.xeq_qP_F1)));
fprintf(fid, "- source01 Table9-12 rows: %d\n\n", height(S));

fprintf(fid, "## モデル説明力 source01 Table9-12\n\n");
for i = 1:height(modelCompare)
    fprintf(fid, "- %s R2: %.3f\n", modelCompare.Model(i), modelCompare.R2(i));
end

fprintf(fid, "\n## same-table short-long residual\n\n");
for i = 1:height(pairSummary)
    fprintf(fid, "- Table%d %s: delta=%.3f, SE=%.3f, CI95=[%.3f, %.3f]\n", ...
        pairSummary.TableNo(i), pairSummary.Model(i), pairSummary.Delta(i), ...
        pairSummary.SE_delta(i), pairSummary.CI95_low(i), pairSummary.CI95_high(i));
end

fprintf(fid, "\n## Table8 middle確認\n\n");
fprintf(fid, "- Table8 middle - Table9 all PM_F1差: %.3f\n", T8contrast.Delta_PM_F1_T8middle_minus_T9all);
fprintf(fid, "- Table8 middle - Table9 all Hsub+P+xeq残差差: %.3f\n", T8contrast.Delta_resid_Hsub_P_xeq);
fprintf(fid, "- Table8/9 Hsub+P+xeq R2: %.3f\n\n", T8contrast.R2_Hsub_P_xeq);

fprintf(fid, "## ChatGPTにしてほしいこと\n\n");
fprintf(fid, "v16bの結果を読み、x_eqでTable12 long残差が残るか、Hsub関数形で消えるか、Table8除外判断が維持されるかを説明してください。\n");

fclose(fid);

fprintf("Done.\nUpload next:\n%s\n", reportFile);

%% local functions
function f = latestFile(folder, pat)
    d = dir(fullfile(folder, pat));
    if isempty(d); error("file not found: %s", pat); end
    [~,i] = max([d.datenum]);
    f = fullfile(d(i).folder, d(i).name);
end

function name = pick(T, cands)
    vars = string(T.Properties.VariableNames);
    for c = cands
        if any(vars == c)
            name = c;
            return;
        end
    end
    error("列が見つかりません。候補: %s", strjoin(cands,", "));
end

function sid = extractSource(keys)
    sid = strings(size(keys));
    for i=1:numel(keys)
        tok = regexp(char(keys(i)), '\.(\d+)_', 'tokens', 'once');
        if isempty(tok); sid(i)="unknown"; else; sid(i)=compose("%02.0f", str2double(tok{1})); end
    end
end

function z = zscore_nan(x)
    x = double(x);
    z = (x - mean(x,"omitnan")) ./ std(x,"omitnan");
end

function [resid,R2,RMSE] = fitResid(X,y)
    X = double(X); y = double(y);
    if isvector(X); X = X(:); end
    good = ~isnan(y) & all(~isnan(X),2);
    resid = nan(size(y));
    Xd = [ones(sum(good),1), X(good,:)];
    b = Xd \ y(good);
    yh = Xd*b;
    resid(good) = y(good)-yh;
    R2 = 1 - sum((y(good)-yh).^2)/sum((y(good)-mean(y(good))).^2);
    RMSE = sqrt(mean((y(good)-yh).^2));
end

function R = deltaRow(tbl, model, sh, lo)
    sh = sh(~isnan(sh)); lo = lo(~isnan(lo));
    d = mean(lo) - mean(sh);
    se = sqrt(var(lo)/numel(lo) + var(sh)/numel(sh));
    R = table(tbl, model, numel(sh), numel(lo), d, se, d-1.96*se, d+1.96*se, ...
        'VariableNames',["TableNo","Model","N_short","N_long","Delta","SE_delta","CI95_low","CI95_high"]);
end