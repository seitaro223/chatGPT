# BT08-A2 current_bundle_input_v2 FformLinear

作成日時: 20260616

## 1. 目的

BT08-A1dで確定したF_form linear_v1をcurrent_bundle_input_v1へ集約し、current_bundle_input_v2を作成する。既存F_formは上書きせずlegacyとして残し、Fform_linearを別列として追加する。

## 2. 入力と出力

- input current_bundle v1: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`
- input r3: `バンドルデータ整理r3.xlsx`
- output current_bundle v2: `H52Q_current_bundle_input_v2_FformLinear_20260616_145015.xlsx`

## 3. 方針

```text
- 既存F_form列は上書きしない。
- 既存F_formは Fform_legacy として残す。
- 新しい定義は Fform_linear として追加する。
- current_bundle_input_v2作成段階ではマクロ再計算しない。
- マクロ用には BT08A2_macro_replace_map を別途出す。
```

## 4. Fform linear master

| Fform_definition_version | case_label | Bundle | z_DNB_ratio | profile_sheet | profile_source_cols | profile_N | z_min | z_max | f_DNB_linear | Blue_area_linear | Orange_area_linear | Fform_linear | Blue_area_method | f_DNB_method | Orange_area_method | Fform_source_book | Fform_source_sheet | r3_blue_area_stored_legacy_like | r3_total_area_stored | r3_z_heat_ratio_stored | r3_note | Fform_status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| linear_v1 | 108_70in | 108 | 0.729167 | 非一様加熱を一様加熱に補正108 | E/F | 28 | 0 | 1 | 1.5825311 | 0.71522932 | 1.1539295 | 0.61982066 | linear_integral_0_to_xDNB | linear_interp_at_xDNB | xDNB_times_fDNB | バンドルデータ整理r3.xlsx | 非一様加熱を一様加熱に補正108 | 0.755174 | 0.994499 | 0.75935119 | DNB位置 z=70/96 inch | adopt_linear_v1 |
| linear_v1 | 108_76in | 108 | 0.791667 | 非一様加熱を一様加熱に補正108 | E/F | 28 | 0 | 1 | 1.3919731 | 0.80849999 | 1.1019791 | 0.73367994 | linear_integral_0_to_xDNB | linear_interp_at_xDNB | xDNB_times_fDNB | バンドルデータ整理r3.xlsx | 非一様加熱を一様加熱に補正108 | 0.862749 | 0.994499 | 0.86752123 | DNB位置 z=76/96 inch | adopt_linear_v1 |
| linear_v1 | 161_uniform | 161 | 0.997024 | 非一様加熱を一様加熱に補正161  | E/F | 28 | 0 | 1 | 1 | 0.997024 | 0.997024 | 1 | linear_integral_0_to_xDNB | linear_interp_at_xDNB | xDNB_times_fDNB | バンドルデータ整理r3.xlsx | 非一様加熱を一様加熱に補正161  | 1 | 1 | 1 | 一様加熱 | uniform_or_nearly_uniform |
| linear_v1 | 164_112in | 164 | 0.666667 | 非一様加熱を一様加熱に補正164 | E/F | 27 | 0 | 1 | 1.2720999 | 0.74430116 | 0.84806699 | 0.8776443 | linear_integral_0_to_xDNB | linear_interp_at_xDNB | xDNB_times_fDNB | バンドルデータ整理r3.xlsx | 非一様加熱を一様加熱に補正164 | 0.8596465 | 0.999825 | 0.85979696 | DNB位置 z=112/168 inch | adopt_linear_v1 |
| linear_v1 | 164_134in_normal | 164 | 0.797619 | 非一様加熱を一様加熱に補正164 | E/F | 27 | 0 | 1 | 0.8520446 | 0.88348441 | 0.67960696 | 1.2999932 | linear_integral_0_to_xDNB | linear_interp_at_xDNB | xDNB_times_fDNB | バンドルデータ整理r3.xlsx | 非一様加熱を一様加熱に補正164 | 0.9101065 | 0.999825 | 0.9102658 | DNB位置 z=134/168 inch | adopt_linear_v1 |

## 5. Sheet inventory

| sheet | kind | rows | cols | mapped_rows | unmapped_rows |
| --- | --- | --- | --- | --- | --- |
| README_CURRENT | copied_as_cell_sheet | 16 | 2 |  |  |
| DATA_DICTIONARY_CURRENT | copy_failed_or_unsupported |  |  |  |  |
| SOURCE_MANIFEST | copy_failed_or_unsupported |  |  |  |  |
| QUALITY_NOTES | copied_as_cell_sheet | 9 | 2 |  |  |
| tm_108 | copied_as_cell_sheet | 15 | 70 |  |  |
| tm_161 | copied_as_cell_sheet | 24 | 70 |  |  |
| tm_164 | copied_as_cell_sheet | 22 | 70 |  |  |
| tm_F1_108 | bundle_data_with_Fform_linear_added | 14 | 82 | 14 | 0 |
| tm_F1_161 | bundle_data_with_Fform_linear_added | 23 | 82 | 23 | 0 |
| tm_F1_164 | bundle_data_with_Fform_linear_added | 21 | 82 | 21 | 0 |

## 6. Case summary

| case_label | Bundle | N_rows | N_mapped | mean_Fform_legacy | mean_Fform_linear | mean_diff_linear_minus_legacy | mean_ratio_linear_to_legacy | min_z_current | max_z_current |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108_70in | 108 | 12 | 12 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | 0.7292863 | 0.7292863 |
| 108_76in | 108 | 2 | 2 | 0.760494 | 0.73367994 | -0.026814062 | 0.96474126 | 0.79179655 | 0.79179655 |
| 161_uniform | 161 | 23 | 23 | 1 | 1 | 0 | 1 | 0.99707054 | 0.99707054 |
| 164_112in | 164 | 1 | 1 | 1.014 | 0.8776443 | -0.1363557 | 0.86552692 | 0.66669791 | 0.66669791 |
| 164_134in_normal | 164 | 20 | 20 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | 0.79765643 | 0.79765643 |

## 7. Diff summary

| Bundle | N_rows | mean_Fform_legacy | mean_Fform_linear | mean_diff_linear_minus_legacy | max_abs_diff | mean_ratio_linear_to_legacy |
| --- | --- | --- | --- | --- | --- | --- |
| 108 | 14 | 0.66949453 | 0.63608627 | -0.033408257 | 0.034507289 | 0.9497599 |
| 161 | 23 | 1 | 1 | 0 | 0 | 1 |
| 164 | 21 | 1.346381 | 1.2798813 | -0.066499634 | 0.1363557 | 0.9495712 |

## 8. Macro replacement map preview

| sheet | data_row_index | excel_row_if_header1 | Bundle | No | z_DNB_over_L_current | z_DNB_over_DH_current | nearest_master_case_label | master_z_DNB_ratio | mapping_abs_dz | Fform_legacy | Fform_linear | Fform_diff_linear_minus_legacy | Fform_ratio_linear_to_legacy | mapping_status | replace_target_column | new_value_column | replace_action | do_not_edit_original | macro_note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| tm_F1_108 | 1 | 2 | 108 | 229 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | 2 | 3 | 108 | 230 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | 3 | 4 | 108 | 231 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | 4 | 5 | 108 | 232 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | 5 | 6 | 108 | 242 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | 6 | 7 | 108 | 243 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | 7 | 8 | 108 | 244 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | 8 | 9 | 108 | 245 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | 9 | 10 | 108 | 246 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | 10 | 11 | 108 | 247 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | 11 | 12 | 108 | 248 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | 12 | 13 | 108 | 252 | 0.79179655 | 149.79523 | 108_76in | 0.791667 | 0.00012955455 | 0.760494 | 0.73367994 | -0.026814062 | 0.96474126 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | 13 | 14 | 108 | 253 | 0.79179655 | 149.79523 | 108_76in | 0.791667 | 0.00012955455 | 0.760494 | 0.73367994 | -0.026814062 | 0.96474126 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | 14 | 15 | 108 | 254 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 1 | 2 | 161 | 268 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 2 | 3 | 161 | 269 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 3 | 4 | 161 | 270 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 4 | 5 | 161 | 271 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 5 | 6 | 161 | 272 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 6 | 7 | 161 | 273 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 7 | 8 | 161 | 274 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 8 | 9 | 161 | 275 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 9 | 10 | 161 | 276 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 10 | 11 | 161 | 277 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 11 | 12 | 161 | 278 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 12 | 13 | 161 | 281 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 13 | 14 | 161 | 282 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 14 | 15 | 161 | 290 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 15 | 16 | 161 | 291 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 16 | 17 | 161 | 295 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 17 | 18 | 161 | 297 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 18 | 19 | 161 | 298 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 19 | 20 | 161 | 301 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 20 | 21 | 161 | 302 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 21 | 22 | 161 | 305 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 22 | 23 | 161 | 310 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_161 | 23 | 24 | 161 | 317 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_164 | 1 | 2 | 164 | 319 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_164 | 2 | 3 | 164 | 320 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_164 | 3 | 4 | 164 | 322 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |

## 9. Decision flags

| item | status | value | reading |
| --- | --- | --- | --- |
| BT08A2_position | OK |  | current_bundle_input_v2にFform_linearとlegacy列を集約した。マクロ再計算はまだ行わない。 |
| definition | adopt | linear_v1 | F_form定義は全ケースで線形補間・線形積分に統一。 |
| legacy_policy | adopt | keep_legacy | 既存F_formは上書きせずFform_legacyとして残す。 |
| master_cases | OK | N=5 | Fform_linear masterを作成。 |
| target_sheets | OK | N=3 | noF1/F1の108/161/164対象シートに列を追加。 |
| row_mapping | OK | rows=58 | 行ごとのlegacy→linear対応表を作成。 |
| max_abs_diff | diagnostic | 0.1363557 | Fform_linearとlegacyの最大差。 |
| macro_replace_map | prepared | rows=58 | 次段階でマクロブックのコピーに適用する差し替え表。 |
| next | next | BT08-A3 / BT09-0 | マクロ投入用差し替え表の確認とマクロブック側F_form入力位置確認へ進む。 |

## 10. 次アクション

1. 出力された current_bundle_input_v2 の `BT08A2_Fform_linear_master` と `BT08A2_row_mapping` を確認する。
2. 問題なければ、次はBT08-A3としてマクロ投入用F_form差し替え表を確定する。
3. その後BT09-0として、マクロブック側のF_form入力位置を確認する。
4. マクロブックは必ずコピーしてから、Fform_linear版を作る。
5. Fform_linear版のマクロ再計算後、BT10としてPM影響を再診断する。
