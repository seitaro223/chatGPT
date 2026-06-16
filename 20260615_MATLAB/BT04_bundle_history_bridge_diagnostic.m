%% BT04_bundle_history_bridge_diagnostic.m
% BT04: 単管L/D仮説からバンドル履歴変数への橋渡し診断
%
% 目的:
%   もともとは「バンドル108/161/164差をL/DHで補正できそう」という問題意識だった。
%   単管T&M/BMIでは、L/D単独補正式は弱い一方で、L/Dや加熱長は熱履歴・
%   沸騰履歴の代理として意味を持つ可能性があると整理した。
%   そこでBT04では、バンドル側で L/DHそのものではなく、DNBまでの実効履歴長、
%   x_eq、F1(Tsub)、F_form のどれを見るのが筋がよいかを診断する。
%
% 重要:
%   - 補正式は作らない。
%   - R2が高いモデルをそのまま採用しない。
%   - F2/F1F2は使わない。
%   - バンドルでは x_Mes = x_eq として扱う。
%   - F_formはF1ではない。
%
% 入力:
%   H52Q_current_bundle_input_v1_*.xlsx
%
% 出力:
%   BT04_bundle_history_bridge_diagnostic_yyyymmdd_HHMMSS.xlsx
%   run_report_BT04_bundle_history_bridge_diagnostic_yyyymmdd_HHMMSS.md

clear; clc;

%% Settings
inputFile = ""; % 空なら最新のcurrent_bundle_inputを自動探索
if strlength(inputFile)==0
    inputFile = findLatestFile("H52Q_current_bundle_input_v1_*.xlsx");
end
if ~isfile(inputFile)
    error("Input file not found: %s", inputFile);
end

ts = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "BT04_bundle_history_bridge_diagnostic_" + ts + ".xlsx";
outMd   = "run_report_BT04_bundle_history_bridge_diagnostic_" + ts + ".md";

sheetMap = table( ...
    ["noF1";"noF1";"noF1";"F1";"F1";"F1"], ...
    ["108";"161";"164";"108";"161";"164"], ...
    ["tm_108";"tm_161";"tm_164";"tm_F1_108";"tm_F1_161";"tm_F1_164"], ...
    'VariableNames', {'corr','case_id','sheet'});

%% Read all sheets
all = table();
for i=1:height(sheetMap)
    T = readSheet(inputFile, sheetMap.sheet(i));
    D = normalizeSheet(T, sheetMap.corr(i), sheetMap.case_id(i), sheetMap.sheet(i));
    all = [all; D]; %#ok<AGROW>
end

% add point index inside each case/correction
all.point_index = zeros(height(all),1);
for c = ["noF1","F1"]
    for id = ["108","161","164"]
        idx = find(all.corr==c & all.case_id==id);
        all.point_index(idx) = (1:numel(idx))';
    end
end

%% Pair noF1 and F1
P = table();
for id = ["108","161","164"]
    n = min(sum(all.corr=="noF1" & all.case_id==id), sum(all.corr=="F1" & all.case_id==id));
    for k=1:n
        A = all(all.corr=="noF1" & all.case_id==id & all.point_index==k,:);
        B = all(all.corr=="F1"   & all.case_id==id & all.point_index==k,:);
        r = table();
        r.case_id = id;
        r.point_index = k;
        r.No_TableNo = B.No_TableNo;
        r.No = B.No;
        % response variables
        r.q_exp_MWm2 = B.q_exp_MWm2;
        r.q_calc_noF1_MWm2 = A.q_calc_MWm2;
        r.q_calc_F1_MWm2   = B.q_calc_MWm2;
        r.PM_noF1 = A.PM;
        r.PM_F1   = B.PM;
        r.delta_PM = B.PM - A.PM;
        r.lift_ratio = safeRatio(B.PM, A.PM);
        r.delta_PM_per_Fcorr_minus1 = safeRatio(r.delta_PM, B.Fcorr - 1);
        r.lift_minus1_per_Fcorr_minus1 = safeRatio(r.lift_ratio - 1, B.Fcorr - 1);
        % axis variables
        r.L_over_DH = B.L_over_DH;
        r.z_DNB_over_DH = B.z_DNB_over_DH;
        r.z_DNB_over_L  = B.z_DNB_over_L;
        r.x_eq = B.x_eq;
        r.Tsub_K = B.Tsub_K;
        r.Fcorr = B.Fcorr;
        r.F1_formula_from_Tsub = B.F1_formula_from_Tsub;
        r.F_form = B.F_form;
        r.Tw_minus_Tsat_K = B.Tw_minus_Tsat_K;
        r.Tm_minus_Tsat_K = B.Tm_minus_Tsat_K;
        P = [P; r]; %#ok<AGROW>
    end
end

%% Definitions
defResponse = cell2table({
    'PM_noF1','F1なしの元モデル誤差。L/DH仮説・x_eq仮説を見る最初の応答量。'
    'PM_F1','F1後に残る誤差。BT03で見た最終状態。'
    'delta_PM','F1による絶対的な持ち上げ量。PM_F1 - PM_noF1。'
    'lift_ratio','F1による倍率効果。PM_F1 / PM_noF1。'
    'delta_PM_per_Fcorr_minus1','F1係数差を割った見かけの効きやすさ。Fcorrが1に近いので参考扱い。'
    'lift_minus1_per_Fcorr_minus1','倍率効果をFcorr-1で割った見かけの効きやすさ。参考扱い。'
    'q_exp_MWm2','実験熱流束。結果量であり補正式入力ではない。'
    'q_calc_noF1_MWm2','noF1計算熱流束。'
    'q_calc_F1_MWm2','F1計算熱流束。'
    }, 'VariableNames', {'response','meaning'});

defAxis = cell2table({
    'L_over_DH','geometry_length','全加熱長の水力等価直径基準長さ。元のL/DH仮説。','単管で避けたL/D単独補正式に戻らない。'
    'z_DNB_over_DH','effective_history','DNB位置までの水力等価直径基準の実効履歴長。','L/DHと交絡するがDNB位置までの履歴に近い。'
    'z_DNB_over_L','effective_history','DNB位置の相対位置。','z_DNB/DHとは意味が違う。'
    'x_eq','thermal_state','熱平衡クオリティ。熱収支・沸騰進行度候補。','単独説明因子と決めつけない。'
    'Tsub_K','thermal_state','入口サブクール度。現行F1の元変数。','入口条件であり局所履歴とは異なる。'
    'Fcorr','F1_Tsub','現行F1(Tsub)補正係数。','係数差だけでなくモデル応答も見る。'
    'F_form','nonuniform_heat','非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。','F1ではない。'
    'Tw_minus_Tsat_K','model_internal','壁面過熱度。結果側・モデル内部量。','補正式入力として読むには注意。'
    'Tm_minus_Tsat_K','model_internal','平均液温と飽和温度の差。結果側・モデル内部量。','補正式入力として読むには注意。'
    }, 'VariableNames', {'axis','axis_group','meaning','caution'});

responseVars = string(defResponse.response);
axisVars = string(defAxis.axis);

%% Case summary
caseSummary = table();
summaryVars = [responseVars; axisVars];
for id = ["108","161","164"]
    S = P(P.case_id==id,:);
    row = table(); row.case_id = id; row.N = height(S);
    for v = summaryVars'
        row.(v + "_mean") = mean(S.(v),'omitnan');
        row.(v + "_sd")   = std(S.(v),'omitnan');
    end
    caseSummary = [caseSummary; row]; %#ok<AGROW>
end

%% 108 contrasts
responseSummary = table();
for v = responseVars'
    responseSummary = [responseSummary; contrast108(caseSummary, v+"_mean", "response")]; %#ok<AGROW>
end
axisSummary = table();
for v = axisVars'
    axisSummary = [axisSummary; contrast108(caseSummary, v+"_mean", "axis")]; %#ok<AGROW>
end

%% Correlations
corrPoint = corrTable(P, responseVars, defAxis, "point_level");
caseCorrInput = makeCaseInput(caseSummary, [responseVars; axisVars]);
corrCase = corrTable(caseCorrInput, responseVars, defAxis, "case_mean_N3");

noF1Focus = corrPoint(corrPoint.response=="PM_noF1",:);
noF1Focus = sortrows(noF1Focus,'R2','descend');

f1EffectFocus = corrPoint(ismember(corrPoint.response, ["delta_PM","lift_ratio","delta_PM_per_Fcorr_minus1","lift_minus1_per_Fcorr_minus1"]),:);
f1EffectFocus = sortrows(f1EffectFocus, {'response','R2'}, {'ascend','descend'});

historyVsGeometry = makeHistoryVsGeometry(corrPoint);

%% Exploratory model comparison (DIAG_ONLY)
modelCompare = table();
specs = {
    'PM_noF1 ~ L/DH','PM_noF1',{'L_over_DH'}
    'PM_noF1 ~ z_DNB/DH','PM_noF1',{'z_DNB_over_DH'}
    'PM_noF1 ~ z_DNB/L','PM_noF1',{'z_DNB_over_L'}
    'PM_noF1 ~ x_eq','PM_noF1',{'x_eq'}
    'PM_noF1 ~ Tsub','PM_noF1',{'Tsub_K'}
    'PM_noF1 ~ F_form','PM_noF1',{'F_form'}
    'PM_noF1 ~ x_eq + z_DNB/DH','PM_noF1',{'x_eq','z_DNB_over_DH'}
    'PM_noF1 ~ L/DH + z_DNB/DH','PM_noF1',{'L_over_DH','z_DNB_over_DH'}
    'PM_noF1 ~ x_eq + F_form + z_DNB/DH','PM_noF1',{'x_eq','F_form','z_DNB_over_DH'}
    'PM_F1 ~ L/DH','PM_F1',{'L_over_DH'}
    'PM_F1 ~ z_DNB/DH','PM_F1',{'z_DNB_over_DH'}
    'PM_F1 ~ x_eq','PM_F1',{'x_eq'}
    'PM_F1 ~ Tsub','PM_F1',{'Tsub_K'}
    'PM_F1 ~ F_form','PM_F1',{'F_form'}
    'PM_F1 ~ x_eq + F_form + z_DNB/DH','PM_F1',{'x_eq','F_form','z_DNB_over_DH'}
    'PM_F1 ~ Tsub + x_eq + F_form + z_DNB/DH','PM_F1',{'Tsub_K','x_eq','F_form','z_DNB_over_DH'}
    'delta_PM ~ x_eq','delta_PM',{'x_eq'}
    'delta_PM ~ Tsub','delta_PM',{'Tsub_K'}
    'delta_PM ~ Fcorr','delta_PM',{'Fcorr'}
    'delta_PM ~ z_DNB/DH','delta_PM',{'z_DNB_over_DH'}
    'delta_PM ~ L/DH','delta_PM',{'L_over_DH'}
    'delta_PM ~ x_eq + Tsub','delta_PM',{'x_eq','Tsub_K'}
    'lift_ratio ~ x_eq','lift_ratio',{'x_eq'}
    'lift_ratio ~ Tsub','lift_ratio',{'Tsub_K'}
    'lift_ratio ~ Fcorr','lift_ratio',{'Fcorr'}
    'lift_ratio ~ z_DNB/DH','lift_ratio',{'z_DNB_over_DH'}
    'lift_ratio ~ L/DH','lift_ratio',{'L_over_DH'}
    'lift_ratio ~ x_eq + Tsub','lift_ratio',{'x_eq','Tsub_K'}
    };
for i=1:size(specs,1)
    row = fitModel(P, string(specs{i,2}), string(specs{i,3}));
    row.model = string(specs{i,1});
    row.response = string(specs{i,2});
    row.predictors = strjoin(string(specs{i,3}), ' + ');
    modelCompare = [modelCompare; row]; %#ok<AGROW>
end
modelCompare = movevars(modelCompare, {'model','response','predictors'}, 'Before', 1);
modelCompare = sortrows(modelCompare, {'response','R2'}, {'ascend','descend'});

%% Interpretation flags
flags = makeFlags(responseSummary, axisSummary, noF1Focus, f1EffectFocus, historyVsGeometry, modelCompare);

%% Write Excel
if exist(outXlsx,'file'), delete(outXlsx); end
writetable(defResponse, outXlsx, 'Sheet','definitions_response');
writetable(defAxis, outXlsx, 'Sheet','definitions_axis');
writetable(caseSummary, outXlsx, 'Sheet','BT04_case_summary');
writetable(responseSummary, outXlsx, 'Sheet','BT04_response_summary');
writetable(axisSummary, outXlsx, 'Sheet','BT04_axis_summary');
writetable(corrPoint, outXlsx, 'Sheet','BT04_response_axis_corr');
writetable(noF1Focus, outXlsx, 'Sheet','BT04_noF1_focus');
writetable(f1EffectFocus, outXlsx, 'Sheet','BT04_F1_effect_focus');
writetable(historyVsGeometry, outXlsx, 'Sheet','BT04_history_vs_geometry');
writetable(modelCompare, outXlsx, 'Sheet','BT04_model_compare_DIAG');
writetable(corrCase, outXlsx, 'Sheet','BT04_case_corr_N3');
writetable(flags, outXlsx, 'Sheet','BT04_interpretation_flags');
writetable(P, outXlsx, 'Sheet','BT04_paired_points');
writetable(all, outXlsx, 'Sheet','BT04_point_detail');

%% Write report
md = strings(0,1);
md(end+1) = "# BT04 bundle history bridge diagnostic";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "単管T&M/BMIでは、L/D単独補正式を作る根拠は弱い一方で、L/Dや加熱長は沸騰履歴・熱履歴の代理として意味を持つ可能性があると整理した。BT04では、この流れを受けて、バンドル108/161/164で、L/DHそのもの、DNBまでの実効履歴長、x_eq、F1(Tsub)、F_formのどれを見るのが筋がよいかを診断した。";
md(end+1) = "";
md(end+1) = "## 2. 入力と出力";
md(end+1) = "";
md(end+1) = "- 入力: `" + inputFile + "`";
md(end+1) = "- 出力Excel: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 3. 前提";
md(end+1) = "";
md(end+1) = "- r8 resultブックは直接読まない。";
md(end+1) = "- current_bundle_inputを読む。";
md(end+1) = "- F2/F1F2は使わない。";
md(end+1) = "- 比較対象はnoF1とF1のみ。";
md(end+1) = "- バンドルでは `x_Mes = x_eq` として扱う。";
md(end+1) = "- F1は単管基準のTsub補正。";
md(end+1) = "- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。";
md(end+1) = "- 補正式は作らない。";
md(end+1) = "- R2が高いモデルをそのまま採用しない。";
md(end+1) = "";
md(end+1) = "## 4. Response summary"; md(end+1) = ""; md(end+1) = tableToMarkdown(responseSummary); md(end+1) = "";
md(end+1) = "## 5. Axis summary"; md(end+1) = ""; md(end+1) = tableToMarkdown(axisSummary); md(end+1) = "";
md(end+1) = "## 6. Response-axis correlation"; md(end+1) = ""; md(end+1) = "注：点群相関は探索的診断であり、補正式係数ではない。"; md(end+1) = ""; md(end+1) = tableToMarkdown(corrPoint); md(end+1) = "";
md(end+1) = "## 7. PM_noF1 focus"; md(end+1) = ""; md(end+1) = "F1なしの元モデル誤差が、L/DH、DNBまでの履歴長、x_eqなどで整理されるかを見る。"; md(end+1) = ""; md(end+1) = tableToMarkdown(noF1Focus); md(end+1) = "";
md(end+1) = "## 8. F1 effect focus"; md(end+1) = ""; md(end+1) = "F1による持ち上げ量・倍率が、x_eq、Tsub、Fcorr、履歴長などで整理されるかを見る。"; md(end+1) = ""; md(end+1) = tableToMarkdown(f1EffectFocus); md(end+1) = "";
md(end+1) = "## 9. History versus geometry"; md(end+1) = ""; md(end+1) = "単純なL/DHと、DNBまでの実効履歴長 z_DNB/DH、z_DNB/L、x_eq を比較する。"; md(end+1) = ""; md(end+1) = tableToMarkdown(historyVsGeometry); md(end+1) = "";
md(end+1) = "## 10. Exploratory model comparison"; md(end+1) = ""; md(end+1) = "注：探索的な線形整理であり、係数・R2を補正式として採用しない。"; md(end+1) = ""; md(end+1) = tableToMarkdown(modelCompare); md(end+1) = "";
md(end+1) = "## 11. Interpretation flags"; md(end+1) = ""; md(end+1) = tableToMarkdown(flags); md(end+1) = "";
md(end+1) = "## 12. 次アクション";
md(end+1) = "";
md(end+1) = "1. BT04_interpretation_flagsを確認する。";
md(end+1) = "2. PM_noF1が、L/DH・z_DNB/DH・x_eqのどれと対応するかを見る。";
md(end+1) = "3. delta_PM / lift_ratioが、x_eq・Tsub・Fcorr・履歴長のどれと対応するかを見る。";
md(end+1) = "4. L/DHだけが高く見える場合でも、単管で避けたL/D単独補正式に戻らない。";
md(end+1) = "5. F_formが効いて見える場合は、F1置換より先に非一様加熱換算の扱いを固定する。";
md(end+1) = "6. BT04の結果をworking logへ追記し、その後にBT05へ進むか判断する。";

fid = fopen(outMd,'w');
for i=1:numel(md), fprintf(fid, "%s\n", md(i)); end
fclose(fid);

fprintf("Wrote Excel: %s\n", outXlsx);
fprintf("Wrote Markdown: %s\n", outMd);

disp("=== BT04 interpretation flags ===");
disp(flags);

%% Local functions
function latest = findLatestFile(pattern)
    d = dir(pattern);
    if isempty(d), error("No file matching pattern: %s", pattern); end
    [~,idx] = max([d.datenum]);
    latest = string(d(idx).name);
end

function T = readSheet(file, sheet)
    opts = detectImportOptions(file,'Sheet',sheet);
    opts.VariableNamingRule = 'preserve';
    T = readtable(file,opts);
end

function D = normalizeSheet(T, corr, case_id, sheet)
    n = height(T);
    qP = numcol(T,["q_P","qP","q_calc","qCalc"]);
    qM = numcol(T,["q_M","qM","q_exp","qExp"]);
    Tin = numcol(T,"Tin");
    Tsat = numcol(T,["Ts","Tsat"]);
    Tsub = numcol(T,"Tsub");
    Fcorr = numcol(T,["Fcorr","F_corr","F1corr"]);
    A_corr = numcol(T,["A_corr","Acorr","A"]);
    sigma_corr = numcol(T,["σ_corr","sigma_corr","sigmacorr","sigma"]);
    xeq = numcol(T,["x_Mes","xMes","x_EQ","xeq","x_eq"]);
    L_DNB = numcol(T,["L_DNB","LDNB","z_DNB","zDNB"]);
    DH = numcol(T,["DH","D_h","Dh"]);
    L = numcol(T,["L","HeatedLength","L_heat"]);
    Tm = numcol(T,"Tm");
    Tw = numcol(T,"Tw");
    F_form = numcol(T,"F_form");
    No = numcol(T,"No");
    No_TableNo = textcol(T,["No_TableNo","Case","case"]);

    F1form = NaN(n,1);
    ok = isfinite(A_corr) & isfinite(sigma_corr) & isfinite(Tsub) & sigma_corr~=0;
    F1form(ok) = 1 + A_corr(ok).*exp(-((Tsub(ok)-40).^2)./sigma_corr(ok));

    D = table();
    D.corr = repmat(string(corr),n,1);
    D.case_id = repmat(string(case_id),n,1);
    D.sheet = repmat(string(sheet),n,1);
    D.No_TableNo = No_TableNo;
    D.No = No;
    D.q_exp_Wm2 = qM;
    D.q_calc_Wm2 = qP;
    D.q_exp_MWm2 = qM/1e6;
    D.q_calc_MWm2 = qP/1e6;
    D.PM = qP./qM;
    D.Tin_K = Tin;
    D.Tsat_K = Tsat;
    D.Tsub_K = Tsub;
    D.Fcorr = Fcorr;
    D.A_corr = A_corr;
    D.sigma_corr = sigma_corr;
    D.F1_formula_from_Tsub = F1form;
    D.x_eq = xeq;
    D.DH_m = DH;
    D.L_m = L;
    D.L_over_DH = L./DH;
    D.z_DNB_m = L_DNB;
    D.z_DNB_over_DH = L_DNB./DH;
    D.z_DNB_over_L = L_DNB./L;
    D.Tm_K = Tm;
    D.Tw_K = Tw;
    D.Tw_minus_Tsat_K = Tw - Tsat;
    D.Tm_minus_Tsat_K = Tm - Tsat;
    D.F_form = F_form;
end

function v = numcol(T, candidates)
    name = findcol(T,candidates);
    if strlength(name)==0, v = NaN(height(T),1); return; end
    raw = T.(name);
    if isnumeric(raw), v = double(raw); else, v = str2double(string(raw)); end
end

function v = textcol(T, candidates)
    name = findcol(T,candidates);
    if strlength(name)==0, v = strings(height(T),1); return; end
    v = string(T.(name));
end

function name = findcol(T,candidates)
    vars = string(T.Properties.VariableNames);
    for c = string(candidates)
        idx = find(vars==c,1);
        if ~isempty(idx), name = vars(idx); return; end
    end
    nv = normnames(vars);
    for c = string(candidates)
        idx = find(nv==normnames(c),1);
        if ~isempty(idx), name = vars(idx); return; end
    end
    name = "";
end

function s = normnames(s)
    s = lower(string(s));
    s = replace(s,"σ","sigma");
    s = regexprep(s,"[^a-z0-9]","");
end

function r = safeRatio(a,b)
    r = NaN(size(a));
    ok = isfinite(a) & isfinite(b) & abs(b)>0;
    r(ok) = a(ok)./b(ok);
end

function C = contrast108(caseSummary, varName, kind)
    A = caseSummary(caseSummary.case_id=="108",:);
    B = caseSummary(caseSummary.case_id=="161",:);
    Cc = caseSummary(caseSummary.case_id=="164",:);
    C = table();
    C.kind = string(kind);
    C.name = erase(string(varName),"_mean");
    C.value_108 = A.(varName);
    C.value_161 = B.(varName);
    C.value_164 = Cc.(varName);
    C.mean_161_164 = mean([B.(varName), Cc.(varName)],'omitnan');
    C.delta_108_minus_mean_161_164 = C.value_108 - C.mean_161_164;
    C.ratio_108_over_mean_161_164 = safeRatio(C.value_108, C.mean_161_164);
end

function caseInput = makeCaseInput(caseSummary, vars)
    caseInput = table(); caseInput.case_id = caseSummary.case_id;
    for v = string(vars)'
        vn = v + "_mean";
        if ismember(vn,string(caseSummary.Properties.VariableNames))
            caseInput.(v) = caseSummary.(vn);
        end
    end
end

function CT = corrTable(T, responses, defAxis, level)
    CT = table();
    for r = string(responses)'
        for i=1:height(defAxis)
            ax = string(defAxis.axis(i));
            row = table(); row.level=string(level); row.response=r; row.axis=ax; row.axis_group=string(defAxis.axis_group(i));
            if ~ismember(r,string(T.Properties.VariableNames)) || ~ismember(ax,string(T.Properties.VariableNames))
                row.N=0; row.pearson_r=NaN; row.slope=NaN; row.intercept=NaN; row.R2=NaN;
            else
                x=T.(ax); y=T.(r); ok=isfinite(x)&isfinite(y); row.N=sum(ok);
                if row.N>=3
                    CC=corrcoef(x(ok),y(ok)); row.pearson_r=CC(1,2);
                    p=polyfit(x(ok),y(ok),1); yhat=polyval(p,x(ok));
                    ssr=sum((y(ok)-yhat).^2); sst=sum((y(ok)-mean(y(ok))).^2);
                    row.slope=p(1); row.intercept=p(2); row.R2=1-ssr/sst;
                else
                    row.pearson_r=NaN; row.slope=NaN; row.intercept=NaN; row.R2=NaN;
                end
            end
            CT=[CT;row]; %#ok<AGROW>
        end
    end
end

function H = makeHistoryVsGeometry(corrPoint)
    H = table();
    for r = ["PM_noF1","PM_F1","delta_PM","lift_ratio"]
        row=table(); row.response=r;
        row.R2_L_over_DH=getR2(corrPoint,r,"L_over_DH");
        row.R2_z_DNB_over_DH=getR2(corrPoint,r,"z_DNB_over_DH");
        row.R2_z_DNB_over_L=getR2(corrPoint,r,"z_DNB_over_L");
        row.R2_x_eq=getR2(corrPoint,r,"x_eq");
        row.R2_Tsub=getR2(corrPoint,r,"Tsub_K");
        row.R2_Fcorr=getR2(corrPoint,r,"Fcorr");
        row.R2_F_form=getR2(corrPoint,r,"F_form");
        vals=[row.R2_L_over_DH,row.R2_z_DNB_over_DH,row.R2_z_DNB_over_L,row.R2_x_eq,row.R2_Tsub,row.R2_Fcorr,row.R2_F_form];
        labs=["L_over_DH","z_DNB_over_DH","z_DNB_over_L","x_eq","Tsub_K","Fcorr","F_form"];
        [best,idx]=max(vals); row.best_single_axis=labs(idx); row.best_single_R2=best;
        row.history_beats_geometry=row.R2_z_DNB_over_DH>row.R2_L_over_DH;
        row.xeq_beats_geometry=row.R2_x_eq>row.R2_L_over_DH;
        H=[H;row]; %#ok<AGROW>
    end
end

function r2 = getR2(T,response,axis)
    idx=find(T.response==response & T.axis==axis,1);
    if isempty(idx), r2=NaN; else, r2=T.R2(idx); end
end

function row = fitModel(T,response,preds)
    y=T.(response); X=[]; ok=isfinite(y);
    for p=string(preds)
        x=T.(p); ok=ok&isfinite(x); X=[X,x]; %#ok<AGROW>
    end
    row=table(); row.N=sum(ok); row.k_predictors=numel(preds);
    if row.N <= numel(preds)+1
        row.R2=NaN; row.RMSE=NaN; row.note="N不足"; return;
    end
    Xd=[ones(sum(ok),1), X(ok,:)]; yy=y(ok);
    b=Xd\yy; yh=Xd*b;
    ssr=sum((yy-yh).^2); sst=sum((yy-mean(yy)).^2);
    row.R2=1-ssr/sst; row.RMSE=sqrt(mean((yy-yh).^2)); row.note="DIAG_ONLY: 補正式係数として採用しない";
end

function F = makeFlags(responseSummary, axisSummary, noF1Focus, f1EffectFocus, historyVsGeometry, modelCompare)
    item=strings(0,1); status=strings(0,1); value=strings(0,1); reading=strings(0,1);
    add("BT04位置づけ","OK","","単管L/D仮説からバンドル履歴変数への橋渡し診断。補正式化ではない。");
    for resp=["PM_noF1","PM_F1","delta_PM","lift_ratio"]
        S=historyVsGeometry(historyVsGeometry.response==resp,:);
        if height(S)>0
            add(resp+"_best_axis","diagnostic",string(S.best_single_axis)+", R2="+string(sprintf('%.6g',S.best_single_R2)),"どの軸と最も対応するかを見る。過読しない。");
        end
    end
    add("PM_noF1_L_vs_history_vs_xeq","diagnostic",sprintf('R2_LDH=%.6g, R2_zDNB_DH=%.6g, R2_xeq=%.6g', getFocus(noF1Focus,"L_over_DH"), getFocus(noF1Focus,"z_DNB_over_DH"), getFocus(noF1Focus,"x_eq")),"単管で避けたL/D単独補正式に戻らないため、L/DH・z_DNB/DH・x_eqを比較する。");
    add("delta_PM_xeq_Tsub_Fcorr_history","diagnostic",sprintf('R2_xeq=%.6g, R2_Tsub=%.6g, R2_Fcorr=%.6g, R2_zDNB_DH=%.6g', getEffect(f1EffectFocus,"delta_PM","x_eq"), getEffect(f1EffectFocus,"delta_PM","Tsub_K"), getEffect(f1EffectFocus,"delta_PM","Fcorr"), getEffect(f1EffectFocus,"delta_PM","z_DNB_over_DH")),"F1が何に反応して持ち上げているかを見る。Tsub/Fcorrとの共変に注意。");
    add("lift_ratio_xeq_Tsub_Fcorr_history","diagnostic",sprintf('R2_xeq=%.6g, R2_Tsub=%.6g, R2_Fcorr=%.6g, R2_zDNB_DH=%.6g', getEffect(f1EffectFocus,"lift_ratio","x_eq"), getEffect(f1EffectFocus,"lift_ratio","Tsub_K"), getEffect(f1EffectFocus,"lift_ratio","Fcorr"), getEffect(f1EffectFocus,"lift_ratio","z_DNB_over_DH")),"倍率効果でF1の効きやすさと状態量の関係を見る。");
    for resp=["PM_noF1","PM_F1","delta_PM","lift_ratio"]
        S=modelCompare(modelCompare.response==resp,:);
        if height(S)>0
            S=sortrows(S,'R2','descend');
            add("best_model_"+resp,"DIAG_ONLY",string(S.model(1)) + ", R2=" + string(sprintf('%.6g',S.R2(1))),"探索的モデル。補正式として採用しない。");
        end
    end
    add("BT04判断ゲート","hold","","PM_noF1・F1効果量・PM_F1を分け、L/DHではなく履歴長やx_eqで読むべきか判断する。");
    F=table(item,status,value,reading);
    function add(a,b,c,d)
        item(end+1,1)=string(a); status(end+1,1)=string(b); value(end+1,1)=string(c); reading(end+1,1)=string(d);
    end
end

function v = getFocus(T,axis)
    idx=find(T.axis==axis,1); if isempty(idx), v=NaN; else, v=T.R2(idx); end
end
function v = getEffect(T,response,axis)
    idx=find(T.response==response & T.axis==axis,1); if isempty(idx), v=NaN; else, v=T.R2(idx); end
end

function md = tableToMarkdown(T)
    vars=string(T.Properties.VariableNames);
    lines=strings(0,1);
    lines(end+1)="| "+strjoin(vars," | ")+" |";
    lines(end+1)="| "+strjoin(repmat("---",1,numel(vars))," | ")+" |";
    for i=1:height(T)
        row=strings(1,numel(vars));
        for j=1:numel(vars)
            val=T{i,j};
            if isnumeric(val)
                if isscalar(val)
                    if isnan(val), row(j)=""; else, row(j)=string(sprintf('%.6g',val)); end
                else
                    row(j)="[array]";
                end
            elseif isstring(val)
                row(j)=val;
            elseif iscell(val)
                row(j)=string(val{1});
            else
                row(j)=string(val);
            end
            row(j)=replace(row(j),"|","/");
            row(j)=replace(row(j),newline," ");
        end
        lines(end+1)="| "+strjoin(row," | ")+" |";
    end
    md=strjoin(lines,newline);
end
