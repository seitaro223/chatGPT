# BT12 current_bundle_input v2 FformLinearCanonical

作成日時: 20260616

## 1. 目的

BT11-AでFformLinear_v1をF_form正本として採用したため、以後のバンドル解析入力をv2へ更新する。
v1は上書きせず、旧定義・監査用へ降格する。

## 2. 入力

- bundle v1: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`
- Fform map: `BT08A3_macro_Fform_replace_package_20260616_145859.xlsx`

## 3. 出力

- bundle v2: `H52Q_current_bundle_input_v2_FformLinearCanonical_20260616_181819.xlsx`

## 4. 方針

```text
F_form = FformLinear_v1
F_form_legacy_deprecated = 旧F_form
Fform_definition_version = linear_v1
Fform_status = canonical
legacy_Fform_status = deprecated_definition_error_audit_only
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

| sheet | N_rows | N_target_rows | N_mapped_ok | N_mapped_duplicate_first | N_no_map_keep_old | No_min | No_max | Fform_old_mean | Fform_new_mean | Fform_delta_mean | Fform_delta_min | Fform_delta_max | N_new_equals_linear | N_old_new_changed | N_old_vs_map_original_large_diff |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| tm_108 | 14 | 14 | 14 | 0 | 0 | 229 | 254 | 0.66949453 | 0.63608627 | -0.033408257 | -0.034507289 | -0.026814062 | 14 | 14 | 0 |
| tm_161 | 23 | 23 | 23 | 0 | 0 | 268 | 317 | 1 | 1 | 0 | 0 | 0 | 23 | 0 | 0 |
| tm_164 | 21 | 21 | 21 | 0 | 0 | 319 | 381 | 1.346381 | 1.2798813 | -0.066499634 | -0.1363557 | -0.063006831 | 21 | 21 | 0 |
| tm_F1_108 | 14 | 14 | 14 | 0 | 0 | 229 | 254 | 0.66949453 | 0.63608627 | -0.033408257 | -0.034507289 | -0.026814062 | 14 | 14 | 0 |
| tm_F1_161 | 23 | 23 | 23 | 0 | 0 | 268 | 317 | 1 | 1 | 0 | 0 | 0 | 23 | 0 | 0 |
| tm_F1_164 | 21 | 21 | 21 | 0 | 0 | 319 | 381 | 1.346381 | 1.2798813 | -0.066499634 | -0.1363557 | -0.063006831 | 21 | 21 | 0 |

## 7. Workbook QC

| item | status | value | reading |
| --- | --- | --- | --- |
| input_bundle_v1 | info | H52Q_current_bundle_input_v1_20260615_180822.xlsx | 旧current_bundle_input。今後は監査用。 |
| input_Fform_map | info | BT08A3_macro_Fform_replace_package_20260616_145859.xlsx | FformLinear_v1差し替え元。 |
| output_bundle_v2 | info | H52Q_current_bundle_input_v2_FformLinearCanonical_20260616_181819.xlsx | 今後のバンドル解析入力。 |
| target_rows | OK | 116 | noF1 58 + F1 58 = 116 が期待値。 |
| mapped_rows | OK | 116/116 | 全対象行がFformLinear_v1へマップされること。 |
| no_map_rows | OK | 0 | マップ不可行は0が期待値。 |
| canonical_equals_linear | OK | 116/116 | F_form列がF_form_linear_v1と一致すること。 |
| old_value_vs_map_original | OK | large_diff=0 | 旧F_formとmap originalの不一致確認。 |
| legacy_status | OK | deprecated_definition_error_audit_only | legacyは感度比較ではなく監査用。 |
| Fform_status | OK | linear_v1 canonical | FformLinear_v1を正本として採用。 |

## 8. 判断

```text
BT12で current_bundle_input_v2_FformLinearCanonical を作成した。
以後のバンドル解析では、v1ではなくv2を読む。
legacy F_formは感度比較ではなく、旧定義ミス・監査用としてのみ保持する。
FformLinear_v1はF_form定義の正本であり、残差補正式ではない。
```

## 9. 次アクション

```text
BT12結果を確認する。
問題なければ、working_logへ追記する。
その後、BT13としてv2正本入力を使い、108過大化の診断を再開する。
```
