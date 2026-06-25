%% BT01_bundle_108_161_164_MATLAB_repro.m
% BT01：バンドル108/161/164の正式再現診断
%
% 目的：
%   ChatGPT試作版BT01を、resultブックからMATLABで再現する。
%
% 重要：
%   - F2は使わない。
%   - F1F2は使わない。
%   - 比較対象は noF1 と F1 のみ。
%   - バンドルでは x_Mes 列に x_eq が直接入っているため、x_Mes = x_eq として扱う。
%   - 今回は補正式を作らない。BT02にも進まない。
%
% 実行方法：
%   この .m ファイルを resultブックと同じフォルダに置いて実行する。
%
% 入力ブック：
%   20260612_計算結果比較r8_result_文献追加用.xlsx
%
% 出力：
%   BT01_bundle_108_161_164_MATLAB_repro_yyyymmdd_HHMMSS.xlsx
%   run_report_BT01_bundle_108_161_164_MATLAB_repro_yyyymmdd_HHMMSS.md

clear; clc;

%% ===== Settings =====

inFile = "20260612_計算結果比較r8_result_文献追加用.xlsx";

timestamp = string(datetime("now","Format","yyyyMMdd_HHmmss"));
outXlsx = "BT01_bundle_108_161_164_MATLAB_repro_" + timestamp + ".xlsx";
outMd   = "run_report_BT01_bundle_108_161_164_MATLAB_repro_" + timestamp + ".md";

% noF1 と F1 のみ。F2/F1F2は明示的に対象外。
sheetMap = table( ...
    ["noF1"; "noF1"; "noF1"; "F1"; "F1"; "F1"], ...
    ["108";  "161";  "164";  "108"; "161"; "164"], ...
    ["tm_108"; "tm_161"; "tm_164"; "tm_F1_108"; "tm_F1_161"; "tm_F1_164"], ...
    'VariableNames', {'correction','case_id','sheet_name'} ...
);

%% ===== Read sheets =====

detail = table();

for i = 1:height(sheetMap)
    corr = sheetMap.correction(i);
    cid  = sheetMap.case_id(i);
    sh   = sheetMap.sheet_name(i);

    fprintf("Reading sheet: %s / %s / %s\n", corr, cid, sh);

    T = readSheetAsTable(inFile, sh);
    D = makeDetail(T, corr, cid, sh);
    detail = [detail; D]; %#ok<AGROW>
end

%% ===== Summary by case/correction =====

summary = table();

for corr = ["noF1","F1"]
    for cid = ["108","161","164"]
        S = detail(detail.correction == corr & detail.case_id == cid, :);

        row = table();
        row.correction = corr;
        row.case_id = cid;
        row.N = height(S);

        row.q_exp_MWm2_mean  = mean(S.q_exp_MWm2, 'omitnan');
        row.q_exp_MWm2_min   = min(S.q_exp_MWm2, [], 'omitnan');
        row.q_exp_MWm2_max   = max(S.q_exp_MWm2, [], 'omitnan');

        row.q_calc_MWm2_mean = mean(S.q_calc_MWm2, 'omitnan');
        row.q_calc_MWm2_min  = min(S.q_calc_MWm2, [], 'omitnan');
        row.q_calc_MWm2_max  = max(S.q_calc_MWm2, [], 'omitnan');

        row.PM_mean = mean(S.PM, 'omitnan');
        row.PM_min  = min(S.PM, [], 'omitnan');
        row.PM_max  = max(S.PM, [], 'omitnan');

        row.F_form_mean = mean(S.F_form, 'omitnan');
        row.Fcorr_mean  = mean(S.Fcorr, 'omitnan');

        row.P_MPa_mean = mean(S.P_MPa, 'omitnan');
        row.G_mean     = mean(S.G, 'omitnan');

        row.Tin_K_mean  = mean(S.Tin_K, 'omitnan');
        row.Tsat_K_mean = mean(S.Tsat_K, 'omitnan');
        row.Tsub_K_mean = mean(S.Tsub_K, 'omitnan');

        row.x_eq_mean = mean(S.x_eq, 'omitnan');
        row.x_eq_min  = min(S.x_eq, [], 'omitnan');
        row.x_eq_max  = max(S.x_eq, [], 'omitnan');

        row.DH_m_mean = mean(S.DH_m, 'omitnan');
        row.L_m_mean  = mean(S.L_m, 'omitnan');
        row.L_over_DH_mean = mean(S.L_over_DH, 'omitnan');

        row.z_DNB_m_mean = mean(S.z_DNB_m, 'omitnan');
        row.z_DNB_over_L_mean  = mean(S.z_DNB_over_L, 'omitnan');
        row.z_DNB_over_DH_mean = mean(S.z_DNB_over_DH, 'omitnan');

        row.Tm_K_mean = mean(S.Tm_K, 'omitnan');
        row.Tw_K_mean = mean(S.Tw_K, 'omitnan');
        row.Tw_minus_Tsat_K_mean = mean(S.Tw_minus_Tsat_K, 'omitnan');
        row.Tm_minus_Tsat_K_mean = mean(S.Tm_minus_Tsat_K, 'omitnan');

        row.DB_m_mean    = mean(S.DB_m, 'omitnan');
        row.delta_m_mean = mean(S.delta_m, 'omitnan');
        row.tauw_mean    = mean(S.tauw, 'omitnan');

        summary = [summary; row]; %#ok<AGROW>
    end
end

%% ===== Delta: 108 - mean(161,164) =====

delta = table();

metricList = [
    "q_exp_MWm2_mean"
    "q_calc_MWm2_mean"
    "PM_mean"
    "Tsub_K_mean"
    "x_eq_mean"
    "L_over_DH_mean"
    "z_DNB_over_L_mean"
    "z_DNB_over_DH_mean"
    "Tw_minus_Tsat_K_mean"
    "Tm_minus_Tsat_K_mean"
    "F_form_mean"
    "Fcorr_mean"
];

for corr = ["noF1","F1"]
    S108 = summary(summary.correction == corr & summary.case_id == "108", :);
    S161 = summary(summary.correction == corr & summary.case_id == "161", :);
    S164 = summary(summary.correction == corr & summary.case_id == "164", :);

    for k = 1:numel(metricList)
        m = metricList(k);

        v108 = S108.(m);
        v161164 = mean([S161.(m), S164.(m)], 'omitnan');

        row = table();
        row.correction = corr;
        row.metric = m;
        row.value_108 = v108;
        row.mean_161_164 = v161164;
        row.delta_108_minus_mean_161_164 = v108 - v161164;

        if isfinite(v161164) && abs(v161164) > 0
            row.ratio_108_over_mean_161_164 = v108 / v161164;
        else
            row.ratio_108_over_mean_161_164 = NaN;
        end

        delta = [delta; row]; %#ok<AGROW>
    end
end

%% ===== Definitions / notes =====

definitions = cell2table({
    "correction", "noF1 または F1。F2/F1F2は使わない。"
    "case_id", "バンドルケース番号。108, 161, 164。"
    "q_exp_MWm2", "実験CHF。q_M系の列をMW/m2に換算。"
    "q_calc_MWm2", "計算CHF。q_P系の列をMW/m2に換算。"
    "PM", "q_calc / q_exp として再計算。"
    "x_eq", "バンドルでは x_Mes 列に x_eq が直接入っているため、x_Mes=x_eq として扱う。"
    "z_DNB_over_DH", "DNB位置を水力等価直径で割った履歴長指標。"
    "z_DNB_over_L", "DNB位置を加熱長で割った相対位置。"
    "L_over_DH", "全加熱長を水力等価直径で割った値。"
    "F2", "使用しない。"
    "F1F2", "使用しない。"
}, 'VariableNames', {'name','definition'});

notes = cell2table({
    "目的", "BT01は108/161/164の横並び診断であり、補正式は作らない。"
    "位置づけ", "ChatGPT試作版BT01をMATLABで正式再現するためのrun。"
    "x_eq扱い", "バンドルではx_Mesをx_eqとして扱う。"
    "次段階", "BT02はBT01確認後に、x_eq・履歴長・PMの関係を深掘りする段階。"
    "禁止", "この結果だけでL/DH効果、F1置換、補正式係数を断定しない。"
}, 'VariableNames', {'item','note'});

%% ===== Write Excel =====

if exist(outXlsx, "file")
    delete(outXlsx);
end

writetable(summary,     outXlsx, 'Sheet', 'BT01_case_summary');
writetable(detail,      outXlsx, 'Sheet', 'BT01_point_detail');
writetable(delta,       outXlsx, 'Sheet', 'BT01_delta_108_vs_161164');
writetable(definitions, outXlsx, 'Sheet', 'BT01_definitions');
writetable(notes,       outXlsx, 'Sheet', 'BT01_notes');

fprintf("Wrote Excel: %s\n", outXlsx);

%% ===== Write Markdown report =====

md = strings(0,1);

md(end+1) = "# BT01 bundle 108/161/164 MATLAB reproduction";
md(end+1) = "";
md(end+1) = "作成日時: " + string(datetime("now"));
md(end+1) = "";
md(end+1) = "## 1. 入力と出力";
md(end+1) = "";
md(end+1) = "- 入力ブック: `" + inFile + "`";
md(end+1) = "- 出力Excel: `" + outXlsx + "`";
md(end+1) = "";
md(end+1) = "## 2. 前提";
md(end+1) = "";
md(end+1) = "- F2は使わない。";
md(end+1) = "- F1F2は使わない。";
md(end+1) = "- 比較対象は noF1 と F1 のみ。";
md(end+1) = "- バンドルでは `x_Mes` 列を `x_eq` として扱う。";
md(end+1) = "- 今回は補正式化しない。";
md(end+1) = "- 今回はBT01の正式再現であり、BT02の深掘りにはまだ進まない。";
md(end+1) = "";
md(end+1) = "## 3. 対象シート";
md(end+1) = "";
for i = 1:height(sheetMap)
    md(end+1) = "- " + sheetMap.correction(i) + " / " + sheetMap.case_id(i) + " : `" + sheetMap.sheet_name(i) + "`";
end
md(end+1) = "";
md(end+1) = "## 4. Case summary";
md(end+1) = "";
showCols = {'correction','case_id','N','q_exp_MWm2_mean','q_calc_MWm2_mean','PM_mean', ...
            'x_eq_mean','z_DNB_over_DH_mean','z_DNB_over_L_mean','L_over_DH_mean'};
md(end+1) = tableToMarkdown(summary(:, showCols));
md(end+1) = "";
md(end+1) = "## 5. 108 - mean(161,164)";
md(end+1) = "";
md(end+1) = tableToMarkdown(delta);
md(end+1) = "";
md(end+1) = "## 6. 現時点で言えることの確認観点";
md(end+1) = "";
md(end+1) = "- 108高・161/164低が、実験値だけでなく計算値にも出ているか。";
md(end+1) = "- noF1では全体に過小評価か。";
md(end+1) = "- F1後に108がほぼ合い、161/164が低めに残るか。";
md(end+1) = "- x_eq単独で大小関係が説明できるか。";
md(end+1) = "- DNB位置までの履歴長 z_DNB/DH が108と161/164で大きく違うか。";
md(end+1) = "";
md(end+1) = "## 7. まだ言ってはいけないこと";
md(end+1) = "";
md(end+1) = "- 108/161/164の差はL/DH効果である、と断定しない。";
md(end+1) = "- F1を置換すべき、と断定しない。";
md(end+1) = "- x_eqだけで整理できる、と断定しない。";
md(end+1) = "- DNB位置までの履歴長が原因である、と断定しない。";
md(end+1) = "- このBT01だけで補正式を作るとは言わない。";
md(end+1) = "";
md(end+1) = "## 8. 次アクション";
md(end+1) = "";
md(end+1) = "- このMATLAB版BT01とChatGPT試作版BT01が同じ傾向か確認する。";
md(end+1) = "- 確認後、BT02としてx_eq・DNB位置までの履歴長・PMの関係を深掘りする。";

fid = fopen(outMd, 'w');
for i = 1:numel(md)
    fprintf(fid, "%s\n", md(i));
end
fclose(fid);

fprintf("Wrote Markdown: %s\n", outMd);

%% ===== Display quick summary =====

disp("=== BT01 summary ===");
disp(summary(:, showCols));

disp("=== BT01 delta ===");
disp(delta);

%% ===== Local functions =====

function T = readSheetAsTable(inFile, sheetName)
    opts = detectImportOptions(inFile, 'Sheet', sheetName);
    opts.VariableNamingRule = 'preserve';
    T = readtable(inFile, opts);
end

function D = makeDetail(T, corr, cid, sh)

    n = height(T);

    qP = getNumCol(T, ["q_P","qP","q_calc","qCalc"]);
    qM = getNumCol(T, ["q_M","qM","q_exp","qExp"]);

    P = getNumCol(T, ["P"]);
    G = getNumCol(T, ["G"]);

    Tin  = getNumCol(T, ["Tin"]);
    Tsat = getNumCol(T, ["Ts","Tsat"]);
    Tsub = getNumCol(T, ["Tsub"]);

    xMes = getNumCol(T, ["x_Mes","xMes","x_EQ","xeq","x_eq"]);

    L_DNB = getNumCol(T, ["L_DNB","LDNB","z_DNB","zDNB"]);
    DH    = getNumCol(T, ["DH","D_h","Dh"]);
    L     = getNumCol(T, ["L","HeatedLength","L_heat"]);

    Tm = getNumCol(T, ["Tm"]);
    Tw = getNumCol(T, ["Tw"]);

    DB    = getNumCol(T, ["DB"]);
    delta = getNumCol(T, ["delta"]);
    tauw  = getNumCol(T, ["tauw","tau","Tau"]);

    F_form = getNumCol(T, ["F_form","F1"]);
    Fcorr  = getNumCol(T, ["Fcorr"]);

    No = getNumCol(T, ["No"]);
    No_TableNo = getTextCol(T, ["No_TableNo","Case","case"]);

    D = table();
    D.correction = repmat(string(corr), n, 1);
    D.case_id    = repmat(string(cid), n, 1);
    D.sheet_name = repmat(string(sh), n, 1);

    D.No_TableNo = No_TableNo;
    D.No = No;

    D.q_exp_Wm2 = qM;
    D.q_calc_Wm2 = qP;
    D.q_exp_MWm2 = qM ./ 1e6;
    D.q_calc_MWm2 = qP ./ 1e6;
    D.PM = qP ./ qM;

    D.P_Pa  = P;
    D.P_MPa = P ./ 1e6;
    D.G = G;

    D.Tin_K  = Tin;
    D.Tsat_K = Tsat;
    D.Tsub_K = Tsub;

    % バンドルでは x_Mes = x_eq
    D.x_eq = xMes;

    D.DH_m = DH;
    D.L_m = L;
    D.L_over_DH = L ./ DH;

    D.z_DNB_m = L_DNB;
    D.z_DNB_over_L  = L_DNB ./ L;
    D.z_DNB_over_DH = L_DNB ./ DH;

    D.Tm_K = Tm;
    D.Tw_K = Tw;
    D.Tw_minus_Tsat_K = Tw - Tsat;
    D.Tm_minus_Tsat_K = Tm - Tsat;

    D.DB_m    = DB;
    D.delta_m = delta;
    D.tauw    = tauw;

    D.F_form = F_form;
    D.Fcorr  = Fcorr;
end

function v = getNumCol(T, candidates)
    name = findColumn(T, candidates);
    if strlength(name) == 0
        v = NaN(height(T),1);
        return;
    end

    raw = T.(name);
    if isnumeric(raw)
        v = raw;
    elseif iscell(raw)
        v = str2double(string(raw));
    else
        v = str2double(string(raw));
    end

    v = double(v);
end

function v = getTextCol(T, candidates)
    name = findColumn(T, candidates);
    if strlength(name) == 0
        v = strings(height(T),1);
        return;
    end
    v = string(T.(name));
end

function name = findColumn(T, candidates)
    vars = string(T.Properties.VariableNames);

    for c = string(candidates)
        idx = find(vars == c, 1);
        if ~isempty(idx)
            name = vars(idx);
            return;
        end
    end

    normVars = normalizeNames(vars);
    for c = string(candidates)
        nc = normalizeNames(c);
        idx = find(normVars == nc, 1);
        if ~isempty(idx)
            name = vars(idx);
            return;
        end
    end

    name = "";
end

function s = normalizeNames(s)
    s = lower(string(s));
    s = regexprep(s, "[^a-z0-9]", "");
end

function md = tableToMarkdown(T)
    vars = string(T.Properties.VariableNames);

    lines = strings(0,1);
    lines(end+1) = "| " + strjoin(vars, " | ") + " |";
    lines(end+1) = "| " + strjoin(repmat("---", 1, numel(vars)), " | ") + " |";

    for i = 1:height(T)
        row = strings(1, numel(vars));
        for j = 1:numel(vars)
            val = T{i,j};

            if isnumeric(val)
                if isscalar(val)
                    row(j) = string(sprintf("%.6g", val));
                else
                    row(j) = "[array]";
                end
            elseif isstring(val)
                row(j) = val;
            elseif iscell(val)
                row(j) = string(val{1});
            else
                row(j) = string(val);
            end

            row(j) = replace(row(j), "|", "/");
            row(j) = replace(row(j), newline, " ");
        end
        lines(end+1) = "| " + strjoin(row, " | ") + " |";
    end

    md = strjoin(lines, newline);
end
