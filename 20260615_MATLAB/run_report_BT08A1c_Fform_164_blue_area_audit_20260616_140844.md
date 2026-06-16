# BT08-A1c F_form 164 Blue_area audit

作成日時: 20260616

## 1. 目的

164r1.xlsxのA列/B列にある長尺線形補間表から、164通常ケースのBlue_area=0.926529を再現できるか確認する。あわせて112/168側のBlue_area=0.8596465も確認する。

## 2. 入力

- 164: `164r1.xlsx`
- current_bundle: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`

## 3. TRUE points valid

| file | sheet | row_in_sheet | true_col | true_header | z_from_A | q_from_B | true_cell_value | left1 | right1 | note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 164r1.xlsx | TEST SECTION NUMBER 164 | 6764 | 3 | TEST NUMBER | 0.66666667 | 1.2721009 | ture | 1.2721 | 採用 | A列/B列の線形補間点で、同じ行のTRUE/採用列を抽出 |
| 164r1.xlsx | TEST SECTION NUMBER 164 | 8073 | 3 | TEST NUMBER | 0.79757976 | 0.85217279 | true | 0.85217 | 採用 | A列/B列の線形補間点で、同じ行のTRUE/採用列を抽出 |

## 4. Blue area audit

| case_label | manual_file | manual_sheet | manual_row | true_col | true_header | z_manual | z_nominal | q_DNB_TRUE | profile_sheet | profile_N | blue_exact_manual_z | blue_exact_nominal_z | blue_trapz_LE_manual_z | blue_trapz_include_next_manual_z | user_confirmed_blue_area | diff_blue_exact_nominal_minus_user | absdiff_blue_exact_nominal_minus_user | orange_manual_z | orange_nominal_z | Fform_exact_manual_z | Fform_exact_nominal_z | Fform_userblue_manual_z | Fform_userblue_nominal_z | current_match_N | current_z_mean | current_Fform_mean | current_expected_from_user | blue_needed_from_current_manual_z | blue_needed_from_current_nominal_z | diff_userblue_to_needed_nominal | absdiff_userblue_to_needed_nominal | diff_Fform_userblue_nominal_to_current | absdiff_Fform_userblue_nominal_to_current | match_status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 21_164_112in | 164r1.xlsx | TEST SECTION NUMBER 164 | 6764 | 3 | TEST NUMBER | 0.66666667 | 0.66666667 | 1.2721009 | TEST SECTION NUMBER 164 | 10025 | 0.74430074 | 0.74430074 | 0.74430074 | 0.74442794 | 0.8596465 | -0.11534576 | 0.11534576 | 0.84806728 | 0.84806728 | 0.8776435 | 0.8776435 | 1.0136537 | 1.0136537 | 1 | 0.66669791 | 1.014 | 1.014 | 0.85994022 | 0.85994022 | -0.00029372018 | 0.00029372018 | -0.00034634066 | 0.00034634066 | match_lt_1e-3 |
| normal_164_134in | 164r1.xlsx | TEST SECTION NUMBER 164 | 8073 | 3 | TEST NUMBER | 0.79757976 | 0.79761905 | 0.85217279 | TEST SECTION NUMBER 164 | 10025 | 0.88345097 | 0.88348445 | 0.88345097 | 0.88353618 | 0.926529 | -0.043044551 | 0.043044551 | 0.67967577 | 0.67970925 | 1.2998124 | 1.2997976 | 1.3631926 | 1.3631255 | 20 | 0.79765643 | 1.363 | 1.363 | 0.92639807 | 0.92644371 | 8.529272e-05 | 8.529272e-05 | 0.00012548412 | 0.00012548412 | match_lt_1e-3 |

## 5. Decision flags

| item | status | value | reading |
| --- | --- | --- | --- |
| profile_read | OK | N=10025, sheet=TEST SECTION NUMBER 164 | 164r1.xlsxのA/B長尺線形補間表を読んだ。 |
| true_points_raw | diagnostic | N=5 | TRUE/採用セルを拾った。z=0などの誤検出を含む可能性がある。 |
| true_points_valid | OK | N=2 | z>0.05で有効なTRUE採用点に絞った。 |
| audit_21_164_112in | match_lt_1e-3 | Fform_userblue_nominal=1.0136537, current=1.014, blue_exact_nominal=0.74430074, user_blue=0.8596465 | ユーザー確認Blue_areaを使ったF_form照合。blue_exact_nominal_zとの差も確認する。 |
| audit_normal_164_134in | match_lt_1e-3 | Fform_userblue_nominal=1.3631255, current=1.363, blue_exact_nominal=0.88348445, user_blue=0.926529 | ユーザー確認Blue_areaを使ったF_form照合。blue_exact_nominal_zとの差も確認する。 |
| interpretation | hold |  | 134/168側のズレはq_DNBではなくBlue_area出典の差として扱う。 |
| next | next |  | 確定後、current_bundle_input_v2にFform_blue_area_sourceとq_DNB_sourceを追加する。 |

## 6. Fields for current_bundle_input_v2

| field | suggested_value_or_formula | meaning |
| --- | --- | --- |
| Fform_source_book | バンドルデータ整理r3.xlsx / 164r1.xlsx / F_Form_108整理版.xlsx | F_form作成元の追跡 |
| Fform_case_label | normal_164_134in / 21_164_112in / 108_70in / 108_76in / uniform_161 | DNB位置・ケース識別 |
| Fform_DNB_z_ratio | x_DNB = DNB位置 / 加熱長 | DNB位置 z/L |
| Fform_blue_area_source | r3 inclusive or 164r1 dense-integral/user-confirmed | 青面積の出典 |
| Fform_blue_area | 0.926529 for 164 normal, 0.8596465 for 164 112in | 採用青面積 |
| Fform_q_DNB_source | TRUE row in 164r1 A/B table or 108 f_DNB sheet | オレンジ高さの出典 |
| Fform_q_DNB_used | 採用したf_DNB | DNB位置局所係数 |
| Fform_orange_area | x_DNB * f_DNB | オレンジ面積 |
| Fform_recalc | Fform_blue_area / Fform_orange_area | 再計算F_form |
| Fform_current | current_bundle_input existing F_form | 既存F_form |
| Fform_diff | Fform_recalc - Fform_current | 差分 |
| Fform_match_status | match/near/rough/diff/manual_check_required | 照合状態 |
| Fform_definition_note | 青面積とオレンジ高さの作り方を文章で残す | 定義メモ |
| Fform_interpolation_method | manual TRUE / dense linear interpolation / user-confirmed blue area | 補間方法 |
| Fform_stop_rule | case-dependent: inclusive / dense-integral to DNB / user-confirmed | 青面積側の止め方 |

## 7. 次アクション

1. 164通常ケースで Blue_area=0.926529 が再現またはユーザー確認値として整合するか確認する。
2. 164の134/168側は q_DNB ではなく Blue_area 出典がズレの原因だった、という認識でよいか確認する。
3. 112/168側は Blue_area=0.8596465、f_DNB=1.2721009174、F_form≈1.014 として確定する。
4. 134/168側は Blue_area=0.926529、f_DNB=0.8521727906、F_form≈1.363 として確定する。
5. 確定後、BT08-A2として current_bundle_input_v2 に必要列を集約する。
