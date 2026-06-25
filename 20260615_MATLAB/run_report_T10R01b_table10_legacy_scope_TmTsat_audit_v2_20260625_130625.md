# T10R01b_Table10_legacy_scope_TmTsat_audit_v2

作成日時: `2026-06-25 13:08:16`

## 1. 目的

T&M Table10の旧採用点について、初期検討用にかなり絞った「良いデータ集合」だった可能性を前提に、Table10全649行との関係を監査する。

また、後から手で切った可能性がある条件、特にF1適用時にTmが飽和温度を越した点を除外した可能性について、利用可能な計算ブック内にTm/Tsat列があれば照合する。

このrunでは採用点を決めない。F1を作り直す可能性がある場合、過去のTm>Tsat除外条件をそのまま継承するかどうかは別判断とする。

## 2. 時系列認識の修正

今回の前提は以下である。

```text
Table10初期抽出:
  初期検討だったため、まず信頼しやすい・扱いやすいデータをかなり絞った。
  G範囲や手作業除外は、この初期厳選の結果である可能性がある。

Table11/12追加:
  後からL/Dの大きい点が欲しくなって追加した。
  Table10旧採用点ほど厳密な抽出思想ではない。
```

## 3. 入力

- Table10正本Markdown: `W:\thompson_macbeth_table10_2000psia_r1.md`
- 出力Excel: `T10R01b_table10_legacy_scope_TmTsat_audit_v2_20260625_130625.xlsx`
- legacy mode: `auto_detected_from_workbooks`
- manual legacy source: `none`

## 4. QC

- Parsed Table10 rows: `649`
- legacy IDs used: `113`
- Tm/Tsat audit raw rows: `2182`
- Tm/Tsat available Table10 rows: `103`
- Tm > Tsat rows among available: `0`

## 5. Source summary

| source_label | N | sources | flags | D_range | L_range | LD_range | G_range | Hsub_range | x_report_range | frac_x_le_0 | frac_x_le_005 | frac_legacy | frac_Tm_gt_Tsat_available |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| source01 | 388 | source01 | G, H, none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 0.0281 - 7.79 | 0.7 - 626.1 | -0.459 - 1.069 | 0.38918 | 0.48969 | 0.27577 | 0 |
| source07 | 4 | source07 | C, none | 0.12 - 0.18 | 6 - 9.4 | 50 - 52.22 | 0.023 - 0.07 | 316.9 - 537.2 | 0.213 - 0.905 | 0 | 0 | 0 |  |
| source09 | 232 | source09 | DJ, J, none | 0.304 - 0.436 | 18 - 18 | 41.28 - 59.21 | 0.126 - 2 | 0 - 601 | -0.82 - 0.72 | 0.40086 | 0.50431 | 0.025862 |  |
| source11 | 25 | source11 | none | 0.411 - 0.415 | 72 - 72 | 173.5 - 175.2 | 0.5 - 1.3 | 15.9 - 242 | 0.183 - 0.515 | 0 | 0 | 0 |  |

## 6. Flag summary

| flag_norm | N | sources | flags | D_range | L_range | LD_range | G_range | Hsub_range | x_report_range | frac_x_le_0 | frac_x_le_005 | frac_legacy | frac_Tm_gt_Tsat_available |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| C | 3 | source07 | C | 0.12 - 0.12 | 6 - 6 | 50 - 50 | 0.023 - 0.07 | 427.1 - 537.2 | 0.213 - 0.905 | 0 | 0 | 0 |  |
| DJ | 4 | source09 | DJ | 0.436 - 0.436 | 18 - 18 | 41.28 - 41.28 | 0.126 - 0.133 | 31.5 - 85 | 0.608 - 0.72 | 0 | 0 | 0 |  |
| G | 3 | source01 | G | 0.143 - 0.226 | 3 - 24.6 | 20.98 - 108.8 | 3.8 - 3.95 | 75.3 - 470.6 | -0.449 - 0.029 | 0.66667 | 1 | 0 |  |
| H | 1 | source01 | H | 0.187 - 0.187 | 12.5 - 12.5 | 66.84 - 66.84 | 0.616 - 0.616 | 55.8 - 55.8 | 0.422 - 0.422 | 0 | 0 | 0 |  |
| J | 122 | source09 | J | 0.436 - 0.436 | 18 - 18 | 41.28 - 41.28 | 0.134 - 1.55 | 0 - 601 | -0.82 - 0.687 | 0.36885 | 0.44262 | 0.04918 |  |
| none | 516 | source01, source07, source09, source11 | none | 0.075 - 0.415 | 3 - 72 | 20.98 - 365.3 | 0.0281 - 7.79 | 0.7 - 626.1 | -0.459 - 1.069 | 0.38178 | 0.4845 | 0.20736 | 0 |

## 7. Candidate set summary

以下は採用判断ではなく、抽出思想を比較するための候補集合である。

| candidate_set | N | sources | flags | D_range | L_range | LD_range | G_range | Hsub_range | x_report_range | frac_x_le_0 | frac_x_le_005 | frac_legacy | frac_Tm_gt_Tsat_available |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| raw_all | 649 | source01, source07, source09, source11 | C, DJ, G, H, J, none | 0.075 - 0.436 | 3 - 72 | 20.98 - 365.3 | 0.023 - 7.79 | 0 - 626.1 | -0.82 - 1.069 | 0.37596 | 0.47304 | 0.17411 | 0 |
| legacy_selected | 113 | source01, source09 | J, none | 0.075 - 0.436 | 3 - 27.4 | 20.98 - 365.3 | 0.136 - 5.23 | 0.7 - 626.1 | -0.457 - 0.652 | 0.52212 | 0.58407 | 1 | 0 |
| source01_all | 388 | source01 | G, H, none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 0.0281 - 7.79 | 0.7 - 626.1 | -0.459 - 1.069 | 0.38918 | 0.48969 | 0.27577 | 0 |
| source01_x_le_005 | 190 | source01 | G, none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 0.384 - 7.79 | 16.6 - 626.1 | -0.459 - 0.05 | 0.79474 | 1 | 0.34737 | 0 |
| source01_x_le_0 | 151 | source01 | G, none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 0.577 - 7.79 | 75.3 - 626.1 | -0.459 - -0.003 | 1 | 1 | 0.39073 | 0 |
| source01_lowX_not_legacy | 124 | source01 | G, none | 0.143 - 0.306 | 3 - 24.6 | 20.98 - 108.8 | 0.384 - 7.79 | 16.6 - 602.5 | -0.459 - 0.05 | 0.74194 | 1 | 0 |  |
| source09_all_weatherhead_like | 232 | source09 | DJ, J, none | 0.304 - 0.436 | 18 - 18 | 41.28 - 59.21 | 0.126 - 2 | 0 - 601 | -0.82 - 0.72 | 0.40086 | 0.50431 | 0.025862 |  |
| source09_x_le_005 | 117 | source09 | J, none | 0.304 - 0.436 | 18 - 18 | 41.28 - 59.21 | 0.255 - 2 | 61.5 - 601 | -0.82 - 0.048 | 0.79487 | 1 | 0 |  |
| all_x_le_005 | 307 | source01, source09 | G, J, none | 0.075 - 0.436 | 3 - 27.4 | 20.98 - 365.3 | 0.255 - 7.79 | 16.6 - 626.1 | -0.82 - 0.05 | 0.79479 | 1 | 0.21498 | 0 |
| all_x_le_005_source01_or09 | 307 | source01, source09 | G, J, none | 0.075 - 0.436 | 3 - 27.4 | 20.98 - 365.3 | 0.255 - 7.79 | 16.6 - 626.1 | -0.82 - 0.05 | 0.79479 | 1 | 0.21498 | 0 |
| all_x_le_005_no_CGH | 304 | source01, source09 | J, none | 0.075 - 0.436 | 3 - 27.4 | 20.98 - 365.3 | 0.255 - 7.79 | 16.6 - 626.1 | -0.82 - 0.05 | 0.79605 | 1 | 0.21711 | 0 |
| source01_G_legacy_range_0.136_5.23 | 348 | source01 | G, H, none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 0.166 - 5.23 | 0.7 - 626.1 | -0.457 - 0.85 | 0.37069 | 0.48276 | 0.30747 | 0 |
| source01_G_legacy_range_0.136_5.23_x_le_005 | 168 | source01 | G, none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 0.384 - 5.18 | 16.6 - 626.1 | -0.457 - 0.05 | 0.76786 | 1 | 0.39286 | 0 |
| source01_G_1p60_3p00 | 125 | source01 | none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 1.61 - 3 | 5.1 - 626.1 | -0.457 - 0.188 | 0.488 | 0.56 | 0.84 | 0 |
| source01_G_1p60_3p00_x_le_005 | 70 | source01 | none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 1.62 - 3 | 16.6 - 626.1 | -0.457 - 0.049 | 0.87143 | 1 | 0.92857 | 0 |
| source01_G_1p77_2p95 | 103 | source01 | none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 1.77 - 2.94 | 5.1 - 626.1 | -0.457 - 0.188 | 0.50485 | 0.58252 | 0.8835 | 0 |
| source01_G_1p77_2p95_x_le_005 | 60 | source01 | none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 1.77 - 2.9 | 16.6 - 626.1 | -0.457 - 0.049 | 0.86667 | 1 | 0.93333 | 0 |
| source01_x_le_005_TmTsat_available | 64 | source01 | none | 0.075 - 0.306 | 6 - 27.4 | 64.52 - 365.3 | 1.62 - 3 | 91.6 - 626.1 | -0.457 - 0.049 | 0.90625 | 1 | 1 | 0 |
| source01_x_le_005_Tm_le_Tsat_available | 64 | source01 | none | 0.075 - 0.306 | 6 - 27.4 | 64.52 - 365.3 | 1.62 - 3 | 91.6 - 626.1 | -0.457 - 0.049 | 0.90625 | 1 | 1 | 0 |
| source01_x_le_005_Tm_gt_Tsat_available | 0 |  |  |  |  |  |  |  |  |  |  |  |  |

## 8. Legacy scan

| file | sheet | n_rows | n_cols | n_matched_unique_expt | expt_columns | match_min_expt | match_max_expt |
|---|---|---|---|---|---|---|---|
| 164r1.xlsx | TEST SECTION NUMBER 164 | 10096 | 18 | 1 | Y | 1.01 | 1.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_ST | 86 | 70 | 95 | Fcorr, Fcorr2, No_TableNo, PM_ratio, Tf, Tin, Tm, UB, YB_plus, q_P_MW, y_plus2 | 1.01 | 599.09 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_108 | 14 | 70 | 2 | F2, q_P_MW | 1.01 | 2.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_161 | 23 | 70 | 4 | Tf, Tm, Tw, q_P_MW, tauw | 1.01 | 633.09 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_164 | 21 | 70 | 3 | (Tsub-40)^2, F_form, y_plus2 | 1.01 | 224.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1_ST | 86 | 70 | 91 | Fcorr, Fcorr2, No_TableNo, PM_ratio, Tin, Tw, UB | 1.01 | 627.09 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1_108 | 14 | 70 | 2 | F2, PM_ratio, y_plus2 | 1.01 | 32.07 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1_161 | 23 | 70 | 4 | PM_ratio, Q, YB_plus, tauw | 1.01 | 51.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1_164 | 21 | 70 | 3 | (Tsub-40)^2, F_form, Karman_UB, PM_ratio, q_P_MW | 1.01 | 224.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1F2_ST | 86 | 104 | 93 | F2_P, F_corr_before_ST_import, F_corr_with_F2P_candidate, Fcorr, Fcorr2, Fcorr2_before_STF2P_value, Fcorr_before_STF2P_value, No_TableNo, PM_ratio, PM_ratio_after_STF2P, PM_ratio_before_STF2P_value, PM_ratio_before_ST_import, ST_F2P_import_key, Tf, Tin, Tm, UB, UB_after_STF2P, delta_Tw_STF2P, q_P_MW | 1.01 | 599.09 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1F2_108 | 14 | 116 | 2 | F2, F2_P, PM_ratio, PM_ratio_after_F2P, PM_ratio_before_F2P_value, PM_ratio_before_macro_value, Q | 1.01 | 2.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1F2_161 | 23 | 116 | 3 | F2_P, F_corr_applied_value, F_corr_with_F2P, Fcorr, Fcorr2, Karman_UB, PM_ratio_before_F2P_value, PM_ratio_before_macro_value, YB_plus, delta_Tw, tauw | 1.01 | 51.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1F2_164 | 21 | 116 | 4 | (Tsub-40)^2, F2_P, F_corr_applied_value, F_corr_with_F2P, F_form, Fcorr, Fcorr2, Karman_UB, PM_ratio_before_F2P_value, PM_ratio_before_macro_value, Q, Tw, Tw_after_F2P | 1.01 | 642.09 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_ST_add_TM11_14_noF1_raw | 18 | 70 | 9 | No_TableNo, Tf, Tm, y_plus2 | 10.01 | 533.09 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_ST_add_TM11_14_F1_raw | 18 | 70 | 9 | No_TableNo, Tf, Tm, y_plus2 | 10.01 | 533.09 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_ST_add_TM11_14_diag | 18 | 26 | 7 | No_TableNo | 24.01 | 30.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | LDH_graph_candidates | 21 | 13 | 1 | Tsub_K_mean | 61.01 | 61.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | TM10_vs_TM11_14_diag | 106 | 34 | 9 | H-52G: Table10（短管・P=13.79MPa固定）基準による T&M Table11-14 追加データの過大評価診, Table10（短管 L/DH 62-80）, Var5, Var6, Var7, Var8 | 1.01 | 30.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | LUT_input_TM10_TM11_14 | 120 | 16 | 94 | PM_F1, case_id | 1.01 | 498.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | master_curve_PM_vs_xMes | 165 | 40 | 1 | D≈11.8-12.9mm バンドル, D≈4.6-4.8mm 単管(T10), Table10 単管・一様 (L/DH 62-80) | 1.01 | 1.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52O_TM_audit | 75 | 30 | 7 | Var3, 対象 | 24.01 | 30.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52O_source_trace | 32 | 16 | 7 | T&M_expt_no | 24.01 | 30.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52Q_Tsub_LD_residual | 168 | 43 | 94 | PM_F1, case_id | 1.01 | 498.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52Q_graphs | 167 | 34 | 1 | Var18, Var27 | 1.01 | 1.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52Q_pattern_review | 62 | 19 | 1 | min_L_over_D | 61.01 | 61.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52Q_review_packet | 57 | 23 | 1 | mean_Delta_T_sub, mean_L_over_D | 61.01 | 61.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52Q_TM_corr | 275 | 23 | 94 | Var13, Var14, Var15, candidate, formula_note, warning | 1.01 | 498.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52Q_TM_valid | 334 | 23 | 94 | Chart helper: PM after B2 vs PM after C, Var1, Var14, Var15, Var18, Var19, Var2, Var22, Var23, Var4, Var5, Var6, Var7, Var8, Var9 | 1.01 | 498.01 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_r124_F1_T8_14 | 224 | 70 | 111 | Fcorr, Fcorr2, Karman_UB, No_TableNo, PM_ratio, Tf, Tin, Tm, Tw, UB, UBL, f_left, f_rihgt, q_P_MW, y_plus2 | 1.01 | 632.09 |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_r123_noF1_T8_14 | 224 | 70 | 113 | Karman_UB, No_TableNo, PM_ratio, Q, Tf, Tin, Tm, UB, UBL, YB_plus, f_left, f_rihgt, q_P_MW, y_plus2 | 1.01 | 599.09 |
| 20260612_計算結果比較r8_staging_TM8_14_v1.xlsx | SRC_tm_r123_noF1_T8_14 | 224 | 70 | 113 | Karman_UB, No_TableNo, PM_ratio, Q, Tf, Tin, Tm, UB, UBL, YB_plus, f_left, f_rihgt, q_P_MW, y_plus2 | 1.01 | 599.09 |
| 20260612_計算結果比較r8_staging_TM8_14_v1.xlsx | SRC_tm_r124_F1_T8_14 | 224 | 70 | 111 | Fcorr, Fcorr2, Karman_UB, No_TableNo, PM_ratio, Tf, Tin, Tm, Tw, UB, UBL, f_left, f_rihgt, q_P_MW, y_plus2 | 1.01 | 632.09 |
| 20260612_計算結果比較r8_staging_TM8_14_v1.xlsx | STG_added138_noF1 | 138 | 79 | 35 | Karman_UB, No_TableNo, PM_ratio, Q, Tf, Tin, Tm, UB, UBL, YB_plus, f_left, f_rihgt, q_P_MW, y_plus2 | 1.01 | 563.09 |
| 20260612_計算結果比較r8_staging_TM8_14_v1.xlsx | STG_added138_F1 | 138 | 79 | 35 | Fcorr, Fcorr2, Karman_UB, No_TableNo, PM_ratio, Tf, Tin, Tm, Tw, UB, UBL, f_left, f_rihgt, q_P_MW, y_plus2 | 1.01 | 632.09 |
| BT01_02_current_bundle_repro_20260615_184359.xlsx | BT02_108_contrast | 17 | 7 | 1 | mean_161_164 | 324.09 | 324.09 |
| BT01_02_current_bundle_repro_20260615_184359.xlsx | paired_points | 58 | 21 | 3 | F_form, PM_F1, PM_lift_ratio_F1_over_noF1, Tw_minus_Tsat_K, q_calc_F1_MWm2, q_calc_noF1_MWm2, qcalc_lift_ratio_F1_over_noF1 | 1.01 | 31.07 |
| BT01_02_current_bundle_repro_20260615_184359.xlsx | point_detail | 116 | 27 | 5 | F_form, PM, Tm_K, Tw_K, Tw_minus_Tsat_K, q_calc_MWm2 | 1.01 | 633.09 |
| BT01_bundle_108_161_164_MATLAB_repro_20260615_171136.xlsx | BT01_point_detail | 116 | 32 | 6 | F_form, PM, Tm_K, Tw_K, Tw_minus_Tsat_K, q_calc_MWm2, tauw | 1.01 | 633.09 |
| BT01_bundle_108_161_164_MATLAB_repro_20260615_171136.xlsx | BT01_delta_108_vs_161164 | 24 | 6 | 1 | mean_161_164 | 324.09 | 324.09 |
| BT01_bundle_108_161_164_diagnostic_20260615.xlsx | BT01_row_extract | 116 | 30 | 6 | F_form, PM_calc_over_exp, Tm_K, Tw_K, Tw_minus_Tsat_K, q_calc_MWm2, tauw | 1.01 | 633.09 |

... truncated to first 40 rows ...

## 9. Tm/Tsat audit

Tm/Tsat candidate rows were detected. See Excel sheets `TmTsat_audit_raw`, `TmTsat_available_rows`, and `Tm_gt_Tsat_rows`.

| group | N | sources | flags | D_range | L_range | LD_range | G_range | Hsub_range | x_report_range | frac_x_le_0 | frac_x_le_005 | frac_legacy | frac_Tm_gt_Tsat_available |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Tm_gt_Tsat_available | 0 |  |  |  |  |  |  |  |  |  |  |  |  |
| Tm_le_Tsat_available | 103 | source01 | none | 0.075 - 0.306 | 6 - 27.4 | 64.52 - 365.3 | 1.62 - 3 | 17.8 - 626.1 | -0.457 - 0.137 | 0.56311 | 0.62136 | 1 | 0 |

## 10. 一次判断

このrunでは、Table10旧採用点を絶対基準として再現するのではなく、初期検討用の厳選集合として位置づける。

重要なのは、F1を作り直す場合に、過去の手作業除外条件をそのまま継承しないことである。特に、F1適用時にTmがTsatを越した点を過去に除外していたとしても、それは「現行F1を維持して使うための品質管理」だった可能性がある。F1自体を作り直すなら、これらの点は除外ではなく、まず別管理の監査対象とする。

## 11. 採用・保留

```text
採用:
  - Table10 raw_allは649点として固定する。
  - Table10旧採用点は、初期検討用に厳選された集合として扱う。
  - Table11/12追加時の抽出思想とは同一視しない。
  - Tm>Tsat疑い点は、除外ではなく別管理で監査する。

保留:
  - exact legacy 86点の確実なIDリスト。
  - Tm>Tsat除外条件の再現。
  - F1固定運用ならTm>Tsatを切るべきか。
  - F1再設計ならTm>Tsat点も学習候補に戻すべきか。
```

## 12. 次アクション

- exact legacy 86 ID が分かる場合は `Table10_legacy86_exptno.txt` を作り、再実行する。
- Tm/Tsatを含む旧計算ブックを同じフォルダに置き、`Tm > Tsat` 除外候補を再現する。
- 次runでは、`source01_lowX_not_legacy` と `Tm_gt_Tsat_rows` を照合し、過去に切った理由を分類する。
- まだPM計算やF1再fitへは進まない。

## 13. Figures

- `fig_T10R01b_01_source_counts_20260625_130625.png`
- `fig_T10R01b_02_candidate_counts_20260625_130625.png`
- `fig_T10R01b_03_x_vs_G_legacy_lowX_20260625_130625.png`
