# BT14-B2 F_form consistency check

作成日時: 20260617

## 1. 目的

BT14-Bでは、BT08-A1dのlinear_v1定義を正本として再利用し、BT13-B正本入力内F_formとの照合を行う予定だった。
しかし、current inputの読み込みが0行となり、F_form照合が未完了だった。
BT14-B2では、シート名確認と読み込み状態を明示し、current inputのF_formがBT08-A1d linear_v1と一致するかを再確認する。

## 2. 入力

- current input: `H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx`
- BT08-A1d report: `run_report_BT08A1d_Fform_linear_finalize_20260616_144056.md`
- BT14-A report: `run_report_BT14A_Fform_position_shape_diag_20260617_093233.md`
- previous BT14-B report: `run_report_BT14B_Fform_reintegration_audit_closure_20260617_094603.md`

## 3. 出力

- output Excel: `BT14B2_Fform_consistency_check_20260617_095120.xlsx`

## 4. F_form linear_v1定義

```text
x_DNB = DNB位置 / 加熱長
f_DNB = interp1(x, f, x_DNB)
Blue_area_linear = integral_0^x_DNB f(x) dx
Orange_area_linear = x_DNB * f_DNB
F_form_linear = Blue_area_linear / Orange_area_linear
```

## 5. QC

| item | status | value | reading |
| --- | --- | --- | --- |
| current_input_exists | OK | H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx | BT13-B正本入力。 |
| BT08A1d_report_exists | OK | run_report_BT08A1d_Fform_linear_finalize_20260616_144056.md | BT08-A1d再積分監査結果。 |
| BT14A_report_exists | OK | run_report_BT14A_Fform_position_shape_diag_20260617_093233.md | BT14-A挙動診断結果。 |
| previous_BT14B_report_exists | OK | run_report_BT14B_Fform_reintegration_audit_closure_20260617_094603.md | BT14-B未完レポート。 |
| target_sheet_map | OK | 6/6 | 対象6シートのマッピング。 |
| sheet_read | OK | 6/6 | 対象6シートの読み込み。 |
| current_rows | OK | 116 | noF1 58 + F1 58 = 116行が期待値。 |
| current_Fform_vs_linear_v1 | OK | max_abs_delta=3.078041e-08 | current inputのF_formがlinear_v1と一致するか。 |
| definition_policy | OK | linear_v1 | BT08-A1dで確定した定義を使う。 |
| legacy_policy | OK | legacy_trace_only | legacy F_formは履歴・比較用。 |
| formula_policy | OK | no_new_formula | BT14-B2でも補正式は作らない。 |

## 6. Sheet inventory

| sheet_index | sheet_name |
| --- | --- |
| 1 | tm_108 |
| 2 | tm_161 |
| 3 | tm_164 |
| 4 | tm_F1_108 |
| 5 | tm_F1_161 |
| 6 | tm_F1_164 |
| 7 | README_BT13B |

## 7. Target sheet map

| target_sheet | mapped_sheet | status |
| --- | --- | --- |
| tm_108 | tm_108 | OK_exact |
| tm_161 | tm_161 | OK_exact |
| tm_164 | tm_164 | OK_exact |
| tm_F1_108 | tm_F1_108 | OK_exact |
| tm_F1_161 | tm_F1_161 | OK_exact |
| tm_F1_164 | tm_F1_164 | OK_exact |

## 8. Sheet read status

| target_sheet | mapped_sheet | status | N_rows | message |
| --- | --- | --- | --- | --- |
| tm_108 | tm_108 | OK_read | 14 |  |
| tm_161 | tm_161 | OK_read | 23 |  |
| tm_164 | tm_164 | OK_read | 21 |  |
| tm_F1_108 | tm_F1_108 | OK_read | 14 |  |
| tm_F1_161 | tm_F1_161 | OK_read | 23 |  |
| tm_F1_164 | tm_F1_164 | OK_read | 21 |  |

## 9. canonical F_form linear_v1

| definition_version | case_label | Bundle | z_DNB_ratio | profile_sheet | f_DNB_linear | Blue_area_linear | Orange_area_linear | Fform_linear_v1 | Fform_legacy_mean | diff_linear_minus_legacy | ratio_linear_to_legacy | definition_note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| linear_v1 | 108_70in | 108 | 0.729167 | 非一様加熱を一様加熱に補正108 | 1.5825311 | 0.71522932 | 1.1539295 | 0.61982066 | 0.65432795 | -0.03450729 | 0.947263 | BT08-A1d: linear interpolation and linear integral |
| linear_v1 | 108_76in | 108 | 0.791667 | 非一様加熱を一様加熱に補正108 | 1.3919731 | 0.80849999 | 1.1019791 | 0.73367994 | 0.760494 | -0.02681406 | 0.96474126 | BT08-A1d: linear interpolation and linear integral |
| linear_v1 | 161_uniform | 161 | 0.997024 | 非一様加熱を一様加熱に補正161 | 1 | 0.997024 | 0.997024 | 1 | 1 | 0 | 1 | BT08-A1d: linear interpolation and linear integral |
| linear_v1 | 164_112in | 164 | 0.666667 | 非一様加熱を一様加熱に補正164 | 1.2720999 | 0.74430116 | 0.84806699 | 0.8776443 | 1.014 | -0.1363557 | 0.86552692 | BT08-A1d: linear interpolation and linear integral |
| linear_v1 | 164_134in_normal | 164 | 0.797619 | 非一様加熱を一様加熱に補正164 | 0.8520446 | 0.88348441 | 0.67960696 | 1.2999932 | 1.363 | -0.0630068 | 0.95377344 | BT08-A1d: linear interpolation and linear integral |

## 10. current input case summary

| case_label | N | N_noF1 | N_F1 | Bundle | Fform_current_mean | Fform_current_sd | Fform_min | Fform_max | PM_F1_mean | PM_noF1_mean | z_DNB_L_mean | z_DNB_DH_mean | L_DH_mean |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108_70in | 24 | 12 | 12 | 108 | 0.61982066 | 2.268203e-16 | 0.61982066 | 0.61982066 | 1.1166142 | 0.65672421 | 0.7292863 | 137.96929 | 189.18399 |
| 108_76in | 4 | 2 | 2 | 108 | 0.73367994 | 0 | 0.73367994 | 0.73367994 | 1.1628772 | 0.63099733 | 0.79179655 | 149.79523 | 189.18399 |
| 161_uniform | 46 | 23 | 23 | 161 | 1 | 0 | 1 | 1 | 0.90884087 | 0.62098048 | 0.99707054 | 361.35516 | 362.41684 |
| 164_112in | 2 | 1 | 1 | 164 | 0.8776443 | 0 | 0.8776443 | 0.8776443 | 0.79743867 | 0.33017459 | 0.66669791 | 241.62255 | 362.41684 |
| 164_134in_normal | 40 | 20 | 20 | 164 | 1.2999932 | 1.1243666e-15 | 1.2999932 | 1.2999932 | 0.94666661 | 0.61124627 | 0.79765643 | 289.08413 | 362.41684 |

## 11. consistency check

| case_label | Bundle | Fform_linear_v1 | Fform_legacy_mean | Fform_current_mean | N_current | diff_current_minus_linear_v1 | check_status | diff_linear_minus_legacy |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108_70in | 108 | 0.61982066 | 0.65432795 | 0.61982066 | 24 | -1.0786553e-09 | OK_current_matches_linear_v1 | -0.03450729 |
| 108_76in | 108 | 0.73367994 | 0.760494 | 0.73367994 | 4 | -2.4189644e-09 | OK_current_matches_linear_v1 | -0.02681406 |
| 161_uniform | 161 | 1 | 1 | 1 | 46 | 0 | OK_current_matches_linear_v1 | 0 |
| 164_112in | 164 | 0.8776443 | 1.014 | 0.8776443 | 2 | -3.2747963e-09 | OK_current_matches_linear_v1 | -0.1363557 |
| 164_134in_normal | 164 | 1.2999932 | 1.363 | 1.2999932 | 40 | -3.078041e-08 | OK_current_matches_linear_v1 | -0.0630068 |

## 12. near-position examples

| case_a | case_b | delta_z_DNB_ratio | abs_delta_z_DNB_ratio | delta_Fform_linear_v1 | abs_delta_Fform_linear_v1 | delta_PM_F1_current | delta_L_DH_current | current_note | reading |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108_76in | 164_134in_normal | -0.005952 | 0.005952 | -0.56631326 | 0.56631326 | 0.21621055 | -173.23285 | from_current_input | near_DNB_position_but_large_Fform_difference |
| 108_70in | 164_134in_normal | -0.068452 | 0.068452 | -0.68017254 | 0.68017254 | 0.1699476 | -173.23285 | from_current_input | near_DNB_position |
| 108_70in | 164_112in | 0.0625 | 0.0625 | -0.25782364 | 0.25782364 | 0.31917554 | -173.23285 | from_current_input | near_DNB_position |

## 13. decision flags

| item | status | value | reading |
| --- | --- | --- | --- |
| Fform_definition | adopt | linear_v1 | BT08-A1dの統一ルールを正本化する。 |
| Fform_reintegration_audit | adopt | reuse_BT08A1d | F_form再積分監査はBT08-A1dで実施済み。BT14-B2では照合を完了する。 |
| current_input_status | adopt | matches_linear_v1 | BT13-B正本入力のF_formはlinear_v1と一致。 |
| BT14_status | close_ready | Fform_audit_closed | BT14を閉じられる。 |
| legacy_policy | adopt | trace_only | legacy F_formは履歴・比較用であり、今後の解析入力には使わない。 |
| Fform_causal_claim | do_not_claim | not_cause_yet | F_formがPM_F1残差の原因とは断定しない。 |
| formula_policy | do_not_create | no_Fform_DNB_LDH_formula | F_form/DNB位置/L_DH補正式は作らない。 |

## 14. 判断メモ

```text
BT14-B2は、BT14-Bで未完だったcurrent input照合をやり直す修正版である。
BT08-A1d linear_v1をF_form正本とする。
BT13-B正本入力のF_formがlinear_v1と一致すれば、F_form実装監査を閉じる。
legacy F_formは履歴・比較用であり、今後の感度解析入力には使わない。
F_form補正式、DNB位置補正式、L/DH補正式は作らない。
```

## 15. 次アクション

```text
BT14-B2結果を確認する。
照合がOKならworking_logへ追記し、BT14を閉じる。
照合がCHECKなら、sheet_read_statusまたはconsistency_checkに基づいて原因を修正する。
```
