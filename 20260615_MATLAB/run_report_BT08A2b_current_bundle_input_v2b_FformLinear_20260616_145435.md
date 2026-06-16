# BT08-A2b current_bundle_input_v2b FformLinear

作成日時: 20260616

## 1. 目的

BT08-A2でF1側3シートのみが対象になったため、修正版としてnoF1側のtm_108/tm_161/tm_164を含む6シートすべてにFform_linear関連列を追加する。既存F_formは上書きせず、Fform_legacyとして保持する。

## 2. 入力と出力

- input current_bundle v1: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`
- input r3: `バンドルデータ整理r3.xlsx`
- output current_bundle v2b: `H52Q_current_bundle_input_v2b_FformLinear_20260616_145435.xlsx`

## 3. 方針

```text
- 既存F_form列は上書きしない。
- 既存F_formは Fform_legacy として残す。
- 新しい定義は Fform_linear として追加する。
- noF1/F1の6シートすべてを対象にする。
- current_bundle_input_v2b作成段階ではマクロ再計算しない。
- マクロ用には BT08A2b_macro_replace_map を別途出す。
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

| sheet | kind | target_kind | rows | cols | mapped_rows | unmapped_rows | copy_status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| README_CURRENT | copied_as_cell_sheet |  | 16 | 2 |  |  | OK |
| DATA_DICTIONARY_CURRENT | copied_as_cell_sheet |  | 73 | 6 |  |  | OK |
| SOURCE_MANIFEST | copied_as_cell_sheet |  | 10 | 9 |  |  | OK |
| QUALITY_NOTES | copied_as_cell_sheet |  | 9 | 2 |  |  | OK |
| tm_108 | bundle_data_with_Fform_linear_added | noF1 | 14 | 83 | 14 | 0 | OK |
| tm_161 | bundle_data_with_Fform_linear_added | noF1 | 23 | 83 | 23 | 0 | OK |
| tm_164 | bundle_data_with_Fform_linear_added | noF1 | 21 | 83 | 21 | 0 | OK |
| tm_F1_108 | bundle_data_with_Fform_linear_added | F1 | 14 | 83 | 14 | 0 | OK |
| tm_F1_161 | bundle_data_with_Fform_linear_added | F1 | 23 | 83 | 23 | 0 | OK |
| tm_F1_164 | bundle_data_with_Fform_linear_added | F1 | 21 | 83 | 21 | 0 | OK |

## 6. Sheet kind summary

| sheet | target_kind | N_rows | N_mapped | mean_Fform_legacy | mean_Fform_linear |
| --- | --- | --- | --- | --- | --- |
| tm_108 | noF1 | 14 | 14 | 0.66949453 | 0.63608627 |
| tm_161 | noF1 | 23 | 23 | 1 | 1 |
| tm_164 | noF1 | 21 | 21 | 1.346381 | 1.2798813 |
| tm_F1_108 | F1 | 14 | 14 | 0.66949453 | 0.63608627 |
| tm_F1_161 | F1 | 23 | 23 | 1 | 1 |
| tm_F1_164 | F1 | 21 | 21 | 1.346381 | 1.2798813 |

## 7. Case summary

| case_label | Bundle | N_rows | N_mapped | N_noF1 | N_F1 | mean_Fform_legacy | mean_Fform_linear | mean_diff_linear_minus_legacy | mean_ratio_linear_to_legacy | min_z_current | max_z_current |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108_70in | 108 | 24 | 24 | 12 | 12 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | 0.7292863 | 0.7292863 |
| 108_76in | 108 | 4 | 4 | 2 | 2 | 0.760494 | 0.73367994 | -0.026814062 | 0.96474126 | 0.79179655 | 0.79179655 |
| 161_uniform | 161 | 46 | 46 | 23 | 23 | 1 | 1 | 0 | 1 | 0.99707054 | 0.99707054 |
| 164_112in | 164 | 2 | 2 | 1 | 1 | 1.014 | 0.8776443 | -0.1363557 | 0.86552692 | 0.66669791 | 0.66669791 |
| 164_134in_normal | 164 | 40 | 40 | 20 | 20 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | 0.79765643 | 0.79765643 |

## 8. Diff summary

| Bundle | N_rows | N_noF1 | N_F1 | mean_Fform_legacy | mean_Fform_linear | mean_diff_linear_minus_legacy | max_abs_diff | mean_ratio_linear_to_legacy |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | 28 | 14 | 14 | 0.66949453 | 0.63608627 | -0.033408257 | 0.034507289 | 0.9497599 |
| 161 | 46 | 23 | 23 | 1 | 1 | 0 | 0 | 1 |
| 164 | 42 | 21 | 21 | 1.346381 | 1.2798813 | -0.066499634 | 0.1363557 | 0.9495712 |

## 9. Macro replacement map preview

| sheet | target_kind | data_row_index | excel_row_if_header1 | Bundle | No | z_DNB_over_L_current | z_DNB_over_DH_current | nearest_master_case_label | master_z_DNB_ratio | mapping_abs_dz | Fform_legacy | Fform_linear | Fform_diff_linear_minus_legacy | Fform_ratio_linear_to_legacy | mapping_status | replace_target_column | new_value_column | replace_action | do_not_edit_original | macro_note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| tm_108 | noF1 | 1 | 2 | 108 | 229 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_108 | noF1 | 2 | 3 | 108 | 230 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_108 | noF1 | 3 | 4 | 108 | 231 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_108 | noF1 | 4 | 5 | 108 | 232 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_108 | noF1 | 5 | 6 | 108 | 242 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_108 | noF1 | 6 | 7 | 108 | 243 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_108 | noF1 | 7 | 8 | 108 | 244 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_108 | noF1 | 8 | 9 | 108 | 245 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_108 | noF1 | 9 | 10 | 108 | 246 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_108 | noF1 | 10 | 11 | 108 | 247 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_108 | noF1 | 11 | 12 | 108 | 248 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_108 | noF1 | 12 | 13 | 108 | 252 | 0.79179655 | 149.79523 | 108_76in | 0.791667 | 0.00012955455 | 0.760494 | 0.73367994 | -0.026814062 | 0.96474126 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_108 | noF1 | 13 | 14 | 108 | 253 | 0.79179655 | 149.79523 | 108_76in | 0.791667 | 0.00012955455 | 0.760494 | 0.73367994 | -0.026814062 | 0.96474126 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_108 | noF1 | 14 | 15 | 108 | 254 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 1 | 2 | 161 | 268 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 2 | 3 | 161 | 269 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 3 | 4 | 161 | 270 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 4 | 5 | 161 | 271 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 5 | 6 | 161 | 272 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 6 | 7 | 161 | 273 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 7 | 8 | 161 | 274 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 8 | 9 | 161 | 275 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 9 | 10 | 161 | 276 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 10 | 11 | 161 | 277 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 11 | 12 | 161 | 278 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 12 | 13 | 161 | 281 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 13 | 14 | 161 | 282 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 14 | 15 | 161 | 290 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 15 | 16 | 161 | 291 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 16 | 17 | 161 | 295 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 17 | 18 | 161 | 297 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 18 | 19 | 161 | 298 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 19 | 20 | 161 | 301 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 20 | 21 | 161 | 302 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 21 | 22 | 161 | 305 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 22 | 23 | 161 | 310 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_161 | noF1 | 23 | 24 | 161 | 317 | 0.99707054 | 361.35516 | 161_uniform | 0.997024 | 4.6541364e-05 | 1 | 1 | 0 | 1 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 1 | 2 | 164 | 319 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 2 | 3 | 164 | 320 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 3 | 4 | 164 | 322 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 4 | 5 | 164 | 323 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 5 | 6 | 164 | 325 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 6 | 7 | 164 | 326 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 7 | 8 | 164 | 327 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 8 | 9 | 164 | 329 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 9 | 10 | 164 | 330 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 10 | 11 | 164 | 331 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 11 | 12 | 164 | 334 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 12 | 13 | 164 | 335 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 13 | 14 | 164 | 336 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 14 | 15 | 164 | 338 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 15 | 16 | 164 | 339 | 0.66669791 | 241.62255 | 164_112in | 0.666667 | 3.0914225e-05 | 1.014 | 0.8776443 | -0.1363557 | 0.86552692 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 16 | 17 | 164 | 340 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 17 | 18 | 164 | 341 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 18 | 19 | 164 | 360 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 19 | 20 | 164 | 371 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 20 | 21 | 164 | 380 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_164 | noF1 | 21 | 22 | 164 | 381 | 0.79765643 | 289.08413 | 164_134in_normal | 0.797619 | 3.7433091e-05 | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | F1 | 1 | 2 | 108 | 229 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |
| tm_F1_108 | F1 | 2 | 3 | 108 | 230 | 0.7292863 | 137.96929 | 108_70in | 0.729167 | 0.00011930025 | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | F_form | Fform_linear | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true | This is a replacement map for a copied macro workbook. Do not overwrite original macro workbook. |

## 10. Decision flags

| item | status | value | reading |
| --- | --- | --- | --- |
| BT08A2b_position | OK |  | BT08-A2の修正版。noF1/F1の6シートすべてにFform_linearとlegacy列を集約する。 |
| definition | adopt | linear_v1 | F_form定義は全ケースで線形補間・線形積分に統一。 |
| legacy_policy | adopt | keep_legacy | 既存F_formは上書きせずFform_legacyとして残す。 |
| master_cases | OK | N=5 | Fform_linear masterを作成。 |
| target_sheets | diagnostic | N=6 | 対象シート数。期待値は6。 |
| row_mapping | OK | rows=116, noF1=58, F1=58 | 行ごとのlegacy→linear対応表を作成。 |
| A2b_fix_status | OK |  | BT08-A2で不足していたnoF1側も取り込めた。 |
| max_abs_diff | diagnostic | 0.1363557 | Fform_linearとlegacyの最大差。 |
| macro_replace_map | prepared | rows=116 | 次段階でマクロブックのコピーに適用する差し替え表。 |
| next | next | BT08-A3 / BT09-0 | マクロ投入用差し替え表の確認とマクロブック側F_form入力位置確認へ進む。 |

## 11. 次アクション

1. 出力された current_bundle_input_v2b の `BT08A2b_sheet_inventory` で、tm_108/tm_161/tm_164/tm_F1_108/tm_F1_161/tm_F1_164 の6シートが対象になっていることを確認する。
2. `BT08A2b_row_mapping` と `BT08A2b_macro_replace_map` を確認する。
3. 問題なければBT08-A3としてマクロ投入用F_form差し替え表を確定する。
4. その後BT09-0として、マクロブック側のF_form入力位置を確認する。
5. マクロブックは必ずコピーしてから、Fform_linear版を作る。
