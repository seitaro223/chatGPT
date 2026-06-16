%% h52q_tm8_14_table10_anchor_check_v16c.m
% v16c: Table10支配性チェック
% v16bのsummary_tables.xlsxを読み、Table10有無・Table均等重みでTable12残差を見る

clear; clc;

baseOut = fullfile(pwd, "out_TM8_14");

d = dir(fullfile(baseOut, "run_v16b_xeq_added_*", "summary_tables.xlsx"));
if isempty(d)
    error("v16b summary_tables.xlsx が見つかりません");
end
[~,i] = max([d.datenum]);
v16bXlsx = fullfile(d(i).folder, d(i).name);

ts = string(datetime("now","Format","yyyyMMdd_HHmmss"));
runId = "v16c_table10_anchor_" + ts;
runDir = fullfile(baseOut, "run_" + runId);
if ~exist(runDir,"dir"); mkdir(runDir); end

reportFile = fullfile(runDir, "run_report_" + runId + ".md");
outXlsx = fullfile(runDir, "summary_tables.xlsx");

S = readtable(v16bXlsx, "Sheet","S_source01_9_12", "VariableNamingRule","preserve");

% 必要列
S.TableNo = double(S.TableNo);
S.LD_band = string(S.LD_band);

% モデルに使う列
Y = double(S.PM_F1);
H = double(S.Hsub_true_kJkg);
P = double(S.P_MPa);
Xeq = double(S.xeq_qP_F1);
LD = double(S.LD_geom);

% fitケース
cases = {
    "A_all_T9_10_11_12", true(height(S),1), "none";
    "B_without_Table10", S.TableNo ~= 10, "none";
    "C_table_equal_weight", true(height(S),1), "table_equal";
};

models = {
    "Hsub_P_xeq",     [H, P, Xeq];
    "Hsub_LD_P_xeq", [H, LD, P, Xeq];
};

modelCompare = table();
pairSummary = table();
table10Summary = table();

for c = 1:size(cases,1)
    caseName = string(cases{c,1});
    mask = cases{c,2};
    weightMode = string(cases{c,3});

    Sc = S(mask,:);
    Yc = Y(mask);

    % Table均等重み
    if weightMode == "table_equal"
        w = zeros(height(Sc),1);
        tabs = unique(Sc.TableNo);
        for t = tabs'
            idx = Sc.TableNo == t;
            w(idx) = 1 / sum(idx);
        end
        w = w / mean(w);
    else
        w = ones(height(Sc),1);
    end

    for m = 1:size(models,1)
        modelName = string(models{m,1});
        Xall = models{m,2};
        Xc = Xall(mask,:);

        [resid, R2, RMSE] = wfit_resid(Xc, Yc, w);

        Sc.resid_tmp = resid;

        modelCompare = [modelCompare; table(caseName, modelName, height(Sc), R2, RMSE, ...
            'VariableNames',["Case","Model","N","R2","RMSE"])];

        for tbl = [9 11 12]
            sh = Sc.resid_tmp(Sc.TableNo==tbl & Sc.LD_band=="short_anchor");
            lo = Sc.resid_tmp(Sc.TableNo==tbl & Sc.LD_band=="long");
            pairSummary = [pairSummary; delta_row(caseName, modelName, tbl, sh, lo)];
        end

        % Table10はshortのみの基準点として残差分布を見る
        t10 = Sc.resid_tmp(Sc.TableNo==10);
        table10Summary = [table10Summary; table(caseName, modelName, numel(t10), ...
            mean(t10,"omitnan"), std(t10,"omitnan"), ...
            'VariableNames',["Case","Model","N_Table10","Mean_resid_Table10","SD_resid_Table10"])];
    end
end

writetable(modelCompare, outXlsx, "Sheet","model_compare");
writetable(pairSummary, outXlsx, "Sheet","pair_summary");
writetable(table10Summary, outXlsx, "Sheet","table10_summary");

fid = fopen(reportFile, "w", "n", "UTF-8");

fprintf(fid, "# AI_READ_THIS_FIRST\n\n");
fprintf(fid, "## run_id\n\n%s\n\n", runId);
fprintf(fid, "## run_type\n\ntable10_anchor_check\n\n");
fprintf(fid, "## input_files\n\n- v16b: `%s`\n\n", v16bXlsx);

fprintf(fid, "## 目的\n\n");
fprintf(fid, "v16bでは Hsub+P+x_eq でTable12 long正残差がほぼ消えた。\n\n");
fprintf(fid, "ただしTable10は86点あり、回帰面を支配している可能性がある。\n");
fprintf(fid, "そのため、Table10を含めた場合、除いた場合、Table別均等重みにした場合で、Table12残差がどう変わるかを確認した。\n\n");

fprintf(fid, "## モデル説明力\n\n");
for i = 1:height(modelCompare)
    fprintf(fid, "- %s / %s: N=%d, R2=%.3f, RMSE=%.3f\n", ...
        modelCompare.Case(i), modelCompare.Model(i), modelCompare.N(i), modelCompare.R2(i), modelCompare.RMSE(i));
end

fprintf(fid, "\n## same-table short-long residual\n\n");
for i = 1:height(pairSummary)
    fprintf(fid, "- %s / %s / Table%d: delta=%.3f, SE=%.3f, CI95=[%.3f, %.3f]\n", ...
        pairSummary.Case(i), pairSummary.Model(i), pairSummary.TableNo(i), ...
        pairSummary.Delta(i), pairSummary.SE_delta(i), pairSummary.CI95_low(i), pairSummary.CI95_high(i));
end

fprintf(fid, "\n## Table10 residual summary\n\n");
for i = 1:height(table10Summary)
    fprintf(fid, "- %s / %s: N=%d, mean=%.3f, SD=%.3f\n", ...
        table10Summary.Case(i), table10Summary.Model(i), ...
        table10Summary.N_Table10(i), table10Summary.Mean_resid_Table10(i), table10Summary.SD_resid_Table10(i));
end

fprintf(fid, "\n## ChatGPTにしてほしいこと\n\n");
fprintf(fid, "Table10を含めた場合、除いた場合、Table均等重みの場合で、Table12 long残差が消える判断が維持されるか説明してください。\n");
fprintf(fid, "また、Table10が回帰面を支配していたかどうかを判断してください。\n");

fclose(fid);

fprintf("Done.\nUpload next:\n%s\n", reportFile);

%% local functions
function [resid,R2,RMSE] = wfit_resid(X,y,w)
    X = double(X); y = double(y); w = double(w);
    good = ~isnan(y) & all(~isnan(X),2) & ~isnan(w);
    Xg = X(good,:); yg = y(good); wg = w(good);

    Xd = [ones(size(Xg,1),1), Xg];
    sw = sqrt(wg);
    bw = (Xd.*sw) \ (yg.*sw);
    yh = Xd*bw;

    resid = nan(size(y));
    resid(good) = yg - yh;

    ybar = sum(wg.*yg) / sum(wg);
    SSE = sum(wg .* (yg-yh).^2);
    SST = sum(wg .* (yg-ybar).^2);
    R2 = 1 - SSE/SST;
    RMSE = sqrt(mean((yg-yh).^2));
end

function R = delta_row(caseName, modelName, tbl, sh, lo)
    sh = sh(~isnan(sh)); lo = lo(~isnan(lo));
    d = mean(lo) - mean(sh);

    if numel(sh) > 1 && numel(lo) > 1
        se = sqrt(var(lo)/numel(lo) + var(sh)/numel(sh));
    else
        se = NaN;
    end

    R = table(string(caseName), string(modelName), tbl, numel(sh), numel(lo), ...
        d, se, d-1.96*se, d+1.96*se, ...
        'VariableNames',["Case","Model","TableNo","N_short","N_long","Delta","SE_delta","CI95_low","CI95_high"]);
end