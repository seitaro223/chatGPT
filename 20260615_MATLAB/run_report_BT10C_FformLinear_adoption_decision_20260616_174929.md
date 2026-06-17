# BT10-C FformLinear_v1 adoption decision package

作成日時: 20260616

## 1. 目的

BT10-Bの結果を受けて、legacy F_formとFformLinear_v1を比較し、FformLinear_v1を正本候補にするか、legacy併記感度として扱うかを判断する。

## 2. 入力

- legacy current_bundle: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`
- BT10B workbook: `BT10B_FformLinear_residual_diagnostic_20260616_174402.xlsx`

## 3. 前提

```text
- F1(Tsub)は維持する。
- F1(Tsub)をF(x_eq)へ置換しない。
- F_formはF1ではない。
- FformLinear_v1は定義の一貫化であり、残差補正式ではない。
- 108悪化と164改善を同時に見る。
- R2や誤差指標が良くても、ここで新補正式は作らない。
```

## 4. Bundle summary

| Bundle | N | No_min | No_max | PM_F1_legacy_mean | PM_F1_linear_mean | delta_PM_F1_linear_minus_legacy_mean | abs_err_F1_legacy_mean | abs_err_F1_linear_mean | delta_abs_err_linear_minus_legacy_mean | PM_noF1_legacy_mean | PM_noF1_linear_mean | Fform_legacy_mean | Fform_linear_mean | delta_Fform_mean | Tsub_mean | x_eq_mean | z_DNB_DH_mean | z_DNB_L_mean | L_DH_mean |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | 14 | 229 | 254 | 1.0667888 | 1.1232232 | 0.056434437 | 0.071840788 | 0.1232232 | 0.051382414 | 0.62183051 | 0.65304894 | 0.66949453 | 0.63608627 | -0.033408257 | 46.083809 | -0.013990909 | 139.65871 | 0.73821634 | 189.18399 |
| 161 | 23 | 268 | 317 | 0.90884087 | 0.90884087 | 0 | 0.097589743 | 0.097589743 | 0 | 0.62098048 | 0.62098048 | 1 | 1 | 0 | 63.843926 | -0.082322824 | 361.35516 | 0.99707054 | 362.41684 |
| 164 | 21 | 319 | 381 | 0.89201812 | 0.93956052 | 0.047542392 | 0.10960828 | 0.086036296 | -0.023571989 | 0.57092312 | 0.59786191 | 1.346381 | 1.2798813 | -0.066499634 | 54.954868 | -0.15527776 | 286.82405 | 0.79142031 | 362.41684 |

## 5. Case summary

| case_label | N | No_min | No_max | PM_F1_legacy_mean | PM_F1_linear_mean | delta_PM_F1_linear_minus_legacy_mean | abs_err_F1_legacy_mean | abs_err_F1_linear_mean | delta_abs_err_linear_minus_legacy_mean | PM_noF1_legacy_mean | PM_noF1_linear_mean | Fform_legacy_mean | Fform_linear_mean | delta_Fform_mean | Tsub_mean | x_eq_mean | z_DNB_DH_mean | z_DNB_L_mean | L_DH_mean |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108_70in | 12 | 229 | 254 | 1.0572283 | 1.1166142 | 0.059385932 | 0.063122304 | 0.11661421 | 0.053491906 | 0.62336116 | 0.65672421 | 0.65432795 | 0.61982066 | -0.034507289 | 47.1332 | -0.011302126 | 137.96929 | 0.7292863 | 189.18399 |
| 108_76in | 2 | 252 | 253 | 1.1241517 | 1.1628772 | 0.038725466 | 0.12415169 | 0.16287716 | 0.038725466 | 0.61264663 | 0.63099733 | 0.760494 | 0.73367994 | -0.026814062 | 39.787462 | -0.030123609 | 149.79523 | 0.79179655 | 189.18399 |
| 161_uniform | 23 | 268 | 317 | 0.90884087 | 0.90884087 | 0 | 0.097589743 | 0.097589743 | 0 | 0.62098048 | 0.62098048 | 1 | 1 | 0 | 63.843926 | -0.082322824 | 361.35516 | 0.99707054 | 362.41684 |
| 164_112in | 1 | 339 | 339 | 0.68909447 | 0.79743867 | 0.1083442 | 0.31090553 | 0.20256133 | -0.1083442 | 0.28284149 | 0.33017459 | 1.014 | 0.8776443 | -0.1363557 | 19.778147 | 0.095434412 | 241.62255 | 0.66669791 | 362.41684 |
| 164_134in_normal | 20 | 319 | 381 | 0.90216431 | 0.94666661 | 0.044502302 | 0.099543423 | 0.080210044 | -0.019333378 | 0.5853272 | 0.61124627 | 1.363 | 1.2999932 | -0.063006831 | 56.713704 | -0.16781337 | 289.08413 | 0.79765643 | 362.41684 |

## 6. Metric summary

| metric | legacy | linear_v1 | delta_linear_minus_legacy | direction | note |
| --- | --- | --- | --- | --- | --- |
| row_weighted_all_MAE_F1 | 0.095726019 | 0.099593985 | 0.0038679661 | worse_if_smaller | row重みMAE |
| row_weighted_all_RMSE_F1 | 0.1281786 | 0.12696007 | -0.001218531 | improved_if_smaller | row重みRMSE |
| row_weighted_all_bias_F1 | -0.059124769 | -0.028289038 | 0.03083573 | worse_if_smaller | row重みbias |
| row_weighted_bundle_108_MAE_F1 | 0.071840788 | 0.1232232 | 0.051382414 | worse_if_smaller | row重みMAE |
| row_weighted_bundle_108_RMSE_F1 | 0.087147362 | 0.13555862 | 0.048411259 | worse_if_smaller | row重みRMSE |
| row_weighted_bundle_108_bias_F1 | 0.066788766 | 0.1232232 | 0.056434437 | worse_if_smaller | row重みbias |
| row_weighted_bundle_161_MAE_F1 | 0.097589743 | 0.097589743 | 0 | same | row重みMAE |
| row_weighted_bundle_161_RMSE_F1 | 0.13024577 | 0.13024577 | 0 | same | row重みRMSE |
| row_weighted_bundle_161_bias_F1 | -0.091159126 | -0.091159126 | 0 | same | row重みbias |
| row_weighted_bundle_164_MAE_F1 | 0.10960828 | 0.086036296 | -0.023571989 | improved_if_smaller | row重みMAE |
| row_weighted_bundle_164_RMSE_F1 | 0.14742703 | 0.11699751 | -0.03042952 | improved_if_smaller | row重みRMSE |
| row_weighted_bundle_164_bias_F1 | -0.10798188 | -0.060439484 | 0.047542392 | worse_if_smaller | row重みbias |
| bundle_mean_MAE_F1 | 0.088643256 | 0.091607271 | 0.0029640149 | worse_if_smaller | bundle平均を同じ重みで見たMAE |
| bundle_mean_RMSE_F1 | 0.090241918 | 0.095126013 | 0.0048840956 | worse_if_smaller | bundle平均を同じ重みで見たRMSE |
| bundle_mean_bias_F1 | -0.044117412 | -0.0094584691 | 0.034658943 | worse_if_smaller | bundle平均を同じ重みで見たbias |

## 7. Decision flags

| item | status | value | reading |
| --- | --- | --- | --- |
| row_join | OK | N=58 | legacyとlinear_v1をNoで結合。期待値は58。 |
| 108_effect | caution | 1.06679 -> 1.12322 | 108はFformLinear_v1で過大側へ悪化。 |
| 161_effect | neutral | 0.908841 -> 0.908841 | 161は一様加熱で変化しない。 |
| 164_effect | improve | 0.892018 -> 0.939561 | 164はFformLinear_v1で改善。 |
| definition_status | adopt_candidate | linear_v1 | FformLinear_v1はlegacyより定義が一貫している。 |
| performance_status | mixed | 108 worsens, 164 improves | 予測性能の改善は一様ではない。 |
| recommended_handling | adopt_with_caution | canonical_candidate_plus_legacy_sensitivity | 正本候補にする場合も、legacy比較を併記する。 |
| formula_status | do_not_formula | no new correction | FformLinear_v1を残差補正式として使わない。 |
| F1_status | keep | F1(Tsub) | F1(Tsub)は維持。F(x_eq)へ置換しない。 |
| next | next | BT11 | BT10-C結果をログへ固定し、FformLinear_v1の扱いを決める。 |

## 8. Adoption options

| option | status | meaning | risk | recommendation |
| --- | --- | --- | --- | --- |
| Option 1: adopt linear_v1 as canonical | candidate | F_formの定義はlinear_v1へ統一し、legacyは履歴・感度比較として残す。 | 108の過大化を説明できないまま正本化するリスク。 | 定義の一貫性を重視するなら採用。ただし結果比較は必ず併記。 |
| Option 2: keep legacy as main and linear_v1 as sensitivity | safe_short_term | 従来結果を主にし、linear_v1は感度ケースとして扱う。 | F_form定義の不整合を残すリスク。 | 報告前の保守的運用としては安全。 |
| Option 3: create new residual correction | reject_now | FformLinear後の残差をさらにFform/L_DH/z_DNBで補正する。 | 108/164の局所的都合合わせになりやすい。 | 現時点では採用しない。 |
| Option 4: revert to legacy | reject_as_final | FformLinear作業を戻し、legacyだけで進む。 | 164低め残差の一部がlegacy定義由来だった可能性を無視する。 | 完全撤回はしない。legacyは比較用に保持。 |

## 9. Next steps

| step | action | detail |
| --- | --- | --- |
| 1 | Review BT10-C package | Check bundle_summary, metric_summary, decision_flags, and adoption_options. |
| 2 | Decide handling | Choose canonical_candidate_plus_legacy_sensitivity or legacy_main_linear_sensitivity. |
| 3 | Do not create formula | Do not create Fform/L_DH/z_DNB residual correction from 108/161/164 alone. |
| 4 | Update working log | Append BT10-B/BT10-C interpretation to working log. |
| 5 | Proceed to BT11 | BT11 should fix final wording for FformLinear_v1 and residual interpretation. |
| 6 | Optional | If needed, inspect axial profile/DNB geometry for 108 overprediction, but not as formula fitting. |

## 10. 判断メモ

```text
- FformLinear_v1は、legacyより定義としては一貫している。
- ただし、予測性能としては164を改善する一方、108を過大側に悪化させる。
- したがって、FformLinear_v1を残差補正式として採用するのではなく、定義正規化・感度ケースとして扱うのが安全。
- 最終的に正本化する場合も、legacy比較結果を併記して判断する。
```
