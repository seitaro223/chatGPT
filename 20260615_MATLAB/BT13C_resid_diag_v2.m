%% BT13C_resid_diag_v2.m
% BT13-C：FformLinear_v1再計算済みcurrent_bundle_input_v2で残差診断を再実行
%
% 背景：
%   BT13では、F_form列だけがlinear_v1で、q_calc/PM列がlegacy値のままという
%   不整合な入力を読んでいた。
%
%   BT13-Bで、FformLinear_v1再計算済みr125/r126マクロから
%   H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible を作成し、
%   F_form、q_calc、PMが整合した正本入力を作った。
%
% 目的：
%   - BT13-Bの正本入力を使って、BT13相当の残差診断を再実行する。
%   - FformLinear_v1再計算後のPM_F1残差を確認する。
%   - 108が過大側、164が改善側へ動いた状態を正本入力で再確認する。
%   - F1後残差がTsub/x_eq側ではなく、F_form・DNB位置・L/DH側に残るかを再診断する。
%
% 前提：
%   - F2/F1F2は使わない。
%   - 比較対象はnoF1とF1のみ。
%   - F1(Tsub)は維持する。
%   - F1(Tsub)をF(x_eq)へ置換しない。
%   - F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。
%   - qM/qPは診断量として扱い、補正式入力には使わない。
%   - BT13-Cでは補正式を作らない。
%
% 入力：
%   H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_*.xlsx
%
% 出力：
%   BT13C_resid_diag_v2_yyyymmdd_HHMMSS.xlsx
%   run_report_BT13C_resid_diag_v2_yyyymmdd_HHMMSS.md

clear; clc;

%% ===== Settings =====

inputFile = "";
if strlength(inputFile)==0
    inputFile = latest("H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_*.xlsx");
end

ts = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "BT13C_resid_diag_v2_" + ts + ".xlsx";
outMd   = "run_report_BT13C_resid_diag_v2_" + ts + ".md";

bundles = ["108","161","164"];

fprintf("Input : %s\n", inputFile);
fprintf("Excel : %s\n", outXlsx);
fprintf("Report: %s\n", outMd);

%% ===== Read paired sheets =====

D = table();

for b = bundles
    T0 = readtable(inputFile, 'Sheet', "tm_" + b, 'VariableNamingRule','preserve');
    T1 = readtable(inputFile, 'Sheet', "tm_F1_" + b, 'VariableNamingRule','preserve');
    D = [D; pairBundle(T0,T1,str2double(b))]; %#ok<AGROW>
end

%% ===== Diagnostics columns =====

D.err_noF1 = D.PM_noF1 - 1;
D.err_F1   = D.PM_F1 - 1;
D.abs_err_noF1 = abs(D.err_noF1);
D.abs_err_F1   = abs(D.err_F1);
D.delta_PM = D.PM_F1 - D.PM_noF1;
D.lift_ratio = D.PM_F1 ./ D.PM_noF1;

D.case_group = strings(height(D),1);
for i=1:height(D)
    if D.Bundle(i)==108
        if round(D.No(i))==252 || round(D.No(i))==253
            D.case_group(i)="108_76in";
        else
            D.case_group(i)="108_70in";
        end
    elseif D.Bundle(i)==161
        D.case_group(i)="161_uniform";
    elseif D.Bundle(i)==164
        if round(D.No(i))==339
            D.case_group(i)="164_112in";
        else
            D.case_group(i)="164_134in_normal";
        end
    end
end

%% ===== Summaries =====

qc = makeQC(D,inputFile);

bundleSummary = groupSummary(D,"Bundle");
caseSummary = groupSummary(D,"case_group");
contrast108 = contrast108vsOthers(D);
simpleR2 = simpleR2Table(D);
models = modelTable(D);
residR2 = residualizedTable(D);
confounds = confoundTable(D);

%% ===== Write Excel =====

if exist(outXlsx,"file"); delete(outXlsx); end

writetable(D,outXlsx,'Sheet','BT13C_rows');
writetable(qc,outXlsx,'Sheet','BT13C_QC');
writetable(bundleSummary,outXlsx,'Sheet','bundle_summary');
writetable(caseSummary,outXlsx,'Sheet','case_summary');
writetable(contrast108,outXlsx,'Sheet','contrast_108_vs_others');
writetable(simpleR2,outXlsx,'Sheet','simple_R2');
writetable(models,outXlsx,'Sheet','exploratory_models');
writetable(residR2,outXlsx,'Sheet','residualized_R2');
writetable(confounds,outXlsx,'Sheet','pairwise_confounds');

%% ===== Markdown report =====

md = strings(0,1);
md(end+1) = "# BT13-C residual diagnostic using FformLinearRecalc tmCompatible v2";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT13-Bで作成したFformLinear_v1再計算済みcurrent_bundle_input_v2を用いて、BT13相当の残差診断を再実行する。";
md(end+1) = "BT13で見つかったF_form列とq_calc/PM列の不整合が解消された状態で、108/161/164のF1後残差を確認する。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- input: `" + inputFile + "`";
md(end+1) = "";
md(end+1) = "## 3. 出力";
md(end+1) = "";
md(end+1) = "- output Excel: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 4. 前提";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "- F2/F1F2は使わない。";
md(end+1) = "- 比較対象はnoF1とF1のみ。";
md(end+1) = "- F1(Tsub)は維持する。";
md(end+1) = "- F1(Tsub)をF(x_eq)へ置換しない。";
md(end+1) = "- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。";
md(end+1) = "- qM/qPは診断量であり、補正式入力には使わない。";
md(end+1) = "- BT13-Cでは補正式を作らない。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 5. QC";
md(end+1) = "";
md(end+1) = tableToMarkdown(qc);
md(end+1) = "";
md(end+1) = "## 6. Bundle summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(bundleSummary);
md(end+1) = "";
md(end+1) = "## 7. Case summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(caseSummary);
md(end+1) = "";
md(end+1) = "## 8. 108 vs 161/164 contrast";
md(end+1) = "";
md(end+1) = tableToMarkdown(contrast108);
md(end+1) = "";
md(end+1) = "## 9. Simple R2 diagnostics";
md(end+1) = "";
md(end+1) = tableToMarkdown(simpleR2);
md(end+1) = "";
md(end+1) = "## 10. Exploratory models";
md(end+1) = "";
md(end+1) = tableToMarkdown(models);
md(end+1) = "";
md(end+1) = "## 11. Residualized R2";
md(end+1) = "";
md(end+1) = tableToMarkdown(residR2);
md(end+1) = "";
md(end+1) = "## 12. Pairwise confounds";
md(end+1) = "";
md(end+1) = tableToMarkdown(confounds);
md(end+1) = "";
md(end+1) = "## 13. 判断メモ";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "このrun_reportを確認して判断する。";
md(end+1) = "見るべきポイント：";
md(end+1) = "  1. 108はFformLinear_v1再計算後に過大側へ残るか。";
md(end+1) = "  2. 164はlegacy時代より改善しているか。";
md(end+1) = "  3. F1後残差はTsub/x_eqより、F_form・DNB位置・L/DH側に残るか。";
md(end+1) = "  4. F_form、z_DNB/DH、z_DNB/L、L/DHがどの程度交絡しているか。";
md(end+1) = "  5. 補正式を作らず、診断項として保留する判断でよいか。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 14. 次アクション";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "BT13-C結果を確認する。";
md(end+1) = "問題なければworking_logへ追記する。";
md(end+1) = "その後、BT14としてF_form・DNB位置・非一様加熱分布側の扱いを整理する。";
md(end+1) = "```";

fid = fopen(outMd,"w");
for i=1:numel(md)
    fprintf(fid,"%s\n",md(i));
end
fclose(fid);

disp("=== QC ===");
disp(qc);
disp("=== Bundle summary ===");
disp(bundleSummary);

fprintf("Wrote %s\n", outXlsx);
fprintf("Wrote %s\n", outMd);

%% ===== local functions =====

function f = latest(pattern)
d = dir(pattern);
if isempty(d); error("No file matching %s",pattern); end
[~,i]=max([d.datenum]);
f=string(d(i).name);
end

function D = pairBundle(T0,T1,bundle)
no0 = numCol(T0,["No","NO","no"]);
no1 = numCol(T1,["No","NO","no"]);

[commonNo,ia,ib] = intersect(no0,no1,'stable');
T0 = T0(ia,:);
T1 = T1(ib,:);

D = table();
D.Bundle = repmat(bundle,height(T0),1);
D.No = commonNo;

D.q_exp = firstNum(T1,["q_exp","q_M","qM","q_M_MW","qM_MW","qMes","q_Mes"]);
if all(~isfinite(D.q_exp))
    D.q_exp = firstNum(T0,["q_exp","q_M","qM","q_M_MW","qM_MW","qMes","q_Mes"]);
end

D.q_calc_noF1 = firstNum(T0,["q_calc","q_P","qP","q_P_MW","qP_MW","qCal","q_Cal"]);
D.q_calc_F1   = firstNum(T1,["q_calc","q_P","qP","q_P_MW","qP_MW","qCal","q_Cal"]);

D.PM_noF1 = firstNum(T0,["PM_ratio","PM","P_M","P/M","PoverM"]);
D.PM_F1   = firstNum(T1,["PM_ratio","PM","P_M","P/M","PoverM"]);

if all(~isfinite(D.PM_noF1)) && any(isfinite(D.q_calc_noF1)) && any(isfinite(D.q_exp))
    D.PM_noF1 = D.q_calc_noF1 ./ D.q_exp;
end
if all(~isfinite(D.PM_F1)) && any(isfinite(D.q_calc_F1)) && any(isfinite(D.q_exp))
    D.PM_F1 = D.q_calc_F1 ./ D.q_exp;
end

D.Tsub = firstNonMissing(T1,T0,["Tsub","T_sub","DeltaTsub","dTsub"]);
D.Fcorr = firstNonMissing(T1,T0,["Fcorr","F_corr","F1","F_1"]);
D.F_form = firstNonMissing(T1,T0,["F_form","Fform","F_FORM"]);
D.x_eq = firstNonMissing(T1,T0,["x_Mes","xMes","x_eq","xeq"]);

D.L_DNB = firstNonMissing(T1,T0,["L_DNB","LDNB","z_DNB","zDNB"]);
D.L = firstNonMissing(T1,T0,["L","Length","HeatedLength"]);
D.DH = firstNonMissing(T1,T0,["DH","D_h","Dh","HydraulicDiameter"]);

D.z_DNB_DH = firstNonMissing(T1,T0,["z_DNB_DH","LDNB_DH","L_DNB_DH"]);
if all(~isfinite(D.z_DNB_DH)) && any(isfinite(D.L_DNB)) && any(isfinite(D.DH))
    D.z_DNB_DH = D.L_DNB ./ D.DH;
end

D.z_DNB_L = firstNonMissing(T1,T0,["z_DNB_L","LDNB_L","L_DNB_L"]);
if all(~isfinite(D.z_DNB_L)) && any(isfinite(D.L_DNB)) && any(isfinite(D.L))
    D.z_DNB_L = D.L_DNB ./ D.L;
end

D.L_DH = firstNonMissing(T1,T0,["L_DH","LDH","L_over_DH"]);
if all(~isfinite(D.L_DH)) && any(isfinite(D.L)) && any(isfinite(D.DH))
    D.L_DH = D.L ./ D.DH;
end
end

function v = firstNonMissing(T1,T0,cands)
v = firstNum(T1,cands);
if all(~isfinite(v))
    v = firstNum(T0,cands);
end
end

function Q = makeQC(D,inputFile)
item = strings(0,1); status = strings(0,1); value = strings(0,1); reading = strings(0,1);
add("input_file","info",inputFile,"BT13-Bで作成したFformLinearRecalc tmCompatible v2");
add("row_count",ok(height(D)==58),sprintf("%d",height(D)),"108=14, 161=23, 164=21 合計58行が期待値");
add("bundle_count",ok(numel(unique(D.Bundle))==3),sprintf("%d",numel(unique(D.Bundle))),"108/161/164の3群");
add("PM_F1_missing",ok(sum(~isfinite(D.PM_F1))==0),sprintf("%d",sum(~isfinite(D.PM_F1))),"PM_F1欠損");
add("PM_noF1_missing",ok(sum(~isfinite(D.PM_noF1))==0),sprintf("%d",sum(~isfinite(D.PM_noF1))),"PM_noF1欠損");
add("F_form_missing",ok(sum(~isfinite(D.F_form))==0),sprintf("%d",sum(~isfinite(D.F_form))),"F_form欠損");
add("Tsub_missing",ok(sum(~isfinite(D.Tsub))==0),sprintf("%d",sum(~isfinite(D.Tsub))),"Tsub欠損");
add("x_eq_missing",ok(sum(~isfinite(D.x_eq))==0),sprintf("%d",sum(~isfinite(D.x_eq))),"x_eq欠損");
add("z_DNB_DH_missing",ok(sum(~isfinite(D.z_DNB_DH))==0),sprintf("%d",sum(~isfinite(D.z_DNB_DH))),"z_DNB/DH欠損");
add("L_DH_missing",ok(sum(~isfinite(D.L_DH))==0),sprintf("%d",sum(~isfinite(D.L_DH))),"L/DH欠損");
add("Fform_recalc_reference","OK","BT13-B","F_form/q_calc/PM整合済み入力を使用");
add("formula_policy","OK","no_new_formula","BT13-Cでは補正式を作らない");
add("F1_policy","OK","keep_F1_Tsub","F1(Tsub)を維持する");
Q = table(item,status,value,reading);
    function add(a,b,c,d)
        item(end+1,1)=string(a); status(end+1,1)=string(b);
        value(end+1,1)=string(c); reading(end+1,1)=string(d);
    end
end

function S = groupSummary(D,groupName)
g = string(D.(groupName));
ug = unique(g,'stable');
S = table();
for k=1:numel(ug)
    idx = g==ug(k);
    row = table();
    row.group = ug(k);
    row.N = sum(idx);
    row.No_min = min(D.No(idx),[],'omitnan');
    row.No_max = max(D.No(idx),[],'omitnan');

    vars = ["q_exp","q_calc_noF1","q_calc_F1","PM_noF1","PM_F1","err_F1","abs_err_F1", ...
            "delta_PM","lift_ratio","Tsub","Fcorr","F_form","x_eq","z_DNB_DH","z_DNB_L","L_DH"];
    for vname = vars
        v = D.(vname);
        row.(vname+"_mean") = mean(v(idx),'omitnan');
        row.(vname+"_sd") = std(v(idx),'omitnan');
    end
    S = [S; row]; %#ok<AGROW>
end
end

function C = contrast108vsOthers(D)
idx108 = D.Bundle==108;
idxOther = D.Bundle==161 | D.Bundle==164;
vars = ["PM_noF1","PM_F1","err_F1","abs_err_F1","delta_PM","lift_ratio", ...
        "q_exp","q_calc_F1","Tsub","Fcorr","F_form","x_eq","z_DNB_DH","z_DNB_L","L_DH"];
C = table();
for vname = vars
    v = D.(vname);
    row = table();
    row.variable = vname;
    row.mean_108 = mean(v(idx108),'omitnan');
    row.mean_161164 = mean(v(idxOther),'omitnan');
    row.delta_108_minus_161164 = row.mean_108 - row.mean_161164;
    C = [C; row]; %#ok<AGROW>
end
end

function R = simpleR2Table(D)
targets = ["PM_noF1","PM_F1","err_F1","abs_err_F1","delta_PM","lift_ratio"];
preds = ["Tsub","Fcorr","F_form","x_eq","z_DNB_DH","z_DNB_L","L_DH","q_exp","q_calc_F1"];
R = table();
for y = targets
    for x = preds
        [r2,n,slope,intercept] = linR2(D.(x),D.(y));
        row = table();
        row.target = y;
        row.predictor = x;
        row.N = n;
        row.R2 = r2;
        row.slope = slope;
        row.intercept = intercept;
        R = [R; row]; %#ok<AGROW>
    end
end
end

function M = modelTable(D)
specs = {
    "PM_F1", ["Tsub"]
    "PM_F1", ["x_eq"]
    "PM_F1", ["F_form"]
    "PM_F1", ["z_DNB_DH"]
    "PM_F1", ["z_DNB_L"]
    "PM_F1", ["L_DH"]
    "PM_F1", ["Tsub","x_eq"]
    "PM_F1", ["Tsub","x_eq","F_form"]
    "PM_F1", ["Tsub","x_eq","z_DNB_DH"]
    "PM_F1", ["Tsub","x_eq","F_form","z_DNB_DH"]
    "PM_F1", ["Tsub","x_eq","F_form","z_DNB_L"]
    "PM_F1", ["Tsub","x_eq","F_form","L_DH"]
    "err_F1", ["Tsub","x_eq","F_form","z_DNB_DH"]
    "err_F1", ["Tsub","x_eq","F_form","z_DNB_L"]
    "err_F1", ["Tsub","x_eq","F_form","L_DH"]
};
M = table();
for i=1:size(specs,1)
    y = string(specs{i,1});
    xs = string(specs{i,2});
    [r2,n,status] = multiR2(D,y,xs);
    row = table();
    row.target = y;
    row.predictors = strjoin(xs," + ");
    row.N = n;
    row.R2 = r2;
    row.status = status;
    row.note = "exploratory_only_not_formula";
    M = [M; row]; %#ok<AGROW>
end
end

function R = residualizedTable(D)
controls = {
    "Tsub", ["Tsub"]
    "Tsub_xeq", ["Tsub","x_eq"]
    "LDH", ["L_DH"]
    "Fform", ["F_form"]
    "zDNB_DH", ["z_DNB_DH"]
};
cands = ["Tsub","x_eq","F_form","z_DNB_DH","z_DNB_L","L_DH"];
R = table();
for i=1:size(controls,1)
    label = string(controls{i,1});
    xs = string(controls{i,2});
    yres = residualize(D,"err_F1",xs);
    for x = cands
        if any(x==xs); continue; end
        [r2,n,slope,intercept] = linR2(D.(x),yres);
        row = table();
        row.target = "err_F1";
        row.control = label;
        row.candidate = x;
        row.N = n;
        row.R2 = r2;
        row.slope = slope;
        row.intercept = intercept;
        R = [R; row]; %#ok<AGROW>
    end
end
end

function C = confoundTable(D)
vars = ["Tsub","x_eq","F_form","z_DNB_DH","z_DNB_L","L_DH","q_exp","q_calc_F1"];
C = table();
for i=1:numel(vars)
    for j=i+1:numel(vars)
        [r2,n,slope,intercept] = linR2(D.(vars(i)),D.(vars(j)));
        row = table();
        row.x = vars(i);
        row.y = vars(j);
        row.N = n;
        row.R2 = r2;
        row.slope = slope;
        row.intercept = intercept;
        C = [C; row]; %#ok<AGROW>
    end
end
end

function yres = residualize(D,yname,xnames)
y = D.(yname);
X = [];
ok = isfinite(y);
for x = xnames
    v = D.(x);
    X = [X,v]; %#ok<AGROW>
    ok = ok & isfinite(v);
end
yres = NaN(size(y));
if sum(ok) < size(X,2)+2; return; end
Xok = [ones(sum(ok),1), X(ok,:)];
beta = Xok \ y(ok);
yres(ok) = y(ok) - Xok*beta;
end

function [r2,n,status] = multiR2(D,yname,xnames)
y = D.(yname);
X = [];
ok = isfinite(y);
for x = xnames
    v = D.(x);
    X = [X,v]; %#ok<AGROW>
    ok = ok & isfinite(v);
end
n = sum(ok);
p = size(X,2);
if n < p+2
    r2 = NaN; status = "too_few_rows"; return;
end
if rank(X(ok,:)) < p
    status = "rank_deficient";
else
    status = "OK";
end
Xok = [ones(n,1), X(ok,:)];
beta = Xok \ y(ok);
yhat = Xok*beta;
ssr = sum((y(ok)-yhat).^2);
sst = sum((y(ok)-mean(y(ok))).^2);
r2 = 1 - ssr/sst;
end

function [r2,n,slope,intercept] = linR2(x,y)
x = double(x); y = double(y);
ok = isfinite(x) & isfinite(y);
n = sum(ok);
if n < 3 || numel(unique(x(ok))) < 2
    r2=NaN; slope=NaN; intercept=NaN; return;
end
X = [ones(n,1), x(ok)];
beta = X \ y(ok);
yhat = X*beta;
ssr = sum((y(ok)-yhat).^2);
sst = sum((y(ok)-mean(y(ok))).^2);
r2 = 1 - ssr/sst;
intercept = beta(1);
slope = beta(2);
end

function s = ok(tf)
if tf, s="OK"; else, s="CHECK"; end
end

function v = firstNum(T,cands)
v = NaN(height(T),1);
for c = cands
    tmp = numCol(T,c);
    if any(isfinite(tmp)); v=tmp; return; end
end
end

function v = numCol(T,cands)
name = findCol(T,cands);
if strlength(name)==0
    v = NaN(height(T),1); return;
end
raw = T.(char(name));
if isnumeric(raw)
    v = double(raw);
else
    v = str2double(string(raw));
end
end

function name = findCol(T,cands)
vars = string(T.Properties.VariableNames);
for c = string(cands)
    idx = find(vars==c,1);
    if ~isempty(idx); name=vars(idx); return; end
end
nv = normName(vars);
for c = string(cands)
    idx = find(nv==normName(c),1);
    if ~isempty(idx); name=vars(idx); return; end
end
name = "";
end

function n = normName(s)
n = lower(string(s));
n = regexprep(n,"[^a-z0-9]","");
end

function md = tableToMarkdown(T)
if height(T)==0; md="_empty_"; return; end
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
