# BT08-A1d F_form linear finalize

作成日時: 20260616

## 1. 目的

Excelをこれ以上手作業で編集せず、MATLAB計算とMarkdownログでF_form定義を確定する。既存F_formには、108では近傍点使用、164では線形補間、164通常ケースでは暫定的なBlue_area補正が混在していた可能性があるため、全ケースを線形補間・線形積分の統一ルールで再計算する。

## 2. 入力

- r3: `バンドルデータ整理r3.xlsx`
- current_bundle: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`

## 3. 統一ルール

```text
x_DNB = DNB位置 / 加熱長
f_DNB = interp1(x, f, x_DNB)
Blue_area_linear = integral_0^x_DNB f(x) dx
Orange_area_linear = x_DNB * f_DNB
F_form_linear = Blue_area_linear / Orange_area_linear
```

## 4. F_form_linear

| case_label | Bundle | z_DNB_ratio | profile_sheet | profile_source_cols | profile_N | z_min | z_max | f_DNB_linear | Blue_area_linear | Orange_area_linear | Fform_linear | Blue_area_method | f_DNB_method | Orange_area_method | r3_note | r3_blue_area_stored | r3_total_area_stored | r3_z_heat_ratio_stored | diff_linear_blue_minus_r3_stored_blue | diff_linear_Fform_vs_r3blue_interp |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108_70in | 108 | 0.729167 | 非一様加熱を一様加熱に補正108 | E/F | 28 | 0 | 1 | 1.5825311 | 0.71522932 | 1.1539295 | 0.61982066 | linear_integral_0_to_xDNB | linear_interp_at_xDNB | xDNB_times_fDNB | DNB位置 z=70/96 inch | 0.755174 | 0.994499 | 0.75935119 | -0.039944678 | -0.034616222 |
| 108_76in | 108 | 0.791667 | 非一様加熱を一様加熱に補正108 | E/F | 28 | 0 | 1 | 1.3919731 | 0.80849999 | 1.1019791 | 0.73367994 | linear_integral_0_to_xDNB | linear_interp_at_xDNB | xDNB_times_fDNB | DNB位置 z=76/96 inch | 0.862749 | 0.994499 | 0.86752123 | -0.054249006 | -0.049228705 |
| 161_uniform | 161 | 0.997024 | 非一様加熱を一様加熱に補正161  | E/F | 28 | 0 | 1 | 1 | 0.997024 | 0.997024 | 1 | linear_integral_0_to_xDNB | linear_interp_at_xDNB | xDNB_times_fDNB | 一様加熱 | 1 | 1 | 1 | -0.002976 | -0.002984883 |
| 164_112in | 164 | 0.666667 | 非一様加熱を一様加熱に補正164 | E/F | 27 | 0 | 1 | 1.2720999 | 0.74430116 | 0.84806699 | 0.8776443 | linear_integral_0_to_xDNB | linear_interp_at_xDNB | xDNB_times_fDNB | DNB位置 z=112/168 inch | 0.8596465 | 0.999825 | 0.85979696 | -0.11534534 | -0.1360097 |
| 164_134in_normal | 164 | 0.797619 | 非一様加熱を一様加熱に補正164 | E/F | 27 | 0 | 1 | 0.8520446 | 0.88348441 | 0.67960696 | 1.2999932 | linear_integral_0_to_xDNB | linear_interp_at_xDNB | xDNB_times_fDNB | DNB位置 z=134/168 inch | 0.9101065 | 0.999825 | 0.9102658 | -0.026622092 | -0.039172777 |

## 5. Legacy comparison

| case_label | Bundle | z_DNB_ratio | current_match_N | current_z_mean | Fform_legacy_mean | Fform_legacy_sd | Fform_linear | diff_linear_minus_legacy | ratio_linear_to_legacy | Blue_area_linear | Blue_area_legacy_stored_r3 | diff_Blue_linear_minus_r3stored | f_DNB_linear | Orange_area_linear | compare_status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108_70in | 108 | 0.729167 | 12 | 0.7292863 | 0.65432795 | 1.1595901e-16 | 0.61982066 | -0.034507289 | 0.94726301 | 0.71522932 | 0.755174 | -0.039944678 | 1.5825311 | 1.1539295 | changed_lt_5e-2 |
| 108_76in | 108 | 0.791667 | 2 | 0.79179655 | 0.760494 | 0 | 0.73367994 | -0.026814062 | 0.96474126 | 0.80849999 | 0.862749 | -0.054249006 | 1.3919731 | 1.1019791 | changed_lt_5e-2 |
| 161_uniform | 161 | 0.997024 | 23 | 0.99707054 | 1 | 0 | 1 | 0 | 1 | 0.997024 | 1 | -0.002976 | 1 | 0.997024 | same_lt_1e-3 |
| 164_112in | 164 | 0.666667 | 1 | 0.66669791 | 1.014 | 0 | 0.8776443 | -0.1363557 | 0.86552692 | 0.74430116 | 0.8596465 | -0.11534534 | 1.2720999 | 0.84806699 | changed_ge_5e-2 |
| 164_134in_normal | 164 | 0.797619 | 20 | 0.79765643 | 1.363 | 2.2781296e-16 | 1.2999932 | -0.063006831 | 0.95377342 | 0.88348441 | 0.9101065 | -0.026622092 | 0.8520446 | 0.67960696 | changed_ge_5e-2 |

## 6. Final F_form table

| Fform_definition_version | case_label | Bundle | z_DNB_ratio | f_DNB_used | Blue_area_used | Orange_area_used | Fform_final_linear | Fform_legacy_mean | diff_linear_minus_legacy | ratio_linear_to_legacy | compare_status | Fform_status | definition_note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| linear_v1 | 108_70in | 108 | 0.729167 | 1.5825311 | 0.71522932 | 1.1539295 | 0.61982066 | 0.65432795 | -0.034507289 | 0.94726301 | changed_lt_5e-2 | adopt_linear_v1 | 全ケースでf_DNBを線形補間し、Blue_areaを0からx_DNBまで線形補間積分したF_form。既存F_formはlegacyとして残す。 |
| linear_v1 | 108_76in | 108 | 0.791667 | 1.3919731 | 0.80849999 | 1.1019791 | 0.73367994 | 0.760494 | -0.026814062 | 0.96474126 | changed_lt_5e-2 | adopt_linear_v1 | 全ケースでf_DNBを線形補間し、Blue_areaを0からx_DNBまで線形補間積分したF_form。既存F_formはlegacyとして残す。 |
| linear_v1 | 161_uniform | 161 | 0.997024 | 1 | 0.997024 | 0.997024 | 1 | 1 | 0 | 1 | same_lt_1e-3 | uniform_or_nearly_uniform | 全ケースでf_DNBを線形補間し、Blue_areaを0からx_DNBまで線形補間積分したF_form。既存F_formはlegacyとして残す。 |
| linear_v1 | 164_112in | 164 | 0.666667 | 1.2720999 | 0.74430116 | 0.84806699 | 0.8776443 | 1.014 | -0.1363557 | 0.86552692 | changed_ge_5e-2 | adopt_linear_v1 | 全ケースでf_DNBを線形補間し、Blue_areaを0からx_DNBまで線形補間積分したF_form。既存F_formはlegacyとして残す。 |
| linear_v1 | 164_134in_normal | 164 | 0.797619 | 0.8520446 | 0.88348441 | 0.67960696 | 1.2999932 | 1.363 | -0.063006831 | 0.95377342 | changed_ge_5e-2 | adopt_linear_v1 | 全ケースでf_DNBを線形補間し、Blue_areaを0からx_DNBまで線形補間積分したF_form。既存F_formはlegacyとして残す。 |

## 7. Decision flags

| item | status | value | reading |
| --- | --- | --- | --- |
| definition | adopt | linear_v1 | F_formは全ケースで線形補間・線形積分に統一する。 |
| excel_policy | adopt | no_manual_excel_edit | Excelを直接いじり回さず、MATLAB出力とMarkdownログで定義を確定する。 |
| legacy_policy | adopt | keep_legacy | 既存F_formはlegacyとして残し、Fform_linearとの差分を残す。 |
| case_108_70in | changed_lt_5e-2 | legacy=0.65432795, linear=0.61982066, diff=-0.034507289 | 定義変更によるF_form差。 |
| case_108_76in | changed_lt_5e-2 | legacy=0.760494, linear=0.73367994, diff=-0.026814062 | 定義変更によるF_form差。 |
| case_161_uniform | same_lt_1e-3 | legacy=1, linear=1, diff=0 | 定義変更によるF_form差。 |
| case_164_112in | changed_ge_5e-2 | legacy=1.014, linear=0.8776443, diff=-0.1363557 | 定義変更によるF_form差。 |
| case_164_134in_normal | changed_ge_5e-2 | legacy=1.363, linear=1.2999932, diff=-0.063006831 | 定義変更によるF_form差。 |
| max_change | diagnostic | 0.1363557 | legacyからlinear_v1への最大変化。 |
| next | next | BT08-A2 | current_bundle_input_v2へFform_linear列と出典列を集約する。P/M影響はその後の別タスクで確認する。 |

## 8. Fields for current_bundle_input_v2

| field | suggested_value_or_formula | meaning |
| --- | --- | --- |
| Fform_definition_version | linear_v1 | F_form定義バージョン |
| Fform_source_book | バンドルデータ整理r3.xlsx | 軸方向出力分布の出典 |
| Fform_source_sheet | 非一様加熱を一様加熱に補正108/161/164 | 軸方向出力分布シート |
| Fform_case_label | 108_70in / 108_76in / 161_uniform / 164_112in / 164_134in_normal | DNB位置別の識別 |
| Fform_DNB_z_ratio | x_DNB = DNB位置 / 加熱長 | DNB位置 |
| Fform_q_DNB_linear | interp1(x,f,x_DNB) | DNB位置の軸方向係数 |
| Fform_blue_area_linear | integral_0^xDNB f(x) dx by linear interpolation | DNB位置までの線形補間積分面積 |
| Fform_orange_area_linear | x_DNB * q_DNB_linear | 基準長方形面積 |
| Fform_linear | Fform_blue_area_linear / Fform_orange_area_linear | 修正後F_form |
| Fform_legacy | current_bundle_input existing F_form | 既存F_form |
| Fform_diff_linear_minus_legacy | Fform_linear - Fform_legacy | 定義変更差 |
| Fform_ratio_linear_to_legacy | Fform_linear / Fform_legacy | 定義変更比 |
| Fform_status | adopt_linear / uniform / legacy_trace | 採用状態 |
| Fform_definition_note | 全ケースを線形補間・線形積分で統一 | 定義メモ |

## 9. 次アクション

1. このMarkdownのFform_linearを確認する。
2. 問題なければ、F_formはlinear_v1として確定する。
3. Excel手作業ではなく、次のBT08-A2でcurrent_bundle_input_v2へ列として集約する。
4. 既存F_formはlegacyとして残し、Fform_linearとの差分も残す。
5. その後、必要ならFform_linearを使ったP/M影響を別タスクで確認する。
