%% BT14B2_Fform_consistency_check.m
% BT14-B2：BT14-B修正版
%
% 目的：
%   BT14-Bでは、BT08-A1dのlinear_v1定義とBT13-B正本入力内F_formの照合を狙った。
%   しかし、current inputの読み込みが0行となり、照合が未完了だった。
%
%   BT14-B2では、以下を修正する。
%     - sheetnamesを出力して、実際のシート名を確認する。
%     - 対象シートの読み込み失敗を握りつぶさず、sheet_read_statusに残す。
%     - F_form照合はNoグループで判定する。
%     - 108_70in / 108_76in / 161_uniform / 164_112in / 164_134in_normal の
%       current F_form平均がBT08-A1d linear_v1正本値と一致するか確認する。
%
% 入力：
%   H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_*.xlsx
%
% 出力：
%   BT14B2_Fform_consistency_check_yyyymmdd_HHMMSS.xlsx
%   run_report_BT14B2_Fform_consistency_check_yyyymmdd_HHMMSS.md
%
% 注意：
%   - 新しいF_form定義は作らない。
%   - BT08-A1d linear_v1を正本とする。
%   - 補正式は作らない。

clear; clc;

%% ===== Settings =====

currentInput = "";
if strlength(currentInput)==0
    currentInput = latest("H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_*.xlsx");
end

bt08Report = latestOrEmpty("run_report_BT08A1d_Fform_linear_finalize_*.md");
bt14aReport = latestOrEmpty("run_report_BT14A_Fform_position_shape_diag_*.md");
bt14bReport = latestOrEmpty("run_report_BT14B_Fform_reintegration_audit_closure_*.md");

ts = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "BT14B2_Fform_consistency_check_" + ts + ".xlsx";
outMd   = "run_report_BT14B2_Fform_consistency_check_" + ts + ".md";

fprintf("current input : %s\n", currentInput);
fprintf("out Excel     : %s\n", outXlsx);
fprintf("out report    : %s\n", outMd);

%% ===== Canonical table =====

canonical = makeCanonicalFformTable();

%% ===== Read current input robustly =====

availableSheets = string(sheetnames(currentInput));
sheetInventory = table();
sheetInventory.sheet_index = (1:numel(availableSheets))';
sheetInventory.sheet_name = availableSheets(:);

[targetMap, mapStatus] = makeTargetSheetMap(availableSheets);

[currentRows, sheetReadStatus] = readCurrentRows(currentInput, targetMap);

currentCaseSummary = summarizeCurrentByCase(currentRows, canonical);
consistency = makeConsistencyCheck(canonical, currentCaseSummary);

nearPosition = makeNearPositionExamples(canonical, currentCaseSummary);
qc = makeQC(currentInput, bt08Report, bt14aReport, bt14bReport, currentRows, consistency, sheetReadStatus, mapStatus);
decisionFlags = makeDecisionFlags(consistency, currentRows, sheetReadStatus);

definition = makeDefinitionTable(bt08Report, bt14aReport, bt14bReport);

%% ===== Write Excel =====

if exist(outXlsx,"file"); delete(outXlsx); end

writetable(definition, outXlsx, 'Sheet', 'definition');
writetable(sheetInventory, outXlsx, 'Sheet', 'sheet_inventory');
writetable(mapStatus, outXlsx, 'Sheet', 'target_sheet_map');
writetable(sheetReadStatus, outXlsx, 'Sheet', 'sheet_read_status');
writetable(canonical, outXlsx, 'Sheet', 'canonical_Fform_linear_v1');
writetable(currentRows, outXlsx, 'Sheet', 'current_rows');
writetable(currentCaseSummary, outXlsx, 'Sheet', 'current_case_summary');
writetable(consistency, outXlsx, 'Sheet', 'consistency_check');
writetable(nearPosition, outXlsx, 'Sheet', 'near_position_examples');
writetable(qc, outXlsx, 'Sheet', 'BT14B2_QC');
writetable(decisionFlags, outXlsx, 'Sheet', 'decision_flags');

%% ===== Markdown report =====

md = strings(0,1);
md(end+1) = "# BT14-B2 F_form consistency check";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 目的";
md(end+1) = "";
md(end+1) = "BT14-Bでは、BT08-A1dのlinear_v1定義を正本として再利用し、BT13-B正本入力内F_formとの照合を行う予定だった。";
md(end+1) = "しかし、current inputの読み込みが0行となり、F_form照合が未完了だった。";
md(end+1) = "BT14-B2では、シート名確認と読み込み状態を明示し、current inputのF_formがBT08-A1d linear_v1と一致するかを再確認する。";
md(end+1) = "";
md(end+1) = "## 2. 入力";
md(end+1) = "";
md(end+1) = "- current input: `" + currentInput + "`";
md(end+1) = "- BT08-A1d report: `" + bt08Report + "`";
md(end+1) = "- BT14-A report: `" + bt14aReport + "`";
md(end+1) = "- previous BT14-B report: `" + bt14bReport + "`";
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
md(end+1) = "## 6. Sheet inventory";
md(end+1) = "";
md(end+1) = tableToMarkdown(sheetInventory);
md(end+1) = "";
md(end+1) = "## 7. Target sheet map";
md(end+1) = "";
md(end+1) = tableToMarkdown(mapStatus);
md(end+1) = "";
md(end+1) = "## 8. Sheet read status";
md(end+1) = "";
md(end+1) = tableToMarkdown(sheetReadStatus);
md(end+1) = "";
md(end+1) = "## 9. canonical F_form linear_v1";
md(end+1) = "";
md(end+1) = tableToMarkdown(canonical);
md(end+1) = "";
md(end+1) = "## 10. current input case summary";
md(end+1) = "";
md(end+1) = tableToMarkdown(currentCaseSummary);
md(end+1) = "";
md(end+1) = "## 11. consistency check";
md(end+1) = "";
md(end+1) = tableToMarkdown(consistency);
md(end+1) = "";
md(end+1) = "## 12. near-position examples";
md(end+1) = "";
md(end+1) = tableToMarkdown(nearPosition);
md(end+1) = "";
md(end+1) = "## 13. decision flags";
md(end+1) = "";
md(end+1) = tableToMarkdown(decisionFlags);
md(end+1) = "";
md(end+1) = "## 14. 判断メモ";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "BT14-B2は、BT14-Bで未完だったcurrent input照合をやり直す修正版である。";
md(end+1) = "BT08-A1d linear_v1をF_form正本とする。";
md(end+1) = "BT13-B正本入力のF_formがlinear_v1と一致すれば、F_form実装監査を閉じる。";
md(end+1) = "legacy F_formは履歴・比較用であり、今後の感度解析入力には使わない。";
md(end+1) = "F_form補正式、DNB位置補正式、L/DH補正式は作らない。";
md(end+1) = "```";
md(end+1) = "";
md(end+1) = "## 15. 次アクション";
md(end+1) = "";
md(end+1) = "```text";
md(end+1) = "BT14-B2結果を確認する。";
md(end+1) = "照合がOKならworking_logへ追記し、BT14を閉じる。";
md(end+1) = "照合がCHECKなら、sheet_read_statusまたはconsistency_checkに基づいて原因を修正する。";
md(end+1) = "```";

fid = fopen(outMd,"w");
for i=1:numel(md)
    fprintf(fid,"%s\n",md(i));
end
fclose(fid);

disp("=== QC ===");
disp(qc);
disp("=== consistency ===");
disp(consistency);

fprintf("Wrote %s\n", outXlsx);
fprintf("Wrote %s\n", outMd);

%% ===== functions =====

function f = latest(pattern)
d = dir(pattern);
if isempty(d)
    error("No file matching %s", pattern);
end
[~,i] = max([d.datenum]);
f = string(d(i).name);
end

function f = latestOrEmpty(pattern)
d = dir(pattern);
if isempty(d)
    f = "";
else
    [~,i] = max([d.datenum]);
    f = string(d(i).name);
end
end

function canonical = makeCanonicalFformTable()
definition_version = repmat("linear_v1",5,1);
case_label = ["108_70in";"108_76in";"161_uniform";"164_112in";"164_134in_normal"];
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
definition_note = repmat("BT08-A1d: linear interpolation and linear integral",5,1);

canonical = table(definition_version,case_label,Bundle,z_DNB_ratio,profile_sheet, ...
    f_DNB_linear,Blue_area_linear,Orange_area_linear,Fform_linear_v1, ...
    Fform_legacy_mean,diff_linear_minus_legacy,ratio_linear_to_legacy,definition_note);
end

function [targetMap,mapStatus] = makeTargetSheetMap(sheets)
targets = ["tm_108";"tm_161";"tm_164";"tm_F1_108";"tm_F1_161";"tm_F1_164"];
targetMap = table();
mapStatus = table();

for t = targets'
    exact = sheets(sheets==t);
    if ~isempty(exact)
        mapped = exact(1);
        status = "OK_exact";
    else
        mapped = discoverSheet(sheets,t);
        if strlength(mapped)>0
            status = "OK_discovered";
        else
            status = "CHECK_not_found";
        end
    end

    row = table();
    row.target_sheet = string(t);
    row.mapped_sheet = string(mapped);
    row.status = string(status);
    mapStatus = [mapStatus; row]; %#ok<AGROW>
end

targetMap = mapStatus(:,["target_sheet","mapped_sheet"]);
end

function mapped = discoverSheet(sheets,target)
t = lower(string(target));
wantF1 = contains(t,"f1");
bundle = "";
if contains(t,"108"), bundle="108";
elseif contains(t,"161"), bundle="161";
elseif contains(t,"164"), bundle="164";
end

mapped = "";
for s = sheets'
    ns = lower(string(s));
    hasBundle = contains(ns,bundle);
    hasF1 = contains(ns,"f1");
    if hasBundle && hasF1==wantF1
        mapped = s;
        return;
    end
end
end

function [rows,statusTable] = readCurrentRows(inputFile,targetMap)
rows = table();
statusTable = table();

for i=1:height(targetMap)
    target = string(targetMap.target_sheet(i));
    sheet = string(targetMap.mapped_sheet(i));

    rowStatus = table();
    rowStatus.target_sheet = target;
    rowStatus.mapped_sheet = sheet;

    if strlength(sheet)==0
        rowStatus.status = "CHECK_no_sheet";
        rowStatus.N_rows = 0;
        rowStatus.message = "mapped sheet is empty";
        statusTable = [statusTable; rowStatus]; %#ok<AGROW>
        continue;
    end

    try
        T = readtable(inputFile,'Sheet',sheet,'VariableNamingRule','preserve');
        r = extractRows(T,target,sheet);
        rows = [rows; r]; %#ok<AGROW>

        rowStatus.status = "OK_read";
        rowStatus.N_rows = height(T);
        rowStatus.message = "";
    catch ME
        rowStatus.status = "CHECK_read_failed";
        rowStatus.N_rows = 0;
        rowStatus.message = string(ME.message);
    end

    statusTable = [statusTable; rowStatus]; %#ok<AGROW>
end
end

function r = extractRows(T,target,sheet)
n = height(T);
kind = kindOfTarget(target);
bundle = bundleOfTarget(target);

No = numCol(T,["No","NO","no"]);
F_form = firstNum(T,["F_form","Fform","F_FORM"]);
PM = firstNum(T,["PM_ratio","PM","P_M","P/M","PoverM"]);
z_DNB_L = firstOrCalc(T,["z_DNB_L","LDNB_L","L_DNB_L"],"zL");
z_DNB_DH = firstOrCalc(T,["z_DNB_DH","LDNB_DH","L_DNB_DH"],"zDH");
L_DH = firstOrCalc(T,["L_DH","LDH","L_over_DH"],"LDH");

case_label = strings(n,1);
for j=1:n
    case_label(j) = caseLabel(bundle,No(j),z_DNB_L(j));
end

r = table();
r.target_sheet = repmat(string(target),n,1);
r.actual_sheet = repmat(string(sheet),n,1);
r.kind = repmat(kind,n,1);
r.Bundle = repmat(bundle,n,1);
r.No = No;
r.case_label = case_label;
r.F_form = F_form;
r.PM = PM;
r.z_DNB_L = z_DNB_L;
r.z_DNB_DH = z_DNB_DH;
r.L_DH = L_DH;
end

function k = kindOfTarget(target)
if contains(lower(string(target)),"f1")
    k = "F1";
else
    k = "noF1";
end
end

function b = bundleOfTarget(target)
s = string(target);
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

function S = summarizeCurrentByCase(rows,canonical)
S = table();
if height(rows)==0
    return;
end

for c = canonical.case_label'
    idx = rows.case_label == c;
    row = table();
    row.case_label = string(c);
    row.N = sum(idx);
    row.N_noF1 = sum(idx & rows.kind=="noF1");
    row.N_F1 = sum(idx & rows.kind=="F1");
    if any(idx)
        row.Bundle = mode(rows.Bundle(idx));
        row.Fform_current_mean = mean(rows.F_form(idx),'omitnan');
        row.Fform_current_sd = std(rows.F_form(idx),'omitnan');
        row.Fform_min = min(rows.F_form(idx),[],'omitnan');
        row.Fform_max = max(rows.F_form(idx),[],'omitnan');
        row.PM_F1_mean = mean(rows.PM(idx & rows.kind=="F1"),'omitnan');
        row.PM_noF1_mean = mean(rows.PM(idx & rows.kind=="noF1"),'omitnan');
        row.z_DNB_L_mean = mean(rows.z_DNB_L(idx),'omitnan');
        row.z_DNB_DH_mean = mean(rows.z_DNB_DH(idx),'omitnan');
        row.L_DH_mean = mean(rows.L_DH(idx),'omitnan');
    else
        row.Bundle = NaN;
        row.Fform_current_mean = NaN;
        row.Fform_current_sd = NaN;
        row.Fform_min = NaN;
        row.Fform_max = NaN;
        row.PM_F1_mean = NaN;
        row.PM_noF1_mean = NaN;
        row.z_DNB_L_mean = NaN;
        row.z_DNB_DH_mean = NaN;
        row.L_DH_mean = NaN;
    end
    S = [S; row]; %#ok<AGROW>
end
end

function C = makeConsistencyCheck(canonical,currentSummary)
C = table();
for i=1:height(canonical)
    row = table();
    row.case_label = canonical.case_label(i);
    row.Bundle = canonical.Bundle(i);
    row.Fform_linear_v1 = canonical.Fform_linear_v1(i);
    row.Fform_legacy_mean = canonical.Fform_legacy_mean(i);

    j = find(currentSummary.case_label==canonical.case_label(i),1);
    if isempty(j)
        row.Fform_current_mean = NaN;
        row.N_current = 0;
        row.diff_current_minus_linear_v1 = NaN;
        row.check_status = "CHECK_no_current_input_match";
    else
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

function N = makeNearPositionExamples(canonical,currentSummary)
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

function Q = makeQC(currentInput,bt08Report,bt14aReport,bt14bReport,currentRows,consistency,sheetReadStatus,mapStatus)
item = strings(0,1);
status = strings(0,1);
value = strings(0,1);
reading = strings(0,1);

add("current_input_exists", ok(isfile(currentInput)), currentInput, "BT13-B正本入力。");
add("BT08A1d_report_exists", ok(strlength(bt08Report)>0 && isfile(bt08Report)), bt08Report, "BT08-A1d再積分監査結果。");
add("BT14A_report_exists", ok(strlength(bt14aReport)>0 && isfile(bt14aReport)), bt14aReport, "BT14-A挙動診断結果。");
add("previous_BT14B_report_exists", ok(strlength(bt14bReport)>0 && isfile(bt14bReport)), bt14bReport, "BT14-B未完レポート。");

add("target_sheet_map", ok(all(startsWith(mapStatus.status,"OK"))), sprintf("%d/6",sum(startsWith(mapStatus.status,"OK"))), "対象6シートのマッピング。");
add("sheet_read", ok(all(sheetReadStatus.status=="OK_read")), sprintf("%d/6",sum(sheetReadStatus.status=="OK_read")), "対象6シートの読み込み。");
add("current_rows", ok(height(currentRows)==116), sprintf("%d",height(currentRows)), "noF1 58 + F1 58 = 116行が期待値。");

if height(consistency)>0 && any(isfinite(consistency.diff_current_minus_linear_v1))
    maxd = max(abs(consistency.diff_current_minus_linear_v1),[],'omitnan');
    allOK = all(startsWith(consistency.check_status,"OK"));
    add("current_Fform_vs_linear_v1", ok(allOK), sprintf("max_abs_delta=%.8g",maxd), "current inputのF_formがlinear_v1と一致するか。");
else
    add("current_Fform_vs_linear_v1", "CHECK", "not_checked", "照合できていない。");
end

add("definition_policy","OK","linear_v1","BT08-A1dで確定した定義を使う。");
add("legacy_policy","OK","legacy_trace_only","legacy F_formは履歴・比較用。");
add("formula_policy","OK","no_new_formula","BT14-B2でも補正式は作らない。");

Q = table(item,status,value,reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function D = makeDecisionFlags(consistency,currentRows,sheetReadStatus)
item = strings(0,1);
status = strings(0,1);
value = strings(0,1);
reading = strings(0,1);

add("Fform_definition","adopt","linear_v1","BT08-A1dの統一ルールを正本化する。");
add("Fform_reintegration_audit","adopt","reuse_BT08A1d","F_form再積分監査はBT08-A1dで実施済み。BT14-B2では照合を完了する。");

if height(currentRows)==116 && all(sheetReadStatus.status=="OK_read") && all(startsWith(consistency.check_status,"OK"))
    add("current_input_status","adopt","matches_linear_v1","BT13-B正本入力のF_formはlinear_v1と一致。");
    add("BT14_status","close_ready","Fform_audit_closed","BT14を閉じられる。");
else
    add("current_input_status","CHECK","not_ready","current input照合に未解決点あり。");
    add("BT14_status","CHECK","not_close_ready","BT14はまだ閉じない。");
end

add("legacy_policy","adopt","trace_only","legacy F_formは履歴・比較用であり、今後の解析入力には使わない。");
add("Fform_causal_claim","do_not_claim","not_cause_yet","F_formがPM_F1残差の原因とは断定しない。");
add("formula_policy","do_not_create","no_Fform_DNB_LDH_formula","F_form/DNB位置/L_DH補正式は作らない。");

D = table(item,status,value,reading);

    function add(a,b,c,d)
        item(end+1,1) = string(a);
        status(end+1,1) = string(b);
        value(end+1,1) = string(c);
        reading(end+1,1) = string(d);
    end
end

function T = makeDefinitionTable(bt08Report,bt14aReport,bt14bReport)
key = strings(0,1);
value = strings(0,1);
note = strings(0,1);

add("task","BT14-B2","BT14-Bのcurrent input未読問題の修正版");
add("definition_version","linear_v1","BT08-A1dで確定");
add("definition_formula","Blue_area_linear / Orange_area_linear","F_formはF1ではない");
add("x_DNB","DNB位置 / 加熱長","");
add("f_DNB","interp1(x,f,x_DNB)","");
add("Blue_area_linear","integral_0^x_DNB f(x) dx","");
add("Orange_area_linear","x_DNB * f_DNB","");
add("BT08A1d_report",bt08Report,"再積分監査元");
add("BT14A_report",bt14aReport,"挙動診断元");
add("BT14B_report",bt14bReport,"未完照合レポート");
add("policy","no_new_formula","補正式は作らない");

T = table(key,value,note);

    function add(a,b,c)
        key(end+1,1) = string(a);
        value(end+1,1) = string(b);
        note(end+1,1) = string(c);
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
