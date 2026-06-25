# BT08-A1 F_form area recalculation audit

作成日時: 20260616

## 1. 目的

BT07では、current_bundle_input単体ではF_formの青面積/オレンジ面積を再計算できないことを確認した。一方、バンドルデータ整理r3.xlsxには、F_form作成元に相当する非一様加熱補正シートがある。BT08-A1では、まずr3だけを使ってF_form面積計算を再現・監査する。

## 2. 入力と出力

- 入力r3: `バンドルデータ整理r3.xlsx`
- 任意照合current_bundle: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`
- 出力Excel: `BT08A1_Fform_area_recalc_audit_20260616_131638.xlsx`

## 3. 前提

- r3でまず試す。
- 目的を達成したら、必要最小限の情報をcurrent_bundle_input_v2へ集約する。
- この段階ではcurrent_bundle_inputを更新しない。
- F_formはF1ではない。
- 補正式は作らない。

## 4. x_eq summary / DNB positions from r3

| Bundle | z_ratio | z_heat_ratio | note | row_in_sheet | numerator_r3 | denominator_r3 | reading_method |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | 0.729167 | 0.75935119 | DNB位置 z=70/96 inch | 5 | 0.755174 | 0.994499 | numeric_scan_02_xeq_recalc_summary_block |
| 108 | 0.791667 | 0.86752123 | DNB位置 z=76/96 inch | 6 | 0.862749 | 0.994499 | numeric_scan_02_xeq_recalc_summary_block |
| 161 | 0.997024 | 1 | 一様加熱 | 7 | 1 | 1 | numeric_scan_02_xeq_recalc_summary_block |
| 164 | 0.666667 | 0.85979696 | DNB位置 z=112/168 inch | 8 | 0.8596465 | 0.999825 | numeric_scan_02_xeq_recalc_summary_block |
| 164 | 0.797619 | 0.9102658 | DNB位置 z=134/168 inch | 9 | 0.9101065 | 0.999825 | numeric_scan_02_xeq_recalc_summary_block |

## 5. Area audit

| Bundle | z_ratio | profile_z_min | profile_z_max | profile_N | total_area | blue_area_inclusive | blue_area_exact | z_heat_ratio_inclusive | z_heat_ratio_exact | z_prev | q_local_prev | z_next | q_local_next | q_local_interp | q_local_nearest | orange_area_prev | orange_area_interp | orange_area_nearest | Fform_prev_inclusive | Fform_interp_inclusive | Fform_nearest_inclusive | Fform_prev_exact | Fform_interp_exact | Fform_nearest_exact | qeq_avg_inclusive | qeq_avg_exact | z_heat_ratio_r3 | z_heat_ratio_diff_inclusive_minus_r3 | xeq_note | numerator_r3 | denominator_r3 | xeq_reading_method |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | 0.729167 | 0 | 1 | 28 | 0.994499 | 0.755174 | 0.71522932 | 0.75935119 | 0.71918556 | 0.729 | 1.583 | 0.755 | 1.51 | 1.5825311 | 1.583 | 1.1542714 | 1.1539295 | 1.1542714 | 0.65424304 | 0.65443688 | 0.65424304 | 0.61963707 | 0.61982066 | 0.61963707 | 1.0356667 | 0.98088548 | 0.75935119 | 0 | DNB位置 z=70/96 inch | 0.755174 | 0.994499 | numeric_scan_02_xeq_recalc_summary_block |
| 108 | 0.791667 | 0 | 1 | 28 | 0.994499 | 0.862749 | 0.80849999 | 0.86752123 | 0.81297215 | 0.781 | 1.433 | 0.833 | 1.233 | 1.3919731 | 1.433 | 1.1344588 | 1.1019791 | 1.1344588 | 0.7604939 | 0.78290864 | 0.7604939 | 0.71267461 | 0.73367994 | 0.71267461 | 1.0897878 | 1.0212627 | 0.86752123 | 0 | DNB位置 z=76/96 inch | 0.862749 | 0.994499 | numeric_scan_02_xeq_recalc_summary_block |
| 161 | 0.997024 | 0 | 1 | 28 | 1 | 1 | 0.997024 | 1 | 0.997024 | 0.963 | 1 | 1 | 1 | 1 | 1 | 0.997024 | 0.997024 | 0.997024 | 1.0029849 | 1.0029849 | 1.0029849 | 1 | 1 | 1 | 1.0029849 | 1 | 1 | 0 | 一様加熱 | 1 | 1 | numeric_scan_02_xeq_recalc_summary_block |
| 164 | 0.666667 | 0 | 1 | 27 | 0.999825 | 0.8596465 | 0.74430116 | 0.85979696 | 0.74443144 | 0.662 | 1.287 | 0.771 | 0.939 | 1.2720999 | 1.287 | 0.85800043 | 0.84806699 | 0.85800043 | 1.0019185 | 1.013654 | 1.0019185 | 0.86748344 | 0.8776443 | 0.86748344 | 1.2894691 | 1.1164512 | 0.85979696 | 0 | DNB位置 z=112/168 inch | 0.8596465 | 0.999825 | numeric_scan_02_xeq_recalc_summary_block |
| 164 | 0.797619 | 0 | 1 | 27 | 0.999825 | 0.9101065 | 0.88348441 | 0.9102658 | 0.88363904 | 0.771 | 0.939 | 0.831 | 0.743 | 0.8520446 | 0.939 | 0.74896424 | 0.67960696 | 0.74896424 | 1.2151535 | 1.3391659 | 1.2151535 | 1.1796083 | 1.2999932 | 1.1796083 | 1.1410291 | 1.1076522 | 0.9102658 | 0 | DNB位置 z=134/168 inch | 0.9101065 | 0.999825 | numeric_scan_02_xeq_recalc_summary_block |

## 6. Optional current_bundle F_form comparison

| Bundle | z_ratio_r3 | current_match_N | current_z_mean | current_Fform_mean | current_Fform_sd | Fform_prev_inclusive | Fform_prev_inclusive_absdiff | Fform_interp_inclusive | Fform_interp_inclusive_absdiff | Fform_nearest_inclusive | Fform_nearest_inclusive_absdiff | Fform_prev_exact | Fform_prev_exact_absdiff | Fform_interp_exact | Fform_interp_exact_absdiff | Fform_nearest_exact | Fform_nearest_exact_absdiff | best_candidate | best_absdiff | match_status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | 0.729167 | 12 | 0.7292863 | 0.65432795 | 1.1595901e-16 | 0.65424304 | 8.4911581e-05 | 0.65443688 | 0.00010893263 | 0.65424304 | 8.4911581e-05 | 0.61963707 | 0.03469088 | 0.61982066 | 0.034507289 | 0.61963707 | 0.03469088 | Fform_prev_inclusive | 8.4911581e-05 | match_lt_1e-3 |
| 108 | 0.791667 | 2 | 0.79179655 | 0.760494 | 0 | 0.7604939 | 1.0490697e-07 | 0.78290864 | 0.022414642 | 0.7604939 | 1.0490697e-07 | 0.71267461 | 0.047819387 | 0.73367994 | 0.026814062 | 0.71267461 | 0.047819387 | Fform_prev_inclusive | 1.0490697e-07 | match_lt_1e-3 |
| 161 | 0.997024 | 23 | 0.99707054 | 1 | 0 | 1.0029849 | 0.002984883 | 1.0029849 | 0.002984883 | 1.0029849 | 0.002984883 | 1 | 0 | 1 | 0 | 1 | 0 | Fform_prev_exact | 0 | match_lt_1e-3 |
| 164 | 0.666667 | 1 | 0.66669791 | 1.014 | 0 | 1.0019185 | 0.012081503 | 1.013654 | 0.00034599948 | 1.0019185 | 0.012081503 | 0.86748344 | 0.14651656 | 0.8776443 | 0.1363557 | 0.86748344 | 0.14651656 | Fform_interp_inclusive | 0.00034599948 | match_lt_1e-3 |
| 164 | 0.797619 | 20 | 0.79765643 | 1.363 | 2.2781296e-16 | 1.2151535 | 0.14784653 | 1.3391659 | 0.023834054 | 1.2151535 | 0.14784653 | 1.1796083 | 0.18339174 | 1.2999932 | 0.063006831 | 1.1796083 | 0.18339174 | Fform_interp_inclusive | 0.023834054 | rough_lt_5e-2 |

## 7. Candidate ranking

| candidate | N_compared | MAE_to_current | max_absdiff_to_current | reading |
| --- | --- | --- | --- | --- |
| Fform_interp_inclusive | 5 | 0.0099377022 | 0.023834054 | 既存F_formと概ね一致。定義確認後に候補。 |
| Fform_prev_inclusive | 5 | 0.032599586 | 0.14784653 | おおまかには近いが、DNB局所出力の取り方または区間含め方の確認が必要。 |
| Fform_nearest_inclusive | 5 | 0.032599586 | 0.14784653 | おおまかには近いが、DNB局所出力の取り方または区間含め方の確認が必要。 |
| Fform_interp_exact | 5 | 0.052136777 | 0.1363557 | 既存F_formとの差が大きい。候補としては弱い。 |
| Fform_prev_exact | 5 | 0.082483714 | 0.18339174 | 既存F_formとの差が大きい。候補としては弱い。 |
| Fform_nearest_exact | 5 | 0.082483714 | 0.18339174 | 既存F_formとの差が大きい。候補としては弱い。 |

## 8. Proposed fields for current_bundle_input_v2

| field | suggested_value_or_formula | meaning |
| --- | --- | --- |
| Fform_source_book | バンドルデータ整理r3.xlsx | F_form作成元ブック名 |
| Fform_source_sheet | 非一様加熱を一様加熱に補正108/161/164 | F_form作成元シート名 |
| Fform_source_z_profile_col | E列またはA列 | z分布。BT08-A1ではE列を優先 |
| Fform_source_q_profile_col | F列またはC列 | 軸方向出力分布。BT08-A1ではF列を優先 |
| Fform_DNB_z_ratio | 02_xeq_recalc!z_ratio | DNB位置のz/L |
| Fform_blue_area_inclusive | sum interval area where segment start z <= z_DNB | r3のz_heat_ratioと整合する青面積候補 |
| Fform_blue_area_exact | integral from 0 to z_DNB | 物理的にDNB位置までで切った青面積候補 |
| Fform_total_area | full integral over 0<=z<=1 | 全長積分面積 |
| Fform_z_heat_ratio | blue_area_inclusive / total_area | r3のz_heat_ratio確認用 |
| Fform_q_local_prev | largest profile z <= z_DNB | 既存F_formに近い可能性がある局所出力候補 |
| Fform_q_local_interp | linear interpolation at z_DNB | 物理的な局所出力候補 |
| Fform_orange_area_prev | q_local_prev * z_DNB | オレンジ面積候補 |
| Fform_orange_area_interp | q_local_interp * z_DNB | オレンジ面積候補 |
| Fform_recalc_prev_inclusive | blue_area_inclusive / orange_area_prev | 既存F_form照合候補 |
| Fform_recalc_interp_inclusive | blue_area_inclusive / orange_area_interp | 補助候補 |
| Fform_recalc_interp_exact | blue_area_exact / orange_area_interp | 補助候補 |
| Fform_recalc_status | match/near/diff/not_checked | current_bundle F_formとの照合結果 |

## 9. Interpretation flags

| item | status | value | reading |
| --- | --- | --- | --- |
| BT08A1_position | OK |  | r3でまずF_form面積再計算を監査する。current_bundle_input更新はまだ行わない。 |
| r3_input | OK | バンドルデータ整理r3.xlsx | バンドルデータ整理r3.xlsxをF_form作成元として扱う。 |
| profile_sheets | OK | profile rows=83 | 非一様加熱補正シートからz分布と軸方向出力分布を読んだ。 |
| xeq_summary | OK | DNB positions=5 | 02_xeq_recalcからz_ratioとz_heat_ratioを読んだ。 |
| z_heat_ratio_reproduction | diagnostic | max abs diff=0 | inclusive区間和でr3のz_heat_ratioを再現できるかの確認。小さければr3面積計算の再現性が高い。 |
| current_bundle_compare | diagnostic | H52Q_current_bundle_input_v1_20260615_180822.xlsx | 任意でcurrent_bundle_inputの既存F_formと照合した。 |
| best_candidate | diagnostic | Fform_interp_inclusive, MAE=0.0099377 | 既存F_formに最も近い候補。採用前に定義の物理的意味を確認する。 |
| next_step | next |  | 目的を達成したら、BT08-A2としてcurrent_bundle_input_v2に必要最小限のF_form再現情報を集約する。 |

## 10. 次アクション

1. BT08_area_auditで、r3のz_heat_ratioが再計算できているか確認する。
2. current_bundle照合がある場合は、どのF_form候補が既存F_formに最も近いか確認する。
3. 定義が固まったら、BT08-A2としてcurrent_bundle_input_v2へ必要最小限のF_form再現情報を集約する。
4. 手動の線形補間・DNB位置手前止めが入っている場合は、その判断を Fform_definition_note / interpolation_method / stop_rule として残す。
4. ただし、F_formを補正式候補にはしない。F_formは非一様加熱換算・DNB位置・軸方向出力分布の診断項として扱う。
