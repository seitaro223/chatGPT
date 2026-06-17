%% ST_BT05_single_tube_xeq_independent_effect.m
% ST-BT05：単管側における x_eq 独立効果の切り分け診断
%
% 目的：
%   ここまでの整理では、単管T&M source01 Table9〜12において、
%   Hsub + P + x_eq を入れると Table12 long 正残差がほぼ消える、
%   という結果が得られている。
%
%   ただし、この結果だけでは、
%     x_eq が本当に独立した説明力を持つのか
%     それとも Hsub / P / Tsub の代理として効いているだけなのか
%   が未確認である。
%
%   ST-BT05では、単管側についてBT05相当の切り分けを行う。
%
% 確認すること：
%   1. PM_F1を Hsub / P / Tsub で説明した後に、x_eq がまだ効くか。
%   2. PM_F1を x_eq で説明した後に、Hsub / P / Tsub がまだ効くか。
%   3. Table12 long正残差が、Hsub線形では残るが、
%      Hsub/P/Tsub/x_eqでどう変わるか。
%   4. 単管で x_eq が効くなら、バンドルBT05で効かなかったことを
%      「単管とバンドルの差」として読む準備をする。
%
% 前提：
%   - qM と x_Mes は結果側量なので、補正式候補には使わない。
%   - x_eq は予測側 qP_F1 と熱収支から計算した量を優先する。
%   - 既に xeq_qP_F1 等の列がある場合はそれを使う。
%   - 無い場合は qP_F1, G, L/D, Hsub, hlg から計算する。
%   - 補正式は作らない。
%
% 入力候補：
%   H52Q_current_single_tube_input_v1_*.xlsx
%     優先シート：ST_F1_T8_14_current
%   fallback:
%     20260612_計算結果比較r8_result_文献追加用.xlsx
%     優先シート：tm_r124_F1_T8_14
%
% 出力：
%   ST_BT05_single_tube_xeq_independent_effect_yyyymmdd_HHMMSS.xlsx
%   run_report_ST_BT05_single_tube_xeq_independent_effect_yyyymmdd_HHMMSS.md

clear; clc;

%% ===== Settings =====

inputFile = latestOrEmpty("H52Q_current_single_tube_input_v1_*.xlsx");
inputRole = "current_single_tube";

if strlength(inputFile)==0
    inputFile = latestOrEmpty("20260612_計算結果比較r8_result_文献追加用.xlsx");
    inputRole = "legacy_r8_fallback";
end

if strlength(inputFile)==0 || ~isfile(inputFile)
    error("Input workbook not found. Put H52Q_current_single_tube_input_v1_*.xlsx or 20260612_計算結果比較r8_result_文献追加用.xlsx in the working folder.");
end

availableSheets = string(sheetnames(inputFile));
f1Sheet = discoverSheet(availableSheets, ["ST_F1_T8_14_current","tm_r124_F1_T8_14"]);
if strlength(f1Sheet)==0
    error("F1 single-tube sheet not found. Expected ST_F1_T8_14_current or tm_r124_F1_T8_14.");
end

ts = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "ST_BT05_single_tube_xeq_independent_effect_" + ts + ".xlsx";
outMd   = "run_report_ST_BT05_single_tube_xeq_independent_effect_" + ts + ".md";

fprintf("input file : %s\n", inputFile);
fprintf("input role : %s\n", inputRole);
fprintf("F1 sheet   : %s\n", f1Sheet);
fprintf("out Excel  : %s\n", outXlsx);
fprintf("out report : %s\n", outMd);

%% ===== Read and build analysis table =====

Traw = readtable(inputFile, 'Sheet', char(f1Sheet), 'VariableNamingRule','preserve');

D0 = buildDataTable(Traw);
D0.input_role = repmat(inputRole,height(D0),1);
D0.input_file = repmat(inputFile,height(D0),1);
D0.source_sheet = repmat(f1Sheet,height(D0),1);

% Target: source01 Table9-12
idxTable = ismember(round(D0.TableNo), [9 10 11 12]);
if any(isfinite(D0.SourceNo))
    idxSource = round(D0.SourceNo)==1;
else
    idxSource = true(height(D0),1);
end

D = D0(idxTable & idxSource, :);
D.LD_group = assignLDGroup(D.TableNo, D.LD);

% remove rows without PM_F1
D = D(isfinite(D.PM_F1), :);

%% ===== Model fitting =====

models = makeModelSpecs(D);
modelSummary = table();
residualLongShort = table();

for i=1:height(models)
    spec = models(i,:);
    [fit, pred, resid] = fitOLS(D, spec.predictors);
    row = table();
    row.model_id = spec.model_id;
    row.predictors = spec.predictors_label;
    row.N = fit.N;
    row.k = fit.k;
    row.R2 = fit.R2;
    row.RMSE = fit.RMSE;
    row.status = fit.status;
    modelSummary = [modelSummary; row]; %#ok<AGROW>

    tmp = makeResidualGroupSummary(D, resid, spec.model_id);
    residualLongShort = [residualLongShort; tmp]; %#ok<AGROW>
end

incremental = makeIncrementalTable(D);
residProbe = makeResidualProbeTable(D);
tableSummary = makeTableSummary(D);
varCorr = makeCorrelationTable(D);
qc = makeQC(inputFile, inputRole, f1Sheet, D0, D, modelSummary);
decisionFlags = makeDecisionFlags(incremental, modelSummary, D);
handoff = makeHandoffTable();

%% ===== Write Excel =====

if exist(outXlsx,"file"); delete(outXlsx); end

writetable(qc, outXlsx, 'Sheet', 'STBT05_QC');
writetable(handoff, outXlsx, 'Sheet', 'handoff_intent');
writetable(D, outXlsx, 'Sheet', 'analysis_rows');
writetable(tableSummary, outXlsx, 'Sheet', 'table_summary');
writetable(varCorr, outXlsx, 'Sheet', 'variable_correlations');
writetable(modelSummary, outXlsx, 'Sheet', 'model_summary');
writetable(incremental, outXlsx, 'Sheet', 'incremental_xeq');
writetable(residProbe, outXlsx, 'Sheet', 'residual_probe');
writetable(residualLongShort, outXlsx, 'Sheet', 'residual_by_table_LD');
writetable(decisionFlags, outXlsx, 'Sheet', 'decision_flags');

%% ===== Markdown report =====

md = strings(0,1);
md(end+1) = "# ST-BT05 single-tube x_eq independent-effect diagnostic";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "単管T&M source01 Table9〜12では、Hsub + P + x_eq によりTable12 long正残差がほぼ消えるという診断結果があった。";
md(end+1) = "ただし、x_eqが本当に独立して効いているのか、Hsub/P/Tsubの代理として効いているだけなのかは未確認だった。";
md(end+1) = "ST-BT05では、単管側について、バンドルBT05相当のx_eq独立効果切り分け診断を行う。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- input file: `" + inputFile + "`";
md(end+1) = "- input role: `" + inputRole + "`";
md(end+1) = "- F1 sheet: `" + f1Sheet + "`";
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
md(end+1) = tableToMarkdown(varCorr);
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
md(end+1) = tableToMarkdown(residualLongShort);
md(end+1) = "";
md(end+1) = "## 11. 判断フラグ";
md(end+1) = "";
md(end+1) = tableToMarkdown(decisionFlags);
md(end+1) = "";
md(end+1) = "## 12. 読み方";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "このrunは、補正式を作るためのものではない。";
md(end+1) = "";
md(end+1) = "見たい問いは次の1点である。";
md(end+1) = "  単管側では、Hsub/P/Tsubを入れた後でも、x_eqが独立に効くのか。";
md(end+1) = "";
md(end+1) = "もしx_eq追加説明力が小さいなら、";
md(end+1) = "  単管でHsub+P+x_eqが効いたように見えた結果は、";
md(end+1) = "  x_eq独立効果ではなく、Hsub/P/Tsubの代理だった可能性が高い。";
md(end+1) = "";
md(end+1) = "もしx_eq追加説明力が大きいなら、";
md(end+1) = "  単管ではx_eqが効くが、バンドルBT05では効かなかった、";
md(end+1) = "  という単管・バンドル差として整理できる。";
md(end+1) = "";
md(end+1) = "どちらの結果でも、バンドル側でF1(Tsub)をすぐF(x_eq)へ置換する判断にはしない。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 13. 次アクション";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "1. ST-BT05の結果をworking_logへ追記する。";
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
disp("=== decision_flags ===");
disp(decisionFlags);
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

function sheet = discoverSheet(sheets, candidates)
sheet = "";
sheets = string(sheets);
for c = string(candidates)
    idx = find(sheets==c, 1);
    if ~isempty(idx)
        sheet = sheets(idx);
        return;
    end
end
normSheets = normName(sheets);
for c = string(candidates)
    idx = find(normSheets==normName(c),1);
    if ~isempty(idx)
        sheet = sheets(idx);
        return;
    end
end
end

function D = buildDataTable(T)
n = height(T);

D = table();
D.row_id = (1:n)';
D.TableNo = getTableNo(T);
D.SourceNo = firstNum(T, ["Source","source","SOURCE","SourceNo","source_no","No_Source","No_source"]);
D.ExptNo = firstNum(T, ["ExptNo","EXPT NO","EXPT_NO","ExperimentNo","Expt_No"]);
D.P_MPa = firstNum(T, ["P_MPa","Pressure_MPa","P","Pressure","圧力"]);
D.G = firstNum(T, ["G","MassFlux","Mass_Flux","G_kgm2s","MASS FLUX","mass flux"]);
D.LD = firstNum(T, ["L_D","L/D","LD","L_over_D","L_DH","L/DH","LDH"]);
D.Hsub_true = firstNum(T, ["Hsub_true_kJkg","Hsub_true_kJ_kg","Hsub_PDF_kJkg","hSub_kJ_kg","Hsub_kJkg","Hsub","H_SUB","InletSubcooling_kJkg"]);
D.Hsub_proxy = firstNum(T, ["Hsub_proxy","Hsub_proxy_kJkg","CPL_Tsub"]);
D.Tsub = firstNum(T, ["Tsub","T_sub","DeltaTsub","Tsub_K","Tsub_C"]);
D.PM_F1 = firstNum(T, ["PM_F1","PM_ratio","PM","P_M","P/M","PoverM"]);
D.qP_F1 = firstNum(T, ["qP_F1","qP","q_calc_F1","qPred_F1","qP_MWm2","qP_Wm2"]);
D.qM = firstNum(T, ["qM","q_exp","qMeasured","qM_MWm2","qM_Wm2"]);
D.hlg = firstNum(T, ["HG-HL","HG_HL","HGHL","h_fg","hfg","hlg","Hfg","H_FG"]);
D.xeq_existing = firstNum(T, ["xeq_qP_F1","x_eq_qP_F1","xeq_qP","x_eq","xeq","xEq"]);

% Prefer true Hsub; fallback to proxy only with flag.
D.Hsub_used = D.Hsub_true;
D.Hsub_status = repmat("true",n,1);
idx = ~isfinite(D.Hsub_used) & isfinite(D.Hsub_proxy);
D.Hsub_used(idx) = D.Hsub_proxy(idx);
D.Hsub_status(idx) = "proxy_fallback";
D.Hsub_status(~isfinite(D.Hsub_used)) = "missing";

[D.x_eq, D.xeq_status] = makeXeq(D);
end

function TableNo = getTableNo(T)
TableNo = firstNum(T, ["TableNo","Table_No","TABLE","Table","No_TableNo"]);
if any(isfinite(TableNo))
    return;
end

% try parse from No_TableNo text, if numeric helper failed
name = findCol(T, ["No_TableNo","TableNo"]);
if strlength(name)>0
    raw = string(T.(char(name)));
    vals = regexp(raw, "\d+", "match", "once");
    TableNo = str2double(string(vals));
else
    TableNo = NaN(height(T),1);
end
end

function [x,status] = makeXeq(D)
n = height(D);
x = D.xeq_existing;
status = repmat("existing_or_missing",n,1);

idxExisting = isfinite(x);
status(idxExisting) = "existing";

idxNeed = ~idxExisting;
if ~any(idxNeed)
    return;
end

q = D.qP_F1;
G = D.G;
LD = D.LD;
Hsub = D.Hsub_used;
hlg = D.hlg;

% unit conversion for q: if typical value below 100, assume MW/m2.
qW = q;
medq = median(q(isfinite(q)));
if isfinite(medq) && medq < 1000
    qW = q * 1e6;
end

% unit conversion for Hsub and hlg: if typical value above 10000, assume J/kg.
Hsub_kJ = Hsub;
medH = median(Hsub(isfinite(Hsub)));
if isfinite(medH) && medH > 10000
    Hsub_kJ = Hsub / 1000;
end

hlg_kJ = hlg;
medHlg = median(hlg(isfinite(hlg)));
if isfinite(medHlg) && medHlg > 10000
    hlg_kJ = hlg / 1000;
end

canCompute = idxNeed & isfinite(qW) & isfinite(G) & isfinite(LD) & isfinite(Hsub_kJ) & isfinite(hlg_kJ) & G~=0 & hlg_kJ~=0;

deltaH_kJkg = qW .* 4 .* LD ./ G ./ 1000;
x(canCompute) = (deltaH_kJkg(canCompute) - Hsub_kJ(canCompute)) ./ hlg_kJ(canCompute);
status(canCompute) = "computed_from_qP_G_LD_Hsub_hlg";
status(idxNeed & ~canCompute) = "missing_or_insufficient_columns";
end

function specs = makeModelSpecs(D)
model_id = strings(0,1);
predictors = strings(0,1);
predictors_label = strings(0,1);

add("M01_Hsub_linear", "Hsub_used", "Hsub");
add("M02_Hsub_quadratic", "Hsub_used,Hsub2", "Hsub + Hsub^2");
add("M03_Hsub_cubic", "Hsub_used,Hsub2,Hsub3", "Hsub + Hsub^2 + Hsub^3");
add("M04_Tsub_linear", "Tsub", "Tsub");
add("M05_xeq_linear", "x_eq", "x_eq");
add("M06_Hsub_P", "Hsub_used,P_MPa", "Hsub + P");
add("M07_Hsub_xeq", "Hsub_used,x_eq", "Hsub + x_eq");
add("M08_Hsub_P_xeq", "Hsub_used,P_MPa,x_eq", "Hsub + P + x_eq");
add("M09_Hsub_P_Tsub", "Hsub_used,P_MPa,Tsub", "Hsub + P + Tsub");
add("M10_Hsub_P_Tsub_xeq", "Hsub_used,P_MPa,Tsub,x_eq", "Hsub + P + Tsub + x_eq");
add("M11_Tsub_P_xeq", "Tsub,P_MPa,x_eq", "Tsub + P + x_eq");
add("M12_Hsub_P_xeq_LD", "Hsub_used,P_MPa,x_eq,LD", "Hsub + P + x_eq + L/D");
add("M13_Hsub_poly2_P_xeq", "Hsub_used,Hsub2,P_MPa,x_eq", "Hsub + Hsub^2 + P + x_eq");

specs = table(model_id,predictors,predictors_label);

    function add(a,b,c)
        model_id(end+1,1) = string(a);
        predictors(end+1,1) = string(b);
        predictors_label(end+1,1) = string(c);
    end
end

function [fit,pred,resid] = fitOLS(D,predictorString)
y = D.PM_F1;
[X,ok,predNames] = designMatrix(D,predictorString);
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

Xok = X(ok,:);
yok = y(ok);

try
    beta = Xok \ yok;
    yhat = Xok * beta;
    e = yok - yhat;
    pred(ok) = yhat;
    resid(ok) = e;

    ssr = sum(e.^2);
    sst = sum((yok - mean(yok)).^2);
    fit.R2 = 1 - ssr/sst;
    fit.RMSE = sqrt(mean(e.^2));
    fit.status = "OK";
catch ME
    fit.status = "CHECK_fit_failed_" + string(ME.identifier);
end
end

function [X,ok,names] = designMatrix(D,predictorString)
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
    case "Hsub_used"
        v = D.Hsub_used;
    case "Hsub2"
        v = D.Hsub_used.^2;
    case "Hsub3"
        v = D.Hsub_used.^3;
    case "P_MPa"
        v = D.P_MPa;
    case "Tsub"
        v = D.Tsub;
    case "x_eq"
        v = D.x_eq;
    case "LD"
        v = D.LD;
    otherwise
        error("Unknown predictor: %s", name);
end
end

function inc = makeIncrementalTable(D)
inc = table();

addPair("x_eq after Hsub", "Hsub_used", "Hsub_used,x_eq");
addPair("x_eq after Hsub+P", "Hsub_used,P_MPa", "Hsub_used,P_MPa,x_eq");
addPair("x_eq after Hsub+P+Tsub", "Hsub_used,P_MPa,Tsub", "Hsub_used,P_MPa,Tsub,x_eq");
addPair("x_eq after Tsub", "Tsub", "Tsub,x_eq");
addPair("x_eq after Tsub+P", "Tsub,P_MPa", "Tsub,P_MPa,x_eq");
addPair("x_eq after Hsub quadratic+P", "Hsub_used,Hsub2,P_MPa", "Hsub_used,Hsub2,P_MPa,x_eq");
addPair("Hsub+P+Tsub after x_eq", "x_eq", "x_eq,Hsub_used,P_MPa,Tsub");

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
    "Hsub_used"
    "Hsub_used,P_MPa"
    "Hsub_used,P_MPa,Tsub"
    "Tsub"
    "Tsub,P_MPa"
    "Hsub_used,Hsub2,P_MPa"
];

for b = bases'
    [fitBase,~,resid] = fitOLS(D,b);
    Dtmp = D;
    Dtmp.PM_F1 = resid;
    [fitProbe,~,~] = fitOLS(Dtmp,"x_eq");

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
for t = tables(:)'
    idxT = round(D.TableNo)==t;
    groups = unique(D.LD_group(idxT),'stable');
    for g = groups(:)'
        idx = idxT & D.LD_group==g;
        row = table();
        row.TableNo = t;
        row.LD_group = string(g);
        row.N = sum(idx);
        row.PM_F1_mean = mean(D.PM_F1(idx),'omitnan');
        row.Hsub_mean = mean(D.Hsub_used(idx),'omitnan');
        row.P_MPa_mean = mean(D.P_MPa(idx),'omitnan');
        row.Tsub_mean = mean(D.Tsub(idx),'omitnan');
        row.x_eq_mean = mean(D.x_eq(idx),'omitnan');
        row.LD_mean = mean(D.LD(idx),'omitnan');
        row.xeq_status_mode = modeString(D.xeq_status(idx));
        S = [S; row]; %#ok<AGROW>
    end
end
end

function C = makeCorrelationTable(D)
pairs = [
    "PM_F1","Hsub_used"
    "PM_F1","P_MPa"
    "PM_F1","Tsub"
    "PM_F1","x_eq"
    "PM_F1","LD"
    "x_eq","Hsub_used"
    "x_eq","P_MPa"
    "x_eq","Tsub"
    "x_eq","LD"
    "Hsub_used","Tsub"
    "Hsub_used","P_MPa"
];

C = table();
for i=1:size(pairs,1)
    a = pairs(i,1);
    b = pairs(i,2);
    va = getVar(D,a);
    vb = getVar(D,b);
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
    case "Hsub_used"
        v = D.Hsub_used;
    case "P_MPa"
        v = D.P_MPa;
    case "Tsub"
        v = D.Tsub;
    case "x_eq"
        v = D.x_eq;
    case "LD"
        v = D.LD;
    otherwise
        v = NaN(height(D),1);
end
end

function R = makeResidualGroupSummary(D,resid,model_id)
R = table();
tables = unique(round(D.TableNo(isfinite(D.TableNo))));
for t = tables(:)'
    idxT = round(D.TableNo)==t;
    groups = unique(D.LD_group(idxT),'stable');
    for g = groups(:)'
        idx = idxT & D.LD_group==g & isfinite(resid);
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
        R = [R; row]; %#ok<AGROW>
    end

    % long-short delta if both exist
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

function Q = makeQC(inputFile,inputRole,f1Sheet,D0,D,modelSummary)
item = strings(0,1);
status = strings(0,1);
value = strings(0,1);
reading = strings(0,1);

add("input_file_exists", ok(strlength(inputFile)>0 && isfile(inputFile)), inputFile, "単管current入力を優先。");
add("input_role", "INFO", inputRole, "current_single_tubeなら正本入口。fallbackなら注意。");
add("F1_sheet", ok(strlength(f1Sheet)>0), f1Sheet, "F1単管シート。");
add("raw_rows", ok(height(D0)>0), sprintf("%d",height(D0)), "読み込み行数。");
add("target_source01_Table9_12_rows", ok(height(D)>0), sprintf("%d",height(D)), "source01 Table9-12対象行。");
add("PM_F1_missing", ok(sum(~isfinite(D.PM_F1))==0), sprintf("%d",sum(~isfinite(D.PM_F1))), "PM_F1欠損。");
add("Hsub_used_missing", ok(sum(~isfinite(D.Hsub_used))==0), sprintf("%d",sum(~isfinite(D.Hsub_used))), "Hsub true優先、無ければproxy fallback。");
add("P_MPa_missing", ok(sum(~isfinite(D.P_MPa))==0), sprintf("%d",sum(~isfinite(D.P_MPa))), "圧力欠損。");
add("Tsub_missing", ok(sum(~isfinite(D.Tsub))==0), sprintf("%d",sum(~isfinite(D.Tsub))), "Tsub欠損。");
add("x_eq_missing", ok(sum(~isfinite(D.x_eq))==0), sprintf("%d",sum(~isfinite(D.x_eq))), "x_eq欠損。existingまたは予測側熱収支から計算。");
add("x_eq_status", "INFO", strjoin(unique(D.xeq_status,'stable'),","), "x_eqの由来。");
add("model_OK_count", ok(sum(modelSummary.status=="OK")>=5), sprintf("%d/%d",sum(modelSummary.status=="OK"),height(modelSummary)), "主要モデルが実行できたか。");
add("qM_policy", "OK", "diagnostic_only_not_predictor", "qMは結果側量なのでモデルには入れない。");
add("xMes_policy", "OK", "not_used_as_predictor", "x_Mesは結果側量として使わない。");

Q = table(item,status,value,reading);

    function add(a,b,c,d)
        item(end+1,1)=string(a);
        status(end+1,1)=string(b);
        value(end+1,1)=string(c);
        reading(end+1,1)=string(d);
    end
end

function Df = makeDecisionFlags(incremental, modelSummary, D)
item = strings(0,1);
status = strings(0,1);
value = strings(0,1);
reading = strings(0,1);

add("task_status", "CHECK_AFTER_RUN", "ST-BT05", "数値結果を見て採否を判断する。");
add("Fform_policy", "fixed_elsewhere", "not_in_scope", "ST-BT05はF_formを扱わない。");
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

add("next_after_STBT05", "summarize_for_user_and_Claude", "personal_summary", "ST-BT05後に全体を私用まとめ＋Claudeレビュー依頼文へ整理する。");

Df = table(item,status,value,reading);

    function add(a,b,c,d)
        item(end+1,1)=string(a);
        status(end+1,1)=string(b);
        value(end+1,1)=string(c);
        reading(end+1,1)=string(d);
    end
end

function H = makeHandoffTable()
step = [
    "ST-BT05"
    "Personal synthesis"
    "Claude Code review request"
    "Literature wait"
];
purpose = [
    "単管側でx_eqがHsub/P/Tsub後も独立に効くか確認する。"
    "単管とバンドルの比較を、櫻井さん自身の理解用に整理する。"
    "全データをClaude Codeに渡す前提で、レビュー依頼文を作る。"
    "L/D・熱履歴はBecker等の追加文献到着後に再検証する。"
];
note = [
    "補正式は作らない。"
    "内部説明用ではなく、次の判断のための整理。"
    "ファイル名・run_report・working_logを読ませる前提。"
    "今あるT&M/BMIではパターン不足。"
];
H = table(step,purpose,note);
end

function g = assignLDGroup(TableNo, LD)
g = strings(numel(TableNo),1);
for t = unique(round(TableNo(isfinite(TableNo))))'
    idx = round(TableNo)==t;
    vals = unique(round(LD(idx & isfinite(LD)),6));
    if isempty(vals)
        g(idx) = "unknown";
    elseif numel(vals)==1
        % Table10 may effectively be single-length anchor.
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

function s = modeString(x)
if isempty(x)
    s = "";
    return;
end
x = string(x);
u = unique(x);
cnt = zeros(numel(u),1);
for i=1:numel(u)
    cnt(i) = sum(x==u(i));
end
[~,j] = max(cnt);
s = u(j);
end

function v = firstNum(T,cands)
v = NaN(height(T),1);
for c = string(cands)
    tmp = numCol(T,c);
    if any(isfinite(tmp))
        v = tmp;
        return;
    end
end
end

function v = numCol(T,cands)
name = findCol(T,cands);
if strlength(name)==0
    v = NaN(height(T),1);
    return;
end
raw = T.(char(name));
if isnumeric(raw)
    v = double(raw);
elseif iscell(raw)
    v = str2double(string(raw));
elseif isstring(raw) || ischar(raw)
    v = str2double(string(raw));
else
    try
        v = double(raw);
    catch
        v = str2double(string(raw));
    end
end
end

function name = findCol(T,cands)
vars = string(T.Properties.VariableNames);
for c = string(cands)
    idx = find(vars==c,1);
    if ~isempty(idx)
        name = vars(idx);
        return;
    end
end
nv = normName(vars);
for c = string(cands)
    idx = find(nv==normName(c),1);
    if ~isempty(idx)
        name = vars(idx);
        return;
    end
end
name = "";
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
for i=1:min(height(T),120)
    row = strings(1,numel(vars));
    for j=1:numel(vars)
        row(j) = val2str(T{i,j});
        row(j) = replace(row(j),"|","/");
        row(j) = replace(row(j),newline," ");
    end
    lines(end+1) = "| " + strjoin(row," | ") + " |";
end
if height(T)>120
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
