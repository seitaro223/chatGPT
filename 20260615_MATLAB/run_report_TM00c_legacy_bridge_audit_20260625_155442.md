# TM00c Legacy Bridge Audit

作成日: 2026-06-25 15:54:47

## 1. 目的

TM00bで固定した新しい正本候補 `source01_lowX_9_12` と、過去診断で使っていた旧Table9〜12集合の関係をキー単位で確認する。

このrunでは採用点を決めない。PM計算、F1再fit、L/D補正式作成は行わない。

## 2. 入力・出力

- rootDir: `W:\`
- input TM00b xlsx: `TM00b_tables9_12_candidate_sets_20260625_153926.xlsx`
- legacy xlsx: `H52Q_current_single_tube_input_v1_20260615_183839.xlsx`
- legacy sheet: `ST_F1_T8_14_current`
- output Excel: `TM00c_legacy_bridge_audit_20260625_155442.xlsx`

## 3. Expected checks

| checkName | expected | actual | status |
| --- | --- | --- | --- |
| new_source01_lowX_9_12 | 280 | 280 | OK |
| legacy_source01_9_12 | 176 | 0 | CHECK |
| new_T9 | 30 | 30 | OK |
| new_T10 | 190 | 190 | OK |
| new_T11 | 30 | 30 | OK |
| new_T12 | 30 | 30 | OK |
| legacy_T9 | 30 | 0 | CHECK |
| legacy_T10 | 86 | 0 | CHECK |
| legacy_T11 | 30 | 0 | CHECK |
| legacy_T12 | 30 | 0 | CHECK |
| overlap_all_observed |  | 0 | INFO |
| new_only_all_observed |  | 280 | INFO |
| legacy_only_all_observed |  | 0 | INFO |
| T10_overlap_observed |  | 0 | INFO |
| T10_new_only_observed |  | 190 | INFO |
| T10_legacy_only_observed |  | 0 | INFO |

## 4. Overall bridge summary

| item | N | note |
| --- | --- | --- |
| new_source01_lowX_9_12 | 280 | New canonical source01 lowX set from TM00b |
| legacy_source01_9_12 | 0 | Old legacy source01 Table9-12 set from legacy workbook |
| overlap | 0 | Keys present in both sets |
| new_only | 280 | New canonical keys absent from old legacy set |
| legacy_only | 0 | Old legacy keys absent from new canonical source01 lowX set |

## 5. By-table bridge summary

| TableNo | N_new | N_legacy | N_overlap | N_new_only | N_legacy_only |
| --- | --- | --- | --- | --- | --- |
| 9 | 30 | 0 | 0 | 30 | 0 |
| 10 | 190 | 0 | 0 | 190 | 0 |
| 11 | 30 | 0 | 0 | 30 | 0 |
| 12 | 30 | 0 | 0 | 30 | 0 |

## 6. Bridge groups by table

| TableNo | bridge_group | N |
| --- | --- | --- |
| 9 | new_only | 30 |
| 10 | new_only | 190 |
| 11 | new_only | 30 |
| 12 | new_only | 30 |

## 7. Condition summary by bridge group

| bridge_group | N | flag_counts | P_min | P_max | GSI_min | GSI_max | LD_min | LD_max | Hsub_min | Hsub_max | x_min | x_max |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| new_only | 280 | G:3, none:277 | 1750 | 2500 | 520.792 | 10565 | 20.979 | 365.333 | 38.6116 | 1585.4 | -0.459 | 0.05 |

## 8. Condition summary by table and bridge group

| TableNo | bridge_group | N | flag_counts | P_min | P_max | GSI_min | GSI_max | LD_min | LD_max | Hsub_min | Hsub_max | x_min | x_max |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 9 | new_only | 30 | none:30 | 1750 | 1750 | 2305.59 | 4109.38 | 80 | 365.333 | 348.667 | 1393.97 | -0.079 | 0.012 |
| 10 | new_only | 190 | G:3, none:187 | 2000 | 2000 | 520.792 | 10565 | 20.979 | 365.333 | 38.6116 | 1456.31 | -0.459 | 0.05 |
| 11 | new_only | 30 | none:30 | 2250 | 2250 | 2034.35 | 3878.82 | 80 | 365.333 | 420.541 | 1515.85 | -0.122 | 0.011 |
| 12 | new_only | 30 | none:30 | 2500 | 2500 | 1939.41 | 3661.82 | 80 | 365.333 | 461.478 | 1585.4 | -0.199 | 0.047 |

## 9. 読み方

- `source01_lowX_9_12` は正本Markdown起点の新しい主解析候補である。
- 旧集合は過去のv15/v16系診断の入口であり、Table10旧86点を含む。
- 新旧の差は主にTable10で出るはずである。
- 旧Table10 86点を、新Table10 source01 lowX 190点の単純な部分集合と仮定しない。
- 数だけを見ると新Table10は旧86点より104点多いが、集合差としては overlap / new_only / legacy_only を見る。
- このrunで食い違いがあっても、直ちに誤りとはせず、旧集合の抽出条件と新しいlowX入口条件の違いとして読む。

## 10. 採用・保留

### 採用

- TM00cは旧176点相当集合と新280点集合の橋渡し監査runとして扱う。
- 新旧比較はTableNo + ExptNoキーで行う。
- TM00cではPM計算、F1再fit、L/D補正式には進まない。

### 保留

- どの候補集合でPM診断・F1再fitへ進むか。
- 旧Table10 86点の抽出思想を今後保持するか。
- 新Table10 source01 lowXのnew_only点をどこまで主解析に入れるか。
- legacy_only点がlowX外または旧F1/TmTsat監査由来としてどう位置づくか。
