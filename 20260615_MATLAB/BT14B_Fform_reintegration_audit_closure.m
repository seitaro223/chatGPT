%% BT14B_Fform_reintegration_audit_closure.m
% BT14-B：F_form再積分監査結果の再利用・正本化確認
%
% 位置づけ：
%   BT14-Aでは、current_bundle_inputだけでは軸方向出力分布の元配列がなく、
%   F_formの再積分監査ではなくF_form挙動診断であることを確認した。
%
%   ただし、F_formはこのチャット内のBT08-A1dで定義済みであり、
%   既に以下の統一ルールで再積分監査している。
%
%     x_DNB = DNB位置 / 加熱長
%     f_DNB = interp1(x, f, x_DNB)
%     Blue_area_linear = integral_0^x_DNB f(x) dx
%     Orange_area_linear = x_DNB * f_DNB
%     F_form_linear = Blue_area_linear / Orange_area_linear
%
%   BT14-Bでは、BT08-A1dの結果を正本監査結果として再利用し、
%   BT13-Bで作成した正本current_bundle_input_v2内のF_formが
%   そのlinear_v1値と整合しているか確認する。
%
% 入力：
%   H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_*.xlsx
%   run_report_BT08A1d_Fform_linear_finalize_*.md        （存在確認用）
%   run_report_BT14A_Fform_position_shape_diag_*.md      （存在確認用）
%
% 出力：
%   BT14B_Fform_reintegration_audit_closure_yyyymmdd_HHMMSS.xlsx
%   run_report_BT14B_Fform_reintegration_audit_closure_yyyymmdd_HHMMSS.md
%
% 注意：
%   - BT14-Bは新しい補正式を作らない。
%   - BT14-BはF_formを再定義しない。
%   - BT08-A1dのlinear_v1を正本定義として使う。
%   - 必要なら後でraw profileを再読込する再計算版を作るが、
%     現時点では過去出力とログを根拠に正本化確認を行う。

clear; clc;

%% ===== Settings =====

currentInput = "";
if strlength(currentInput)==0
    currentInput = latestOrEmpty("H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_*.xlsx");
end

bt08Report = latestOrEmpty("run_report_BT08A1d_Fform_linear_finalize_*.md");
bt14aReport = latestOrEmpty("run_report_BT14A_Fform_position_shape_diag_*.md");

ts = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "BT14B_Fform_reintegration_audit_closure_" + ts + ".xlsx";
outMd   = "run_report_BT14B_Fform_reintegration_audit_closure_" + ts + ".md";

fprintf("current input : %s\n", currentInput);
fprintf("BT08-A1d md   : %s\n", bt08Report);
fprintf("BT14-A md     : %s\n", bt14aReport);
fprintf("out Excel     : %s\n", outXlsx);
fprintf("out report    : %s\n", outMd);

%% ===== Canonical F_form linear_v1 from BT08-A1d =====

canonical = makeCanonicalFformTable();

%% ===== Optional current input check =====

if strlength(currentInput)>0 && isfile(currentInput)
    currentRows = readCurrentInputRows(currentInput);
    currentCaseSummary = summarizeCurrentByCase(currentRows, canonical);
    consistency = makeConsistencyCheck(canonical, currentCaseSummary);
else
    currentRows = table();
    currentCaseSummary = table();
    consistency = makeMissingCurrentConsistency(canonical);
end

%% ===== BT14-A connection =====

nearPosition = makeNearPositionExamples(canonical, currentCaseSummary);

definition = makeDefinitionTable(bt08Report, bt14aReport);
qc = makeQC(currentInput, bt08Report, bt14aReport, currentRows, consistency);

decisionFlags = makeDecisionFlags(consistency);

%% ===== Write Excel =====

if exist(outXlsx,"file"); delete(outXlsx); end

writetable(definition, outXlsx, 'Sheet', 'definition');
writetable(canonical, outXlsx, 'Sheet', 'canonical_Fform_linear_v1');
writetable(currentCaseSummary, outXlsx, 'Sheet', 'current_case_summary');
writetable(consistency, outXlsx, 'Sheet', 'consistency_check');
writetable(nearPosition, outXlsx, 'Sheet', 'near_position_examples');
writetable(qc, outXlsx, 'Sheet', 'BT14B_QC');
writetable(decisionFlags, outXlsx, 'Sheet', 'decision_flags');

if height(currentRows)>0
    writetable(currentRows, outXlsx, 'Sheet', 'current_rows');
end

%% ===== Markdown report =====

md = strings(0,1);
md(end+1) = "# BT14-B F_form reintegration audit closure";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT14-Aでは、current_bundle_inputだけでは軸方向出力分布元配列がなく、F_form再積分監査まではできないことを確認した。";
md(end+1) = "一方で、F_formは既にBT08-A1dでこのチャット内においてlinear_v1として定義・再積分監査済みである。";
md(end+1) = "BT14-Bでは、BT08-A1dの結果を正本監査結果として再利用し、BT13-B正本入力のF_formがlinear_v1値と整合しているかを確認する。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- current input: `" + currentInput + "`";
md(end+1) = "- BT08-A1d report: `" + bt08Report + "`";
md(end+1) = "- BT14-A report: `" + bt14aReport + "`";
md(end+1) = "";
md(end+1) = "## 3. 出力";
md(end+1) = "";
md(end+1) = "- output Excel: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 4. F_form linear_v1定義";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "x_DNB = DNB位置 / 加熱長";
md(end+1) = "f_DNB = interp1(x, f, x_DNB)";
md(end+1) = "Blue_area_linear = integral_0^x_DNB f(x) dx";
md(end+1) = "Orange_area_linear = x_DNB * f_DNB";
md(end+1) = "F_form_linear = Blue_area_linear / Orange_area_linear";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 5. QC";
md(end+1) = "";
md(end+1) = tableToMarkdown(qc);
md(end+1) = "";
md(end+1) = "## 6. canonical F_form linear_v1";
md(end+1) = "";
md(end+1) = tableToMarkdown(canonical);
md(end+1) = "";
md(end+1) = "## 7. current input case summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(currentCaseSummary);
md(end+1) = "";
md(end+1) = "## 8. consistency check";
md(end+1) = "";
md(end+1) = tableToMarkdown(consistency);
md(end+1) = "";
md(end+1) = "## 9. near-position examples";
md(end+1) = "";
md(end+1) = tableToMarkdown(nearPosition);
md(end+1) = "";
md(end+1) = "## 10. decision flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(decisionFlags);
md(end+1) = "";
md(end+1) = "## 11. 判断メモ";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "BT14-Bは、BT08-A1dの再積分監査結果を再利用する閉じ作業である。";
md(end+1) = "新しいF_form定義は作らない。";
md(end+1) = "F_formはlinear_v1を正本とする。";
md(end+1) = "legacy F_formは監査・履歴用として残すが、今後の感度解析入力には使わない。";
md(end+1) = "BT13-B正本入力のF_formがcanonical linear_v1と一致すれば、F_form実装監査は閉じられる。";
md(end+1) = "BT14-Aで見えたF_form挙動診断は、BT14-Bの定義監査とは別物として扱う。";
md(end+1) = "F_form補正式、DNB位置補正式、L/DH補正式は作らない。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 12. 次アクション";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "BT14-B結果を確認する。";
md(end+1) = "問題なければworking_logへ追記する。";
md(end+1) = "その後、BT14全体を閉じ、F_formはlinear_v1正本として今後の入力に固定する。";
md(end+1) = "次に進むなら、BT15としてF_form正本化後の全体判断または発表用整理へ進む。";
md(end+1) = "```";

fid = fopen(outMd,"w");
for i=1:numel(md)
    fprintf(fid,"%s\n",md(i));
end
fclose(fid);

disp("=== QC ===");
disp(qc);
disp("=== Consistency ===");
disp(consistency);

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
case_label = [
    "108_70in"
    "108_76in"
    "161_uniform"
    "164_112in"
    "164_134in_normal"
];
Bundle = [108;108;161;164;164];
z_DNB_ratio = [0.729167;0.791667;0.997024;0.666667;0.797619];
profile_sheet = [
    "非一様加熱を一様加熱に補正108"
    "非一様加熱を一様加熱に補正108"
    "非一様加熱を一様加熱に補正161"
    "非一様加熱を一様加熱に補正164"
    "非一様加熱を一様加熱に補正164"
];
f_DNB_linear = [1.5825311;1.3919731;1;1.2720999;0.8520446];
Blue_area_linear = [0.71522932;0.80849999;0.997024;0.74430116;0.88348441];
Orange_area_linear = [1.1539295;1.1019791;0.997024;0.84806699;0.67960696];
Fform_linear_v1 = [0.61982066;0.73367994;1;0.8776443;1.2999932];
Fform_legacy_mean = [0.65432795;0.760494;1;1.014;1.363];
diff_linear_minus_legacy = Fform_linear_v1 - Fform_legacy_mean;
ratio_linear_to_legacy = Fform_linear_v1 ./ Fform_legacy_mean;
definition_version = repmat("linear_v1",5,1);
definition_note = repmat("all cases use linear interpolation at x_DNB and linear integral from 0 to x_DNB",5,1);

T = table(definition_version,case_label,Bundle,z_DNB_ratio,profile_sheet, ...
    f_DNB_linear,Blue_area_linear,Orange_area_linear,Fform_linear_v1, ...
    Fform_legacy_mean,diff_linear_minus_legacy,ratio_linear_to_legacy,definition_note);
end

function T = makeDefinitionTable(bt08Report,bt14aReport)
key = strings(0,1);
value = strings(0,1);
note = strings(0,1);

add("task","BT14-B","F_form再積分監査結果の再利用・正本化確認");
add("definition_version","linear_v1","BT08-A1dで確定");
add("definition_formula","Blue_area_linear / Orange_area_linear","F_formはF1ではない");
add("x_DNB","DNB位置 / 加熱長","");
add("f_DNB","interp1(x,f,x_DNB)","");
add("Blue_area_linear","integral_0^x_DNB f(x) dx","");
add("Orange_area_linear","x_DNB * f_DNB","");
add("BT08A1d_report",bt08Report,"再積分監査元");
add("BT14A_report",bt14aReport,"挙動診断元");
add("policy","no_new_formula","補正式は作らない");

T = table(key,value,note);

    function add(a,b,c)
        key(end+1,1) = string(a);
        value(end+1,1) = string(b);
        note(end+1,1) = string(c);
    end
end

function rows = readCurrentInputRows(inputFile)
sheets = ["tm_108","tm_161","tm_164","tm_F1_108","tm_F1_161","tm_F1_164"];
rows = table();

for s = sheets'
    try
        T = readtable(inputFile, 'Sheet', s, 'VariableNamingRule','preserve');
    catch
        continue;
    end
    r = table();
    r.sheet = repmat(string(s),height(T),1);
    r.kind = repmat(kindOfSheet(s),height(T),1);
    r.Bundle = repmat(bundleOfSheet(s),height(T),1);
    r.No = numCol(T,["No","NO","no"]);
    r.F_form = firstNum(T,["F_form","Fform","F_FORM"]);
    r.z_DNB_L = firstOrCalc(T,["z_DNB_L","LDNB_L","L_DNB_L"],"zL");
    r.z_DNB_DH = firstOrCalc(T,["z_DNB_DH","LDNB_DH","L_DNB_DH"],"zDH");
    r.L_DH = firstOrCalc(T,["L_DH","LDH","L_over_DH"],"LDH");
    r.PM = firstNum(T,["PM_ratio","PM","P_M","P/M","PoverM"]);
    rows = [rows; r]; %#ok<AGROW>
end

rows.case_label = strings(height(rows),1);
for i=1:height(rows)
    rows.case_label(i) = caseLabel(rows.Bundle(i), rows.z_DNB_L(i), rows.No(i));
end
end

function S = summarizeCurrentByCase(rows, canonical)
if height(rows)==0
    S = table();
    return;
end

cases = canonical.case_label;
S = table();

for c = cases'
    idx = rows.case_label == c;
    if ~any(idx)
        row = emptyCaseRow(c);
    else
        row = table();
        row.case_label = c;
        row.N = sum(idx);
        row.N_noF1 = sum(idx & rows.kind=="noF1");
        row.N_F1 = sum(idx & rows.kind=="F1");
        row.Bundle = mode(rows.Bundle(idx));
        row.Fform_current_mean = mean(rows.F_form(idx),'omitnan');
        row.Fform_current_sd = std(rows.F_form(idx),'omitnan');
        row.z_DNB_L_mean = mean(rows.z_DNB_L(idx),'omitnan');
        row.z_DNB_DH_mean = mean(rows.z_DNB_DH(idx),'omitnan');
        row.L_DH_mean = mean(rows.L_DH(idx),'omitnan');
        row.PM_F1_mean = mean(rows.PM(idx & rows.kind=="F1"),'omitnan');
        row.PM_noF1_mean = mean(rows.PM(idx & rows.kind=="noF1"),'omitnan');
    end
    S = [S; row]; %#ok<AGROW>
end
end

function row = emptyCaseRow(c)
row = table();
row.case_label = string(c);
row.N = 0;
row.N_noF1 = 0;
row.N_F1 = 0;
row.Bundle = NaN;
row.Fform_current_mean = NaN;
row.Fform_current_sd = NaN;
row.z_DNB_L_mean = NaN;
row.z_DNB_DH_mean = NaN;
row.L_DH_mean = NaN;
row.PM_F1_mean = NaN;
row.PM_noF1_mean = NaN;
end

function C = makeConsistencyCheck(canonical,currentSummary)
C = table();

for i=1:height(canonical)
    row = table();
    row.case_label = canonical.case_label(i);
    row.Bundle = canonical.Bundle(i);
    row.Fform_linear_v1 = canonical.Fform_linear_v1(i);
    row.Fform_legacy_mean = canonical.Fform_legacy_mean(i);

    if height(currentSummary)==0 || ~any(currentSummary.case_label==canonical.case_label(i))
        row.Fform_current_mean = NaN;
        row.N_current = 0;
        row.diff_current_minus_linear_v1 = NaN;
        row.check_status = "CHECK_no_current_input_match";
    else
        j = find(currentSummary.case_label==canonical.case_label(i),1);
        row.Fform_current_mean = currentSummary.Fform_current_mean(j);
        row.N_current = currentSummary.N(j);
        row.diff_current_minus_linear_v1 = row.Fform_current_mean - row.Fform_linear_v1;

        if abs(row.diff_current_minus_linear_v1) < 1e-7
            row.check_status = "OK_current_matches_linear_v1";
        elseif abs(row.diff_current_minus_linear_v1) < 1e-4
            row.check_status = "OK_current_nearly_matches_linear_v1";
        else
            row.check_status = "CHECK_current_not_linear_v1";
        end
    end

    row.diff_linear_minus_legacy = canonical.diff_linear_minus_legacy(i);
    C = [C; row]; %#ok<AGROW>
end
end

function C = makeMissingCurrentConsistency(canonical)
C = table();
for i=1:height(canonical)
    row = table();
    row.case_label = canonical.case_label(i);
    row.Bundle = canonical.Bundle(i);
    row.Fform_linear_v1 = canonical.Fform_linear_v1(i);
    row.Fform_legacy_mean = canonical.Fform_legacy_mean(i);
    row.Fform_current_mean = NaN;
    row.N_current = 0;
    row.diff_current_minus_linear_v1 = NaN;
    row.check_status = "CHECK_current_input_missing";
    row.diff_linear_minus_legacy = canonical.diff_linear_minus_legacy(i);
    C = [C; row]; %#ok<AGROW>
end
end

function N = makeNearPositionExamples(canonical,currentSummary)
% Uses canonical linear_v1 and current summary where possible.
pairs = {
    "108_76in","164_134in_normal"
    "108_70in","164_134in_normal"
    "108_70in","164_112in"
};

N = table();
for i=1:size(pairs,1)
    a = string(pairs{i,1});
    b = string(pairs{i,2});
    ca = canonical(canonical.case_label==a,:);
    cb = canonical(canonical.case_label==b,:);

    row = table();
    row.case_a = a;
    row.case_b = b;
    row.delta_z_DNB_ratio = ca.z_DNB_ratio - cb.z_DNB_ratio;
    row.abs_delta_z_DNB_ratio = abs(row.delta_z_DNB_ratio);
    row.delta_Fform_linear_v1 = ca.Fform_linear_v1 - cb.Fform_linear_v1;
    row.abs_delta_Fform_linear_v1 = abs(row.delta_Fform_linear_v1);

    if height(currentSummary)>0 && any(currentSummary.case_label==a) && any(currentSummary.case_label==b)
        sa = currentSummary(currentSummary.case_label==a,:);
        sb = currentSummary(currentSummary.case_label==b,:);
        row.delta_PM_F1_current = sa.PM_F1_mean - sb.PM_F1_mean;
        row.delta_L_DH_current = sa.L_DH_mean - sb.L_DH_mean;
        row.current_note = "from_current_input";
    else
        row.delta_PM_F1_current = NaN;
        row.delta_L_DH_current = NaN;
        row.current_note = "current_input_not_available";
    end

    if row.abs_delta_z_DNB_ratio < 0.01 && row.abs_delta_Fform_linear_v1 > 0.3
        row.reading = "near_DNB_position_but_large_Fform_difference";
    elseif row.abs_delta_z_DNB_ratio < 0.08
        row.reading = "near_DNB_position";
    else
        row.reading = "general_pair";
    end
    N = [N; row]; %#ok<AGROW>
end
end

function Q = makeQC(currentInput,bt08Report,bt14aReport,currentRows,consistency)
item = strings(0,1);
status = strings(0,1);
value = strings(0,1);
reading = strings(0,1);

add("BT08A1d_report_exists", ok(strlength(bt08Report)>0 && isfile(bt08Report)), bt08Report, "BT08-A1dの再積分監査結果を正本として使う。");
add("BT14A_report_exists", ok(strlength(bt14aReport)>0 && isfile(bt14aReport)), bt14aReport, "BT14-Aの挙動診断結果。");
add("current_input_exists", ok(strlength(currentInput)>0 && isfile(currentInput)), currentInput, "BT13-Bで作成した正本入力。");

if height(currentRows)>0
    add("current_rows", ok(height(currentRows)==116), sprintf("%d",height(currentRows)), "noF1 58 + F1 58 = 116行が期待値。");
else
    add("current_rows", "CHECK", "0", "current inputを読めていない。");
end

if height(consistency)>0 && any(isfinite(consistency.diff_current_minus_linear_v1))
    maxd = max(abs(consistency.diff_current_minus_linear_v1),[],'omitnan');
    allOK = all(startsWith(consistency.check_status,"OK"));
    add("current_Fform_vs_linear_v1", ok(allOK), sprintf("max_abs_delta=%.8g",maxd), "current_inputのF_formがBT08-A1d linear_v1と一致するか。");
else
    add("current_Fform_vs_linear_v1", "CHECK", "not_checked", "current input未読のため照合不可。");
end

add("definition_policy", "OK", "linear_v1", "BT08-A1dで確定した定義を使う。");
add("legacy_policy", "OK", "legacy_trace_only", "legacy F_formは履歴・比較用。感度解析入力には使わない。");
add("formula_policy", "OK", "no_new_formula", "BT14-Bでも補正式は作らない。");

Q = table(item,status,value,reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function D = makeDecisionFlags(consistency)
item = strings(0,1);
status = strings(0,1);
value = strings(0,1);
reading = strings(0,1);

add("Fform_definition", "adopt", "linear_v1", "BT08-A1dの統一ルールを正本化する。");
add("Fform_reintegration_audit", "adopt", "reuse_BT08A1d", "F_form再積分監査はBT08-A1dで実施済み。BT14-Bでは再利用・照合する。");
add("manual_excel_policy", "adopt", "no_manual_excel_edit", "Excel手作業ではなくMATLAB出力とMarkdownログで固定する。");

if height(consistency)>0 && any(isfinite(consistency.diff_current_minus_linear_v1))
    maxd = max(abs(consistency.diff_current_minus_linear_v1),[],'omitnan');
    if maxd < 1e-7
        add("current_input_status", "adopt", "matches_linear_v1", "BT13-B正本入力のF_formはlinear_v1と一致。");
    else
        add("current_input_status", "CHECK", sprintf("max_abs_delta=%.8g",maxd), "BT13-B正本入力のF_formとlinear_v1に差あり。");
    end
else
    add("current_input_status", "CHECK", "not_checked", "current_inputが読めず照合未完。");
end

add("Fform_causal_claim", "do_not_claim", "not_cause_yet", "F_formがPM_F1残差の原因とは断定しない。");
add("next", "next", "close_BT14_or_prepare_BT15", "BT14-B確認後、F_form正本化を閉じる。");

D = table(item,status,value,reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function s = ok(tf)
if tf
    s = "OK";
else
    s = "CHECK";
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

function c = caseLabel(bundle,z,no)
if bundle==108
    if isfinite(z) && z > 0.76
        c = "108_76in";
    elseif isfinite(no) && (round(no)==252 || round(no)==253)
        c = "108_76in";
    else
        c = "108_70in";
    end
elseif bundle==161
    c = "161_uniform";
elseif bundle==164
    if isfinite(z) && z < 0.73
        c = "164_112in";
    elseif isfinite(no) && round(no)==339
        c = "164_112in";
    else
        c = "164_134in_normal";
    end
else
    c = "unknown";
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
