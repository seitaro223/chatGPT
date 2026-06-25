# TM01 Source01 lowX Main Set Freeze

作成日: 2026-06-25 16:51:08

## 1. 目的

TM00bで固定した `source01_lowX_9_12 = 280` を、今後のT&M Table9〜12主解析入口として明示的に固定する。

このrunでは採用入口を固定するだけであり、PM計算、F1再fit、L/D補正式作成は行わない。

## 2. 入力・出力

- rootDir: `W:\`
- input TM00b xlsx: `TM00b_tables9_12_candidate_sets_20260625_153926.xlsx`
- input TM00c xlsx: `TM00c_legacy_bridge_audit_20260625_161948.xlsx`
- output Excel: `TM01_source01_lowX_main_set_freeze_20260625_165104.xlsx`

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
| bridge_overlap_with_legacy | 137 | 137 | OK |
| bridge_new_only_vs_legacy | 143 | 143 | OK |

## 4. Main set summary

| candidate_set | N | table_counts | source_counts | flag_counts | P_min | P_max | GSI_min | GSI_max | LD_min | LD_max | Hsub_min | Hsub_max | x_min | x_max | D_min_mm | D_max_mm |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| source01_lowX_9_12_TM01_main | 280 | 9:30, 10:190, 11:30, 12:30 | source01:280 | none:277, G:3 | 1750 | 2500 | 520.792 | 10565 | 20.979 | 365.333 | 38.6116 | 1585.4 | -0.459 | 0.05 | 1.905 | 7.7724 |

## 5. By-table summary

| TableNo | N | flag_counts | P_min | P_max | GSI_min | GSI_max | LD_min | LD_max | Hsub_min | Hsub_max | x_min | x_max | D_min_mm | D_max_mm |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 9 | 30 | none:30 | 1750 | 1750 | 2305.59 | 4109.38 | 80 | 365.333 | 348.667 | 1393.97 | -0.079 | 0.012 | 1.905 | 1.905 |
| 10 | 190 | none:187, G:3 | 2000 | 2000 | 520.792 | 10565 | 20.979 | 365.333 | 38.6116 | 1456.31 | -0.459 | 0.05 | 1.905 | 7.7724 |
| 11 | 30 | none:30 | 2250 | 2250 | 2034.35 | 3878.82 | 80 | 365.333 | 420.541 | 1515.85 | -0.122 | 0.011 | 1.905 | 1.905 |
| 12 | 30 | none:30 | 2500 | 2500 | 1939.41 | 3661.82 | 80 | 365.333 | 461.478 | 1585.4 | -0.199 | 0.047 | 1.905 | 1.905 |

## 6. Bridge summary

TM00cのbridge labelを読み込んだ。`overlap_with_legacy` は旧176点にも含まれる新正本点、`new_only_vs_legacy` は旧176点には含まれない新正本点である。

| legacy_bridge_group | N | flag_counts | P_min | P_max | GSI_min | GSI_max | LD_min | LD_max | Hsub_min | Hsub_max | x_min | x_max | D_min_mm | D_max_mm |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| overlap_with_legacy | 137 | none:137 | 1750 | 2500 | 1939.41 | 4109.38 | 64.5161 | 365.333 | 213.062 | 1585.4 | -0.457 | 0.049 | 1.905 | 7.7724 |
| new_only_vs_legacy | 143 | none:140, G:3 | 2000 | 2000 | 520.792 | 10565 | 20.979 | 365.333 | 38.6116 | 1456.31 | -0.459 | 0.05 | 1.905 | 7.7724 |

### By table and bridge group

| TableNo | legacy_bridge_group | N | flag_counts | P_min | P_max | GSI_min | GSI_max | LD_min | LD_max | Hsub_min | Hsub_max | x_min | x_max | D_min_mm | D_max_mm |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 9 | overlap_with_legacy | 30 | none:30 | 1750 | 1750 | 2305.59 | 4109.38 | 80 | 365.333 | 348.667 | 1393.97 | -0.079 | 0.012 | 1.905 | 1.905 |
| 10 | new_only_vs_legacy | 143 | none:140, G:3 | 2000 | 2000 | 520.792 | 10565 | 20.979 | 365.333 | 38.6116 | 1456.31 | -0.459 | 0.05 | 1.905 | 7.7724 |
| 10 | overlap_with_legacy | 47 | none:47 | 2000 | 2000 | 2441.21 | 4068.69 | 64.5161 | 80 | 213.062 | 1196.96 | -0.457 | 0.049 | 1.905 | 7.7724 |
| 11 | overlap_with_legacy | 30 | none:30 | 2250 | 2250 | 2034.35 | 3878.82 | 80 | 365.333 | 420.541 | 1515.85 | -0.122 | 0.011 | 1.905 | 1.905 |
| 12 | overlap_with_legacy | 30 | none:30 | 2500 | 2500 | 1939.41 | 3661.82 | 80 | 365.333 | 461.478 | 1585.4 | -0.199 | 0.047 | 1.905 | 1.905 |

## 7. Policy notes

| No | policy_note |
| --- | --- |
| 1 | TM01 adopts source01_lowX_9_12 = 280 as the main T&M Table9-12 entrance. |
| 2 | Selection rule is Table9-12 AND source01 AND x_report <= 0.05. |
| 3 | The legacy 176 set is frozen as a reference for old diagnostics, not used as the main entrance. |
| 4 | The old Table10 86 set was not selected by quality; the difference from new Table10 190 is not an error. |
| 5 | This run does not compute PM, does not refit F1, and does not create an L/D correction. |
| 6 | TM00c bridge labels are loaded for overlap/new_only reference. |

## 8. 読み方

- 今後のT&M Table9〜12主解析入口は `x_report <= 0.05` かつ `source01` の280点である。
- Table9/11/12は旧legacy集合と一致していたが、Table10は旧86点と新190点で抽出思想が異なる。
- 旧Table10 86点はquality条件で絞った集合ではないため、新Table10 190点との差を誤りとして扱わない。
- 旧176点は過去診断との比較用legacy集合として凍結し、今後の主解析入口には使わない。
- 次にPM/F1診断へ進む場合は、このTM01 main setを入口として用いる。ただし、このrunではまだPM/F1診断を実施していない。

## 9. 採用・保留

### 採用

- TM01を主解析入口固定runとして扱う。
- 主解析入口は `source01_lowX_9_12 = 280` とする。
- 入口条件は `x_report <= 0.05` とする。
- 旧176点はlegacy referenceとして凍結する。

### 保留

- この280点でPM診断へ進んだとき、旧176点診断と結果がどう変わるか。
- F1再fitへ進むかどうか。
- Table10 new_only 143点が診断結果に与える影響。
- source09/Weatherhead照合後の扱い。

### まだ行わない

- PM計算。
- F1再fit。
- L/D補正式作成。
