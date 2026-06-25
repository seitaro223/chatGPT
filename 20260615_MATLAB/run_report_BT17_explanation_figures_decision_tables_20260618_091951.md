# BT17 explanation figures decision tables

作成日時: 20260618_091951

## 1. 目的

BT16の「F1後残差はF_form・DNB位置・L/DH・ケース構造と対応して残る」という整理を、補正式ではなく説明用図・判断表として固定する。

BT17では新しい補正式を作らない。R2が高い軸を補正式係数として採用しない。

## 2. 入力

- input BT16 Excel: `BT16_Fform_canonical_explanation_package_20260618_090954.xlsx`

## 3. 出力

- output Excel: `BT17_explanation_figures_decision_tables_20260618_091951.xlsx`
- figure: `fig_BT17_PM_F1_by_bundle_20260618_091951.png`
- figure: `fig_BT17_PM_F1_R2_axes_20260618_091951.png`
- figure: `fig_BT17_Fform_vs_zDNB_case_map_20260618_091951.png`
- figure: `fig_BT17_story_ladder_20260618_091951.png`

## 4. 前提

```text
- BT17は説明用図・判断表の整理である。
- F2/F1F2は使わない。
- F1(Tsub)は維持する。
- F1(Tsub)をF(x_eq)へ置換しない。
- F_formはlinear_v1正本として扱う。
- legacy F_formは今後の解析入力には使わない。
- F_form補正式、DNB位置補正式、L/DH補正式は作らない。
- 『原因』ではなく『対応して残る』と表現する。
```

## 5. QC

| item | status | value | reading | 
| --- | --- | --- | --- | 
| input_BT16_exists | OK | BT16_Fform_canonical_explanation_package_20260618_090954.xlsx | BT16の出力Excelが存在するか。 | 
| sheet_exists_QC | OK | QC | BT17で読むBT16シート。 | 
| sheet_exists_bundle_summary | OK | bundle_summary | BT17で読むBT16シート。 | 
| sheet_exists_case_summary | OK | case_summary | BT17で読むBT16シート。 | 
| sheet_exists_contrast_108_vs_161164 | OK | contrast_108_vs_161164 | BT17で読むBT16シート。 | 
| sheet_exists_corr_diagnostic_only | OK | corr_diagnostic_only | BT17で読むBT16シート。 | 
| sheet_exists_decision_summary | OK | decision_summary | BT17で読むBT16シート。 | 
| sheet_exists_can_say | OK | can_say | BT17で読むBT16シート。 | 
| sheet_exists_cannot_say | OK | cannot_say | BT17で読むBT16シート。 | 
| sheet_exists_paired_point_data | OK | paired_point_data | BT17で読むBT16シート。 | 
| bundle_summary_rows | OK | 3 | 108/161/164の3行が期待値。 | 
| case_summary_rows | OK | 5 | 108_70/108_76/161/164_112/164_134の5行が期待値。 | 
| paired_rows | OK | 58 | BT16でペア化された58行を読む。 | 

## 6. 説明ラダー

| step | title | message | evidence_type | do_not_say | 
| --- | --- | --- | --- | --- | 
| 1 | 正本化 | F_formはlinear_v1で正本化し、BT13-B正本入力を用いる。 | BT15/BT16 decision | legacy F_formも同格に扱う | 
| 2 | 観察 | FformLinear_v1再計算後、108は過大側、161/164は過小側に残る。 | bundle PM_F1 summary | 108だけが悪い | 
| 3 | 残差の向き | F1後残差はTsub/x_eqだけでは整理しにくい。 | single predictor R2 | Tsub/x_eqで説明できる | 
| 4 | 対応する軸 | F_form、DNB位置、L/DH、ケース構造と対応して残る。 | diagnostic axes | 対応軸が原因である | 
| 5 | 交絡の注意 | F_form、DNB位置、L/DHは互いに交絡しており、単独原因にはできない。 | cross-confounding | L/DHだけで補正式を作れる | 
| 6 | 安全な表現 | 原因ではなく、対応して残る、と表現する。 | wording guard | 原因である | 
| 7 | 現時点の結論 | 補正式は作らず、説明用の判断表・図として固定する。 | BT17 decision | BT17で係数を決める | 

## 7. 診断軸テーブル

| axis | axis_label | category | R2_PM_F1 | safe_reading | forbidden_reading | 
| --- | --- | --- | --- | --- | --- | 
| L_DH_F1 | L/DH | 加熱長・ケース構造 | 0.47681733 | L/DHは便利な診断軸だが複合代理である。 | L/DH補正式を作れる。 | 
| z_DNB_DH_F1 | z_DNB/DH | DNBまでの履歴長 | 0.44351822 | DNB位置までの履歴長と対応する。 | DNB位置が原因である。 | 
| F_form_F1 | F_form | 非一様加熱換算 | 0.24322033 | PM_F1と対応するが、原因とは言わない。 | F_formが残差原因である。 | 
| z_DNB_L_F1 | z_DNB/L | 相対DNB位置 | 0.22095238 | 相対DNB位置とも対応する。 | z_DNB/Lだけで説明できる。 | 
| x_eq_F1 | x_eq | 熱平衡状態量 | 0.032173408 | F1後残差に対する単独対応は弱い。診断量として残す。 | F1(Tsub)をF(x_eq)へ置換すべき。 | 
| Tsub_F1 | Tsub | 入口サブクール | 0.0063023797 | F1後残差に対する単独対応は弱い。 | F1後残差はTsubで説明できる。 | 

## 8. 原因断定を避けるための判断表

| axis | can_show | why_not_cause | allowed_phrase | forbidden_phrase | 
| --- | --- | --- | --- | --- | 
| F_form | 非一様加熱換算、DNB位置、出力分布形状の違いを含む診断軸 | DNB位置、L/DH、軸方向出力分布と交絡している | F_formと対応して残る | F_formが原因である | 
| z_DNB/DH | 入口からDNB位置までの履歴長の違い | L/DHと強く交絡している | DNBまでの履歴長と対応して残る | DNB位置が原因である | 
| z_DNB/L | DNBが上流寄りか出口寄りかの違い | F_formや出力分布形状と交絡している | 相対DNB位置とも対応する | z_DNB/Lだけで説明できる | 
| L/DH | 全体の加熱長・ケース群差を含む整理軸 | 複合代理であり、単独物理量ではない | L/DHは診断軸として残る | L/DH補正式を作る | 
| Tsub | F1の元変数であり、F1前の誤差やF1効果量の説明軸 | F1後残差への対応は弱い | F1(Tsub)は維持する | F1後残差はTsubで説明できる | 
| x_eq | 熱平衡状態・二相発達状態の診断量 | Tsubと共変し、F1後残差への対応は弱い | x_eqは診断量として残す | F1をF(x_eq)へ置換する | 
| qM/qP | 実験側・予測側のレベル確認用 | qMは結果側量、qPは予測側量で循環しやすい | qM/qPは診断用に見る | qMを補正式入力にする | 
| case structure | 108/161/164のセットとして同時に変わる条件群 | 3ケースだけでは一般化できない | ケース構造と対応して残る | 108/161/164だけで一般化できる | 

## 9. 表現修正表

| avoid_phrase | recommended_phrase | reason | 
| --- | --- | --- | 
| F_formがPM_F1残差の原因である。 | PM_F1残差はF_formと対応して残るが、原因とは断定しない。 | F_formはDNB位置・L/DH・出力分布形状と交絡しているため。 | 
| L/DHで補正式を作れる。 | L/DHは診断軸として有用だが、複合代理として扱う。 | L/DHはケース構造をまとめて代表している可能性があるため。 | 
| DNB位置で補正式を作れる。 | DNB位置は診断軸であり、補正式化はしない。 | DNB位置はL/DHやF_formと切り分けられていないため。 | 
| F1後残差はF_form・DNB位置・L/DH側に残る。 | F1後残差はF_form・DNB位置・L/DH・ケース構造と対応して残る。 | 『側に残る』は原因に見えやすいため。 | 
| x_eqでF1を置換する。 | F1(Tsub)は維持し、x_eqは診断量として保留する。 | BT05/BT15/BT16でx_eq置換根拠が弱いと判断済みのため。 | 
| 108/161/164から一般的な結論が得られた。 | 108/161/164ではこの対応が見えるが、一般化には追加確認が必要である。 | 3ケース群だけでは外部一般化できないため。 | 

## 10. 図の役割

| figure | purpose | do_not_infer | 
| --- | --- | --- | 
| fig1_PM_F1_by_bundle | 108が過大側、161/164が過小側に残ることを示す | 原因断定に使わない | 
| fig2_PM_F1_R2_axes | F1後残差がTsub/x_eqよりF_form・DNB位置・L/DHと対応することを示す | R2を補正式係数にしない | 
| fig3_Fform_vs_zDNB_case_map | F_formがDNB位置だけではなくケース構造と絡むことを示す | F_form原因説にしない | 
| fig4_story_ladder | 説明の流れを一枚で固定する | 結論の飛躍を避ける | 

## 11. BT17判断

| item | decision | 
| --- | --- | 
| BT17 role | explanation figures and decision tables | 
| formula policy | no new formula | 
| safe wording | 対応して残る | 
| main message | F1後残差はTsub/x_eq側ではなく、F_form・DNB位置・L/DH・ケース構造と対応して残る | 
| forbidden jump | F_form/DNB位置/L_DHの単独原因化 | 
| next after BT17 | working_logへ追記し、必要なら内部説明文またはスライド骨子へ進む | 

## 12. BT16 bundle summary再掲

| group | N | PM_noF1_mean | PM_F1_mean | err_F1_mean | abs_err_F1_mean | delta_PM_mean | lift_ratio_mean | qM_MWm2_mean | qP_F1_MWm2_mean | F_form_mean | Tsub_mean | x_eq_mean | z_DNB_DH_mean | z_DNB_L_mean | L_DH_mean | 
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | 
| 108 | 14 | 0.65304894 | 1.1232232 | 0.1232232 | 0.1232232 | 0.47017426 | 1.7702032 | 3.0362535 | 3.408174 | 0.63608627 | 46.083809 | -0.013990909 | 139.65871 | 0.73821634 | 189.18399 | 
| 161 | 23 | 0.62098048 | 0.90884087 | -0.091159126 | 0.097589743 | 0.2878604 | 1.5527097 | 1.4135983 | 1.29514 | 1 | 63.843926 | -0.082322824 | 361.35516 | 0.99707054 | 362.41684 | 
| 164 | 21 | 0.59786191 | 0.93956052 | -0.060439484 | 0.086036296 | 0.34169861 | 1.672137 | 1.1887617 | 1.1240311 | 1.2798813 | 54.954868 | -0.15527776 | 286.82405 | 0.79142031 | 362.41684 | 

## 13. BT16 case summary再掲

| group | N | PM_noF1_mean | PM_F1_mean | err_F1_mean | abs_err_F1_mean | delta_PM_mean | lift_ratio_mean | qM_MWm2_mean | qP_F1_MWm2_mean | F_form_mean | Tsub_mean | x_eq_mean | z_DNB_DH_mean | z_DNB_L_mean | L_DH_mean | 
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | 
| 108_70in | 12 | 0.65672421 | 1.1166142 | 0.11661421 | 0.11661421 | 0.45989 | 1.7564697 | 3.0738852 | 3.431708 | 0.61982066 | 47.1332 | -0.011302126 | 137.96929 | 0.7292863 | 189.18399 | 
| 108_76in | 2 | 0.63099733 | 1.1628772 | 0.16287716 | 0.16287716 | 0.53187983 | 1.8526041 | 2.8104627 | 3.2669701 | 0.73367994 | 39.787462 | -0.030123609 | 149.79523 | 0.79179655 | 189.18399 | 
| 161_uniform | 23 | 0.62098048 | 0.90884087 | -0.091159126 | 0.097589743 | 0.2878604 | 1.5527097 | 1.4135983 | 1.29514 | 1 | 63.843926 | -0.082322824 | 361.35516 | 0.99707054 | 362.41684 | 
| 164_112in | 1 | 0.33017459 | 0.79743867 | -0.20256133 | 0.20256133 | 0.46726408 | 2.415203 | 1.1380982 | 0.90756354 | 0.8776443 | 19.778147 | 0.095434412 | 241.62255 | 0.66669791 | 362.41684 | 
| 164_134in_normal | 20 | 0.61124627 | 0.94666661 | -0.053333392 | 0.080210044 | 0.33542033 | 1.6349837 | 1.1912949 | 1.1348545 | 1.2999932 | 56.713704 | -0.16781337 | 289.08413 | 0.79765643 | 362.41684 | 

## 14. 108 vs mean(161,164)再掲

| variable | value_108 | mean_161_164 | delta_108_minus_161_164 | ratio_108_over_161_164 | 
| --- | --- | --- | --- | --- | 
| PM_noF1_mean | 0.65304894 | 0.60942119 | 0.043627744 | 1.0715888 | 
| PM_F1_mean | 1.1232232 | 0.92420069 | 0.19902251 | 1.2153456 | 
| err_F1_mean | 0.1232232 | -0.075799305 | 0.19902251 | -1.6256508 | 
| abs_err_F1_mean | 0.1232232 | 0.09181302 | 0.031410183 | 1.3421103 | 
| delta_PM_mean | 0.47017426 | 0.3147795 | 0.15539476 | 1.4936623 | 
| lift_ratio_mean | 1.7702032 | 1.6124234 | 0.15777984 | 1.0978526 | 
| qM_MWm2_mean | 3.0362535 | 1.30118 | 1.7350734 | 2.3334614 | 
| qP_F1_MWm2_mean | 3.408174 | 1.2095856 | 2.1985885 | 2.8176378 | 
| F_form_mean | 0.63608627 | 1.1399407 | -0.50385439 | 0.55799946 | 
| Tsub_mean | 46.083809 | 59.399397 | -13.315588 | 0.77582958 | 
| x_eq_mean | -0.013990909 | -0.11880029 | 0.10480938 | 0.11776831 | 
| z_DNB_DH_mean | 139.65871 | 324.08961 | -184.43089 | 0.43092624 | 
| z_DNB_L_mean | 0.73821634 | 0.89424543 | -0.15602909 | 0.82551872 | 
| L_DH_mean | 189.18399 | 362.41684 | -173.23285 | 0.52200662 | 

## 15. 一次読み

```text
BT17では、BT16の数値結果を補正式化せず、説明用の図・判断表として整理した。

説明の中心は、F1後残差がTsub/x_eq側ではなく、F_form・DNB位置・L/DH・ケース構造と対応して残る、という点である。
ただし、F_form、DNB位置、L/DHは互いに交絡しているため、単独原因にはしない。
したがって、BT17の安全な表現は『対応して残る』であり、『原因である』ではない。
BT17でもF1(Tsub)は維持し、F(x_eq)置換、F_form補正式、DNB位置補正式、L/DH補正式には進まない。
```

## 16. 次アクション

```text
1. このrun_reportをチャットへアップロードする。
2. チャット側で図・判断表の言い過ぎがないか確認する。
3. 問題なければ、working_logへBT17追記を行う。
4. rを上げたworking_logを再アップロードして、追記確認まで行う。
5. その後、必要なら内部説明文またはスライド骨子に進む。
```
