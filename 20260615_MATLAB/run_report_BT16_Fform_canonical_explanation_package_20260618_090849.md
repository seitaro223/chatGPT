# BT16 Fform canonical explanation package

作成日時: 20260618_090849

## 1. 目的

BT15でF_formをlinear_v1として正本化した後の状態を、内部説明・発表用に整理する。

本タスクは補正式作成ではない。

## 2. 入力

- input: `H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx`

## 3. 出力

- output Excel: `BT16_Fform_canonical_explanation_package_20260618_090849.xlsx`
- figure: `fig_BT16_PM_F1_by_bundle_20260618_090849.png`
- figure: `fig_BT16_PM_F1_vs_LDH_20260618_090849.png`
- figure: `fig_BT16_Fform_by_case_20260618_090849.png`

## 4. 前提

```text
- F2/F1F2は使わない。
- 比較対象はnoF1とF1のみ。
- F1(Tsub)は維持する。
- F1(Tsub)をF(x_eq)へ置換しない。
- F_formはlinear_v1正本として扱う。
- legacy F_formは今後の解析入力には使わない。
- F_form補正式、DNB位置補正式、L/DH補正式は作らない。
- BT16は説明整理であり、新補正式探索ではない。
```

## 5. QC

| item | status | value | reading | 
| 