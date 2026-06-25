# BT15 F_form canonical decision package

作成日時: 20260617

## 1. 目的

BT15では、BT13-C、BT14-A、BT14-B2の結果を統合し、F_form正本化後の全体判断を整理する。
これは補正式作成ではなく、次フェーズへ進む前の判断ゲートである。

## 2. 入力

- current input: `H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx`
- BT13-C report: `run_report_BT13C_resid_diag_v2_20260617_091836.md`
- BT14-A report: `run_report_BT14A_Fform_position_shape_diag_20260617_093233.md`
- BT14-B2 report: `run_report_BT14B2_Fform_consistency_check_20260617_095120.md`
- previous BT14-B report: `run_report_BT14B_Fform_reintegration_audit_closure_20260617_094603.md`

## 3. 出力

- output Excel: `BT15_Fform_decision_package_20260617_100701.xlsx`

## 4. QC

| item | status | value | reading |
| --- | --- | --- | --- |
| current_input_exists | OK | H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx | BT13-B正本入力。 |
| BT13C_report_exists | OK | run_report_BT13C_resid_diag_v2_20260617_091836.md | 正本入力での残差診断。 |
| BT14A_report_exists | OK | run_report_BT14A_Fform_position_shape_diag_20260617_093233.md | F_form挙動診断。 |
| BT14B2_report_exists | OK | run_report_BT14B2_Fform_consistency_check_20260617_095120.md | F_form実装照合。 |
| current_rows | OK | 116 | noF1 58 + F1 58 が期待値。 |
| bundle_summary_rows | OK | 3 | 108/161/164。 |
| case_summary_rows | OK | 5 | 108_70/108_76/161/164_112/164_134。 |
| BT15_formula_policy | OK | no_new_formula | BT15でも補正式は作らない。 |
| BT15_F1_policy | OK | keep_F1_Tsub | F1(Tsub)を維持する。 |
| BT15_Fform_policy | OK | linear_v1 | F_formはlinear_v1を正本とする。 |

## 5. 採用ファイル

| role | file | status | note |
| --- | --- | --- | --- |
| current_bundle_input | H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx | adopt | FformLinear_v1再計算済みtmCompatible正本入力 |
| BT13-C report | run_report_BT13C_resid_diag_v2_20260617_091836.md | adopt | 正本入力での残差診断 |
| BT14-A report | run_report_BT14A_Fform_position_shape_diag_20260617_093233.md | adopt | F_form挙動診断 |
| BT14-B2 report | run_report_BT14B2_Fform_consistency_check_20260617_095120.md | adopt | F_form実装照合完了 |
| BT14-B report | run_report_BT14B_Fform_reintegration_audit_closure_20260617_094603.md | reference_unfinished | current input未読のためBT14-B2で修正 |

## 6. 判断サマリ

| item | decision | reason |
| --- | --- | --- |
| F_form definition | adopt linear_v1 | BT08-A1dで線形補間・線形積分として定義し、BT14-B2でcurrent input一致を確認。 |
| current bundle input | adopt BT13-B recalc tmCompatible v2 | F_form/q_calc/PMがFformLinear_v1再計算後で整合。 |
| legacy F_form | trace only | 履歴・比較用。今後の解析入力には使わない。 |
| BT13-C residual finding | adopt as diagnostic | 108は過大側、161/164は過小側に残る。 |
| F1(Tsub) | keep | BT05でx_eqへの置換根拠が弱く、BT13-C後も置換しない。 |
| F(x_eq) replacement | not adopt | x_eqはTsubに対する追加説明力が小さい。 |
| F_form formula | do not create | F_formは原因ではなく、非一様加熱換算・DNB位置・ケース構造と交絡。 |
| DNB/L/DH formula | do not create | DNB位置、L/DHは診断軸であり、補正式にはしない。 |
| BT14 | close | F_form定義・実装・current input反映の監査が完了。 |

## 7. 根拠サマリ

| source | finding | reading |
| --- | --- | --- |
| BT13-C | PM_F1: 108=1.123, 161=0.909, 164=0.940 | FformLinear_v1再計算後、108は過大側、161/164は過小側に残る。 |
| BT13-C | Tsub/x_eqではPM_F1残差をほとんど説明しない | F1後残差はTsub/x_eq側の問題として整理しにくい。 |
| BT13-C | F_form・z_DNB/DH・L/DHとPM_F1に対応あり | ただし強い交絡があり原因断定不可。 |
| BT14-A | F_form vs z_DNB/L R2が低い | F_formはDNB相対位置だけでは決まらない。 |
| BT14-A | 108_76inと164_134inはz_DNB/Lが近いがF_formが大きく異なる | 軸方向出力分布形状・L/DH・ケース構造を含む。 |
| BT14-B2 | current_Fform_vs_linear_v1 OK | BT13-B正本入力のF_formはBT08-A1d linear_v1と一致。 |
| BT05 | x_eq after Tsubの追加説明力は小さい | F1(Tsub)をF(x_eq)へ置換する根拠は弱い。 |
| 単管T&M/BMI | L/D単独補正式は弱い | L/Dは履歴代理として保留するが補正式にはしない。 |

## 8. F_form linear_v1正本値

| definition_version | case_label | Bundle | z_DNB_ratio | f_DNB_linear | Blue_area_linear | Orange_area_linear | Fform_linear_v1 | definition_note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| linear_v1 | 108_70in | 108 | 0.729167 | 1.5825311 | 0.71522932 | 1.1539295 | 0.61982066 | BT08-A1d正本：linear interpolation and linear integral |
| linear_v1 | 108_76in | 108 | 0.791667 | 1.3919731 | 0.80849999 | 1.1019791 | 0.73367994 | BT08-A1d正本：linear interpolation and linear integral |
| linear_v1 | 161_uniform | 161 | 0.997024 | 1 | 0.997024 | 0.997024 | 1 | BT08-A1d正本：linear interpolation and linear integral |
| linear_v1 | 164_112in | 164 | 0.666667 | 1.2720999 | 0.74430116 | 0.84806699 | 0.8776443 | BT08-A1d正本：linear interpolation and linear integral |
| linear_v1 | 164_134in_normal | 164 | 0.797619 | 0.8520446 | 0.88348441 | 0.67960696 | 1.2999932 | BT08-A1d正本：linear interpolation and linear integral |

## 9. Bundle summary

| Bundle | N_total | N_noF1 | N_F1 | PM_noF1_mean | PM_F1_mean | err_F1_mean | F_form_mean | Tsub_mean | x_eq_mean | z_DNB_L_mean | z_DNB_DH_mean | L_DH_mean |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | 28 | 14 | 14 | 0.65304894 | 1.1232232 | 0.1232232 | 0.63608627 | 46.083809 | -0.013990909 | 0.73821634 | 139.65871 | 189.18399 |
| 161 | 46 | 23 | 23 | 0.62098048 | 0.90884087 | -0.091159126 | 1 | 63.843926 | -0.082322824 | 0.99707054 | 361.35516 | 362.41684 |
| 164 | 42 | 21 | 21 | 0.59786191 | 0.93956052 | -0.060439484 | 1.2798813 | 54.954868 | -0.15527776 | 0.79142031 | 286.82405 | 362.41684 |

## 10. Case summary

| case_label | N_total | N_noF1 | N_F1 | F_form_mean | PM_noF1_mean | PM_F1_mean | Tsub_mean | x_eq_mean | z_DNB_L_mean | z_DNB_DH_mean | L_DH_mean |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108_70in | 24 | 12 | 12 | 0.61982066 | 0.65672421 | 1.1166142 | 47.1332 | -0.011302126 | 0.7292863 | 137.96929 | 189.18399 |
| 108_76in | 4 | 2 | 2 | 0.73367994 | 0.63099733 | 1.1628772 | 39.787462 | -0.030123609 | 0.79179655 | 149.79523 | 189.18399 |
| 161_uniform | 46 | 23 | 23 | 1 | 0.62098048 | 0.90884087 | 63.843926 | -0.082322824 | 0.99707054 | 361.35516 | 362.41684 |
| 164_112in | 2 | 1 | 1 | 0.8776443 | 0.33017459 | 0.79743867 | 19.778147 | 0.095434412 | 0.66669791 | 241.62255 | 362.41684 |
| 164_134in_normal | 40 | 20 | 20 | 1.2999932 | 0.61124627 | 0.94666661 | 56.713704 | -0.16781337 | 0.79765643 | 289.08413 | 362.41684 |

## 11. 不採用・旧扱い

| item | status | reason |
| --- | --- | --- |
| BT12-A full版 | reference_only | F_form列置換のQC用。q_calc/PMはlegacyのまま。 |
| BT12-B minimal版 | not_adopt | 列を削りすぎた。 |
| BT12-C F_form列だけ置換版 | not_adopt | tm互換だがF_formだけlinear、PM/q_calcがlegacy。 |
| BT13 初回残差診断 | not_adopt_as_numeric_diagnostic | 不整合入力を読んでいた。 |
| legacy F_form | trace_only | 旧定義であり、今後の解析入力に使わない。 |
| F2/F1F2 | exclude | 今回の比較対象外。 |

## 12. まだ言ってはいけないこと

| claim | reason |
| --- | --- |
| F_formがPM_F1残差の原因である | F_form、DNB位置、L/DH、ケース構造が交絡。 |
| DNB位置が原因である | z_DNB/DHとL/DHが強く交絡。 |
| L/DHが原因である | L/DHは便利な診断軸だが複合代理。 |
| F_form補正式を作る | 補正式化する根拠はない。 |
| DNB位置補正式を作る | 補正式化する根拠はない。 |
| L/DH補正式を作る | 単管側でもL/D単独補正式は弱い。 |
| F1(Tsub)をF(x_eq)へ置換する | x_eq追加説明力が小さい。 |
| BT14だけでF_formが最終物理説明変数である | F_formは換算係数であり原因とは限らない。 |

## 13. リスク・保留事項

| risk | handling |
| --- | --- |
| F_form原因説への飛躍 | 原因とは言わず、診断項として扱う。 |
| L/DH補正式への飛躍 | L/DHは複合代理として扱う。 |
| x_eq置換への飛躍 | F1(Tsub)維持を明記する。 |
| BT13初回結果の混入 | BT13は不整合入力として不採用にする。 |
| legacy F_formの再利用 | legacyは履歴・比較用に限定する。 |
| 3ケースでの一般化 | 追加ケースまたは外部データ確認まで一般化しない。 |

## 14. 次アクション

| task | priority | purpose | note |
| --- | --- | --- | --- |
| BT15 log append | now | BT15の判断をworking_logへ追記する。 | 一タスク一run_reportの運用。 |
| BT16 or presentation package | next_candidate | F_form正本化後の判断を内部説明・発表用に整理する。 | 補正式作成ではなく説明整理。 |
| ST-BT05 | deferred | 単管側でHsub/P/Tsub後のx_eq独立効果を確認する。 | 保留課題。 |
| Source01原本確認 | deferred | Table9/10/11/12の装置・系列・表注が数値診断と矛盾しないか確認する。 | 文献確認フェーズ。 |
| Bundle additional cases | deferred | 108/161/164以外にも同じ傾向があるか確認する。 | データ拡張時。 |

## 15. 判断メモ

```text
BT15で固定する判断：

1. F_formはBT08-A1d linear_v1を正本とする。
2. BT13-B正本入力のF_formはlinear_v1と一致している。
3. legacy F_formは履歴・比較用であり、今後の解析入力には使わない。
4. FformLinear_v1再計算後、BT13-Cでは108が過大側、161/164が過小側に残る。
5. F1後残差はTsub/x_eq側ではなく、F_form・DNB位置・L/DH・ケース構造側に残る。
6. ただし、F_form・DNB位置・L/DHは強く交絡する。
7. F_formが原因であるとは断定しない。
8. F_form補正式、DNB位置補正式、L/DH補正式は作らない。
9. F1(Tsub)は維持し、F(x_eq)への置換にも進まない。
10. 次は、全体判断を発表・内部説明に落とすか、ST-BT05等の保留課題へ移る。
```

## 16. BT15の結論

```text
BT15により、F_form正本化後の判断を整理した。

今後のバンドル解析入力は、BT13-Bで作成した
H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible を正本とする。

F_formはlinear_v1で固定する。
F1(Tsub)は維持する。
追加補正式は作らない。

108/161/164の残差は、補正式化ではなく、
非一様加熱換算、DNB位置、L/DH、ケース構造、適用範囲の診断課題として残す。
```
