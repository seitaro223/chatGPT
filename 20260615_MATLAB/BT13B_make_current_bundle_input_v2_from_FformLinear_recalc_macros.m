%% BT13B_make_current_bundle_input_v2_from_FformLinear_recalc_macros.m
% BT13-B：FformLinear_v1再計算済みマクロブックからcurrent_bundle_input_v2を作り直す
%
% 背景：
%   BT13で、BT12-C tmCompatible v2は
%     F_form列 = FformLinear_v1
%     q_calc / PM列 = legacy計算値
%   という不整合を持つことが分かった。
%
% 目的：
%   FformLinear_v1でマクロ再計算済みのr125/r126ブックから、
%   tm互換列構成のcurrent_bundle_input_v2を再作成する。
%
% 出力：
%   H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_yyyymmdd_HHMMSS.xlsx
%   run_report_BT13B_current_bundle_input_v2_FformLinearRecalc_yyyymmdd_HHMMSS.md
%
% 注意：
%   - BT12-A/B/Cのv2は入力として使わない。
%   - template v1は列構成の参照にだけ使う。
%   - tmシートには追加列を入れない。
%   - README_BT13Bとrun_reportに管理情報を逃がす。
%   - 補正式は作らない。

clear; clc;

templateFile = "H52Q_current_bundle_input_v1_20260615_180822.xlsx";
noF1File = "";
F1File = "";

if ~isfile(templateFile)
    templateFile = latest("H52Q_current_bundle_input_v1_*.xlsx");
end
if strlength(noF1File)==0
    noF1File = latest("*r125*FformLinear_v1*.xlsm");
end
if strlength(F1File)==0
    F1File = latest("*r126*FformLinear_v1*.xlsm");
end

ts = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_" + ts + ".xlsx";
outMd   = "run_report_BT13B_current_bundle_input_v2_FformLinearRecalc_" + ts + ".md";

targetSheets = ["tm_108";"tm_161";"tm_164";"tm_F1_108";"tm_F1_161";"tm_F1_164"];

fprintf("template: %s\n", templateFile);
fprintf("noF1    : %s\n", noF1File);
fprintf("F1      : %s\n", F1File);
fprintf("out     : %s\n", outXlsx);

shNoF1 = findTmSheet(noF1File);
shF1   = findTmSheet(F1File);
srcNoF1 = readtable(noF1File, 'Sheet', shNoF1, 'VariableNamingRule','preserve');
srcF1   = readtable(F1File,   'Sheet', shF1,   'VariableNamingRule','preserve');

if exist(outXlsx,"file"); delete(outXlsx); end

sheetSummary = table();
bundleRows = table();

for s = targetSheets'
    Ttpl = readtable(templateFile, 'Sheet', s, 'VariableNamingRule','preserve');
    if contains(lower(s), "f1")
        Tsrc = srcF1;
        kind = "F1";
    else
        Tsrc = srcNoF1;
        kind = "noF1";
    end

    Tout = alignToTemplateByNo(Ttpl, Tsrc, s);
    writetable(Tout, outXlsx, 'Sheet', s);

    sheetSummary = [sheetSummary; summarizeSheet(Ttpl, Tout, s, kind)]; %#ok<AGROW>
    bundleRows = [bundleRows; rowsForBundleSummary(Tout, s, kind)]; %#ok<AGROW>
end

bundleSummary = summarizeBundles(bundleRows);
qc = makeQC(sheetSummary, bundleSummary, templateFile, noF1File, F1File, outXlsx);

readme = table();
readme.key = ["created_at";"task";"template_v1";"noF1_macro";"F1_macro";"noF1_sheet";"F1_sheet";"output";"policy";"note"];
readme.value = [string(datetime("now")); "BT13-B"; templateFile; noF1File; F1File; shNoF1; shF1; outXlsx; "tm columns/order same as v1, values from recalculated macros"; "BT12-A/B/C v2 not used as input"];
writetable(readme, outXlsx, 'Sheet', 'README_BT13B');

md = strings(0,1);
md(end+1) = "# BT13-B current_bundle_input v2 from FformLinear_v1 recalculated macros";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "BT13で見つかった、F_form列とq_calc/PM列の不整合を解消するため、FformLinear_v1再計算済みr125/r126マクロからcurrent_bundle_input_v2を作り直す。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "- template v1: `" + templateFile + "`";
md(end+1) = "- noF1 recalc macro: `" + noF1File + "`";
md(end+1) = "- F1 recalc macro: `" + F1File + "`";
md(end+1) = "- noF1 source sheet: `" + shNoF1 + "`";
md(end+1) = "- F1 source sheet: `" + shF1 + "`";
md(end+1) = "";
md(end+1) = "## 3. 出力";
md(end+1) = "- output v2: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 4. 方針";
md(end+1) = "```text";
md(end+1) = "- BT12-A/B/Cのv2は入力として使わない。";
md(end+1) = "- FformLinear_v1再計算済みマクロからtmシートを取り直す。";
md(end+1) = "- template v1と同じ列数・列名・列順を維持する。";
md(end+1) = "- 追加管理列はtmに入れない。";
md(end+1) = "- 補正式は作らない。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 5. QC";
md(end+1) = tableToMarkdown(qc);
md(end+1) = "";
md(end+1) = "## 6. Sheet summary";
md(end+1) = tableToMarkdown(sheetSummary);
md(end+1) = "";
md(end+1) = "## 7. Bundle summary";
md(end+1) = tableToMarkdown(bundleSummary);
md(end+1) = "";
md(end+1) = "## 8. 判断メモ";
md(end+1) = "```text";
md(end+1) = "このrun_reportを確認してから判断する。";
md(end+1) = "見るべきポイント：";
md(end+1) = "  1. 6シートすべてがtemplate v1と同じ列構成か。";
md(end+1) = "  2. PM_noF1/PM_F1がBT10-C linear側の値へ更新されているか。";
md(end+1) = "  3. BT13で見つかったF_form列とPM列の不整合が解消したか。";
md(end+1) = "  4. この新v2を今後のバンドル解析入力として採用できるか。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 9. 次アクション";
md(end+1) = "```text";
md(end+1) = "BT13-B結果を確認する。";
md(end+1) = "問題なければworking_logへ追記する。";
md(end+1) = "その後、この新v2でBT13相当の残差診断を再実行する。";
md(end+1) = "```";

fid = fopen(outMd,"w");
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

disp(qc);
disp(bundleSummary);
fprintf("Wrote %s\n", outXlsx);
fprintf("Wrote %s\n", outMd);

%% ===== functions =====

function f = latest(pattern)
d = dir(pattern);
if isempty(d); error("No file: %s", pattern); end
[~,i] = max([d.datenum]);
f = string(d(i).name);
end

function sh = findTmSheet(file)
sheets = string(sheetnames(file));
if any(sheets=="tm"); sh="tm"; return; end
best = ""; bestScore = -inf;
for s = sheets'
    try
        T = readtable(file,'Sheet',s,'VariableNamingRule','preserve');
        v = normNames(string(T.Properties.VariableNames));
        score = 0;
        if any(v=="no"), score=score+10; end
        if any(v=="pmratio") || any(v=="pm"), score=score+5; end
        if width(T)>=60, score=score+3; end
        if height(T)>=50, score=score+3; end
        if score > bestScore
            bestScore = score; best = s;
        end
    catch
    end
end
if bestScore < 10; error("tm-like sheet not found in %s", file); end
sh = best;
end

function Tout = alignToTemplateByNo(Ttpl,Tsrc,sheetName)
tplVars = string(Ttpl.Properties.VariableNames);
srcVars = string(Tsrc.Properties.VariableNames);
tplNo = numCol(Ttpl,["No","NO","no"]);
srcNo = numCol(Tsrc,["No","NO","no"]);

if all(~isfinite(tplNo)); error("No missing in template %s", sheetName); end
if all(~isfinite(srcNo)); error("No missing in source for %s", sheetName); end

row = NaN(height(Ttpl),1);
for i=1:height(Ttpl)
    j = find(srcNo == tplNo(i),1);
    if isempty(j)
        error("No %g missing in source for %s", tplNo(i), sheetName);
    end
    row(i)=j;
end

Tout = Ttpl;
for k=1:numel(tplVars)
    srcName = matchCol(srcVars,tplVars(k));
    if strlength(srcName)==0
        error("Column %s missing in source for %s", tplVars(k), sheetName);
    end
    Tout.(char(tplVars(k))) = Tsrc.(char(srcName))(row,:);
end
end

function S = summarizeSheet(Ttpl,Tout,sheetName,kind)
S = table();
S.sheet = string(sheetName);
S.source_kind = string(kind);
S.N_rows = height(Tout);
S.N_cols_template = width(Ttpl);
S.N_cols_output = width(Tout);
S.N_cols_delta = width(Tout)-width(Ttpl);
S.column_structure_same = width(Ttpl)==width(Tout) && all(string(Ttpl.Properties.VariableNames)==string(Tout.Properties.VariableNames));
S.No_min = min(numCol(Tout,["No"]),[],'omitnan');
S.No_max = max(numCol(Tout,["No"]),[],'omitnan');
S.PM_mean = mean(firstNum(Tout,["PM_ratio","PM","P_M","PoverM"]), 'omitnan');
S.F_form_mean = mean(firstNum(Tout,["F_form","Fform","F_FORM"]), 'omitnan');
S.qP_mean = mean(firstNum(Tout,["q_P","qP","q_calc","q_Cal"]), 'omitnan');
S.qM_mean = mean(firstNum(Tout,["q_M","qM","q_exp","q_Mes"]), 'omitnan');
end

function R = rowsForBundleSummary(T,sheetName,kind)
R = table();
R.Bundle = repmat(bundleOf(sheetName),height(T),1);
R.source_kind = repmat(string(kind),height(T),1);
R.No = numCol(T,["No"]);
R.PM = firstNum(T,["PM_ratio","PM","P_M","PoverM"]);
R.F_form = firstNum(T,["F_form","Fform","F_FORM"]);
R.qP = firstNum(T,["q_P","qP","q_calc","q_Cal"]);
R.qM = firstNum(T,["q_M","qM","q_exp","q_Mes"]);
R.Tsub = firstNum(T,["Tsub","T_sub","DeltaTsub"]);
R.x_eq = firstNum(T,["x_Mes","xMes","x_eq","xeq"]);
end

function S = summarizeBundles(R)
S = table();
for b = unique(R.Bundle,'stable')'
    for k = unique(R.source_kind,'stable')'
        idx = R.Bundle==b & R.source_kind==k;
        if ~any(idx); continue; end
        row = table();
        row.Bundle = b;
        row.source_kind = k;
        row.N = sum(idx);
        row.PM_mean = mean(R.PM(idx),'omitnan');
        row.PM_sd = std(R.PM(idx),'omitnan');
        row.F_form_mean = mean(R.F_form(idx),'omitnan');
        row.qP_mean = mean(R.qP(idx),'omitnan');
        row.qM_mean = mean(R.qM(idx),'omitnan');
        row.Tsub_mean = mean(R.Tsub(idx),'omitnan');
        row.x_eq_mean = mean(R.x_eq(idx),'omitnan');
        row.expected_PM_BT10C_linear = expectedPM(b,k);
        row.delta_PM_vs_expected = row.PM_mean - row.expected_PM_BT10C_linear;
        S = [S; row]; %#ok<AGROW>
    end
end
end

function e = expectedPM(bundle,kind)
if kind=="noF1"
    if bundle==108, e=0.65304894;
    elseif bundle==161, e=0.62098048;
    elseif bundle==164, e=0.59786191;
    else, e=NaN; end
else
    if bundle==108, e=1.1232232;
    elseif bundle==161, e=0.90884087;
    elseif bundle==164, e=0.93956052;
    else, e=NaN; end
end
end

function Q = makeQC(sheetSummary,bundleSummary,templateFile,noF1File,F1File,outXlsx)
item = strings(0,1); status = strings(0,1); value = strings(0,1); reading = strings(0,1);
add("template_v1","info",templateFile,"列構成テンプレート");
add("macro_noF1","info",noF1File,"FformLinear_v1再計算済みnoF1");
add("macro_F1","info",F1File,"FformLinear_v1再計算済みF1");
add("output_v2","info",outXlsx,"新current_bundle_input候補");

totalRows = sum(sheetSummary.N_rows);
sameCols = sum(sheetSummary.column_structure_same);
maxPMdelta = max(abs(bundleSummary.delta_PM_vs_expected),[],'omitnan');

add("target_rows",ok(totalRows==116),sprintf("%d",totalRows),"6シート合計116行が期待値");
add("sheet_count",ok(height(sheetSummary)==6),sprintf("%d",height(sheetSummary)),"対象6シート");
add("tm_column_structure_same",ok(sameCols==6),sprintf("%d/6",sameCols),"template v1と列構成が同じ");
add("PM_mean_vs_BT10C_linear",ok(maxPMdelta<1e-5),sprintf("max_abs_delta=%.8g",maxPMdelta),"PM平均がBT10-C linear側と一致するか");
add("BT13_inconsistency_status","target","resolve_Fform_PM_mismatch","BT13で見つかった不整合を解消する");
add("formula_policy","OK","no_new_formula","補正式は作らない");

Q = table(item,status,value,reading);
    function add(a,b,c,d)
        item(end+1,1)=string(a); status(end+1,1)=string(b);
        value(end+1,1)=string(c); reading(end+1,1)=string(d);
    end
end

function s = ok(tf)
if tf, s="OK"; else, s="CHECK"; end
end

function b = bundleOf(sheetName)
s = string(sheetName);
if contains(s,"108"), b=108;
elseif contains(s,"161"), b=161;
elseif contains(s,"164"), b=164;
else, b=NaN; end
end

function out = matchCol(vars,name)
idx = find(vars==name,1);
if ~isempty(idx); out=vars(idx); return; end
nv = normNames(vars);
nn = normNames(name);
idx = find(nv==nn,1);
if ~isempty(idx); out=vars(idx); else, out=""; end
end

function v = firstNum(T,cands)
v = NaN(height(T),1);
for c = string(cands)
    tmp = numCol(T,c);
    if any(isfinite(tmp)); v = tmp; return; end
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
nv = normNames(vars);
for c = string(cands)
    idx = find(nv==normNames(c),1);
    if ~isempty(idx); name=vars(idx); return; end
end
name = "";
end

function n = normNames(s)
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
    end
    lines(end+1) = "| " + strjoin(row," | ") + " |";
end
md = strjoin(lines,newline);
end

function s = val2str(x)
if isnumeric(x)
    if isempty(x) || (isscalar(x) && isnan(x)), s="";
    elseif isscalar(x), s=string(sprintf("%.8g",x));
    else, s=strjoin(string(x(:)'),","); end
elseif isstring(x)
    s=strjoin(x(:)',",");
elseif iscell(x)
    s=strjoin(string(x),",");
elseif islogical(x)
    s=string(x);
else
    try s=string(x); catch, s=""; end
end
end
