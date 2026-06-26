% TM03C_export_main280_input_xlsx.m
% Export the TM03C main280 injection payload as a plain .xlsx file.
%
% New TM03C workflow:
%   MATLAB does NOT edit the B2 robust xlsm and does NOT run Solver/VBA.
%   MATLAB only writes TM03C_main280_input_YYYYMMDD_HHMMSS.xlsx.
%   The companion VBA module TM03C_ImportMain280FromXlsx.bas imports that xlsx
%   into the B2 robust workbook's tm sheet rows 226:505.

clear; clc;

scriptDir = fileparts(mfilename('fullpath'));
if strlength(string(scriptDir)) == 0, scriptDir = pwd; end

previewFile = fullfile(scriptDir, 'tm_input_preview_20260625_083115.xlsx');
previewSheet = 'tm_input_preview';
flagsSheet = 'QA_flags';

startRow = 226;
expectedN = 280;
endRow = startRow + expectedN - 1; % 505
stamp = datestr(now, 'yyyymmdd_HHMMSS');
outXlsx = fullfile(scriptDir, sprintf('TM03C_main280_input_%s.xlsx', stamp));

if ~isfile(previewFile)
    error('Missing preview workbook: %s', previewFile);
end

raw = readtable(previewFile, 'Sheet', previewSheet, 'VariableNamingRule', 'preserve');
if height(raw) ~= expectedN
    error('Expected %d rows in %s, found %d.', expectedN, previewSheet, height(raw));
end

T = table();
T.target_row = (startRow:endRow)';
T.A_No_TableNo = firstText(raw, ["tmA_No_TableNo","No_TableNo"]);
T.B_P = firstNumeric(raw, ["tmB_P_Pa","B_P","P","P_Pa"]);
T.M_No = firstNumeric(raw, ["ExptNo","M_No","No"]);
T.N_G = firstNumeric(raw, ["tmN_G_kg_m2s","N_G","G","G_kg_m2s"]);
T.Q_DH = firstNumeric(raw, ["tmQ_DH_m","Q_DH","DH","D_H","Dh"]);
T.R_L_DNB = firstNumeric(raw, ["tmR_L_DNB_m","R_L_DNB","L_DNB","LDNB","z_DNB"]);
T.S_q_in_seed = firstNumeric(raw, ["tmBE_qM_W_m2","BE_q_M","q_M","qM","q_exp"]);
T.T_Tin = firstNumeric(raw, ["tmT_Tin_K","T_Tin","Tin","Tin_K"]);
T.V_f = repmat(0.03, expectedN, 1);
T.X_f_seed = repmat(0.01, expectedN, 1);
T.AC_Tw_seed = repmat(600, expectedN, 1);
T.AG_y_star_seed = repmat(1e-5, expectedN, 1);
T.AP_UB_seed = ones(expectedN, 1);
T.BE_q_M = T.S_q_in_seed;
T.BG_F_form = ones(expectedN, 1);
T.BH_x_Mes = firstNumeric(raw, ["tmBH_x_Mes","BH_x_Mes","x_Mes","x_report","x_eq"]);
T.BI_A_corr = repmat(0.046, expectedN, 1);
T.BJ_sigma_corr = repmat(5625, expectedN, 1);
T.BK_Fcorr = ones(expectedN, 1);
T.BQ_F2 = ones(expectedN, 1);
T.BR_L = firstNumeric(raw, ["tmBR_L_m","BR_L","L","Length"]);

Meta = table();
Meta.key = firstText(raw, ["key","tmA_No_TableNo","No_TableNo"]);
Meta.TableNo = firstNumeric(raw, ["TableNo","Table"]);
Meta.ExptNo = firstNumeric(raw, ["ExptNo","No"]);
Meta.bridge_group = optionalText(raw, ["bridge_group","bridge","source_class","new_overlap"], "unknown");
Meta.No_TableNo = T.A_No_TableNo;
Meta.target_row = T.target_row;

Batch = makeBatchPlan(Meta, readFlagsIfAvailable(previewFile, flagsSheet), startRow, endRow);
ColumnMapping = makeColumnMapping();
QA = makeQA(T, Meta, startRow, endRow);

writetable(T, outXlsx, 'Sheet', 'input');
writetable(Meta, outXlsx, 'Sheet', 'metadata');
writetable(ColumnMapping, outXlsx, 'Sheet', 'column_mapping');
writetable(Batch, outXlsx, 'Sheet', 'batch_plan');
writetable(groupcounts(Meta, 'TableNo'), outXlsx, 'Sheet', 'table_counts');
writetable(groupcounts(Meta, 'bridge_group'), outXlsx, 'Sheet', 'bridge_counts');
writetable(QA, outXlsx, 'Sheet', 'QA');

fprintf('Created TM03C main280 input xlsx: %s\n', outXlsx);
fprintf('Rows: %d-%d (%d points)\n', startRow, endRow, height(T));

function M = makeColumnMapping()
    M = table( ...
        ["A";"B";"M";"N";"Q";"R";"S";"T";"V";"X";"AC";"AG";"AP";"BE";"BG";"BH";"BI";"BJ";"BK";"BQ";"BR"], ...
        ["A_No_TableNo";"B_P";"M_No";"N_G";"Q_DH";"R_L_DNB";"S_q_in_seed";"T_Tin";"V_f";"X_f_seed";"AC_Tw_seed";"AG_y_star_seed";"AP_UB_seed";"BE_q_M";"BG_F_form";"BH_x_Mes";"BI_A_corr";"BJ_sigma_corr";"BK_Fcorr";"BQ_F2";"BR_L"], ...
        ["preview";"preview";"preview";"preview";"preview";"preview";"q_M initial";"preview";"fixed 0.03";"fixed 0.01";"fixed 600";"fixed 1e-5";"fixed 1";"preview q_M";"fixed 1";"preview";"fixed 0.046";"fixed 5625";"fixed 1";"fixed 1";"preview"], ...
        'VariableNames', {'tm_column','input_header','source'});
end

function QA = makeQA(T, Meta, startRow, endRow)
    check = [
        "280_points_exported"
        "No_TableNo_unique"
        "target_rows_226_to_505"
        "S_equals_BE_q_M"
        "fixed_V"
        "fixed_X"
        "fixed_AC"
        "fixed_AG"
        "fixed_AP_BG_BK_BQ"
        "fixed_BI_BJ"];
    pass = [
        height(T) == 280
        numel(unique(T.A_No_TableNo)) == height(T)
        min(T.target_row) == startRow && max(T.target_row) == endRow
        all(T.S_q_in_seed == T.BE_q_M)
        all(T.V_f == 0.03)
        all(T.X_f_seed == 0.01)
        all(T.AC_Tw_seed == 600)
        all(T.AG_y_star_seed == 1e-5)
        all(T.AP_UB_seed == 1 & T.BG_F_form == 1 & T.BK_Fcorr == 1 & T.BQ_F2 == 1)
        all(T.BI_A_corr == 0.046 & T.BJ_sigma_corr == 5625)];
    QA = table(check, pass, 'VariableNames', {'check','pass'});
    if all(Meta.bridge_group == "unknown")
        QA(end+1,:) = {"bridge_group_unavailable_warning", false};
    end
end

function B = makeBatchPlan(Meta, flags, startRow, endRow)
    batchStart = (startRow:50:endRow)';
    batchEnd = min(batchStart + 49, endRow);
    batch = (1:numel(batchStart))';
    N = batchEnd - batchStart + 1;
    TableNo_values = strings(numel(batch),1);
    bridge_counts = strings(numel(batch),1);
    FlagG_count = nan(numel(batch),1);
    for i = 1:numel(batch)
        ix = Meta.target_row >= batchStart(i) & Meta.target_row <= batchEnd(i);
        TableNo_values(i) = strjoin(string(unique(Meta.TableNo(ix)))', ',');
        G = groupcounts(Meta(ix,:), 'bridge_group');
        bridge_counts(i) = strjoin(string(G.bridge_group) + ":" + string(G.GroupCount), ', ');
        FlagG_count(i) = countFlagG(Meta(ix,:), flags);
    end
    B = table(batch, batchStart, batchEnd, N, TableNo_values, bridge_counts, FlagG_count, ...
        'VariableNames', {'batch','start_row','end_row','N','TableNo_values','bridge_counts','FlagG_count'});
end

function n = countFlagG(MetaBatch, flags)
    n = NaN;
    if height(flags) == 0, return; end
    vars = string(flags.Properties.VariableNames);
    keyIdx = find(ismember(normName(vars), normName(["key","No_TableNo"])), 1);
    flagIdx = find(ismember(normName(vars), normName(["flags","flag","Flag"])), 1);
    if isempty(keyIdx) || isempty(flagIdx), return; end
    keys = string(flags.(vars(keyIdx)));
    flagText = string(flags.(vars(flagIdx)));
    [tf, loc] = ismember(MetaBatch.key, keys);
    isG = false(height(MetaBatch), 1);
    isG(tf) = contains(flagText(loc(tf)), "G");
    n = sum(isG);
end

function F = readFlagsIfAvailable(file, sheet)
    try
        F = readtable(file, 'Sheet', sheet, 'VariableNamingRule', 'preserve');
    catch
        F = table();
    end
end

function v = firstNumeric(T, candidates)
    vars = string(T.Properties.VariableNames);
    idx = find(ismember(normName(vars), normName(candidates)), 1);
    if isempty(idx), error('Missing numeric column. Candidates: %s', strjoin(candidates, ', ')); end
    raw = T.(vars(idx));
    if isnumeric(raw), v = double(raw); else, v = str2double(string(raw)); end
end

function v = firstText(T, candidates)
    vars = string(T.Properties.VariableNames);
    idx = find(ismember(normName(vars), normName(candidates)), 1);
    if isempty(idx), error('Missing text column. Candidates: %s', strjoin(candidates, ', ')); end
    v = string(T.(vars(idx)));
end

function v = optionalText(T, candidates, defaultValue)
    vars = string(T.Properties.VariableNames);
    idx = find(ismember(normName(vars), normName(candidates)), 1);
    if isempty(idx), v = repmat(string(defaultValue), height(T), 1); else, v = string(T.(vars(idx))); end
end

function n = normName(s)
    n = lower(regexprep(string(s), '[^a-zA-Z0-9]', ''));
end
