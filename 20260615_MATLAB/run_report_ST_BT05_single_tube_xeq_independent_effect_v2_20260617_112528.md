# ST-BT05 v2 single-tube x_eq independent-effect diagnostic

作成日時: 20260617

## 1. 目的

ST-BT05 v1では、current_single_tube入力だけではHsub_trueとx_eq計算に必要な列が不足し、x_eq独立効果を確認できなかった。
v2では、v10のtarget_rows_T8_12とr8のtm_F1_STをNo_TableNoで結合し、qP_F1側の熱収支からx_eqを計算して、単管側のx_eq独立効果を確認する。

見たい問いは、単管T&M Table9〜12で、Hsub/P/Tsubを入れた後でもx_eqが独立に効くか、である。

## 2. 入力

- v10 file: `TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx`
- v10 sheet: `target_rows_T8_12`
- r8 file: `20260612_計算結果比較r8_result_文献追加用.xlsx`
- r8 sheet: `tm_F1_ST`

## 3. 出力

- output Excel: `ST_BT05_single_tube_xeq_independent_effect_v2_20260617_112528.xlsx`

## 4. QC

| item | status | value | reading |
| --- | --- | --- | --- |
| v10_file_exists | OK | TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx | Hsub true付きTable8-12診断ブック。 |
| r8_file_exists | OK | 20260612_計算結果比較r8_result_文献追加用.xlsx | hlg取得元。 |
| v10_raw_rows | OK | 192 | target_rows_T8_12。 |
| r8_raw_rows | OK | 86 | tm_F1_ST。 |
| join_rows_T8_12 | OK | 86 | No_TableNo結合後。 |
| target_Table9_12_rows | OK | 86 | ST-BT05主対象。 |
| Hsub_missing | OK | 0 | Hsub true欠損。 |
| P_missing | OK | 0 | P欠損。 |
| Tsub_missing | OK | 0 | Tsub欠損。 |
| hlg_missing | OK | 0 | hlg欠損。 |
| x_eq_missing | OK | 0 | qP_F1側x_eq欠損。 |
| model_OK_count | OK | 13/13 | 主要モデル実行数。 |
| qM_policy | OK | diagnostic_only | qMは結果側量。モデルには入れない。 |
| xMes_policy | OK | diagnostic_only | x_Mesは結果側量。モデルには入れない。 |

## 5. 対象データsummary

| TableNo | LD_group | N | PM_F1_mean | Hsub_mean | P_MPa_mean | Tsub_mean | x_eq_mean | LD_mean | xMes_result_side_mean |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 10 | long | 13 | 1.1006738 | 547.68354 | 13.78952 | 101.49096 | 0.0065227069 | 80 | -0.036615385 |
| 10 | short | 16 | 1.0156542 | 426.60294 | 13.78952 | 76.076745 | -0.038525726 | 64.516129 | -0.0451875 |
| 10 | middle | 57 | 0.95104818 | 265.54759 | 13.78952 | 47.542529 | 0.0075749405 | 67.135167 | 0.014070175 |

## 6. 変数相関

| var_y | var_x | N | R | R2 |
| --- | --- | --- | --- | --- |
| PM_F1 | Hsub_true_kJkg | 86 | 0.61526793 | 0.37855462 |
| PM_F1 | P_MPa | 86 | -1.0158851e-16 | 1.0320224e-32 |
| PM_F1 | Tsub | 86 | 0.59830025 | 0.35796319 |
| PM_F1 | x_eq_qP_F1 | 86 | -0.43036479 | 0.18521385 |
| PM_F1 | LD_geom | 86 | 0.44054534 | 0.19408019 |
| x_eq_qP_F1 | Hsub_true_kJkg | 86 | -0.90692841 | 0.82251913 |
| x_eq_qP_F1 | P_MPa | 86 | 4.1318821e-17 | 1.707245e-33 |
| x_eq_qP_F1 | Tsub | 86 | -0.91604553 | 0.83913942 |
| x_eq_qP_F1 | LD_geom | 86 | 0.062815329 | 0.0039457656 |
| Hsub_true_kJkg | Tsub | 86 | 0.99774136 | 0.99548782 |
| Hsub_true_kJkg | P_MPa | 86 | -5.2123947e-17 | 2.7169058e-33 |

## 7. モデルsummary

| model_id | predictors | N | k | R2 | RMSE | status |
| --- | --- | --- | --- | --- | --- | --- |
| M01_Hsub_linear | Hsub | 86 | 2 | 0.37855462 | 0.080141723 | OK |
| M02_Hsub_quadratic | Hsub + Hsub^2 | 86 | 3 | 0.41127862 | 0.078003142 | OK |
| M03_Hsub_cubic | Hsub + Hsub^2 + Hsub^3 | 86 | 4 | 0.4522609 | 0.075239182 | OK |
| M04_Tsub_linear | Tsub | 86 | 2 | 0.35796319 | 0.081458641 | OK |
| M05_xeq_linear | x_eq | 86 | 2 | 0.18521385 | 0.09176541 | OK |
| M06_Hsub_P | Hsub + P | 86 | 3 | 0.37855462 | 0.080141723 | OK |
| M07_Hsub_xeq | Hsub + x_eq | 86 | 3 | 0.47034907 | 0.073986428 | OK |
| M08_Hsub_P_xeq | Hsub + P + x_eq | 86 | 4 | 0.47034907 | 0.073986428 | OK |
| M09_Hsub_P_Tsub | Hsub + P + Tsub | 86 | 4 | 0.43233669 | 0.076595385 | OK |
| M10_Hsub_P_Tsub_xeq | Hsub + P + Tsub + x_eq | 86 | 5 | 0.4853037 | 0.072934451 | OK |
| M11_Tsub_P_xeq | Tsub + P + x_eq | 86 | 4 | 0.44409106 | 0.075798223 | OK |
| M12_Hsub_P_xeq_LD | Hsub + P + x_eq + L/D | 86 | 5 | 0.47420575 | 0.073716569 | OK |
| M13_Hsub_poly2_P_xeq | Hsub + Hsub^2 + P + x_eq | 86 | 5 | 0.47562586 | 0.073616951 | OK |

## 8. x_eq追加説明力

| test | base_predictors | full_predictors | N_base | R2_base | R2_full | delta_R2 | reading |
| --- | --- | --- | --- | --- | --- | --- | --- |
| x_eq after Hsub | Hsub_true_kJkg | Hsub_true_kJkg,x_eq_qP_F1 | 86 | 0.37855462 | 0.47034907 | 0.091794446 | meaningful_increment_check |
| x_eq after Hsub+P | Hsub_true_kJkg,P_MPa | Hsub_true_kJkg,P_MPa,x_eq_qP_F1 | 86 | 0.37855462 | 0.47034907 | 0.091794446 | meaningful_increment_check |
| x_eq after Hsub+P+Tsub | Hsub_true_kJkg,P_MPa,Tsub | Hsub_true_kJkg,P_MPa,Tsub,x_eq_qP_F1 | 86 | 0.43233669 | 0.4853037 | 0.052967011 | meaningful_increment_check |
| x_eq after Tsub | Tsub | Tsub,x_eq_qP_F1 | 86 | 0.35796319 | 0.44409106 | 0.086127871 | meaningful_increment_check |
| x_eq after Tsub+P | Tsub,P_MPa | Tsub,P_MPa,x_eq_qP_F1 | 86 | 0.35796319 | 0.44409106 | 0.086127871 | meaningful_increment_check |
| x_eq after Hsub quadratic+P | Hsub_true_kJkg,Hsub2,P_MPa | Hsub_true_kJkg,Hsub2,P_MPa,x_eq_qP_F1 | 86 | 0.41127862 | 0.47562586 | 0.064347235 | meaningful_increment_check |
| Hsub+P+Tsub after x_eq | x_eq_qP_F1 | x_eq_qP_F1,Hsub_true_kJkg,P_MPa,Tsub | 86 | 0.18521385 | 0.4853037 | 0.30008985 | meaningful_increment_check |

## 9. 残差化後のx_eq説明力

| base_model | base_R2 | residual_vs_xeq_R2 | N | reading |
| --- | --- | --- | --- | --- |
| Hsub_true_kJkg | 0.37855462 | 0.026215913 | 86 | x_eq_weak_after_base |
| Hsub_true_kJkg,P_MPa | 0.37855462 | 0.026215913 | 86 | x_eq_weak_after_base |
| Hsub_true_kJkg,P_MPa,Tsub | 0.43233669 | 0.01398219 | 86 | x_eq_weak_after_base |
| Tsub | 0.35796319 | 0.021579105 | 86 | x_eq_weak_after_base |
| Tsub,P_MPa | 0.35796319 | 0.021579105 | 86 | x_eq_weak_after_base |
| Hsub_true_kJkg,Hsub2,P_MPa | 0.41127862 | 0.01667384 | 86 | x_eq_weak_after_base |

## 10. Table別・L/D群別残差

| model_id | TableNo | LD_group | N | resid_mean | resid_sd | resid_se | resid_ci95_low | resid_ci95_high |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| M01_Hsub_linear | 10 | long | 13 | 0.063313076 | 0.093714754 | 0.025991796 | 0.012369156 | 0.114257 |
| M01_Hsub_linear | 10 | short | 16 | 0.0081556628 | 0.03307136 | 0.0082678399 | -0.0080493034 | 0.024360629 |
| M01_Hsub_linear | 10 | middle | 57 | -0.016729133 | 0.080337355 | 0.010640943 | -0.037585381 | 0.0041271144 |
| M01_Hsub_linear | 10 | long_minus_short | 29 | 0.055157413 |  | 0.027275092 | 0.001698233 | 0.10861659 |
| M02_Hsub_quadratic | 10 | long | 13 | 0.052313996 | 0.087228805 | 0.024192918 | 0.0048958776 | 0.099732115 |
| M02_Hsub_quadratic | 10 | short | 16 | -0.0053127076 | 0.029825979 | 0.0074564947 | -0.019927437 | 0.009302022 |
| M02_Hsub_quadratic | 10 | middle | 57 | -0.010439976 | 0.081981481 | 0.010858712 | -0.031723052 | 0.0108431 |
| M02_Hsub_quadratic | 10 | long_minus_short | 29 | 0.057626704 |  | 0.025315935 | 0.0080074707 | 0.10724594 |
| M03_Hsub_cubic | 10 | long | 13 | 0.058527558 | 0.072142332 | 0.020008683 | 0.019310539 | 0.097744576 |
| M03_Hsub_cubic | 10 | short | 16 | -0.013674671 | 0.024224758 | 0.0060561895 | -0.025544802 | -0.0018045397 |
| M03_Hsub_cubic | 10 | middle | 57 | -0.0095098863 | 0.080501277 | 0.010662655 | -0.030408689 | 0.011388917 |
| M03_Hsub_cubic | 10 | long_minus_short | 29 | 0.072202229 |  | 0.020905139 | 0.031228157 | 0.1131763 |
| M04_Tsub_linear | 10 | long | 13 | 0.066988999 | 0.094976013 | 0.026341607 | 0.01535945 | 0.11861855 |
| M04_Tsub_linear | 10 | short | 16 | 0.012100701 | 0.034051978 | 0.0085129944 | -0.0045847683 | 0.02878617 |
| M04_Tsub_linear | 10 | middle | 57 | -0.018674881 | 0.080673063 | 0.010685408 | -0.039618281 | 0.0022685193 |
| M04_Tsub_linear | 10 | long_minus_short | 29 | 0.054888299 |  | 0.027683051 | 0.00062951861 | 0.10914708 |
| M05_xeq_linear | 10 | long | 13 | 0.11857461 | 0.086089845 | 0.023877027 | 0.071775635 | 0.16537358 |
| M05_xeq_linear | 10 | short | 16 | 0.012527467 | 0.03549336 | 0.00887334 | -0.0048642795 | 0.029919213 |
| M05_xeq_linear | 10 | middle | 57 | -0.030559814 | 0.082140967 | 0.010879837 | -0.051884294 | -0.0092353333 |
| M05_xeq_linear | 10 | long_minus_short | 29 | 0.10604714 |  | 0.025472506 | 0.056121029 | 0.15597325 |
| M06_Hsub_P | 10 | long | 13 | 0.063313076 | 0.093714754 | 0.025991796 | 0.012369156 | 0.114257 |
| M06_Hsub_P | 10 | short | 16 | 0.0081556628 | 0.03307136 | 0.0082678399 | -0.0080493034 | 0.024360629 |
| M06_Hsub_P | 10 | middle | 57 | -0.016729133 | 0.080337355 | 0.010640943 | -0.037585381 | 0.0041271144 |
| M06_Hsub_P | 10 | long_minus_short | 29 | 0.055157413 |  | 0.027275092 | 0.001698233 | 0.10861659 |
| M07_Hsub_xeq | 10 | long | 13 | 0.0025397432 | 0.093539108 | 0.025943081 | -0.048308695 | 0.053388181 |
| M07_Hsub_xeq | 10 | short | 16 | 0.014177399 | 0.031407769 | 0.0078519422 | -0.0012124075 | 0.029567206 |
| M07_Hsub_xeq | 10 | middle | 57 | -0.0045588605 | 0.078659223 | 0.010418669 | -0.024979451 | 0.01586173 |
| M07_Hsub_xeq | 10 | long_minus_short | 29 | -0.011637656 |  | 0.027105284 | -0.064764013 | 0.041488701 |
| M08_Hsub_P_xeq | 10 | long | 13 | 0.0025397432 | 0.093539108 | 0.025943081 | -0.048308695 | 0.053388181 |
| M08_Hsub_P_xeq | 10 | short | 16 | 0.014177399 | 0.031407769 | 0.0078519422 | -0.0012124075 | 0.029567206 |
| M08_Hsub_P_xeq | 10 | middle | 57 | -0.0045588605 | 0.078659223 | 0.010418669 | -0.024979451 | 0.01586173 |
| M08_Hsub_P_xeq | 10 | long_minus_short | 29 | -0.011637656 |  | 0.027105284 | -0.064764013 | 0.041488701 |
| M09_Hsub_P_Tsub | 10 | long | 13 | 0.050979704 | 0.082256836 | 0.022813941 | 0.0062643787 | 0.095695029 |
| M09_Hsub_P_Tsub | 10 | short | 16 | -0.010861185 | 0.027370388 | 0.0068425971 | -0.024272675 | 0.0025503056 |
| M09_Hsub_P_Tsub | 10 | middle | 57 | -0.0085781964 | 0.081531122 | 0.010799061 | -0.029744356 | 0.012587963 |
| M09_Hsub_P_Tsub | 10 | long_minus_short | 29 | 0.061840889 |  | 0.023817999 | 0.015157611 | 0.10852417 |
| M10_Hsub_P_Tsub_xeq | 10 | long | 13 | 0.0059949074 | 0.0863148 | 0.023939418 | -0.040926353 | 0.052916167 |
| M10_Hsub_P_Tsub_xeq | 10 | short | 16 | 0.0022205161 | 0.028850777 | 0.0072126942 | -0.011916365 | 0.016357397 |
| M10_Hsub_P_Tsub_xeq | 10 | middle | 57 | -0.0019905623 | 0.079598427 | 0.010543069 | -0.022654978 | 0.018673853 |
| M10_Hsub_P_Tsub_xeq | 10 | long_minus_short | 29 | 0.0037743913 |  | 0.025002374 | -0.045230262 | 0.052779044 |
| M11_Tsub_P_xeq | 10 | long | 13 | 0.007116338 | 0.097599138 | 0.02706913 | -0.045939158 | 0.060171834 |
| M11_Tsub_P_xeq | 10 | short | 16 | 0.021736831 | 0.033125379 | 0.0082813448 | 0.0055053956 | 0.037968267 |
| M11_Tsub_P_xeq | 10 | middle | 57 | -0.0077245912 | 0.079250515 | 0.010496987 | -0.028298686 | 0.012849504 |
| M11_Tsub_P_xeq | 10 | long_minus_short | 29 | -0.014620493 |  | 0.02830757 | -0.07010333 | 0.040862343 |
| M12_Hsub_P_xeq_LD | 10 | long | 13 | -8.4985629e-05 | 0.091975821 | 0.025509503 | -0.050083611 | 0.04991364 |
| M12_Hsub_P_xeq_LD | 10 | short | 16 | 0.021239153 | 0.031051529 | 0.0077628822 | 0.006023904 | 0.036454402 |
| M12_Hsub_P_xeq_LD | 10 | middle | 57 | -0.0059424849 | 0.078162747 | 0.010352909 | -0.026234186 | 0.014349216 |
| M12_Hsub_P_xeq_LD | 10 | long_minus_short | 29 | -0.021324139 |  | 0.026664529 | -0.073586615 | 0.030938337 |
| M13_Hsub_poly2_P_xeq | 10 | long | 13 | 0.0036660366 | 0.090461799 | 0.025089589 | -0.045509558 | 0.052841631 |
| M13_Hsub_poly2_P_xeq | 10 | short | 16 | 0.0077601818 | 0.030086893 | 0.0075217232 | -0.0069823956 | 0.022502759 |
| M13_Hsub_poly2_P_xeq | 10 | middle | 57 | -0.0030144103 | 0.079354385 | 0.010510745 | -0.023615471 | 0.01758665 |
| M13_Hsub_poly2_P_xeq | 10 | long_minus_short | 29 | -0.0040941452 |  | 0.026192819 | -0.055432071 | 0.047243781 |

## 11. 判断フラグ

| item | status | value | reading |
| --- | --- | --- | --- |
| task_status | CHECK_AFTER_RUN | ST-BT05_v2 | 数値結果を見て採否を判断する。 |
| v1_policy | not_adopt | missing_Hsub_xeq | ST-BT05 v1はx_eq独立効果を計算できなかった。 |
| Fform_policy | closed | linear_v1_fixed | F_formは本タスク対象外。追加監査しない。 |
| LD_policy | deferred | literature_wait | L/D・熱履歴はBecker等の文献待ち。 |
| qM_policy | do_not_use | result_side | qMは補正式入力に使わない。 |
| xMes_policy | do_not_use | result_side | x_Mesは補正式入力に使わない。 |
| x_eq_independent_effect_after_Hsub_P_Tsub | possible | delta_R2=0.052967 | 単管ではx_eqが独立に効く可能性。バンドルとの差として重要。 |
| next_after_STBT05_v2 | summarize_for_user_and_Claude | personal_summary | ST-BT05後に全体を私用まとめ＋Claudeレビュー依頼文へ整理する。 |

## 12. 読み方

```text
このrunは補正式作成ではない。

単管側でx_eqがHsub/P/Tsub後も独立に効くなら、
  単管ではx_eqが効くが、バンドルBT05では効かない、
  という単管・バンドル差として読む。

単管側でもx_eq追加説明力が小さいなら、
  Hsub+P+x_eqが効いたように見えたのは、
  x_eq独立効果ではなくHsub/P/Tsubの代理だった可能性が高い。

どちらでも、バンドル側のF1(Tsub)をすぐ置換する判断にはしない。
```

## 13. 次アクション

```text
1. ST-BT05 v2の結果をworking_logへ追記する。
2. 単管・バンドル比較を私用まとめとして整理する。
3. Claude Codeに全データを渡す前提で、レビュー依頼文を作る。
4. L/D・熱履歴の追加検証はBecker等の文献待ちに回す。
```
