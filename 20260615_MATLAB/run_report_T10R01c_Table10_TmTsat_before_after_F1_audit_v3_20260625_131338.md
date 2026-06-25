# T10R01c_Table10_TmTsat_before_after_F1_audit_v3

作成日時: `2026-06-25 13:15:04`

## 1. 目的

T10R01b v2ではTm/Tsatを監査したが、F1適用前(noF1)とF1適用後(F1)を明示的に分けていなかった。

このrunでは、ユーザーコメント「F1適用後にTm>Tsat、F1適用前は該当なし」を確認するため、計算モード別にTm/Tsatを監査する。

このrunでも採用点は決めない。F1再設計時にはTm>Tsatを除外条件ではなく監査フラグとして扱う。

## 2. 入力

- Table10正本Markdown: `W:\thompson_macbeth_table10_2000psia_r1.md`
- 出力Excel: `T10R01c_Table10_TmTsat_before_after_F1_audit_v3_20260625_131338.xlsx`
- legacy mode: `none`
- manual legacy source: `none`

## 3. QC

- Parsed Table10 rows: `649`
- Rows with noF1 Tm/Tsat available: `103`
- Rows with F1 Tm/Tsat available: `103`
- noF1 rows with Tm > Tsat: `0`
- F1 rows with Tm > Tsat: `40`
- F1-only Tm > Tsat rows: `40`

## 4. Mode summary

| calc_mode | N_expt | N_Tm_gt_Tsat | frac_Tm_gt_Tsat | TmMinusTsat_max_range | Expt_range |
|---|---|---|---|---|---|
| noF1 | 103 | 0 | 0 | -144 - -2.626 | 1.01 - 498 |
| F1 | 103 | 40 | 0.38835 | -144 - 12.05 | 1.01 - 498 |
| F1F2 | 86 | 42 | 0.48837 | -140 - 16.98 | 9.01 - 498 |
| unknown | 0 | 0 |  |  |  |

## 5. Source summary

| source_label | N | sources | flags | D_range | L_range | LD_range | G_range | Hsub_range | x_report_range | frac_x_le_0 | frac_x_le_005 | frac_legacy |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| source01 | 388 | source01 | G, H, none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 0.0281 - 7.79 | 0.7 - 626.1 | -0.459 - 1.069 | 0.38918 | 0.48969 | 0 |
| source07 | 4 | source07 | C, none | 0.12 - 0.18 | 6 - 9.4 | 50 - 52.22 | 0.023 - 0.07 | 316.9 - 537.2 | 0.213 - 0.905 | 0 | 0 | 0 |
| source09 | 232 | source09 | DJ, J, none | 0.304 - 0.436 | 18 - 18 | 41.28 - 59.21 | 0.126 - 2 | 0 - 601 | -0.82 - 0.72 | 0.40086 | 0.50431 | 0 |
| source11 | 25 | source11 | none | 0.411 - 0.415 | 72 - 72 | 173.5 - 175.2 | 0.5 - 1.3 | 15.9 - 242 | 0.183 - 0.515 | 0 | 0 | 0 |

## 6. noF1 Tm > Tsat rows

(empty)

## 7. F1 Tm > Tsat rows

| ExptNo | calc_mode | N_rows | N_sources | Tm_minus_Tsat_min | Tm_minus_Tsat_max | Tm_minus_Tsat_mean | Tm_gt_Tsat_any | max_source_sheet | max_Tm_column | max_Tsat_column | max_Tm_value | max_Tsat_value | source_label | flag_norm | Dia_in | Length_in | L_over_D | G_1e6_lb_hr_ft2 | InletSubcool_BTUlb | ExitQuality | lowX_le_005 | legacy_selected_flag |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 130.01 | F1 | 4 | 4 | 1.1626 | 1.1626 | 1.1626 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 609.78 | 608.62 | source01 | none | 0.186 | 12 | 64.516 | 2.035 | 94.3 | 0.052 | 0 | 0 |
| 143.01 | F1 | 4 | 4 | 4.8533 | 4.8533 | 4.8533 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 613.47 | 608.62 | source01 | none | 0.186 | 12 | 64.516 | 2.64 | 61.4 | 0.081 | 0 | 0 |
| 192.01 | F1 | 4 | 4 | 7.9656 | 7.9656 | 7.9656 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 616.59 | 608.62 | source01 | none | 0.187 | 12.5 | 66.845 | 2.03 | 57.3 | 0.117 | 0 | 0 |
| 194.01 | F1 | 4 | 4 | 2.3628 | 2.3628 | 2.3628 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 610.98 | 608.62 | source01 | none | 0.187 | 12.5 | 66.845 | 2.11 | 89 | 0.079 | 0 | 0 |
| 195.01 | F1 | 4 | 4 | 2.1103 | 2.1103 | 2.1103 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 610.73 | 608.62 | source01 | none | 0.187 | 12.5 | 66.845 | 2.11 | 90.3 | 0.087 | 0 | 0 |
| 211.01 | F1 | 4 | 4 | 11.077 | 11.077 | 11.077 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 619.7 | 608.62 | source01 | none | 0.187 | 12.5 | 66.845 | 2.73 | 17.8 | 0.13 | 0 | 0 |
| 212.01 | F1 | 4 | 4 | 10.713 | 10.713 | 10.713 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 619.33 | 608.62 | source01 | none | 0.187 | 12.5 | 66.845 | 2.78 | 20.3 | 0.13 | 0 | 0 |
| 214.01 | F1 | 4 | 4 | 5.311 | 5.311 | 5.311 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 613.93 | 608.62 | source01 | none | 0.187 | 12.5 | 66.845 | 2.88 | 57.3 | 0.089 | 0 | 0 |
| 215.01 | F1 | 4 | 4 | 5.0162 | 5.0162 | 5.0162 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 613.64 | 608.62 | source01 | none | 0.187 | 12.5 | 66.845 | 2.93 | 57.3 | 0.072 | 0 | 0 |
| 491.01 | F1 | 4 | 4 | 6.1212 | 6.1212 | 6.1212 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 614.74 | 608.62 | source01 | none | 0.306 | 23.25 | 75.98 | 2.04 | 67 | 0.083 | 0 | 0 |
| 492.01 | F1 | 4 | 4 | 5.8982 | 5.8982 | 5.8982 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 614.52 | 608.62 | source01 | none | 0.306 | 23.25 | 75.98 | 2.04 | 68.4 | 0.082 | 0 | 0 |
| 493.01 | F1 | 4 | 4 | 1.321 | 1.321 | 1.321 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 609.94 | 608.62 | source01 | none | 0.306 | 23.25 | 75.98 | 2.13 | 91.6 | 0.049 | 1 | 0 |
| 494.01 | F1 | 4 | 4 | 6.148 | 6.148 | 6.148 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 614.77 | 608.62 | source01 | none | 0.306 | 23.25 | 75.98 | 2.15 | 64.2 | 0.081 | 0 | 0 |
| 495.01 | F1 | 4 | 4 | 5.9246 | 5.9246 | 5.9246 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 614.55 | 608.62 | source01 | none | 0.306 | 23.25 | 75.98 | 2.15 | 65.6 | 0.077 | 0 | 0 |
| 496.01 | F1 | 4 | 4 | 0.13141 | 0.13141 | 0.13141 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 608.75 | 608.62 | source01 | none | 0.306 | 23.25 | 75.98 | 2.21 | 95.6 | 0.037 | 1 | 0 |
| 51.01 | F1 | 4 | 4 | 12.051 | 12.051 | 12.051 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 620.67 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.03 | 20.3 | 0.137 | 0 | 0 |
| 52.01 | F1 | 4 | 4 | 8.3051 | 8.3051 | 8.3051 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 616.93 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.51 | 42.2 | 0.061 | 0 | 0 |
| 53.01 | F1 | 4 | 4 | 11.203 | 11.203 | 11.203 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 619.82 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.51 | 18.6 | 0.079 | 0 | 0 |
| 54.01 | F1 | 4 | 4 | 11.018 | 11.018 | 11.018 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 619.64 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.51 | 20.3 | 0.075 | 0 | 0 |
| 55.01 | F1 | 4 | 4 | 8.9269 | 8.9269 | 8.9269 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 617.55 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.51 | 37.6 | 0.107 | 0 | 0 |
| 56.01 | F1 | 4 | 4 | 8.0178 | 8.0178 | 8.0178 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 616.64 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.54 | 43.7 | 0.093 | 0 | 0 |
| 57.01 | F1 | 4 | 4 | 7.8045 | 7.8045 | 7.8045 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 616.43 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.54 | 45.2 | 0.092 | 0 | 0 |
| 58.01 | F1 | 4 | 4 | 9.2483 | 9.2483 | 9.2483 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 617.87 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.54 | 34.6 | 0.073 | 0 | 0 |
| 59.01 | F1 | 4 | 4 | 9.0522 | 9.0522 | 9.0522 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 617.67 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.54 | 36.1 | 0.072 | 0 | 0 |
| 60.01 | F1 | 4 | 4 | 8.855 | 8.855 | 8.855 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 617.48 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.54 | 37.6 | 0.068 | 0 | 0 |
| 61.01 | F1 | 4 | 4 | 4.7306 | 4.7306 | 4.7306 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 613.35 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.57 | 64.2 | 0.077 | 0 | 0 |
| 62.01 | F1 | 4 | 4 | 4.2442 | 4.2442 | 4.2442 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 612.87 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.57 | 67 | 0.07 | 0 | 0 |
| 63.01 | F1 | 4 | 4 | 3.9971 | 3.9971 | 3.9971 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 612.62 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.57 | 68.4 | 0.069 | 0 | 0 |
| 64.01 | F1 | 4 | 4 | 4.1481 | 4.1481 | 4.1481 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 612.77 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.6 | 67 | 0.065 | 0 | 0 |
| 65.01 | F1 | 4 | 4 | 10.511 | 10.511 | 10.511 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 619.13 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.68 | 22 | 0.096 | 0 | 0 |
| 66.01 | F1 | 4 | 4 | 10.511 | 10.511 | 10.511 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 619.13 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.68 | 22 | 0.105 | 0 | 0 |
| 67.01 | F1 | 4 | 4 | 10.255 | 10.255 | 10.255 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 618.88 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.71 | 23.7 | 0.102 | 0 | 0 |
| 68.01 | F1 | 4 | 4 | 9.0108 | 9.0108 | 9.0108 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 617.63 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.74 | 33.1 | 0.092 | 0 | 0 |
| 69.01 | F1 | 4 | 4 | 8.1044 | 8.1044 | 8.1044 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 616.73 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.88 | 37.6 | 0.074 | 0 | 0 |
| 70.01 | F1 | 4 | 4 | 7.812 | 7.812 | 7.812 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 616.43 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.91 | 39.2 | 0.076 | 0 | 0 |
| 72.01 | F1 | 4 | 4 | 7.5305 | 7.5305 | 7.5305 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 616.15 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.94 | 40.7 | 0.073 | 0 | 0 |
| 73.01 | F1 | 4 | 4 | 8.786 | 8.786 | 8.786 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 617.41 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.96 | 31.6 | 0.081 | 0 | 0 |
| 74.01 | F1 | 4 | 4 | 9.1198 | 9.1198 | 9.1198 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 617.74 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 3 | 28.6 | 0.091 | 0 | 0 |
| 75.01 | F1 | 4 | 4 | 8.9171 | 8.9171 | 8.9171 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 617.54 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 3 | 30.1 | 0.087 | 0 | 0 |
| 76.01 | F1 | 4 | 4 | 8.5059 | 8.5059 | 8.5059 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 617.13 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 3 | 33.1 | 0.086 | 0 | 0 |

## 8. F1-only Tm > Tsat rows

| ExptNo | calc_mode | N_rows | N_sources | Tm_minus_Tsat_min | Tm_minus_Tsat_max | Tm_minus_Tsat_mean | Tm_gt_Tsat_any | max_source_sheet | max_Tm_column | max_Tsat_column | max_Tm_value | max_Tsat_value | source_label | flag_norm | Dia_in | Length_in | L_over_D | G_1e6_lb_hr_ft2 | InletSubcool_BTUlb | ExitQuality | lowX_le_005 | legacy_selected_flag |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 130.01 | F1 | 4 | 4 | 1.1626 | 1.1626 | 1.1626 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 609.78 | 608.62 | source01 | none | 0.186 | 12 | 64.516 | 2.035 | 94.3 | 0.052 | 0 | 0 |
| 143.01 | F1 | 4 | 4 | 4.8533 | 4.8533 | 4.8533 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 613.47 | 608.62 | source01 | none | 0.186 | 12 | 64.516 | 2.64 | 61.4 | 0.081 | 0 | 0 |
| 192.01 | F1 | 4 | 4 | 7.9656 | 7.9656 | 7.9656 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 616.59 | 608.62 | source01 | none | 0.187 | 12.5 | 66.845 | 2.03 | 57.3 | 0.117 | 0 | 0 |
| 194.01 | F1 | 4 | 4 | 2.3628 | 2.3628 | 2.3628 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 610.98 | 608.62 | source01 | none | 0.187 | 12.5 | 66.845 | 2.11 | 89 | 0.079 | 0 | 0 |
| 195.01 | F1 | 4 | 4 | 2.1103 | 2.1103 | 2.1103 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 610.73 | 608.62 | source01 | none | 0.187 | 12.5 | 66.845 | 2.11 | 90.3 | 0.087 | 0 | 0 |
| 211.01 | F1 | 4 | 4 | 11.077 | 11.077 | 11.077 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 619.7 | 608.62 | source01 | none | 0.187 | 12.5 | 66.845 | 2.73 | 17.8 | 0.13 | 0 | 0 |
| 212.01 | F1 | 4 | 4 | 10.713 | 10.713 | 10.713 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 619.33 | 608.62 | source01 | none | 0.187 | 12.5 | 66.845 | 2.78 | 20.3 | 0.13 | 0 | 0 |
| 214.01 | F1 | 4 | 4 | 5.311 | 5.311 | 5.311 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 613.93 | 608.62 | source01 | none | 0.187 | 12.5 | 66.845 | 2.88 | 57.3 | 0.089 | 0 | 0 |
| 215.01 | F1 | 4 | 4 | 5.0162 | 5.0162 | 5.0162 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 613.64 | 608.62 | source01 | none | 0.187 | 12.5 | 66.845 | 2.93 | 57.3 | 0.072 | 0 | 0 |
| 491.01 | F1 | 4 | 4 | 6.1212 | 6.1212 | 6.1212 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 614.74 | 608.62 | source01 | none | 0.306 | 23.25 | 75.98 | 2.04 | 67 | 0.083 | 0 | 0 |
| 492.01 | F1 | 4 | 4 | 5.8982 | 5.8982 | 5.8982 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 614.52 | 608.62 | source01 | none | 0.306 | 23.25 | 75.98 | 2.04 | 68.4 | 0.082 | 0 | 0 |
| 493.01 | F1 | 4 | 4 | 1.321 | 1.321 | 1.321 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 609.94 | 608.62 | source01 | none | 0.306 | 23.25 | 75.98 | 2.13 | 91.6 | 0.049 | 1 | 0 |
| 494.01 | F1 | 4 | 4 | 6.148 | 6.148 | 6.148 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 614.77 | 608.62 | source01 | none | 0.306 | 23.25 | 75.98 | 2.15 | 64.2 | 0.081 | 0 | 0 |
| 495.01 | F1 | 4 | 4 | 5.9246 | 5.9246 | 5.9246 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 614.55 | 608.62 | source01 | none | 0.306 | 23.25 | 75.98 | 2.15 | 65.6 | 0.077 | 0 | 0 |
| 496.01 | F1 | 4 | 4 | 0.13141 | 0.13141 | 0.13141 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 608.75 | 608.62 | source01 | none | 0.306 | 23.25 | 75.98 | 2.21 | 95.6 | 0.037 | 1 | 0 |
| 51.01 | F1 | 4 | 4 | 12.051 | 12.051 | 12.051 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 620.67 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.03 | 20.3 | 0.137 | 0 | 0 |
| 52.01 | F1 | 4 | 4 | 8.3051 | 8.3051 | 8.3051 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 616.93 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.51 | 42.2 | 0.061 | 0 | 0 |
| 53.01 | F1 | 4 | 4 | 11.203 | 11.203 | 11.203 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 619.82 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.51 | 18.6 | 0.079 | 0 | 0 |
| 54.01 | F1 | 4 | 4 | 11.018 | 11.018 | 11.018 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 619.64 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.51 | 20.3 | 0.075 | 0 | 0 |
| 55.01 | F1 | 4 | 4 | 8.9269 | 8.9269 | 8.9269 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 617.55 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.51 | 37.6 | 0.107 | 0 | 0 |
| 56.01 | F1 | 4 | 4 | 8.0178 | 8.0178 | 8.0178 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 616.64 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.54 | 43.7 | 0.093 | 0 | 0 |
| 57.01 | F1 | 4 | 4 | 7.8045 | 7.8045 | 7.8045 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 616.43 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.54 | 45.2 | 0.092 | 0 | 0 |
| 58.01 | F1 | 4 | 4 | 9.2483 | 9.2483 | 9.2483 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 617.87 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.54 | 34.6 | 0.073 | 0 | 0 |
| 59.01 | F1 | 4 | 4 | 9.0522 | 9.0522 | 9.0522 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 617.67 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.54 | 36.1 | 0.072 | 0 | 0 |
| 60.01 | F1 | 4 | 4 | 8.855 | 8.855 | 8.855 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 617.48 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.54 | 37.6 | 0.068 | 0 | 0 |
| 61.01 | F1 | 4 | 4 | 4.7306 | 4.7306 | 4.7306 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 613.35 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.57 | 64.2 | 0.077 | 0 | 0 |
| 62.01 | F1 | 4 | 4 | 4.2442 | 4.2442 | 4.2442 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 612.87 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.57 | 67 | 0.07 | 0 | 0 |
| 63.01 | F1 | 4 | 4 | 3.9971 | 3.9971 | 3.9971 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 612.62 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.57 | 68.4 | 0.069 | 0 | 0 |
| 64.01 | F1 | 4 | 4 | 4.1481 | 4.1481 | 4.1481 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 612.77 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.6 | 67 | 0.065 | 0 | 0 |
| 65.01 | F1 | 4 | 4 | 10.511 | 10.511 | 10.511 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 619.13 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.68 | 22 | 0.096 | 0 | 0 |
| 66.01 | F1 | 4 | 4 | 10.511 | 10.511 | 10.511 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 619.13 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.68 | 22 | 0.105 | 0 | 0 |
| 67.01 | F1 | 4 | 4 | 10.255 | 10.255 | 10.255 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 618.88 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.71 | 23.7 | 0.102 | 0 | 0 |
| 68.01 | F1 | 4 | 4 | 9.0108 | 9.0108 | 9.0108 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 617.63 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.74 | 33.1 | 0.092 | 0 | 0 |
| 69.01 | F1 | 4 | 4 | 8.1044 | 8.1044 | 8.1044 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 616.73 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.88 | 37.6 | 0.074 | 0 | 0 |
| 70.01 | F1 | 4 | 4 | 7.812 | 7.812 | 7.812 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 616.43 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.91 | 39.2 | 0.076 | 0 | 0 |
| 72.01 | F1 | 4 | 4 | 7.5305 | 7.5305 | 7.5305 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 616.15 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.94 | 40.7 | 0.073 | 0 | 0 |
| 73.01 | F1 | 4 | 4 | 8.786 | 8.786 | 8.786 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 617.41 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 2.96 | 31.6 | 0.081 | 0 | 0 |
| 74.01 | F1 | 4 | 4 | 9.1198 | 9.1198 | 9.1198 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_r124_F1_T8_14 | Tm | Ts | 617.74 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 3 | 28.6 | 0.091 | 0 | 0 |
| 75.01 | F1 | 4 | 4 | 8.9171 | 8.9171 | 8.9171 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 617.54 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 3 | 30.1 | 0.087 | 0 | 0 |
| 76.01 | F1 | 4 | 4 | 8.5059 | 8.5059 | 8.5059 | 1 | 20260612_計算結果比較r8_result_文献追加用.xlsx :: tm_F1_ST | Tm | Ts | 617.13 | 608.62 | source01 | none | 0.18 | 11.625 | 64.583 | 3 | 33.1 | 0.086 | 0 | 0 |

## 9. Sheet scan log

| file | sheet | calc_mode | context_score | context_text | n_rows | n_cols | expt_cols | Tm_cols | Tsat_cols |
|---|---|---|---|---|---|---|---|---|---|
| 164r1.xlsx | TEST SECTION NUMBER 164 | unknown | 0 | mode_unknown | 10096 | 18 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 00_RESULT_README | unknown | 0 | mode_unknown | 54 | 1 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 00_SHEET_MAP | unknown | 0 | mode_unknown | 29 | 10 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 00_DATA_ADDITION_FLOW | unknown | 0 | mode_unknown | 18 | 7 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 00_TM8_14_IMPORT_PLAN | unknown | 0 | mode_unknown | 47 | 5 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 00_ARCHIVE_MAP | unknown | 0 | mode_unknown | 13 | 5 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 00_CURRENT_PUBLIC_SUMMARY | unknown | 0 | mode_unknown | 20 | 5 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 01_PUBLIC_GRAPH_DATA | unknown | 0 | mode_unknown | 9 | 7 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 02_LDNB_GEOMETRY_DIAGNOSTIC | unknown | 0 | mode_unknown | 21 | 8 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 03_GEOMETRY_LDH_SEARCH | unknown | 0 | mode_unknown | 29 | 9 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | literature_candidate_list | unknown | 0 | mode_unknown | 38 | 26 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_ST | noF1 | 50 | single tube raw/noF1-like sheet | 86 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_108 | unknown | 0 | mode_unknown | 14 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_161 | unknown | 0 | mode_unknown | 23 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_164 | unknown | 0 | mode_unknown | 21 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1_ST | F1 | 80 | sheet/file contains F1 or r124 | 86 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1_108 | F1 | 80 | sheet/file contains F1 or r124 | 14 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1_161 | F1 | 80 | sheet/file contains F1 or r124 | 23 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1_164 | F1 | 80 | sheet/file contains F1 or r124 | 21 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1F2_ST | F1F2 | 80 | sheet/file contains F1F2 | 86 | 104 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1F2_108 | F1F2 | 80 | sheet/file contains F1F2 | 14 | 116 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1F2_161 | F1F2 | 80 | sheet/file contains F1F2 | 23 | 116 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1F2_164 | F1F2 | 80 | sheet/file contains F1F2 | 21 | 116 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 99_RESULT_CLEANUP_QC_H50H2 | unknown | 0 | mode_unknown | 107 | 7 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_ST_add_TM11_14_noF1_raw | noF1 | 80 | sheet/file contains noF1 or r123 | 18 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_ST_add_TM11_14_F1_raw | F1 | 80 | sheet/file contains F1 or r124 | 18 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_ST_add_TM11_14_diag | noF1 | 50 | single tube raw/noF1-like sheet | 18 | 26 | No_TableNo |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_ST_add_TM11_14_summary | noF1 | 50 | single tube raw/noF1-like sheet | 4 | 24 |  | Delta_PM_percent_min, Delta_PM_percent_max, Delta_PM_percent_mean |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | LDH_diagnostic_all | unknown | 0 | mode_unknown | 7 | 32 |  | Delta_PM_percent_mean |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | LDH_graph_candidates | unknown | 0 | mode_unknown | 21 | 13 |  | Delta_PM_percent_mean |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | TM10_vs_TM11_14_diag | unknown | 0 | mode_unknown | 106 | 34 |  | H-52G: Table10（短管・P=13.79MPa固定）基準による T&M Table11-14 追加データの過大評価診, T&M Table11-14（L/DH 365） |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | LUT_input_TM10_TM11_14 | unknown | 0 | mode_unknown | 120 | 16 | case_id |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | master_curve_PM_vs_xMes | unknown | 0 | mode_unknown | 165 | 40 |  | T&M Tbl11-14 単管・一様 (L/DH 365), D≈1.9mm 単管(T10+T&M) |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | energy_balance_LD_constraint | unknown | 0 | mode_unknown | 44 | 20 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52K_hypotheses | unknown | 0 | mode_unknown | 37 | 9 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52_overview | unknown | 0 | mode_unknown | 40 | 8 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52O_TM_audit | unknown | 0 | mode_unknown | 75 | 30 |  | 原表値（T&M、英単位、ユーザー提供転記） |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52O_source_trace | unknown | 0 | mode_unknown | 32 | 16 | T&M_expt_no | T&M_table, T&M_expt_no, T&M_ref_no, T&M_ref_title |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52Q_Tsub_LD_residual | unknown | 0 | mode_unknown | 168 | 43 | case_id |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52Q_graphs | unknown | 0 | mode_unknown | 167 | 34 |  |  |  |

... truncated to first 40 rows ...

## 10. Column detection log

| file | sheet | calc_mode | n_rows | n_cols | expt_cols | Tm_cols | Tsat_cols |
|---|---|---|---|---|---|---|---|
| 164r1.xlsx | TEST SECTION NUMBER 164 | unknown | 10096 | 18 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 00_RESULT_README | unknown | 54 | 1 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 00_SHEET_MAP | unknown | 29 | 10 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 00_DATA_ADDITION_FLOW | unknown | 18 | 7 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 00_TM8_14_IMPORT_PLAN | unknown | 47 | 5 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 00_ARCHIVE_MAP | unknown | 13 | 5 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 00_CURRENT_PUBLIC_SUMMARY | unknown | 20 | 5 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 01_PUBLIC_GRAPH_DATA | unknown | 9 | 7 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 02_LDNB_GEOMETRY_DIAGNOSTIC | unknown | 21 | 8 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 03_GEOMETRY_LDH_SEARCH | unknown | 29 | 9 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | literature_candidate_list | unknown | 38 | 26 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_ST | noF1 | 86 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_108 | unknown | 14 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_161 | unknown | 23 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_164 | unknown | 21 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1_ST | F1 | 86 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1_108 | F1 | 14 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1_161 | F1 | 23 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1_164 | F1 | 21 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1F2_ST | F1F2 | 86 | 104 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1F2_108 | F1F2 | 14 | 116 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1F2_161 | F1F2 | 23 | 116 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_F1F2_164 | F1F2 | 21 | 116 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | 99_RESULT_CLEANUP_QC_H50H2 | unknown | 107 | 7 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_ST_add_TM11_14_noF1_raw | noF1 | 18 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_ST_add_TM11_14_F1_raw | F1 | 18 | 70 | No_TableNo | Tm | Ts |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_ST_add_TM11_14_diag | noF1 | 18 | 26 | No_TableNo |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_ST_add_TM11_14_summary | noF1 | 4 | 24 |  | Delta_PM_percent_min, Delta_PM_percent_max, Delta_PM_percent_mean |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | LDH_diagnostic_all | unknown | 7 | 32 |  | Delta_PM_percent_mean |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | LDH_graph_candidates | unknown | 21 | 13 |  | Delta_PM_percent_mean |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | TM10_vs_TM11_14_diag | unknown | 106 | 34 |  | H-52G: Table10（短管・P=13.79MPa固定）基準による T&M Table11-14 追加データの過大評価診, T&M Table11-14（L/DH 365） |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | LUT_input_TM10_TM11_14 | unknown | 120 | 16 | case_id |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | master_curve_PM_vs_xMes | unknown | 165 | 40 |  | T&M Tbl11-14 単管・一様 (L/DH 365), D≈1.9mm 単管(T10+T&M) |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | energy_balance_LD_constraint | unknown | 44 | 20 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52K_hypotheses | unknown | 37 | 9 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52_overview | unknown | 40 | 8 |  |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52O_TM_audit | unknown | 75 | 30 |  | 原表値（T&M、英単位、ユーザー提供転記） |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52O_source_trace | unknown | 32 | 16 | T&M_expt_no | T&M_table, T&M_expt_no, T&M_ref_no, T&M_ref_title |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52Q_Tsub_LD_residual | unknown | 168 | 43 | case_id |  |  |
| 20260612_計算結果比較r8_result_文献追加用.xlsx | internal_H52Q_graphs | unknown | 167 | 34 |  |  |  |

... truncated to first 40 rows ...

## 11. 一次判断テンプレート

```text
T10R01b v2の「Tm>Tsat=0」は、F1前後を分けていないため、F1適用後の除外条件を再現したものとは扱わない。
T10R01c v3では、noF1とF1を分けてTm/Tsatを確認した。
F1後にのみTm>Tsatが出る場合、それは現行F1固定運用のQC条件としては意味があるが、F1再設計では自動除外せず監査フラグとして保持する。
```

## 12. 次アクション

- run_report_T10R01c_*.mdを確認し、F1後Tm>Tsat点の有無とIDをログへ追記する。
- F1固定用集合ではTm>Tsat除外あり/なしを分ける。
- F1再設計用集合ではTm>Tsat点を除外せず、監査フラグとして保持する。

## 13. Figures

- `fig_T10R01c_01_Tm_gt_Tsat_by_mode_20260625_131338.png`
- `fig_T10R01c_02_F1_TmMinusTsat_vs_G_20260625_131338.png`
