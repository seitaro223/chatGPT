% TM03E_extract_current_main280_result_v1.m
% Purpose:
%   Extract TM03C all_rev macrobook results into a fixed current_result file.
%   This is acceptance QA + F1 feasibility pre-check, NOT F1 fitting.
%
% Inputs expected in the same folder or edit the paths below:
%   celataモデル_簡易計算_単管_櫻井検算r127_F1なし_all_rev.xlsm
%   TM03C_main280_input_20260626_130059.xlsx
%
% Outputs:
%   TM03E_current_main280_result_v1_YYYYMMDD_HHMMSS.xlsx
%   TM03E_records_all280_current_result_v1_YYYYMMDD_HHMMSS.csv
%   TM03E_records_valid277_current_result_v1_YYYYMMDD_HHMMSS.csv
%   TM03E_excluded3_current_result_v1_YYYYMMDD_HHMMSS.csv
%   TM03E_tsub_feasibility_current_result_v1_YYYYMMDD_HHMMSS.csv
%   run_report_TM03E_current_main280_result_v1_YYYYMMDD_HHMMSS.md

clear; clc;
stamp = datestr(now, 'yyyymmdd_HHMMSS');

source_xlsm = 'celataモデル_簡易計算_単管_櫻井検算r127_F1なし_all_rev.xlsm';
input_xlsx  = 'TM03C_main280_input_20260626_130059.xlsx';

% ---- read input list (main280) ----
in = readtable(input_xlsx, 'Sheet', 'input', 'VariableNamingRule', 'preserve');
noInput = string(in.A_No_TableNo);

% ---- read tm sheet with worksheet row numbers ----
raw = readcell(source_xlsm, 'Sheet', 'tm');
headers = string(raw(1,:));
headers = matlab.lang.makeValidName(headers);
headers = matlab.lang.makeUniqueStrings(headers);
body = raw(2:end,:);
T = cell2table(body, 'VariableNames', cellstr(headers));
T.result_row_in_all_rev = (2:(height(T)+1))';
T.No_TableNo = string(T.No_TableNo);

% Convert selected tm columns to numeric. readcell/cell2table often leaves cell columns.
tmNumeric = {'P','Ts','rhoG','rhoL','HG','HL','muG','muL','KL','CPL','sigma','No','G','A','Pw','DH','L_DNB','q_in','Tin','Tf','f_beta_','Re','f','f_left','f_rihgt','f_balance','DB','Tw','y_plus','Tm','Tw_balance','y_star','tauw','Utau','y_plus2','Q','Pr','T_y_plus_','y_star_balance','delta','UB','LB','YB','YB_plus','Karman_UB','UBL','UB_left','CD','UB_right','UB_balance','HG_HL','LB_UB','q_P','dq_chf','dq_ratio','q_M','PM_ratio','F_form','x_Mes','A_corr','x__corr','Fcorr','Tsub','q_P_MW','Tsub2','Fcorr2','Tsub_40__2','F2','L'};
for k = 1:numel(tmNumeric)
    v = tmNumeric{k};
    if ismember(v, T.Properties.VariableNames)
        T.(v) = localToDouble(T.(v));
    end
end

% Keep only current valid rows. all_rev is expected to have valid277 in tm rows >=226.
valid = T(T.result_row_in_all_rev >= 226 & ismember(T.No_TableNo, noInput), :);

% ---- read Log and extract current run summaries rows 226:505 ----
logRaw = readcell(source_xlsm, 'Sheet', 'Log');
logHeaders = string(logRaw(1,:));
logHeaders = matlab.lang.makeValidName(logHeaders);
logHeaders = matlab.lang.makeUniqueStrings(logHeaders);
logBody = logRaw(2:end,:);
L = cell2table(logBody, 'VariableNames', cellstr(logHeaders));
L.No_TableNo = string(L.No_TableNo);
L.phase = string(L.phase);
L.status = string(L.status);
if ismember('message', L.Properties.VariableNames)
    L.message = string(L.message);
end
logNumeric = {'RowNo','iter','q_low','q_high','q_in','q_P','delta','y_star','PM_ratio','dq_ratio_pct','f_solver'};
for k = 1:numel(logNumeric)
    v = logNumeric{k};
    if ismember(v, L.Properties.VariableNames)
        L.(v) = localToDouble(L.(v));
    end
end
currentLog = L(L.phase == "SUMMARY" & L.RowNo >= 226 & L.RowNo <= 505 & ismember(L.No_TableNo, noInput), :);

% ---- build all280 from input order ----
all280 = in(:, {'target_row','A_No_TableNo','B_P','M_No','N_G','Q_DH','R_L_DNB','T_Tin','BE_q_M','BG_F_form','BH_x_Mes','BR_L'});
all280.Properties.VariableNames = {'original_target_row','No_TableNo','P_Pa_input','ExptNo','G','DH_m','L_DNB_m_input','Tin_K','q_M_Wm2_input','F_form_input','x_Mes_input','L_m_input'};
all280.No_TableNo = string(all280.No_TableNo);
all280.TableNo = str2double(extractAfter(all280.No_TableNo, '_'));
all280.P_MPa = all280.P_Pa_input / 1e6;
all280.q_M_MWm2_input = all280.q_M_Wm2_input / 1e6;
all280.L_DNB_over_DH_input = all280.L_DNB_m_input ./ all280.DH_m;
all280.L_over_DH_input = all280.L_m_input ./ all280.DH_m;

% Attach status from Log.
statusTbl = currentLog(:, {'No_TableNo','RowNo','status','message','q_low','q_high','q_in','q_P','PM_ratio','dq_ratio_pct'});
statusTbl.Properties.VariableNames = {'No_TableNo','log_RowNo','Status','log_message','log_q_low','log_q_high','log_q_in','log_q_P','log_PM_ratio','log_dq_ratio_pct'};
all280 = outerjoin(all280, statusTbl, 'Keys','No_TableNo', 'MergeKeys',true, 'Type','left');

% Attach result values for OK rows.
resVars = {'No_TableNo','result_row_in_all_rev','q_in','q_P','q_M','PM_ratio','dq_ratio','Tsub','Tsub2','Fcorr','F_form','x_Mes','q_P_MW'};
res = valid(:, resVars);
res.Properties.VariableNames = {'No_TableNo','result_row_in_all_rev','q_in_Wm2','q_P_Wm2','q_M_Wm2_result','PM_noF1','dq_ratio_pct_result','Tsub_K','Tsub2','Fcorr','F_form_result','x_Mes_result','q_P_MWm2'};
res.q_in_MWm2 = res.q_in_Wm2 / 1e6;
res.q_M_MWm2_result = res.q_M_Wm2_result / 1e6;
all280 = outerjoin(all280, res, 'Keys','No_TableNo', 'MergeKeys',true, 'Type','left');
all280 = sortrows(all280, 'original_target_row');

valid277 = all280(all280.Status == "OK", :);
excluded3 = all280(all280.Status ~= "OK", :);

% ---- table summary ----
tabList = unique(valid277.TableNo);
tableSummary = table();
for i = 1:numel(tabList)
    tbl = tabList(i);
    sub = valid277(valid277.TableNo == tbl, :);
    row = table(tbl, height(sub), mean(sub.PM_noF1,'omitnan'), median(sub.PM_noF1,'omitnan'), std(sub.PM_noF1,'omitnan'), min(sub.PM_noF1), max(sub.PM_noF1), mean(sub.Tsub_K,'omitnan'), mean(sub.x_Mes_result,'omitnan'), mean(sub.P_MPa,'omitnan'), ...
        'VariableNames', {'TableNo','N_valid','PM_mean','PM_median','PM_SD','PM_min','PM_max','Tsub_mean_K','x_Mes_mean','P_MPa_mean'});
    tableSummary = [tableSummary; row]; %#ok<AGROW>
end

% ---- Tsub/F1 feasibility pre-check ----
feas = table();
feas = [feas; localFitRow(valid277, "all_valid277", false)];
feas = [feas; localFitRow(valid277, "all_valid277", true)];
trim = valid277(valid277.PM_noF1 >= 0.2 & valid277.PM_noF1 <= 3.0, :);
feas = [feas; localFitRow(trim, "trim_PM_0p2_3p0", false)];
feas = [feas; localFitRow(trim, "trim_PM_0p2_3p0", true)];
for i = 1:numel(tabList)
    sub = valid277(valid277.TableNo == tabList(i), :);
    feas = [feas; localFitRow(sub, "Table" + string(tabList(i)), false)]; %#ok<AGROW>
    feas = [feas; localFitRow(sub, "Table" + string(tabList(i)), true)]; %#ok<AGROW>
end

% ---- write outputs ----
out_xlsx = "TM03E_current_main280_result_v1_" + stamp + ".xlsx";
writetable(all280, out_xlsx, 'Sheet','records_all280');
writetable(valid277, out_xlsx, 'Sheet','records_valid277');
writetable(excluded3, out_xlsx, 'Sheet','excluded3');
writetable(tableSummary, out_xlsx, 'Sheet','table_summary');
writetable(feas, out_xlsx, 'Sheet','Tsub_F1_feasibility');

writetable(all280, "TM03E_records_all280_current_result_v1_" + stamp + ".csv");
writetable(valid277, "TM03E_records_valid277_current_result_v1_" + stamp + ".csv");
writetable(excluded3, "TM03E_excluded3_current_result_v1_" + stamp + ".csv");
writetable(feas, "TM03E_tsub_feasibility_current_result_v1_" + stamp + ".csv");

% ---- report ----
fid = fopen("run_report_TM03E_current_main280_result_v1_" + stamp + ".md", 'w');
fprintf(fid, "# TM03E current main280 result extraction\n\n");
fprintf(fid, "## Positioning\n\n");
fprintf(fid, "This run freezes values from all_rev.xlsm into current_result. This is acceptance QA and F1 feasibility pre-check only; it is not F1 fitting.\n\n");
fprintf(fid, "## QA\n\n");
fprintf(fid, "- main280 input rows: %d\n", height(in));
fprintf(fid, "- current Log summaries rows 226-505: %d\n", height(currentLog));
fprintf(fid, "- valid OK rows: %d\n", height(valid277));
fprintf(fid, "- excluded rows: %d\n", height(excluded3));
fprintf(fid, "- excluded IDs: %s\n\n", strjoin(cellstr(excluded3.No_TableNo), ", "));
fprintf(fid, "## Tsub feasibility pre-check\n\n");
fprintf(fid, "Tsub correlation is used only to check whether F1-like structure may exist. No fitting is adopted here.\n\n");
for i = 1:height(feas)
    fprintf(fid, "- %s / %s: N=%d, R2=%.4f, slope=%.6g\n", feas.scope(i), feas.model(i), feas.N(i), feas.R2(i), feas.slope(i));
end
fprintf(fid, "\n## Next\n\n");
fprintf(fid, "- Weatherhead coverage check requires a canonical Weatherhead point list.\n");
fprintf(fid, "- Do not over-diagnose before Becker/Weatherhead/Zenkevich inputs are complete.\n");
fclose(fid);

fprintf('Done. Wrote %s\n', out_xlsx);

function out = localToDouble(x)
    if isnumeric(x)
        out = double(x);
        return;
    end
    if iscell(x)
        out = NaN(size(x));
        for ii = 1:numel(x)
            v = x{ii};
            if isnumeric(v) && isscalar(v)
                out(ii) = double(v);
            elseif isstring(v) || ischar(v)
                out(ii) = str2double(string(v));
            else
                out(ii) = NaN;
            end
        end
        return;
    end
    out = str2double(string(x));
end

function row = localFitRow(T, scope, useLog)
    x = T.Tsub_K;
    y = T.PM_noF1;
    if useLog
        mask = isfinite(x) & isfinite(y) & y > 0;
        y = log(y(mask)); x = x(mask);
        model = "ln(PM_noF1) ~ Tsub";
    else
        mask = isfinite(x) & isfinite(y);
        y = y(mask); x = x(mask);
        model = "PM_noF1 ~ Tsub";
    end
    n = numel(x);
    if n < 3 || var(x) == 0 || var(y) == 0
        slope = NaN; intercept = NaN; R2 = NaN; corrv = NaN;
    else
        p = polyfit(x, y, 1);
        yhat = polyval(p, x);
        ssres = sum((y-yhat).^2);
        sstot = sum((y-mean(y)).^2);
        R2 = 1 - ssres/sstot;
        c = corrcoef(x, y);
        corrv = c(1,2);
        slope = p(1); intercept = p(2);
    end
    row = table(string(scope), string(model), n, slope, intercept, R2, corrv, 'VariableNames', {'scope','model','N','slope','intercept','R2','corr'});
end
