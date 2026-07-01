# TM03E current_result抽出・受入QA・Tsub予備確認

## 位置づけ

この作業は、TM03C all_rev xlsmを今後の解析で直接読み続けないため、値を抽出して current_result を固定する作業である。
目的は追加データの受入QAと、F1成立性の予備確認であり、F1の係数作成や補正式探索ではない。

## 入力

- source xlsm: `celataモデル_簡易計算_単管_櫻井検算r127_F1なし_all_rev.xlsm`
- main280 input: `TM03C_main280_input_20260626_130059.xlsx`

## QA結果

- main280 input: 280 点
- Log SUMMARY rows 226〜505: 280 件
- valid OK: 277 点
- excluded: 3 点
- excluded IDs: 148.01_10, 39.01_10, 42.01_10

## valid277 PM一次統計

- mean: 1.44932
- median: 1.41649
- SD: 0.572001
- min: 0.0735488
- max: 3.60536

## Table別PM

- Table 9: N=30, mean=1.26704, median=1.2932, SD=0.181806
- Table 10: N=187, mean=1.39358, median=1.35348, SD=0.639188
- Table 11: N=30, mean=1.54781, median=1.49815, SD=0.274531
- Table 12: N=30, mean=1.88052, median=1.88001, SD=0.358154

## Tsub / F1成立性の予備確認

- all_valid277 / PM_noF1 ~ Tsub: N=277, R2=0.386357, corr=0.621577, slope=0.00406138
- all_valid277 / ln(PM_noF1) ~ Tsub: N=277, R2=0.336418, corr=0.580016, slope=0.00369062
- trim_PM_0p2_3p0 / PM_noF1 ~ Tsub: N=271, R2=0.392677, corr=0.62664, slope=0.00383284
- trim_PM_0p2_3p0 / ln(PM_noF1) ~ Tsub: N=271, R2=0.374401, corr=0.611883, slope=0.00312897

Table別のTsub相関は `Tsub_F1_feasibility` を参照する。

## 判断

- Tsub相関は、F1を作るためではなく、F1を作れる構造が残っているかを見る予備確認として扱う。
- valid277は受入QAとしては固定できる。
- Weatherhead収録確認は未実施。Weatherheadのcanonical point listを入力にして別途照合する。
- 追加文献が揃うまでは、F1再fitや補正式探索には進まない。

## 出力

- `TM03E_records_all280_current_result_v1_20260629_042158.csv`
- `TM03E_records_valid277_current_result_v1_20260629_042158.csv`
- `TM03E_excluded3_current_result_v1_20260629_042158.csv`
- `TM03E_table_summary_current_result_v1_20260629_042158.csv`
- `TM03E_tsub_feasibility_current_result_v1_20260629_042158.csv`
- `TM03E_tsub_bins_current_result_v1_20260629_042158.csv`
- `TM03E_outliers_current_result_v1_20260629_042158.csv`
- `TM03E_current_main280_result_v1_20260629_042158.xlsx`
- `TM03E_extract_current_main280_result_v1_20260629_042158.m`