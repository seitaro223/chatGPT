# TM02 Main280 New Calculation Package

作成日: 2026-06-25 17:06:59

## 1. 目的

TM01で固定した `source01_lowX_9_12 = 280` を、新規計算用の入力パッケージとして整理する。

このrunでは古い計算結果のカバレッジ監査は行わない。条件を選んだ後は、280点を新しく計算する前提とする。

PM計算、F1再fit、L/D補正式作成は行わない。

## 2. 入力・出力

- rootDir: `W:\`
- input TM01 xlsx: `TM01_source01_lowX_main_set_freeze_20260625_165104.xlsx`
- output Excel: `TM02_main280_new_calculation_package_20260625_170657.xlsx`

## 3. Expected checks

| checkName | expected | actual | status |
| --- | --- | --- | --- |
| main_total | 280 | 280 | OK |
| all_source01 | 280 | 280 | OK |
| all_lowX_x_report_le_0p05 | 280 | 280 | OK |
| duplicate_keys | 0 | 0 | OK |
| T9_main | 30 | 30 | OK |
| T10_main | 190 | 190 | OK |
| T11_main | 30 | 30 | OK |
| T12_main | 30 | 30 | OK |
| calc_action_to_be_newly_calculated | 280 | 280 | OK |

## 4. Main set summary

| candidate_set | N | table_counts | source_counts | bridge_counts | flag_counts | P_min | P_max | G_min | G_max | LD_min | LD_max | Hsub_min | Hsub_max | x_min | x_max |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TM02_main280_new_calculation_package | 280 | 10:190, 11:30, 12:30, 9:30 | source01:280 | new_only_vs_legacy:143, overlap_with_legacy:137 | G:3, none:277 | 1750 | 2500 |  |  | 20.979 | 365.333 | 38.6116 | 1585.4 | -0.459 | 0.05 |

## 5. By-table summary

| TableNo | N | table_counts | source_counts | bridge_counts | flag_counts | P_min | P_max | G_min | G_max | LD_min | LD_max | Hsub_min | Hsub_max | x_min | x_max |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 9 | 30 | 9:30 | source01:30 | overlap_with_legacy:30 | none:30 | 1750 | 1750 |  |  | 80 | 365.333 | 348.667 | 1393.97 | -0.079 | 0.012 |
| 10 | 190 | 10:190 | source01:190 | new_only_vs_legacy:143, overlap_with_legacy:47 | G:3, none:187 | 2000 | 2000 |  |  | 20.979 | 365.333 | 38.6116 | 1456.31 | -0.459 | 0.05 |
| 11 | 30 | 11:30 | source01:30 | overlap_with_legacy:30 | none:30 | 2250 | 2250 |  |  | 80 | 365.333 | 420.541 | 1515.85 | -0.122 | 0.011 |
| 12 | 30 | 12:30 | source01:30 | overlap_with_legacy:30 | none:30 | 2500 | 2500 |  |  | 80 | 365.333 | 461.478 | 1585.4 | -0.199 | 0.047 |

## 6. Bridge summary

TM01で付与されたlegacy bridge labelを引き継ぐ。ただし、これは旧計算値を利用するためではなく、旧176点との差分を後で説明するための参照ラベルである。

| legacy_bridge_group | N | table_counts | source_counts | bridge_counts | flag_counts | P_min | P_max | G_min | G_max | LD_min | LD_max | Hsub_min | Hsub_max | x_min | x_max |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| new_only_vs_legacy | 143 | 10:143 | source01:143 | new_only_vs_legacy:143 | G:3, none:140 | 2000 | 2000 |  |  | 20.979 | 365.333 | 38.6116 | 1456.31 | -0.459 | 0.05 |
| overlap_with_legacy | 137 | 10:47, 11:30, 12:30, 9:30 | source01:137 | overlap_with_legacy:137 | none:137 | 1750 | 2500 |  |  | 64.5161 | 365.333 | 213.062 | 1585.4 | -0.457 | 0.049 |

### By table and bridge group

| TableNo | legacy_bridge_group | N | table_counts | source_counts | bridge_counts | flag_counts | P_min | P_max | G_min | G_max | LD_min | LD_max | Hsub_min | Hsub_max | x_min | x_max |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 9 | overlap_with_legacy | 30 | 9:30 | source01:30 | overlap_with_legacy:30 | none:30 | 1750 | 1750 |  |  | 80 | 365.333 | 348.667 | 1393.97 | -0.079 | 0.012 |
| 10 | new_only_vs_legacy | 143 | 10:143 | source01:143 | new_only_vs_legacy:143 | G:3, none:140 | 2000 | 2000 |  |  | 20.979 | 365.333 | 38.6116 | 1456.31 | -0.459 | 0.05 |
| 10 | overlap_with_legacy | 47 | 10:47 | source01:47 | overlap_with_legacy:47 | none:47 | 2000 | 2000 |  |  | 64.5161 | 80 | 213.062 | 1196.96 | -0.457 | 0.049 |
| 11 | overlap_with_legacy | 30 | 11:30 | source01:30 | overlap_with_legacy:30 | none:30 | 2250 | 2250 |  |  | 80 | 365.333 | 420.541 | 1515.85 | -0.122 | 0.011 |
| 12 | overlap_with_legacy | 30 | 12:30 | source01:30 | overlap_with_legacy:30 | none:30 | 2500 | 2500 |  |  | 80 | 365.333 | 461.478 | 1585.4 | -0.199 | 0.047 |

## 7. Policy notes

| No | policy_note |
| --- | --- |
| 1 | TM02 replaces the previous coverage-audit idea. |
| 2 | After selecting conditions, all main280 points should be newly calculated. |
| 3 | Old/legacy calculation results are not used to decide whether the point is valid or covered. |
| 4 | The old 176 set remains a legacy reference only. |
| 5 | This run prepares a new calculation package only; it does not compute qP, PM, F1, or L/D correction. |
| 6 | Main entrance remains Table9-12 AND source01 AND x_report <= 0.05 = 280 points. |

## 8. 読み方

- TM02は、古い計算結果が何点あるかを調べるrunではない。
- 条件を選んだ後は、新しい主解析入口280点を新規に計算する。
- 旧176点および旧計算結果は、過去診断との比較用referenceとしてのみ扱う。
- `new_calc_manifest` シートを次の新規計算の入力リストとして使う。
- このrunではPM、F1、L/D補正はまだ計算しない。

## 9. 採用・保留

### 採用

- TM02はmain280の新規計算パッケージ作成runとして扱う。
- main280は全点 `TO_BE_NEWLY_CALCULATED` とする。
- 古い計算カバレッジを確認して採否を決める案は使わない。

### 保留

- 新規計算後にPM/F1診断へ進むか。
- F1再fitへ進むか。
- Table10 new_only 143点が診断結果に与える影響。

### まだ行わない

- PM計算。
- F1再fit。
- L/D補正式作成。
