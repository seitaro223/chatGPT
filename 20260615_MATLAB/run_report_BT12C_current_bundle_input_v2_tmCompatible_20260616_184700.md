# BT12-C current_bundle_input v2 tmCompatible FformLinearCanonical

作成日時: 20260616

## 1. 目的

BT12-B minimal版ではtmシートの列を削りすぎたため、v1のtm列構成を保持したままF_form列のみをFformLinear_v1へ置換するtm互換版を作成する。

## 2. 入力

- bundle v1: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`
- Fform map: `BT08A3_macro_Fform_replace_package_20260616_145859.xlsx`

## 3. 出力

- output v2 tmCompatible: `H52Q_current_bundle_input_v2_FformLinearCanonical_tmCompatible_20260616_184700.xlsx`

## 4. 方針

```text
- tmシートの列数・列名・列順はv1と同じにする。
- tmシートに追加管理列を入れない。
- 変更はF_form列の値だけに限定する。
- README_BT12Cだけを追加し、正本化・legacy扱い・QCはそこへ逃がす。
- BT12-B minimal版は今後の入力には使わない。
- legacy F_formは感度比較ではなくdeprecated / audit only。
```

## 5. 対象シート

```text
tm_108
tm_161
tm_164
tm_F1_108
tm_F1_161
tm_F1_164
```

## 6. Sheet summary

| sheet | N_rows | N_cols_v1 | N_cols_v2 | N_cols_delta | N_mapped_ok | N_mapped_duplicate_first | N_no_map_keep_old | N_column_structure_same | No_min | No_max | Fform_old_mean | Fform_new_mean | Fform_delta_mean | Fform_delta_min | Fform_delta_max | N_rows_changed | N_old_vs_map_original_large_diff |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| tm_108 | 14 | 70 | 70 | 0 | 14 | 0 | 0 | 1 | 229 | 254 | 0.66949453 | 0.63608627 | -0.033408257 | -0.034507289 | -0.026814062 | 14 | 0 |
| tm_161 | 23 | 70 | 70 | 0 | 23 | 0 | 0 | 1 | 268 | 317 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| tm_164 | 21 | 70 | 70 | 0 | 21 | 0 | 0 | 1 | 319 | 381 | 1.346381 | 1.2798813 | -0.066499634 | -0.1363557 | -0.063006831 | 21 | 0 |
| tm_F1_108 | 14 | 70 | 70 | 0 | 14 | 0 | 0 | 1 | 229 | 254 | 0.66949453 | 0.63608627 | -0.033408257 | -0.034507289 | -0.026814062 | 14 | 0 |
| tm_F1_161 | 23 | 70 | 70 | 0 | 23 | 0 | 0 | 1 | 268 | 317 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| tm_F1_164 | 21 | 70 | 70 | 0 | 21 | 0 | 0 | 1 | 319 | 381 | 1.346381 | 1.2798813 | -0.066499634 | -0.1363557 | -0.063006831 | 21 | 0 |

## 7. Workbook QC

| item | status | value | reading |
| --- | --- | --- | --- |
| input_bundle_v1 | info | H52Q_current_bundle_input_v1_20260615_180822.xlsx | 旧F_formを含む監査用入力。 |
| input_Fform_map | info | BT08A3_macro_Fform_replace_package_20260616_145859.xlsx | FformLinear_v1差し替え元。 |
| output_bundle_v2 | info | H52Q_current_bundle_input_v2_FformLinearCanonical_tmCompatible_20260616_184700.xlsx | 今後のバンドル解析入力候補。 |
| target_rows | OK | 116 | noF1 58 + F1 58 = 116 が期待値。 |
| mapped_rows | OK | 116/116 | 全対象行がFformLinear_v1へマップされること。 |
| no_map_rows | OK | 0 | マップ不可行は0が期待値。 |
| tm_column_structure_same | OK | 6/6 | 対象6シートすべてでv1と列構成が同じ。 |
| old_value_vs_map_original | OK | large_diff=0 | v1旧F_formとmap originalの不一致確認。 |
| readme_only_metadata | OK | README_BT12C | 管理情報はtmではなくREADMEへ逃がした。 |
| legacy_status | OK | deprecated audit only | legacyは感度比較ではない。 |
| Fform_status | OK | linear_v1 canonical | FformLinear_v1を正本として採用。 |

## 8. 判断

```text
BT12-B minimal版は列を削りすぎたため、今後の入力としては不採用とする。
BT12-Cでは、v1と同じtm列構成を維持し、F_form列だけをFformLinear_v1へ置換した。
追加管理列はtmに入れず、README_BT12Cとrun_reportへ逃がした。
以後のBT解析では、このtmCompatible版を入力候補とする。
```

## 9. 次アクション

```text
BT12-C結果を確認する。
問題なければworking_logへ追記する。
その後、BT13としてtmCompatible v2を入力にして108過大化診断へ進む。
```
