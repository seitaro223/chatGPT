# BT18 slide figure package

作成日時: 20260618_104018

## 1. 目的

確認用スライドに必要な図を作成する。
本タスクはPowerPoint本体の作成ではなく、図とその使い方を固定するためのもの。

## 2. 入力

- mandatory: `BT16_Fform_canonical_explanation_package_20260618_090954.xlsx`
- optional: `BT17_explanation_figures_decision_tables_20260618_091951.xlsx`
- optional exists: `true`

## 3. 出力

- Excel: `BT18_slide_figure_package_20260618_104018.xlsx`
- `fig_BT18_01_bundle_PM_noF1_vs_F1_20260618_104018.png`
- `fig_BT18_02_PM_noF1_vs_LDH_20260618_104018.png`
- `fig_BT18_03_PM_F1_vs_LDH_20260618_104018.png`
- `fig_BT18_04_R2_compare_PMnoF1_PM_F1_20260618_104018.png`
- `fig_BT18_05_Fform_vs_zDNBL_case_map_20260618_104018.png`
- `fig_BT18_06_safe_wording_20260618_104018.png`
- `fig_BT18_07_single_tube_takeaway_20260618_104018.png`

## 4. QC

| item | status | value | reading | 
| --- | --- | --- | --- | 
| input_BT16_exists | OK | BT16_Fform_canonical_explanation_package_20260618_090954.xlsx | BT16出力Excelが存在するか。 | 
| input_BT17_exists_optional | OK | BT17_explanation_figures_decision_tables_20260618_091951.xlsx | BT17出力Excelがあれば読む。なくても実行可。 | 
| bundle_summary_rows | OK | 3 | 108/161/164の3行が期待値。 | 
| case_summary_rows | OK | 5 | 108_70/108_76/161/164_112/164_134の5行が期待値。 | 
| paired_rows | OK | 58 | BT16のペア行数が58であること。 | 
| paired_required_columns | OK |  | BT18図作成に必要なBT16 paired_point_data列。 | 

## 5. Slide-Figure map

| slide_no | slide_title | figure_file | message | 
| --- | --- | --- | --- | 
| Slide 1 | 全体結論 | fig_BT18_07_single_tube_takeaway_20260618_104018.png | 単管は要点図 | 
| Slide 2 | 単管側の整理 | fig_BT18_07_single_tube_takeaway_20260618_104018.png | 単管は要点図 | 
| Slide 3 | バンドル noF1 | fig_BT18_02_PM_noF1_vs_LDH_20260618_104018.png | PM_noF1ではL/DHが効かない | 
| Slide 4 | バンドル F1後 | fig_BT18_03_PM_F1_vs_LDH_20260618_104018.png + fig_BT18_04_R2_compare_PMnoF1_PM_F1_20260618_104018.png | PM_F1ではL/DH等と対応が見える | 
| Slide 5 | F_formの位置づけ | fig_BT18_05_Fform_vs_zDNBL_case_map_20260618_104018.png | F_formは原因ではなく診断軸 | 
| Slide 6 | 安全な表現 | fig_BT18_06_safe_wording_20260618_104018.png | 『対応して残る』を固定 | 
| Slide 7 | まとめ | fig_BT18_01_bundle_PM_noF1_vs_F1_20260618_104018.png | 108/161/164のPM整理 | 

## 6. Correlation comparison (used for Slide 3-4)

| axis_var | axis_label | N_noF1 | r_PM_noF1 | R2_PM_noF1 | N_F1 | r_PM_F1 | R2_PM_F1 | 
| --- | --- | --- | --- | --- | --- | --- | --- | 
| L_DH_F1 | L/DH | 58 | -0.12201915 | 0.014888672 | 58 | -0.69051961 | 0.47681733 | 
| z_DNB_DH_F1 | z_DNB/DH | 58 | -0.07156664 | 0.0051217839 | 58 | -0.66597163 | 0.44351822 | 
| z_DNB_L_F1 | z_DNB/L | 58 | 0.010872423 | 0.00011820959 | 58 | -0.47005573 | 0.22095238 | 
| F_form_F1 | F_form | 58 | -0.086360716 | 0.0074581732 | 58 | -0.49317373 | 0.24322033 | 
| Tsub_F1 | Tsub | 58 | 0.87734122 | 0.76972761 | 58 | 0.079387528 | 0.0063023797 | 
| x_eq_F1 | x_eq | 58 | -0.79200334 | 0.6272693 | 58 | -0.17936947 | 0.032173408 | 

## 7. BT17 decision reminder

| item | decision | 
| --- | --- | 
| BT17 role | explanation figures and decision tables | 
| formula policy | no new formula | 
| safe wording | 対応して残る | 
| main message | F1後残差はTsub/x_eq側ではなく、F_form・DNB位置・L/DH・ケース構造と対応して残る | 
| forbidden jump | F_form/DNB位置/L_DHの単独原因化 | 
| next after BT17 | working_logへ追記し、必要なら内部説明文またはスライド骨子へ進む | 

## 8. 一次読み

```text
BT18では、確認用スライドに必要な図を作成した。
重要なのは、noF1ではL/DHが効かない一方、F1後にはL/DH等との対応が見える、という違いを明確に見せること。
この違いにより、L/DH補正式へ進まず、L/DHを診断軸として扱う理由を説明しやすくする。
単管側はこの段階では生データ図を増やさず、Hsub/PでL/Dに見えた差を整理できるという要点図に留めた。
BT18の図は確認用であり、必要なら次にラベル・凡例・注記を発表向けに整える。
```

## 9. 次アクション

```text
1. このrun_reportをチャットへアップロードする。
2. 可能ならfig_BT18_*.pngもアップロードする。
3. 図の採用/不採用を決める。
4. 次に、スライド本文・箇条書き・注記を作る。
```
