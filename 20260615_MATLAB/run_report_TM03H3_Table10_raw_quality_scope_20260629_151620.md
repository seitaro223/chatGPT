# TM03H3_Table10_raw_quality_scope

作成日時: `2026-06-29 15:16:20`

## 1. 目的

TM03H2では、現在の `main280 / current_result` に含まれるTable10 valid187点がすべて `x <= 0.05` であり、current_result内では `x > 0.05` を含めたTsub相関変化を確認できないことが分かった。

そこでTM03H3では、計算済みPMではなく、T&M Table10 raw全649行へ戻り、`x > 0.05` を含む範囲の棚卸しを行う。

目的は採用点を増やすことではなく、以下を確認することである。

```text
- source01 lowXの外側にどれだけx>0.05があるか
- source09/Weatherhead側のx>0.05分布はどうか
- x>0.05でも低G側にある点がどれだけあるか
- qualityしきい値とGしきい値を流動様式の代理として使うときの危うさ
```

## 2. 入力

- Table10正本Markdown: `thompson_macbeth_table10_2000psia_r1.md`
- Parsed Table10 raw rows: `649`

## 3. 全体QC

```text
raw_all        : 649
x <= 0.05      : 307
x > 0.05       : 342
source counts  : {'source01': 388, 'source07': 4, 'source09': 232, 'source11': 25}
lowX by source : {'source01': 190, 'source09': 117}
x>0.05 by source: {'source01': 198, 'source07': 4, 'source09': 115, 'source11': 25}
```

## 4. 重要結果：x>0.05はrawには多いが、current_resultには入っていない

Table10 raw全体では、`x > 0.05` は `342` 点ある。

内訳は以下である。

```text
source01 x>0.05 : 198
source07 x>0.05 : 4
source09 x>0.05 : 115
source11 x>0.05 : 25
```

一方、現在の `main280 / current_result` は source01 lowX を主対象にしており、Table10 valid187点はすべて `x <= 0.05` であった。

したがって、`x > 0.05` を含めるとTsub相関がどう見えるか、という問いは、現在のcurrent_resultではなく、raw側または新しい計算対象で確認する必要がある。

## 5. quality × G分布

Gは kg/m2/s に換算し、暫定的に以下で層別した。

```text
G < 1900
1900 <= G <= 4200
G > 4200
```

quality × Gの件数は以下である。

| quality_bin   |   G<1900 |   1900<=G<=4200 |   G>4200 |
|:--------------|---------:|----------------:|---------:|
| x<=0          |       89 |              98 |       57 |
| 0<x<=0.05     |       26 |              22 |       15 |
| 0.05<x<=0.15  |       70 |              71 |        9 |
| 0.15<x<=0.5   |      127 |               3 |        0 |
| x>0.5         |       62 |               0 |        0 |

特に `x > 0.05` だけを見ると、source別G分布は以下である。

| source   |   G<1900 |   1900<=G<=4200 |   G>4200 |
|:---------|---------:|----------------:|---------:|
| source01 |      123 |              66 |        9 |
| source07 |        4 |               0 |        0 |
| source09 |      107 |               8 |        0 |
| source11 |       25 |               0 |        0 |

## 6. 読み方

TM03H2後のコメントでは、`x <= 0.05` なら気泡流〜スラグ流側に近いのではないか、したがってG下限で強く切らない方がよいのではないか、という見方を置いた。

TM03H3のraw棚卸しから、この見方は次のように補正できる。

```text
現在のsource01 lowX/current_resultについては、全点x<=0.05であり、
G下限カットを主条件にしすぎると、低クオリティ側のDNB候補まで落とす可能性がある。

一方、Table10 raw全体にはx>0.05が多数ある。
その中には低G側の点も多く、x>0.05だから直ちに環状流・ドライアウト側とは言い切れない。

つまり、qualityしきい値だけでも、Gしきい値だけでも、流動様式を直接分けられない。
```

## 7. 現時点の判断

```text
採用:
  Table10 current_result/source01 lowXでは、G下限カットを主条件にしすぎない。
  Gは除外条件ではなく、傾向を見る比較軸として扱う。

採用:
  Table10 rawにはx>0.05点が多数あり、これらはcurrent_resultの範囲外である。
  x>0.05を含めたTsub相関は、現在のvalid187では検証できない。

採用:
  x>0.05でも低G側にある点があり、qualityだけで流動様式を断定しない。

保留:
  x>0.05 raw点をどこまで計算対象に戻すか。
  source01 x>0.05を使うのか、source09/Weatherheadも別枠で見るのか。
  低G・高quality点が本当にDNB的に扱える流動様式なのか。

撤回気味:
  x>0.05を一律にDNB対象外として落とす案。
  G下限だけでDNBらしさを判断する案。
```

## 8. 次アクション案

次に進めるなら、以下のどちらかである。

```text
案A: TM03H4 raw source01 x>0.05 計算候補抽出
  source01に限定して、x>0.05のうち旧計算済み/未計算、G帯、flag、D/Lを整理し、
  どこまで追加計算する価値があるかを見る。

案B: TM03H4 source09/Weatherhead別枠棚卸し
  source09はWeatherhead/ANL相当なので、source01主解析とは混ぜず、
  別枠の比較候補としてx/G/Hsub分布を整理する。
```

今回の流れでは、まず案Aが自然である。
source01内で `x>0.05` を含めたときに、昔のTsub相関の見え方がどう変わる可能性があるかを追いやすいためである。

## 9. 出力

- `TM03H3_Table10_raw_quality_scope_20260629_151620_raw_records_with_scope_tags.csv`
- `TM03H3_Table10_raw_quality_scope_20260629_151620_candidate_set_summary.csv`
- `TM03H3_Table10_raw_quality_scope_20260629_151620_source_quality_summary.csv`
- `TM03H3_Table10_raw_quality_scope_20260629_151620_quality_G_summary.csv`
- `TM03H3_Table10_raw_quality_scope_20260629_151620_source_G_quality_summary.csv`
- `TM03H3_Table10_raw_quality_scope_20260629_151620_source01_x_gt_005_records.csv`
