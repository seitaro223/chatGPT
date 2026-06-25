# ST-BT05 single-tube x_eq independent-effect diagnostic

作成日時: 20260617

## 1. 目的

単管T&M source01 Table9〜12では、Hsub + P + x_eq によりTable12 long正残差がほぼ消えるという診断結果があった。
ただし、x_eqが本当に独立して効いているのか、Hsub/P/Tsubの代理として効いているだけなのかは未確認だった。
ST-BT05では、単管側について、バンドルBT05相当のx_eq独立効果切り分け診断を行う。

## 2. 入力

- input file: `H52Q_current_single_tube_input_v1_20260615_183839.xlsx`
- input role: `current_single_tube`
- F1 sheet: `ST_F1_T8_14_current`

## 3. 出力

- output Excel: `ST_BT05_single_tube_xeq_independent_effect_20260617_105751.xlsx`

## 4. QC

| item | status | value | reading |
| --- | --- | --- | --- |
| input_file_exists | OK | H52Q_current_single_tube_input_v1_20260615_183839.xlsx | 単管current入力を優先。 |
| input_role | INFO | current_single_tube | current_single_tubeなら正本入口。fallbackなら注意。 |
| F1_sheet | OK | ST_F1_T8_14_current | F1単管シート。 |
| raw_rows | OK | 224 | 読み込み行数。 |
| target_source01_Table9_12_rows | OK | 22 | source01 Table9-12対象行。 |
| PM_F1_missing | OK | 0 | PM_F1欠損。 |
| Hsub_used_missing | CHECK | 22 | Hsub true優先、無ければproxy fallback。 |
| P_MPa_missing | OK | 0 | 圧力欠損。 |
| Tsub_missing | OK | 0 | Tsub欠損。 |
| x_eq_missing | CHECK | 22 | x_eq欠損。existingまたは予測側熱収支から計算。 |
| x_eq_status | INFO | missing_or_insufficient_columns | x_eqの由来。 |
| model_OK_count | CHECK | 1/13 | 主要モデルが実行できたか。 |
| qM_policy | OK | diagnostic_only_not_predictor | qMは結果側量なのでモデルには入れない。 |
| xMes_policy | OK | not_used_as_predictor | x_Mesは結果側量として使わない。 |

## 5. 対象データsummary

| TableNo | LD_group | N | PM_F1_mean | Hsub_mean | P_MPa_mean | Tsub_mean | x_eq_mean | LD_mean | xeq_status_mode |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 9 | unknown | 6 | 1.2408941 |  | 15972855 | 95.242737 |  |  | missing_or_insufficient_columns |
| 10 | unknown | 6 | 1.2587048 |  | 15972855 | 92.018349 |  |  | missing_or_insufficient_columns |
| 11 | unknown | 5 | 1.0487034 |  | 15513205 | 108.94526 |  |  | missing_or_insufficient_columns |
| 12 | unknown | 5 | 1.0781166 |  | 15513205 | 104.1372 |  |  | missing_or_insufficient_columns |

## 6. 変数相関

| var_y | var_x | N | R | R2 |
| --- | --- | --- | --- | --- |
| PM_F1 | Hsub_used | 0 |  |  |
| PM_F1 | P_MPa | 22 | 0.41603022 | 0.17308114 |
| PM_F1 | Tsub | 22 | -0.87766345 | 0.77029314 |
| PM_F1 | x_eq | 0 |  |  |
| PM_F1 | LD | 0 |  |  |
| x_eq | Hsub_used | 0 |  |  |
| x_eq | P_MPa | 0 |  |  |
| x_eq | Tsub | 0 |  |  |
| x_eq | LD | 0 |  |  |
| Hsub_used | Tsub | 0 |  |  |
| Hsub_used | P_MPa | 0 |  |  |

## 7. モデルsummary

| model_id | predictors | N | k | R2 | RMSE | status |
| --- | --- | --- | --- | --- | --- | --- |
| M01_Hsub_linear | Hsub | 0 | 2 |  |  | CHECK_not_enough_rows |
| M02_Hsub_quadratic | Hsub + Hsub^2 | 0 | 3 |  |  | CHECK_not_enough_rows |
| M03_Hsub_cubic | Hsub + Hsub^2 + Hsub^3 | 0 | 4 |  |  | CHECK_not_enough_rows |
| M04_Tsub_linear | Tsub | 22 | 2 | 0.77029314 | 0.085503264 | OK |
| M05_xeq_linear | x_eq | 0 | 2 |  |  | CHECK_not_enough_rows |
| M06_Hsub_P | Hsub + P | 0 | 3 |  |  | CHECK_not_enough_rows |
| M07_Hsub_xeq | Hsub + x_eq | 0 | 3 |  |  | CHECK_not_enough_rows |
| M08_Hsub_P_xeq | Hsub + P + x_eq | 0 | 4 |  |  | CHECK_not_enough_rows |
| M09_Hsub_P_Tsub | Hsub + P + Tsub | 0 | 4 |  |  | CHECK_not_enough_rows |
| M10_Hsub_P_Tsub_xeq | Hsub + P + Tsub + x_eq | 0 | 5 |  |  | CHECK_not_enough_rows |
| M11_Tsub_P_xeq | Tsub + P + x_eq | 0 | 4 |  |  | CHECK_not_enough_rows |
| M12_Hsub_P_xeq_LD | Hsub + P + x_eq + L/D | 0 | 5 |  |  | CHECK_not_enough_rows |
| M13_Hsub_poly2_P_xeq | Hsub + Hsub^2 + P + x_eq | 0 | 5 |  |  | CHECK_not_enough_rows |

## 8. x_eq追加説明力

| test | base_predictors | full_predictors | N_base | R2_base | R2_full | delta_R2 | reading |
| --- | --- | --- | --- | --- | --- | --- | --- |
| x_eq after Hsub | Hsub_used | Hsub_used,x_eq | 0 |  |  |  | not_available |
| x_eq after Hsub+P | Hsub_used,P_MPa | Hsub_used,P_MPa,x_eq | 0 |  |  |  | not_available |
| x_eq after Hsub+P+Tsub | Hsub_used,P_MPa,Tsub | Hsub_used,P_MPa,Tsub,x_eq | 0 |  |  |  | not_available |
| x_eq after Tsub | Tsub | Tsub,x_eq | 22 | 0.77029314 |  |  | not_available |
| x_eq after Tsub+P | Tsub,P_MPa | Tsub,P_MPa,x_eq | 22 | 0.777562 |  |  | not_available |
| x_eq after Hsub quadratic+P | Hsub_used,Hsub2,P_MPa | Hsub_used,Hsub2,P_MPa,x_eq | 0 |  |  |  | not_available |
| Hsub+P+Tsub after x_eq | x_eq | x_eq,Hsub_used,P_MPa,Tsub | 0 |  |  |  | not_available |

## 9. 残差化後のx_eq説明力

| base_model | base_R2 | residual_vs_xeq_R2 | N | reading |
| --- | --- | --- | --- | --- |
| Hsub_used |  |  | 0 | not_available |
| Hsub_used,P_MPa |  |  | 0 | not_available |
| Hsub_used,P_MPa,Tsub |  |  | 0 | not_available |
| Tsub | 0.77029314 |  | 0 | not_available |
| Tsub,P_MPa | 0.777562 |  | 0 | not_available |
| Hsub_used,Hsub2,P_MPa |  |  | 0 | not_available |

## 10. Table別・L/D群別残差

| model_id | TableNo | LD_group | N | resid_mean | resid_sd | resid_se | resid_ci95_low | resid_ci95_high |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| M01_Hsub_linear | 9 | unknown | 0 |  |  |  |  |  |
| M01_Hsub_linear | 10 | unknown | 0 |  |  |  |  |  |
| M01_Hsub_linear | 11 | unknown | 0 |  |  |  |  |  |
| M01_Hsub_linear | 12 | unknown | 0 |  |  |  |  |  |
| M02_Hsub_quadratic | 9 | unknown | 0 |  |  |  |  |  |
| M02_Hsub_quadratic | 10 | unknown | 0 |  |  |  |  |  |
| M02_Hsub_quadratic | 11 | unknown | 0 |  |  |  |  |  |
| M02_Hsub_quadratic | 12 | unknown | 0 |  |  |  |  |  |
| M03_Hsub_cubic | 9 | unknown | 0 |  |  |  |  |  |
| M03_Hsub_cubic | 10 | unknown | 0 |  |  |  |  |  |
| M03_Hsub_cubic | 11 | unknown | 0 |  |  |  |  |  |
| M03_Hsub_cubic | 12 | unknown | 0 |  |  |  |  |  |
| M04_Tsub_linear | 9 | unknown | 6 | 0.054395796 | 0.038147779 | 0.015573766 | 0.023871216 | 0.084920377 |
| M04_Tsub_linear | 10 | unknown | 6 | 0.055978566 | 0.030662194 | 0.012517788 | 0.031443701 | 0.080513431 |
| M04_Tsub_linear | 11 | unknown | 5 | -0.06883204 | 0.076539036 | 0.034229297 | -0.13592146 | -0.0017426175 |
| M04_Tsub_linear | 12 | unknown | 5 | -0.063617194 | 0.10600444 | 0.047406629 | -0.15653419 | 0.029299798 |
| M05_xeq_linear | 9 | unknown | 0 |  |  |  |  |  |
| M05_xeq_linear | 10 | unknown | 0 |  |  |  |  |  |
| M05_xeq_linear | 11 | unknown | 0 |  |  |  |  |  |
| M05_xeq_linear | 12 | unknown | 0 |  |  |  |  |  |
| M06_Hsub_P | 9 | unknown | 0 |  |  |  |  |  |
| M06_Hsub_P | 10 | unknown | 0 |  |  |  |  |  |
| M06_Hsub_P | 11 | unknown | 0 |  |  |  |  |  |
| M06_Hsub_P | 12 | unknown | 0 |  |  |  |  |  |
| M07_Hsub_xeq | 9 | unknown | 0 |  |  |  |  |  |
| M07_Hsub_xeq | 10 | unknown | 0 |  |  |  |  |  |
| M07_Hsub_xeq | 11 | unknown | 0 |  |  |  |  |  |
| M07_Hsub_xeq | 12 | unknown | 0 |  |  |  |  |  |
| M08_Hsub_P_xeq | 9 | unknown | 0 |  |  |  |  |  |
| M08_Hsub_P_xeq | 10 | unknown | 0 |  |  |  |  |  |
| M08_Hsub_P_xeq | 11 | unknown | 0 |  |  |  |  |  |
| M08_Hsub_P_xeq | 12 | unknown | 0 |  |  |  |  |  |
| M09_Hsub_P_Tsub | 9 | unknown | 0 |  |  |  |  |  |
| M09_Hsub_P_Tsub | 10 | unknown | 0 |  |  |  |  |  |
| M09_Hsub_P_Tsub | 11 | unknown | 0 |  |  |  |  |  |
| M09_Hsub_P_Tsub | 12 | unknown | 0 |  |  |  |  |  |
| M10_Hsub_P_Tsub_xeq | 9 | unknown | 0 |  |  |  |  |  |
| M10_Hsub_P_Tsub_xeq | 10 | unknown | 0 |  |  |  |  |  |
| M10_Hsub_P_Tsub_xeq | 11 | unknown | 0 |  |  |  |  |  |
| M10_Hsub_P_Tsub_xeq | 12 | unknown | 0 |  |  |  |  |  |
| M11_Tsub_P_xeq | 9 | unknown | 0 |  |  |  |  |  |
| M11_Tsub_P_xeq | 10 | unknown | 0 |  |  |  |  |  |
| M11_Tsub_P_xeq | 11 | unknown | 0 |  |  |  |  |  |
| M11_Tsub_P_xeq | 12 | unknown | 0 |  |  |  |  |  |
| M12_Hsub_P_xeq_LD | 9 | unknown | 0 |  |  |  |  |  |
| M12_Hsub_P_xeq_LD | 10 | unknown | 0 |  |  |  |  |  |
| M12_Hsub_P_xeq_LD | 11 | unknown | 0 |  |  |  |  |  |
| M12_Hsub_P_xeq_LD | 12 | unknown | 0 |  |  |  |  |  |
| M13_Hsub_poly2_P_xeq | 9 | unknown | 0 |  |  |  |  |  |
| M13_Hsub_poly2_P_xeq | 10 | unknown | 0 |  |  |  |  |  |
| M13_Hsub_poly2_P_xeq | 11 | unknown | 0 |  |  |  |  |  |
| M13_Hsub_poly2_P_xeq | 12 | unknown | 0 |  |  |  |  |  |

## 11. 判断フラグ

| item | status | value | reading |
| --- | --- | --- | --- |
| task_status | CHECK_AFTER_RUN | ST-BT05 | 数値結果を見て採否を判断する。 |
| Fform_policy | fixed_elsewhere | not_in_scope | ST-BT05はF_formを扱わない。 |
| LD_policy | deferred | literature_wait | L/D・熱履歴はBecker等の文献待ち。 |
| qM_policy | do_not_use | result_side | qMは補正式入力に使わない。 |
| xMes_policy | do_not_use | result_side | x_Mesは補正式入力に使わない。 |
| x_eq_independent_effect_after_Hsub_P_Tsub | CHECK | not_available | x_eq追加説明力を計算できていない。 |
| next_after_STBT05 | summarize_for_user_and_Claude | personal_summary | ST-BT05後に全体を私用まとめ＋Claudeレビュー依頼文へ整理する。 |

## 12. 読み方

```text
このrunは、補正式を作るためのものではない。

見たい問いは次の1点である。
  単管側では、Hsub/P/Tsubを入れた後でも、x_eqが独立に効くのか。

もしx_eq追加説明力が小さいなら、
  単管でHsub+P+x_eqが効いたように見えた結果は、
  x_eq独立効果ではなく、Hsub/P/Tsubの代理だった可能性が高い。

もしx_eq追加説明力が大きいなら、
  単管ではx_eqが効くが、バンドルBT05では効かなかった、
  という単管・バンドル差として整理できる。

どちらの結果でも、バンドル側でF1(Tsub)をすぐF(x_eq)へ置換する判断にはしない。
```

## 13. 次アクション

```text
1. ST-BT05の結果をworking_logへ追記する。
2. 単管・バンドル比較を私用まとめとして整理する。
3. Claude Codeに全データを渡す前提で、レビュー依頼文を作る。
4. L/D・熱履歴の追加検証はBecker等の文献待ちに回す。
```
