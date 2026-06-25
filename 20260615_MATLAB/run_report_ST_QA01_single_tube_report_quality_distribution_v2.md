# ST-QA01 T&M単管 報告書転記クオリティ分布確認

## 目的

- qM/qPから再計算したx_eqではなく、T&M報告書から転記した実験値側クオリティを見る。
- Table9〜12について、Table別・L/D群別に、負側〜0近傍が多いか確認する。

## 入力

- input file: `H52Q_current_single_tube_input_v1_20260615_183839.xlsx`
- sheet: `ST_F1_T8_14_current`
- report quality column: `x_Mes`

## 重要な注意

- このrunでは、`qM`ベースまたは`qP`ベースで計算したx_eqは使っていない。
- 使用しているのは報告書転記クオリティ列である。

## Table別・L/D群別summary

| TableNo | LD_group | N | x_report_mean | x_report_median | x_report_min | x_report_max | x_report_sd | frac_x_le_0 | frac_x_le_005 | frac_x_gt_0 | LD_mean | Tsub_mean | P_MPa_mean | PM_mean |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 9 | short_or_middle | 6 | -0.0693333 | -0.055 | -0.146 | -0.047 | 0.0379719 | 1 | 1 | 0 | 0.152019 | 95.2427 | 1.59729e+07 | 1.24089 |
| 10 | short_or_middle | 6 | -0.0695 | -0.0555 | -0.138 | -0.035 | 0.0362146 | 1 | 1 | 0 | 0.152019 | 92.0183 | 1.59729e+07 | 1.2587 |
| 11 | short_or_middle | 5 | -0.0524 | -0.056 | -0.104 | 0.001 | 0.0394119 | 0.8 | 1 | 0.2 | 0.1524 | 108.945 | 1.55132e+07 | 1.0487 |
| 12 | short_or_middle | 5 | -0.0664 | -0.04 | -0.202 | -0.004 | 0.0808103 | 1 | 1 | 0 | 0.1524 | 104.137 | 1.55132e+07 | 1.07812 |

## Table別summary

| TableNo | N | x_report_mean | x_report_median | x_report_min | x_report_max | frac_x_le_0 | frac_x_le_005 | frac_x_gt_0 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 9 | 6 | -0.0693333 | -0.055 | -0.146 | -0.047 | 1 | 1 | 0 |
| 10 | 6 | -0.0695 | -0.0555 | -0.138 | -0.035 | 1 | 1 | 0 |
| 11 | 5 | -0.0524 | -0.056 | -0.104 | 0.001 | 0.8 | 1 | 0.2 |
| 12 | 5 | -0.0664 | -0.04 | -0.202 | -0.004 | 1 | 1 | 0 |

## 出力

- `ST_QA01_single_tube_report_quality_distribution_v2.xlsx`
- `fig_ST_QA01_single_tube_report_quality_distribution_v2_01_by_table_ld.png`
- `fig_ST_QA01_single_tube_report_quality_distribution_v2_02_vs_LD.png`
- `fig_ST_QA01_single_tube_report_quality_distribution_v2_03_vs_Tsub.png`
