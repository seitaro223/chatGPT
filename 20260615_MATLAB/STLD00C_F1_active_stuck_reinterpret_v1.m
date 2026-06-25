%% STLD00C_F1_active_stuck_reinterpret_v1.m
% ST-LD-00C: F1 active/stuck領域でST-LD-00を再解釈する
%
% 目的:
%   ST-F1-00で確認した F1_fixed の効き幅を使い、
%   Table9-12のPM_F1残差を F1 active / weak / stuck に分けて見る。
%   補正式は作らない。ST-LD-01へ進む前の再解釈ゲート。
%
% 入力:
%   H52Q_current_single_tube_input_v1_20260615_183839.xlsx
%
% 出力:
%   STLD00C_F1_active_stuck_reinterpret_v1_yyyymmdd_HHMMSS.xlsx
%   run_report_STLD00C_F1_active_stuck_reinterpret_v1_yyyymmdd_HHMMSS.md
%
% F1_fixed:
%   F1 = 1 + 0.053 * exp(-(Tsub-40)^2/5625)

clear; clc;

%% settings
inFile = "H52Q_current_single_tube_input_v1_20260615_183839.xlsx";
A = 0.053;
T0 = 40;
sigma = 5625;

thr_active = 0.010;  % F1-1 >= 1%
thr_stuck  = 0.001;  % F1-1 <= 0.1%

if ~isfile(inFile)
    [f,p] = uigetfile("*.xlsx", "Select H52Q_current_single_tube_input workbook");
    if isequal(f,0); error("Input file not selected."); end
    inFile = fullfile(p,f);
end

ts = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "STLD00C_F1_active_stuck_reinterpret_v1_" + ts + ".xlsx";
outMd   = "run_report_STLD00C_F1_active_stuck_reinterpret_v1_" + ts + ".md";

fig1 = "fig_STLD00C_v1_01_PM_F1_vs_Tsub_regime_" + ts + ".png";
fig2 = "fig_STLD00C_v1_02_PM_F1_vs_LD_regime_" + ts + ".png";
fig3 = "fig_STLD00C_v1_03_error_by_table_regime_" + ts + ".png";
fig4 = "fig_STLD00C_v1_04_within_Tsub_by_regime_" + ts + ".png";

%% read
sheets = sheetnames(inFile);
shNo = pickSheet(sheets, "nof1");
shF1 = pickSheet(sheets, "f1");

fprintf("NoF1 sheet: %s\n", shNo);
fprintf("F1 sheet  : %s\n", shF1);

Tno = readtable(inFile, "Sheet", shNo, "VariableNamingRule","preserve");
Tf1 = readtable(inFile, "Sheet", shF1, "VariableNamingRule","preserve");

Cno = cleanST(Tno, "noF1");
Cf1 = cleanST(Tf1, "F1");

% Pair by original row order. current sheets are copied from same source.
C = table;
C.row_id   = Cno.row_id;
C.TableNo  = Cno.TableNo;
C.Tsub     = Cf1.Tsub;
C.LD       = Cf1.LD;
C.LD_group = Cf1.LD_group;
C.PM_noF1  = Cno.PM;
C.PM_F1    = Cf1.PM;
C.Fcorr_book = Cf1.Fcorr;

valid = isfinite(C.TableNo) & isfinite(C.Tsub) & isfinite(C.LD) & ...
        isfinite(C.PM_noF1) & isfinite(C.PM_F1) & C.LD_group ~= "";
C = C(valid,:);

%% F1 fixed and regimes
C.F1_fixed = 1 + A .* exp(-((C.Tsub - T0).^2)./sigma);
C.F1_minus_1 = C.F1_fixed - 1;
C.F1_pct = 100*C.F1_minus_1;

C.F1_regime = strings(height(C),1);
C.F1_regime(C.F1_minus_1 >= thr_active) = "active_ge_1pct";
C.F1_regime(C.F1_minus_1 > thr_stuck & C.F1_minus_1 < thr_active) = "weak_0p1_to_1pct";
C.F1_regime(C.F1_minus_1 <= thr_stuck) = "stuck_le_0p1pct";

C.err_noF1 = C.PM_noF1 - 1;
C.err_F1 = C.PM_F1 - 1;
C.abs_err_noF1 = abs(C.err_noF1);
C.abs_err_F1 = abs(C.err_F1);
C.delta_abs_err = C.abs_err_F1 - C.abs_err_noF1;
C.improved = C.delta_abs_err < -1e-12;
C.worsened = C.delta_abs_err >  1e-12;
C.before_under = C.PM_noF1 < 1;
C.before_over = C.PM_noF1 > 1;
C.PM_delta = C.PM_F1 - C.PM_noF1;
C.PM_lift_ratio = C.PM_F1 ./ C.PM_noF1;

primary = C(ismember(C.TableNo,[9 10 11 12]),:);
refall  = C(ismember(C.TableNo,8:14),:);

%% summaries
overall_primary = analyzeSubset(primary, "primary_T9_12_all");
overall_ref     = analyzeSubset(refall,  "reference_T8_14_all");

by_table = groupSummary(primary, "Table", "T"+string(primary.TableNo));
by_regime = groupSummary(primary, "F1_regime", primary.F1_regime);
by_table_regime = groupSummary(primary, "Table_F1_regime", "T"+string(primary.TableNo)+"_"+primary.F1_regime);
by_ld_regime = groupSummary(primary, "LDgroup_F1_regime", primary.LD_group+"_"+primary.F1_regime);
by_table_ld_regime = groupSummary(primary, "Table_LDgroup_F1regime", "T"+string(primary.TableNo)+"_"+primary.LD_group+"_"+primary.F1_regime);

model_primary = modelCompare(primary, "primary_T9_12_all");
within_primary = withinDecomp(primary, "primary_T9_12_all");

within_by_regime = table;
regs = unique(primary.F1_regime,"stable");
for i=1:numel(regs)
    D = primary(primary.F1_regime==regs(i),:);
    if height(D) >= 5
        within_by_regime = [within_by_regime; withinDecomp(D, "regime_"+regs(i))]; %#ok<AGROW>
    end
end

within_by_table = table;
tabs = unique(primary.TableNo)';
for t=tabs
    D = primary(primary.TableNo==t,:);
    if height(D) >= 5
        within_by_table = [within_by_table; withinDecomp(D, "T"+string(t))]; %#ok<AGROW>
    end
end

model_by_regime = table;
for i=1:numel(regs)
    D = primary(primary.F1_regime==regs(i),:);
    if height(D) >= 5
        model_by_regime = [model_by_regime; modelCompare(D, "regime_"+regs(i))]; %#ok<AGROW>
    end
end

%% write xlsx
writetable(C, outXlsx, "Sheet","paired_all_rows");
writetable(primary, outXlsx, "Sheet","primary_Table9_12");
writetable(refall, outXlsx, "Sheet","reference_Table8_14");

writetable(overall_primary, outXlsx, "Sheet","primary_summary");
writetable(overall_ref, outXlsx, "Sheet","reference_summary");
writetable(by_table, outXlsx, "Sheet","by_table");
writetable(by_regime, outXlsx, "Sheet","by_F1_regime");
writetable(by_table_regime, outXlsx, "Sheet","by_table_regime");
writetable(by_ld_regime, outXlsx, "Sheet","by_LD_regime");
writetable(by_table_ld_regime, outXlsx, "Sheet","by_table_LD_regime");
writetable(model_primary, outXlsx, "Sheet","models_primary");
writetable(model_by_regime, outXlsx, "Sheet","models_by_regime");
writetable(within_primary, outXlsx, "Sheet","within_primary");
writetable(within_by_regime, outXlsx, "Sheet","within_by_regime");
writetable(within_by_table, outXlsx, "Sheet","within_by_table");

metadata = table;
metadata.item = ["input_file";"noF1_sheet";"F1_sheet";"A";"T0";"sigma";"active_threshold_F1minus1";"stuck_threshold_F1minus1"];
metadata.value = [string(inFile);string(shNo);string(shF1);string(A);string(T0);string(sigma);string(thr_active);string(thr_stuck)];
writetable(metadata, outXlsx, "Sheet","metadata");

%% figures
makeFigures(primary, by_table_regime, within_by_regime, model_by_regime, fig1, fig2, fig3, fig4);

%% markdown
writeReport(outMd, inFile, shNo, shF1, A, T0, sigma, thr_active, thr_stuck, ...
    overall_primary, overall_ref, by_table, by_regime, by_table_regime, by_ld_regime, by_table_ld_regime, ...
    model_primary, model_by_regime, within_primary, within_by_regime, within_by_table, ...
    fig1, fig2, fig3, fig4);

fprintf("\nDONE\n");
fprintf("Output xlsx: %s\n", outXlsx);
fprintf("Report md  : %s\n", outMd);
fprintf("Figures    : %s, %s, %s, %s\n", fig1, fig2, fig3, fig4);

%% local functions

function sh = pickSheet(sheets, mode)
    low = lower(string(sheets));
    if mode == "nof1"
        idx = find(strcmpi(sheets,"ST_noF1_T8_14_current"),1);
        if isempty(idx); idx = find(contains(low,"nof1") | contains(low,"no_f1"),1); end
    else
        idx = find(strcmpi(sheets,"ST_F1_T8_14_current"),1);
        if isempty(idx); idx = find(contains(low,"f1") & ~contains(low,"nof1") & ~contains(low,"no_f1"),1); end
    end
    if isempty(idx)
        disp(sheets);
        error("Cannot find %s sheet.", mode);
    end
    sh = string(sheets(idx));
end

function C = cleanST(T, label)
    vars = string(T.Properties.VariableNames);
    nvars = lower(regexprep(vars,"[\s_\-/\(\)\[\]\.]",""));

    colTable = pickCol(vars,nvars,["No_TableNo","TableNo","Table","TNo"]);
    colPM    = pickCol(vars,nvars,["PM_ratio","PM","PM_F1","PM_noF1"]);
    colTsub  = pickCol(vars,nvars,["Tsub","T_sub","Tsub_K"]);
    colLD    = pickCol(vars,nvars,["L_DNB","L/D","LD","L_D"]);
    colGroup = pickColOpt(vars,nvars,["LD_group","LDgroup","LDBand","band","group"]);
    colFcorr = pickColOpt(vars,nvars,["Fcorr","F_corr","補正式F","FCorrection"]);

    if colTable=="" || colPM=="" || colTsub=="" || colLD==""
        disp(vars');
        error("Missing required column in %s sheet.", label);
    end

    C = table;
    C.row_id = (1:height(T))';
    C.TableNo = parseTableNo(T.(colTable));
    C.PM = toNum(T.(colPM));
    C.Tsub = toNum(T.(colTsub));
    C.LD = toNum(T.(colLD));

    if colGroup ~= ""
        C.LD_group = normGroup(string(T.(colGroup)));
    else
        C.LD_group = makeLDGroups(C.LD);
    end

    if colFcorr ~= ""
        C.Fcorr = toNum(T.(colFcorr));
    else
        C.Fcorr = nan(height(T),1);
    end
end

function col = pickCol(vars,nvars,cands)
    col = pickColOpt(vars,nvars,cands);
end

function col = pickColOpt(vars,nvars,cands)
    col = "";
    cands = string(cands);
    nc = lower(regexprep(cands,"[\s_\-/\(\)\[\]\.]",""));
    for c=nc
        idx=find(nvars==c,1);
        if ~isempty(idx); col=vars(idx); return; end
    end
    for c=nc
        idx=find(contains(nvars,c),1);
        if ~isempty(idx); col=vars(idx); return; end
    end
end

function x = toNum(v)
    if isnumeric(v)
        x = double(v);
    else
        x = str2double(replace(string(v),",",""));
    end
end

function out = parseTableNo(v)
    if isnumeric(v)
        raw = double(v(:));
        out = nan(size(raw));
        hit = ismember(round(raw),8:14);
        out(hit) = round(raw(hit));
        miss = isnan(out);
        if any(miss); out(miss) = parseTableNoString(string(raw(miss))); end
    else
        out = parseTableNoString(string(v));
    end
end

function out = parseTableNoString(s)
    out = nan(numel(s),1);
    for i=1:numel(s)
        nums = regexp(s(i),"[0-9]+","match");
        vals = str2double(nums);
        hit = vals(ismember(vals,8:14));
        if ~isempty(hit); out(i)=hit(1); end
    end
end

function g = normGroup(s)
    ss = lower(strtrim(s));
    g = strings(size(ss));
    g(contains(ss,"short") | ss=="s") = "short";
    g(contains(ss,"middle") | contains(ss,"mid") | ss=="m") = "middle";
    g(contains(ss,"long") | ss=="l") = "long";
end

function g = makeLDGroups(LD)
    g = strings(size(LD));
    x = LD(:);
    ok = isfinite(x);
    ux = unique(round(x(ok),3));
    if numel(ux)==1
        g(ok)="single"; return;
    end
    if numel(ux)<=6
        sx=sort(ux);
        for i=1:numel(sx)
            if i==1; lab="short"; elseif i==numel(sx); lab="long"; else; lab="middle"; end
            g(abs(round(x,3)-sx(i))<1e-9)=lab;
        end
    else
        q1=quantile(x(ok),1/3); q2=quantile(x(ok),2/3);
        g(ok & x<=q1)="short";
        g(ok & x>q1 & x<=q2)="middle";
        g(ok & x>q2)="long";
    end
end

function S = analyzeSubset(D, label)
    S = summarizeOne(D);
    S.dataset = string(label);
    S = movevars(S,"dataset","Before",1);

    [r2t, st, ~] = linR2(D.Tsub,D.PM_F1);
    [r2l, sl, ~] = linR2(D.LD,D.PM_F1);
    [r2f, sf, ~] = linR2(D.F1_minus_1,D.PM_F1);

    S.R2_PM_Tsub = r2t;
    S.slope_PM_per_100K = st*100;
    S.R2_PM_LD = r2l;
    S.slope_PM_per_LD = sl;
    S.R2_PM_F1minus1 = r2f;
    S.slope_PM_per_F1minus1 = sf;
end

function S = groupSummary(D, groupType, groupLabels)
    labels = string(groupLabels);
    groups = unique(labels,"stable");
    S = table;
    for i=1:numel(groups)
        idx = labels==groups(i);
        row = summarizeOne(D(idx,:));
        row.group_type = string(groupType);
        row.group = groups(i);
        S = [S; row]; %#ok<AGROW>
    end
    S = movevars(S,["group_type","group"],"Before",1);
end

function row = summarizeOne(D)
    n = height(D);
    row = table;
    row.N = n;
    row.PM_noF1_mean = mean(D.PM_noF1,"omitnan");
    row.PM_F1_mean = mean(D.PM_F1,"omitnan");
    row.abs_err_noF1_mean = mean(D.abs_err_noF1,"omitnan");
    row.abs_err_F1_mean = mean(D.abs_err_F1,"omitnan");
    row.delta_abs_err_mean = mean(D.delta_abs_err,"omitnan");
    row.improved_N = sum(D.improved);
    row.worsened_N = sum(D.worsened);
    row.improved_frac = row.improved_N/max(n,1);
    row.worsened_frac = row.worsened_N/max(n,1);
    row.before_under_N = sum(D.before_under);
    row.before_over_N = sum(D.before_over);
    row.before_under_improved_N = sum(D.before_under & D.improved);
    row.before_under_worsened_N = sum(D.before_under & D.worsened);
    row.before_over_improved_N = sum(D.before_over & D.improved);
    row.before_over_worsened_N = sum(D.before_over & D.worsened);
    row.F1_fixed_mean = mean(D.F1_fixed,"omitnan");
    row.F1_minus_1_mean = mean(D.F1_minus_1,"omitnan");
    row.F1_minus_1_min = min(D.F1_minus_1,[],"omitnan");
    row.F1_minus_1_max = max(D.F1_minus_1,[],"omitnan");
    row.Tsub_mean = mean(D.Tsub,"omitnan");
    row.Tsub_min = min(D.Tsub,[],"omitnan");
    row.Tsub_max = max(D.Tsub,[],"omitnan");
    row.LD_mean = mean(D.LD,"omitnan");
    row.LD_min = min(D.LD,[],"omitnan");
    row.LD_max = max(D.LD,[],"omitnan");
end

function M = modelCompare(D,label)
    y = D.PM_F1;
    M = table;
    M = addModel(M,label,"PM_F1 ~ Tsub",y,[ones(height(D),1),D.Tsub]);
    M = addModel(M,label,"PM_F1 ~ L/D",y,[ones(height(D),1),D.LD]);
    M = addModel(M,label,"PM_F1 ~ F1_minus_1",y,[ones(height(D),1),D.F1_minus_1]);
    M = addModel(M,label,"PM_F1 ~ LD_group",y,designGroup(D.LD_group));
    M = addModel(M,label,"PM_F1 ~ LD_group + Tsub",y,[designGroup(D.LD_group),D.Tsub]);
    M = addModel(M,label,"PM_F1 ~ LD_group + F1_minus_1",y,[designGroup(D.LD_group),D.F1_minus_1]);
end

function M = addModel(M,label,name,y,X)
    [r2,rmse,k] = olsR2(y,X);
    row = table(string(label),string(name),numel(y),k,r2,rmse, ...
        'VariableNames',{'dataset','model','N','k','R2','RMSE'});
    M = [M; row];
end

function W = withinDecomp(D,label)
    W = table;
    W.dataset = string(label);
    W.N = height(D);

    if height(D)<5 || numel(unique(D.LD_group))<2
        W.R2_within_PM_Tsub = NaN;
        W.slope_within_PM_per_100K = NaN;
        W.R2_group_only = NaN;
        W.R2_group_plus_TsubWithin = NaN;
        W.delta_R2_TsubWithin_afterGroup = NaN;
        W.reading = "insufficient";
        return;
    end

    groups=unique(D.LD_group,"stable");
    pmw=nan(height(D),1); tsw=nan(height(D),1);
    for i=1:numel(groups)
        idx=D.LD_group==groups(i);
        pmw(idx)=D.PM_F1(idx)-mean(D.PM_F1(idx),"omitnan");
        tsw(idx)=D.Tsub(idx)-mean(D.Tsub(idx),"omitnan");
    end

    [r2w,slopew,~]=linR2(tsw,pmw);
    Xg=designGroup(D.LD_group);
    [r2g,~,~]=olsR2(D.PM_F1,Xg);
    [r2gt,~,~]=olsR2(D.PM_F1,[Xg,tsw]);

    W.R2_within_PM_Tsub = r2w;
    W.slope_within_PM_per_100K = slopew*100;
    W.R2_group_only = r2g;
    W.R2_group_plus_TsubWithin = r2gt;
    W.delta_R2_TsubWithin_afterGroup = r2gt-r2g;

    if W.delta_R2_TsubWithin_afterGroup <= 0.05 && abs(W.slope_within_PM_per_100K)<=0.10
        W.reading = "within_Tsub_small";
    elseif W.delta_R2_TsubWithin_afterGroup >= 0.10 || abs(W.slope_within_PM_per_100K)>=0.20
        W.reading = "within_Tsub_remaining";
    else
        W.reading = "borderline";
    end
end

function X=designGroup(g)
    groups=unique(g,"stable");
    X=ones(numel(g),1);
    for i=2:numel(groups)
        X=[X,double(g==groups(i))]; %#ok<AGROW>
    end
end

function [r2,slope,intc]=linR2(x,y)
    ok=isfinite(x)&isfinite(y);
    x=x(ok); y=y(ok);
    if numel(x)<3 || numel(unique(x))<2
        r2=NaN; slope=NaN; intc=NaN; return;
    end
    X=[ones(numel(x),1),x(:)];
    if rank(X)<size(X,2)
        r2=NaN; slope=NaN; intc=NaN; return;
    end
    b=X\y(:);
    yh=X*b;
    ssr=sum((y(:)-yh).^2);
    sst=sum((y(:)-mean(y(:))).^2);
    r2=1-ssr/sst;
    intc=b(1); slope=b(2);
end

function [r2,rmse,k]=olsR2(y,X)
    ok=all(isfinite(X),2)&isfinite(y);
    y=y(ok); X=X(ok,:);
    k=rank(X);
    if numel(y)<k+1 || rank(X)<size(X,2)
        r2=NaN; rmse=NaN; return;
    end
    b=X\y;
    yh=X*b;
    ssr=sum((y-yh).^2);
    sst=sum((y-mean(y)).^2);
    r2=1-ssr/sst;
    rmse=sqrt(mean((y-yh).^2));
end

function makeFigures(D, statsTableRegime, withinByRegime, modelByRegime, fig1, fig2, fig3, fig4)
    regs=unique(D.F1_regime,"stable");

    f=figure("Color","w"); hold on; grid on; box on;
    for i=1:numel(regs)
        idx=D.F1_regime==regs(i);
        scatter(D.Tsub(idx),D.PM_F1(idx),30,"filled","DisplayName",regs(i));
    end
    yline(1,"--","PM=1","HandleVisibility","off");
    xlabel("Tsub [K]"); ylabel("PM_F1 [-]");
    title("ST-LD-00C: PM_F1 vs Tsub by F1 regime");
    legend("Location","best"); saveas(f,fig1); close(f);

    f=figure("Color","w"); hold on; grid on; box on;
    for i=1:numel(regs)
        idx=D.F1_regime==regs(i);
        scatter(D.LD(idx),D.PM_F1(idx),30,"filled","DisplayName",regs(i));
    end
    yline(1,"--","PM=1","HandleVisibility","off");
    xlabel("L/D or L_DNB [-]"); ylabel("PM_F1 [-]");
    title("ST-LD-00C: PM_F1 vs L/D by F1 regime");
    legend("Location","best"); saveas(f,fig2); close(f);

    f=figure("Color","w");
    bar(categorical(statsTableRegime.group),[statsTableRegime.abs_err_noF1_mean,statsTableRegime.abs_err_F1_mean]);
    ylabel("Mean absolute error |PM-1|");
    title("Error before/after by Table and F1 regime");
    legend(["noF1","F1"],"Location","best"); grid on; box on; xtickangle(45);
    saveas(f,fig3); close(f);

    f=figure("Color","w");
    if ~isempty(withinByRegime)
        bar(categorical(withinByRegime.dataset),withinByRegime.delta_R2_TsubWithin_afterGroup);
        ylabel("\Delta R^2 by adding Tsub within LD_group");
        title("Within-group Tsub contribution by F1 regime");
        grid on; box on; xtickangle(30);
    end
    saveas(f,fig4); close(f);
end

function writeReport(outMd,inFile,shNo,shF1,A,T0,sigma,thr_active,thr_stuck, ...
    overall_primary, overall_ref, by_table, by_regime, by_table_regime, by_ld_regime, by_table_ld_regime, ...
    model_primary, model_by_regime, within_primary, within_by_regime, within_by_table, ...
    fig1,fig2,fig3,fig4)

    fid=fopen(outMd,"w");
    if fid<0; error("Cannot write md."); end

    fprintf(fid,"# ST-LD-00C F1 active/stuck reinterpretation\n\n");
    fprintf(fid,"作成日時: %s\n\n", string(datetime("now","Format","yyyy-MM-dd HH:mm:ss")));
    fprintf(fid,"## 1. 目的\n\n");
    fprintf(fid,"ST-F1-00で確認したF1_fixedの効き幅・張り付き結果を踏まえ、ST-LD-00の読みを再解釈する。\n\n");
    fprintf(fid,"このrunでは補正式を作らない。F1 active / weak / stuck 領域別に、PM_F1、L/D group、群内Tsub成分を分けて見る。\n\n");

    fprintf(fid,"## 2. 入力\n\n");
    fprintf(fid,"- input_file: `%s`\n", string(inFile));
    fprintf(fid,"- noF1_sheet: `%s`\n", string(shNo));
    fprintf(fid,"- F1_sheet: `%s`\n\n", string(shF1));

    fprintf(fid,"## 3. F1_fixed definition and regimes\n\n");
    fprintf(fid,"```text\n");
    fprintf(fid,"F1_fixed(Tsub) = 1 + A * exp( - (Tsub - T0)^2 / sigma )\n");
    fprintf(fid,"A     = %.8g\n",A);
    fprintf(fid,"T0    = %.8g K\n",T0);
    fprintf(fid,"sigma = %.8g\n",sigma);
    fprintf(fid,"active_ge_1pct   : F1 - 1 >= %.6g\n",thr_active);
    fprintf(fid,"weak_0p1_to_1pct : %.6g < F1 - 1 < %.6g\n",thr_stuck,thr_active);
    fprintf(fid,"stuck_le_0p1pct  : F1 - 1 <= %.6g\n",thr_stuck);
    fprintf(fid,"```\n\n");

    fprintf(fid,"## 4. Primary summary: Table9-12\n\n"); writeTableMd(fid,overall_primary);
    fprintf(fid,"\n\n## 5. Reference summary: Table8-14\n\n"); writeTableMd(fid,overall_ref);
    fprintf(fid,"\n\n## 6. By Table\n\n"); writeTableMd(fid,by_table);
    fprintf(fid,"\n\n## 7. By F1 regime\n\n"); writeTableMd(fid,by_regime);
    fprintf(fid,"\n\n## 8. By Table and F1 regime\n\n"); writeTableMd(fid,by_table_regime);
    fprintf(fid,"\n\n## 9. By L/D group and F1 regime\n\n"); writeTableMd(fid,by_ld_regime);
    fprintf(fid,"\n\n## 10. By Table, L/D group, and F1 regime\n\n"); writeTableMd(fid,by_table_ld_regime);
    fprintf(fid,"\n\n## 11. Model compare: primary\n\n"); writeTableMd(fid,model_primary);
    fprintf(fid,"\n\n## 12. Model compare: by F1 regime\n\n"); writeTableMd(fid,model_by_regime);
    fprintf(fid,"\n\n## 13. Within decomposition: primary\n\n"); writeTableMd(fid,within_primary);
    fprintf(fid,"\n\n## 14. Within decomposition: by F1 regime\n\n"); writeTableMd(fid,within_by_regime);
    fprintf(fid,"\n\n## 15. Within decomposition: by Table\n\n"); writeTableMd(fid,within_by_table);

    fprintf(fid,"\n\n## 16. Automatic reading guide\n\n");
    fprintf(fid,"```text\n");
    fprintf(fid,"1. active_ge_1pctでPM_noF1<1が多く改善している場合、F1は過小側持ち上げとして効いている。\n");
    fprintf(fid,"2. active_ge_1pctでPM_noF1>1が悪化している場合、片方向補正の副作用として読む。\n");
    fprintf(fid,"3. stuck_le_0p1pctでPM_F1差が残る場合、それはF1が補正した結果ではなく、F1がほぼ効いていない元構造として読む。\n");
    fprintf(fid,"4. stuck領域でL/D group差が見えても、直ちにL/D補正式へは進まない。\n");
    fprintf(fid,"5. ST-LD-01へ進む前に、active/stuckで同じ向きの残差構造が再現するかを見る。\n");
    fprintf(fid,"```\n\n");

    fprintf(fid,"## 17. Figures\n\n");
    fprintf(fid,"- `%s`\n",fig1);
    fprintf(fid,"- `%s`\n",fig2);
    fprintf(fid,"- `%s`\n",fig3);
    fprintf(fid,"- `%s`\n\n",fig4);

    fprintf(fid,"## 18. 次アクション\n\n");
    fprintf(fid,"```text\n");
    fprintf(fid,"1. by_F1_regime を確認する。\n");
    fprintf(fid,"2. by_table_regime と by_table_LD_regime で、Table11/12 longがstuck側にあるか確認する。\n");
    fprintf(fid,"3. within_by_regime で、F1 active側とstuck側の群内Tsub成分を確認する。\n");
    fprintf(fid,"4. ST-LD-00のTable11/12判定を、F1が効いて消えたのか、F1が効いていない領域の元構造なのかに分けて再解釈する。\n");
    fprintf(fid,"5. 判断をworking_log r38へ追記する。\n");
    fprintf(fid,"```\n");
    fclose(fid);
end

function writeTableMd(fid,T)
    if isempty(T); fprintf(fid,"_empty_\n"); return; end
    vars=string(T.Properties.VariableNames);
    fprintf(fid,"| %s |\n",strjoin(vars," | "));
    fprintf(fid,"| %s |\n",strjoin(repmat("---",size(vars))," | "));
    for i=1:height(T)
        vals=strings(1,numel(vars));
        for j=1:numel(vars)
            v=T.(vars(j))(i);
            if isnumeric(v) || islogical(v)
                vals(j)=sprintf("%.6g",double(v));
            else
                vals(j)=string(v);
            end
            vals(j)=replace(vals(j),"|","/");
        end
        fprintf(fid,"| %s |\n",strjoin(vals," | "));
    end
end
