# BT08-A3 macro F_form replace package

作成日時: 20260616

## 1. 目的

BT08-A2bで作成したcurrent_bundle_input_v2bから、マクロブックへ投入するためのF_form差し替え表を確定する。この段階ではマクロブックを編集しない。

## 2. 入力と出力

- input v2b: `H52Q_current_bundle_input_v2b_FformLinear_20260616_145435.xlsx`
- output package: `BT08A3_macro_Fform_replace_package_20260616_145859.xlsx`
- output csv: `BT08A3_macro_Fform_replace_map_20260616_145859.csv`

## 3. 方針

```text
- 元マクロブックは編集しない。
- マクロブックはBT09以降でコピーしてから編集する。
- 差し替え対象はF_form列。
- 差し替え値はFform_linear列。
- legacy値はoriginal_valueとして保持する。
```

## 4. QC flags

| item | status | value | reading |
| --- | --- | --- | --- |
| input_rows | OK | 116 | 差し替え表の行数。期待値はnoF1 58 + F1 58 = 116。 |
| target_kind_balance | OK | noF1=58, F1=58 | noF1/F1の両方を含む。 |
| target_sheet_count | OK | 6 | 6対象シートを確認。 |
| mapping_status | OK | 116/116 | 全行マップ済み。 |
| mapping_abs_dz | OK | 0.00012955455 | DNB位置対応差は小さい。 |
| max_abs_Fform_change | diagnostic | 0.1363557 | legacyからlinear_v1への最大変更量。 |
| master_case_count | OK | 5 | Fform linear masterは5ケース。 |
| macro_edit_policy | adopt | copy_only | 元マクロブックは編集しない。コピー側にだけ適用する。 |
| next | next | BT09-0 | マクロブック側のF_form入力位置確認へ進む。 |

## 5. Summary by sheet

| sheet | target_kind | N_rows | N_mapped | mean_original_value | mean_replace_value | mean_delta | max_abs_delta | mean_ratio | min_No | max_No |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| tm_108 | noF1 | 14 | 14 | 0.66949453 | 0.63608627 | -0.033408257 | 0.034507289 | 0.9497599 | 229 | 254 |
| tm_161 | noF1 | 23 | 23 | 1 | 1 | 0 | 0 | 1 | 268 | 317 |
| tm_164 | noF1 | 21 | 21 | 1.346381 | 1.2798813 | -0.066499634 | 0.1363557 | 0.9495712 | 319 | 381 |
| tm_F1_108 | F1 | 14 | 14 | 0.66949453 | 0.63608627 | -0.033408257 | 0.034507289 | 0.9497599 | 229 | 254 |
| tm_F1_161 | F1 | 23 | 23 | 1 | 1 | 0 | 0 | 1 | 268 | 317 |
| tm_F1_164 | F1 | 21 | 21 | 1.346381 | 1.2798813 | -0.066499634 | 0.1363557 | 0.9495712 | 319 | 381 |

## 6. Summary by case

| nearest_master_case_label | Bundle | N_rows | N_mapped | mean_original_value | mean_replace_value | mean_delta | max_abs_delta | mean_ratio | min_No | max_No |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108_70in | 108 | 24 | 24 | 0.65432795 | 0.61982066 | -0.034507289 | 0.034507289 | 0.94726301 | 229 | 254 |
| 108_76in | 108 | 4 | 4 | 0.760494 | 0.73367994 | -0.026814062 | 0.026814062 | 0.96474126 | 252 | 253 |
| 161_uniform | 161 | 46 | 46 | 1 | 1 | 0 | 0 | 1 | 268 | 317 |
| 164_112in | 164 | 2 | 2 | 1.014 | 0.8776443 | -0.1363557 | 0.1363557 | 0.86552692 | 339 | 339 |
| 164_134in_normal | 164 | 40 | 40 | 1.363 | 1.2999932 | -0.063006831 | 0.063006831 | 0.95377342 | 319 | 381 |

## 7. Summary by bundle

| Bundle | N_rows | N_mapped | mean_original_value | mean_replace_value | mean_delta | max_abs_delta | mean_ratio | min_No | max_No |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | 28 | 28 | 0.66949453 | 0.63608627 | -0.033408257 | 0.034507289 | 0.9497599 | 229 | 254 |
| 161 | 46 | 46 | 1 | 1 | 0 | 0 | 1 | 268 | 317 |
| 164 | 42 | 42 | 1.346381 | 1.2798813 | -0.066499634 | 0.1363557 | 0.9495712 | 319 | 381 |

## 8. Macro replace map preview

| sheet | target_kind | data_row_index | excel_row_if_header1 | Bundle | No | nearest_master_case_label | z_DNB_over_L_current | master_z_DNB_ratio | mapping_abs_dz | legacy_column_name_expected | linear_column_name_in_v2b | original_value | replace_value | value_delta | value_ratio | mapping_status | replace_action | do_not_edit_original |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| tm_108 | noF1 | 1 | 2 | 108 | 229 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_108 | noF1 | 2 | 3 | 108 | 230 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_108 | noF1 | 3 | 4 | 108 | 231 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_108 | noF1 | 4 | 5 | 108 | 232 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_108 | noF1 | 5 | 6 | 108 | 242 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_108 | noF1 | 6 | 7 | 108 | 243 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_108 | noF1 | 7 | 8 | 108 | 244 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_108 | noF1 | 8 | 9 | 108 | 245 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_108 | noF1 | 9 | 10 | 108 | 246 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_108 | noF1 | 10 | 11 | 108 | 247 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_108 | noF1 | 11 | 12 | 108 | 248 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_108 | noF1 | 12 | 13 | 108 | 252 | 108_76in | 0.79179655 | 0.791667 | 0.00012955455 | F_form | Fform_linear | 0.760494 | 0.73367994 | -0.026814062 | 0.96474126 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_108 | noF1 | 13 | 14 | 108 | 253 | 108_76in | 0.79179655 | 0.791667 | 0.00012955455 | F_form | Fform_linear | 0.760494 | 0.73367994 | -0.026814062 | 0.96474126 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_108 | noF1 | 14 | 15 | 108 | 254 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 1 | 2 | 161 | 268 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 2 | 3 | 161 | 269 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 3 | 4 | 161 | 270 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 4 | 5 | 161 | 271 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 5 | 6 | 161 | 272 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 6 | 7 | 161 | 273 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 7 | 8 | 161 | 274 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 8 | 9 | 161 | 275 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 9 | 10 | 161 | 276 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 10 | 11 | 161 | 277 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 11 | 12 | 161 | 278 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 12 | 13 | 161 | 281 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 13 | 14 | 161 | 282 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 14 | 15 | 161 | 290 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 15 | 16 | 161 | 291 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 16 | 17 | 161 | 295 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 17 | 18 | 161 | 297 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 18 | 19 | 161 | 298 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 19 | 20 | 161 | 301 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 20 | 21 | 161 | 302 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 21 | 22 | 161 | 305 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 22 | 23 | 161 | 310 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_161 | noF1 | 23 | 24 | 161 | 317 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 1 | 2 | 164 | 319 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 2 | 3 | 164 | 320 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 3 | 4 | 164 | 322 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 4 | 5 | 164 | 323 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 5 | 6 | 164 | 325 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 6 | 7 | 164 | 326 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 7 | 8 | 164 | 327 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 8 | 9 | 164 | 329 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 9 | 10 | 164 | 330 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 10 | 11 | 164 | 331 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 11 | 12 | 164 | 334 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 12 | 13 | 164 | 335 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 13 | 14 | 164 | 336 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 14 | 15 | 164 | 338 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 15 | 16 | 164 | 339 | 164_112in | 0.66669791 | 0.666667 | 3.0914225e-05 | F_form | Fform_linear | 1.014 | 0.8776443 | -0.1363557 | 0.86552692 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 16 | 17 | 164 | 340 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 17 | 18 | 164 | 341 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 18 | 19 | 164 | 360 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 19 | 20 | 164 | 371 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 20 | 21 | 164 | 380 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_164 | noF1 | 21 | 22 | 164 | 381 | 164_134in_normal | 0.79765643 | 0.797619 | 3.7433091e-05 | F_form | Fform_linear | 1.363 | 1.2999932 | -0.063006831 | 0.95377342 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_108 | F1 | 1 | 2 | 108 | 229 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_108 | F1 | 2 | 3 | 108 | 230 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_108 | F1 | 3 | 4 | 108 | 231 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_108 | F1 | 4 | 5 | 108 | 232 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_108 | F1 | 5 | 6 | 108 | 242 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_108 | F1 | 6 | 7 | 108 | 243 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_108 | F1 | 7 | 8 | 108 | 244 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_108 | F1 | 8 | 9 | 108 | 245 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_108 | F1 | 9 | 10 | 108 | 246 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_108 | F1 | 10 | 11 | 108 | 247 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_108 | F1 | 11 | 12 | 108 | 248 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_108 | F1 | 12 | 13 | 108 | 252 | 108_76in | 0.79179655 | 0.791667 | 0.00012955455 | F_form | Fform_linear | 0.760494 | 0.73367994 | -0.026814062 | 0.96474126 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_108 | F1 | 13 | 14 | 108 | 253 | 108_76in | 0.79179655 | 0.791667 | 0.00012955455 | F_form | Fform_linear | 0.760494 | 0.73367994 | -0.026814062 | 0.96474126 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_108 | F1 | 14 | 15 | 108 | 254 | 108_70in | 0.7292863 | 0.729167 | 0.00011930025 | F_form | Fform_linear | 0.65432795 | 0.61982066 | -0.034507289 | 0.94726301 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_161 | F1 | 1 | 2 | 161 | 268 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_161 | F1 | 2 | 3 | 161 | 269 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_161 | F1 | 3 | 4 | 161 | 270 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_161 | F1 | 4 | 5 | 161 | 271 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_161 | F1 | 5 | 6 | 161 | 272 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_161 | F1 | 6 | 7 | 161 | 273 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_161 | F1 | 7 | 8 | 161 | 274 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |
| tm_F1_161 | F1 | 8 | 9 | 161 | 275 | 161_uniform | 0.99707054 | 0.997024 | 4.6541364e-05 | F_form | Fform_linear | 1 | 1 | 0 | 1 | mapped | replace_legacy_F_form_with_Fform_linear_in_macro_copy_only | true |

## 9. Macro handoff steps

| step | action | detail |
| --- | --- | --- |
| 1 | Confirm package | Open BT08A3_macro_Fform_replace_package_20260616_145859.xlsx and check A3_QC_flags. |
| 2 | Confirm replacement map | Check A3_macro_replace_map: sheet, target_kind, No, original_value, replace_value. |
| 3 | Do not edit original macro workbook | Make a copy of the macro workbook before changing F_form. |
| 4 | Find F_form input location | BT09-0 should identify the exact sheet and column in the macro workbook where F_form is read. |
| 5 | Apply replacement only to copy | Use replace_value from BT08A3_macro_Fform_replace_map_20260616_145859.csv or A3_macro_replace_map. |
| 6 | Keep legacy file | Original macro workbook and current_bundle_input_v1 remain unchanged. |
| 7 | Run macro | Run only noF1/F1 comparison unless intentionally expanding scope. |
| 8 | Export recalculated results | Save the macro output with a new name including FformLinear or linear_v1. |
| 9 | Run BT10 | Use recalculated output to diagnose PM impact of Fform_linear. |

## 10. 次アクション

1. `A3_QC_flags` がOKであることを確認する。
2. `A3_macro_replace_map` の sheet / No / original_value / replace_value を確認する。
3. 次はBT09-0として、マクロブック側のF_form入力位置を確認する。
4. マクロブックをコピーし、コピー側だけにFform_linearを投入する。
5. マクロ再計算後、BT10でPM影響を診断する。
