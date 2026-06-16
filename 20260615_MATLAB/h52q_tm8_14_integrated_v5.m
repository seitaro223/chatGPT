%% h52q_tm8_14_integrated_v5.m
% H52Q / T&M Table 8-14
% stagingブック内のSRCシート全体を読み、Table10を含めた統合診断を行う。
%
% 目的:
%   追加138行だけではなく、既存側に含まれるTable10を復帰させる。
%   Table 8-14全体を、pressure band / L-D band / Table別に再整理する。
%
% 入力:
%   20260612_計算結果比較r8_staging_TM8_14_v1.xlsx
%
% 出力:
%   out_TM8_14/TM8_14_integrated_v5_yyyymmdd_HHMMSS.xlsx

clear; clc; close all;

%% ===== 設定 =====
inFile = fullfile(pwd, "20260612_計算結果比較r8_staging_TM8_14_v1.xlsx");

sheetNoF1 = "SRC_tm_r123_noF1_T8_14";
sheetF1   = "SRC_tm_r124_F1_T8_14";

outDir = fullfile(pwd, "out_TM8_14");
if ~exist(outDir, "dir")
    mkdir(outDir);
end

timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outFile = fullfile(outDir, "TM8_14_integrated_v5_" + timestamp + ".xlsx");

fprintf("Input : %s\n", inFile);
fprintf("Output: %s\n\n", outFile);

%% ===== 読み込み =====
opts0 = detectImportOptions(inFile, "Sheet", sheetNoF1, "VariableNamingRule", "preserve");
opts1 = detectImportOptions(inFile, "Sheet", sheetF1,   "VariableNamingRule", "preserve");

T0raw = readtable(inFile, opts0);
T1raw = readtable(inFile, opts1);

%% ===== 標準化 =====
T0 = standardizeTmTable(T0raw, "noF1");
T1 = standardizeTmTable(T1raw, "F1");

% キーが空・TableNoが読めない行は除外
T0 = T0(~ismissing(T0.No_TableNo) & ~isnan(T0.TableNo), :);
T1 = T1(~ismissing(T1.No_TableNo) & ~isnan(T1.TableNo), :);

fprintf("Valid rows noF1 = %d\n", height(T0));
fprintf("Valid rows F1   = %d\n\n", height(T1));

%% ===== noF1/F1結合 =====
% 古いMATLABでは innerjoin の LeftSuffix / RightSuffix が使えないため、
% 事前に列名を変更してから結合する。

T0j = T0(:, ["No_TableNo", "source_row_in_tm", "data_origin", ...
             "TableNo", "P_Pa", "P_MPa", "G", "DH", "L", ...
             "LD_geom", "LD_band", "P_band", "Tin", "x_Mes", ...
             "qP", "PM"]);

T1j = T1(:, ["No_TableNo", "source_row_in_tm", "data_origin", ...
             "qP", "PM"]);

T0j.Properties.VariableNames = { ...
    'No_TableNo', ...
    'source_row_in_tm_noF1', ...
    'data_origin_noF1', ...
    'TableNo', ...
    'P_Pa', ...
    'P_MPa', ...
    'G', ...
    'DH', ...
    'L', ...
    'LD_geom', ...
    'LD_band', ...
    'P_band', ...
    'Tin', ...
    'x_Mes', ...
    'qP_noF1', ...
    'PM_noF1'};

T1j.Properties.VariableNames = { ...
    'No_TableNo', ...
    'source_row_in_tm_F1', ...
    'data_origin_F1', ...
    'qP_F1', ...
    'PM_F1'};

C = innerjoin(T0j, T1j, "Keys", "No_TableNo");

% 実験値 qM 復元：PM = qP / qM とみなす
C.qM_noF1 = C.qP_noF1 ./ C.PM_noF1;
C.qM_F1   = C.qP_F1   ./ C.PM_F1;
C.qM_mean = mean([C.qM_noF1, C.qM_F1], 2, "omitnan");
C.qM_MW_m2 = C.qM_mean / 1e6;

C.dPM = C.PM_F1 - C.PM_noF1;
C.dPM_percent = 100 * C.dPM ./ C.PM_noF1;
C.qP_ratio_F1_over_noF1 = C.qP_F1 ./ C.qP_noF1;

%% ===== 基本確認 =====
basic = table( ...
    ["valid_noF1"; "valid_F1"; "joined_rows"; "added_rows_in_join"; "existing_rows_in_join"; "Table10_rows_in_join"], ...
    [height(T0); height(T1); height(C); ...
     sum(C.data_origin_noF1 == "added_138"); ...
     sum(C.data_origin_noF1 == "existing_pre_add"); ...
     sum(C.TableNo == 10)], ...
    'VariableNames', ["Item", "Value"]);

%% ===== Table別・圧力帯別・L/D別 =====
tableList = unique(C.TableNo);
tableList = tableList(~isnan(tableList));
tableList = sort(tableList);

byTable = table();
for i = 1:numel(tableList)
    m = C.TableNo == tableList(i);
    byTable = [byTable; makeStats("Table", "T" + string(tableList(i)), C(m,:))]; %#ok<AGROW>
end

pBands = ["explore_low"; "main"; "high_check"; "outside_pressure"; "missing"];
byPband = table();
for i = 1:numel(pBands)
    m = C.P_band == pBands(i);
    if any(m)
        byPband = [byPband; makeStats("P_band", pBands(i), C(m,:))]; %#ok<AGROW>
    end
end

ldBands = ["outside_low"; "short_anchor"; "middle"; "long"; "outside_high"; "missing"];
byLD = table();
for i = 1:numel(ldBands)
    m = C.LD_band == ldBands(i);
    if any(m)
        byLD = [byLD; makeStats("LD_band", ldBands(i), C(m,:))]; %#ok<AGROW>
    end
end

byP_LD = table();
for i = 1:numel(pBands)
    for j = 1:numel(ldBands)
        m = C.P_band == pBands(i) & C.LD_band == ldBands(j);
        if any(m)
            byP_LD = [byP_LD; makeStats("P_LD", pBands(i) + "_" + ldBands(j), C(m,:))]; %#ok<AGROW>
        end
    end
end

byTable_LD = table();
for i = 1:numel(tableList)
    for j = 1:numel(ldBands)
        m = C.TableNo == tableList(i) & C.LD_band == ldBands(j);
        if any(m)
            byTable_LD = [byTable_LD; makeStats("Table_LD", "T" + string(tableList(i)) + "_" + ldBands(j), C(m,:))]; %#ok<AGROW>
        end
    end
end

%% ===== 注目抽出 =====
table10 = C(C.TableNo == 10, :);
table10 = sortrows(table10, ["P_MPa", "LD_geom", "Tin"]);

mainRows = C(C.P_band == "main", :);
mainRows = sortrows(mainRows, ["TableNo", "LD_geom", "Tin"]);

mainByTableLD = table();
mainTables = unique(mainRows.TableNo);
mainTables = sort(mainTables);
for i = 1:numel(mainTables)
    for j = 1:numel(ldBands)
        m = mainRows.TableNo == mainTables(i) & mainRows.LD_band == ldBands(j);
        if any(m)
            mainByTableLD = [mainByTableLD; makeStats("main_Table_LD", "T" + string(mainTables(i)) + "_" + ldBands(j), mainRows(m,:))]; %#ok<AGROW>
        end
    end
end

% Table14はhigh_checkとして隔離
highCheckRows = C(C.P_band == "high_check", :);
highCheckRows = sortrows(highCheckRows, ["TableNo", "LD_geom", "Tin"]);

% Table13はN=2候補として隔離
table13Rows = C(C.TableNo == 13, :);

%% ===== Excel出力 =====
writetable(basic, outFile, "Sheet", "basic");
writetable(byTable, outFile, "Sheet", "by_table");
writetable(byPband, outFile, "Sheet", "by_pressure_band");
writetable(byLD, outFile, "Sheet", "by_LD_band");
writetable(byP_LD, outFile, "Sheet", "by_pressure_LD");
writetable(byTable_LD, outFile, "Sheet", "by_table_LD");
writetable(table10, outFile, "Sheet", "Table10_rows");
writetable(mainRows, outFile, "Sheet", "main_rows_13_17p2MPa");
writetable(mainByTableLD, outFile, "Sheet", "main_by_table_LD");
writetable(highCheckRows, outFile, "Sheet", "high_check_rows");
writetable(table13Rows, outFile, "Sheet", "Table13_rows_N2");
writetable(C, outFile, "Sheet", "integrated_all");

%% ===== 図出力 =====

% PM vs L/D by pressure band
fig1 = figure;
hold on;
for i = 1:numel(pBands)
    m = C.P_band == pBands(i);
    if any(m)
        scatter(C.LD_geom(m), C.PM_F1(m), 36, "filled");
    end
end
grid on; box on;
xlabel("L/D");
ylabel("PM ratio F1");
title("Integrated: PM_F1 vs L/D by pressure band");
legend(pBands(arrayfun(@(i) any(C.P_band == pBands(i)), 1:numel(pBands))), "Location", "best");
exportgraphics(fig1, fullfile(outDir, "TM8_14_v5_PM_F1_vs_LD_byPband.png"), "Resolution", 200);

% PM vs Tin by pressure band
fig2 = figure;
hold on;
for i = 1:numel(pBands)
    m = C.P_band == pBands(i);
    if any(m)
        scatter(C.Tin(m), C.PM_F1(m), 36, "filled");
    end
end
grid on; box on;
xlabel("Tin [K]");
ylabel("PM ratio F1");
title("Integrated: PM_F1 vs Tin by pressure band");
legend(pBands(arrayfun(@(i) any(C.P_band == pBands(i)), 1:numel(pBands))), "Location", "best");
exportgraphics(fig2, fullfile(outDir, "TM8_14_v5_PM_F1_vs_Tin_byPband.png"), "Resolution", 200);

% main only: PM vs L/D
fig3 = figure;
scatter(mainRows.LD_geom, mainRows.PM_F1, 40, "filled");
grid on; box on;
xlabel("L/D");
ylabel("PM ratio F1");
title("Main pressure band only: PM_F1 vs L/D");
exportgraphics(fig3, fullfile(outDir, "TM8_14_v5_main_PM_F1_vs_LD.png"), "Resolution", 200);

% main only: PM vs Tin
fig4 = figure;
scatter(mainRows.Tin, mainRows.PM_F1, 40, "filled");
grid on; box on;
xlabel("Tin [K]");
ylabel("PM ratio F1");
title("Main pressure band only: PM_F1 vs Tin");
exportgraphics(fig4, fullfile(outDir, "TM8_14_v5_main_PM_F1_vs_Tin.png"), "Resolution", 200);

%% ===== 表示 =====
disp("=== basic ===");
disp(basic);

disp("=== by pressure band ===");
disp(byPband);

disp("=== by table ===");
disp(byTable);

disp("=== main by table/L-D ===");
disp(mainByTableLD);

fprintf("\nDone.\n");
fprintf("Excel output:\n  %s\n", outFile);
fprintf("PNG outputs are in:\n  %s\n", outDir);

%% ===== ローカル関数 =====

function T = standardizeTmTable(R, variant)
    key = string(getcol(R, ["No_TableNo", "No TableNo", "NoTableNo", "ExptNo_TableNo"]));

    P   = tonum(getcol(R, ["P"]));
    G   = tonum(getcol(R, ["G"]));
    DH  = tonum(getcol(R, ["DH", "D", "D_m"]));
    L   = tonum(getcol(R, ["L", "L_DNB"]));
    Tin = tonum(getcol(R, ["Tin"]));
    qP  = tonum(getcol(R, ["q_P", "qP"]));
    PM  = tonum(getcol(R, ["PM_ratio", "PM ratio", "PM"]));
    xMes = tonum(getcol(R, ["x_Mes", "x Mes", "xMes"]));

    n = height(R);

    T = table();
    T.No_TableNo = key;
    T.source_row_in_tm = (1:n)' + 1;  % Excel上のヘッダ1行を想定
    T.variant = repmat(string(variant), n, 1);

    T.TableNo = parseTableNo(key);
    T.P_Pa = P;
    T.P_MPa = P ./ 1e6;
    T.G = G;
    T.DH = DH;
    T.L = L;
    T.LD_geom = L ./ DH;
    T.LD_band = classifyLD(T.LD_geom);
    T.P_band = classifyPressure(T.P_MPa);
    T.Tin = Tin;
    T.x_Mes = xMes;
    T.qP = qP;
    T.PM = PM;

    T.data_origin = strings(n,1);
    T.data_origin(T.source_row_in_tm >= 88 & T.source_row_in_tm <= 225) = "added_138";
    T.data_origin(T.data_origin == "") = "existing_pre_add";
end

function v = getcol(T, candidates)
    vars = string(T.Properties.VariableNames);
    normVars = normalizeName(vars);

    for c = candidates
        idx = find(normVars == normalizeName(c), 1);
        if ~isempty(idx)
            v = T.(vars(idx));
            return;
        end
    end

    error("Required column not found. Candidates: %s\nAvailable columns:\n%s", ...
        strjoin(candidates, ", "), strjoin(vars, ", "));
end

function s = normalizeName(x)
    s = lower(string(x));
    s = regexprep(s, "[\s_()\-/\.]", "");
end

function x = tonum(v)
    if isnumeric(v)
        x = double(v);
    elseif iscell(v)
        x = str2double(string(v));
    elseif isstring(v) || ischar(v)
        x = str2double(string(v));
    else
        x = str2double(string(v));
    end
end

function tableNo = parseTableNo(key)
    tableNo = nan(size(key));
    for i = 1:numel(key)
        token = regexp(key(i), "_(\d+)$", "tokens", "once");
        if ~isempty(token)
            tableNo(i) = str2double(token{1});
        end
    end
end

function band = classifyLD(LD)
    band = strings(size(LD));

    band(LD < 40) = "outside_low";
    band(LD >= 40 & LD <= 100) = "short_anchor";
    band(LD > 100 & LD < 250) = "middle";
    band(LD >= 250 & LD <= 400) = "long";
    band(LD > 400) = "outside_high";

    band(isnan(LD)) = "missing";
end

function pband = classifyPressure(P_MPa)
    pband = strings(size(P_MPa));

    pband(P_MPa >= 10 & P_MPa < 13) = "explore_low";
    pband(P_MPa >= 13 & P_MPa <= 17.2) = "main";
    pband(P_MPa > 17.2 & P_MPa <= 20) = "high_check";
    pband((P_MPa < 10 | P_MPa > 20) & ~isnan(P_MPa)) = "outside_pressure";
    pband(isnan(P_MPa)) = "missing";
end

function S = makeStats(groupType, groupValue, X)
    S = table( ...
        string(groupType), string(groupValue), height(X), ...
        mean(X.PM_noF1, "omitnan"), median(X.PM_noF1, "omitnan"), std(X.PM_noF1, "omitnan"), ...
        mean(X.PM_F1, "omitnan"), median(X.PM_F1, "omitnan"), std(X.PM_F1, "omitnan"), ...
        mean(X.dPM_percent, "omitnan"), median(X.dPM_percent, "omitnan"), ...
        mean(X.LD_geom, "omitnan"), min(X.LD_geom, [], "omitnan"), max(X.LD_geom, [], "omitnan"), ...
        mean(X.Tin, "omitnan"), min(X.Tin, [], "omitnan"), max(X.Tin, [], "omitnan"), ...
        mean(X.x_Mes, "omitnan"), min(X.x_Mes, [], "omitnan"), max(X.x_Mes, [], "omitnan"), ...
        mean(X.qM_MW_m2, "omitnan"), min(X.qM_MW_m2, [], "omitnan"), max(X.qM_MW_m2, [], "omitnan"), ...
        mean(X.G, "omitnan"), min(X.G, [], "omitnan"), max(X.G, [], "omitnan"), ...
        mean(X.P_MPa, "omitnan"), min(X.P_MPa, [], "omitnan"), max(X.P_MPa, [], "omitnan"), ...
        'VariableNames', ["GroupType", "GroupValue", "N", ...
                          "Mean_PM_noF1", "Median_PM_noF1", "Std_PM_noF1", ...
                          "Mean_PM_F1", "Median_PM_F1", "Std_PM_F1", ...
                          "Mean_dPM_percent", "Median_dPM_percent", ...
                          "Mean_LD", "Min_LD", "Max_LD", ...
                          "Mean_Tin", "Min_Tin", "Max_Tin", ...
                          "Mean_xMes", "Min_xMes", "Max_xMes", ...
                          "Mean_qM_MW_m2", "Min_qM_MW_m2", "Max_qM_MW_m2", ...
                          "Mean_G", "Min_G", "Max_G", ...
                          "Mean_P_MPa", "Min_P_MPa", "Max_P_MPa"] ...
    );
end