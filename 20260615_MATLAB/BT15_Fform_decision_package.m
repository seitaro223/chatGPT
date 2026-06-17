%% BT15_Fform_decision_package.m
% BT15：F_form正本化後の全体判断整理
%
% 位置づけ：
%   BT13-C：FformLinear_v1再計算済み正本入力で残差診断を再実行。
%   BT14-A：F_form・DNB位置・L/DHの挙動診断。
%   BT14-B2：BT13-B正本入力のF_formがBT08-A1d linear_v1と一致することを確認。
%
% 目的：
%   - F_form正本化後の判断を一つのrun_reportにまとめる。
%   - 今後使う正本入力、採用する判断、不採用にするもの、禁止する主張を固定する。
%   - 次フェーズへ進む前の判断ゲートにする。
%
% 入力：
%   H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_*.xlsx
%   run_report_BT13C_resid_diag_v2_*.md
%   run_report_BT14A_Fform_position_shape_diag_*.md
%   run_report_BT14B2_Fform_consistency_check_*.md
%
% 出力：
%   BT15_Fform_decision_package_yyyymmdd_HHMMSS.xlsx
%   run_report_BT15_Fform_decision_package_yyyymmdd_HHMMSS.md
%
% 注意：
%   - BT15でも補正式は作らない。
%   - F_formをPM_F1残差の原因とは断定しない。
%   - F1(Tsub)は維持する。
%   - legacy F_formは履歴・比較用に限定する。

clear; clc;

%% ===== Settings =====

currentInput = latestOrEmpty("H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_*.xlsx");

reportBT13C = latestOrEmpty("run_report_BT13C_resid_diag_v2_*.md");
reportBT14A = latestOrEmpty("run_report_BT14A_Fform_position_shape_diag_*.md");
reportBT14B2 = latestOrEmpty("run_report_BT14B2_Fform_consistency_check_*.md");
reportBT14B = latestOrEmpty("run_report_BT14B_Fform_reintegration_audit_closure_*.md");

ts = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "BT15_Fform_decision_package_" + ts + ".xlsx";
outMd = "run_report_BT15_Fform_decision_package_" + ts + ".md";

fprintf("current input : %s\n", currentInput);
fprintf("BT13-C report : %s\n", reportBT13C);
fprintf("BT14-A report : %s\n", reportBT14A);
fprintf("BT14-B2 report: %s\n", reportBT14B2);
fprintf("out Excel     : %s\n", outXlsx);
fprintf("out report    : %s\n", outMd);

%% ===== Fixed values and optional current input calculation =====

canonicalFform = makeCanonicalFformTable();

if strlength(currentInput)>0 && isfile(currentInput)
    currentRows = readCurrentRows(currentInput);
    bundleSummary = summarizeBundle(currentRows);
    caseSummary = summarizeCase(currentRows, canonicalFform);
else
    currentRows = table();
    bundleSummary = makeFixedBundleSummary();
    caseSummary = table();
end

decisionSummary = makeDecisionSummary();
evidenceSummary = makeEvidenceSummary();
adoptedFiles = makeAdoptedFiles(currentInput, reportBT13C, reportBT14A, reportBT14B2, reportBT14B);
notAdopted = makeNotAdopted();
doNotClaim = makeDoNotClaim();
nextActions = makeNextActions();
riskRegister = makeRiskRegister();
qc = makeQC(currentInput, reportBT13C, reportBT14A, reportBT14B2, currentRows, bundleSummary, caseSummary);

%% ===== Write Excel =====

if exist(outXlsx,"file"); delete(outXlsx); end

writetable(qc, outXlsx, 'Sheet', 'BT15_QC');
writetable(adoptedFiles, outXlsx, 'Sheet', 'adopted_files');
writetable(decisionSummary, outXlsx, 'Sheet', 'decision_summary');
writetable(evidenceSummary, outXlsx, 'Sheet', 'evidence_summary');
writetable(canonicalFform, outXlsx, 'Sheet', 'canonical_Fform_linear_v1');
writetable(bundleSummary, outXlsx, 'Sheet', 'bundle_summary');
writetable(caseSummary, outXlsx, 'Sheet', 'case_summary');
writetable(notAdopted, outXlsx, 'Sheet', 'not_adopted');
writetable(doNotClaim, outXlsx, 'Sheet', 'do_not_claim');
writetable(nextActions, outXlsx, 'Sheet', 'next_actions');
writetable(riskRegister, outXlsx, 'Sheet', 'risk_register');

if height(currentRows)>0
    writetable(currentRows, outXlsx, 'Sheet', 'current_rows');
end

%% ===== Markdown report =====

md = strings(0,1);

md(end+1) = "# BT15 F_form canonical decision package";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT15では、BT13-C、BT14-A、BT14-B2の結果を統合し、F_form正本化後の全体判断を整理する。";
md(end+1) = "これは補正式作成ではなく、次フェーズへ進む前の判断ゲートである。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- current input: `" + currentInput + "`";
md(end+1) = "- BT13-C report: `" + reportBT13C + "`";
md(end+1) = "- BT14-A report: `" + reportBT14A + "`";
md(end+1) = "- BT14-B2 report: `" + reportBT14B2 + "`";
md(end+1) = "- previous BT14-B report: `" + reportBT14B + "`";
md(end+1) = "";
md(end+1) = "## 3. 出力";
md(end+1) = "";
md(end+1) = "- output Excel: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 4. QC";
md(end+1) = "";
md(end+1) = tableToMarkdown(qc);
md(end+1) = "";
md(end+1) = "## 5. 採用ファイル";
md(end+1) = "";
md(end+1) = tableToMarkdown(adoptedFiles);
md(end+1) = "";
md(end+1) = "## 6. 判断サマリ";
md(end+1) = "";
md(end+1) = tableToMarkdown(decisionSummary);
md(end+1) = "";
md(end+1) = "## 7. 根拠サマリ";
md(end+1) = "";
md(end+1) = tableToMarkdown(evidenceSummary);
md(end+1) = "";
md(end+1) = "## 8. F_form linear_v1正本値";
md(end+1) = "";
md(end+1) = tableToMarkdown(canonicalFform);
md(end+1) = "";
md(end+1) = "## 9. Bundle summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(bundleSummary);
md(end+1) = "";
md(end+1) = "## 10. Case summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(caseSummary);
md(end+1) = "";
md(end+1) = "## 11. 不採用・旧扱い";
md(end+1) = "";
md(end+1) = tableToMarkdown(notAdopted);
md(end+1) = "";
md(end+1) = "## 12. まだ言ってはいけないこと";
md(end+1) = "";
md(end+1) = tableToMarkdown(doNotClaim);
md(end+1) = "";
md(end+1) = "## 13. リスク・保留事項";
md(end+1) = "";
md(end+1) = tableToMarkdown(riskRegister);
md(end+1) = "";
md(end+1) = "## 14. 次アクション";
md(end+1) = "";
md(end+1) = tableToMarkdown(nextActions);
md(end+1) = "";
md(end+1) = "## 15. 判断メモ";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "BT15で固定する判断：";
md(end+1) = "";
md(end+1) = "1. F_formはBT08-A1d linear_v1を正本とする。";
md(end+1) = "2. BT13-B正本入力のF_formはlinear_v1と一致している。";
md(end+1) = "3. legacy F_formは履歴・比較用であり、今後の解析入力には使わない。";
md(end+1) = "4. FformLinear_v1再計算後、BT13-Cでは108が過大側、161/164が過小側に残る。";
md(end+1) = "5. F1後残差はTsub/x_eq側ではなく、F_form・DNB位置・L/DH・ケース構造側に残る。";
md(end+1) = "6. ただし、F_form・DNB位置・L/DHは強く交絡する。";
md(end+1) = "7. F_formが原因であるとは断定しない。";
md(end+1) = "8. F_form補正式、DNB位置補正式、L/DH補正式は作らない。";
md(end+1) = "9. F1(Tsub)は維持し、F(x_eq)への置換にも進まない。";
md(end+1) = "10. 次は、全体判断を発表・内部説明に落とすか、ST-BT05等の保留課題へ移る。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 16. BT15の結論";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "BT15により、F_form正本化後の判断を整理した。";
md(end+1) = "";
md(end+1) = "今後のバンドル解析入力は、BT13-Bで作成した";
md(end+1) = "H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible を正本とする。";
md(end+1) = "";
md(end+1) = "F_formはlinear_v1で固定する。";
md(end+1) = "F1(Tsub)は維持する。";
md(end+1) = "追加補正式は作らない。";
md(end+1) = "";
md(end+1) = "108/161/164の残差は、補正式化ではなく、";
md(end+1) = "非一様加熱換算、DNB位置、L/DH、ケース構造、適用範囲の診断課題として残す。";
md(end+1) = "```";

fid = fopen(outMd,"w");
for i=1:numel(md)
    fprintf(fid,"%s\n",md(i));
end
fclose(fid);

disp("=== QC ===");
disp(qc);
disp("=== Decision summary ===");
disp(decisionSummary);
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

function T = makeCanonicalFformTable()
case_label = ["108_70in";"108_76in";"161_uniform";"164_112in";"164_134in_normal"];
Bundle = [108;108;161;164;164];
z_DNB_ratio = [0.729167;0.791667;0.997024;0.666667;0.797619];
f_DNB_linear = [1.5825311;1.3919731;1;1.2720999;0.8520446];
Blue_area_linear = [0.71522932;0.80849999;0.997024;0.74430116;0.88348441];
Orange_area_linear = [1.1539295;1.1019791;0.997024;0.84806699;0.67960696];
Fform_linear_v1 = [0.61982066;0.73367994;1;0.8776443;1.2999932];
definition_version = repmat("linear_v1",5,1);
definition_note = repmat("BT08-A1d正本：linear interpolation and linear integral",5,1);

T = table(definition_version,case_label,Bundle,z_DNB_ratio,f_DNB_linear, ...
    Blue_area_linear,Orange_area_linear,Fform_linear_v1,definition_note);
end

function rows = readCurrentRows(inputFile)
sheets = ["tm_108","tm_161","tm_164","tm_F1_108","tm_F1_161","tm_F1_164"];
rows = table();

for s = sheets'
    if ~any(string(sheetnames(inputFile))==s)
        continue;
    end
    T = readtable(inputFile,'Sheet',s,'VariableNamingRule','preserve');

    bundle = bundleOfSheet(s);
    kind = kindOfSheet(s);
    No = numCol(T,["No","NO","no"]);
    F_form = firstNum(T,["F_form","Fform","F_FORM"]);
    PM = firstNum(T,["PM_ratio","PM","P_M","P/M","PoverM"]);
    Tsub = firstNum(T,["Tsub","T_sub","DeltaTsub"]);
    Fcorr = firstNum(T,["Fcorr","F_corr","F1","F_1"]);
    x_eq = firstNum(T,["x_Mes","xMes","x_eq","xeq"]);
    z_DNB_L = firstOrCalc(T,["z_DNB_L","LDNB_L","L_DNB_L"],"zL");
    z_DNB_DH = firstOrCalc(T,["z_DNB_DH","LDNB_DH","L_DNB_DH"],"zDH");
    L_DH = firstOrCalc(T,["L_DH","LDH","L_over_DH"],"LDH");

    case_label = strings(height(T),1);
    for i=1:height(T)
        case_label(i) = caseLabel(bundle,No(i),z_DNB_L(i));
    end

    r = table();
    r.sheet = repmat(string(s),height(T),1);
    r.kind = repmat(kind,height(T),1);
    r.Bundle = repmat(bundle,height(T),1);
    r.No = No;
    r.case_label = case_label;
    r.PM = PM;
    r.F_form = F_form;
    r.Tsub = Tsub;
    r.Fcorr = Fcorr;
    r.x_eq = x_eq;
    r.z_DNB_L = z_DNB_L;
    r.z_DNB_DH = z_DNB_DH;
    r.L_DH = L_DH;
    rows = [rows; r]; %#ok<AGROW>
end
end

function S = summarizeBundle(rows)
if height(rows)==0
    S = makeFixedBundleSummary();
    return;
end

S = table();
for b = unique(rows.Bundle,'stable')'
    row = table();
    row.Bundle = b;
    row.N_total = sum(rows.Bundle==b);
    row.N_noF1 = sum(rows.Bundle==b & rows.kind=="noF1");
    row.N_F1 = sum(rows.Bundle==b & rows.kind=="F1");
    row.PM_noF1_mean = mean(rows.PM(rows.Bundle==b & rows.kind=="noF1"),'omitnan');
    row.PM_F1_mean = mean(rows.PM(rows.Bundle==b & rows.kind=="F1"),'omitnan');
    row.err_F1_mean = row.PM_F1_mean - 1;
    row.F_form_mean = mean(rows.F_form(rows.Bundle==b),'omitnan');
    row.Tsub_mean = mean(rows.Tsub(rows.Bundle==b),'omitnan');
    row.x_eq_mean = mean(rows.x_eq(rows.Bundle==b),'omitnan');
    row.z_DNB_L_mean = mean(rows.z_DNB_L(rows.Bundle==b),'omitnan');
    row.z_DNB_DH_mean = mean(rows.z_DNB_DH(rows.Bundle==b),'omitnan');
    row.L_DH_mean = mean(rows.L_DH(rows.Bundle==b),'omitnan');
    S = [S; row]; %#ok<AGROW>
end
end

function S = makeFixedBundleSummary()
Bundle = [108;161;164];
N_total = [28;46;42];
N_noF1 = [14;23;21];
N_F1 = [14;23;21];
PM_noF1_mean = [0.65304894;0.62098048;0.59786191];
PM_F1_mean = [1.1232232;0.90884087;0.93956052];
err_F1_mean = PM_F1_mean - 1;
F_form_mean = [0.63608627;1;1.2798813];
Tsub_mean = [46.083809;63.843926;54.954868];
x_eq_mean = [-0.013990909;-0.082322824;-0.15527776];
z_DNB_L_mean = [0.73821634;0.99707054;0.79142031];
z_DNB_DH_mean = [139.65871;361.35516;286.82405];
L_DH_mean = [189.18399;362.41684;362.41684];

S = table(Bundle,N_total,N_noF1,N_F1,PM_noF1_mean,PM_F1_mean,err_F1_mean, ...
    F_form_mean,Tsub_mean,x_eq_mean,z_DNB_L_mean,z_DNB_DH_mean,L_DH_mean);
end

function S = summarizeCase(rows,canonical)
S = table();
if height(rows)==0
    return;
end

for c = canonical.case_label'
    idx = rows.case_label==c;
    row = table();
    row.case_label = string(c);
    row.N_total = sum(idx);
    row.N_noF1 = sum(idx & rows.kind=="noF1");
    row.N_F1 = sum(idx & rows.kind=="F1");
    row.F_form_mean = mean(rows.F_form(idx),'omitnan');
    row.PM_noF1_mean = mean(rows.PM(idx & rows.kind=="noF1"),'omitnan');
    row.PM_F1_mean = mean(rows.PM(idx & rows.kind=="F1"),'omitnan');
    row.Tsub_mean = mean(rows.Tsub(idx),'omitnan');
    row.x_eq_mean = mean(rows.x_eq(idx),'omitnan');
    row.z_DNB_L_mean = mean(rows.z_DNB_L(idx),'omitnan');
    row.z_DNB_DH_mean = mean(rows.z_DNB_DH(idx),'omitnan');
    row.L_DH_mean = mean(rows.L_DH(idx),'omitnan');
    S = [S; row]; %#ok<AGROW>
end
end

function T = makeDecisionSummary()
item = strings(0,1);
decision = strings(0,1);
reason = strings(0,1);

add("F_form definition","adopt linear_v1","BT08-A1dで線形補間・線形積分として定義し、BT14-B2でcurrent input一致を確認。");
add("current bundle input","adopt BT13-B recalc tmCompatible v2","F_form/q_calc/PMがFformLinear_v1再計算後で整合。");
add("legacy F_form","trace only","履歴・比較用。今後の解析入力には使わない。");
add("BT13-C residual finding","adopt as diagnostic","108は過大側、161/164は過小側に残る。");
add("F1(Tsub)","keep","BT05でx_eqへの置換根拠が弱く、BT13-C後も置換しない。");
add("F(x_eq) replacement","not adopt","x_eqはTsubに対する追加説明力が小さい。");
add("F_form formula","do not create","F_formは原因ではなく、非一様加熱換算・DNB位置・ケース構造と交絡。");
add("DNB/L/DH formula","do not create","DNB位置、L/DHは診断軸であり、補正式にはしない。");
add("BT14","close","F_form定義・実装・current input反映の監査が完了。");

T = table(item,decision,reason);

    function add(a,b,c)
        item(end+1,1)=string(a);
        decision(end+1,1)=string(b);
        reason(end+1,1)=string(c);
    end
end

function T = makeEvidenceSummary()
source = strings(0,1);
finding = strings(0,1);
reading = strings(0,1);

add("BT13-C","PM_F1: 108=1.123, 161=0.909, 164=0.940","FformLinear_v1再計算後、108は過大側、161/164は過小側に残る。");
add("BT13-C","Tsub/x_eqではPM_F1残差をほとんど説明しない","F1後残差はTsub/x_eq側の問題として整理しにくい。");
add("BT13-C","F_form・z_DNB/DH・L/DHとPM_F1に対応あり","ただし強い交絡があり原因断定不可。");
add("BT14-A","F_form vs z_DNB/L R2が低い","F_formはDNB相対位置だけでは決まらない。");
add("BT14-A","108_76inと164_134inはz_DNB/Lが近いがF_formが大きく異なる","軸方向出力分布形状・L/DH・ケース構造を含む。");
add("BT14-B2","current_Fform_vs_linear_v1 OK","BT13-B正本入力のF_formはBT08-A1d linear_v1と一致。");
add("BT05","x_eq after Tsubの追加説明力は小さい","F1(Tsub)をF(x_eq)へ置換する根拠は弱い。");
add("単管T&M/BMI","L/D単独補正式は弱い","L/Dは履歴代理として保留するが補正式にはしない。");

T = table(source,finding,reading);

    function add(a,b,c)
        source(end+1,1)=string(a);
        finding(end+1,1)=string(b);
        reading(end+1,1)=string(c);
    end
end

function T = makeAdoptedFiles(currentInput,r13,r14a,r14b2,r14b)
role = ["current_bundle_input";"BT13-C report";"BT14-A report";"BT14-B2 report";"BT14-B report"];
file = [currentInput;r13;r14a;r14b2;r14b];
status = ["adopt";"adopt";"adopt";"adopt";"reference_unfinished"];
note = [
    "FformLinear_v1再計算済みtmCompatible正本入力"
    "正本入力での残差診断"
    "F_form挙動診断"
    "F_form実装照合完了"
    "current input未読のためBT14-B2で修正"
];
T = table(role,file,status,note);
end

function T = makeNotAdopted()
item = [
    "BT12-A full版"
    "BT12-B minimal版"
    "BT12-C F_form列だけ置換版"
    "BT13 初回残差診断"
    "legacy F_form"
    "F2/F1F2"
];
status = [
    "reference_only"
    "not_adopt"
    "not_adopt"
    "not_adopt_as_numeric_diagnostic"
    "trace_only"
    "exclude"
];
reason = [
    "F_form列置換のQC用。q_calc/PMはlegacyのまま。"
    "列を削りすぎた。"
    "tm互換だがF_formだけlinear、PM/q_calcがlegacy。"
    "不整合入力を読んでいた。"
    "旧定義であり、今後の解析入力に使わない。"
    "今回の比較対象外。"
];
T = table(item,status,reason);
end

function T = makeDoNotClaim()
claim = [
    "F_formがPM_F1残差の原因である"
    "DNB位置が原因である"
    "L/DHが原因である"
    "F_form補正式を作る"
    "DNB位置補正式を作る"
    "L/DH補正式を作る"
    "F1(Tsub)をF(x_eq)へ置換する"
    "BT14だけでF_formが最終物理説明変数である"
];
reason = [
    "F_form、DNB位置、L/DH、ケース構造が交絡。"
    "z_DNB/DHとL/DHが強く交絡。"
    "L/DHは便利な診断軸だが複合代理。"
    "補正式化する根拠はない。"
    "補正式化する根拠はない。"
    "単管側でもL/D単独補正式は弱い。"
    "x_eq追加説明力が小さい。"
    "F_formは換算係数であり原因とは限らない。"
];
T = table(claim,reason);
end

function T = makeNextActions()
task = [
    "BT15 log append"
    "BT16 or presentation package"
    "ST-BT05"
    "Source01原本確認"
    "Bundle additional cases"
];
priority = [
    "now"
    "next_candidate"
    "deferred"
    "deferred"
    "deferred"
];
purpose = [
    "BT15の判断をworking_logへ追記する。"
    "F_form正本化後の判断を内部説明・発表用に整理する。"
    "単管側でHsub/P/Tsub後のx_eq独立効果を確認する。"
    "Table9/10/11/12の装置・系列・表注が数値診断と矛盾しないか確認する。"
    "108/161/164以外にも同じ傾向があるか確認する。"
];
note = [
    "一タスク一run_reportの運用。"
    "補正式作成ではなく説明整理。"
    "保留課題。"
    "文献確認フェーズ。"
    "データ拡張時。"
];
T = table(task,priority,purpose,note);
end

function T = makeRiskRegister()
risk = [
    "F_form原因説への飛躍"
    "L/DH補正式への飛躍"
    "x_eq置換への飛躍"
    "BT13初回結果の混入"
    "legacy F_formの再利用"
    "3ケースでの一般化"
];
handling = [
    "原因とは言わず、診断項として扱う。"
    "L/DHは複合代理として扱う。"
    "F1(Tsub)維持を明記する。"
    "BT13は不整合入力として不採用にする。"
    "legacyは履歴・比較用に限定する。"
    "追加ケースまたは外部データ確認まで一般化しない。"
];
T = table(risk,handling);
end

function Q = makeQC(currentInput,r13,r14a,r14b2,currentRows,bundleSummary,caseSummary)
item = strings(0,1); status = strings(0,1); value = strings(0,1); reading = strings(0,1);

add("current_input_exists", ok(strlength(currentInput)>0 && isfile(currentInput)), currentInput, "BT13-B正本入力。");
add("BT13C_report_exists", ok(strlength(r13)>0 && isfile(r13)), r13, "正本入力での残差診断。");
add("BT14A_report_exists", ok(strlength(r14a)>0 && isfile(r14a)), r14a, "F_form挙動診断。");
add("BT14B2_report_exists", ok(strlength(r14b2)>0 && isfile(r14b2)), r14b2, "F_form実装照合。");

if height(currentRows)>0
    add("current_rows", ok(height(currentRows)==116), sprintf("%d",height(currentRows)), "noF1 58 + F1 58 が期待値。");
else
    add("current_rows", "info", "not_read_or_not_needed", "固定値summaryでレポート作成可能。");
end

if height(bundleSummary)>0
    add("bundle_summary_rows", ok(height(bundleSummary)==3), sprintf("%d",height(bundleSummary)), "108/161/164。");
end
if height(caseSummary)>0
    add("case_summary_rows", ok(height(caseSummary)==5), sprintf("%d",height(caseSummary)), "108_70/108_76/161/164_112/164_134。");
end

add("BT15_formula_policy","OK","no_new_formula","BT15でも補正式は作らない。");
add("BT15_F1_policy","OK","keep_F1_Tsub","F1(Tsub)を維持する。");
add("BT15_Fform_policy","OK","linear_v1","F_formはlinear_v1を正本とする。");

Q = table(item,status,value,reading);

    function add(a,b,c,d)
        item(end+1,1)=string(a);
        status(end+1,1)=string(b);
        value(end+1,1)=string(c);
        reading(end+1,1)=string(d);
    end
end

function b = bundleOfSheet(s)
s = string(s);
if contains(s,"108")
    b = 108;
elseif contains(s,"161")
    b = 161;
elseif contains(s,"164")
    b = 164;
else
    b = NaN;
end
end

function k = kindOfSheet(s)
if contains(lower(string(s)),"f1")
    k = "F1";
else
    k = "noF1";
end
end

function label = caseLabel(bundle,No,z)
if bundle==108
    if isfinite(No) && (round(No)==252 || round(No)==253)
        label = "108_76in";
    elseif isfinite(z) && z > 0.76
        label = "108_76in";
    else
        label = "108_70in";
    end
elseif bundle==161
    label = "161_uniform";
elseif bundle==164
    if isfinite(No) && round(No)==339
        label = "164_112in";
    elseif isfinite(z) && z < 0.73
        label = "164_112in";
    else
        label = "164_134in_normal";
    end
else
    label = "unknown";
end
end

function v = firstOrCalc(T,cands,calcKind)
v = firstNum(T,cands);
if any(isfinite(v)); return; end

L_DNB = firstNum(T,["L_DNB","LDNB","z_DNB","zDNB"]);
L = firstNum(T,["L","Length","HeatedLength"]);
DH = firstNum(T,["DH","D_h","Dh","HydraulicDiameter"]);

if calcKind=="zL" && any(isfinite(L_DNB)) && any(isfinite(L))
    v = L_DNB ./ L;
elseif calcKind=="zDH" && any(isfinite(L_DNB)) && any(isfinite(DH))
    v = L_DNB ./ DH;
elseif calcKind=="LDH" && any(isfinite(L)) && any(isfinite(DH))
    v = L ./ DH;
end
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
else
    v = str2double(string(raw));
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
