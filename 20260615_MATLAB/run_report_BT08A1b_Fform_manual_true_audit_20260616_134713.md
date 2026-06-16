# BT08-A1b F_form manual TRUE audit

作成日時: 20260616

## 1. 目的

BT08-A1で164の一部F_formが完全一致しなかったため、164.xlsxのTRUE採用点を優先してF_formを再計算する。108についてはF_Form_108整理版.xlsxから定義・計算値をキーワード抽出する。

## 2. 入力

- r3: `バンドルデータ整理r3.xlsx`
- 164 TRUE採用点ファイル: `164r1.xlsx`
- 108: `F_Form_108整理版.xlsx`
- current_bundle: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`

## 3. r3 area audit

| Bundle | z_ratio | total_area | blue_area_inclusive | blue_area_exact | z_heat_ratio_inclusive | z_heat_ratio_exact | z_prev | q_local_prev | z_next | q_local_next | q_local_interp | orange_area_prev | orange_area_interp | Fform_prev_inclusive | Fform_interp_inclusive | Fform_prev_exact | Fform_interp_exact | z_heat_ratio_r3 | z_heat_ratio_diff_inclusive_minus_r3 | xeq_note | numerator_r3 | denominator_r3 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | 0.729167 | 0.994499 | 0.755174 | 0.71522932 | 0.75935119 | 0.71918556 | 0.729 | 1.583 | 0.755 | 1.51 | 1.5825311 | 1.1542714 | 1.1539295 | 0.65424304 | 0.65443688 | 0.61963707 | 0.61982066 | 0.75935119 | 0 | DNB位置 z=70/96 inch | 0.755174 | 0.994499 |
| 108 | 0.791667 | 0.994499 | 0.862749 | 0.80849999 | 0.86752123 | 0.81297215 | 0.781 | 1.433 | 0.833 | 1.233 | 1.3919731 | 1.1344588 | 1.1019791 | 0.7604939 | 0.78290864 | 0.71267461 | 0.73367994 | 0.86752123 | 0 | DNB位置 z=76/96 inch | 0.862749 | 0.994499 |
| 161 | 0.997024 | 1 | 1 | 0.997024 | 1 | 0.997024 | 0.963 | 1 | 1 | 1 | 1 | 0.997024 | 0.997024 | 1.0029849 | 1.0029849 | 1 | 1 | 1 | 0 | 一様加熱 | 1 | 1 |
| 164 | 0.666667 | 0.999825 | 0.8596465 | 0.74430116 | 0.85979696 | 0.74443144 | 0.662 | 1.287 | 0.771 | 0.939 | 1.2720999 | 0.85800043 | 0.84806699 | 1.0019185 | 1.013654 | 0.86748344 | 0.8776443 | 0.85979696 | 0 | DNB位置 z=112/168 inch | 0.8596465 | 0.999825 |
| 164 | 0.797619 | 0.999825 | 0.9101065 | 0.88348441 | 0.9102658 | 0.88363904 | 0.771 | 0.939 | 0.831 | 0.743 | 0.8520446 | 0.74896424 | 0.67960696 | 1.2151535 | 1.3391659 | 1.1796083 | 1.2999932 | 0.9102658 | 0 | DNB位置 z=134/168 inch | 0.9101065 | 0.999825 |

## 4. 164 TRUE adopted points

| file | sheet | row_in_sheet | true_col | true_header | z_from_A | q_from_B | true_cell_value | left1 | right1 | note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 164r1.xlsx | TEST SECTION NUMBER 164 | 2 | 9 | SRL[-] | 0 | 0.39 | 1 |  | 1979 | A列/B列の線形補間点で、同じ行のTRUE列を採用点として抽出 |
| 164r1.xlsx | TEST SECTION NUMBER 164 | 6764 | 4 |  | 0.66666667 | 1.2721009 | 採用 | ture |  | A列/B列の線形補間点で、同じ行のTRUE列を採用点として抽出 |
| 164r1.xlsx | TEST SECTION NUMBER 164 | 8073 | 3 | TEST NUMBER | 0.79757976 | 0.85217279 | true | 0.85217 | 採用 | A列/B列の線形補間点で、同じ行のTRUE列を採用点として抽出 |
| 164r1.xlsx | TEST SECTION NUMBER 164 | 8073 | 4 |  | 0.79757976 | 0.85217279 | 採用 | true |  | A列/B列の線形補間点で、同じ行のTRUE列を採用点として抽出 |

## 5. 164 TRUE comparison

| Bundle | manual_file | manual_sheet | manual_row | true_flag_column | true_flag_header | z_manual_A | q_manual_B | matched_r3_z_ratio | match_abs_dz | blue_area_inclusive | blue_area_exact | orange_area_manual | Fform_manual_inclusive | Fform_manual_exact | current_match_N | current_z_mean | current_Fform_mean | diff_manual_inclusive_to_current | absdiff_manual_inclusive_to_current | diff_manual_exact_to_current | absdiff_manual_exact_to_current | match_status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 164 | 164r1.xlsx | TEST SECTION NUMBER 164 | 2 | 9 | SRL[-] | 0 | 0.39 | 0.666667 | 0.666667 | 0.8596465 | 0.74430116 | 0.26000013 | 3.306331 | 2.8626953 | 1 | 0.66669791 | 1.014 | 2.292331 | 2.292331 | 1.8486953 | 1.8486953 | diff_ge_5e-2 |
| 164 | 164r1.xlsx | TEST SECTION NUMBER 164 | 6764 | 4 |  | 0.66666667 | 1.2721009 | 0.666667 | 3.3333333e-07 | 0.8596465 | 0.74430116 | 0.8480677 | 1.0136532 | 0.87764356 | 1 | 0.66669791 | 1.014 | -0.00034684749 | 0.00034684749 | -0.13635644 | 0.13635644 | match_lt_1e-3 |
| 164 | 164r1.xlsx | TEST SECTION NUMBER 164 | 8073 | 3 | TEST NUMBER | 0.79757976 | 0.85217279 | 0.797619 | 3.9242024e-05 | 0.9101065 | 0.88348441 | 0.67970921 | 1.3389645 | 1.2997976 | 20 | 0.79765643 | 1.363 | -0.024035502 | 0.024035502 | -0.063202386 | 0.063202386 | rough_lt_5e-2 |
| 164 | 164r1.xlsx | TEST SECTION NUMBER 164 | 8073 | 4 |  | 0.79757976 | 0.85217279 | 0.797619 | 3.9242024e-05 | 0.9101065 | 0.88348441 | 0.67970921 | 1.3389645 | 1.2997976 | 20 | 0.79765643 | 1.363 | -0.024035502 | 0.024035502 | -0.063202386 | 0.063202386 | rough_lt_5e-2 |

## 6. 108 keyword scan

| file | sheet | row_in_sheet | col_in_sheet | keyword | cell_text | right1 | right2 | below1 | below2 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| F_Form_108整理版.xlsx | 108_Fform_check | 1 | 12 | x_DNB | x_DNB | f_DNB | Blue_end_x | 0.72917 |  |
| F_Form_108整理版.xlsx | 108_Fform_check | 1 | 13 | f_DNB | f_DNB | Blue_end_x | Blue_area | 1.5828 |  |
| F_Form_108整理版.xlsx | 108_Fform_check | 1 | 15 | Blue_area | Blue_area | Orange_area | F_form_corrected | 0.75517 |  |
| F_Form_108整理版.xlsx | 108_Fform_check | 1 | 16 | Orange_area | Orange_area | F_form_corrected | F_form_old | 1.1541 |  |
| F_Form_108整理版.xlsx | 108_Fform_check | 1 | 17 | F_form | F_form_corrected | F_form_old | old/corrected | 0.65433 | 0.76049 |
| F_Form_108整理版.xlsx | 108_Fform_check | 1 | 18 | F_form | F_form_old | old/corrected | note | 0.75517 |  |
| F_Form_108整理版.xlsx | README_Fform | 1 | 1 | F_form | 108 F_form確認 | 108 F_form確認 | 108 F_form確認 |  | 目的： |
| F_Form_108整理版.xlsx | README_Fform | 7 | 1 | Blue_area | Blue_area： | Blue_area： | Blue_area： | 入口からDNB位置付近までの軸方向分布 f(x) の積分面積。 | 旧F_form = Blue_area として使っていた。 |
| F_Form_108整理版.xlsx | README_Fform | 9 | 1 | Blue_area | 旧F_form = Blue_area として使っていた。 | 旧F_form = Blue_area として使っていた。 | 旧F_form = Blue_area として使っていた。 |  | Orange_area： |
| F_Form_108整理版.xlsx | README_Fform | 11 | 1 | Orange_area | Orange_area： | Orange_area： | Orange_area： | DNB位置の軸方向係数 f_DNB を、 | 入口からDNB位置まで一様に与えた場合の面積。 |
| F_Form_108整理版.xlsx | README_Fform | 12 | 1 | f_DNB | DNB位置の軸方向係数 f_DNB を、 | DNB位置の軸方向係数 f_DNB を、 | DNB位置の軸方向係数 f_DNB を、 | 入口からDNB位置まで一様に与えた場合の面積。 | Orange_area = x_DNB × f_DNB |
| F_Form_108整理版.xlsx | README_Fform | 14 | 1 | Orange_area | Orange_area = x_DNB × f_DNB | Orange_area = x_DNB × f_DNB | Orange_area = x_DNB × f_DNB |  | 修正後F_form： |
| F_Form_108整理版.xlsx | README_Fform | 16 | 1 | F_form | 修正後F_form： | 修正後F_form： | 修正後F_form： | F_form_corrected = Blue_area / Orange_area |  |
| F_Form_108整理版.xlsx | README_Fform | 17 | 1 | Blue_area | F_form_corrected = Blue_area / Orange_area | F_form_corrected = Blue_area / Orange_area | F_form_corrected = Blue_area / Orange_area |  | 注意： |
| F_Form_108整理版.xlsx | README_Fform | 21 | 1 | F_form | F_form_correctedには入れない。 | F_form_correctedには入れない。 | F_form_correctedには入れない。 | F_form_correctedには入れない。 | F_form_correctedには入れない。 |

## 7. Decision flags

| item | status | value | reading |
| --- | --- | --- | --- |
| BT08A1b_position | OK |  | 164.xlsxのTRUE採用点を優先して、164のF_form再計算を確認する。 |
| r3_blue_area | OK | rows=5 | 青面積はr3由来のinclusive面積を使う。 |
| 164_true_points | diagnostic | N=4 | 164.xlsxからTRUE採用点を抽出した。 |
| 164_manual_compare | diagnostic | min abs diff=0.000346847 | TRUE採用点を使ったF_formとcurrent F_formを照合した。 |
| 108_keyword_scan | diagnostic | hits=15 | F_Form_108整理版から定義・計算値に関するキーワード周辺を抽出した。 |
| current_bundle_v2_policy | next |  | 一致した定義と手作業判断をcurrent_bundle_input_v2へ列として集約する。 |

## 8. Fields for current_bundle_input_v2

| field | suggested_value_or_formula | meaning |
| --- | --- | --- |
| Fform_source_book | バンドルデータ整理r3.xlsx / 164.xlsx / F_Form_108整理版.xlsx | F_form作成元の追跡 |
| Fform_source_sheet | 非一様加熱を一様加熱に補正*, 02_xeq_recalc, 164.xlsx TRUE採用点 | F_form作成元シート |
| Fform_DNB_z_ratio | 02_xeq_recalc z_ratio | DNB位置 z/L |
| Fform_blue_area | r3 blue_area_inclusive | DNB位置を含む区間まで足した青面積 |
| Fform_total_area | r3 total_area | 全長積分面積 |
| Fform_z_heat_ratio | blue_area / total_area | r3 z_heat_ratio再現 |
| Fform_q_local_method | manual_true / DNB直前点 / 線形補間 / 一様加熱 | オレンジ高さの決め方 |
| Fform_q_local_used | 採用したDNB局所出力 | オレンジ面積の高さ |
| Fform_orange_area | z_DNB * q_local_used | オレンジ面積 |
| Fform_recalc | blue_area / orange_area | 再計算F_form |
| Fform_current | current_bundle_input existing F_form | 既存F_form |
| Fform_diff | Fform_recalc - Fform_current | 差分 |
| Fform_match_status | match/near/rough/diff/manual_check_required | 照合状態 |
| Fform_definition_note | 青面積inclusive、オレンジ高さは手作業採用点を優先 | 定義メモ |
| Fform_interpolation_method | manual TRUE / linear interpolation / previous point / uniform | 補間方法 |
| Fform_stop_rule | DNB位置を含む区間まで足す | 青面積側の止め方 |

## 9. 次アクション

1. 164 TRUE採用点で既存F_formが再現できるか確認する。
2. 再現できる場合、current_bundle_input_v2には q_local_method=manual_TRUE として残す。
3. 再現できない場合、TRUE列の意味または採用列の読み方をユーザー確認する。
4. 108はF_Form_108整理版の定義を優先し、DNB直前点ではなくx_DNB位置のf_DNBを用いた計算として記録する。
