# TM03H5 Table10 scatter / old86 / nonlinear diagnostic

作成日時: 20260629_064139

## 目的

Table10 source01 lowX の違和感について、R²だけでなく散布図で確認する。
特に以下を確認する。

- current_result Table10 valid187点で、P/M vs Tsubに外れ点・曲線性があるか。
- current_result Table10 valid187点で、P/M vs qualityに曲線性・飽和型らしさがあるか。
- 旧解析86点で本当にTsub相関があったか。
- 旧86点と現在187点は同じ母集団か。
- 線形だけでなく2次・3次・簡易飽和型を見たときに解釈が変わるか。

## 入力

- current_result valid277 CSV: `TM03EF_current_result_acceptance_QA_20260629_135859_records_valid277.csv`
- current_single_tube input: `H52Q_current_single_tube_input_v1_20260615_183839.xlsx`

## データ数

- current Table10 valid: 187
- current Table10 x<=0.05: 187
- current Table10 G<=4200: 117
- current Table10 G>4200: 70
- old86 noF1 rows: 86
- old86 F1 rows: 86
- old86 x<=0.05 rows: 47
- old86 x>0.05 rows: 39
- current187 と old86 のExptNo重複: 47

## 主要R²

### current187 noF1

| x軸 | 線形R² | 2次R² | 3次R² | 簡易飽和型R² |
|---|---:|---:|---:|---:|
| Tsub | 0.418 | 0.696 | 0.696 | 0.659 |
| x | 0.774 | 0.790 | 0.794 | 0.773 |

### old86 noF1 / F1

| dataset | x軸 | 線形R² | 2次R² | 3次R² | 簡易飽和型R² |
|---|---|---:|---:|---:|---:|
| old86 noF1 | Tsub | 0.872 | 0.967 | 0.976 | 0.977 |
| old86 noF1 | x | 0.759 | 0.905 | 0.920 | 0.756 |
| old86 F1 | Tsub | 0.358 | 0.397 | 0.449 | 0.432 |
| old86 F1 | x | 0.385 | 0.490 | 0.625 | 0.384 |

## 一次読み

1. current187では、Tsub線形R²は中程度だが、quality x のR²がかなり大きい。
2. current187では、xを2次・3次にしても大きく改善するわけではなく、xとの関係はこのlowX範囲ではかなり単調に近い。
3. old86は current187 と同じ集合ではない。old86のうち x<=0.05 は 47 点、x>0.05 は 39 点である。
4. current187に含まれるold86相当点は 47 点だけであり、old86全体とは直接比較できない。
5. 旧86点でTsub相関が見えていたとしても、それはx>0.05点を含む母集団、Tsub範囲、またはF1適用後の条件差に由来する可能性がある。
6. P/M vs Tsub散布図で外れ点候補を確認する価値がある。外れ点候補はCSVに出力した。

## 注意

- current187のP/Mは current_result の `PM_noF1` として扱った。
- old86については `ST_noF1_T8_14_current` と `ST_F1_T8_14_current` の両方を見た。
- xやqMは補正式入力として使わない。ここではTable10の違和感を理解するための診断量として扱う。
- 非線形モデルのR²が高くても、補正式として採用しない。

## 出力

- dataset summary: `TM03H5_Table10_scatter_legacy_nonlinear_20260629_064139_dataset_summary.csv`
- model compare: `TM03H5_Table10_scatter_legacy_nonlinear_20260629_064139_model_compare.csv`
- outlier candidates: `TM03H5_Table10_scatter_legacy_nonlinear_20260629_064139_outlier_candidates.csv`
- current records with old86 tag: `TM03H5_Table10_scatter_legacy_nonlinear_20260629_064139_current187_records_with_old86_tag.csv`
- old86 records scope: `TM03H5_Table10_scatter_legacy_nonlinear_20260629_064139_old86_records_scope.csv`

## 図

- `fig_TM03H5_01_current187_PM_vs_Tsub_20260629_064139.png`
- `fig_TM03H5_02_current187_PM_vs_x_20260629_064139.png`
- `fig_TM03H5_03_old86_PM_vs_Tsub_20260629_064139.png`
- `fig_TM03H5_04_old86_PM_vs_Tsub_20260629_064139.png`
- `fig_TM03H5_05_overlay_current187_old86_PM_vs_Tsub_20260629_064139.png`
- `fig_TM03H5_06_key_R2_compare_20260629_064139.png`
