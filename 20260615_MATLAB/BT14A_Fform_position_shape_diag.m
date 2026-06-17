%% BT14A_Fform_position_shape_diag.m
% BT14-A：F_form・DNB位置・非一様加熱分布側の扱い整理
%
% 位置づけ：
%   BT13-Cで、FformLinear_v1再計算済み正本入力を用いた残差診断を行った。
%   その結果、F1後残差はTsub/x_eq側ではなく、F_form・DNB位置・L/DH側に残る
%   ことを確認した。ただし、F_form、z_DNB/DH、z_DNB/L、L/DHは強く交絡している。
%
% 目的：
%   - F_formを「原因」として扱う前に、DNB位置・L/DH・ケース構造との関係を整理する。
%   - F_formがDNB位置だけで決まっているのか、非一様加熱分布形状も強く含むのかを見る。
%   - 108/164でDNB位置が近いのにF_formが違うケースがあるかを確認する。
%   - PM_F1残差を、補正式ではなく、非一様加熱換算・DNB位置診断として残すべきか整理する。
%
% 前提：
%   - 入力はBT13-Bで作成したFformLinearRecalc tmCompatible v2を使う。
%   - F2/F1F2は使わない。
%   - F1(Tsub)は維持する。
%   - F1(Tsub)をF(x_eq)へ置換しない。
%   - F_form補正式、DNB位置補正式、L/DH補正式は作らない。
%   - current_bundle_inputには軸方向出力分布の元配列は入っていないため、
%     BT14-AではF_formの再積分監査は行わない。
%
% 入力：
%   H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_*.xlsx
%
% 出力：
%   BT14A_Fform_position_shape_diag_yyyymmdd_HHMMSS.xlsx
%   run_report_BT14A_Fform_position_shape_diag_yyyymmdd_HHMMSS.md

clear; clc;

%% ===== Settings =====

inputFile = "";
if strlength(inputFile)==0
    inputFile = latest("H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_*.xlsx");
end

ts = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "BT14A_Fform_position_shape_diag_" + ts + ".xlsx";
outMd   = "run_report_BT14A_Fform_position_shape_diag_" + ts + ".md";

bundles = ["108","161","164"];

fprintf("Input : %s\n", inputFile);
fprintf("Excel : %s\n", outXlsx);
fprintf("Report: %s\n", outMd);

%% ===== Read paired bundle rows =====

D = table();

for b = bundles
    T0 = readtable(inputFile, 'Sheet', "tm_" + b, 'VariableNamingRule','preserve');
    T1 = readtable(inputFile, 'Sheet', "tm_F1_" + b, 'VariableNamingRule','preserve');
    D = [D; pairBundle(T0,T1,str2double(b))]; %#ok<AGROW>
end

D.err_F1 = D.PM_F1 - 1;
D.abs_err_F1 = abs(D.err_F1);

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

%% ===== Diagnostics =====

qc = makeQC(D,inputFile);

bundleSummary = groupSummary(D,"Bundle");
caseSummary = groupSummary(D,"case_group");

pairContrasts = makeCasePairContrasts(caseSummary);
nearPositionPairs = pairContrasts(abs(pairContrasts.delta_z_DNB_L) <= 0.08,:);
if height(nearPositionPairs)==0
    nearPositionPairs = pairContrasts(abs(pairContrasts.delta_z_DNB_L) <= 0.12,:);
end

fformModels = makeFformModelTable(D);
pmModels = makePMModelTable(D);
confounds = makeConfounds(D);

readingFlags = makeReadingFlags(caseSummary, pairContrasts, fformModels, pmModels, confounds);

%% ===== Write Excel =====

if exist(outXlsx,"file"); delete(outXlsx); end

writetable(D,outXlsx,'Sheet','BT14A_rows');
writetable(qc,outXlsx,'Sheet','BT14A_QC');
writetable(bundleSummary,outXlsx,'Sheet','bundle_summary');
writetable(caseSummary,outXlsx,'Sheet','case_summary');
writetable(pairContrasts,outXlsx,'Sheet','case_pair_contrasts');
writetable(nearPositionPairs,outXlsx,'Sheet','near_position_pairs');
writetable(fformModels,outXlsx,'Sheet','Fform_position_models');
writetable(pmModels,outXlsx,'Sheet','PM_F1_relation_models');
writetable(confounds,outXlsx,'Sheet','pairwise_confounds');
writetable(readingFlags,outXlsx,'Sheet','reading_flags');

%% ===== Markdown report =====

md = strings(0,1);
md(end+1) = "# BT14-A F_form / DNB position / axial-shape diagnostic";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT13-Cで、F1後残差がTsub/x_eq側ではなくF_form・DNB位置・L/DH側に残ることを確認した。";
md(end+1) = "BT14-Aでは、F_formを原因と断定する前に、F_formがDNB位置だけで決まっているのか、非一様加熱分布形状も強く含むのかを整理する。";
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
md(end+1) = "- F1(Tsub)は維持する。";
md(end+1) = "- F1(Tsub)をF(x_eq)へ置換しない。";
md(end+1) = "- F_formはF1ではなく、DNB位置の局所熱流束基準への非一様加熱換算係数である。";
md(end+1) = "- BT14-AではF_form補正式、DNB位置補正式、L/DH補正式を作らない。";
md(end+1) = "- current_bundle_inputには軸方向出力分布の元配列がないため、BT14-AはF_form再積分監査ではなく挙動診断である。";
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
md(end+1) = "## 8. Case-pair contrasts";
md(end+1) = "";
md(end+1) = tableToMarkdown(pairContrasts);
md(end+1) = "";
md(end+1) = "## 9. Near-position pairs";
md(end+1) = "";
md(end+1) = tableToMarkdown(nearPositionPairs);
md(end+1) = "";
md(end+1) = "## 10. F_form position models";
md(end+1) = "";
md(end+1) = tableToMarkdown(fformModels);
md(end+1) = "";
md(end+1) = "## 11. PM_F1 relation models";
md(end+1) = "";
md(end+1) = tableToMarkdown(pmModels);
md(end+1) = "";
md(end+1) = "## 12. Pairwise confounds";
md(end+1) = "";
md(end+1) = tableToMarkdown(confounds);
md(end+1) = "";
md(end+1) = "## 13. Reading flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(readingFlags);
md(end+1) = "";
md(end+1) = "## 14. 判断メモ";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "このrun_reportを確認してから判断する。";
md(end+1) = "見るべきポイント：";
md(end+1) = "  1. 108/164でz_DNB/Lが近いのにF_formが大きく違う組合せがあるか。";
md(end+1) = "  2. F_formがDNB位置だけではなく、非一様加熱分布形状を強く含むと読めるか。";
md(end+1) = "  3. F_formとL/DH、z_DNB/DH、z_DNB/Lの交絡がどの程度か。";
md(end+1) = "  4. PM_F1残差をF_form補正式化せず、非一様加熱換算・DNB位置診断として残す判断でよいか。";
md(end+1) = "  5. 次に軸方向出力分布元データを使ったF_form再積分監査へ進む必要があるか。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 15. 次アクション";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "BT14-A結果を確認する。";
md(end+1) = "問題なければworking_logへ追記する。";
md(end+1) = "必要ならBT14-Bとして、F_form作成元の軸方向出力分布を用いた再積分監査へ進む。";
md(end+1) = "```";

fid = fopen(outMd,"w");
for i=1:numel(md)
    fprintf(fid,"%s\n",md(i));
end
fclose(fid);

disp("=== QC ===");
disp(qc);
disp("=== Case summary ===");
disp(caseSummary);
disp("=== Near-position pairs ===");
disp(nearPositionPairs);

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
D.PM_noF1 = firstNum(T0,["PM_ratio","PM","P_M","P/M","PoverM"]);
D.PM_F1   = firstNum(T1,["PM_ratio","PM","P_M","P/M","PoverM"]);
D.q_exp = firstNonMissing(T1,T0,["q_exp","q_M","qM","q_M_MW","qM_MW","qMes","q_Mes"]);
D.q_calc_F1 = firstNum(T1,["q_calc","q_P","qP","q_P_MW","qP_MW","qCal","q_Cal"]);
D.F_form = firstNonMissing(T1,T0,["F_form","Fform","F_FORM"]);
D.Tsub = firstNonMissing(T1,T0,["Tsub","T_sub","DeltaTsub","dTsub"]);
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
add("input_file","info",inputFile,"BT13-B正本入力。");
add("row_count",ok(height(D)==58),sprintf("%d",height(D)),"108=14, 161=23, 164=21 合計58行が期待値。");
add("bundle_count",ok(numel(unique(D.Bundle))==3),sprintf("%d",numel(unique(D.Bundle))),"108/161/164の3群。");
add("PM_F1_missing",ok(sum(~isfinite(D.PM_F1))==0),sprintf("%d",sum(~isfinite(D.PM_F1))),"PM_F1欠損。");
add("F_form_missing",ok(sum(~isfinite(D.F_form))==0),sprintf("%d",sum(~isfinite(D.F_form))),"F_form欠損。");
add("z_DNB_L_missing",ok(sum(~isfinite(D.z_DNB_L))==0),sprintf("%d",sum(~isfinite(D.z_DNB_L))),"z_DNB/L欠損。");
add("z_DNB_DH_missing",ok(sum(~isfinite(D.z_DNB_DH))==0),sprintf("%d",sum(~isfinite(D.z_DNB_DH))),"z_DNB/DH欠損。");
add("L_DH_missing",ok(sum(~isfinite(D.L_DH))==0),sprintf("%d",sum(~isfinite(D.L_DH))),"L/DH欠損。");
add("axial_profile_available","CHECK","not_in_current_input","current_bundle_inputには軸方向出力分布元配列がない。BT14-Aは再積分監査ではなく挙動診断。");
add("formula_policy","OK","no_new_formula","F_form/DNB位置/L_DH補正式は作らない。");
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
    vars = ["PM_noF1","PM_F1","err_F1","abs_err_F1","q_exp","q_calc_F1","F_form","Tsub","x_eq","z_DNB_DH","z_DNB_L","L_DH"];
    for vname = vars
        v = D.(vname);
        row.(vname+"_mean") = mean(v(idx),'omitnan');
        row.(vname+"_sd") = std(v(idx),'omitnan');
    end
    S = [S; row]; %#ok<AGROW>
end
end

function P = makeCasePairContrasts(CS)
P = table();
for i=1:height(CS)
    for j=i+1:height(CS)
        row = table();
        row.case_a = CS.group(i);
        row.case_b = CS.group(j);
        row.delta_z_DNB_L = CS.z_DNB_L_mean(i) - CS.z_DNB_L_mean(j);
        row.abs_delta_z_DNB_L = abs(row.delta_z_DNB_L);
        row.delta_z_DNB_DH = CS.z_DNB_DH_mean(i) - CS.z_DNB_DH_mean(j);
        row.delta_L_DH = CS.L_DH_mean(i) - CS.L_DH_mean(j);
        row.delta_F_form = CS.F_form_mean(i) - CS.F_form_mean(j);
        row.abs_delta_F_form = abs(row.delta_F_form);
        row.delta_PM_F1 = CS.PM_F1_mean(i) - CS.PM_F1_mean(j);
        row.note = "general_pair";
        if abs(row.delta_z_DNB_L) <= 0.08 && abs(row.delta_F_form) >= 0.30
            row.note = "near_DNB_position_but_large_Fform_difference";
        elseif abs(row.delta_z_DNB_L) <= 0.08
            row.note = "near_DNB_position";
        elseif abs(row.delta_F_form) >= 0.30
            row.note = "large_Fform_difference";
        end
        P = [P; row]; %#ok<AGROW>
    end
end
P = sortrows(P,["abs_delta_z_DNB_L","abs_delta_F_form"],["ascend","descend"]);
end

function M = makeFformModelTable(D)
M = table();

[y, oky] = finiteVector(D.F_form);

addSimple("F_form","z_DNB_L",D.z_DNB_L);
addSimple("F_form","z_DNB_DH",D.z_DNB_DH);
addSimple("F_form","L_DH",D.L_DH);
addMulti("F_form","z_DNB_L + L_DH",[D.z_DNB_L, D.L_DH]);
addMulti("F_form","z_DNB_L + z_DNB_DH",[D.z_DNB_L, D.z_DNB_DH]);
addMulti("F_form","z_DNB_L + z_DNB_DH + L_DH",[D.z_DNB_L, D.z_DNB_DH, D.L_DH]);
addCaseDummy("F_form","case_group_dummy",D.case_group);

    function addSimple(target,predName,x)
        [r2,n,slope,intercept] = linR2(x,D.F_form);
        row = table();
        row.target = string(target);
        row.predictors = string(predName);
        row.N = n;
        row.R2 = r2;
        row.slope_first = slope;
        row.intercept = intercept;
        row.status = "diagnostic_only";
        M = [M; row]; %#ok<AGROW>
    end

    function addMulti(target,predName,X)
        [r2,n,status] = multiR2(D.F_form,X);
        row = table();
        row.target = string(target);
        row.predictors = string(predName);
        row.N = n;
        row.R2 = r2;
        row.slope_first = NaN;
        row.intercept = NaN;
        row.status = status;
        M = [M; row]; %#ok<AGROW>
    end

    function addCaseDummy(target,predName,g)
        X = dummyMatrix(g);
        [r2,n,status] = multiR2(D.F_form,X);
        row = table();
        row.target = string(target);
        row.predictors = string(predName);
        row.N = n;
        row.R2 = r2;
        row.slope_first = NaN;
        row.intercept = NaN;
        row.status = status + "_diagnostic_only";
        M = [M; row]; %#ok<AGROW>
    end
end

function M = makePMModelTable(D)
M = table();
addSimple("PM_F1","F_form",D.F_form);
addSimple("PM_F1","z_DNB_L",D.z_DNB_L);
addSimple("PM_F1","z_DNB_DH",D.z_DNB_DH);
addSimple("PM_F1","L_DH",D.L_DH);
addMulti("PM_F1","F_form + z_DNB_L",[D.F_form, D.z_DNB_L]);
addMulti("PM_F1","F_form + z_DNB_DH",[D.F_form, D.z_DNB_DH]);
addMulti("PM_F1","F_form + L_DH",[D.F_form, D.L_DH]);
addMulti("PM_F1","F_form + z_DNB_L + L_DH",[D.F_form, D.z_DNB_L, D.L_DH]);

    function addSimple(target,predName,x)
        [r2,n,slope,intercept] = linR2(x,D.PM_F1);
        row = table();
        row.target = string(target);
        row.predictors = string(predName);
        row.N = n;
        row.R2 = r2;
        row.slope_first = slope;
        row.intercept = intercept;
        row.status = "diagnostic_only_not_formula";
        M = [M; row]; %#ok<AGROW>
    end

    function addMulti(target,predName,X)
        [r2,n,status] = multiR2(D.PM_F1,X);
        row = table();
        row.target = string(target);
        row.predictors = string(predName);
        row.N = n;
        row.R2 = r2;
        row.slope_first = NaN;
        row.intercept = NaN;
        row.status = status + "_diagnostic_only_not_formula";
        M = [M; row]; %#ok<AGROW>
    end
end

function C = makeConfounds(D)
pairs = {
    "F_form","z_DNB_L"
    "F_form","z_DNB_DH"
    "F_form","L_DH"
    "z_DNB_L","z_DNB_DH"
    "z_DNB_DH","L_DH"
    "z_DNB_L","L_DH"
    "F_form","q_exp"
    "F_form","q_calc_F1"
    "L_DH","q_exp"
    "L_DH","q_calc_F1"
};
C = table();
for i=1:size(pairs,1)
    xname = string(pairs{i,1});
    yname = string(pairs{i,2});
    [r2,n,slope,intercept] = linR2(D.(xname),D.(yname));
    row = table();
    row.x = xname;
    row.y = yname;
    row.N = n;
    row.R2 = r2;
    row.slope = slope;
    row.intercept = intercept;
    C = [C; row]; %#ok<AGROW>
end
end

function R = makeReadingFlags(caseSummary,pairContrasts,fformModels,pmModels,confounds)
item = strings(0,1); reading = strings(0,1); value = strings(0,1); implication = strings(0,1);

nearLarge = pairContrasts(pairContrasts.note=="near_DNB_position_but_large_Fform_difference",:);
add("near_position_large_Fform_difference", string(height(nearLarge)), "近いz_DNB/LでもF_formが大きく違うペア数。", ...
    "F_formはDNB位置だけでなく軸方向出力分布形状も強く含む可能性。");

r2_zL = getR2(fformModels,"F_form","z_DNB_L");
r2_LDH = getR2(fformModels,"F_form","L_DH");
r2_case = getR2(fformModels,"F_form","case_group_dummy");
add("Fform_vs_z_DNB_L_R2", sprintf("%.6g",r2_zL), "F_formをz_DNB/Lだけで説明したR2。", ...
    "低ければDNB相対位置だけではF_formを説明しにくい。");
add("Fform_vs_L_DH_R2", sprintf("%.6g",r2_LDH), "F_formとL/DHの対応。", ...
    "高ければケース構造との交絡が強い。");
add("Fform_vs_case_dummy_R2", sprintf("%.6g",r2_case), "F_formとcase_group dummyの対応。", ...
    "ケース別形状・DNB位置・L/DHの複合差を示す。");

r2_pm_fform = getR2(pmModels,"PM_F1","F_form");
r2_pm_z = getR2(pmModels,"PM_F1","z_DNB_DH");
r2_pm_L = getR2(pmModels,"PM_F1","L_DH");
add("PM_F1_vs_Fform_R2", sprintf("%.6g",r2_pm_fform), "PM_F1とF_formの対応。", ...
    "相関があってもF_form原因とは断定しない。");
add("PM_F1_vs_z_DNB_DH_R2", sprintf("%.6g",r2_pm_z), "PM_F1とz_DNB/DHの対応。", ...
    "DNB位置・履歴長側との対応。");
add("PM_F1_vs_L_DH_R2", sprintf("%.6g",r2_pm_L), "PM_F1とL/DHの対応。", ...
    "L/DHは診断項であり補正式候補ではない。");

r2_conf = getConfR2(confounds,"F_form","L_DH");
add("confound_Fform_LDH_R2", sprintf("%.6g",r2_conf), "F_formとL/DHの交絡。", ...
    "F_form原因説とL/DH原因説を分けにくい。");

R = table(item,value,reading,implication);

    function add(a,b,c,d)
        item(end+1,1)=string(a);
        value(end+1,1)=string(b);
        reading(end+1,1)=string(c);
        implication(end+1,1)=string(d);
    end
end

function r2 = getR2(T,target,predictors)
idx = T.target==string(target) & T.predictors==string(predictors);
if any(idx)
    r2 = T.R2(find(idx,1));
else
    r2 = NaN;
end
end

function r2 = getConfR2(T,x,y)
idx = T.x==string(x) & T.y==string(y);
if any(idx)
    r2 = T.R2(find(idx,1));
else
    r2 = NaN;
end
end

function X = dummyMatrix(g)
ug = unique(string(g),'stable');
n = numel(g);
if numel(ug) <= 1
    X = zeros(n,0);
    return;
end
X = zeros(n,numel(ug)-1);
for k=2:numel(ug)
    X(:,k-1) = double(string(g)==ug(k));
end
end

function [r2,n,status] = multiR2(y,X)
ok = isfinite(y);
for j=1:size(X,2)
    ok = ok & isfinite(X(:,j));
end
n = sum(ok);
p = size(X,2);
if n < p+2
    r2 = NaN; status = "too_few_rows"; return;
end
if p==0
    r2 = NaN; status = "no_predictor"; return;
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

function [v,okv] = finiteVector(v)
okv = isfinite(v);
v = v(okv);
end

function s = ok(tf)
if tf, s="OK"; else, s="CHECK"; end
end

function v = firstNum(T,cands)
v = NaN(height(T),1);
for c = string(cands)
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
