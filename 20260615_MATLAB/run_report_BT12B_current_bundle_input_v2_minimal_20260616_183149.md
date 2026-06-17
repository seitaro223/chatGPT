# BT12-B current_bundle_input v2 minimal FformLinearCanonical

作成日時: 20260616

## 1. 目的

BT12-Aで作成したFformLinearCanonical版v2を、以後のBT解析で読みやすい最小構成へ整理する。
BT12-A版はQC付き作成履歴として保持し、BT12-B版を解析入力候補とする。

## 2. 入力

- input v2 full: `H52Q_current_bundle_input_v2_FformLinearCanonical_20260616_181819.xlsx`

## 3. 出力

- output minimal: `H52Q_current_bundle_input_v2_minimal_FformLinearCanonical_20260616_183149.xlsx`

## 4. 方針

```text
- 解析用6シートだけを残す。
- README/QC/補助シートはworkbookには入れない。
- F_form列はlinear_v1正本値のままにする。
- legacy F_formは監査用列として最低限残す。
- legacyは感度比較ではなくdeprecated / audit only。
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

| sheet | N_rows | N_cols_full | N_cols_minimal | N_cols_dropped | No_min | No_max | Fform_canonical_mean | Fform_legacy_mean | Fform_delta_mean | N_canonical_equals_linear | N_rows_changed_from_legacy |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| tm_108 | 14 | 82 | 25 | 60 | 229 | 254 | 0.63608627 | 0.66949453 | -0.033408257 | 14 | 14 |
| tm_161 | 23 | 82 | 25 | 60 | 268 | 317 | 1 | 1 | 0 | 23 | 0 |
| tm_164 | 21 | 82 | 25 | 60 | 319 | 381 | 1.2798813 | 1.346381 | -0.066499634 | 21 | 21 |
| tm_F1_108 | 14 | 82 | 25 | 60 | 229 | 254 | 0.63608627 | 0.66949453 | -0.033408257 | 14 | 14 |
| tm_F1_161 | 23 | 82 | 25 | 60 | 268 | 317 | 1 | 1 | 0 | 23 | 0 |
| tm_F1_164 | 21 | 82 | 25 | 60 | 319 | 381 | 1.2798813 | 1.346381 | -0.066499634 | 21 | 21 |

## 7. Workbook QC

| item | status | value | reading |
| --- | --- | --- | --- |
| input_full_v2 | info | H52Q_current_bundle_input_v2_FformLinearCanonical_20260616_181819.xlsx | BT12-Aのfull版。 |
| output_minimal_v2 | info | H52Q_current_bundle_input_v2_minimal_FformLinearCanonical_20260616_183149.xlsx | 以後のBT解析入力候補。 |
| target_rows | OK | 116 | 6シート合計116行が期待値。 |
| canonical_equals_linear | OK | 116/116 | F_form列がF_form_linear_v1と一致すること。 |
| sheet_count | OK | 6 | 解析用6シートのみ処理。 |
| missing_required_count | CHECK | 6 | 必須候補列の欠損。実際の必要性は次BTで確認。 |
| legacy_handling | OK | deprecated audit only | legacyは感度比較ではない。 |
| readme_qc_sheets | OK | not included in workbook | 最小構成のためQCはrun_reportにのみ残す。 |

## 8. Missing required columns

| sheet | missing_required | note |
| --- | --- | --- |
| tm_108 | PM | 存在しない場合でも解析可能な列はあるが、次BTで必要なら確認する |
| tm_161 | PM | 存在しない場合でも解析可能な列はあるが、次BTで必要なら確認する |
| tm_164 | PM | 存在しない場合でも解析可能な列はあるが、次BTで必要なら確認する |
| tm_F1_108 | PM | 存在しない場合でも解析可能な列はあるが、次BTで必要なら確認する |
| tm_F1_161 | PM | 存在しない場合でも解析可能な列はあるが、次BTで必要なら確認する |
| tm_F1_164 | PM | 存在しない場合でも解析可能な列はあるが、次BTで必要なら確認する |

## 9. 判断

```text
BT12-Bで、以後のBT解析用の最小構成 current_bundle_input_v2 を作成した。
以後のBT解析では、原則としてこのminimal版を読む。
BT12-Aのfull版は作成履歴・QC確認用として保持する。
```

## 10. 次アクション

```text
BT12-B結果を確認する。
問題なければworking_logへ追記する。
その後、BT13としてminimal v2を入力にして108過大化診断へ進む。
```
