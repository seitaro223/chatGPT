# BT14-B F_form reintegration audit closure

作成日時: 20260617

## 1. 目的

BT14-Aでは、current_bundle_inputだけでは軸方向出力分布元配列がなく、F_form再積分監査まではできないことを確認した。
一方で、F_formは既にBT08-A1dでこのチャット内においてlinear_v1として定義・再積分監査済みである。
BT14-Bでは、BT08-A1dの結果を正本監査結果として再利用し、BT13-B正本入力のF_formがlinear_v1値と整合しているかを確認する。

## 2. 入力

- current input: `H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx`
- BT08-A1d report: `run_report_BT08A1d_Fform_linear_finalize_20260616_144056.md`
- BT14-A report: `run_report_BT14A_Fform_position_shape_diag_20260617_093233.md`

## 3. 出力

- output Excel: `BT14B_Fform_reintegration_audit_closure_20260617_094603.xlsx`

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
| BT08A1d_report_exists | OK | run_report_BT08A1d_Fform_linear_finalize_20260616_144056.md | BT08-A1dの再積分監査結果を正本として使う。 |
| BT14A_report_exists | OK | run_report_BT14A_Fform_position_shape_diag_20260617_093233.md | BT14-Aの挙動診断結果。 |
| current_input_exists | OK | H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx | BT13-Bで作成した正本入力。 |
| current_rows | CHECK | 0 | current inputを読めていない。 |
| current_Fform_vs_linear_v1 | CHECK | not_checked | current input未読のため照合不可。 |
| definition_policy | OK | linear_v1 | BT08-A1dで確定した定義を使う。 |
| legacy_policy | OK | legacy_trace_only | legacy F_formは履歴・比較用。感度解析入力には使わない。 |
| formula_policy | OK | no_new_formula | BT14-Bでも補正式は作らない。 |

## 6. canonical F_form linear_v1

| definition_version | case_label | Bundle | z_DNB_ratio | profile_sheet | f_DNB_linear | Blue_area_linear | Orange_area_linear | Fform_linear_v1 | Fform_legacy_mean | diff_linear_minus_legacy | ratio_linear_to_legacy | definition_note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| linear_v1 | 108_70in | 108 | 0.729167 | 非一様加熱を一様加熱に補正108 | 1.5825311 | 0.71522932 | 1.1539295 | 0.61982066 | 0.65432795 | -0.03450729 | 0.947263 | all cases use linear interpolation at x_DNB and linear integral from 0 to x_DNB |
| linear_v1 | 108_76in | 108 | 0.791667 | 非一様加熱を一様加熱に補正108 | 1.3919731 | 0.80849999 | 1.1019791 | 0.73367994 | 0.760494 | -0.02681406 | 0.96474126 | all cases use linear interpolation at x_DNB and linear integral from 0 to x_DNB |
| linear_v1 | 161_uniform | 161 | 0.997024 | 非一様加熱を一様加熱に補正161 | 1 | 0.997024 | 0.997024 | 1 | 1 | 0 | 1 | all cases use linear interpolation at x_DNB and linear integral from 0 to x_DNB |
| linear_v1 | 164_112in | 164 | 0.666667 | 非一様加熱を一様加熱に補正164 | 1.2720999 | 0.74430116 | 0.84806699 | 0.8776443 | 1.014 | -0.1363557 | 0.86552692 | all cases use linear interpolation at x_DNB and linear integral from 0 to x_DNB |
| linear_v1 | 164_134in_normal | 164 | 0.797619 | 非一様加熱を一様加熱に補正164 | 0.8520446 | 0.88348441 | 0.67960696 | 1.2999932 | 1.363 | -0.0630068 | 0.95377344 | all cases use linear interpolation at x_DNB and linear integral from 0 to x_DNB |

## 7. current input case summary

_empty_

## 8. consistency check

| case_label | Bundle | Fform_linear_v1 | Fform_legacy_mean | Fform_current_mean | N_current | diff_current_minus_linear_v1 | check_status | diff_linear_minus_legacy |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108_70in | 108 | 0.61982066 | 0.65432795 |  | 0 |  | CHECK_no_current_input_match | -0.03450729 |
| 108_76in | 108 | 0.73367994 | 0.760494 |  | 0 |  | CHECK_no_current_input_match | -0.02681406 |
| 161_uniform | 161 | 1 | 1 |  | 0 |  | CHECK_no_current_input_match | 0 |
| 164_112in | 164 | 0.8776443 | 1.014 |  | 0 |  | CHECK_no_current_input_match | -0.1363557 |
| 164_134in_normal | 164 | 1.2999932 | 1.363 |  | 0 |  | CHECK_no_current_input_match | -0.0630068 |

## 9. near-position examples

| case_a | case_b | delta_z_DNB_ratio | abs_delta_z_DNB_ratio | delta_Fform_linear_v1 | abs_delta_Fform_linear_v1 | delta_PM_F1_current | delta_L_DH_current | current_note | reading |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108_76in | 164_134in_normal | -0.005952 | 0.005952 | -0.56631326 | 0.56631326 |  |  | current_input_not_available | near_DNB_position_but_large_Fform_difference |
| 108_70in | 164_134in_normal | -0.068452 | 0.068452 | -0.68017254 | 0.68017254 |  |  | current_input_not_available | near_DNB_position |
| 108_70in | 164_112in | 0.0625 | 0.0625 | -0.25782364 | 0.25782364 |  |  | current_input_not_available | near_DNB_position |

## 10. decision flags

| item | status | value | reading |
| --- | --- | --- | --- |
| Fform_definition | adopt | linear_v1 | BT08-A1dの統一ルールを正本化する。 |
| Fform_reintegration_audit | adopt | reuse_BT08A1d | F_form再積分監査はBT08-A1dで実施済み。BT14-Bでは再利用・照合する。 |
| manual_excel_policy | adopt | no_manual_excel_edit | Excel手作業ではなくMATLAB出力とMarkdownログで固定する。 |
| current_input_status | CHECK | not_checked | current_inputが読めず照合未完。 |
| Fform_causal_claim | do_not_claim | not_cause_yet | F_formがPM_F1残差の原因とは断定しない。 |
| next | next | close_BT14_or_prepare_BT15 | BT14-B確認後、F_form正本化を閉じる。 |

## 11. 判断メモ

```text
BT14-Bは、BT08-A1dの再積分監査結果を再利用する閉じ作業である。
新しいF_form定義は作らない。
F_formはlinear_v1を正本とする。
legacy F_formは監査・履歴用として残すが、今後の感度解析入力には使わない。
BT13-B正本入力のF_formがcanonical linear_v1と一致すれば、F_form実装監査は閉じられる。
BT14-Aで見えたF_form挙動診断は、BT14-Bの定義監査とは別物として扱う。
F_form補正式、DNB位置補正式、L/DH補正式は作らない。
```

## 12. 次アクション

```text
BT14-B結果を確認する。
問題なければworking_logへ追記する。
その後、BT14全体を閉じ、F_formはlinear_v1正本として今後の入力に固定する。
次に進むなら、BT15としてF_form正本化後の全体判断または発表用整理へ進む。
```
