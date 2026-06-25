# T10R00/T10R01 Table10 raw parse and extraction audit

作成日時: `2026-06-25 11:46:28`

## 1. 目的

Weatherhead/ANLデータ確認により、T&M Table10の `.09` 系列がANL/Weatherhead由来である可能性が高くなった。
そのため、旧Table10抽出86点が厳しすぎた可能性を確認するため、まずT&M Table10正本Markdown全体を構造化し、抽出基準の監査を行う。

このrunでは、採用点は決めない。目的は `raw_all`、旧採用点、新規候補集合の見える化である。

## 2. 入力

- Table10正本Markdown: `thompson_macbeth_table10_2000psia_r1.md`
- ANL/Weatherhead抽出Markdown: `anl_1958_chf_claude.md`
- legacy selected workbook keys detected: 121 unique ExptNo

## 3. QC

- Parsed Table10 rows: `649`
- Unique source codes: `source01, source07, source09, source11`
- Unique flag values: `C, DJ, G, H, J, none`
- Exit quality range: `-0.820` to `1.069`
- G range [10^6 lb/(hr ft^2)]: `0.023` to `7.79`
- Diameter range [in]: `0.075` to `0.436`
- Length range [in]: `3` to `72`

## 4. Source summary

| source_label | N | x_mean | x_min | x_max | frac_x_le_0 | frac_x_le_005 | G_min | G_max | Hsub_min | Hsub_max | D_min | D_max | L_min | L_max |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| source01 | 388 | 0.07727 | -0.459 | 1.069 | 0.3892 | 0.4897 | 0.0281 | 7.79 | 0.7 | 626.1 | 0.075 | 0.306 | 3 | 27.4 |
| source07 | 4 | 0.562 | 0.213 | 0.905 | 0 | 0 | 0.023 | 0.07 | 316.9 | 537.2 | 0.12 | 0.18 | 6 | 9.4 |
| source09 | 232 | 0.07791 | -0.82 | 0.72 | 0.4009 | 0.5043 | 0.126 | 2 | 0 | 601 | 0.304 | 0.436 | 18 | 18 |
| source11 | 25 | 0.312 | 0.183 | 0.515 | 0 | 0 | 0.5 | 1.3 | 15.9 | 242 | 0.411 | 0.415 | 72 | 72 |

## 5. Flag summary

| flag_norm | N | x_mean | x_min | x_max | frac_x_le_0 | frac_x_le_005 | G_min | G_max | Hsub_min | Hsub_max | D_min | D_max | L_min | L_max |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| C | 3 | 0.4607 | 0.213 | 0.905 | 0 | 0 | 0.023 | 0.07 | 427.1 | 537.2 | 0.12 | 0.12 | 6 | 6 |
| DJ | 4 | 0.678 | 0.608 | 0.72 | 0 | 0 | 0.126 | 0.133 | 31.5 | 85 | 0.436 | 0.436 | 18 | 18 |
| G | 3 | -0.144 | -0.449 | 0.029 | 0.6667 | 1 | 3.8 | 3.95 | 75.3 | 470.6 | 0.143 | 0.226 | 3 | 24.6 |
| H | 1 | 0.422 | 0.422 | 0.422 | 0 | 0 | 0.616 | 0.616 | 55.8 | 55.8 | 0.187 | 0.187 | 12.5 | 12.5 |
| J | 122 | 0.1256 | -0.82 | 0.687 | 0.3689 | 0.4426 | 0.134 | 1.55 | 0 | 601 | 0.436 | 0.436 | 18 | 18 |
| none | 516 | 0.07499 | -0.459 | 1.069 | 0.3818 | 0.4845 | 0.0281 | 7.79 | 0.7 | 626.1 | 0.075 | 0.415 | 3 | 72 |

## 6. Candidate set counts (audit only)

以下は採用判断ではなく、抽出基準を比較するための候補集合である。

| candidate_set | N | sources | D_in_range | L_in_range | G_range | x_report_range |
|---|---|---|---|---|---|---|
| raw_all | 649 | source01, source07, source09, source11 | 0.075 - 0.436 | 3 - 72 | 0.023 - 7.79 | -0.82 - 1.07 |
| legacy_selected_detected | 103 | source01 | 0.075 - 0.306 | 6 - 27.4 | 1.62 - 3 | -0.457 - 0.137 |
| source01_all | 388 | source01 | 0.075 - 0.306 | 3 - 27.4 | 0.0281 - 7.79 | -0.459 - 1.07 |
| source01_x_le_005 | 190 | source01 | 0.075 - 0.306 | 3 - 27.4 | 0.384 - 7.79 | -0.459 - 0.05 |
| source09_all_weatherhead_like | 232 | source09 | 0.304 - 0.436 | 18 - 18 | 0.126 - 2 | -0.82 - 0.72 |
| source09_x_le_005 | 117 | source09 | 0.304 - 0.436 | 18 - 18 | 0.255 - 2 | -0.82 - 0.048 |
| all_x_le_005 | 307 | source01, source09 | 0.075 - 0.436 | 3 - 27.4 | 0.255 - 7.79 | -0.82 - 0.05 |
| all_x_le_005_no_CGH | 304 | source01, source09 | 0.075 - 0.436 | 3 - 27.4 | 0.255 - 7.79 | -0.82 - 0.05 |
| all_x_le_005_flag_none_or_J_DJ | 304 | source01, source09 | 0.075 - 0.436 | 3 - 27.4 | 0.255 - 7.79 | -0.82 - 0.05 |
| source01_or09_x_le_005 | 307 | source01, source09 | 0.075 - 0.436 | 3 - 27.4 | 0.255 - 7.79 | -0.82 - 0.05 |
| all_x_le_0 | 244 | source01, source09 | 0.075 - 0.436 | 3 - 27.4 | 0.258 - 7.79 | -0.82 - -0.003 |
| loose_G_1_to_8_and_x_le_005 | 239 | source01, source09 | 0.075 - 0.436 | 3 - 27.4 | 1 - 7.79 | -0.82 - 0.05 |

## 7. Legacy match

- Legacy unique ExptNo detected: `121`
- Matched to raw Table10: `103`
- Source01 low-x not legacy: `126`

| group | N | x_mean | G_range | x_report_range |
|---|---|---|---|---|
| raw_all | 649 | 0.08953 | 0.023 - 7.79 | -0.82 - 1.07 |
| legacy_selected | 103 | -0.01237 | 1.62 - 3 | -0.457 - 0.137 |
| not_legacy | 546 | 0.1088 | 0.023 - 7.79 | -0.82 - 1.07 |
| source01_lowX_not_legacy | 126 | -0.1267 | 0.384 - 7.79 | -0.459 - 0.05 |
| source09_not_legacy | 232 | 0.07791 | 0.126 - 2 | -0.82 - 0.72 |

## 8. ANL/Weatherhead coarse check

ANL/Weatherhead抽出Markdown内のTable見出しから粗く読んだ件数である。T&Mとの完全照合は次runで行う。

| ANL_table | N_rows |
|---|---|
| Table I 0.304 in | 232 |

## 9. Figures

- `fig_T10R00_01_source_counts_20260625_114609.png`
- `fig_T10R00_02_x_report_vs_G_by_source_20260625_114609.png`
- `fig_T10R00_03_Hsub_vs_G_by_source_20260625_114609.png`
- `fig_T10R00_04_candidate_set_counts_20260625_114609.png`

## 10. 一次判断

このrunはTable10抽出監査の入口であり、まだ採用点を増やす判断はしない。
まず、Table10全649行に対して、source、flag、D/L、G、Hsub、報告書転記クオリティの分布を固定する。
次runでは、旧採用86点がどの範囲を拾っていたか、また `.09` / Weatherhead相当系列を独立文献として足すのではなくT&M内出典系列としてどう扱うかを確認する。

## 11. 次アクション案

- T10R01b: 旧採用86点ExptNoとの確実な照合。
- T10R02: ANL/Weatherhead Table I/II と T&M `.09` 系列のキー照合。
- T10R03: 抽出基準候補 set_A〜set_F の条件範囲比較。
- T10R04: 候補点のPM計算へ進むか判断。ただしこの段階でも採用は急がない。
