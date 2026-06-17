%% ST_BT05_single_tube_xeq_independent_effect_v2.m
% ST-BT05 v2：単管側における x_eq 独立効果の切り分け診断（修正版）
%
% v1の問題：
%   current_single_tube の ST_F1_T8_14_current だけを読んだ結果、
%   Hsub_true, L/D, x_eq計算に必要な情報が欠損し、対象行も22行に落ちた。
%   そのため、x_eq独立効果は not_available であり、v1結果は採用しない。
%
% v2の方針：
%   - 単管側の正本診断ブック v10 の target_rows_T8_12 を読む。
%     ここには Table8〜12 の Hsub_true, P, Tsub, L/D, qP_F1, PM_F1 が入っている。
%   - r8 resultブックの tm_F1_ST から HG-HL = hlg を読み、No_TableNoで結合する。
%   - 予測側 qP_F1 から x_eq_qP_F1 を計算する。
%   - Table9〜12を対象に、Hsub/P/Tsubを入れた後のx_eq追加説明力を確認する。
%
% 目的：
%   単管では Hsub + P + x_eq で Table12 long 正残差がほぼ消えたように見えたが、
%   x_eqがHsub/P/Tsubに対して独立に効いたのか、
%   Hsub/P/Tsubの代理だっただけなのかを確認する。
%
% 注意：
%   - 補正式は作らない。
%   - qMとx_Mesは結果側量なので、補正式候補には使わない。
%   - x_eqは qP_F1, G, L/D, Hsub_true, hlg から前向き側で計算する。
%   - L/D・熱履歴は文献待ちの保留軸とする。

clear; clc;

%% ===== Settings =====

v10File = latestOrEmpty("TM8_14_explorelow_truehsub_v10_*.xlsx");
r8File  = latestOrEmpty("20260612_計算結果比較r8_result_文献追加用.xlsx");

if strlength(v10File)==0 || ~isfile(v10File)
    error("TM8_14_explorelow_truehsub_v10_*.xlsx が見つかりません。");
end
if strlength(r8File)==0 || ~isfile(r8File)
    error("20260612_計算結果比較r8_result_文献追加用.xlsx が見つかりません。");
end

targetSheet = "target_rows_T8_12";
f1Sheet = "tm_F1_ST";

ts = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "ST_BT05_single_tube_xeq_independent_effect_v2_" + ts + ".xlsx";
outMd   = "run_report_ST_BT05_single_tube_xeq_independent_effect_v2_" + ts + ".md";

fprintf("v10 file  : %s\n", v10File);
fprintf("r8 file   : %s\n", r8File);
fprintf("out Excel : %s\n", outXlsx);
fprintf("out report: %s\n", outMd);

%% ===== Read source tables =====

T10raw = readtable(v10File, 'Sheet', char(targetSheet), 'VariableNamingRule','preserve');
R8raw  = readtable(r8File,  'Sheet', char(f1Sheet),     'VariableNamingRule','preserve');

D10 = buildFromV10(T10raw);
R8  = buildHlgFromR8(R8raw);

% Join hlg from r8 by No_TableNo.
D = innerjoin(D10, R8, 'Keys', 'No_TableNo');

% Compute x_eq from qP_F1 side.
D.x_eq_qP_F1 = computeXeq(D.qP_F1, D.G, D.LD_geom, D.Hsub_true_kJkg, D.hlg_kJkg);

% Main target: Table9-12.  Table8 is kept out of this ST-BT05 main check.
D_all_T8_12 = D;
D = D(ismember(round(D.TableNo), [9 10 11 12]), :);

% Remove rows with missing main variables.
needed = isfinite(D.PM_F1) & isfinite(D.Hsub_true_kJkg) & isfinite(D.P_MPa) & ...
         isfinite(D.Tsub) & isfinite(D.x_eq_qP_F1);
D = D(needed, :);

D.LD_group = assignLDGroup(D.TableNo, D.LD_geom);

%% ===== Analyses =====

modelSpecs = makeModelSpecs();
modelSummary = table();
residGroup = table();

for i=1:height(modelSpecs)
    [fit, pred, resid] = fitOLS(D, modelSpecs.predictors(i));
    row = table();
    row.model_id = modelSpecs.model_id(i);
    row.predictors = modelSpecs.predictors_label(i);
    row.N = fit.N;
    row.k = fit.k;
    row.R2 = fit.R2;
    row.RMSE = fit.RMSE;
    row.status = fit.status;
    modelSummary = [modelSummary; row]; %#ok<AGROW>

    tmp = makeResidualGroupSummary(D, resid, modelSpecs.model_id(i));
    residGroup = [residGroup; tmp]; %#ok<AGROW>
end

incremental = makeIncrementalTable(D);
residProbe  = makeResidualProbeTable(D);
tableSummary = makeTableSummary(D);
corrSummary = makeCorrelationTable(D);
qc = makeQC(v10File, r8File, T10raw, R8raw, D10, R8, D_all_T8_12, D, modelSummary);
decision = makeDecisionFlags(incremental, residProbe);

%% ===== Write Excel =====

if exist(outXlsx,"file"); delete(outXlsx); end

writetable(qc, outXlsx, 'Sheet', 'STBT05v2_QC');
writetable(D, outXlsx, 'Sheet', 'analysis_rows_T9_12');
writetable(tableSummary, outXlsx, 'Sheet', 'table_summary');
writetable(corrSummary, outXlsx, 'Sheet', 'correlations');
writetable(modelSummary, outXlsx, 'Sheet', 'model_summary');
writetable(incremental, outXlsx, 'Sheet', 'incremental_xeq');
writetable(residProbe, outXlsx, 'Sheet', 'residual_probe');
writetable(residGroup, outXlsx, 'Sheet', 'residual_by_table_LD');
writetable(decision, outXlsx, 'Sheet', 'decision_flags');

%% ===== Markdown report =====

md = strings(0,1);
md(end+1) = "# ST-BT05 v2 single-tube x_eq independent-effect diagnostic";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "ST-BT05 v1では、current_single_tube入力だけではHsub_trueとx_eq計算に必要な列が不足し、x_eq独立効果を確認できなかった。";
md(end+1) = "v2では、v10のtarget_rows_T8_12とr8のtm_F1_STをNo_TableNoで結合し、qP_F1側の熱収支からx_eqを計算して、単管側のx_eq独立効果を確認する。";
md(end+1) = "";
md(end+1) = "見たい問いは、単管T&M Table9〜12で、Hsub/P/Tsubを入れた後でもx_eqが独立に効くか、である。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- v10 file: `" + v10File + "`";
md(end+1) = "- v10 sheet: `" + targetSheet + "`";
md(end+1) = "- r8 file: `" + r8File + "`";
md(end+1) = "- r8 sheet: `" + f1Sheet + "`";
md(end+1) = "";
md(end+1) = "## 3. 出力";
md(end+1) = "";
md(end+1) = "- output Excel: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 4. QC";
md(end+1) = "";
md(end+1) = tableToMarkdown(qc);
md(end+1) = "";
md(end+1) = "## 5. 対象データsummary";
md(end+1) = "";
md(end+1) = tableToMarkdown(tableSummary);
md(end+1) = "";
md(end+1) = "## 6. 変数相関";
md(end+1) = "";
md(end+1) = tableToMarkdown(corrSummary);
md(end+1) = "";
md(end+1) = "## 7. モデルsummary";
md(end+1) = "";
md(end+1) = tableToMarkdown(modelSummary);
md(end+1) = "";
md(end+1) = "## 8. x_eq追加説明力";
md(end+1) = "";
md(end+1) = tableToMarkdown(incremental);
md(end+1) = "";
md(end+1) = "## 9. 残差化後のx_eq説明力";
md(end+1) = "";
md(end+1) = tableToMarkdown(residProbe);
md(end+1) = "";
md(end+1) = "## 10. Table別・L/D群別残差";
md(end+1) = "";
md(end+1) = tableToMarkdown(residGroup);
md(end+1) = "";
md(end+1) = "## 11. 判断フラグ";
md(end+1) = "";
md(end+1) = tableToMarkdown(decision);
md(end+1) = "";
md(end+1) = "## 12. 読み方";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "このrunは補正式作成ではない。";
md(end+1) = "";
md(end+1) = "単管側でx_eqがHsub/P/Tsub後も独立に効くなら、";
md(end+1) = "  単管ではx_eqが効くが、バンドルBT05では効かない、";
md(end+1) = "  という単管・バンドル差として読む。";
md(end+1) = "";
md(end+1) = "単管側でもx_eq追加説明力が小さいなら、";
md(end+1) = "  Hsub+P+x_eqが効いたように見えたのは、";
md(end+1) = "  x_eq独立効果ではなくHsub/P/Tsubの代理だった可能性が高い。";
md(end+1) = "";
md(end+1) = "どちらでも、バンドル側のF1(Tsub)をすぐ置換する判断にはしない。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 13. 次アクション";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "1. ST-BT05 v2の結果をworking_logへ追記する。";
md(end+1) = "2. 単管・バンドル比較を私用まとめとして整理する。";
md(end+1) = "3. Claude Codeに全データを渡す前提で、レビュー依頼文を作る。";
md(end+1) = "4. L/D・熱履歴の追加検証はBecker等の文献待ちに回す。";
md(end+1) = "```";

fid = fopen(outMd,"w");
for i=1:numel(md)
    fprintf(fid,"%s\n",md(i));
end
fclose(fid);

disp("=== QC ===");
disp(qc);
disp("=== incremental_xeq ===");
disp(incremental);
disp("=== decision ===");
disp(decision);

fprintf("Wrote %s\n", outXlsx);
fprintf("Wrote %s\n", outMd);

%% ===== local functions =====

function f = latestOrEmpty(pattern)
d = dir(pattern);
if isempty(d)
    f = "";
else
    [~,i] = max([d.datenum]);
    f = string(d(i).name);
end
end

function D = buildFromV10(T)
D = table();
D.No_TableNo = string(T.("No_TableNo"));
D.TableNo = col(T,"TableNo");
D.P_Pa = col(T,"P_Pa");
D.P_MPa = col(T,"P_MPa");
D.G = col(T,"G");
D.DH = col(T,"DH");
D.L = col(T,"L");
D.LD_geom = col(T,"LD_geom");
D.LD_band_v10 = stringCol(T,"LD_band");
D.Tsub = col(T,"Tsub");
D.x_Mes_result_side = col(T,"x_Mes");
D.qM_result_side = col(T,"qM");
D.qP_F1 = col(T,"qP_F1");
D.PM_F1 = col(T,"PM_F1");
D.Hsub_true_kJkg = col(T,"Hsub_true_kJkg");
D.Hsub_source = stringCol(T,"Hsub_source");
end

function R = buildHlgFromR8(T)
R = table();
R.No_TableNo = string(T.("No_TableNo"));
h = col(T,"HG-HL");
% r8 hlg is usually J/kg. Convert to kJ/kg if needed.
if median(h(isfinite(h))) > 10000
    h = h / 1000;
end
R.hlg_kJkg = h;
end

function v = col(T,name)
name = string(name);
vars = string(T.Properties.VariableNames);
idx = find(vars==name,1);
if isempty(idx)
    idx = find(normName(vars)==normName(name),1);
end
if isempty(idx)
    v = NaN(height(T),1);
    return;
end
raw = T.(char(vars(idx)));
if isnumeric(raw)
    v = double(raw);
else
    v = str2double(string(raw));
end
end

function s = stringCol(T,name)
vars = string(T.Properties.VariableNames);
idx = find(vars==string(name),1);
if isempty(idx)
    idx = find(normName(vars)==normName(name),1);
end
if isempty(idx)
    s = strings(height(T),1);
else
    s = string(T.(char(vars(idx))));
end
end

function x = computeXeq(qP, G, LD, Hsub_kJkg, hlg_kJkg)
% qP expected W/m2 in v10. If it is MW/m2, auto-convert.
q = qP;
medq = median(q(isfinite(q)));
if isfinite(medq) && medq < 1000
    q = q * 1e6;
end

% delta h from heat input to DNB:
% q * heated perimeter / flow area * L/G
% for round tube: perimeter/area = 4/D, so q*4*L/D/G = q*4*LD/G
deltaH_kJkg = q .* 4 .* LD ./ G ./ 1000;
x = (deltaH_kJkg - Hsub_kJkg) ./ hlg_kJkg;
end

function specs = makeModelSpecs()
model_id = strings(0,1);
predictors = strings(0,1);
predictors_label = strings(0,1);

add("M01_Hsub_linear", "Hsub_true_kJkg", "Hsub");
add("M02_Hsub_quadratic", "Hsub_true_kJkg,Hsub2", "Hsub + Hsub^2");
add("M03_Hsub_cubic", "Hsub_true_kJkg,Hsub2,Hsub3", "Hsub + Hsub^2 + Hsub^3");
add("M04_Tsub_linear", "Tsub", "Tsub");
add("M05_xeq_linear", "x_eq_qP_F1", "x_eq");
add("M06_Hsub_P", "Hsub_true_kJkg,P_MPa", "Hsub + P");
add("M07_Hsub_xeq", "Hsub_true_kJkg,x_eq_qP_F1", "Hsub + x_eq");
add("M08_Hsub_P_xeq", "Hsub_true_kJkg,P_MPa,x_eq_qP_F1", "Hsub + P + x_eq");
add("M09_Hsub_P_Tsub", "Hsub_true_kJkg,P_MPa,Tsub", "Hsub + P + Tsub");
add("M10_Hsub_P_Tsub_xeq", "Hsub_true_kJkg,P_MPa,Tsub,x_eq_qP_F1", "Hsub + P + Tsub + x_eq");
add("M11_Tsub_P_xeq", "Tsub,P_MPa,x_eq_qP_F1", "Tsub + P + x_eq");
add("M12_Hsub_P_xeq_LD", "Hsub_true_kJkg,P_MPa,x_eq_qP_F1,LD_geom", "Hsub + P + x_eq + L/D");
add("M13_Hsub_poly2_P_xeq", "Hsub_true_kJkg,Hsub2,P_MPa,x_eq_qP_F1", "Hsub + Hsub^2 + P + x_eq");

specs = table(model_id,predictors,predictors_label);

    function add(a,b,c)
        model_id(end+1,1) = string(a);
        predictors(end+1,1) = string(b);
        predictors_label(end+1,1) = string(c);
    end
end

function [fit,pred,resid] = fitOLS(D,predictorString)
y = D.PM_F1;
[X,ok] = designMatrix(D,predictorString);
ok = ok & isfinite(y);
pred = NaN(height(D),1);
resid = NaN(height(D),1);

fit = struct();
fit.N = sum(ok);
fit.k = size(X,2);
fit.R2 = NaN;
fit.RMSE = NaN;
fit.status = "CHECK_not_enough_rows";

if fit.N <= fit.k + 1
    return;
end

try
    Xok = X(ok,:);
    yok = y(ok);
    beta = Xok \ yok;
    yhat = Xok * beta;
    e = yok - yhat;
    pred(ok) = yhat;
    resid(ok) = e;
    fit.R2 = 1 - sum(e.^2) / sum((yok - mean(yok)).^2);
    fit.RMSE = sqrt(mean(e.^2));
    fit.status = "OK";
catch ME
    fit.status = "CHECK_fit_failed_" + string(ME.identifier);
end
end

function [X,ok] = designMatrix(D,predictorString)
names = strtrim(split(string(predictorString),","));
X = ones(height(D),1);
ok = true(height(D),1);

for i=1:numel(names)
    v = getPredictor(D,names(i));
    X = [X, v]; %#ok<AGROW>
    ok = ok & isfinite(v);
end
end

function v = getPredictor(D,name)
name = string(name);
switch name
    case "Hsub_true_kJkg"
        v = D.Hsub_true_kJkg;
    case "Hsub2"
        v = D.Hsub_true_kJkg.^2;
    case "Hsub3"
        v = D.Hsub_true_kJkg.^3;
    case "P_MPa"
        v = D.P_MPa;
    case "Tsub"
        v = D.Tsub;
    case "x_eq_qP_F1"
        v = D.x_eq_qP_F1;
    case "LD_geom"
        v = D.LD_geom;
    otherwise
        error("Unknown predictor: %s", name);
end
end

function inc = makeIncrementalTable(D)
inc = table();
addPair("x_eq after Hsub", "Hsub_true_kJkg", "Hsub_true_kJkg,x_eq_qP_F1");
addPair("x_eq after Hsub+P", "Hsub_true_kJkg,P_MPa", "Hsub_true_kJkg,P_MPa,x_eq_qP_F1");
addPair("x_eq after Hsub+P+Tsub", "Hsub_true_kJkg,P_MPa,Tsub", "Hsub_true_kJkg,P_MPa,Tsub,x_eq_qP_F1");
addPair("x_eq after Tsub", "Tsub", "Tsub,x_eq_qP_F1");
addPair("x_eq after Tsub+P", "Tsub,P_MPa", "Tsub,P_MPa,x_eq_qP_F1");
addPair("x_eq after Hsub quadratic+P", "Hsub_true_kJkg,Hsub2,P_MPa", "Hsub_true_kJkg,Hsub2,P_MPa,x_eq_qP_F1");
addPair("Hsub+P+Tsub after x_eq", "x_eq_qP_F1", "x_eq_qP_F1,Hsub_true_kJkg,P_MPa,Tsub");

    function addPair(label,basePred,fullPred)
        [fb,~,~] = fitOLS(D,basePred);
        [ff,~,~] = fitOLS(D,fullPred);
        row = table();
        row.test = string(label);
        row.base_predictors = string(basePred);
        row.full_predictors = string(fullPred);
        row.N_base = fb.N;
        row.R2_base = fb.R2;
        row.R2_full = ff.R2;
        row.delta_R2 = ff.R2 - fb.R2;
        if isfinite(row.delta_R2)
            if row.delta_R2 >= 0.02
                row.reading = "meaningful_increment_check";
            elseif row.delta_R2 >= 0.005
                row.reading = "small_increment";
            else
                row.reading = "very_small_increment";
            end
        else
            row.reading = "not_available";
        end
        inc = [inc; row]; %#ok<AGROW>
    end
end

function R = makeResidualProbeTable(D)
R = table();
bases = [
    "Hsub_true_kJkg"
    "Hsub_true_kJkg,P_MPa"
    "Hsub_true_kJkg,P_MPa,Tsub"
    "Tsub"
    "Tsub,P_MPa"
    "Hsub_true_kJkg,Hsub2,P_MPa"
];

for i=1:numel(bases)
    b = bases(i);
    [fitBase,~,resid] = fitOLS(D,b);
    Dtmp = D;
    Dtmp.PM_F1 = resid;
    [fitProbe,~,~] = fitOLS(Dtmp,"x_eq_qP_F1");

    row = table();
    row.base_model = string(b);
    row.base_R2 = fitBase.R2;
    row.residual_vs_xeq_R2 = fitProbe.R2;
    row.N = fitProbe.N;
    if isfinite(fitProbe.R2)
        if fitProbe.R2 >= 0.05
            row.reading = "x_eq_remains_after_base";
        elseif fitProbe.R2 >= 0.01
            row.reading = "x_eq_weak_after_base";
        else
            row.reading = "x_eq_almost_gone_after_base";
        end
    else
        row.reading = "not_available";
    end
    R = [R; row]; %#ok<AGROW>
end
end

function S = makeTableSummary(D)
S = table();
tables = unique(round(D.TableNo(isfinite(D.TableNo))));
for i=1:numel(tables)
    t = tables(i);
    idxT = round(D.TableNo)==t;
    groups = unique(D.LD_group(idxT),'stable');
    for j=1:numel(groups)
        g = groups(j);
        idx = idxT & D.LD_group==g;
        row = table();
        row.TableNo = t;
        row.LD_group = string(g);
        row.N = sum(idx);
        row.PM_F1_mean = mean(D.PM_F1(idx),'omitnan');
        row.Hsub_mean = mean(D.Hsub_true_kJkg(idx),'omitnan');
        row.P_MPa_mean = mean(D.P_MPa(idx),'omitnan');
        row.Tsub_mean = mean(D.Tsub(idx),'omitnan');
        row.x_eq_mean = mean(D.x_eq_qP_F1(idx),'omitnan');
        row.LD_mean = mean(D.LD_geom(idx),'omitnan');
        row.xMes_result_side_mean = mean(D.x_Mes_result_side(idx),'omitnan');
        S = [S; row]; %#ok<AGROW>
    end
end
end

function C = makeCorrelationTable(D)
pairs = [
    "PM_F1","Hsub_true_kJkg"
    "PM_F1","P_MPa"
    "PM_F1","Tsub"
    "PM_F1","x_eq_qP_F1"
    "PM_F1","LD_geom"
    "x_eq_qP_F1","Hsub_true_kJkg"
    "x_eq_qP_F1","P_MPa"
    "x_eq_qP_F1","Tsub"
    "x_eq_qP_F1","LD_geom"
    "Hsub_true_kJkg","Tsub"
    "Hsub_true_kJkg","P_MPa"
];

C = table();
for i=1:size(pairs,1)
    a = pairs(i,1); b = pairs(i,2);
    va = getVar(D,a); vb = getVar(D,b);
    ok = isfinite(va) & isfinite(vb);
    row = table();
    row.var_y = a;
    row.var_x = b;
    row.N = sum(ok);
    if sum(ok) >= 3
        r = corr(va(ok),vb(ok));
        row.R = r;
        row.R2 = r^2;
    else
        row.R = NaN;
        row.R2 = NaN;
    end
    C = [C; row]; %#ok<AGROW>
end
end

function v = getVar(D,name)
name = string(name);
switch name
    case "PM_F1"
        v = D.PM_F1;
    case "Hsub_true_kJkg"
        v = D.Hsub_true_kJkg;
    case "P_MPa"
        v = D.P_MPa;
    case "Tsub"
        v = D.Tsub;
    case "x_eq_qP_F1"
        v = D.x_eq_qP_F1;
    case "LD_geom"
        v = D.LD_geom;
    otherwise
        v = NaN(height(D),1);
end
end

function R = makeResidualGroupSummary(D,resid,model_id)
R = table();
tables = unique(round(D.TableNo(isfinite(D.TableNo))));
for ii=1:numel(tables)
    t = tables(ii);
    idxT = round(D.TableNo)==t;
    groups = unique(D.LD_group(idxT),'stable');

    for jj=1:numel(groups)
        g = groups(jj);
        idx = idxT & D.LD_group==g & isfinite(resid);
        row = oneResidualRow(model_id,t,string(g),resid,idx);
        R = [R; row]; %#ok<AGROW>
    end

    idxS = idxT & D.LD_group=="short" & isfinite(resid);
    idxL = idxT & D.LD_group=="long" & isfinite(resid);
    if any(idxS) && any(idxL)
        row = table();
        row.model_id = string(model_id);
        row.TableNo = t;
        row.LD_group = "long_minus_short";
        row.N = sum(idxL) + sum(idxS);
        mL = mean(resid(idxL),'omitnan');
        mS = mean(resid(idxS),'omitnan');
        sdL = std(resid(idxL),'omitnan');
        sdS = std(resid(idxS),'omitnan');
        se = sqrt(sdL^2/sum(idxL) + sdS^2/sum(idxS));
        row.resid_mean = mL - mS;
        row.resid_sd = NaN;
        row.resid_se = se;
        row.resid_ci95_low = row.resid_mean - 1.96*se;
        row.resid_ci95_high = row.resid_mean + 1.96*se;
        R = [R; row]; %#ok<AGROW>
    end
end
end

function row = oneResidualRow(model_id,t,g,resid,idx)
row = table();
row.model_id = string(model_id);
row.TableNo = t;
row.LD_group = string(g);
row.N = sum(idx);
if row.N > 0
    row.resid_mean = mean(resid(idx),'omitnan');
    row.resid_sd = std(resid(idx),'omitnan');
    row.resid_se = row.resid_sd / sqrt(row.N);
    row.resid_ci95_low = row.resid_mean - 1.96*row.resid_se;
    row.resid_ci95_high = row.resid_mean + 1.96*row.resid_se;
else
    row.resid_mean = NaN;
    row.resid_sd = NaN;
    row.resid_se = NaN;
    row.resid_ci95_low = NaN;
    row.resid_ci95_high = NaN;
end
end

function Q = makeQC(v10File,r8File,T10raw,R8raw,D10,R8,Dall,D,modelSummary)
item = strings(0,1);
status = strings(0,1);
value = strings(0,1);
reading = strings(0,1);

add("v10_file_exists", ok(isfile(v10File)), v10File, "Hsub true付きTable8-12診断ブック。");
add("r8_file_exists", ok(isfile(r8File)), r8File, "hlg取得元。");
add("v10_raw_rows", ok(height(T10raw)>0), sprintf("%d",height(T10raw)), "target_rows_T8_12。");
add("r8_raw_rows", ok(height(R8raw)>0), sprintf("%d",height(R8raw)), "tm_F1_ST。");
add("join_rows_T8_12", ok(height(Dall)>0), sprintf("%d",height(Dall)), "No_TableNo結合後。");
add("target_Table9_12_rows", ok(height(D)>0), sprintf("%d",height(D)), "ST-BT05主対象。");
add("Hsub_missing", ok(sum(~isfinite(D.Hsub_true_kJkg))==0), sprintf("%d",sum(~isfinite(D.Hsub_true_kJkg))), "Hsub true欠損。");
add("P_missing", ok(sum(~isfinite(D.P_MPa))==0), sprintf("%d",sum(~isfinite(D.P_MPa))), "P欠損。");
add("Tsub_missing", ok(sum(~isfinite(D.Tsub))==0), sprintf("%d",sum(~isfinite(D.Tsub))), "Tsub欠損。");
add("hlg_missing", ok(sum(~isfinite(D.hlg_kJkg))==0), sprintf("%d",sum(~isfinite(D.hlg_kJkg))), "hlg欠損。");
add("x_eq_missing", ok(sum(~isfinite(D.x_eq_qP_F1))==0), sprintf("%d",sum(~isfinite(D.x_eq_qP_F1))), "qP_F1側x_eq欠損。");
add("model_OK_count", ok(sum(modelSummary.status=="OK")>=8), sprintf("%d/%d",sum(modelSummary.status=="OK"),height(modelSummary)), "主要モデル実行数。");
add("qM_policy", "OK", "diagnostic_only", "qMは結果側量。モデルには入れない。");
add("xMes_policy", "OK", "diagnostic_only", "x_Mesは結果側量。モデルには入れない。");

Q = table(item,status,value,reading);

    function add(a,b,c,d)
        item(end+1,1)=string(a);
        status(end+1,1)=string(b);
        value(end+1,1)=string(c);
        reading(end+1,1)=string(d);
    end
end

function Df = makeDecisionFlags(incremental, residProbe)
item = strings(0,1);
status = strings(0,1);
value = strings(0,1);
reading = strings(0,1);

add("task_status", "CHECK_AFTER_RUN", "ST-BT05_v2", "数値結果を見て採否を判断する。");
add("v1_policy", "not_adopt", "missing_Hsub_xeq", "ST-BT05 v1はx_eq独立効果を計算できなかった。");
add("Fform_policy", "closed", "linear_v1_fixed", "F_formは本タスク対象外。追加監査しない。");
add("LD_policy", "deferred", "literature_wait", "L/D・熱履歴はBecker等の文献待ち。");
add("qM_policy", "do_not_use", "result_side", "qMは補正式入力に使わない。");
add("xMes_policy", "do_not_use", "result_side", "x_Mesは補正式入力に使わない。");

idx = incremental.test=="x_eq after Hsub+P+Tsub";
if any(idx) && isfinite(incremental.delta_R2(idx))
    dR2 = incremental.delta_R2(idx);
    if dR2 >= 0.02
        add("x_eq_independent_effect_after_Hsub_P_Tsub", "possible", sprintf("delta_R2=%.6g",dR2), "単管ではx_eqが独立に効く可能性。バンドルとの差として重要。");
    elseif dR2 >= 0.005
        add("x_eq_independent_effect_after_Hsub_P_Tsub", "weak", sprintf("delta_R2=%.6g",dR2), "小さい追加効果。慎重に読む。");
    else
        add("x_eq_independent_effect_after_Hsub_P_Tsub", "weak_or_none", sprintf("delta_R2=%.6g",dR2), "x_eqはHsub/P/Tsubの代理だった可能性。");
    end
else
    add("x_eq_independent_effect_after_Hsub_P_Tsub", "CHECK", "not_available", "x_eq追加説明力を計算できていない。");
end

add("next_after_STBT05_v2", "summarize_for_user_and_Claude", "personal_summary", "ST-BT05後に全体を私用まとめ＋Claudeレビュー依頼文へ整理する。");

Df = table(item,status,value,reading);

    function add(a,b,c,d)
        item(end+1,1)=string(a);
        status(end+1,1)=string(b);
        value(end+1,1)=string(c);
        reading(end+1,1)=string(d);
    end
end

function g = assignLDGroup(TableNo, LD)
g = strings(numel(TableNo),1);
for ii = 1:numel(unique(round(TableNo(isfinite(TableNo)))))
    tables = unique(round(TableNo(isfinite(TableNo))));
    t = tables(ii);
    idx = round(TableNo)==t;
    vals = unique(round(LD(idx & isfinite(LD)),6));
    if isempty(vals)
        g(idx) = "unknown";
    elseif numel(vals)==1
        g(idx) = "single";
    elseif numel(vals)==2
        lo = min(vals); hi = max(vals);
        g(idx & abs(round(LD,6)-lo)<1e-9) = "short";
        g(idx & abs(round(LD,6)-hi)<1e-9) = "long";
    else
        lo = min(vals); hi = max(vals);
        g(idx & abs(round(LD,6)-lo)<1e-9) = "short";
        g(idx & abs(round(LD,6)-hi)<1e-9) = "long";
        g(idx & g=="") = "middle";
    end
end
g(g=="") = "unknown";
end

function n = normName(s)
n = lower(string(s));
n = regexprep(n,"[^a-z0-9]","");
end

function s = ok(tf)
if tf
    s = "OK";
else
    s = "CHECK";
end
end

function md = tableToMarkdown(T)
if height(T)==0
    md = "_empty_";
    return;
end
vars = string(T.Properties.VariableNames);
lines = strings(0,1);
lines(end+1) = "| " + strjoin(vars," | ") + " |";
lines(end+1) = "| " + strjoin(repmat("---",1,numel(vars))," | ") + " |";
for i=1:min(height(T),160)
    row = strings(1,numel(vars));
    for j=1:numel(vars)
        row(j) = val2str(T{i,j});
        row(j) = replace(row(j),"|","/");
        row(j) = replace(row(j),newline," ");
    end
    lines(end+1) = "| " + strjoin(row," | ") + " |";
end
if height(T)>160
    lines(end+1) = "| " + strjoin(repmat("...",1,numel(vars))," | ") + " |";
end
md = strjoin(lines,newline);
end

function s = val2str(x)
if isnumeric(x)
    if isempty(x) || (isscalar(x) && isnan(x))
        s = "";
    elseif isscalar(x)
        s = string(sprintf("%.8g",x));
    else
        s = strjoin(string(x(:)'),",");
    end
elseif isstring(x)
    s = strjoin(x(:)',",");
elseif iscell(x)
    try
        s = strjoin(string(x),",");
    catch
        s = "";
    end
elseif islogical(x)
    s = string(x);
else
    try
        s = string(x);
    catch
        s = "";
    end
end
end
