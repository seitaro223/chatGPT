# BT13-B current_bundle_input v2 from FformLinear_v1 recalculated macros

作成日時: 20260617

## 1. 目的
BT13で見つかった、F_form列とq_calc/PM列の不整合を解消するため、FformLinear_v1再計算済みr125/r126マクロからcurrent_bundle_input_v2を作り直す。

## 2. 入力
- template v1: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`
- noF1 recalc macro: `celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm`
- F1 recalc macro: `celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm`
- noF1 source sheet: `tm`
- F1 source sheet: `tm`

## 3. 出力
- output v2: `H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx`

## 4. 方針
```text
- BT12-A/B/Cのv2は入力として使わない。
- FformLinear_v1再計算済みマクロからtmシートを取り直す。
- template v1と同じ列数・列名・列順を維持する。
- 追加管理列はtmに入れない。
- 補正式は作らない。
```

## 5. QC
| item | status | value | reading |
| --- | --- | --- | --- |
| template_v1 | info | H52Q_current_bundle_input_v1_20260615_180822.xlsx | 列構成テンプレート |
| macro_noF1 | info | celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm | FformLinear_v1再計算済みnoF1 |
| macro_F1 | info | celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm | FformLinear_v1再計算済みF1 |
| output_v2 | info | H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx | 新current_bundle_input候補 |
| target_rows | OK | 116 | 6シート合計116行が期待値 |
| sheet_count | OK | 6 | 対象6シート |
| tm_column_structure_same | OK | 6/6 | template v1と列構成が同じ |
| PM_mean_vs_BT10C_linear | OK | max_abs_delta=3.8469362e-09 | PM平均がBT10-C linear側と一致するか |
| BT13_inconsistency_status | target | resolve_Fform_PM_mismatch | BT13で見つかった不整合を解消する |
| formula_policy | OK | no_new_formula | 補正式は作らない |

## 6. Sheet summary
| sheet | source_kind | N_rows | N_cols_template | N_cols_output | N_cols_delta | column_structure_same | No_min | No_max | PM_mean | F_form_mean | qP_mean | qM_mean |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| tm_108 | noF1 | 14 | 70 | 70 | 0 | true | 229 | 254 | 0.65304894 | 0.63608627 | 1996463.2 | 3036253.5 |
| tm_161 | noF1 | 23 | 70 | 70 | 0 | true | 268 | 317 | 0.62098048 | 1 | 911913.52 | 1413598.3 |
| tm_164 | noF1 | 21 | 70 | 70 | 0 | true | 319 | 381 | 0.59786191 | 1.2798813 | 735041.11 | 1188761.7 |
| tm_F1_108 | F1 | 14 | 70 | 70 | 0 | true | 229 | 254 | 1.1232232 | 0.63608627 | 3408174 | 3036253.5 |
| tm_F1_161 | F1 | 23 | 70 | 70 | 0 | true | 268 | 317 | 0.90884087 | 1 | 1295140 | 1413598.3 |
| tm_F1_164 | F1 | 21 | 70 | 70 | 0 | true | 319 | 381 | 0.93956052 | 1.2798813 | 1124031.1 | 1188761.7 |

## 7. Bundle summary
| Bundle | source_kind | N | PM_mean | PM_sd | F_form_mean | qP_mean | qM_mean | Tsub_mean | x_eq_mean | expected_PM_BT10C_linear | delta_PM_vs_expected |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | noF1 | 14 | 0.65304894 | 0.11853198 | 0.63608627 | 1996463.2 | 3036253.5 | 46.083809 | -0.013990909 | 0.65304894 | -1.7508697e-09 |
| 108 | F1 | 14 | 1.1232232 | 0.058632196 | 0.63608627 | 3408174 | 3036253.5 | 46.083809 | -0.013990909 | 1.1232232 | 2.7706593e-09 |
| 161 | noF1 | 23 | 0.62098048 | 0.16583855 | 1 | 911913.52 | 1413598.3 | 63.843926 | -0.082322824 | 0.62098048 | -1.2712267e-09 |
| 161 | F1 | 23 | 0.90884087 | 0.095117486 | 1 | 1295140 | 1413598.3 | 63.843926 | -0.082322824 | 0.90884087 | 3.7566394e-09 |
| 164 | noF1 | 21 | 0.59786191 | 0.15999242 | 1.2798813 | 735041.11 | 1188761.7 | 54.954868 | -0.15527776 | 0.59786191 | -7.9147411e-10 |
| 164 | F1 | 21 | 0.93956052 | 0.10265116 | 1.2798813 | 1124031.1 | 1188761.7 | 54.954868 | -0.15527776 | 0.93956052 | -3.8469362e-09 |

## 8. 判断メモ
```text
このrun_reportを確認してから判断する。
見るべきポイント：
  1. 6シートすべてがtemplate v1と同じ列構成か。
  2. PM_noF1/PM_F1がBT10-C linear側の値へ更新されているか。
  3. BT13で見つかったF_form列とPM列の不整合が解消したか。
  4. この新v2を今後のバンドル解析入力として採用できるか。
```

## 9. 次アクション
```text
BT13-B結果を確認する。
問題なければworking_logへ追記する。
その後、この新v2でBT13相当の残差診断を再実行する。
```
