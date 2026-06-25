# T10R03_Table10_allsource_lowX_inventory_v1

作成日時: `2026-06-25 13:54:57`

## 1. 目的

T&M Table10のlowX候補を、source01に限定せず、全sourceで棚卸しする。

このrunでは採用点を決めない。入口条件は `x_report <= 0.05` とし、その後にsource、G、flag、D、L/D、Hsubで層別する。

## 2. 入力

- Table10正本Markdown: `W:\thompson_macbeth_table10_2000psia_r1.md`
- 出力Excel: `W:\T10R03_Table10_allsource_lowX_inventory_v1_20260625_135452.xlsx`

## 3. QC

- Parsed Table10 rows: `649`
- all lowX rows (x_report <= 0.05): `307`
- source01 lowX rows: `190`
- source09 lowX rows: `117`
- other-source lowX rows: `0`

## 4. 抽出条件

今回の入口条件は以下のみである。

```text
lowX = x_report <= 0.05
```

source、G、flagでは最初から切らない。これらは採用条件ではなく、使いやすさを見るための層別軸として扱う。

## 5. Candidate set summary

| set | N | sources | flags | D_range | L_range | LD_range | G_range | Hsub_range | x_range | frac_x_le_0 | frac_lowX |
|---|---|---|---|---|---|---|---|---|---|---|---|
| raw_all | 649 | source01, source07, source09, source11 | none, C, G, H, DJ, J | 0.075 - 0.436 | 3 - 72 | 20.98 - 365.3 | 0.023 - 7.79 | 0 - 1456 | -0.82 - 1.069 | 0.37596 | 0.47304 |
| all_lowX | 307 | source01, source09 | none, G, J | 0.075 - 0.436 | 3 - 27.4 | 20.98 - 365.3 | 0.255 - 7.79 | 38.61 - 1456 | -0.82 - 0.05 | 0.79479 | 1 |
| all_lowX_cleanFlag | 250 | source01, source09 | none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 0.384 - 7.79 | 38.61 - 1456 | -0.459 - 0.05 | 0.788 | 1 |
| all_lowX_G_1p6_3p0 | 82 | source01, source09 | none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 1.62 - 3 | 38.61 - 1456 | -0.457 - 0.049 | 0.84146 | 1 |
| all_lowX_G_1p77_2p95 | 72 | source01, source09 | none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 1.77 - 2.9 | 38.61 - 1456 | -0.457 - 0.049 | 0.83333 | 1 |
| all_lowX_clean_G_1p6_3p0 | 82 | source01, source09 | none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 1.62 - 3 | 38.61 - 1456 | -0.457 - 0.049 | 0.84146 | 1 |
| source01_lowX | 190 | source01 | none, G | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 0.384 - 7.79 | 38.61 - 1456 | -0.459 - 0.05 | 0.79474 | 1 |
| source09_lowX | 117 | source09 | none, J | 0.304 - 0.436 | 18 - 18 | 41.28 - 59.21 | 0.255 - 2 | 143 - 1398 | -0.82 - 0.048 | 0.79487 | 1 |
| other_lowX | 0 |  |  |  |  |  |  |  |  |  |  |

## 6. Source summary all

| source | N | sources | flags | D_range | L_range | LD_range | G_range | Hsub_range | x_range | frac_x_le_0 | frac_lowX |
|---|---|---|---|---|---|---|---|---|---|---|---|
| source01 | 388 | source01 | none, G, H | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 0.0281 - 7.79 | 1.628 - 1456 | -0.459 - 1.069 | 0.389175 | 0.489691 |
| source07 | 4 | source07 | C, none | 0.12 - 0.18 | 6 - 9.4 | 50 - 52.22 | 0.023 - 0.07 | 737.1 - 1250 | 0.213 - 0.905 | 0 | 0 |
| source09 | 232 | source09 | none, DJ, J | 0.304 - 0.436 | 18 - 18 | 41.28 - 59.21 | 0.126 - 2 | 0 - 1398 | -0.82 - 0.72 | 0.400862 | 0.50431 |
| source11 | 25 | source11 | none | 0.411 - 0.415 | 72 - 72 | 173.5 - 175.2 | 0.5 - 1.3 | 36.98 - 562.9 | 0.183 - 0.515 | 0 | 0 |

## 7. Source summary lowX

| source | N | sources | flags | D_range | L_range | LD_range | G_range | Hsub_range | x_range | frac_x_le_0 | frac_lowX |
|---|---|---|---|---|---|---|---|---|---|---|---|
| source01 | 190 | source01 | none, G | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 0.384 - 7.79 | 38.61 - 1456 | -0.459 - 0.05 | 0.794737 | 1 |
| source09 | 117 | source09 | none, J | 0.304 - 0.436 | 18 - 18 | 41.28 - 59.21 | 0.255 - 2 | 143 - 1398 | -0.82 - 0.048 | 0.794872 | 1 |

## 8. Flag summary lowX

| flag | N | sources | flags | D_range | L_range | LD_range | G_range | Hsub_range | x_range | frac_x_le_0 | frac_lowX |
|---|---|---|---|---|---|---|---|---|---|---|---|
| none | 250 | source01, source09 | none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 0.384 - 7.79 | 38.61 - 1456 | -0.459 - 0.05 | 0.788 | 1 |
| G | 3 | source01 | G | 0.143 - 0.226 | 3 - 24.6 | 20.98 - 108.8 | 3.8 - 3.95 | 175.1 - 1095 | -0.449 - 0.029 | 0.666667 | 1 |
| J | 54 | source09 | J | 0.436 - 0.436 | 18 - 18 | 41.28 - 41.28 | 0.255 - 1.55 | 143 - 1398 | -0.82 - 0.045 | 0.833333 | 1 |

## 9. G-bin summary lowX

| G_bin | N | sources | flags | D_range | L_range | LD_range | G_range | Hsub_range | x_range | frac_x_le_0 | frac_lowX |
|---|---|---|---|---|---|---|---|---|---|---|---|
| G_1p6_3p0 | 82 | source01, source09 | none | 0.075 - 0.306 | 3 - 27.4 | 20.98 - 365.3 | 1.62 - 3 | 38.61 - 1456 | -0.457 - 0.049 | 0.841463 | 1 |
| G_1p0_1p6 | 82 | source01, source09 | none, J | 0.143 - 0.436 | 3 - 23.25 | 20.98 - 75.98 | 1 - 1.59 | 143 - 1293 | -0.82 - 0.048 | 0.756098 | 1 |
| G_3p0_4p0 | 37 | source01 | G, none | 0.143 - 0.226 | 3 - 24.6 | 20.98 - 108.8 | 3.03 - 3.98 | 126.3 - 1220 | -0.449 - 0.05 | 0.621622 | 1 |
| G_gt_4p0 | 38 | source01 | none | 0.143 - 0.226 | 3 - 24.6 | 20.98 - 108.8 | 4.08 - 7.79 | 58.38 - 1101 | -0.459 - 0.033 | 0.921053 | 1 |
| G_lt_1p0 | 68 | source01, source09 | none, J | 0.186 - 0.436 | 12 - 24.6 | 41.28 - 108.8 | 0.255 - 0.998 | 203.5 - 1401 | -0.493 - 0.049 | 0.808824 | 1 |

## 10. 一次判断テンプレート

```text
T10R03では、source01に限定せず、Table10 raw_allからlowX候補を広く棚卸しした。
入口条件はx_report<=0.05のみであり、Gやsourceやflagではまだ切らない。
その後、source別、G範囲別、flag別に層別し、使いやすい候補と監査が必要な候補を分ける。
source別の色分け図により、source01とsource09などが同じ条件空間にいるかを確認する。
まだF1再fitや採用点決定には進まない。
```

## 11. 次アクション

- source別色分け図を確認し、source01/source09/その他がG, Hsub, L/D, x_report上でどの程度重なるかを見る。
- Gを採用条件として固定する前に、PWR-like範囲と広域範囲を分けて感度を見る。
- まだPM計算やF1再fitへは進まない。

## 12. Figures

- `W:\fig_T10R03_01_lowX_x_vs_G_by_source_20260625_135452.png`
- `W:\fig_T10R03_02_lowX_Hsub_vs_G_by_source_20260625_135452.png`
- `W:\fig_T10R03_03_lowX_G_vs_LD_by_source_20260625_135452.png`
- `W:\fig_T10R03_04_raw_x_vs_G_by_source_20260625_135452.png`
