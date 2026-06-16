%% h52q_tm8_14_true_hsub_v8a_make_input.m
% H52Q / T&M Table 8-14
% v8a: 真Hsub診断に進む前の入力表を作る。
%
% 目的:
%   1. Table10の既存86行を抽出し、PDF原表の INLET SUB COOLING [BTU/lb]
%      を入力するためのテンプレートを作る。
%   2. Table11/12側は handoffブックの hSub_kJ_kg を読み、
%      真Hsubとして使える形に整理する。
%
% 入力:
%   out_TM8_14/TM8_14_tsub_residual_v7b_*.xlsx
%   ThompsonMacbeth_TM8_9_11_14_G1000_macrohandoff_TinFilled.xlsx
%
% 出力:
%   out_TM8_14/TM8_14_true_hsub_input_v8a_yyyymmdd_HHMMSS.xlsx

clear; clc; close all;

%% ===== 設定 =====
outDir = fullfile(pwd, "out_TM8_14");

handoffFile = fullfile(pwd, "ThompsonMacbeth_TM8_9_11_14_G1000_macrohandoff_TinFilled.xlsx");
handoffSheet = "120_MACRO_INPUT_FINAL";

files = dir(fullfile(outDir, "TM8_14_tsub_residual_v7b_*.xlsx"));
if isempty(files)
    error("out_TM8_14 に TM8_14_tsub_residual_v7b_*.xlsx が見つかりません。");
end

[~, idx] = max([files.datenum]);
v7bFile = fullfile(files(idx).folder, files(idx).name);

timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
outFile = fullfile(outDir, "TM8_14_true_hsub_input_v8a_" + timestamp + ".xlsx");

fprintf("v7b file    : %s\n", v7bFile);
fprintf("handoff file: %s\n", handoffFile);
fprintf("output file : %s\n\n", outFile);

%% ===== v7b統合データを読む =====
T = readtable(v7bFile, "Sheet", "integrated_with_Tsub", "VariableNamingRule", "preserve");
T.LD_band = string(T.LD_band);
T.P_band_v6 = string(T.P_band_v6);

%% ===== Table10：PDF入力テンプレート =====
T10 = T(T.TableNo == 10, :);
T10 = sortrows(T10, ["LD_geom", "No_TableNo"]);

T10.ExptNo_text = erase(string(T10.No_TableNo), "_10");
T10.ExptNo_num = str2double(T10.ExptNo_text);

% PDFページ推定：Table10 PDF上のページ目安。手入力補助用。
T10.source_pdf_page_est = estimateT10Page(T10.ExptNo_num);

Table10_template = table();
Table10_template.No_TableNo = T10.No_TableNo;
Table10_template.ExptNo = T10.ExptNo_text;
Table10_template.TableNo = T10.TableNo;
Table10_template.P_MPa = T10.P_MPa;
Table10_template.G = T10.G;
Table10_template.DH = T10.DH;
Table10_template.L = T10.L;
Table10_template.LD_geom = T10.LD_geom;
Table10_template.LD_band = T10.LD_band;
Table10_template.Tsub_from_tm_K = T10.Tsub;
Table10_template.Hsub_proxy_kJkg = T10.Hsub_proxy_kJkg;
Table10_template.Hsub_proxy_BTUlb = T10.Hsub_proxy_kJkg ./ 2.326;
Table10_template.PM_F1 = T10.PM_F1;
Table10_template.PM_noF1 = T10.PM_noF1;
Table10_template.source_pdf_page_est = T10.source_pdf_page_est;

% ここをPDFから手入力する
Table10_template.Hsub_PDF_BTUlb = nan(height(Table10_template),1);
Table10_template.Hsub_PDF_kJkg = nan(height(Table10_template),1);

% 入力確認用
Table10_template.input_status = repmat("NEED_PDF_INPUT", height(Table10_template), 1);
Table10_template.note = repmat("Enter INLET SUB COOLING [BTU/lb] from Table 10 PDF, then Hsub_PDF_kJkg = Hsub_PDF_BTUlb*2.326", height(Table10_template), 1);

%% ===== Table11/12：handoffブックから真hSubを取得 =====
H = readtable(handoffFile, "Sheet", handoffSheet, "VariableNamingRule", "preserve");

H.TableNo = double(H.TableNo);
H.ExptNo_text = string(H.ExptNo);
H.No_TableNo = H.ExptNo_text + "_" + string(H.TableNo);

% PWR_near主解析としてTable11/12を抽出
H12 = H(ismember(H.TableNo, [11 12]), :);

added_true_hsub = table();
added_true_hsub.No_TableNo = H12.No_TableNo;
added_true_hsub.ExptNo = H12.ExptNo_text;
added_true_hsub.TableNo = H12.TableNo;
added_true_hsub.P_MPa = H12.P_MPa;
added_true_hsub.G_kg_m2s = H12.G_kg_m2s;
added_true_hsub.D_m = H12.D_m;
added_true_hsub.L_m = H12.L_m;
added_true_hsub.L_over_D = H12.L_over_D;
added_true_hsub.Hsub_true_kJkg = H12.hSub_kJ_kg;
added_true_hsub.Hsub_true_BTUlb = H12.hSub_kJ_kg ./ 2.326;
added_true_hsub.qCHF_MW_m2 = H12.qCHF_MW_m2;
added_true_hsub.x_exit = H12.x_exit;
added_true_hsub.source = repmat("120_MACRO_INPUT_FINAL", height(H12), 1);

%% ===== readiness確認 =====
readiness = table();
readiness.Item = [
    "Table10_rows_need_PDF_input"
    "Table11_12_rows_with_true_hSub_from_handoff"
    "Table11_rows"
    "Table12_rows"
    "Table10_Hsub_PDF_filled_now"
    ];
readiness.Value = [
    height(Table10_template)
    height(added_true_hsub)
    sum(added_true_hsub.TableNo == 11)
    sum(added_true_hsub.TableNo == 12)
    sum(~isnan(Table10_template.Hsub_PDF_BTUlb))
    ];

%% ===== README =====
readme = table();
readme.Memo = [
    "This workbook is v8a input preparation for true-Hsub diagnostics."
    "Table10 true Hsub must be entered from the original Table10 PDF column: INLET SUB COOLING [BTU/lb]."
    "For Table10, fill Hsub_PDF_BTUlb in sheet Table10_PDF_Hsub_input."
    "After filling Hsub_PDF_BTUlb, calculate Hsub_PDF_kJkg = Hsub_PDF_BTUlb * 2.326."
    "For Table11/12, hSub_kJ_kg is read from 120_MACRO_INPUT_FINAL in the handoff workbook."
    "Do not use Hsub_proxy as final true Hsub. Hsub_proxy = CPL*Tsub is only a diagnostic approximation."
    "Next step v8b: merge true Hsub into PWR_near Table10-12 and rerun residual diagnostics."
    ];

%% ===== 出力 =====
writetable(readme, outFile, "Sheet", "README");
writetable(readiness, outFile, "Sheet", "readiness");
writetable(Table10_template, outFile, "Sheet", "Table10_PDF_Hsub_input");
writetable(added_true_hsub, outFile, "Sheet", "Table11_12_hSub_handoff");
writetable(T10, outFile, "Sheet", "Table10_source_rows");
writetable(H12, outFile, "Sheet", "Table11_12_handoff_raw");

%% ===== 表示 =====
disp("=== readiness ===");
disp(readiness);

fprintf("\nDone.\n");
fprintf("Output written to:\n  %s\n", outFile);

%% ===== ローカル関数 =====

function page = estimateT10Page(exptNo)
    page = strings(size(exptNo));

    page(exptNo >= 1   & exptNo <= 45)  = "PDF p.1 / report p.60";
    page(exptNo >= 46  & exptNo <= 90)  = "PDF p.2 / report p.61";
    page(exptNo >= 91  & exptNo <= 137) = "PDF p.3 / report p.62";
    page(exptNo >= 138 & exptNo <= 184) = "PDF p.4 / report p.63";
    page(exptNo >= 185 & exptNo <= 232) = "PDF p.5 / report p.64";
    page(exptNo >= 233 & exptNo <= 279) = "PDF p.6 / report p.65";
    page(exptNo >= 280 & exptNo <= 326) = "PDF p.7 / report p.66";
    page(exptNo >= 327 & exptNo <= 374) = "PDF p.8 / report p.67";
    page(exptNo >= 375 & exptNo <= 421) = "PDF p.9 / report p.68";
    page(exptNo >= 422 & exptNo <= 469) = "PDF p.10 / report p.69";
    page(exptNo >= 470 & exptNo <= 523) = "PDF p.11 / report p.70";
    page(exptNo >= 524 & exptNo <= 561) = "PDF p.12 / report p.71";
    page(exptNo >= 562 & exptNo <= 609) = "PDF p.13 / report p.72";
    page(exptNo >= 610 & exptNo <= 649) = "PDF p.14 / report p.73";

    page(page == "") = "unknown";
end