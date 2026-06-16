%% h52q_tm8_14_v7a_column_inventory.m
% H52Q / T&M Table 8-14
% v7a: Tsub/Hsub診断へ進む前に、staging workbook のSRCシートに
% Hsub / Tsub / Hin / Tsat 相当の列があるかを確認する。
%
% 入力:
%   20260612_計算結果比較r8_staging_TM8_14_v1.xlsx
%
% 出力:
%   out_TM8_14/TM8_14_v7a_column_inventory_yyyymmdd_HHMMSS.xlsx

clear; clc;

%% ===== 設定 =====
inFile = fullfile(pwd, "20260612_計算結果比較r8_staging_TM8_14_v1.xlsx");

sheets = [
    "SRC_tm_r123_noF1_T8_14"
    "SRC_tm_r124_F1_T8_14"
    "STG_added138_noF1"
    "STG_added138_F1"
];

outDir = fullfile(pwd, "out_TM8_14");
if ~exist(outDir, "dir")
    mkdir(outDir);
end

timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outFile = fullfile(outDir, "TM8_14_v7a_column_inventory_" + timestamp + ".xlsx");

fprintf("Input : %s\n", inFile);
fprintf("Output: %s\n\n", outFile);

%% ===== ブック内シート確認 =====
availableSheets = string(sheetnames(inFile));

sheetList = table(availableSheets, 'VariableNames', "SheetName");
writetable(sheetList, outFile, "Sheet", "workbook_sheets");

%% ===== 各シートの列一覧・候補列抽出 =====
allInventory = table();
allCandidates = table();
allSamples = table();

for s = sheets'
    sheet = string(s);

    if ~any(availableSheets == sheet)
        warning("Sheet not found: %s", sheet);
        continue;
    end

    opts = detectImportOptions(inFile, "Sheet", sheet, "VariableNamingRule", "preserve");
    T = readtable(inFile, opts);

    vars = string(T.Properties.VariableNames);
    nvar = numel(vars);

    inv = table();
    inv.SheetName = repmat(sheet, nvar, 1);
    inv.ColIndex = (1:nvar)';
    inv.VarName = vars(:);
    inv.NormalizedName = normalizeName(vars(:));
    inv.IsCandidate_Tsub_Hsub = isCandidate(vars(:));

    allInventory = [allInventory; inv]; %#ok<AGROW>

    candVars = vars(isCandidate(vars));
    if ~isempty(candVars)
        cand = table();
        cand.SheetName = repmat(sheet, numel(candVars), 1);
        cand.VarName = candVars(:);
        cand.NormalizedName = normalizeName(candVars(:));
        cand.MeanValue = nan(numel(candVars),1);
        cand.MinValue = nan(numel(candVars),1);
        cand.MaxValue = nan(numel(candVars),1);
        cand.NumMissing = nan(numel(candVars),1);

        for i = 1:numel(candVars)
            x = toNumSafe(T.(candVars(i)));
            cand.MeanValue(i) = mean(x, "omitnan");
            cand.MinValue(i) = min(x, [], "omitnan");
            cand.MaxValue(i) = max(x, [], "omitnan");
            cand.NumMissing(i) = sum(isnan(x));
        end

        allCandidates = [allCandidates; cand]; %#ok<AGROW>
    end

    % 主要列サンプル
    sample = makeSampleTable(T, sheet);
    allSamples = [allSamples; sample]; %#ok<AGROW>
end

%% ===== 推奨判断 =====
summaryText = strings(0,1);

hasHsub = any(contains(allCandidates.NormalizedName, ["hsub","subcoolingenthalpy","deltahsub","hfhin"]));
hasTsub = any(contains(allCandidates.NormalizedName, ["tsub","subcoolingtemperature","dtsub","deltatsub"]));
hasHin  = any(contains(allCandidates.NormalizedName, ["hin","hinlet","hinletenthalpy","inlethalpy"]));
hasTsat = any(contains(allCandidates.NormalizedName, ["tsat","saturationtemperature","ts"]));

summaryText(end+1) = "v7a判断メモ";
summaryText(end+1) = "目的：Tsub/Hsub正規化に進む前に、tm/stagingシートに必要列があるか確認する。";
summaryText(end+1) = "";
summaryText(end+1) = "Hsub候補あり: " + string(hasHsub);
summaryText(end+1) = "Tsub候補あり: " + string(hasTsub);
summaryText(end+1) = "Hin候補あり : " + string(hasHin);
summaryText(end+1) = "Tsat候補あり: " + string(hasTsat);
summaryText(end+1) = "";

if hasHsub
    summaryText(end+1) = "次段階：Hsub候補列を使ったPM残差診断を優先できる可能性あり。";
elseif hasTsub
    summaryText(end+1) = "次段階：Tsub候補列を使ったPM残差診断を優先できる可能性あり。";
elseif hasHin
    summaryText(end+1) = "次段階：Hin候補列があるため、hf(P)が得られればHsubを作れる可能性あり。";
else
    summaryText(end+1) = "次段階：Hsub/Tsub/Hin列が見つからない可能性あり。元の整形ブックまたはマクロ入力ブックからhSub列を取りに戻る必要がある。";
end

summary = table(summaryText, 'VariableNames', "Memo");

%% ===== 出力 =====
writetable(summary, outFile, "Sheet", "summary");
writetable(allInventory, outFile, "Sheet", "all_column_inventory");
writetable(allCandidates, outFile, "Sheet", "candidate_columns");
writetable(allSamples, outFile, "Sheet", "sample_values");

%% ===== 表示 =====
disp("=== summary ===");
disp(summary);

disp("=== candidate columns ===");
disp(allCandidates);

fprintf("\nDone.\n");
fprintf("Excel output:\n  %s\n", outFile);

%% ===== ローカル関数 =====

function n = normalizeName(x)
    n = lower(string(x));
    n = regexprep(n, "[\s_()\-/\.]", "");
end

function tf = isCandidate(varNames)
    n = normalizeName(varNames);

    patterns = [
        "hsub"
        "tsub"
        "subcool"
        "subcooling"
        "hin"
        "hinlet"
        "enthalpy"
        "hf"
        "sat"
        "tsat"
        "tin"
        "temperature"
        "temp"
    ];

    tf = false(size(n));
    for p = patterns'
        tf = tf | contains(n, p);
    end
end

function x = toNumSafe(v)
    if isnumeric(v)
        x = double(v);
    else
        x = str2double(string(v));
    end
end

function sample = makeSampleTable(T, sheet)
    vars = string(T.Properties.VariableNames);
    normVars = normalizeName(vars);

    targetPatterns = [
        "notableno"
        "p"
        "g"
        "dh"
        "l"
        "tin"
        "tsub"
        "hsub"
        "hin"
        "tsat"
        "q"
        "qp"
        "pm"
        "xmes"
    ];

    keep = false(size(vars));
    for p = targetPatterns'
        keep = keep | contains(normVars, p);
    end

    varsKeep = vars(keep);

    maxVars = min(numel(varsKeep), 40);
    varsKeep = varsKeep(1:maxVars);

    sample = table();
    if isempty(varsKeep)
        return;
    end

    nRows = min(height(T), 8);

    for i = 1:numel(varsKeep)
        vname = varsKeep(i);
        vals = strings(nRows,1);
        raw = T.(vname);

        for r = 1:nRows
            vals(r) = string(raw(r));
        end

        tmp = table();
        tmp.SheetName = repmat(sheet, nRows, 1);
        tmp.VarName = repmat(vname, nRows, 1);
        tmp.RowInReadTable = (1:nRows)';
        tmp.ValueText = vals;

        sample = [sample; tmp]; %#ok<AGROW>
    end
end