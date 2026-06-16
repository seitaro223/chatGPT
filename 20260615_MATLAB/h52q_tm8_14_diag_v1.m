%% h52q_tm8_14_diag_v1.m
% H52Q / Thompson & Macbeth Table 8-14
% stagingブックから追加138行を読み、MATLAB側で基本診断とF1差分確認を行う。
%
% 入力:
%   20260612_計算結果比較r8_staging_TM8_14_v1.xlsx
%
% 出力:
%   out_TM8_14/TM8_14_diag_output_yyyymmdd_HHMMSS.xlsx

clear; clc;

%% ===== 設定 =====
inFile = fullfile(pwd, "20260612_計算結果比較r8_staging_TM8_14_v1.xlsx");

sheetNoF1 = "STG_added138_noF1";
sheetF1   = "STG_added138_F1";

outDir = fullfile(pwd, "out_TM8_14");
if ~exist(outDir, "dir")
    mkdir(outDir);
end

timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outFile = fullfile(outDir, "TM8_14_diag_output_" + timestamp + ".xlsx");

fprintf("Input file:\n  %s\n", inFile);
fprintf("Output file:\n  %s\n\n", outFile);

%% ===== 読み込み =====
opts0 = detectImportOptions(inFile, "Sheet", sheetNoF1, "VariableNamingRule", "preserve");
opts1 = detectImportOptions(inFile, "Sheet", sheetF1,   "VariableNamingRule", "preserve");

T0 = readtable(inFile, opts0);
T1 = readtable(inFile, opts1);

fprintf("Rows noF1 = %d\n", height(T0));
fprintf("Rows F1   = %d\n\n", height(T1));

%% ===== 必須列取得 =====
key0 = string(getcol(T0, ["No_TableNo", "No TableNo", "NoTableNo"]));
key1 = string(getcol(T1, ["No_TableNo", "No TableNo", "NoTableNo"]));

P0   = tonum(getcol(T0, ["P"]));
G0   = tonum(getcol(T0, ["G"]));
DH0  = tonum(getcol(T0, ["DH"]));
L0   = tonum(getcol(T0, ["L"]));
Tin0 = tonum(getcol(T0, ["Tin"]));
qP0  = tonum(getcol(T0, ["q_P", "qP"]));
PM0  = tonum(getcol(T0, ["PM_ratio", "PM ratio", "PM"]));
x0   = tonum(getcol(T0, ["x_Mes", "x Mes", "xMes"]));

P1   = tonum(getcol(T1, ["P"]));
G1   = tonum(getcol(T1, ["G"]));
DH1  = tonum(getcol(T1, ["DH"]));
L1   = tonum(getcol(T1, ["L"]));
Tin1 = tonum(getcol(T1, ["Tin"]));
qP1  = tonum(getcol(T1, ["q_P", "qP"]));
PM1  = tonum(getcol(T1, ["PM_ratio", "PM ratio", "PM"]));
x1   = tonum(getcol(T1, ["x_Mes", "x Mes", "xMes"]));

%% ===== 基本診断 =====
tableNo0 = parseTableNo(key0);
tableNo1 = parseTableNo(key1);

LD0 = L0 ./ DH0;
LD1 = L1 ./ DH1;

band0 = classifyLD(LD0);
band1 = classifyLD(LD1);

sameKey = isequal(key0, key1);

nExpected = 138;
expectedTables = [8; 9; 11; 12; 13; 14];
expectedCounts = [16; 30; 30; 30; 2; 30];

basic = table( ...
    ["noF1_rows"; "F1_rows"; "expected_rows"; "noF1_rows_OK"; "F1_rows_OK"; "key_1to1_match"], ...
    [height(T0); height(T1); nExpected; height(T0)==nExpected; height(T1)==nExpected; sameKey], ...
    'VariableNames', ["Item", "Value"] ...
);

byTable = table(expectedTables, expectedCounts, ...
    countByValue(tableNo0, expectedTables), ...
    countByValue(tableNo1, expectedTables), ...
    'VariableNames', ["TableNo", "Expected", "Count_noF1", "Count_F1"] ...
);

ldBands = ["outside_low"; "short_anchor"; "middle"; "long"; "outside_high"];
byLD = table(ldBands, ...
    countByString(band0, ldBands), ...
    countByString(band1, ldBands), ...
    'VariableNames', ["LD_band", "Count_noF1", "Count_F1"] ...
);

checks = table( ...
    ["G_le_1000_noF1"; "G_le_1000_F1"; ...
     "Tin_missing_noF1"; "Tin_missing_F1"; ...
     "qP_bad_noF1"; "qP_bad_F1"; ...
     "PM_bad_noF1"; "PM_bad_F1"; ...
     "xMes_bad_noF1"; "xMes_bad_F1"], ...
    [sum(G0 <= 1000 | isnan(G0)); sum(G1 <= 1000 | isnan(G1)); ...
     sum(isbad(Tin0)); sum(isbad(Tin1)); ...
     sum(isbad(qP0)); sum(isbad(qP1)); ...
     sum(isbad(PM0)); sum(isbad(PM1)); ...
     sum(isbad(x0)); sum(isbad(x1))], ...
    'VariableNames', ["Check", "Count"] ...
);

%% ===== F1比較表 =====
F1cmp = table( ...
    key0, tableNo0, P0, G0, DH0, L0, LD0, band0, Tin0, x0, ...
    qP0, qP1, qP1 - qP0, qP1 ./ qP0, ...
    PM0, PM1, PM1 - PM0, 100*(PM1 - PM0)./PM0, ...
    'VariableNames', ["No_TableNo", "TableNo", "P_Pa", "G", "DH", "L", "LD_geom", "LD_band", "Tin", "x_Mes", ...
                      "qP_noF1", "qP_F1", "dqP_F1_minus_noF1", "qP_ratio_F1_over_noF1", ...
                      "PM_noF1", "PM_F1", "dPM_F1_minus_noF1", "dPM_percent"] ...
);

F1cmp_sorted = sortrows(F1cmp, "dPM_percent", "descend");

%% ===== 出力 =====
writetable(basic, outFile, "Sheet", "basic");
writetable(byTable, outFile, "Sheet", "by_table");
writetable(byLD, outFile, "Sheet", "by_LD");
writetable(checks, outFile, "Sheet", "checks");
writetable(F1cmp, outFile, "Sheet", "F1_compare_all");
writetable(F1cmp_sorted, outFile, "Sheet", "F1_compare_sorted");

%% ===== コマンドウィンドウ表示 =====
disp("=== Basic ===");
disp(basic);

disp("=== By Table ===");
disp(byTable);

disp("=== By L/D band ===");
disp(byLD);

disp("=== Checks ===");
disp(checks);

fprintf("\nDone.\nOutput written to:\n  %s\n", outFile);

%% ===== ローカル関数 =====

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

function tf = isbad(x)
    tf = isnan(x) | isinf(x);
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

function counts = countByValue(x, values)
    counts = zeros(numel(values), 1);
    for i = 1:numel(values)
        counts(i) = sum(x == values(i));
    end
end

function counts = countByString(x, values)
    counts = zeros(numel(values), 1);
    for i = 1:numel(values)
        counts(i) = sum(string(x) == string(values(i)));
    end
end