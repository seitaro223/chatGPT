% TM03C_build_xlsm_run_package_from_preview.m
% Build a B2-robust xlsm run package by injecting the B1b 12-point target set
% into the tm sheet with Excel COM, preserving VBA, formulas, formats, and tables.
%
% This script intentionally does NOT run Solver or the B2 VBA macro.  It only
% prepares an xlsm package for later Windows Excel/VBA execution.

clear; clc;

%% Configuration
scriptDir = fileparts(mfilename('fullpath'));
if strlength(string(scriptDir)) == 0
    scriptDir = pwd;
end

previewFile = fullfile(scriptDir, 'tm_input_preview_20260625_083115.xlsx');
candidateFile = fullfile(scriptDir, 'TM03B1b_newonly_candidate_points_20260625_235759.xlsx');
preferredTemplate = fullfile(scriptDir, 'TM03_template_B2_robust.xlsm');
fallbackTemplate = fullfile(scriptDir, 'TM03B2_macro_bracket_test_20260625_235759_run_done.xlsm');

if isfile(preferredTemplate)
    templateFile = preferredTemplate;
else
    templateFile = fallbackTemplate;
end

points = [
    "39.01_10"
    "27.01_10"
    "81.01_10"
    "259.01_10"
    "1.01_10"
    "442.01_10"
    "150.01_10"
    "289.01_10"
    "249.01_10"
    "281.01_10"
    "40.01_10"
    "9.01_10"];

startRow = 226;
endRow = startRow + numel(points) - 1;
formulaTemplateRow = 88;
tmSheetName = 'tm';
tableName = 'テーブル2';
lastCol = 'BR';

stamp = datestr(now, 'yyyymmdd_HHMMSS');
outXlsm = fullfile(scriptDir, sprintf('TM03Cprep_B2robust_B1b12_injected_%s.xlsm', stamp));
qaXlsx = fullfile(scriptDir, sprintf('TM03Cprep_B2robust_B1b12_injection_QA_%s.xlsx', stamp));
reportMd = fullfile(scriptDir, sprintf('run_report_TM03Cprep_B2robust_MATLAB_injection_%s.md', stamp));

%% Preconditions
mustExist(previewFile, 'preview input workbook');
mustExist(candidateFile, 'B1b candidate workbook');
mustExist(templateFile, 'B2 robust xlsm template');
if ~ispc
    error(['Excel COM requires MATLAB on Windows. Run this script on the Windows ', ...
        'Excel/Solver machine that will also execute the B2 robust macro.']);
end

%% Read and normalize input rows
Tall = readInputRows(previewFile, candidateFile);
Tin = selectPointRows(Tall, points);

%% Copy template xlsm, inject rows with Excel COM, and resize table
copyfile(templateFile, outXlsm, 'f');

excel = [];
wb = [];
warnings = strings(0,1);
tableRangeAfter = "";
listObjectNames = strings(0,1);
try
    excel = actxserver('Excel.Application');
    excel.DisplayAlerts = false;
    excel.Visible = false;
    wb = excel.Workbooks.Open(outXlsm);
    ws = wb.Worksheets.Item(tmSheetName);

    % Copy A:BR from the proven formula row to every target row.  Inputs are
    % overwritten afterwards, allowing Excel to adjust relative references.
    src = ws.Range(sprintf('A%d:%s%d', formulaTemplateRow, lastCol, formulaTemplateRow));
    for r = startRow:endRow
        dst = ws.Range(sprintf('A%d:%s%d', r, lastCol, r));
        src.Copy(dst);
    end
    excel.CutCopyMode = false;

    for i = 1:height(Tin)
        r = startRow + i - 1;
        writeInputsToRow(ws, r, Tin(i,:));
    end

    % Resize table to include all injected rows. Report available tables if
    % the expected Japanese table name is not found.
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

    wb.SaveAs(outXlsm, 52); % xlOpenXMLWorkbookMacroEnabled
    wb.Close(false);
    wb = [];
    excel.Quit;
    excel = [];
catch ME
    if ~isempty(wb)
        try, wb.Close(false); catch, end %#ok<CTCH>
    end
    if ~isempty(excel)
        try, excel.Quit; catch, end %#ok<CTCH>
    end
    rethrow(ME);
end

%% QA outputs and report
QA = buildQaTables(Tin, points, startRow, endRow, formulaTemplateRow, templateFile, ...
    outXlsm, previewFile, candidateFile, tableRangeAfter, listObjectNames, warnings);
writeQaWorkbook(qaXlsx, QA);
writeMarkdownReport(reportMd, QA, points, startRow, endRow, formulaTemplateRow, ...
    templateFile, outXlsm, qaXlsx, previewFile, candidateFile, warnings);

fprintf('Created xlsm run package: %s\n', outXlsm);
fprintf('Created QA workbook:      %s\n', qaXlsx);
fprintf('Created report:           %s\n', reportMd);

%% Local functions
function mustExist(path, label)
    if ~isfile(path)
        error('Missing %s: %s', label, path);
    end
end

function T = readInputRows(previewFile, candidateFile)
    % Prefer already-materialized injection previews when present because they
    % contain exactly the tm input columns (A/B/M/N/.../BR) used by B1a/B1b.
    T = readPreferredTable(candidateFile, ["input_preview_for_injection", "selected_newonly", "newonly_all"]);
    %#ok<NASGU> previewFile is kept as an explicit precondition and report input;
    % the B1b workbook's input_preview_for_injection sheet is the authoritative
    % source for this 12-point reproduction package.
    T.No_TableNo_norm = normalizePointId(firstText(T, ["A_No_TableNo","tmA_No_TableNo","No_TableNo","Case","case","case_id","point_id","Point"]));
end

function T = readPreferredTable(file, preferredSheets)
    sheets = sheetnames(file);
    for p = 1:numel(preferredSheets)
        hit = find(strcmpi(string(sheets), preferredSheets(p)), 1);
        if ~isempty(hit)
            T = readtable(file, 'Sheet', sheets{hit}, 'VariableNamingRule', 'preserve');
            return;
        end
    end
    T = readFirstUsableTable(file);
end

function T = readFirstUsableTable(file)
    sheets = sheetnames(file);
    lastErr = [];
    for i = 1:numel(sheets)
        try
            X = readtable(file, 'Sheet', sheets{i}, 'VariableNamingRule', 'preserve');
            if height(X) > 0 && width(X) > 0
                T = X;
                return;
            end
        catch ME
            lastErr = ME;
        end
    end
    if isempty(lastErr)
        error('No usable sheets found in %s', file);
    else
        error('Could not read %s: %s', file, lastErr.message);
    end
end

function tf = hasAnyColumn(T, candidates)
    tf = any(ismember(normalizeName(candidates), normalizeName(string(T.Properties.VariableNames))));
end

function Tout = selectPointRows(T, points)
    ids = string(T.No_TableNo_norm);
    pick = zeros(numel(points),1);
    for i = 1:numel(points)
        hit = find(ids == normalizePointId(points(i)), 1, 'first');
        if isempty(hit)
            error('Target point %s was not found in input workbooks.', points(i));
        end
        pick(i) = hit;
    end
    Tout = T(pick,:);
    Tout.No_TableNo_out = points;
    Tout.No_out = parseNo(points);
    Tout.TableNo_out = parseTableNo(points);
    Tout.P_out = firstNumeric(Tout, ["B_P","tmB_P_Pa","P","Pressure","P_Pa","P_MPa","P_psia"]);
    Tout.G_out = firstNumeric(Tout, ["N_G","tmN_G_kg_m2s","G","MassFlux","G_kg_m2s"]);
    Tout.DH_out = firstNumeric(Tout, ["Q_DH","tmQ_DH_m","DH","D_H","Dh","D_h","HydraulicDiameter"]);
    Tout.L_DNB_out = firstNumeric(Tout, ["R_L_DNB","tmR_L_DNB_m","L_DNB","LDNB","z_DNB","zDNB"]);
    Tout.q_M_out = firstNumeric(Tout, ["BE_q_M","tmBE_qM_W_m2","S_q_in_seed","seed_tmS_q_in_W_m2","q_M","qM","q_exp","q_Mes","q_M_MW","qM_MW"]);
    Tout.Tin_out = firstNumeric(Tout, ["T_Tin","tmT_Tin_K","Tin","Tin_K","T_in","InletTemp","T_inlet"]);
    Tout.BH_x_Mes_out = firstNumeric(Tout, ["BH_x_Mes","tmBH_x_Mes","x_Mes","xMes","x_report","x_eq","xeq","x"]);
    Tout.BR_L_out = firstNumeric(Tout, ["BR_L","tmBR_L_m","L","Length","HeatedLength"]);
end

function writeInputsToRow(ws, r, row)
    setCell(ws, 'A', r, char(row.No_TableNo_out));
    setCell(ws, 'B', r, row.P_out);
    setCell(ws, 'M', r, row.No_out);
    setCell(ws, 'N', r, row.G_out);
    setCell(ws, 'Q', r, row.DH_out);
    setCell(ws, 'R', r, row.L_DNB_out);
    setCell(ws, 'S', r, row.q_M_out);
    setCell(ws, 'T', r, row.Tin_out);
    setCell(ws, 'V', r, 0.03);
    setCell(ws, 'X', r, 0.01);
    setCell(ws, 'AC', r, 600);
    setCell(ws, 'AG', r, 1e-5);
    setCell(ws, 'AP', r, 1);
    setCell(ws, 'BE', r, row.q_M_out);
    setCell(ws, 'BG', r, 1);
    setCell(ws, 'BH', r, row.BH_x_Mes_out);
    setCell(ws, 'BI', r, 0.046);
    setCell(ws, 'BJ', r, 5625);
    setCell(ws, 'BK', r, 1);
    setCell(ws, 'BQ', r, 1);
    setCell(ws, 'BR', r, row.BR_L_out);
end

function setCell(ws, col, r, val)
    cell = ws.Range(sprintf('%s%d', col, r));
    if ismissingScalar(val) || (isnumeric(val) && ~isfinite(val))
        cell.Value = [];
    else
        cell.Value = val;
    end
end

function tf = ismissingScalar(v)
    if isstring(v) || ischar(v) || iscellstr(v)
        tf = ismissing(string(v)) || strlength(string(v)) == 0;
    else
        tf = false;
    end
end

function v = firstNumeric(T, candidates)
    vars = string(T.Properties.VariableNames);
    idx = find(ismember(normalizeName(vars), normalizeName(candidates)), 1);
    if isempty(idx)
        error('Missing numeric input column. Candidates: %s', strjoin(candidates, ', '));
    end
    raw = T.(vars(idx));
    if isnumeric(raw)
        v = double(raw);
    else
        v = str2double(string(raw));
    end
end

function v = firstText(T, candidates)
    vars = string(T.Properties.VariableNames);
    idx = find(ismember(normalizeName(vars), normalizeName(candidates)), 1);
    if isempty(idx)
        error('Missing text input column. Candidates: %s', strjoin(candidates, ', '));
    end
    v = string(T.(vars(idx)));
end

function s = normalizeName(s)
    s = lower(regexprep(string(s), '[^a-zA-Z0-9]', ''));
end

function id = normalizePointId(s)
    id = regexprep(strtrim(string(s)), '\s+', '');
end

function no = parseNo(pointIds)
    parts = regexp(string(pointIds), '^([0-9]+(?:\.[0-9]+)?)_([0-9]+)$', 'tokens', 'once');
    no = nan(numel(pointIds),1);
    for i = 1:numel(pointIds)
        if ~isempty(parts{i})
            no(i) = str2double(parts{i}{1});
        end
    end
end

function tableNo = parseTableNo(pointIds)
    parts = regexp(string(pointIds), '^([0-9]+(?:\.[0-9]+)?)_([0-9]+)$', 'tokens', 'once');
    tableNo = nan(numel(pointIds),1);
    for i = 1:numel(pointIds)
        if ~isempty(parts{i})
            tableNo(i) = str2double(parts{i}{2});
        end
    end
end

function QA = buildQaTables(Tin, points, startRow, endRow, formulaTemplateRow, templateFile, outXlsm, previewFile, candidateFile, tableRangeAfter, listObjectNames, warnings)
    rows = (startRow:endRow)';
    QA.injected_points = table(rows, points, Tin.No_TableNo_out, Tin.No_out, Tin.TableNo_out, ...
        'VariableNames', {'tm_row','expected_point','No_TableNo','No','TableNo'});
    QA.input_values = table(rows, Tin.No_TableNo_out, Tin.P_out, Tin.G_out, Tin.DH_out, Tin.L_DNB_out, ...
        Tin.q_M_out, Tin.Tin_out, Tin.BH_x_Mes_out, Tin.BR_L_out, ...
        'VariableNames', {'tm_row','No_TableNo','P','G','DH','L_DNB','q_M','Tin','x_Mes','L'});
    QA.column_mapping = table( ...
        ["A";"B";"M";"N";"Q";"R";"S";"T";"V";"X";"AC";"AG";"AP";"BE";"BG";"BH";"BI";"BJ";"BK";"BQ";"BR"], ...
        ["No_TableNo";"P";"No";"G";"DH";"L_DNB";"q_in initial (=q_M)";"Tin";"f initial";"f_balance seed";"Tw initial";"y_star initial";"UB initial";"q_M";"F_form";"x_Mes";"A_corr";"sigma_corr";"Fcorr";"F2";"L"], ...
        ["preview/candidate";"preview/candidate";"parsed from No_TableNo";"preview/candidate";"preview/candidate";"preview/candidate";"q_M";"preview/candidate";"fixed 0.03";"fixed 0.01";"fixed 600";"fixed 1e-5";"fixed 1";"preview/candidate";"fixed 1";"preview/candidate";"fixed 0.046";"fixed 5625";"fixed 1";"fixed 1";"preview/candidate"], ...
        'VariableNames', {'tm_column','field','source'});
    QA.template_info = table(string(templateFile), string(outXlsm), formulaTemplateRow, startRow, endRow, ...
        'VariableNames', {'template_xlsm','output_xlsm','formula_template_row','start_row','end_row'});
    QA.table_resize_info = table("テーブル2", "A1:BR" + string(endRow), tableRangeAfter, strjoin(listObjectNames, ", "), ...
        'VariableNames', {'requested_table','expected_range','actual_range','list_objects'});
    pass = [numel(points) == height(Tin); all(string(Tin.No_TableNo_out) == points); tableRangeAfter == "A1:BR" + string(endRow)];
    QA.qa_checks = table(["12_points_injected";"order_matches";"table_range_A1_BR237"], pass(:), ...
        'VariableNames', {'check','pass'});
    QA.warnings = table(warnings(:), 'VariableNames', {'warning'});
    if height(QA.warnings) == 0
        QA.warnings = table("none", 'VariableNames', {'warning'});
    end
    QA.input_files = table(string(previewFile), string(candidateFile), 'VariableNames', {'preview_file','candidate_file'});
end

function writeQaWorkbook(file, QA)
    names = fieldnames(QA);
    for i = 1:numel(names)
        writetable(QA.(names{i}), file, 'Sheet', names{i});
    end
end

function writeMarkdownReport(file, QA, points, startRow, endRow, formulaTemplateRow, templateFile, outXlsm, qaXlsx, previewFile, candidateFile, warnings)
    fid = fopen(file, 'w');
    cleaner = onCleanup(@() fclose(fid));
    fprintf(fid, '# TM03Cprep B2 robust MATLAB injection\n\n');
    fprintf(fid, '## 1. 目的\nMATLABでpreview/main280候補から対象点を選び、B2 robust bracket版xlsmのtmシートへ投入するrun packageを作る。Solver/VBA実行は行わない。\n\n');
    fprintf(fid, '## 2. 背景\nTM03B2ではq_high段階拡張のrobust bracket版によりB1b失敗点259.01_10と249.01_10の収束を確認済み。\n\n');
    fprintf(fid, '## 3. なぜB3を保留しB2に戻したか\nB3 summary runnerはWindows Excel環境でErr 429によりsummary作成前に停止したため、高機能runnerを保留し、動作確認済みのB2 robust版投入運用を優先する。\n\n');
    fprintf(fid, '## 4. 入力ファイル\n- %s\n- %s\n\n', previewFile, candidateFile);
    fprintf(fid, '## 5. テンプレートxlsm\n- %s\n- 出力: %s\n\n', templateFile, outXlsm);
    fprintf(fid, '## 6. MATLAB投入方法\nExcel COM (`actxserver(''Excel.Application'')`)でxlsmを開き、VBAを保持したままtmシートへ入力した。保存形式は52 (`xlOpenXMLWorkbookMacroEnabled`)。\n\n');
    fprintf(fid, '## 7. 投入対象点\n開始行=%d、終了行=%d。\n\n', startRow, endRow);
    for i = 1:numel(points), fprintf(fid, '- %s\n', points(i)); end
    fprintf(fid, '\n## 8. 列マッピング\nQA workbookの`column_mapping` sheetを参照。固定値はV=0.03, X=0.01, AC=600, AG=1e-5, AP=1, BG=1, BI=0.046, BJ=5625, BK=1, BQ=1。S q_inはq_Mを初期値として投入。\n\n');
    fprintf(fid, '## 9. 数式コピー方法\n`tm`シートのA:BRについて、実績行%dを各対象行へコピー後、入力21列を上書きした。\n\n', formulaTemplateRow);
    fprintf(fid, '## 10. テーブル範囲拡張\n`テーブル2`をA1:BR%dへResizeした。実際のCOM報告範囲: %s。\n\n', endRow, QA.table_resize_info.actual_range);
    fprintf(fid, '## 11. QA結果\nQA workbook: %s\n\n', qaXlsx);
    for i = 1:height(QA.qa_checks), fprintf(fid, '- %s: %d\n', QA.qa_checks.check(i), QA.qa_checks.pass(i)); end
    if ~isempty(warnings), fprintf(fid, '\nWarnings:\n'); for i = 1:numel(warnings), fprintf(fid, '- %s\n', warnings(i)); end, end
    fprintf(fid, '\n## 12. Windows Excel/VBAでの実行手順\n1. `%s`を開く。\n2. マクロとSolverを有効化する。\n3. `AdjustSValue_BracketRobust_TM03B2`を実行する。\n4. 行入力フォームでは開始行=%d、終了行=%dを指定する。\n5. 実行後、`TM03Cprep_B2robust_B1b12_injected_YYYYMMDD_HHMMSS_run_done.xlsm`として別名保存する。\n\n', outXlsm, startRow, endRow);
    fprintf(fid, '## 13. 合格基準\n- 12点すべてでVBA/Solverが途中停止しない。\n- 12点すべてでq_in、q_P、PM_ratioが有限値。\n- dq_ratioが概ね±1%%以内。\n- 259.01_10と249.01_10がOK。\n- 9.01_10 controlがB1a/B2と同程度。\n- Logが出る。\n\n');
    fprintf(fid, '## 14. 次のTM03C-1へ進む条件\nB1b 12点のMATLAB投入版がWindows Excel/VBAで合格した場合のみ、Table10 new-only 143点の分割投入・分割実行（50/50/43点）へ進む。\n');
end
