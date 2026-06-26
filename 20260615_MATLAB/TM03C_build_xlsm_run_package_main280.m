% TM03C_build_xlsm_run_package_main280.m
% Inject all tm_input_preview main280 rows into a B2 robust xlsm run package.
%
% Scope: prepare the workbook only.  Do NOT run VBA/Solver here.

clear; clc;

%% Configuration
scriptDir = fileparts(mfilename('fullpath'));
if strlength(string(scriptDir)) == 0, scriptDir = pwd; end

previewFile = fullfile(scriptDir, 'tm_input_preview_20260625_083115.xlsx');
preferredTemplate = fullfile(scriptDir, 'TM03_template_B2_robust.xlsm');
fallbackTemplate = fullfile(scriptDir, 'TM03B2_macro_bracket_test_20260625_235759_run_done.xlsm');
if isfile(preferredTemplate)
    templateFile = preferredTemplate;
else
    templateFile = fallbackTemplate;
end

previewSheet = 'tm_input_preview';
flagsSheet = 'QA_flags';
tmSheetName = 'tm';
tableName = 'テーブル2';
lastCol = 'BR';
formulaTemplateRow = 88;
startRow = 226;
expectedN = 280;
endRow = startRow + expectedN - 1; % 505

stamp = datestr(now, 'yyyymmdd_HHMMSS');
outXlsm = fullfile(scriptDir, sprintf('TM03C_B2robust_main280_injected_%s.xlsm', stamp));
qaXlsx = fullfile(scriptDir, sprintf('TM03C_B2robust_main280_injection_QA_%s.xlsx', stamp));
reportMd = fullfile(scriptDir, sprintf('run_report_TM03C_B2robust_main280_injection_%s.md', stamp));

%% Preconditions
mustExist(previewFile, 'tm_input_preview workbook');
mustExist(templateFile, 'B2 robust xlsm template');
if ~ispc
    error(['Excel COM requires Windows MATLAB with Excel installed. ', ...
        'Run this package builder on the Windows Excel/Solver machine.']);
end

%% Read main280 input in preview order
Tin = readMain280(previewFile, previewSheet);
if height(Tin) ~= expectedN
    error('Expected %d main280 rows in %s, found %d.', expectedN, previewSheet, height(Tin));
end
Tin.tm_row = (startRow:endRow)';
Tin = movevars(Tin, 'tm_row', 'Before', 1);
flags = readFlagsIfAvailable(previewFile, flagsSheet);

%% Copy template and inject with Excel COM
copyfile(templateFile, outXlsm, 'f');
excel = [];
wb = [];
warnings = strings(0,1);
listObjectNames = strings(0,1);
tableRangeAfter = "";
rowAfterA = "";
formulaSpotChecks = table();
try
    excel = actxserver('Excel.Application');
    excel.DisplayAlerts = false;
    excel.Visible = false;
    wb = excel.Workbooks.Open(outXlsm);
    ws = wb.Worksheets.Item(tmSheetName);

    src = ws.Range(sprintf('A%d:%s%d', formulaTemplateRow, lastCol, formulaTemplateRow));
    for r = startRow:endRow
        src.Copy(ws.Range(sprintf('A%d:%s%d', r, lastCol, r)));
    end
    excel.CutCopyMode = false;

    for i = 1:height(Tin)
        writeInputsToRow(ws, Tin.tm_row(i), Tin(i,:));
    end

    nListObjects = ws.ListObjects.Count;
    for k = 1:nListObjects
        listObjectNames(end+1,1) = string(ws.ListObjects.Item(k).Name); %#ok<SAGROW>
    end
    try
        lo = ws.ListObjects.Item(tableName);
        lo.Resize(ws.Range(sprintf('A1:%s%d', lastCol, endRow)));
        tableRangeAfter = string(lo.Range.Address(false, false));
    catch tableErr
        warnings(end+1,1) = "Could not resize ListObject '" + string(tableName) + "': " + string(tableErr.message); %#ok<SAGROW>
        warnings(end+1,1) = "Existing ListObjects: " + strjoin(listObjectNames, ", "); %#ok<SAGROW>
    end

    rowAfterA = string(ws.Range(sprintf('A%d', endRow + 1)).Text);
    formulaFormula = string(ws.Range(sprintf('C%d', startRow)).Formula);
    formulaSpotChecks = table(startRow, string(sprintf('C%d', startRow)), formulaFormula, ...
        'VariableNames', {'tm_row','cell','formula'});

    wb.SaveAs(outXlsm, 52); % xlOpenXMLWorkbookMacroEnabled
    wb.Close(false); wb = [];
    excel.Quit; excel = [];
catch ME
    if ~isempty(wb), try, wb.Close(false); catch, end, end %#ok<CTCH>
    if ~isempty(excel), try, excel.Quit; catch, end, end %#ok<CTCH>
    rethrow(ME);
end

%% QA workbook and report
QA = buildQa(Tin, flags, startRow, endRow, tableRangeAfter, listObjectNames, rowAfterA, ...
    formulaSpotChecks, previewFile, templateFile, outXlsm, warnings);
writeQaWorkbook(qaXlsx, QA);
writeReport(reportMd, QA, previewFile, templateFile, outXlsm, qaXlsx, startRow, endRow, formulaTemplateRow);

fprintf('Created main280 xlsm package: %s\n', outXlsm);
fprintf('Created QA workbook:        %s\n', qaXlsx);
fprintf('Created run report:         %s\n', reportMd);

%% Local functions
function mustExist(path, label)
    if ~isfile(path), error('Missing %s: %s', label, path); end
end

function T = readMain280(file, sheet)
    raw = readtable(file, 'Sheet', sheet, 'VariableNamingRule', 'preserve');
    T = table();
    T.No_TableNo = firstText(raw, ["tmA_No_TableNo","No_TableNo"]);
    T.TableNo = firstNumeric(raw, ["TableNo","Table","No_TableNo"]);
    T.ExptNo = firstNumeric(raw, ["ExptNo","No","M_No"]);
    T.P = firstNumeric(raw, ["tmB_P_Pa","B_P","P","P_Pa"]);
    T.No = T.ExptNo;
    T.G = firstNumeric(raw, ["tmN_G_kg_m2s","N_G","G","G_kg_m2s"]);
    T.DH = firstNumeric(raw, ["tmQ_DH_m","Q_DH","DH","D_H","Dh"]);
    T.L_DNB = firstNumeric(raw, ["tmR_L_DNB_m","R_L_DNB","L_DNB","LDNB","z_DNB"]);
    T.q_M = firstNumeric(raw, ["tmBE_qM_W_m2","BE_q_M","q_M","qM","q_exp"]);
    T.Tin = firstNumeric(raw, ["tmT_Tin_K","T_Tin","Tin","Tin_K"]);
    T.x_Mes = firstNumeric(raw, ["tmBH_x_Mes","BH_x_Mes","x_Mes","x_report","x_eq"]);
    T.L = firstNumeric(raw, ["tmBR_L_m","BR_L","L","Length"]);
    T.key = firstText(raw, ["key","No_TableNo","tmA_No_TableNo"]);
    T.bridge_group = optionalText(raw, ["bridge_group","bridge","source_class","new_overlap"], "unknown");
end

function F = readFlagsIfAvailable(file, sheet)
    try
        F = readtable(file, 'Sheet', sheet, 'VariableNamingRule', 'preserve');
    catch
        F = table();
    end
end

function writeInputsToRow(ws, r, row)
    setCell(ws, 'A', r, char(row.No_TableNo));
    setCell(ws, 'B', r, row.P);
    setCell(ws, 'M', r, row.No);
    setCell(ws, 'N', r, row.G);
    setCell(ws, 'Q', r, row.DH);
    setCell(ws, 'R', r, row.L_DNB);
    setCell(ws, 'S', r, row.q_M);
    setCell(ws, 'T', r, row.Tin);
    setCell(ws, 'V', r, 0.03);
    setCell(ws, 'X', r, 0.01);
    setCell(ws, 'AC', r, 600);
    setCell(ws, 'AG', r, 1e-5);
    setCell(ws, 'AP', r, 1);
    setCell(ws, 'BE', r, row.q_M);
    setCell(ws, 'BG', r, 1);
    setCell(ws, 'BH', r, row.x_Mes);
    setCell(ws, 'BI', r, 0.046);
    setCell(ws, 'BJ', r, 5625);
    setCell(ws, 'BK', r, 1);
    setCell(ws, 'BQ', r, 1);
    setCell(ws, 'BR', r, row.L);
end

function setCell(ws, col, r, val)
    c = ws.Range(sprintf('%s%d', col, r));
    if isnumeric(val) && (~isfinite(val) || isnan(val))
        c.Value = [];
    else
        c.Value = val;
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

function QA = buildQa(T, flags, startRow, endRow, tableRangeAfter, listObjectNames, rowAfterA, formulaSpotChecks, previewFile, templateFile, outXlsm, warnings)
    QA.injected_points = T(:, {'tm_row','No_TableNo','TableNo','ExptNo','key','bridge_group'});
    QA.input_values = T(:, {'tm_row','No_TableNo','P','No','G','DH','L_DNB','q_M','Tin','x_Mes','L'});
    QA.column_mapping = table( ...
        ["A";"B";"M";"N";"Q";"R";"S";"T";"V";"X";"AC";"AG";"AP";"BE";"BG";"BH";"BI";"BJ";"BK";"BQ";"BR"], ...
        ["No_TableNo";"P";"No";"G";"DH";"L_DNB";"q_in initial";"Tin";"f initial";"f_balance seed";"Tw initial";"y_star initial";"UB initial";"q_M";"F_form";"x_Mes";"A_corr";"sigma_corr";"Fcorr";"F2";"L"], ...
        ["preview";"preview";"preview ExptNo";"preview";"preview";"preview";"q_M";"preview";"fixed 0.03";"fixed 0.01";"fixed 600";"fixed 1e-5";"fixed 1";"preview";"fixed 1";"preview";"fixed 0.046";"fixed 5625";"fixed 1";"fixed 1";"preview"], ...
        'VariableNames', {'tm_column','field','source'});
    QA.table_resize_info = table("テーブル2", "A1:BR" + string(endRow), tableRangeAfter, strjoin(listObjectNames, ", "), rowAfterA, ...
        'VariableNames', {'requested_table','expected_range','actual_range','list_objects','A_after_end_row'});
    QA.batch_plan = makeBatchPlan(T, flags, startRow, endRow);
    QA.table_counts = groupcounts(T, 'TableNo');
    QA.bridge_counts = groupcounts(T, 'bridge_group');
    QA.formula_spot_checks = formulaSpotChecks;
    QA.input_files = table(string(previewFile), string(templateFile), string(outXlsm), ...
        'VariableNames', {'preview_file','template_xlsm','output_xlsm'});
    check = [
        "280_points_injected"
        "No_TableNo_unique"
        "rows_226_to_505"
        "table_range_A1_BR505"
        "row_506_not_newly_injected"
        "S_equals_q_M_initial_by_construction"
        "fixed_constants_by_construction"];
    pass = [
        height(T) == 280
        numel(unique(T.No_TableNo)) == height(T)
        min(T.tm_row) == startRow && max(T.tm_row) == endRow
        tableRangeAfter == "A1:BR" + string(endRow)
        strlength(rowAfterA) == 0
        true
        true];
    QA.qa_checks = table(check, pass, 'VariableNames', {'check','pass'});
    if height(flags) == 0
        warnings(end+1,1) = "QA_flags sheet could not be read; batch Flag=G counts set to NaN."; %#ok<AGROW>
    end
    if all(T.bridge_group == "unknown")
        warnings(end+1,1) = "No bridge/new_only/overlap column found in tm_input_preview; bridge_counts reports unknown."; %#ok<AGROW>
    end
    if isempty(warnings), warnings = "none"; end
    QA.warnings = table(warnings(:), 'VariableNames', {'warning'});
end

function B = makeBatchPlan(T, flags, startRow, endRow)
    batchStart = (startRow:50:endRow)';
    batchEnd = min(batchStart + 49, endRow);
    batchNo = (1:numel(batchStart))';
    N = batchEnd - batchStart + 1;
    tableNos = strings(numel(batchNo),1);
    bridgeSummary = strings(numel(batchNo),1);
    flagG_count = nan(numel(batchNo),1);
    for i = 1:numel(batchNo)
        ix = T.tm_row >= batchStart(i) & T.tm_row <= batchEnd(i);
        tableNos(i) = strjoin(string(unique(T.TableNo(ix)))', ',');
        G = groupcounts(T(ix,:), 'bridge_group');
        bridgeSummary(i) = strjoin(string(G.bridge_group) + ":" + string(G.GroupCount), ', ');
        flagG_count(i) = countFlagG(T(ix,:), flags);
    end
    B = table(batchNo, batchStart, batchEnd, N, tableNos, bridgeSummary, flagG_count, ...
        'VariableNames', {'batch','start_row','end_row','N','TableNo_values','bridge_counts','FlagG_count'});
end

function n = countFlagG(Tbatch, flags)
    n = NaN;
    if height(flags) == 0, return; end
    vars = string(flags.Properties.VariableNames);
    keyIdx = find(ismember(normName(vars), normName(["key","No_TableNo"])), 1);
    flagIdx = find(ismember(normName(vars), normName(["flags","flag","Flag"])), 1);
    if isempty(keyIdx) || isempty(flagIdx), return; end
    keys = string(flags.(vars(keyIdx)));
    flagText = string(flags.(vars(flagIdx)));
    [tf, loc] = ismember(Tbatch.key, keys);
    n = sum(tf & contains(flagText(loc(tf)), "G"));
end

function writeQaWorkbook(file, QA)
    names = fieldnames(QA);
    for i = 1:numel(names)
        writetable(QA.(names{i}), file, 'Sheet', names{i});
    end
end

function writeReport(file, QA, previewFile, templateFile, outXlsm, qaXlsx, startRow, endRow, formulaTemplateRow)
    fid = fopen(file, 'w');
    cleaner = onCleanup(@() fclose(fid)); %#ok<NASGU>
    fprintf(fid, '# TM03C B2 robust main280 injection\n\n');
    fprintf(fid, '## 1. 目的\nmain280全280点をB2 robust版xlsmへ一括投入する。VBA/Solver実行はここでは行わない。\n\n');
    fprintf(fid, '## 2. 背景\nTM03CprepのB1b代表12点はB2 robust版で全点収束したため、次段階としてmain280投入packageを作成する。\n\n');
    fprintf(fid, '## 3. B3を保留しB2へ戻した理由\nB3 summary runnerはErr 429問題があるため保留し、動作確認済みのB2 robust bracket版で運用を進める。\n\n');
    fprintf(fid, '## 4. 入力ファイル\n- %s\n\n', previewFile);
    fprintf(fid, '## 5. テンプレートxlsm\n- %s\n- output: %s\n\n', templateFile, outXlsm);
    fprintf(fid, '## 6. MATLAB投入方法\nExcel COMでxlsmを開き、tmシートの対象行に式・書式をコピーしてから入力21列を上書きし、xlsm形式(52)で保存する。\n\n');
    fprintf(fid, '## 7. 投入対象 main280\n`tm_input_preview`の順序を維持した280点。\n\n');
    fprintf(fid, '## 8. 行範囲 226〜505\n開始行=%d、終了行=%d、N=%d。\n\n', startRow, endRow, endRow-startRow+1);
    fprintf(fid, '## 9. 列マッピング\nQA workbookの`column_mapping`を参照。S q_in初期値はq_M、固定値はV=0.03, X=0.01, AC=600, AG=1e-5, AP=1, BG=1, BI=0.046, BJ=5625, BK=1, BQ=1。\n\n');
    fprintf(fid, '## 10. 数式コピー方法\nテンプレート行%dのA:BRを各投入行へコピー後、入力21列を上書きした。\n\n', formulaTemplateRow);
    fprintf(fid, '## 11. テーブル範囲 A1:BR505\n要求範囲=A1:BR%d、COM読返し範囲=%s。\n\n', endRow, QA.table_resize_info.actual_range);
    fprintf(fid, '## 12. QA結果\nQA workbook: %s\n\n', qaXlsx);
    for i = 1:height(QA.qa_checks), fprintf(fid, '- %s: %d\n', QA.qa_checks.check(i), QA.qa_checks.pass(i)); end
    fprintf(fid, '\n## 13. batch_plan\nBatch 1: rows 226-275, Batch 2: 276-325, Batch 3: 326-375, Batch 4: 376-425, Batch 5: 426-475, Batch 6: 476-505。詳細はQA workbookの`batch_plan`を参照。\n\n');
    fprintf(fid, '## 14. Windows実行手順\n1. `TM03C_B2robust_main280_injected_*.xlsm`を開く。\n2. マクロとSolverを有効化する。\n3. `AdjustSValue_BracketRobust_TM03B2`を実行する。\n4. まずBatch 1だけ実行する（開始行=226、終了行=275）。\n5. `TM03C_B2robust_main280_batch01_run_done.xlsm`として別名保存する。\n6. 結果確認後にBatch 2以降へ進む。\n\n');
    fprintf(fid, '## 15. 合格基準\n投入package: 280点が226〜505行に投入、テーブル範囲A1:BR505、入力21列が仕様どおり、数式列とB2 robust版マクロが残る、重大warningなし。VBA実行後: batch内で停止なし、q_in/q_P/PM_ratio有限、dq_ratio概ね±1%%以内、Logあり。\n\n');
    fprintf(fid, '## 16. 次アクション\nBatch 1のみ実行し、合格を確認してからBatch 2以降へ進む。280点一括実行、B3復活、F1再fit、F(x_eq)化、L/D・PM補正式作成はまだ行わない。\n');
end
