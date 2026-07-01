# TM03I1 source09 / Weatherhead Table10 B-scope inventory

作成: 20260701_042845

## 目的

TM03H11までで source01 Table10 lowX については、`G<=4200` かつ `L/D>=40` を主候補スコープ（B基準）として扱う方針が固まりつつある。
本作業では、source01で補正式を作り込む前に、別ソースである source09 / Weatherhead(ANL) Table10 に同じB基準を当てたとき、どの程度の点が入るかを確認した。

注意: source09は current_result valid277 には入っていないため、本作業はP/M評価ではなく、採用スコープのインベントリ確認である。

## 入力

- raw Table10 all-source records: `/mnt/data/TM03H3_Table10_raw_quality_scope/TM03H3_Table10_raw_quality_scope_20260629_151620_raw_records_with_scope_tags.csv`
- Weatherhead to T&M source09 mapping: `/mnt/data/TM03G_weatherhead_coverage/TM03G_weatherhead_to_TM_source09_mapping_20260629_054300.csv`
- current_result source09 coverage: `/mnt/data/TM03G_weatherhead_coverage/TM03G_weatherhead_current_result_coverage_20260629_054300.csv`

## B基準

all-source rawに対しては、以下をB-like lowXとして定義した。

```text
lowX: x <= 0.05
G upper: G <= 4200 kg/m2/s
L/D lower: L/D >= 40
```

参考として、PWR代表Gに近い側を見るため、`1900 <= G <= 4200` も別枠で出した。

## mapping / current_result確認

```text
source09 / ANL mapping rows = 232
MATCH_EXACT = 230
current_result valid277 内 source09 = 0
```

したがって、source09はT&M Table10内には存在するが、現在のcurrent_resultには未投入である。

## source09結果

```text
source09 all = 232
source09 lowX x<=0.05 = 117
source09 B-like lowX = 117
source09 B-like lowX and 1900<=G<=4200 = 40
```

source09は、lowX点についてはすべて `G<=4200` かつ `L/D>=40` を満たす。
したがって、source01で得たB基準を機械的に当てると、source09 lowX 117点はすべて主候補に入る。

ただし、G分布はsource01 Bとはかなり異なる。

```text
source01 B-like lowX:
  N = 113
  G mean = 2469.820 kg/m2/s
  G median = 2454.030 kg/m2/s
  G<1900 = 38
  1900<=G<=4200 = 75

source09 B-like lowX:
  N = 117
  G mean = 1500.369 kg/m2/s
  G median = 1382.934 kg/m2/s
  G<1900 = 77
  1900<=G<=4200 = 40
```

source09はD径とL/Dの点ではPWR代表径に近い側を含むが、Gは低めが多い。
このため、source09をsource01 Bと同じ主候補として一括比較するより、`G<1900` と `1900<=G<=4200` を分けて見るのが安全である。

## source09の代表値

```text
source09 B-like lowX:
  D = 0.304～0.436 in
  L/D = 41.284～59.211
  Hsub = 143.049～1397.926 kJ/kg
  qCHF(measured) = 1.849～5.363 MW/m2
  x = -0.820～0.048
```

source09 B-like lowXのG帯別点数は以下。

```text
G<1900: 77
1900<=G<=4200: 40
G>4200: 0
```

## 判断

source09は、source01で得たB基準 `G<=4200, L/D>=40` を通すと、lowX 117点がそのまま入る。
これは、B基準がsource09にも機械的には適用可能であることを示す。

ただし、source09はsource01 Bと比べて低G側が多い。
したがって、source09を次に評価するときは、以下の2段で見るのがよい。

```text
source09 lowX B-like all:
  x<=0.05, G<=4200, L/D>=40
  N=117

source09 PWR-G side check:
  x<=0.05, 1900<=G<=4200, L/D>=40
  N=40
```

現時点では、B基準は「別ソースにも使える入口スコープ」として有効そうである。
一方、source09はG分布がsource01と違うため、Bだけで同一母集団とは扱わない。

## 次アクション

次はsource09をcurrent_resultへ投入できるか確認する。
具体的には、source09 lowX 117点のうち、まず `1900<=G<=4200` の40点を優先候補にして、Celata計算が収束するか、P/Mがsource01 BのTsub飽和型整理と同じ方向に出るかを確認する。

ただし、source01で得た係数やL/D補正をsource09に直接当てて結論しない。
最初は、同じB-likeスコープ分類とP/Mの分布確認に留める。
