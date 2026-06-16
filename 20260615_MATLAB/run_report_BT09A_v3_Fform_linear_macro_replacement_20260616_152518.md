# BT09-A Fform_linear macro replacement

作成日時: 20260616

## 1. 目的

BT08-A3で確定したF_form差し替え表を使い、F1なし版・F1あり版マクロブックのコピーにFform_linearを投入する。元マクロブックは上書きしない。

## 1.1 v2/v3修正点

```text
v1では Excel COM の ws.Cells.Item(r,c).Value で環境依存エラーが出た。
v2/v3では ws.Range('BG2').Value のようなA1セルアドレス指定でF_formを書き込む。
```

## 2. 入力

- A3 package: `BT08A3_macro_Fform_replace_package_20260616_145859.xlsx`
- noF1 macro: `celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm`
- F1 macro: `celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm`

## 3. マクロブック側の差し替え位置

```text
sheet      = tm
No列       = M列
F_form列   = BG列
header row = 1
data start = 2
row match  = No
```

## 4. Workbook summary

| input_macro_file | output_macro_file | target_kind | macro_sheet | No_header_cell | Fform_header_cell | data_start_row | last_row_checked | N_replace_rows | N_old_value_mismatch_vs_A3 | min_No | max_No | mean_old_Fform | mean_new_Fform | mean_delta_new_minus_old | max_abs_delta_new_minus_old | status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | M1 | BG1 | 2 | 59 | 58 | 0 | 229 | 381 | 1.0456366 | 1.0134951 | -0.032141516 | 0.1363557 | copy_written_no_macro_run |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | M1 | BG1 | 2 | 59 | 58 | 0 | 229 | 381 | 1.0456366 | 1.0134951 | -0.032141516 | 0.1363557 | copy_written_no_macro_run |

## 5. QC flags

| item | status | value | reading |
| --- | --- | --- | --- |
| workbooks_processed | OK | 2 | 処理したマクロブック数。期待値は2。 |
| replacement_rows | OK | noF1=58, F1=58 | 各マクロブックで置換行あり。 |
| old_value_match_A3 | OK | 0 mismatches | コピー前のF_form値がA3 original_valueと一致。 |
| output_files_exist | OK | true | コピー版マクロブックが作成された。 |
| edit_policy | adopt | copy_only | 元マクロブックは上書きしていない。 |
| macro_run | not_done | manual_next | このスクリプトはマクロを実行していない。 |
| next | next | run_macro_then_BT10 | コピー版を開いてマクロ再計算し、その結果をBT10で診断する。 |

## 6. Summary by bundle

| target_kind | Bundle | N_rows | N_old_match_A3 | mean_old_Fform | mean_new_Fform | mean_delta | max_abs_delta | min_No | max_No |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| F1 | 108 | 14 | 14 | 0.66949453 | 0.63608627 | -0.033408257 | 0.034507289 | 229 | 254 |
| F1 | 161 | 23 | 23 | 1 | 1 | 0 | 0 | 268 | 317 |
| F1 | 164 | 21 | 21 | 1.346381 | 1.2798813 | -0.066499634 | 0.1363557 | 319 | 381 |
| noF1 | 108 | 14 | 14 | 0.66949453 | 0.63608627 | -0.033408257 | 0.034507289 | 229 | 254 |
| noF1 | 161 | 23 | 23 | 1 | 1 | 0 | 0 | 268 | 317 |
| noF1 | 164 | 21 | 21 | 1.346381 | 1.2798813 | -0.066499634 | 0.1363557 | 319 | 381 |

## 7. Summary by case

| target_kind | nearest_master_case_label | N_rows | N_old_match_A3 | mean_old_Fform | mean_new_Fform | mean_delta | max_abs_delta | min_No | max_No |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| F1 | 108_70in | 12 | 12 | 0.65432795 | 0.61982066 | -0.034507289 | 0.034507289 | 229 | 254 |
| F1 | 108_76in | 2 | 2 | 0.760494 | 0.73367994 | -0.026814062 | 0.026814062 | 252 | 253 |
| F1 | 161_uniform | 23 | 23 | 1 | 1 | 0 | 0 | 268 | 317 |
| F1 | 164_112in | 1 | 1 | 1.014 | 0.8776443 | -0.1363557 | 0.1363557 | 339 | 339 |
| F1 | 164_134in_normal | 20 | 20 | 1.363 | 1.2999932 | -0.063006831 | 0.063006831 | 319 | 381 |
| noF1 | 108_70in | 12 | 12 | 0.65432795 | 0.61982066 | -0.034507289 | 0.034507289 | 229 | 254 |
| noF1 | 108_76in | 2 | 2 | 0.760494 | 0.73367994 | -0.026814062 | 0.026814062 | 252 | 253 |
| noF1 | 161_uniform | 23 | 23 | 1 | 1 | 0 | 0 | 268 | 317 |
| noF1 | 164_112in | 1 | 1 | 1.014 | 0.8776443 | -0.1363557 | 0.1363557 | 339 | 339 |
| noF1 | 164_134in_normal | 20 | 20 | 1.363 | 1.2999932 | -0.063006831 | 0.063006831 | 319 | 381 |

## 8. Replacement rows preview

| input_macro_file | output_macro_file | target_kind | sheet | excel_row | No | Bundle | nearest_master_case_label | Fform_col | Fform_cell | workbook_old_value | original_value_from_A3 | replace_value | value_delta | A3_value_delta | old_matches_A3_original | replace_status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 2 | 229 | 108 | 108_70in | 59 | BG2 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 3 | 230 | 108 | 108_70in | 59 | BG3 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 4 | 231 | 108 | 108_70in | 59 | BG4 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 5 | 232 | 108 | 108_70in | 59 | BG5 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 6 | 242 | 108 | 108_70in | 59 | BG6 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 7 | 243 | 108 | 108_70in | 59 | BG7 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 8 | 244 | 108 | 108_70in | 59 | BG8 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 9 | 245 | 108 | 108_70in | 59 | BG9 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 10 | 246 | 108 | 108_70in | 59 | BG10 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 11 | 247 | 108 | 108_70in | 59 | BG11 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 12 | 248 | 108 | 108_70in | 59 | BG12 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 13 | 252 | 108 | 108_76in | 59 | BG13 | 0.760494 | 0.760494 | 0.73367994 | -0.026814062 | -0.026814062 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 14 | 253 | 108 | 108_76in | 59 | BG14 | 0.760494 | 0.760494 | 0.73367994 | -0.026814062 | -0.026814062 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 15 | 254 | 108 | 108_70in | 59 | BG15 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 16 | 268 | 161 | 161_uniform | 59 | BG16 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 17 | 269 | 161 | 161_uniform | 59 | BG17 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 18 | 270 | 161 | 161_uniform | 59 | BG18 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 19 | 271 | 161 | 161_uniform | 59 | BG19 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 20 | 272 | 161 | 161_uniform | 59 | BG20 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 21 | 273 | 161 | 161_uniform | 59 | BG21 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 22 | 274 | 161 | 161_uniform | 59 | BG22 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 23 | 275 | 161 | 161_uniform | 59 | BG23 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 24 | 276 | 161 | 161_uniform | 59 | BG24 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 25 | 277 | 161 | 161_uniform | 59 | BG25 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 26 | 278 | 161 | 161_uniform | 59 | BG26 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 27 | 281 | 161 | 161_uniform | 59 | BG27 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 28 | 282 | 161 | 161_uniform | 59 | BG28 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 29 | 290 | 161 | 161_uniform | 59 | BG29 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 30 | 291 | 161 | 161_uniform | 59 | BG30 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 31 | 295 | 161 | 161_uniform | 59 | BG31 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 32 | 297 | 161 | 161_uniform | 59 | BG32 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 33 | 298 | 161 | 161_uniform | 59 | BG33 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 34 | 301 | 161 | 161_uniform | 59 | BG34 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 35 | 302 | 161 | 161_uniform | 59 | BG35 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 36 | 305 | 161 | 161_uniform | 59 | BG36 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 37 | 310 | 161 | 161_uniform | 59 | BG37 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 38 | 317 | 161 | 161_uniform | 59 | BG38 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 39 | 319 | 164 | 164_134in_normal | 59 | BG39 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 40 | 320 | 164 | 164_134in_normal | 59 | BG40 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 41 | 322 | 164 | 164_134in_normal | 59 | BG41 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 42 | 323 | 164 | 164_134in_normal | 59 | BG42 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 43 | 325 | 164 | 164_134in_normal | 59 | BG43 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 44 | 326 | 164 | 164_134in_normal | 59 | BG44 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 45 | 327 | 164 | 164_134in_normal | 59 | BG45 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 46 | 329 | 164 | 164_134in_normal | 59 | BG46 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 47 | 330 | 164 | 164_134in_normal | 59 | BG47 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 48 | 331 | 164 | 164_134in_normal | 59 | BG48 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 49 | 334 | 164 | 164_134in_normal | 59 | BG49 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 50 | 335 | 164 | 164_134in_normal | 59 | BG50 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 51 | 336 | 164 | 164_134in_normal | 59 | BG51 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 52 | 338 | 164 | 164_134in_normal | 59 | BG52 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 53 | 339 | 164 | 164_112in | 59 | BG53 | 1.014 | 1.014 | 0.8776443 | -0.1363557 | -0.1363557 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 54 | 340 | 164 | 164_134in_normal | 59 | BG54 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 55 | 341 | 164 | 164_134in_normal | 59 | BG55 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 56 | 360 | 164 | 164_134in_normal | 59 | BG56 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 57 | 371 | 164 | 164_134in_normal | 59 | BG57 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 58 | 380 | 164 | 164_134in_normal | 59 | BG58 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | noF1 | tm | 59 | 381 | 164 | 164_134in_normal | 59 | BG59 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 2 | 229 | 108 | 108_70in | 59 | BG2 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 3 | 230 | 108 | 108_70in | 59 | BG3 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 4 | 231 | 108 | 108_70in | 59 | BG4 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 5 | 232 | 108 | 108_70in | 59 | BG5 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 6 | 242 | 108 | 108_70in | 59 | BG6 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 7 | 243 | 108 | 108_70in | 59 | BG7 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 8 | 244 | 108 | 108_70in | 59 | BG8 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 9 | 245 | 108 | 108_70in | 59 | BG9 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 10 | 246 | 108 | 108_70in | 59 | BG10 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 11 | 247 | 108 | 108_70in | 59 | BG11 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 12 | 248 | 108 | 108_70in | 59 | BG12 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 13 | 252 | 108 | 108_76in | 59 | BG13 | 0.760494 | 0.760494 | 0.73367994 | -0.026814062 | -0.026814062 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 14 | 253 | 108 | 108_76in | 59 | BG14 | 0.760494 | 0.760494 | 0.73367994 | -0.026814062 | -0.026814062 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 15 | 254 | 108 | 108_70in | 59 | BG15 | 0.65432795 | 0.65432795 | 0.61982066 | -0.034507289 | -0.034507289 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 16 | 268 | 161 | 161_uniform | 59 | BG16 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 17 | 269 | 161 | 161_uniform | 59 | BG17 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 18 | 270 | 161 | 161_uniform | 59 | BG18 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 19 | 271 | 161 | 161_uniform | 59 | BG19 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 20 | 272 | 161 | 161_uniform | 59 | BG20 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 21 | 273 | 161 | 161_uniform | 59 | BG21 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 22 | 274 | 161 | 161_uniform | 59 | BG22 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 23 | 275 | 161 | 161_uniform | 59 | BG23 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 24 | 276 | 161 | 161_uniform | 59 | BG24 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 25 | 277 | 161 | 161_uniform | 59 | BG25 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 26 | 278 | 161 | 161_uniform | 59 | BG26 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 27 | 281 | 161 | 161_uniform | 59 | BG27 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 28 | 282 | 161 | 161_uniform | 59 | BG28 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 29 | 290 | 161 | 161_uniform | 59 | BG29 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 30 | 291 | 161 | 161_uniform | 59 | BG30 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 31 | 295 | 161 | 161_uniform | 59 | BG31 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 32 | 297 | 161 | 161_uniform | 59 | BG32 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 33 | 298 | 161 | 161_uniform | 59 | BG33 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 34 | 301 | 161 | 161_uniform | 59 | BG34 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 35 | 302 | 161 | 161_uniform | 59 | BG35 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 36 | 305 | 161 | 161_uniform | 59 | BG36 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 37 | 310 | 161 | 161_uniform | 59 | BG37 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 38 | 317 | 161 | 161_uniform | 59 | BG38 | 1 | 1 | 1 | 0 | 0 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 39 | 319 | 164 | 164_134in_normal | 59 | BG39 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 40 | 320 | 164 | 164_134in_normal | 59 | BG40 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 41 | 322 | 164 | 164_134in_normal | 59 | BG41 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 42 | 323 | 164 | 164_134in_normal | 59 | BG42 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 43 | 325 | 164 | 164_134in_normal | 59 | BG43 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 44 | 326 | 164 | 164_134in_normal | 59 | BG44 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 45 | 327 | 164 | 164_134in_normal | 59 | BG45 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 46 | 329 | 164 | 164_134in_normal | 59 | BG46 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 47 | 330 | 164 | 164_134in_normal | 59 | BG47 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 48 | 331 | 164 | 164_134in_normal | 59 | BG48 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 49 | 334 | 164 | 164_134in_normal | 59 | BG49 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 50 | 335 | 164 | 164_134in_normal | 59 | BG50 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 51 | 336 | 164 | 164_134in_normal | 59 | BG51 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 52 | 338 | 164 | 164_134in_normal | 59 | BG52 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 53 | 339 | 164 | 164_112in | 59 | BG53 | 1.014 | 1.014 | 0.8776443 | -0.1363557 | -0.1363557 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 54 | 340 | 164 | 164_134in_normal | 59 | BG54 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 55 | 341 | 164 | 164_134in_normal | 59 | BG55 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 56 | 360 | 164 | 164_134in_normal | 59 | BG56 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 57 | 371 | 164 | 164_134in_normal | 59 | BG57 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 58 | 380 | 164 | 164_134in_normal | 59 | BG58 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | W:\celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | F1 | tm | 59 | 381 | 164 | 164_134in_normal | 59 | BG59 | 1.363 | 1.363 | 1.2999932 | -0.063006831 | -0.063006831 | true | written_to_copy |

## 9. Next steps

| step | action | detail |
| --- | --- | --- |
| 1 | Open copied macro workbooks | Open the output xlsm files listed in BT09A_workbook_summary. |
| 2 | Enable macros if required | Enable content only for the copied files, not the originals. |
| 3 | Confirm F_form column | tm sheet BG column should contain Fform_linear values. |
| 4 | Run recalculation macro | Run the same macro workflow used for the legacy calculation. |
| 5 | Save recalculated output | Save with a name including FformLinear_v1_recalc. |
| 6 | Upload outputs | Upload recalculated xlsm/xlsx and any run_report/log. |
| 7 | BT10 diagnosis | Compare legacy vs FformLinear PM/q values. |

## 10. 判断メモ

```text
- このBT09-Aでは、コピー版マクロブックのtmシートBG列だけをFform_linearに差し替えた。
- 元マクロブックは変更していない。
- まだマクロ再計算はしていない。
- 次にコピー版を開き、必要なマクロ再計算を実行する。
- 再計算後、BT10でP/M影響を診断する。
```
