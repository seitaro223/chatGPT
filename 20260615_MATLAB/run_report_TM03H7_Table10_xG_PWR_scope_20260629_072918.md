# TM03H7 Table10 current187 x帯 × G帯 PWR条件スコープ診断

作成時刻: 20260629_072918

## 目的

Table10 current187について、強負クオリティ高P/M群を、

- Celataモデル対象外かどうか
- PWR条件外かどうか

を混同せずに整理する。

今回の作業では、強負クオリティであること自体はサブクール沸騰・DNB対象からの除外理由にしない。
一方、GがPWR代表条件から大きく外れる場合は、研究対象スコープ外として主解析から外す候補にする。

## 入力

- `TM03H6_combined_current_old_records_20260629_070106.csv`
- 対象: `current187_noF1` 187点
- P/M列: `PM_plot` を `PM_noF1` として使用
- quality列: `x`
- G列: `G_kg_m2s`

## 区分

quality band:

```text
x <= -0.20
-0.20 < x <= -0.10
-0.10 < x <= 0
0 < x <= 0.05
```

G band:

```text
G < 1900
1900 <= G <= 4200
G > 4200
```

policy class:

```text
A: x<=-0.20 and G>4200       -> PWR条件外候補
B: x<=-0.20 and G<=4200      -> PWR内の強サブクール別枠
C: x>-0.20 and G>4200        -> PWR条件外候補
D: x>-0.20 and G<=4200       -> PWR主解析候補
```

## 主要結果

current187全体:

```text
N = 187
G<=4200 = 117
G>4200  = 70
x<=-0.20 = 41
```

強負クオリティ群 `x<=-0.20` は41点あり、そのうち29点が `G>4200` であった。

```text
x<=-0.20 all G  : N = 41
x<=-0.20 G>4200 : N = 29
x<=-0.20 G<=4200: N = 12
```

高P/M群 `PM>=2.2` は26点あり、そのうち22点が `G>4200` であった。

```text
PM>=2.2 all G   : N = 26
PM>=2.2 G>4200  : N = 22
PM>=2.2 G<=4200 : N = 4
```

手で黄色く囲った候補領域は19点あり、そのうち16点が `G>4200` であった。

```text
yellow candidate all G   : N = 19
yellow candidate G>4200  : N = 16
yellow candidate G<=4200 : N = 3
```

したがって、黄色群・高P/M群の多くは、高G側に偏っている。
ただし、全てではない。
`G<=4200` にも高P/M点が4点、黄色候補が3点残る。

## x帯 × G帯の点数

```text
G_band3         G<1900  1900<=G<=4200  G>4200  All
x_band4                                           
x<=-0.20             3              9      29   41
-0.20<x<=-0.10      11              9      12   32
-0.10<x<=0          13             49      16   78
0<x<=0.05           11             12      13   36
All                 38             79      70  187
```

## policy class集計

```text
                                   group   N  PM_noF1_mean  PM_noF1_median  Tsub_mean    x_mean  G_kg_m2s_mean  N_old86_overlap  N_PM_ge_2p2  R2_PM_Tsub_linear  R2_PM_Tsub_quadratic
A_deep_subcooled_highG_PWR_out_candidate  29      2.316823        2.272600 156.971956 -0.342759    7214.675934                0           22           0.036786              0.059102
  B_deep_subcooled_Gle4200_keep_separate  12      2.197694        2.157303 194.655598 -0.310083    2813.273097                5            4           0.021252              0.068491
      C_not_deep_highG_PWR_out_candidate  41      0.800475        0.833179  60.377530 -0.047780    6114.612573                0            0           0.785672              0.887395
       D_not_deep_Gle4200_main_candidate 105      1.278292        1.301764 126.147468 -0.047876    2428.220025               42            0           0.552892              0.863389
```

## Tsub相関の感度

```text
all_current187:
  N = 187
  Tsub linear R2    = 0.418
  Tsub quadratic R2 = 0.696

G<=4200_all_x:
  N = 117
  Tsub linear R2    = 0.455
  Tsub quadratic R2 = 0.720

x<=-0.20_G>4200:
  N = 29
  Tsub linear R2    = 0.037
  Tsub quadratic R2 = 0.059

x<=-0.20_G<=4200:
  N = 12
  Tsub linear R2    = 0.021
  Tsub quadratic R2 = 0.068

x>-0.20_G<=4200:
  N = 105
  Tsub linear R2    = 0.553
  Tsub quadratic R2 = 0.863
```

## 判断

今回の結果から、強負クオリティ高P/M群の多くは `G>4200` に偏っていることが確認できた。
したがって、これらの多くは、

```text
Celataモデル対象外だから除外
```

ではなく、

```text
PWR条件から外れる高G側なので、PWR主解析から外す候補
```

として扱うのが妥当である。

一方、`x<=-0.20` かつ `G<=4200` の点も12点存在し、`PM>=2.2` かつ `G<=4200` の点も4点残る。
このため、強負クオリティ群を一律に除外するのはまだ危険である。

安全な扱いは以下。

```text
A: x<=-0.20 and G>4200
  PWR条件外候補として主解析から外す候補。
  ただし、Celata対象外とは言わない。

B: x<=-0.20 and G<=4200
  PWR条件内に残る強サブクール群として別枠診断。
  除外しない。

C: x>-0.20 and G>4200
  qualityは普通でも高Gなので、PWR条件外候補。

D: x>-0.20 and G<=4200
  PWR主解析候補。
```

## 次アクション案

次は、TM03H8として、以下を確認する。

```text
Table10 current187を、
  PWR main candidate = G<=4200
  high-G out-of-PWR candidate = G>4200
に分け、
その中で deep subcooled x<=-0.20 を別枠表示する。

目的：
  G>4200を除いたときに、Table10 lowXのP/M vs Tsubがどこまで整理されるかを確認する。
  同時に、G<=4200内に残る強負クオリティ点4〜12点を、外れ候補ではなくPWR内強サブクール群として確認する。
```
