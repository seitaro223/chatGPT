# H52Q / T&M Table 8〜14

# Tsub/Hsub正規化に進む前の整理

作成日：2026-06-15
位置づけ：MATLAB v6終了後、v7でTsub/Hsub正規化へ進む前の判断メモ

---

## 1. このメモの目的

T&M Table 8〜14の追加データ、およびTable 10を含めた統合診断により、PWR近傍条件でのshort/long差が見えてきた。

ただし、現時点では「長さ効果」または「熱履歴効果」と断定するには早い。

理由は、short側とlong側で入口サブクール条件が大きく異なるためである。

このメモは、次段階でTsubまたはHsubによる正規化・残差診断へ進む前に、現在分かっていること、まだ言えないこと、次に見るべきことを固定するために作成する。

---

## 2. ここまでの作業範囲

ここまでのMATLAB診断では、以下を実施した。

* resultブック内の固定ソース `tm_r123_noF1_T8_14` / `tm_r124_F1_T8_14` をstagingへコピー
* 追加138行の抽出診断
* F1ありなし比較
* Table別・L/D分類別のPM整理
* Table 10を復帰させた統合診断
* 圧力帯をPWR近傍重視に再定義
* Table 10〜12をPWR近傍主解析群として整理

v6時点では、圧力帯を以下のように扱った。

```text
explore_low : 10 <= P < 13 MPa
PWR_near    : 13 <= P <= 17.5 MPa
high_check  : 17.5 < P <= 20 MPa
```

この定義により、PWR近傍主解析群は以下になった。

```text
PWR_near = Table 10 + Table 11 + Table 12
```

Table 13およびTable 14は高圧側チェックとして扱う。

---

## 3. v6までで分かったこと

PWR近傍のTable 10〜12で見ると、F1ありではshort側のPMはおおむね1近傍に整理される。

代表値は以下のとおり。

```text
Table 10 short : PM_F1 ≈ 0.986
Table 11 short : PM_F1 ≈ 1.117
Table 12 short : PM_F1 ≈ 1.135
```

一方、long側はF1ありでもPMが高い。

```text
Table 11 long : PM_F1 ≈ 1.651
Table 12 long : PM_F1 ≈ 1.857
```

したがって、PWR近傍主解析群では、

```text
short側はおおむねPM=1近傍
long側はPMが明確に高い
```

という構図が見えている。

---

## 4. ただし、純粋なL/D効果とはまだ言わない

short側とlong側では、L/Dだけでなく入口サブクール条件が大きく異なる。

v6時点では、便宜的にTinで見ていたが、物理的にはTinそのものではなく、以下を見るべきである。

```text
Tsub = Tsat(P) - Tin
Hsub = hf(P) - hin
```

Tinは圧力が変わると意味が変わるため、最終的な診断軸としては弱い。

ただし、Tinで見た段階でも、short側とlong側の入口条件差が非常に大きいことは確認できた。

特にlong側はTinが約298 Kであり、short側は500 K台である。
したがって、

```text
long側 = 長い + 入口サブクールが大きい
short側 = 短い + 入口サブクールが小さい
```

という条件差が重なっている。

このため、現時点では、

```text
long側のPM高値 = 純粋なL/D効果
```

とは断定しない。

---

## 5. qMでは説明しにくい

一方で、long側のPM高値は、実験熱流束qMが高いことでは説明しにくい。

qMは、PMの定義を

```text
PM = qP / qM
```

とみなし、

```text
qM = qP / PM
```

として復元した。

その結果、PWR近傍のTable 11/12では、long側のqMはshort側より高いわけではなく、むしろ低い。

したがって、

```text
long側のPMが高いのは、実験熱流束qMが高いから
```

という説明は採用しにくい。

---

## 6. Tinベースの暫定残差診断から見えたこと

v6では、暫定的にTinだけでPMを説明した残差も確認した。

その結果、

```text
Table 11：Tinだけで見ると、long側の上振れはほぼ消える
Table 12：Tinだけで見ても、long側に少し正残差が残る
```

という傾向が見えた。

これは、Table 11では入口条件差でかなり説明できる可能性を示す一方、Table 12では入口条件だけでは説明しきれない可能性を示す。

ただし、Tinはあくまで代用指標であるため、この段階で強い結論は出さない。

---

## 7. 次にやるべきこと

次段階では、Tinではなく、TsubまたはHsubで診断する。

目的は、以下を確認することである。

```text
Tsub/Hsubで説明できるPM差をいったん取り除いたあと、
それでもlong側にPM高値が残るか
```

見るべき診断は以下である。

```text
PM_F1 vs Tsub
PM_F1 vs Hsub
PM_F1 vs L/D
Tsub補正後PM残差 vs L/D
Hsub補正後PM残差 vs L/D
Table 11 short-long比較
Table 12 short-long比較
Table 10 short基準との比較
```

ここでlong側の正残差が残れば、

```text
Tsub/Hsub条件だけでは説明しきれず、
長さ・熱履歴効果の可能性が残る
```

と言える。

逆にlong側の差が消えれば、

```text
現在見えているL/D差は、主に入口サブクール条件差だった可能性が高い
```

と整理する。

---

## 8. 現時点の判断文

現時点では、以下のように整理する。

PWR近傍のT&M Table 10〜12において、F1ありでは短管側のPMは概ね1近傍に整理される一方、長管側ではPMが高くなる傾向が確認された。この傾向はTable 11およびTable 12の同一Table内short-long比較でも確認される。ただし、長管側は短管側に比べて入口サブクール条件が大きく異なっており、L/D効果とTsub/Hsub効果が交絡している。qMは長管側で高いわけではないため、長管側PM高値は実験熱流束の高さでは説明しにくい。したがって、次段階ではTsubまたはHsubでPM傾向を正規化し、その後も長管側の正残差が残るかを確認する。

---

## 9. このメモの扱い

このメモは、最終結論ではなく、v7へ進む前の判断ゲートである。

今後、Tsub/Hsub正規化後に判断が変わる可能性がある。

そのため、このメモは以下の位置づけで残す。

```text
採用済み：
- Table 10〜12をPWR近傍主解析群として見る
- Table 13/14は高圧側チェックとして隔離
- qMはlong高PMの主因ではなさそう

保留：
- long側PM高値をL/D効果と呼ぶこと
- Tinベースの残差診断を最終判断に使うこと

次に確認：
- Tsub/Hsubで正規化した後もlong側正残差が残るか
```
---

## 10. v7b：Tsub/Hsub proxy残差診断後の判断更新

作成日：2026-06-15
対象出力：`TM8_14_tsub_residual_v7b_20260615_105448.xlsx`
位置づけ：Tsub/Hsub proxyでPM差を整理した後の判断メモ

---

### 10.1 v7bで確認したこと

v7bでは、PWR近傍主解析群であるT&M Table 10〜12を対象に、TsubおよびHsub proxyを用いたPM残差診断を行った。

ここでのHsub proxyは、真のHsubではなく、以下の暫定量である。

```text
Hsub_proxy = CPL × Tsub
```

したがって、Hsub proxyは入口サブクールのエンタルピー差を近似的に見るための診断量であり、最終的なHsubとは区別して扱う。

---

### 10.2 生のshort-long差

PWR近傍のTable 11およびTable 12では、補正前のPM_F1には明確なshort-long差がある。

```text
Table 11:
  short PM_F1 ≈ 1.117
  long  PM_F1 ≈ 1.651
  long - short ≈ +0.535
  long / short ≈ 1.48

Table 12:
  short PM_F1 ≈ 1.135
  long  PM_F1 ≈ 1.857
  long - short ≈ +0.722
  long / short ≈ 1.64
```

この段階だけを見ると、long側でPMが高く、長さまたは熱履歴効果を疑いたくなる。

ただし、同時にTsubも大きく異なっている。

```text
Table 11:
  short Tsub ≈ 105 K
  long  Tsub ≈ 319 K
  long - short ≈ +214 K

Table 12:
  short Tsub ≈ 106 K
  long  Tsub ≈ 328 K
  long - short ≈ +223 K
```

つまり、long側は長いだけでなく、入口サブクール度が非常に大きい条件である。

---

### 10.3 Tsubでならした後の結果

TsubのみでPM_F1を説明し、その残差を確認した。

```text
Table 11:
  short残差 ≈ -0.001
  long 残差 ≈ -0.013
  long - short ≈ -0.012

Table 12:
  short残差 ≈ +0.015
  long 残差 ≈ +0.170
  long - short ≈ +0.154
```

Table 11では、Tsubでならすとshort-long差はほぼ消える。

これは、Table 11のlong側PM高値が、主にTsub差で説明できる可能性を示す。

一方、Table 12では、Tsubでならした後もlong側に正残差が残る。

ただし、生のPM差 `+0.722` と比べると、Tsub補正後の差 `+0.154` は大きく縮小している。

---

### 10.4 Hsub proxyでならした後の結果

Hsub proxy、すなわち `CPL × Tsub` でPM_F1を説明した場合も確認した。

```text
Table 11:
  short残差 ≈ +0.006
  long 残差 ≈ +0.052
  long - short ≈ +0.046

Table 12:
  short残差 ≈ -0.036
  long 残差 ≈ +0.053
  long - short ≈ +0.089
```

Hsub proxyで見ると、Table 11およびTable 12の両方で、long側に小さな正残差が残る。

ただし、この正残差は生のPM差に比べてかなり小さい。

このため、Hsub proxyで見ても、long側PM高値のかなりの部分は入口サブクール条件で説明される可能性が高い。

---

### 10.5 単純モデルの説明力

PM_F1に対する単純モデルのR²は以下であった。

```text
Tsub only             : R² ≈ 0.813
Hsub_proxy only       : R² ≈ 0.863
L/D only              : R² ≈ 0.831
Tsub + L/D            : R² ≈ 0.873
Hsub_proxy + L/D      : R² ≈ 0.893
Tsub + L/D + xMes + P : R² ≈ 0.903
qM only               : R² ≈ 0.021
```

TsubおよびHsub proxyはPM_F1をかなりよく説明する。

L/Dも高い説明力を持つが、Tsub/Hsub proxyとL/Dは強く共変しているため、L/D単独の物理効果とはまだ判断しない。

また、qMの説明力は非常に低く、long側PM高値を実験熱流束の大きさで説明する見方は弱い。

---

### 10.6 判断の更新

v7b後の判断は以下のように更新する。

PWR近傍のTable 10〜12では、F1ありの場合、short側はPM≈1近傍に整理される一方、long側ではPMが高くなる傾向が確認された。

しかし、TsubまたはHsub proxyで整理すると、long側PM高値のかなりの部分は入口サブクール条件差で説明される。

特にTable 11では、Tsubでならした後にshort-long差はほぼ消える。

Table 12では、Tsub/Hsub proxyでならしてもlong側に正残差が残るが、その大きさは生のPM差に比べてかなり小さい。

したがって、現時点では、

```text
長管側PM高値の主要因は、入口サブクール条件差である可能性が高い。
ただし、Table 12ではTsub/Hsub proxy補正後もlong側に小さな正残差が残るため、長さ・熱履歴効果の可能性は保留として残す。
```

と整理する。

---

### 10.7 採用済み・保留・次に確認すること

#### 採用済み

```text
- Table 10〜12をPWR_near主解析群として扱う。
- Table 13/14は高圧側チェックとして隔離する。
- qMはlong側PM高値の主因ではなさそう。
- Tsub/Hsub proxyはPM_F1の主要な説明軸である。
- 生のPM差だけを見てL/D効果とは言わない。
```

#### 保留

```text
- long側PM高値を純粋なL/D効果と呼ぶこと。
- Hsub proxyを真のHsubとして扱うこと。
- Table 12の正残差を長さ・熱履歴効果と断定すること。
```

#### 次に確認すること

```text
- 真のHsubを元の整形ブックまたは入力ブックから取得できるか。
- Hsub_proxyではなく真のHsubで同じ残差診断を行う。
- Table 12のlong側正残差が真のHsubでも残るか。
- Table 11とTable 12の違いが圧力差、物性差、x_Mes、または装置系列差で説明できるか。
```

---

### 10.8 現時点の安全な記述案

現時点で外部向け・内部向けに安全に書くなら、以下の表現が妥当である。

```text
T&M Table 10〜12のPWR近傍条件では、F1ありの場合、短管側のPMは概ね1近傍に整理される一方、長管側ではPMが高くなる傾向が確認された。ただし、長管側は短管側に比べて入口サブクール度が大きく、L/DとTsub/Hsubが強く交絡している。TsubまたはCPL×TsubによるHsub proxyで整理すると、長管側PM高値の多くは入口サブクール条件差で説明され、Table 11ではshort-long差はほぼ消える。一方、Table 12では補正後もlong側に小さな正残差が残るため、長さ・熱履歴効果の可能性は保留として残す。
```

---

### 10.9 この段階の結論

v7bは、長さ効果を強める結果というより、むしろ以下を示した。

```text
生のPM差は大きい。
しかし、その多くはTsub/Hsub proxyで説明される。
それでもTable 12には少し残差が残る。
```

したがって、次段階では「L/D補正を作る」より先に、真のHsubを用いた再診断を行う必要がある。

この判断をもって、v7bをTsub/Hsub proxy段階の暫定判断として固定する。

---

## 11. v8b：真Hsub残差診断後の判断更新

作成日：2026-06-15
対象出力：`TM8_14_true_hsub_residual_v8b_20260615_130127.xlsx`
位置づけ：Table 10〜12について、真Hsubを用いたPM残差診断を行った後の判断メモ

---

### 11.1 v8bで確認したこと

v8bでは、PWR近傍主解析群であるT&M Table 10〜12を対象に、真Hsubを用いたPM残差診断を行った。

真Hsubは以下のように設定した。

```text
Table 10:
  Table 10原表の INLET SUB COOLING [BTU/lb] を使用
  Hsub_true_kJkg = Hsub_PDF_BTUlb × 2.326

Table 11/12:
  handoffブック `120_MACRO_INPUT_FINAL` の hSub_kJ_kg を使用
```

v7bでは `Hsub_proxy = CPL × Tsub` を用いた暫定診断だったが、v8bではTable 10〜12すべてに真Hsubを付与して再診断した。

---

### 11.2 データ統合の確認

v8bでは、真Hsubの統合は正常に完了した。

```text
結合行数          : 146
PWR_near行数      : 146
Table 10行数      : 86
Table 11行数      : 30
Table 12行数      : 30
真Hsub欠損        : 0
Hsub proxy欠損    : 0
Hsubキー重複      : 0
```

したがって、Table 10のPDF由来Hsub、Table 11/12のhandoff由来Hsubを統合したPWR近傍データとして扱える。

---

### 11.3 真Hsub補正後のshort-long残差

真HsubのみでPM_F1を説明し、その残差をTable 11/12のshort-longで比較した。

```text
Table 11:
  short残差 ≈ -0.018
  long 残差 ≈ +0.016
  long - short ≈ +0.034

Table 12:
  short残差 ≈ -0.017
  long 残差 ≈ +0.184
  long - short ≈ +0.201
```

Table 11では、真Hsubで補正するとshort-long差はかなり小さくなる。
したがって、Table 11のlong側PM高値は、入口サブクール条件差でかなり説明できる可能性が高い。

一方、Table 12では、真Hsubで補正してもlong側に明確な正残差が残る。
この点はv7bのHsub proxy段階よりも、むしろ長さ・熱履歴効果の疑いを少し強める結果である。

---

### 11.4 v7bのHsub proxy診断との比較

v7bでは、`Hsub_proxy = CPL × Tsub` を用いた。
そのときのTable 12のlong-short残差は以下だった。

```text
Hsub proxy補正後:
  Table 12 long - short ≈ +0.089
```

v8bで真Hsubを使うと、以下になった。

```text
真Hsub補正後:
  Table 12 long - short ≈ +0.201
```

つまり、Table 12では、真Hsubを用いた方がlong側正残差が大きく残った。

このため、v7bで見えていたTable 12の残差は、Hsub proxyの粗さによる見かけだけではなかった可能性がある。

---

### 11.5 Hsub proxyと真Hsubの差

v8bでは、Hsub proxyと真Hsubの差も確認した。

```text
T10 short:
  Hsub true平均  ≈ 338 kJ/kg
  Hsub proxy平均 ≈ 469 kJ/kg
  proxy/true     ≈ 1.28

T11 short:
  Hsub true平均  ≈ 590 kJ/kg
  Hsub proxy平均 ≈ 947 kJ/kg
  proxy/true     ≈ 1.59

T11 long:
  Hsub true平均  ≈ 1509 kJ/kg
  Hsub proxy平均 ≈ 2875 kJ/kg
  proxy/true     ≈ 1.91

T12 short:
  Hsub true平均  ≈ 622 kJ/kg
  Hsub proxy平均 ≈ 1187 kJ/kg
  proxy/true     ≈ 1.89

T12 long:
  Hsub true平均  ≈ 1579 kJ/kg
  Hsub proxy平均 ≈ 3684 kJ/kg
  proxy/true     ≈ 2.33
```

`CPL × Tsub` は真Hsubに比べてかなり大きく、特にTable 12 longでは2倍以上になっていた。

したがって、Hsub proxyは入口サブクール条件の方向性を見るには使えるが、定量判断には不十分である。

今後の判断では、Hsub proxyではなく真Hsubを優先する。

---

### 11.6 単純モデルの説明力

PM_F1に対する単純モデルのR²は以下であった。

```text
Hsub true only          : R² ≈ 0.806
Hsub proxy only         : R² ≈ 0.863
Tsub only               : R² ≈ 0.813
L/D only                : R² ≈ 0.831
Hsub true + L/D         : R² ≈ 0.881
Hsub true + L/D + xMes + P : R² ≈ 0.902
qM only                 : R² ≈ 0.021
```

真HsubだけでもPM_F1をかなり説明する。

ただし、真HsubにL/Dを加えると説明力はさらに上がる。

この結果は、入口サブクール条件が主要因である一方、L/Dまたは履歴効果に相当する要素が残っている可能性を示す。

ただし、HsubとL/Dは強く共変しているため、L/Dを独立した物理効果と断定することはまだ避ける。

---

### 11.7 判断の更新

v8b後の判断は以下のように更新する。

PWR近傍のT&M Table 10〜12では、F1ありの場合、short側はPM≈1近傍に整理される一方、long側ではPMが高くなる傾向が確認されている。

真Hsubを用いてPM_F1を整理すると、Table 11ではshort-long差はかなり小さくなり、入口サブクール条件差でおおむね説明できる可能性が高い。

一方、Table 12では、真Hsubで補正した後もlong側に明確な正残差が残る。

したがって、現時点では以下のように整理する。

```text
長管側PM高値の主要因は、入口サブクール条件差である可能性が高い。

ただし、Table 12では真Hsub補正後もlong側に正残差が残るため、入口サブクール条件だけでは説明しきれない長さ・熱履歴効果の可能性は保留として残る。
```

---

### 11.8 採用済み・保留・次に確認すること

#### 採用済み

```text
- Table 10〜12をPWR_near主解析群として扱う。
- Table 10にはPDF原表由来の真Hsubを付与できた。
- Table 11/12にはhandoff由来の真Hsubを付与できた。
- Hsub proxyではなく真Hsubを優先して判断する。
- qMはlong側PM高値の主因ではなさそう。
- 生のPM差だけを見てL/D効果とは言わない。
- Table 11のlong側PM高値は、真Hsubでかなり説明できる。
```

#### 保留

```text
- Table 12の真Hsub補正後の正残差を、長さ・熱履歴効果と断定すること。
- L/Dを独立した補正因子として採用すること。
- Table 13/14を主証拠に使うこと。
```

#### 次に確認すること

```text
- Table 12で真Hsub補正後も正残差が残る理由。
- Table 11とTable 12の違いが、圧力差、物性差、xMes、装置系列差、またはデータ範囲差で説明できるか。
- Hsub true + L/D の係数・残差を確認し、L/Dを入れる意味があるかを見る。
- PWR_near内でTable 10 short基準、Table 11/12 longの差を再整理する。
```

---

### 11.9 現時点の安全な記述案

現時点で安全に書くなら、以下の表現が妥当である。

```text
T&M Table 10〜12のPWR近傍条件では、F1ありの場合、短管側のPMは概ね1近傍に整理される一方、長管側ではPMが高くなる傾向が確認された。ただし、長管側は短管側に比べて入口サブクール度が大きく、L/DとHsubが強く交絡している。Table 10のPDF原表およびTable 11/12の整理済み入力値から真Hsubを付与して再整理したところ、Table 11ではshort-long差はかなり小さくなった。一方、Table 12では真Hsub補正後もlong側に正残差が残った。したがって、長管側PM高値の主要因は入口サブクール条件差である可能性が高いが、Table 12については入口サブクール条件だけでは説明しきれない長さ・熱履歴効果の可能性を保留として残す。
```

---

### 11.10 この段階の結論

v8bは、v7bのHsub proxy段階を真Hsubで更新した診断である。

結論は以下である。

```text
真Hsubで見ても、入口サブクール条件はPM_F1の主要な説明軸である。

Table 11のlong高PMは、真Hsubでかなり説明できる。

Table 12では、真Hsubで補正した後もlong側に正残差が残る。

したがって、長さ・熱履歴効果の可能性はTable 12に限って保留として残す。
```

この判断をもって、v8bを真Hsub段階の暫定判断として固定する。

---

## 12. v9：真Hsub補正後残差の分解診断

作成日：2026-06-15
対象出力：`TM8_14_residual_decomp_v9_20260615_130753.xlsx`
位置づけ：v8bでTable 12 long側に残った真Hsub補正後の正残差について、L/D、P、xMes、Table差のどれで説明されるかを確認した判断メモ

---

### 12.1 v9で確認したこと

v8bでは、PWR近傍のT&M Table 10〜12に真Hsubを付与し、PM_F1を真Hsubで整理した。

その結果、Table 11ではshort-long差はかなり小さくなった一方、Table 12では真Hsubで補正した後もlong側に正残差が残った。

v9では、このTable 12の正残差が、以下のどの要因で説明されるかを確認した。

```text
- L/D
- 圧力 P
- xMes
- Table差
- それらの組合せ
```

目的は、Table 12の残差をすぐに補正式へ進めることではなく、まず「何を入れると残差が減るのか」を診断することである。

---

### 12.2 モデル比較

PM_F1に対する単純モデルのR²は以下であった。

```text
Hsub only                 : R² ≈ 0.806
Hsub + L/D                : R² ≈ 0.881
Hsub + P                  : R² ≈ 0.814
Hsub + xMes               : R² ≈ 0.855
Hsub + L/D + P            : R² ≈ 0.896
Hsub + L/D + xMes         : R² ≈ 0.890
Hsub + L/D + xMes + P     : R² ≈ 0.902
Hsub + Table dummy        : R² ≈ 0.815
Hsub + L/D + Table dummy  : R² ≈ 0.897
```

HsubのみでもPM_F1をかなり説明するが、HsubにL/Dを加えると説明力は大きく改善した。

一方、HsubにPだけを加えても改善は小さかった。
xMesを加えた場合は中程度の改善であった。
Table dummyのみを加えた場合も改善は小さかった。

したがって、今回のデータでは、Table 12の残差はPやTable差よりも、L/Dを入れたときに大きく減る。

---

### 12.3 Table 12のshort-long残差差

Table 12のlong-short残差差は、モデルごとに以下のように変化した。

```text
Hsub only             : +0.201
Hsub + P              : +0.239
Hsub + xMes           : +0.108
Hsub + L/D            : +0.048
Hsub + L/D + xMes     : +0.044
Hsub + L/D + P        : +0.091
Hsub + L/D + xMes + P : +0.091
```

HsubのみではTable 12 long側に+0.201程度の正残差が残った。

Pを加えても残差は小さくならなかった。
xMesを加えるとある程度小さくなった。
一方、L/Dを加えると、残差差は+0.048程度まで大きく低下した。

このため、Table 12の真Hsub補正後の正残差は、PやxMesよりも、L/Dを含めることで大きく低減される。

---

### 12.4 Table 11との違い

Table 11では、Hsubのみでshort-long残差差はすでに小さかった。

```text
Table 11:
  Hsub only      : +0.034
  Hsub + L/D     : -0.129
  Hsub + xMes    : -0.048
  Hsub + P       : +0.071
```

Table 11では、真Hsubのみでlong側PM高値はかなり説明できている。

そのため、L/Dを追加すると、long側をやや下げすぎるようにも見える。

したがって、Table 11とTable 12は同じ扱いにできない。

```text
Table 11：Hsubだけでほぼ説明できる
Table 12：Hsubだけでは不足し、L/Dを入れると残差が小さくなる
```

という整理が妥当である。

---

### 12.5 Table 11 long と Table 12 long の比較

Table 11 longとTable 12 longを比較すると、Table 12 longの方がPM_F1は高い。

```text
T12 long - T11 long:
  PM_F1差  ≈ +0.206
  Hsub差   ≈ +70 kJ/kg
  P差      ≈ +1.72 MPa
  xMes差   ≈ -0.035
```

各モデルで補正しても、Table 12 longはTable 11 longより高めに残る傾向がある。

このため、Table 12 longには、Hsubだけではなく、Table 11 longとの差を生む何らかの条件差が残っている可能性がある。

ただし、現段階では、それを圧力差、物性差、L/D効果、装置系列差、データ範囲差のどれかに断定しない。

---

### 12.6 L/D係数の扱い

Hsub + L/Dモデルでは、L/D項を入れることで説明力が明確に改善した。

ただし、現在のT&M Table 10〜12データでは、L/Dは連続的に広く分布しているというより、実質的にshort_anchor群とlong群の二群を表している。

そのため、ここで得られるL/D係数は、連続的なL/D補正式としてそのまま使うべきではない。

現時点では、

```text
L/D項 = short/long群差または熱履歴差を表す診断項
```

として扱う。

---

### 12.7 判断の更新

v9後の判断は以下のように更新する。

```text
真HsubはPM_F1の主要説明軸である。

ただし、Table 12 long側には、真Hsubだけでは説明しきれない正残差が残る。

この正残差は、PやxMesよりもL/Dを含めたときに大きく低減する。

したがって、Table 12では、入口サブクール条件だけでは説明しきれない長さ・熱履歴に関係する成分が残っている可能性がある。
```

一方で、Table 11では真Hsubだけでshort-long差がほぼ説明できるため、L/D効果をTable 10〜12全体に一律に適用するのはまだ早い。

---

### 12.8 採用済み・保留・次に確認すること

#### 採用済み

```text
- 真HsubはPM_F1の主要説明軸である。
- Table 12 long側の真Hsub補正後正残差は、P単独では説明しにくい。
- Table 12 long側の正残差は、L/Dを含めると大きく低減する。
- L/D項は補正式ではなく、現段階では診断項として扱う。
```

#### 保留

```text
- L/Dを独立した補正因子として採用すること。
- Table 12の正残差を長さ・熱履歴効果と断定すること。
- Table 11とTable 12を同一のL/D補正で扱うこと。
```

#### 次に確認すること

```text
- 10〜12 MPa側、すなわち explore_low 側を入れたときに、Hsub補正後残差とL/Dの関係が同じ方向に出るか。
- Table 8 middleを入れたとき、short → middle → long の順に残差傾向が出るか。
- explore_lowとPWR_nearで傾向が一致するか。
- 傾向が一致する場合のみ、L/Dまたは熱履歴補正式候補へ進む。
```

---

### 12.9 現時点の安全な記述案

現時点で安全に書くなら、以下の表現が妥当である。

```text
真Hsubを用いてPWR近傍のT&M Table 10〜12を再整理したところ、PM_F1はHsubに強く依存した。一方、Table 12のlong側にはHsubのみでは説明しきれない正残差が残った。この残差は、PやTable差を加えても大きくは低減しなかったが、L/Dを加えることで大きく低減した。これは、入口サブクール条件だけでは説明しきれない長さ・熱履歴に関係する成分が残っている可能性を示す。ただし、現在のデータではL/Dはshort/long群差を代表している可能性があり、連続的なL/D補正式として扱うには追加検証が必要である。
```

---

### 12.10 この段階の結論

v9は、Table 12に残った真Hsub補正後の正残差を分解する診断である。

結論は以下である。

```text
Table 12 long側の正残差は、Hsubだけでは説明できない。
PやTable差では十分に説明できない。
L/Dを入れると大きく低減する。
ただし、L/Dはまだ補正式ではなく診断項である。
```

したがって、次段階では、いきなり補正式候補へ進まず、10〜12 MPaのexplore_lowデータを追加して、Hsub補正後残差とL/Dの関係が同じ方向に出るかを確認する。

---

## 13. v10：explore_low（10〜13 MPa）を含めた真Hsub残差診断

作成日：2026-06-15
対象出力：`TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx`
位置づけ：PWR_nearで見えたHsub補正後のL/D方向残差が、10〜13 MPa側でも同じ方向に出るかを確認した判断メモ

---

### 13.1 v10で確認したこと

v9では、PWR近傍のTable 10〜12において、Table 12 long側に真Hsub補正後も正残差が残ることを確認した。

また、その残差はPやTable差よりも、L/Dを入れたときに大きく低減した。

ただし、v9時点ではL/Dを補正式候補とするには早く、10〜13 MPa側、すなわち explore_low 側を入れて、同じ方向の傾向が出るかを確認する必要があると判断した。

v10では、以下を対象にした。

```text
explore_low:
  Table 8 + Table 9
  10 <= P < 13 MPa

PWR_near:
  Table 10 + Table 11 + Table 12
  13 <= P <= 17.5 MPa
```

目的は、以下を確認することであった。

```text
PWR_nearで見えた
  Hsub補正後にlong側が上に残る傾向
が、explore_lowでも再現するか。

特にTable 8 middleを含めることで、
  short → middle → long
のようなL/D方向の傾向が見えるか。
```

---

### 13.2 データ統合の確認

v10では、Table 8〜12に真Hsubを統合した。

```text
結合行数                  : 192
target rows Table8〜12     : 192
explore_low Table8/9       : 46
PWR_near Table10/11/12     : 146
真Hsub欠損                : 0
Hsubキー重複              : 0
```

Table 8/9にも真Hsubを付与できており、explore_lowとPWR_nearを同じ真Hsub軸で比較できる状態になった。

---

### 13.3 PWR_near側の確認

PWR_near、すなわちTable 10〜12では、v8b/v9と同じ方向の傾向が維持された。

Hsub-only補正後の残差平均は以下であった。

```text
PWR_near Table10〜12:

short:
  残差 ≈ -0.014

long:
  残差 ≈ +0.100

long - short:
  ≈ +0.114
```

したがって、PWR_nearだけで見れば、

```text
真Hsubで補正してもlong側が上に残る
```

という傾向は維持されている。

これはv8b/v9の判断と整合する。

---

### 13.4 explore_low側の確認

一方、explore_low、すなわちTable 8/9では、PWR_nearと同じL/D方向の傾向は再現しなかった。

Hsub-only補正後の残差平均は以下であった。

```text
explore_low Table8/9:

short:
  残差 ≈ +0.124

middle:
  残差 ≈ -0.165

long:
  残差 ≈ +0.005

long - short:
  ≈ -0.120

middle - short:
  ≈ -0.290
```

この結果は、期待していた

```text
short → middle → long
```

の順に残差が上がる形ではない。

むしろ、explore_lowでは以下の構図である。

```text
Table 9 short  : 高め
Table 8 middle : 低め
Table 9 long   : ほぼゼロ
```

したがって、10〜13 MPa側を含めると、PWR_nearで見えたL/D方向の残差傾向は一貫しない。

---

### 13.5 Table 8 middleの意味

v10で特に重要なのは、Table 8 middleの位置である。

```text
T9 short:
  PM_F1 ≈ 1.096
  Hsub補正後残差 ≈ +0.124

T8 middle:
  PM_F1 ≈ 0.738
  Hsub補正後残差 ≈ -0.165

T9 long:
  PM_F1 ≈ 1.389
  Hsub補正後残差 ≈ +0.005
```

Table 8 middleは、L/Dとしてはshortとlongの中間にある。

しかし、Hsub補正後残差は中間に来ていない。
むしろ、shortおよびlongより低側に外れている。

このため、少なくともexplore_lowでは、

```text
L/Dが大きいほど、Hsub補正後のPM残差が上がる
```

という単純な関係は支持されない。

---

### 13.6 モデル説明力の違い

v10では、explore_lowとPWR_nearで、PM_F1に効く説明変数の傾向も異なっていた。

explore_lowでは、モデル説明力は以下のようであった。

```text
explore_low Table8/9:

Hsub only         : R² ≈ 0.544
Hsub + L/D        : R² ≈ 0.620
Hsub + P          : R² ≈ 0.824
Hsub + xMes       : R² ≈ 0.916
Hsub + L/D+xMes+P : R² ≈ 0.945
```

PWR_nearではL/Dを加える効果が目立ったが、explore_lowでは、L/DよりもPやxMesを加えたときの改善が大きい。

したがって、explore_low側では、

```text
Hsub補正後の残差は、L/DよりもPやxMesに強く関係している可能性が高い
```

と見るべきである。

---

### 13.7 v9判断への影響

v9では、Table 12 long側の真Hsub補正後正残差がL/Dを入れることで大きく低減することを確認した。

しかし、v10でexplore_lowを加えると、そのL/D方向の傾向は全圧力帯で一貫しなかった。

このため、v9の判断は以下のように限定して扱う必要がある。

```text
v9のL/D項の有効性は、PWR_near、とくにTable 12に対する診断としては意味がある。

しかし、Table 8/9を含む10〜13 MPa側まで含めると、
L/D方向の残差傾向は一貫しない。

したがって、L/D項を全体補正式候補へ進める根拠はまだ不足している。
```

---

### 13.8 判断の更新

v10後の判断は以下である。

```text
PWR_near Table10〜12では、真Hsub補正後もlong側に正残差が残る。

しかし、explore_low Table8/9を入れると、Hsub補正後残差は同じL/D方向には並ばない。

特にTable8 middleは、shortとlongの中間ではなく低側に外れる。

したがって、L/D項を全体補正式候補に進める根拠はまだ不足している。
```

現時点では、L/Dまたは熱履歴効果の可能性は以下のように扱う。

```text
PWR_near、とくにTable12では、L/Dまたは熱履歴効果の可能性は残る。

しかし、10〜13 MPa側を含めると傾向は一貫しない。

したがって、L/Dは補正式候補ではなく、診断項として保留する。
```

---

### 13.9 採用済み・保留・次に確認すること

#### 採用済み

```text
- Table 8/9にも真Hsubを付与できた。
- explore_lowとPWR_nearを同じ真Hsub軸で比較できる。
- PWR_nearでは、Hsub補正後もlong側が上に残る傾向は維持される。
- explore_lowでは、同じL/D方向の傾向は再現しない。
- Table8 middleは、L/D中間にもかかわらずHsub補正後残差が低い。
- L/D項は現時点では補正式候補ではなく診断項として扱う。
```

#### 保留

```text
- L/Dを全圧力帯に共通する補正因子として採用すること。
- Table12の正残差を純粋な長さ効果と断定すること。
- explore_lowとPWR_nearを同一の補正式で扱うこと。
```

#### 次に確認すること

```text
- explore_lowでTable8 middleが低く出る理由。
- Table8とTable9の違いが、P、xMes、Hsub、qM、F1影響、装置系列差で説明できるか。
- PWR_nearのTable12固有性と、explore_lowのTable8 middle低下が同じ枠組みで説明できるか。
- 補正式候補へ進む前に、L/D仮説をいったん弱め、圧力帯依存・xMes依存・Table差を切り分ける。
```

---

### 13.10 現時点の安全な記述案

現時点で安全に書くなら、以下の表現が妥当である。

```text
PWR近傍のTable 10〜12では、真Hsubで補正した後もlong側に正残差が残り、とくにTable 12ではL/Dを含めることで残差が大きく低減した。一方、10〜13 MPa側のTable 8/9を含めると、Hsub補正後残差は同じL/D方向には並ばなかった。特にTable 8 middleはL/Dとしては中間にあるにもかかわらず、Hsub補正後残差は低側に外れた。したがって、L/Dまたは熱履歴効果の可能性はPWR近傍、とくにTable 12では保留として残るが、現時点でL/Dを全体補正式候補として採用するのは早い。
```

---

### 13.11 この段階の結論

v10は、v9で見えたL/D診断項の妥当性を、10〜13 MPa側に広げて確認した診断である。

結論は以下である。

```text
PWR_nearでは、Hsub補正後もlong側に正残差が残る。

しかし、explore_lowでは、同じL/D方向の傾向は再現しない。

Table8 middleは、L/D中間にもかかわらず低側に外れる。

したがって、L/Dはまだ補正式候補ではなく、診断項として保留する。
```

次段階では、Table8 middleが低く出る理由を確認し、explore_lowにおいてP、xMes、Table差、F1影響のどれが支配的かを切り分ける。

---

## 14. v11：Table8 middle低下の理由分解

作成日：2026-06-15
対象出力：`TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx`
位置づけ：v10で確認されたTable8 middle低下について、P、xMes、Hsub、qM、F1影響、Table差のどれで説明できるかを確認した判断メモ

---

### 14.1 v11で確認したこと

v10では、explore_low、すなわちTable 8/9を含めると、PWR_nearで見えたL/D方向の残差傾向が再現しないことを確認した。

特にTable8 middleは、L/Dとしてはshortとlongの中間にあるにもかかわらず、Hsub補正後残差が低側に外れた。

v11では、このTable8 middle低下が何によって説明されるかを確認した。

確認対象は以下である。

```text
- P
- xMes
- Hsub true
- qM
- F1影響
- Table8固有差
```

目的は、Table8 middleの低下をL/D効果の反証として扱う前に、そもそもTable8 middleがTable9と同じ条件領域にあるのかを確認することである。

---

### 14.2 Table8 middleは明確に低い

explore_low内の代表群のPM_F1平均は以下であった。

```text
Table9 short:
  N = 21
  PM_F1 ≈ 1.096

Table8 middle:
  N = 16
  PM_F1 ≈ 0.738

Table9 long:
  N = 9
  PM_F1 ≈ 1.389
```

Table8 middleは、Table9 shortより約0.36低く、Table9 longより約0.65低い。

したがって、v10で確認された

```text
Table8 middleが低い
```

という傾向自体は明確である。

---

### 14.3 Table8 middleとTable9は条件がかなり違う

Table8 middleとTable9全体を比較すると、以下の差があった。

```text
Table8 middle - Table9 all:

PM_F1 : 約 -0.446
Hsub  : 約 -392 kJ/kg
P     : 約 -1.02 MPa
xMes  : 約 +0.271
qM    : 約 -2.22 MW/m2
L/D   : ほぼ同程度
```

この結果から、Table8 middleはTable9と単にL/Dだけが違う系列ではない。

Table8 middleは、Table9に比べて、

```text
- 圧力が低い
- Hsubが小さい
- xMesがかなり高い
- qMが低い
```

という状態点にある。

特にxMesの差が大きい。

したがって、Table8 middleの低下は、

```text
L/Dが中間なのに低い
```

というより、

```text
Table9とはかなり違う状態点にいる
```

と見る方が自然である。

---

### 14.4 モデル比較

PM_F1に対するモデル説明力は以下であった。

```text
Hsub only                    : R² ≈ 0.544
Hsub + P                     : R² ≈ 0.824
Hsub + xMes                  : R² ≈ 0.916
Hsub + P + xMes              : R² ≈ 0.922
Hsub + P + xMes + qM         : R² ≈ 0.967
Hsub + P + xMes + Table8     : R² ≈ 0.922
```

HsubのみではTable8/9の違いを十分に説明できない。

一方で、xMesを加えると説明力が大きく上がる。
Pを加えても説明力は改善する。
qMを加えるとさらにR²は上がる。

ただし、PとxMesを入れた後にTable8 dummyを加えても、R²はほとんど変わらなかった。

```text
Hsub + P + xMes          : R² ≈ 0.922
Hsub + P + xMes + isT8   : R² ≈ 0.922
```

したがって、Table8 middleの低下は、Table8固有差というより、Table8が持つP・xMes条件の違いで説明される可能性が高い。

---

### 14.5 F1影響の確認

F1ありなしを見ると、Table8 middleはF1によってむしろPMが上がっている。

```text
Table9 short:
  PM_noF1 ≈ 0.928
  PM_F1   ≈ 1.096
  F1上昇  ≈ +0.168

Table8 middle:
  PM_noF1 ≈ 0.548
  PM_F1   ≈ 0.738
  F1上昇  ≈ +0.190

Table9 long:
  PM_noF1 ≈ 1.390
  PM_F1   ≈ 1.389
  F1影響  ≈ 0
```

Table8 middleは、F1によって約+0.19上昇している。
それでもPM_F1が低い。

したがって、

```text
Table8 middleが低いのはF1補正のせい
```

とは言いにくい。

むしろF1は、Table8 middleの低さを少し緩和している。

---

### 14.6 qMの扱い

qMを入れるとモデル説明力はさらに上がった。

```text
Hsub + P + xMes      : R² ≈ 0.922
Hsub + P + xMes + qM : R² ≈ 0.967
```

したがって、qMもPM_F1の整理に情報を持っている。

ただし、qMはHsub、xMes、Pと相互に関係している可能性があり、係数の物理的意味をこの段階で強く読むのは危うい。

現時点では、

```text
qMも残差整理には効くが、Table8 middle低下の主因とは断定しない
```

と扱う。

主たる説明軸としては、まずxMesとPを見る。

---

### 14.7 近傍マッチングの読み方

Table8 middleをTable9の近い点と比較する近傍マッチングも行った。

Hsub、P、xMesで近いTable9点と比較しても、Table8 middleはTable9より低めに残った。

```text
Hsub/P/xMes近傍マッチ後:
  Table8 middle - Table9 ≈ -0.385
```

ただし、この結果は強い証拠としては扱いにくい。

理由は、近傍マッチングの距離が大きく、xMes差も残っているためである。

```text
Mean distance ≈ 2.69
Mean ΔxMes   ≈ +0.234
```

つまり、Table8 middleに本当に近いTable9の比較点が十分に存在していない。

このため、近傍マッチング結果は、

```text
同じ条件で比べてもTable8が低い
```

というより、

```text
Table8 middleはTable9とは違う条件領域にあり、きれいに対応する比較相手が少ない
```

と読むべきである。

---

### 14.8 判断の更新

v11後の判断は以下である。

```text
Table8 middleの低さは、単純なL/D効果ではない。

Hsubだけでは説明できないが、xMesとPを入れるとかなり説明できる。

P/xMesを入れた後にTable8 dummyを追加しても、説明力はほとんど改善しない。

したがって、Table8 middle低下は、Table8固有差というより、xMesが高い・圧力が低いという状態点の違いで説明される可能性が高い。
```

この結果により、v10の判断は以下のように補足される。

```text
explore_lowでL/D方向の傾向が再現しなかった理由は、
L/D効果が存在しないからと直ちに言えるわけではない。

Table8 middleがTable9とはP・xMes条件の異なる領域にあり、
L/D検証用の中間点として単純には使えないためである。
```

---

### 14.9 PWR_near Table12との関係

v11の結果は、PWR_near Table12で見えたL/Dまたは熱履歴効果の可能性を完全に否定するものではない。

整理すると以下である。

```text
PWR_near Table12:
  真Hsub補正後もlong側に正残差が残る。
  L/Dを入れると残差が小さくなる。

explore_low Table8/9:
  L/D方向の残差傾向は再現しない。
  ただし、Table8 middleはP・xMes条件がTable9とかなり違う。
```

したがって、現時点では以下の判断が安全である。

```text
PWR_near Table12では、L/Dまたは熱履歴効果の可能性は保留として残る。

一方、explore_low Table8/9は、P・xMes条件差が大きく、
L/D補正式の支持または反証データとして単純には使えない。
```

---

### 14.10 採用済み・保留・次に確認すること

#### 採用済み

```text
- Table8 middleはPM_F1が低い。
- Table8 middleはTable9とはP、Hsub、xMes、qMが大きく異なる。
- Table8 middle低下は、Hsubだけでは説明しきれない。
- xMesとPを入れると、explore_low内のPM_F1はかなり説明できる。
- P/xMesを入れた後にTable8 dummyを追加しても、説明力はほとんど改善しない。
- F1はTable8 middleを低くしているのではなく、むしろ少し上げている。
```

#### 保留

```text
- Table8 middle低下をTable8固有差と断定すること。
- Table8 middle低下をL/D効果の反証として扱うこと。
- qMを主因として扱うこと。
- explore_lowをPWR_nearと同じ補正式候補に混ぜること。
```

#### 次に確認すること

```text
- PWR_near Table12の正残差を、Table8 middle低下とは別問題として扱うか。
- explore_lowは補正式検証ではなく、xMes/P依存の診断データとして扱うか。
- 補正式候補に進む前に、PWR_near限定の診断とexplore_low診断を分けて整理する。
```

---

### 14.11 現時点の安全な記述案

現時点で安全に書くなら、以下の表現が妥当である。

```text
10〜13 MPa側のTable 8/9を含めると、Hsub補正後残差はPWR近傍で見えたL/D方向には並ばなかった。特にTable 8 middleはL/Dとしては中間にあるにもかかわらず、PM_F1およびHsub補正後残差が低側に外れた。ただし、Table 8 middleはTable 9と比べて圧力が低く、xMesが高く、HsubやqMも大きく異なる。モデル比較では、Hsubのみでは不十分だが、xMesおよびPを加えるとexplore_low内のPM_F1はかなり説明され、P/xMesを入れた後にTable8 dummyを加えても説明力はほとんど改善しなかった。したがって、Table8 middle低下はTable8固有差というより、xMesおよび圧力条件の違いで説明される可能性が高い。explore_lowはL/D補正式の支持または反証データとして単純には扱わず、PWR近傍Table12の残差とは分けて整理する。
```

---

### 14.12 この段階の結論

v11は、v10で確認されたTable8 middle低下の理由を分解した診断である。

結論は以下である。

```text
Table8 middleは明確に低い。

しかし、その低さはL/Dではなく、xMesとPの違いでかなり説明できる。

Table8固有差やF1影響が主因とは言いにくい。

explore_low Table8/9は、L/D検証データとしては条件差が強すぎる。
```

したがって、次段階では、PWR_near Table12に残る正残差と、explore_low Table8/9のxMes/P依存を分けて扱う。

## 15. v12〜v15：Table8/9/11/12のHsub正規化後残差診断ゲートの仮閉じ

### 15.1 この追記の位置づけ

v8b〜v11までで、Table10〜12の真Hsubを使った残差診断、およびTable8/9を含むexplore_low側の確認を行った。
その後、v12〜v15では、主に「Table8/9/11/12をどこまでL/D効果の検証に使ってよいか」を判断するためのゲートrunを行った。

ここでの目的は、補正式を作ることではなく、次の判断を固定することであった。

* Table8 middleをL/D中間点として扱ってよいか
* Table9をsource01のPWR下限側チェックとして戻せるか
* Table12 longに残る正残差を、source01全体に共通するL/D効果として見てよいか
* qMを補正式候補に使ってよいか
* T&M数値診断をいったん閉じ、source01原本確認フェーズに移るべきか

結論として、この段階では **L/D補正式を作らない**。
T&M Table8〜12の数値診断ゲートはいったん仮閉じし、次はsource01原本確認フェーズに移る。

---

### 15.2 v12：PWR_nearとexplore_lowを分ける判断

v12では、v10/v11までの結果を使って、PWR_near Table10〜12とexplore_low Table8/9を同じ補正式候補に混ぜてよいかを判断した。

主な結果は以下。

* PWR_nearでは、Hsub-only補正後もlong側に正残差が残る。

  * PWR_nearのHsub-only補正後 long-short 残差差：+0.114
* 一方、explore_lowでは同じ方向には並ばない。

  * explore_lowのHsub-only補正後 long-short 残差差：-0.120
  * explore_lowのHsub-only補正後 middle-short 残差差：-0.290
* Table8 middleはPM_F1が低い。

  * Table8 middle PM_F1：約0.738
  * Table8 middle Hsub-only残差：約-0.165

このため、v12では次の判断に更新した。

* PWR_near Table12の正残差と、explore_low Table8 middle低下は、いったん別問題として扱う。
* explore_low Table8/9は、L/D補正式の支持・反証データとして単純には使わない。
* explore_lowは、xMes/P依存を見る診断データとして扱う。

この時点では、Table8 middle低下について「xMes/Pでかなり説明できる」と見ていた。
ただし、この後のコメントで、Table8はsource03、他はsource01であることが問題になった。

---

### 15.3 v13：Table8 middleはsource03に閉じている

v13では、Table8 middleが低い理由について、P/xMes条件差だけでなく、source差が混じっている可能性を確認した。

結果は明確であった。

* Table8 middleの主source：03
* Table9の主source：01
* PWR_near Table10〜12の主source：01
* source03はTable8だけに閉じている。
* source03はmiddleだけに閉じている。
* source03はexplore_lowだけに閉じている。

つまり、Table8 middleでは、以下が完全に重なっている。

* source差
* Table差
* L/D band差
* P差
* xMes差
* Hsub差
* qM差

このため、Table8 middleは「L/D中間点」として素直に使えない。
Table8 middleが低い原因をsource03と断定することもできないが、少なくともsource差を分離できない。

v13での判断更新は以下。

* Table8 middle低下には、P/xMes条件差に加えて、source差・装置差・整理系列差が混じる可能性がある。
* Table8 middleは、L/D補正式の支持・反証データとして単純には使わない。
* explore_low Table8/9は、PWR_near Table12のL/D/熱履歴保留を否定する材料にはしない。

この時点で、Table8はL/D検証から外す、または参考扱いにする方針が強くなった。

---

### 15.4 v14：PWR_near source01限定でTable12 long正残差を再確認

v14では、Table8/9を外し、PWR_near Table10〜12かつsource01のみに限定して、Table12 long正残差を再整理した。

QCとしては、対象は以下。

* 対象行数：146
* Table10：86行
* Table11：30行
* Table12：30行
* source種類数：1
* 真Hsub欠損：0
* PM_F1欠損：0

主な結果は以下。

モデル説明力：

* Hsub only R2：0.806
* Hsub + L/D R2：0.881
* Hsub + P R2：0.814
* Hsub + xMes R2：0.855
* Hsub + qM R2：0.923
* Hsub + P + xMes + qM R2：0.935
* Hsub + L/D + P + xMes + qM R2：0.935
* Hsub + Table12 dummy R2：0.814
* Hsub + L/D + Table12 dummy R2：0.895

Table12のshort-long差：

* raw PM_F1 long-short：+0.722
* Hsub only residual long-short：+0.201
* Hsub + L/D residual long-short：+0.048
* Hsub + P residual long-short：+0.239
* Hsub + xMes residual long-short：+0.108
* Hsub + qM residual long-short：+0.058
* Hsub + P + xMes + qM residual long-short：+0.095
* Hsub + L/D + P + xMes + qM residual long-short：+0.090

Table11との比較：

* Table11 raw PM_F1 long-short：+0.535
* Table11 Hsub only residual long-short：+0.034
* Table11 Hsub + L/D residual long-short：-0.129
* Table12 long - Table11 long raw PM_F1：+0.206
* Table12 long - Table11 long Hsub only residual：+0.168
* Table12 long - Table11 long Hsub+LD+P+xMes+qM residual：+0.127

v14時点では、HsubだけではTable12 long側に正残差が残り、L/Dを入れるとそれが小さくなることが確認された。
ただし、qMを入れても説明力が大きく上がることが分かった。

ここで重要なコメントがあった。

> qMは結果なので補正には使えない。だから、あまり理由にならないかもしれない。

このコメントは正しい。
qMは実験結果側から復元した量であり、予測式・補正式の入力に使うと循環する。
したがって、qMは補正式候補ではなく、残差が実験熱流束レベルや条件群と連動しているかを見る診断量としてだけ扱う。

v14の判断は以下のように修正する。

* Table12 long正残差は、Hsubだけでは残る。
* L/Dを入れると小さくなる。
* qMでも見かけ上よく整理されるが、qMは結果側の量なので補正式には使えない。
* したがって、qMで説明できることは補正候補ではなく、未説明成分が実験熱流束レベルや条件群と絡んでいる可能性を示す診断結果として扱う。
* L/D補正式はまだ作らない。

---

### 15.5 Table9を戻すべきかというコメント

v14後に、Table9はTable8と異なりsource01なので、入れてもよいのではないかというコメントがあった。

この指摘は妥当である。
v13で問題になったのはTable8がsource03に閉じていることであり、Table9はsource01である。
また、Table9は約12 MPaであり、Table10〜12より少し低いが、極端な低圧ではない。

したがって、Table9の扱いは「低圧データ」と言い切るよりも、次のように整理するのがよい。

* Table8：source03、middleのみ、P/xMes/Hsub/qMも異なるため、L/D検証から外す。
* Table9：source01、約12 MPa、PWR_near下限側に近いチェックデータとして使う。
* Table10〜12：source01、PWR_near主解析群として扱う。

この考えに基づいて、v15ではTable8を外し、source01のTable9〜12を対象とした。

---

### 15.6 v15：source01 Table9〜12でTable9を復帰

v15では、Table8を除外し、source01で揃うTable9〜12を対象にした。
Table9は約12 MPaで、PWR_nearよりやや低いが、PWR下限側に近いsource01チェックとして扱った。

QCとしては、対象は以下。

* 対象行数：176
* Table9：30行
* Table10：86行
* Table11：30行
* Table12：30行
* source種類数：1
* 真Hsub欠損：0
* PM_F1欠損：0

モデル説明力：

* Hsub only R2：0.775
* Hsub + L/D R2：0.816
* Hsub + P R2：0.795
* Hsub + xMes R2：0.802
* Hsub + P + xMes R2：0.827
* Hsub + L/D + P + xMes R2：0.850
* Hsub + Table12 dummy R2：0.792
* Hsub + L/D + Table12 dummy R2：0.842
* Hsub + qM R2 DIAG_ONLY：0.867

qMはここでも効くが、補正式候補ではなく診断量である。

same-table short-long残差：

Table9：

* raw PM_F1 long-short：+0.293
* Hsub only residual long-short：-0.128
* Hsub + L/D residual long-short：-0.235
* Hsub + P residual long-short：-0.109
* Hsub + xMes residual long-short：-0.178
* Hsub + P + xMes residual long-short：-0.161

Table11：

* raw PM_F1 long-short：+0.535
* Hsub only residual long-short：+0.074
* Hsub + L/D residual long-short：-0.017

Table12：

* raw PM_F1 long-short：+0.722
* Hsub only residual long-short：+0.242
* Hsub + L/D residual long-short：+0.159
* Hsub + P residual long-short：+0.265
* Hsub + xMes residual long-short：+0.186
* Hsub + P + xMes residual long-short：+0.207

Table12 longと他longの比較：

* Table12 long - Table9 long Hsub-only residual：+0.368
* Table12 long - Table11 long Hsub-only residual：+0.171
* Table12 long - Table9 long Hsub+P+xMes residual：+0.263
* Table12 long - Table11 long Hsub+P+xMes residual：+0.147

ここで重要なのは、Table9ではHsub補正後にlong側正残差が出ないことである。
raw PM_F1ではTable9もlong側が高いが、HsubでならすとTable9のlong側はむしろ低めに残る。
Table11では小さく正側に残る。
Table12では明確に正側に残る。

このため、source01内で一般的な「long側正残差」が一貫して出るとは言いにくい。

---

### 15.7 v15後の判断

v15後の判断は以下。

* Table8はsource03に閉じているため、L/D検証点として単純には使わない。
* Table9はsource01で約12 MPaなので、PWR下限側チェックとして復帰できる。
* ただし、Table9ではHsub補正後にlong側正残差は出ない。
* Table11では、Hsub補正後long側正残差は小さい。
* Table12では、Hsub補正後long側正残差が明確に残る。
* したがって、T&M内で見えている未説明成分は、source01全体に共通する単純なL/D効果というより、Table12または高圧側PWR_near条件に残る未説明成分として保留する。
* L/D補正式はまだ作らない。
* qMは補正式候補には使わない。診断量としてのみ扱う。

この段階で、「Table12固有差」と断定するのもまだ早い。
Table12は、圧力、物性、xMes、Hsub、熱履歴、L/Dが絡んだ条件群として見る必要がある。

---

### 15.8 仮閉じの理由

ここでT&M Table8〜12の数値診断ゲートはいったん仮閉じする。

理由は、数値診断だけでは、Table12 long正残差の原因をこれ以上一意に分離しにくいからである。

現時点で分かっていることは以下。

* Table8はsource03問題があり、L/D検証から外す。
* Table9はsource01なので戻せるが、Hsub補正後long側正残差は出ない。
* Table11では小さく残る。
* Table12では明確に残る。
* qMは見かけ上効くが、結果側の量なので補正式には使えない。
* L/Dを入れると残差は減るが、純粋なL/D効果とは断定できない。
* Table12または高圧側PWR_near条件に残る未説明成分として保留するのが安全である。

したがって、次の段階は、数値モデルを増やすことではなく、source01原本の確認である。

---

### 15.9 次フェーズ：source01原本確認

01の原本を持っているため、次はsource01原本を確認する。

目的は、Table9/11/12の違いを、原本の実験系列・装置・注記・表構成から確認することである。

特に確認すべき点は以下。

* Table9, Table11, Table12が同じ装置・同じ管径・同じ加熱条件か
* Table12だけ圧力以外に何か系列差があるか
* short/longが本当に同じ系列内の長さ違いか
* inlet subcoolingの定義や測定位置に差がないか
* CHF判定、burnout判定、データ除外、表注に差がないか
* Table12だけデータ範囲や実験条件が偏っていないか
* Table9/11/12で入口条件、出口条件、測定位置、加熱長、流動安定性に違いがないか
* Table12のlong側だけが特別な実験系列になっていないか

この原本確認は、T&M数値診断の続きではあるが、フェーズとしては分ける。

次の作業名は、たとえば以下とする。

* source01原本確認フェーズ
* Table9/11/12系列差確認
* T&M source01 Table12残差の文献側確認

このフェーズで確認した結果を見て、Table12 long正残差を以下のどれとして扱うかを再判断する。

* Table12固有のデータ系列差
* 高圧側PWR_near条件の未説明成分
* L/D/熱履歴効果の可能性
* 原本上の注記・整理差に由来する可能性
* Becker等の追加文献到着後に再検証すべき保留項目

現時点では、補正式化せず、internalの保留課題として残す。

---

### 2026-06-15　H52Q / T&M Table8〜12：x_eq再診断とL/D補正式探索の仮閉じ（v16〜v16c）

#### 背景

前回までに、T&M Table8〜12を使って、短管／長管差、Hsub正規化、Table12 long側残差、Table8 middleの扱いを検討していた。

v15時点では、source01に限定してTable9〜12を見た結果、Table12 longにHsub補正後の正残差が残っていた。そのため、L/D効果、熱履歴効果、圧力・物性効果、Hsub関数形ミス、x_eq未考慮などの可能性を保留していた。

その後、Claudeレビューで以下の指摘を受けた。

* Table9、Table11、Table12のHsub補正後残差が圧力順に並んでいるように見える。
* L/Dを入れると残差が減るのは、long/shortをフラグしているだけの可能性がある。
* Hsub線形モデルの高Hsub端での関数形ミスが残差を作っている可能性がある。
* 残差平均だけでなく、SD、SE、CIを確認する必要がある。
* qMを補正式入力に使わない判断は妥当だが、x_Mesも結果側量なので、補正式候補としてはx_eqで見るべき。

ここで、櫻井コメントとして、x_Mesとx_eqの区別を明確化した。

* x_Mesは結果量なので補正式には使えない。
* 一方、熱平衡クオリティx_eqは、前向き計算で使える量であり、バンドル側でもx_Mesではなくx_eqを用いる。
* したがって、補正式候補として見るべきなのはx_Mesではなくx_eqである。

この整理を受けて、source01原本確認に進む前に、内部QCとしてv16〜v16cを追加した。

#### v16：x_eq診断の準備とHsub関数形確認

v16では、x_eq列を探して再診断する予定だったが、対象データ内にx_eq列が存在しなかったため、x_eq込みのモデルは実行できなかった。

ただし、以下の確認はできた。

* Hsub linear R2 = 0.775
* Hsub quadratic R2 = 0.821
* Hsub cubic R2 = 0.896

また、Hsub linearではTable12 long-short残差が明確に残った。

* Table12 Hsub linear residual delta = +0.242
* SE = 0.041
* CI95 = [0.163, 0.322]

一方、Hsub quadraticではTable12残差が +0.105 まで小さくなった。
このため、Table12 long側の正残差の一部は、Hsub線形近似の高Hsub端における関数形ミスで生じている可能性が出た。

ただし、x_eq列が存在しなかったため、v16単独ではx_eqに関する判断は未完了とした。

#### v16b：resultブックのHG-HLからhlgを読み、x_eqを計算

v16bでは、resultブック `tm_r124_F1_T8_14` シートのAZ列 `HG-HL` を hlg として読み、T&M Table8〜12側に結合した。

計算した量は以下の2つ。

* xeq_qM

  * qMを使って計算した熱平衡クオリティ。
  * 実験DNB点の確認用。
  * qMは結果側量なので、補正式候補には使わない。

* xeq_qP_F1

  * qP_F1を使って計算した熱平衡クオリティ。
  * 予測側・補正候補診断用。
  * 今回のx_eq診断ではこちらを主に使う。

QC結果は良好だった。

* hlg欠損 = 0
* xeq_qM欠損 = 0
* xeq_qP_F1欠損 = 0
* source01 Table9〜12 rows = 176

v16bの主結果は以下。

source01 Table9〜12のモデル説明力：

* Hsub linear R2 = 0.775
* Hsub quadratic R2 = 0.821
* Hsub cubic R2 = 0.896
* Hsub + P + x_eq R2 = 0.907
* Hsub + L/D + P + x_eq R2 = 0.910

same-table short-long residualでは、Table12 long正残差が、Hsub linearでは残るが、Hsub + P + x_eqでは消えた。

* Table12 Hsub linear

  * delta = +0.242
  * CI95 = [0.163, 0.322]

* Table12 Hsub quadratic

  * delta = +0.105
  * CI95 = [0.027, 0.184]

* Table12 Hsub cubic

  * delta = -0.028
  * CI95 = [-0.102, 0.046]

* Table12 Hsub + P + x_eq

  * delta = -0.025
  * CI95 = [-0.079, 0.028]

この結果から、Table12 long正残差は、Hsub線形補正だけでは残るが、Hsub高端の非線形性、P、x_eqを考慮するとほぼ消えることが分かった。

Table8 middleについても確認した。

* Table8 middle - Table9 all PM_F1差 = -0.446
* Table8 middle - Table9 all Hsub + P + x_eq残差差 = -0.002
* Table8/9 Hsub + P + x_eq R2 = 0.833

つまり、Table8 middleの低さも、Hsub + P + x_eqでほぼ説明できる。
ただしTable8はsource03に閉じているため、source01 Table9〜12と同格のL/D検証点として使うのは引き続き避ける。

#### v16c：Table10支配性チェック

v16bではTable10を含むsource01 Table9〜12全体で回帰していた。しかしTable10は86点あり、Table9/11/12の各30点より多い。
そのため、Table10が回帰面を支配してTable12 long正残差を見かけ上消している可能性があった。

v16cでは以下の3条件で確認した。

* A：Table9 + Table10 + Table11 + Table12 全部でfit
* B：Table10を除外してfit
* C：Table別に均等重みでfit

結果として、どの条件でもTable12 long正残差は復活しなかった。

Hsub + P + x_eq のTable12 short-long residual：

* A 全部あり

  * delta = -0.025
  * CI95 = [-0.079, 0.028]

* B Table10除外

  * delta = -0.047
  * CI95 = [-0.095, 0.001]

* C Table均等重み

  * delta = -0.030
  * CI95 = [-0.081, 0.022]

Hsub + L/D + P + x_eq でも、Table12はむしろやや負側になった。

* A 全部あり

  * delta = -0.052
  * CI95 = [-0.104, -0.001]

* B Table10除外

  * delta = -0.033
  * CI95 = [-0.083, 0.016]

* C Table均等重み

  * delta = -0.045
  * CI95 = [-0.096, 0.006]

Table10の残差平均も確認した。

* A 全部あり / Hsub + P + x_eq

  * Table10 mean residual = -0.015
  * SD = 0.078

* C Table均等重み / Hsub + P + x_eq

  * Table10 mean residual = -0.034
  * SD = 0.082

Table10は少し負側だが、大きく外れて回帰面を極端に歪めているとは見えない。

したがって、v16bの「Hsub + P + x_eqでTable12 long正残差が消える」という結果は、Table10の点数支配による見かけではなさそうだと判断した。

#### 解釈の更新

v15時点では、Table12 longにHsub補正後も正残差が残るため、L/D効果または熱履歴効果の可能性を保留していた。

v16〜v16c後の整理は以下。

* Table12 long正残差は、Hsub linearでは明確に見える。
* しかし、Hsub非線形性、P、x_eqを考慮するとほぼ消える。
* Table10を除外しても、Table別均等重みにしても、Table12 long正残差は復活しない。
* したがって、T&M source01 Table9〜12から、新しいL/D補正式を作る根拠は弱い。
* L/Dをさらに入れると、Table12 long側を負側へ下げすぎる可能性がある。
* したがって、L/Dは補正式候補というより、診断項として扱うのが安全。

ここで重要なのは、Hsub + P + x_eqをそのまま補正式として採用するわけではないこと。

Hsub、P、x_eqは独立した3つの補正量というより、情報がかなり重なっている。

* F1はもともとTsubで補正していた。
* HsubはTsubをエンタルピー差で見直したものに近い。
* Pはhfg、物性、飽和温度を通じてHsubやx_eqにも入る。
* x_eqはHsub、P、G、L/D、q、hfgを含む熱収支上の状態量である。

したがって、Hsub + P + x_eqは「補正式」ではなく、「Table12残差がL/D単独ではなく、熱収支・圧力・物性側で説明できる可能性を確認する診断式」として扱う。

#### 現時点の判断

T&M Table8〜12を使ったL/D補正式探索については、ここでいったん仮閉じする。

仮閉じの内容は以下。

* T&M source01 Table9〜12では、Hsub + P + x_eqによりTable12 long正残差はほぼ消える。
* この結果はTable10の点数支配による見かけではなさそう。
* Table8 middleの低さもHsub + P + x_eqでほぼ説明されるが、source03に閉じているため、L/D検証点として単純には使わない。
* T&M単管データから新しいL/D補正式を作る方向はいったん止める。
* ただし、x_eqはF1(Tsub)の物理的意味を見直す候補として、バンドル側の議論に送る。

#### 採用・保留・撤回気味

| 状態   | 内容                                                                     |
| ---- | ---------------------------------------------------------------------- |
| 採用   | T&M Table9〜12のTable12 long正残差は、Hsub linearでは見えるが、Hsub + P + x_eqでほぼ消える |
| 採用   | Table10を除いても、Table別均等重みにしても、Table12 long正残差は復活しない                      |
| 採用   | T&M単管データからL/D補正式を作る根拠は弱い                                               |
| 採用   | Hsub + P + x_eqは補正式ではなく、原因切り分け用の診断式として扱う                               |
| 採用   | qMおよびx_Mesは補正式入力には使わない                                                 |
| 採用   | x_eqは、バンドル側で使える前向き計算量として、F1(Tsub)の代替・説明候補にする                           |
| 保留   | F1(Tsub)を維持するか、将来的にF(x_eq)へ置換するか                                       |
| 保留   | qP側に既に入っているL/D項・長さ補正の有無                                                |
| 保留   | Hsub算出経路の表間整合                                                          |
| 保留   | source01原本で、Table9/10/11/12の装置・系列・表注・条件定義に矛盾がないか                       |
| 撤回気味 | T&M単管データから直接L/D補正式を作る案                                                 |
| 撤回気味 | Table12 long正残差をL/D/熱履歴効果の主証拠として扱う案                                    |

#### 次アクション

1. source01原本確認へ進む。

   ただし目的は、Table12 long正残差の原因探しではなく、Hsub + P + x_eqで整理できるという数値診断が、原本の装置・系列・表注・条件定義と矛盾しないかを確認すること。

2. バンドル側の議論に移る。

   特に以下を確認する。

   * 108が高く、161/164が低い理由は何か。
   * それはF1(Tsub)で説明できているのか。
   * x_eqで見ると整理されるのか。
   * 既存F1(Tsub)を維持するべきか。
   * 将来的にF1(Tsub)をF(x_eq)へ置換するべきか。

3. バンドル議論では、T&M単管の結論をそのまま持ち込まない。

   T&M側の結論は「L/D単独補正は弱い」「x_eqが状態量として有力」という位置づけに留める。
   バンドル側では、F1(Tsub)の意味、x_eq補正候補、108/161/164の計算値差を新しい論点として扱う。

---

### 2026-06-15　BMI-1116原本確認：0.075 in短管・長管系列の扱いと熱履歴仮説の整理

#### 背景

WAPD-188確認により、0.075 in径の短管・長管系列は、WAPD内ではRef.11として整理されており、出典は以下であることを確認していた。

```text
Epstein, H. M., Chastain, J. W., and Fawcett, S. L.,
“Heat Transfer and Burnout to Water at High Sub-critical Pressures,”
BMI-1116, July 20, 1956.
```

その後、BMI-1116原本PDFを入手したため、WAPD-188の再整理情報だけでなく、原報側で以下を確認した。

* 0.075 in短管・長管が同一実験系列として扱われているか
* 装置・管径・材料・流動方向に差があるか
* L/d=80とL/d=365の比較が、純粋な長さ比較として扱えるか
* 著者自身が、L/d、入口サブクール、熱履歴をどう解釈しているか
* T&M単管L/D補正式探索の仮閉じ判断を修正する必要があるか

#### BMI-1116の文献確認

BMI-1116原本のタイトルページで、以下を確認した。

```text
Report No. BMI-1116
Heat Transfer and Burnout to Water at High Subcritical Pressures
Harold M. Epstein
Joel W. Chastain
Sherwood L. Fawcett
July 20, 1956
Battelle Memorial Institute
```

したがって、WAPD-188でRef.11として引用されていた文献は、今回確認したBMI-1116原本と一致する。

#### 装置・試験体の確認

BMI-1116では、試験ループは閉ループの高圧再循環系として説明されている。
試験部は垂直管で、水は上向きに流れる。

試験体については、以下が確認できた。

```text
材料      : Hastelloy C
内径      : 0.075 in
外径      : 0.150 in
流動方向  : 垂直上昇流
加熱方式  : 電気加熱
```

burnout試験では、同じ0.075 in ID管について、以下の2つの長さが使われている。

```text
短管側：
  L = 6 in
  L/d = 80

長管側：
  L = 27.4 in
  L/d = 365
```

したがって、BMI原報レベルでも、短管・長管は以下の点で同一系列として扱える。

```text
同じ文献
同じ装置系
同じ管径
同じ材料
同じ流動方向
同じ加熱方式
```

このため、

```text
短管と長管は全く別装置・別材料・別実験系列なので比較不能
```

という判断にはならない。

これはWAPD-188で見た整理とも整合する。

#### ただし、純粋なL/d比較ではない

一方で、BMI原報を確認すると、L/d=80とL/d=365は、単純な幾何学的長さ違いだけの比較ではない。

表に示されたデータを見ると、L/d=80側では入口温度が比較的高く、L/d=365側では入口温度が70〜80°F程度の点が多い。
これは、長管側が非常に大きい入口サブクール条件で運転されていることを意味する。

これまでのT&M/Hsub診断で見えていた構図、

```text
短管側：
  入口サブクールが比較的小さい

長管側：
  入口サブクールが非常に大きい
```

は、BMI原報の表からも確認できる。

したがって、短管・長管は同一系列として比較可能ではあるが、以下の交絡が強い。

```text
L/d差
入口温度差
入口サブクール差
Hsub差
沸騰開始位置の差
熱履歴差
```

このため、L/d=80とL/d=365の差を、

```text
純粋なL/d効果
```

と読むのは危険である。

#### BMI著者自身の整理

BMI-1116の考察では、著者はJens and Lottes型の式でburnout heat fluxを整理しようとしている。

L/d=365については、burnout heat flux と flow rate の関係が比較的まとまり、単純な流量依存が見えると説明している。

一方、L/d=80については、出口サブクールだけでは十分に整理できず、出口サブクール以外の要因が支配的である可能性を述べている。

さらに、L/d=80とL/d=365を同時に満足する形で整理することは難しい、という趣旨の記述がある。

この点は、これまでの数値診断と重要に対応する。

これまでの数値診断では、Hsub linearではTable12 long側に正残差が残ったが、Hsub非線形性、P、x_eqを考慮すると、その正残差はほぼ消えた。
つまり、単純なL/D補正式というより、入口条件・圧力・熱収支状態量で整理される可能性が見えた。

BMI著者の記述も、単純なL/dだけでなく、入口サブクールや上流側の状態が重要であることを示している。

#### 熱履歴仮説について

BMI原報で特に重要なのは、著者がburnout現象を、単なる局所出口条件やL/dだけでなく、上流側の流れ・熱伝達履歴に依存する可能性があると見ている点である。

BMIでは、L/d=80では管のかなり入口側から壁温が飽和温度以上になるケースが多い一方、L/d=365では壁温が飽和温度以上となる区間が管長の一部に限られる、という趣旨の説明がある。

これは、以下の考え方に近い。

```text
重要なのはL/dそのものではなく、
どこから局所沸騰が始まり、
burnout点までにどれだけの沸騰・熱伝達履歴を持つかである。
```

したがって、BMI原報は、

```text
L/dを完全に無視してよい
```

という資料ではない。

むしろ、

```text
L/dは、沸騰履歴または熱履歴の代理変数として意味を持つ可能性がある。
ただし、L/dそのものを単純な補正式にするのは危うい。
```

という読み方が妥当である。

#### WAPD-188との関係

WAPD-188では、円管データに対して `exp(-0.0012 L/D)` の形でL/D項が相関式に入っていた。

一方で、WAPD-188自身も、正しい履歴変数は単なる入口からburnout点までの長さではなく、局所沸騰開始からburnout点までのboiling lengthかもしれないが、設計相関に採用するには根拠が不足している、という趣旨の記述をしている。

BMI-1116の原報確認により、この見方は補強された。

すなわち、

```text
WAPD-188：
  相関式にはL/Dを入れている。
  ただし、本当はboiling lengthのような履歴変数かもしれないと示唆。

BMI-1116：
  L/d=80と365の差は確認される。
  ただし、入口サブクールや上流熱履歴が重要であり、
  両者を単純に同一式で整理するのは難しい。
```

したがって、WAPDとBMIを合わせると、

```text
L/Dは無関係ではない。
しかし、L/Dそのものが最終的な物理変数とは限らない。
```

という整理が自然である。

#### T&M単管L/D補正式探索への影響

BMI-1116確認後も、T&M単管データから単純なL/D補正式を作る方向は採用しない。

理由は以下。

```text
1. 短管・長管は同一系列として比較できるが、
   入口サブクール条件が大きく違う。

2. BMI著者自身も、L/d=80と365を単純な同一整理式で扱うことに難しさを示している。

3. これまでのv16b/v16cでは、
   Hsub + P + x_eqでTable12 long正残差がほぼ消えた。

4. L/Dをさらに入れると、Table12 long側を下げすぎる可能性がある。

5. したがって、L/Dを直接の補正式として採用すると、
   熱履歴・沸騰開始位置・x_eqなどを幾何長さだけで代理することになり、物理的に粗い。
```

ただし、L/Dまたは加熱長を完全に捨てるわけではない。

```text
L/Dは、熱履歴・沸騰履歴の代理指標として保留する。
```

という扱いに更新する。

#### 判断の更新

v16c後の判断は、

```text
T&M source01 Table9〜12では、Hsub + P + x_eqによりTable12 long正残差はほぼ消える。
このため、T&M単管データから新しいL/D補正式を作る根拠は弱い。
```

であった。

BMI-1116確認後は、以下のように少し補正する。

```text
BMI-1116により、0.075 in短管・長管は同一装置・同一管径・同一Hastelloy C管の比較であることが確認できた。

したがって、短管・長管比較そのものは無意味ではない。

ただし、短管・長管では入口サブクール条件が大きく異なり、純粋なL/d比較にはならない。

また、BMI著者自身も、出口サブクールや流量だけでは整理しきれない要因として、入口サブクールおよび上流の流れ・熱伝達履歴の重要性を示している。

したがって、T&M/BMI単管データから単純なL/D補正式を作る方向は引き続き止める。

一方で、L/dや加熱長を完全に捨てるのではなく、沸騰履歴長、x_eq、局所状態の進み具合としてバンドル側に引き継ぐ。
```

#### 採用・保留・撤回気味

| 状態   | 内容                                                      |
| ---- | ------------------------------------------------------- |
| 採用   | BMI-1116はWAPD-188のRef.11原報である                           |
| 採用   | 0.075 in短管・長管は同一文献・同一装置系・同一管径・同一Hastelloy C・垂直上昇流として扱える |
| 採用   | 短管・長管は全く別系列だから比較不能、とは言わない                               |
| 採用   | ただし、短管・長管では入口サブクール条件が大きく異なり、純粋なL/d比較ではない                |
| 採用   | BMI著者自身も、L/d=80と365を単純な同一整理式で扱うことに難しさを示している             |
| 採用   | L/dは熱履歴・沸騰履歴の代理変数として意味を持つ可能性がある                         |
| 採用   | T&M/BMI単管から直接L/D補正式を作る方向は引き続き止める                        |
| 保留   | 真の履歴変数がL/Dなのか、boiling lengthなのか、x_eqなのか                 |
| 保留   | F1(Tsub)を維持するか、F(x_eq)または履歴長ベースに置換するか                   |
| 保留   | BMIデータの個別点とT&M整理済みデータの完全対応                              |
| 撤回気味 | Table12 long正残差を単純なL/D効果の証拠として扱う案                       |
| 撤回気味 | L/Dを完全に無関係として捨てる案                                       |

#### バンドル議論への引き継ぎ

BMI-1116確認により、バンドル側に進む前の前提は以下のように固定する。

```text
単管T&M/BMIからは、単純なL/D補正式を作る根拠は弱い。

しかし、L/Dまたは加熱長は完全に無関係ではなく、
沸騰開始からDNBまでの履歴を代理している可能性がある。

したがって、バンドル側では、
L/DH補正を作るかどうかではなく、
F1(Tsub)が代表している物理量を、
x_eq、沸騰開始位置、DNBまでの履歴長として見直せるかを論点にする。
```

特に、バンドル108/161/164の議論では、以下を確認する。

```text
1. 108が高く、161/164が低い理由は、単純なL/DH差か。
2. それとも、x_eqやDNB点までの熱収支状態の違いか。
3. F1(Tsub)は入口サブクールだけを補正しているのか。
4. F1(Tsub)が実質的に沸騰履歴やx_eqの代理になっている可能性はあるか。
5. F1(Tsub)をそのまま維持するべきか、F(x_eq)または履歴長ベースへ置換するべきか。
```

#### 次アクション

1. このBMI-1116確認結果をもって、T&M/BMI単管側の原本確認をいったん閉じる。

2. 必要であれば、BMI-1116の個別表とT&M整理済み点の対応確認を追加する。
   ただし、現時点では補正式判断を変えるほどの必要性は高くない。

3. バンドル108/161/164の整理に進む。

   その際、T&M/BMIから持ち込む結論は以下に限定する。

```text
L/D単独補正式は弱い。
ただし、L/Dや加熱長は沸騰履歴の代理として意味を持つ可能性がある。
x_eqや沸騰開始位置を使って、F1(Tsub)の意味を見直す。
```

---

---

### 2026-06-15　BT01：バンドル108/161/164の試作診断と一次読み

#### 背景

T&M/BMI単管側の原本確認およびHsub + P + x_eq診断を踏まえ、単管側から単純なL/D補正式を作る方向はいったん止めた。

一方で、L/Dや加熱長を完全に捨てるのではなく、沸騰履歴・DNB位置までの履歴長・x_eq・F1(Tsub)の意味を、バンドル側で見直すことにした。

その最初の作業として、バンドルデータのうち、特に問題意識の中心である以下3ケースを抜き出して比較した。

```text
108
161
164
```

この作業をBT01とする。

#### BT01の位置づけ

BT01は、ChatGPT側でresultブックから先行的に作成した試作診断である。

位置づけは以下。

```text
BT01 = バンドル108/161/164の試作的な横並び診断
```

正式な研究出力として固定する前に、まず以下を確認するためのものである。

```text
1. 108高・161/164低の傾向が、実験値だけでなく計算値にも出ているか
2. noF1とF1で傾向がどう変わるか
3. F1後に108/161/164のPMがどうなるか
4. x_eq、DNB位置、DNB位置までの履歴長がどう違うか
```

重要な前提は以下。

```text
F2は使わない。
F1F2も使わない。
比較対象は noF1 と F1 のみ。
バンドルでは x_Mes 列に直接 x_eq が入っているため、x_Mes = x_eq として扱う。
```

#### 108高・161/164低は、実験値にも計算値にも出ている

BT01試作のF1後平均値では、実験値は以下であった。

```text
q_exp:
108 = 3.036 MW/m2
161 = 1.414 MW/m2
164 = 1.189 MW/m2
```

F1後の計算値は以下であった。

```text
q_calc_F1:
108 = 3.236 MW/m2
161 = 1.295 MW/m2
164 = 1.067 MW/m2
```

したがって、

```text
108が高く、161/164が低い
```

という大小関係は、実験値だけでなく計算値にも出ている。

これは重要である。

この結果から、現時点では、

```text
Celata計算が108/161/164の大小関係をまったく外している
```

とは言いにくい。

むしろ、

```text
計算値にも実験値にも同じ方向の大小関係は出ている。
ただし、PMのずれが残っている。
```

と見るのがよい。

#### noF1では全体に過小評価

補正なしでは、PMは以下のようであった。

```text
PM_noF1:
108 = 0.622
161 = 0.621
164 = 0.571
```

したがって、noF1では全ケースで過小評価である。

この段階では、F1は全体を持ち上げる補正として作用している。

#### F1後は108がほぼ合い、161/164は低めに残る

F1後のPMは以下であった。

```text
PM_F1:
108 = 1.067
161 = 0.909
164 = 0.892
```

したがって、F1を入れると108はほぼ合う。

一方、161/164はF1後もやや低めに残る。

ここで注意すべきことは、次のように読むべきではないという点である。

```text
F1が161/164を過大評価させている
```

むしろBT01の一次読みは以下である。

```text
F1は108にはよく効いている。
161/164にも効いているが、F1後もやや低めに残る。
したがって、F1だけでは108/161/164の差を完全には整理しきれていない可能性がある。
```

#### x_eqの一次確認

バンドルでは、x_Mes列に直接x_eqが入っているため、BT01ではx_Mesをx_eqとして扱った。

代表値は以下であった。

```text
x_eq:
108 = -0.014
161 = -0.082
164 = -0.155
```

108は最も0に近く、164は最もサブクール側である。

したがって、BT01時点では、

```text
x_eqが高いほどqが低い
```

という単純な関係には見えない。

x_eqは重要な状態量であるが、108/161/164の差をx_eq単独で説明できるかは、この時点では未判断である。

#### DNB位置までの履歴長

BT01で特に重要に見えるのは、DNB位置までの履歴長である。

代表値は以下であった。

```text
z_DNB / DH:
108 = 約140
161 = 約361
164 = 約287
```

この結果から、108と161/164では、DNB位置までの履歴長が大きく異なる。

整理すると以下である。

```text
108：
  DNB位置までの履歴長が短い

161：
  DNB位置までの履歴長が非常に長い

164：
  108よりかなり長い
```

これは、T&M/BMI原本確認で出てきた

```text
L/Dそのものではなく、
沸騰開始からDNB/burnout点までの履歴が重要かもしれない
```

という見方と接続しやすい。

ただし、BT01時点では、DNB位置までの履歴長が原因であるとはまだ断定しない。

#### BT01の一次結論

BT01の一次読みは以下である。

```text
108高・161/164低の方向は、実験値にも計算値にも出ている。

noF1では全ケースで過小評価だが、F1により全体が持ち上がる。

F1後は108がほぼ合い、161/164はやや低めに残る。

したがって、問題は「F1が完全に悪い」というより、
108と161/164で、F1以外の状態量・履歴量が異なる可能性を見るべき段階である。

BT01では、特にDNB位置までの履歴長 z_DNB/DH が大きく異なり、
108は短く、161/164は長い。
```

#### 現時点で言えること

```text
- 108高・161/164低は、実験値だけでなく計算値にも出ている。
- noF1では全体に過小評価である。
- F1後は108がほぼ合い、161/164はやや低めに残る。
- x_eq単独では、108/161/164の大小関係を直ちに説明できるとは言えない。
- DNB位置までの履歴長は、108と161/164で大きく異なる。
```

#### まだ言ってはいけないこと

```text
- 108/161/164の差はL/DH効果である、と断定しない。
- F1を置換すべき、と断定しない。
- x_eqだけで整理できる、と断定しない。
- DNB位置までの履歴長が原因である、と断定しない。
- このBT01試作だけで補正式を作るとは言わない。
```

#### 次アクション

次は、BT01を正式にMATLABで再現するかどうかを判断する。

BT01試作は、ChatGPTがresultブックから先行作成したものであるため、研究ログに正式に残すには、MATLABで再現可能な形にする方が安全である。

したがって、次の作業候補は以下。

```text
STEP 3:
  BT01をMATLABで正式再現する。

目的：
  ChatGPT試作版BT01の抽出条件、列定義、noF1/F1比較、x_Mes=x_eq扱いを固定し、
  run_report_BT01_...md と Excel出力を作る。
```

BT02、すなわちx_eq・履歴長・PM関係の深掘りは、BT01正式再現後に進める。

---

---

### 2026-06-15　BT01解釈の補正：q絶対値とP/Mを分けて読む

#### 背景

BT01の一次読みでは、108高・161/164低という大小関係を中心に整理した。

その後、P/Mの解釈について一時的に混乱があった。

混乱の原因は、F_form修正前後の結果の記憶と、q絶対値の大小関係、P/Mの相対差が混ざったことである。

したがって、BT01正式再現後の読みとして、以下のように整理し直す。

#### 採用する結果

採用するのは、MATLABで正式再現したBT01である。

前提は以下。

```text
F2は使わない。
F1F2も使わない。
比較対象は noF1 と F1 のみ。
バンドルでは x_Mes = x_eq として扱う。
今回は補正式化しない。
```

#### q絶対値の読み

qの絶対値では、108高・161/164低である。

```text
q_exp:
108 = 3.036 MW/m2
161 = 1.414 MW/m2
164 = 1.189 MW/m2

q_calc_F1:
108 = 3.236 MW/m2
161 = 1.295 MW/m2
164 = 1.067 MW/m2
```

したがって、実験値でも計算値でも、108が高く、161/164が低い。

この意味では、Celata計算は、108/161/164の大小関係そのものを大きく外してはいない。

#### P/Mの読み

一方、P/Mを見ると、F1後は以下である。

```text
P/M_F1:
108 = 1.067
161 = 0.909
164 = 0.892
```

したがって、F1後のP/Mについては、以下のように読む。

```text
108：
  ほぼ一致だが、やや過大側

161：
  おおむね一致に近いが、やや過小側

164：
  おおむね一致に近いが、やや過小側
```

つまり、

```text
108は相対的にP/Mが大きい。
161/164は相対的にP/Mが小さい。
```

という読みが妥当である。

ただし、これは

```text
108だけが大きく外れている
```

という意味ではない。

より正確には、

```text
F1後のP/Mは全体として1近傍にあるが、
108は1を少し超え、161/164は1を少し下回る。
```

という状態である。

#### noF1との関係

noF1では、P/Mは以下であった。

```text
P/M_noF1:
108 = 0.622
161 = 0.621
164 = 0.571
```

したがって、noF1では全ケースで過小評価である。

F1は全体を持ち上げる補正として働く。

その結果、

```text
108は1をやや超える。
161/164は1よりやや小さいところに残る。
```

という形になった。

#### 合理的なBT01ストーリー

BT01の合理的なストーリーは以下である。

```text
qの絶対値については、108高・161/164低の傾向が、実験値にも計算値にも出ている。

したがって、Celata計算は大小関係の方向を大きく外していない。

一方でP/Mを見ると、F1後は108がほぼ一致〜やや過大、161/164がやや過小であり、
108のP/Mが相対的に大きい。

したがって、BT02で見るべき問いは、
「なぜ161/164のqが低いのか」だけではなく、
「なぜF1後のP/Mが108では相対的に高く、161/164では低めに残るのか」
である。
```

#### BT02への問いの修正

BT02では、以下を確認する。

```text
1. F1後のP/Mが108で相対的に高い理由は何か。
2. それは x_eq の違いで説明できるか。
3. それは DNB位置までの履歴長 z_DNB/DH の違いで説明できるか。
4. それは z_DNB/L、すなわちDNBが上流寄りか出口寄りかで説明できるか。
5. それは L/DH全体の違いか、それともDNB位置までの実効履歴長の違いか。
6. F1(Tsub)は108/161/164に対して同じ意味で効いているのか。
```

#### 現時点で言ってよいこと

```text
- 108高・161/164低は、q絶対値の話として成立する。
- 108のP/Mが相対的に大きい、というP/M上の特徴も成立する。
- F1後のP/Mは、108がほぼ一致〜やや過大、161/164がやや過小である。
- 108/161/164では、x_eq、z_DNB/DH、z_DNB/L、L/DHが大きく異なる。
- したがって、BT02でそれらとP/Mの関係を見る価値がある。
```

#### まだ言ってはいけないこと

```text
- 108のP/Mが高い原因はx_eqである、と断定しない。
- 108のP/Mが高い原因はDNB履歴長である、と断定しない。
- 161/164のP/Mが低い原因はL/DHである、と断定しない。
- F1を置換すべき、と断定しない。
- BT01だけで補正式候補に進むとは言わない。
```

#### 判断

BT01は、以下の形で閉じる。

```text
BT01では、q絶対値の大小関係として108高・161/164低が、実験値にも計算値にも出ていることを確認した。

また、F1後のP/Mでは、108がほぼ一致〜やや過大、161/164がやや過小であり、
108のP/Mが相対的に大きいことを確認した。

したがって、次のBT02では、
P/Mの相対差を、x_eq、DNB位置、DNB位置までの履歴長、L/DH、F1の効き方から分解する。
```

---

---

### 2026-06-15　BT02解釈の補正：F_form、F1、x_Mesの認識合わせ

#### 背景

BT02では、F1後のP/Mが108で相対的に高く、161/164でやや低めに残る理由を、x_eq、DNB位置、DNB位置までの履歴長、L/DH、F1の効き方から確認しようとした。

その過程で、F_formとF1の意味を混同しかけた。

この混同は重要なので、BT02の解釈に入る前に、以下の認識を固定する。

#### F1とF_formは別物である

F1は、単管データに基づいて作ったTsub補正である。

今回のバンドル検討では、単管基準のTsub補正F1をバンドルへ適用したとき、108/161/164のP/Mがどのように残るかを見る。

一方、F_formはF1ではない。

F_formは、軸方向非一様加熱分布を、DNB位置の局所熱流束基準で一様加熱相当に換算するための係数である。

以前の整理では、DNB位置までの軸方向出力分布の面積そのものをF_formとして扱う方向に寄っていたが、その後、Celataモデルで入力している熱流束がDNB位置の局所熱流束であることを踏まえ、現在は以下のように整理している。

```text
旧F_form：
  DNB位置までの青い面積そのもの

新F_form：
  青い面積 / オレンジ面積

意味：
  DNB位置までの平均的な高さ / DNB位置の高さ
```

したがって、F_formは「F1の効き方」ではなく、非一様加熱分布を局所熱流束基準に直すための形状・面積換算係数である。

#### x_Mesの扱い

バンドル側では、x_Mesは熱平衡クオリティとして扱う。

これはWeisman検討で使っていたCOBRA-ENの局所クオリティとは定義が異なる。

したがって、今回のBT01/BT02では、

```text
x_Mes = x_eq
```

として扱うが、これはCOBRA-ENクオリティをそのまま使っているという意味ではない。

また、x_Mesという名前に引きずられて、実験側だけの結果量として扱いすぎないよう注意する。

バンドル側の整理では、x_Mes列に熱平衡クオリティが入っているため、BT01/BT02ではx_eqとして参照する。

#### BT02の数値結果の読み直し

BT02では、F1後のP/Mは以下であった。

```text
P/M_F1:
108 = 1.067
161 = 0.909
164 = 0.892
```

したがって、F1後のP/Mは、108がほぼ一致〜やや過大、161/164がやや過小である。

また、noF1からF1へのP/M上昇量は以下であった。

```text
P/M上昇量:
108 = +0.445
161 = +0.288
164 = +0.321
```

F1/noF1の倍率は以下であった。

```text
F1/noF1倍率:
108 = 1.765
161 = 1.553
164 = 1.668
```

このため、noF1からF1へ進むと、108のP/Mが相対的に大きくなる。

ただし、これを

```text
F_formが108を強く持ち上げている
```

とは読まない。

正しくは、

```text
単管基準Tsub補正F1を適用した結果として、
108のP/M上昇が161/164より相対的に大きくなった
```

と読む。

#### FcorrとTsub補正の関係

BT02では、F1後のP/MとFcorrの相関は弱かった。

このため、少なくとも108/161/164の群平均差については、Fcorr単独で説明できるとは言いにくい。

ただし、F1はTsubに基づく補正であるため、今後の確認では、Fcorrだけを見るのではなく、以下を分けて見る必要がある。

```text
1. Tsubそのものの分布
2. F1(Tsub)の関数形上の補正倍率
3. 非一様加熱換算であるF_form
4. DNB位置までの履歴長 z_DNB/DH
5. DNB位置の相対位置 z_DNB/L
6. 熱平衡クオリティ x_eq
```

#### F_form相関の読み方

BT02では、F_formとq_exp、q_calc、P/Mの相関も出ている。

しかし、F_formはF1ではない。

したがって、F_formとの相関は、

```text
F1の効き方
```

ではなく、

```text
非一様加熱分布・DNB位置・局所熱流束基準換算と、
q_exp、q_calc、P/Mがどう並んでいるか
```

として読む。

特に、F_formは軸方向出力分布とDNB位置に依存するため、L_DNB、z_DNB/L、L/DH、ケース番号と強く交絡している可能性がある。

したがって、BT02だけで、

```text
F_formが原因である
```

とは言わない。

#### BT02の修正版結論

BT02の修正版結論は以下である。

```text
BT02では、F1後のP/Mが108で相対的に高く、161/164でやや低めに残ることを確認した。

noF1からF1への変化を見ると、108のP/M上昇が相対的に大きい。

ただし、F_formはF1ではなく、軸方向非一様加熱をDNB位置の局所熱流束基準へ換算する係数である。

したがって、F_formとの相関をF1の効き方として読んではいけない。

また、x_Mesは熱平衡クオリティx_eqとして扱うが、COBRA-ENクオリティとは混同しない。

BT02で見えたことは、
108/161/164のP/M相対差が、x_eq単独では説明しにくく、
L/DH、z_DNB/DH、z_DNB/L、F_formなどのケース構造と同時に変化している、
という段階までである。
```

#### 現時点で言ってよいこと

```text
- F1は単管データに基づくTsub補正である。
- F_formはF1ではなく、非一様加熱の局所熱流束基準換算係数である。
- x_Mesはバンドル側では熱平衡クオリティx_eqとして扱う。
- F1後のP/Mは、108が相対的に高く、161/164がやや低い。
- noF1からF1へのP/M上昇は、108で相対的に大きい。
- ただし、F_formやL/DHやz_DNB/DHはケース構造と交絡しているため、原因とは断定しない。
```

#### まだ言ってはいけないこと

```text
- F_formがF1の効き方を表している、と言わない。
- F_formが108高め残差の原因である、と断定しない。
- x_eq単独で108/161/164のP/M差を説明できる、と言わない。
- L/DHまたはz_DNB/DHが原因である、と断定しない。
- BT02だけでF1を置換すべき、と言わない。
```

#### 次アクション

BT03へ進む前に、次の認識を固定する。

```text
F1：
  単管基準のTsub補正

F_form：
  非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数

x_Mes：
  バンドル側では熱平衡クオリティx_eqとして扱う

BT02の主結果：
  F1後のP/Mは108が相対的に高い。
  ただし、その差をF_form、x_eq、L/DH、z_DNB/DHのどれか単独に帰す段階ではない。
```

したがって、次のBT03では、F1(Tsub)そのもの、F_form、z_DNB/DH、z_DNB/L、x_eqを分けて、108高め残差に対する対応関係を再確認する。

---

2026-06-15 ログ管理の立て直し

- 今後の正本は 20260615_H52Q_working_log_r8.md とする。
- claude_review_H52Q_Tsub_residual_r10.md はレビュー依頼用パケットとして凍結する。
- r8 resultブックはレガシー・ブリッジブックとして扱い、直接読み続けない。
- バンドル側は BT00-1 により current_bundle_input を作成済み。
- current_bundle_input には 108/161/164 の noF1/F1 6シートだけを含め、F2/F1F2は含めない。
- 次は BT00-2 current_single_tube_input の設計に進む。

---

### 2026-06-15　BT00-2：current_single_tube_input作成完了

#### 位置づけ

BT00-1でバンドル側の `current_bundle_input` を作成した後、BT00-2として単管側の `current_single_tube_input` を作成した。

目的は、T&M/BMI単管側について、今後どのデータを参照してよいかを固定し、r8 resultブックを直接読み続ける運用から離れることである。

#### 出力

```text
H52Q_current_single_tube_input_v1_20260615_183839.xlsx
run_report_BT00_2_current_single_tube_input_20260615_183839.md
```

#### 入力元

```text
20260612_計算結果比較r8_result_文献追加用.xlsx
TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx
TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx
```

#### 取り込んだ主データ

r8 resultブックから、単管側の現行元データとして以下を取り込んだ。

```text
ST_noF1_T8_14_current
  元シート：tm_r123_noF1_T8_14
  224行 × 70列

ST_F1_T8_14_current
  元シート：tm_r124_F1_T8_14
  224行 × 70列
```

また、v10およびv11の診断ブックから、真Hsub診断、Table8 middle分解、モデル比較、残差整理などの診断シートを取り込んだ。

#### current_single_tubeの役割

```text
current_single_tube
  = T&M/BMI単管側の現行参照入口
  = r8 resultブックを直接読み続けないための整理済み入口
  = 補正式を作るためのブックではない
```

#### 固定した判断

```text
- r8 resultブックはレガシー・ブリッジブックとして扱う。
- 単管側では、T&M/BMIから直接L/D補正式を作る方向はいったん止める。
- L/Dは補正式候補ではなく、熱履歴・沸騰履歴の代理指標として保留する。
- 真Hsubを優先し、Hsub proxyは定量判断には使わない。
- qMは結果側量なので、補正式入力には使わない。
- x_Mesも結果側量として扱い、補正式入力には使わない。
- x_eqは前向き計算で使える熱収支状態量として、バンドル側へ送る候補にする。
```

#### Table別の扱い

```text
Table8:
  source03に閉じるため、L/D検証点として単純には使わない。
  reference扱い。

Table9:
  source01で約12 MPa。
  PWR下限側チェックとして扱う。

Table10〜12:
  source01 PWR_near主解析群として扱う。

Table13/14:
  高圧側チェック。
  主補正式判断には使わない。
```

#### 採用・保留・撤回気味

```text
採用：
  T&M Table9〜12のTable12 long正残差は、
  Hsub linearでは見えるが、Hsub + P + x_eqでほぼ消える。

採用：
  Table10を除いても、Table別均等重みにしても、
  Table12 long正残差は復活しない。

採用：
  T&M単管データからL/D補正式を作る根拠は弱い。

採用：
  Hsub + P + x_eqは補正式ではなく、
  原因切り分け用の診断式として扱う。

保留：
  F1(Tsub)を維持するか、
  将来的にF(x_eq)または履歴長ベースに置換するか。

撤回気味：
  T&M単管データから直接L/D補正式を作る案。
```

#### 次アクション

BT00-1とBT00-2により、バンドル側・単管側のcurrent入力が分離できた。

次は、バンドル側の `current_bundle_input` を使って、BT01/BT02の再現確認、またはBT03へ進む。

ただし、BT03へ進む前に、BT01/BT02をcurrent_bundle入力で再現できることを一度確認する方が安全である。

したがって、次の候補は以下。

```text
BT01/BT02 current_bundle再現確認
  目的：
    r8 resultブックではなくcurrent_bundleを入力にして、
    108/161/164のnoF1/F1比較が同じ結果になることを確認する。

その後：
  BT03
    F1(Tsub)、F_form、x_eq、z_DNB/DH、z_DNB/Lを分けて、
    108高めP/M残差の対応関係を確認する。
```

---

---

### 2026-06-15　BT01/BT02：current_bundle入力での再現確認完了

#### 位置づけ

BT00-1で作成した `current_bundle_input` を使って、BT01/BT02の主要結果が再現できるか確認した。

目的は、r8 resultブックを直接読み続ける運用から離れ、今後のバンドル解析を `current_bundle_input` 起点に移行できるかを確認することである。

#### 入力と出力

```text
入力：
H52Q_current_bundle_input_v1_20260615_180822.xlsx

出力：
BT01_02_current_bundle_repro_20260615_184359.xlsx
run_report_BT01_02_current_bundle_repro_20260615_184359.md
```

#### 前提

```text
- F2は使わない。
- F1F2は使わない。
- 比較対象は noF1 と F1 のみ。
- バンドルでは x_Mes = x_eq として扱う。
- F1は単管基準のTsub補正である。
- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。
- 補正式は作らない。
```

#### 再現確認結果

`reproduction_check` では、既知のBT01/BT02平均値との差分が概ね `10^-6` オーダーに収まった。

したがって、r8 resultブックを直接読まなくても、`current_bundle_input` からBT01/BT02の主要結果を再現できることを確認した。

#### BT01再現結果

F1後の代表値は以下である。

```text
q_exp:
108 = 3.03625 MW/m2
161 = 1.41360 MW/m2
164 = 1.18876 MW/m2

q_calc_F1:
108 = 3.23576 MW/m2
161 = 1.29514 MW/m2
164 = 1.06698 MW/m2

P/M_F1:
108 = 1.06679
161 = 0.908841
164 = 0.892018
```

q絶対値では、108高・161/164低の傾向が実験値にも計算値にも出ている。

一方、P/Mでは、F1後に108が1をやや超え、161/164は1をやや下回る。

#### BT02再現結果

noF1からF1へのP/M上昇量は以下である。

```text
delta_PM:
108 = +0.444958
161 = +0.287860
164 = +0.321095
```

F1/noF1の倍率は以下である。

```text
qcalc_lift_ratio:
108 = 1.76502
161 = 1.55271
164 = 1.66790
```

したがって、noF1からF1へ進むと、108のP/M上昇が相対的に大きい。

ただし、この結果をF_formの効果として読まない。

F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。

#### 108と161/164の対比

108は、161/164平均と比べて以下の特徴を持つ。

```text
PM_F1:
108 = 1.06679
161/164平均 = 0.900429
差 = +0.166359

Tsub:
108 = 46.0838 K
161/164平均 = 59.3994 K
差 = -13.3156 K

Fcorr:
108 = 1.04382
161/164平均 = 1.03893
差 = +0.00489

F_form:
108 = 0.669495
161/164平均 = 1.17319
差 = -0.503696

x_eq:
108 = -0.0139909
161/164平均 = -0.1188
差 = +0.104809

z_DNB/DH:
108 = 139.659
161/164平均 = 324.090
差 = -184.431

L/DH:
108 = 189.184
161/164平均 = 362.417
差 = -173.233
```

108は、x_eqが0に近く、DNB位置までの履歴長が短く、L/DHも小さい。

ただし、これらはケース構造と交絡しているため、どれか単独を原因とは断定しない。

#### 相関診断の扱い

相関診断では、PM_F1に対して以下のような傾向が出た。

```text
PM_F1 vs L/DH:
  R2 ≈ 0.390

PM_F1 vs z_DNB/DH:
  R2 ≈ 0.284

PM_F1 vs F_form:
  R2 ≈ 0.240

PM_F1 vs x_eq:
  R2 ≈ 0.039

PM_F1 vs Fcorr:
  R2 ≈ 0.006
```

ただし、これらは探索的診断であり、補正式係数ではない。

特にF_formはF1ではないため、F_formとの相関をF1の効き方として読まない。

#### 判断

BT01/BT02は、current_bundle入力で再現できた。

したがって、今後のバンドル解析では、r8 resultブックを直接読まず、`current_bundle_input` を入力として使う。

#### 次アクション

次はBT03へ進む。

BT03では、以下を分けて確認する。

```text
1. F1(Tsub)そのもの
2. Fcorr
3. F_form
4. x_eq
5. z_DNB/DH
6. z_DNB/L
7. L/DH
```

目的は、108高めP/M残差を、F1(Tsub)、非一様加熱換算、熱平衡クオリティ、DNB位置までの履歴長のどれと対応して見るべきかを整理することである。

---

---

### 2026-06-15　BT03：F1(Tsub)・F_form・x_eq・履歴長の分離診断

#### 位置づけ

BT01/BT02では、`current_bundle_input` を用いて、108/161/164のnoF1/F1比較がr8 resultブックなしで再現できることを確認した。

BT03では、その次段階として、F1後のP/Mが108で相対的に高く、161/164でやや低めに残る理由を、以下の要素に分けて確認した。

```text
1. F1(Tsub)そのもの
2. Fcorr
3. F_form
4. x_eq
5. z_DNB/DH
6. z_DNB/L
7. L/DH
```

このBT03でも、補正式は作らない。
目的は、どの変数とP/M差が対応しているかを確認する分離診断である。

#### 入力と出力

```text
入力：
H52Q_current_bundle_input_v1_20260615_180822.xlsx

出力：
BT03_current_bundle_F1_Fform_xeq_history_separation_20260615_184941.xlsx
run_report_BT03_current_bundle_F1_Fform_xeq_history_separation_20260615_184941.md
```

#### 前提

```text
- r8 resultブックは直接読まない。
- current_bundle_inputを読む。
- F2/F1F2は使わない。
- 比較対象はnoF1とF1のみ。
- バンドルでは x_Mes = x_eq として扱う。
- F1は単管基準のTsub補正である。
- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。
- 補正式は作らない。
```

#### ケース平均の再確認

F1後のP/Mは以下であった。

```text
PM_F1:
108 = 1.06679
161 = 0.908841
164 = 0.892018
```

したがって、108は161/164より相対的にP/Mが高い。

108と161/164平均の差は以下である。

```text
PM_F1:
108 - mean(161,164) = +0.166359
```

#### F1(Tsub)・Fcorrの確認

108は161/164よりTsubが低い。

```text
Tsub:
108 = 46.0838 K
161/164平均 = 59.3994 K
差 = -13.3156 K
```

しかし、F1(Tsub)の補正係数に相当するFcorr差は小さい。

```text
Fcorr:
108 = 1.04382
161/164平均 = 1.03893
差 = +0.00489
```

また、点群相関としても、PM_F1とFcorrの対応は弱かった。

```text
PM_F1 vs Fcorr:
R2 ≈ 0.006
```

したがって、BT03時点では、

```text
108高めP/Mを、F1(Tsub)係数差だけで説明するのは弱い
```

と判断する。

#### F_formの確認

F_formは108と161/164で大きく異なる。

```text
F_form:
108 = 0.669495
161/164平均 = 1.17319
差 = -0.503696
```

ただし、F_formはF1ではない。
F_formは非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。

PM_F1との点群相関は中程度であった。

```text
PM_F1 vs F_form:
R2 ≈ 0.240
```

このため、F_formは無視できないが、

```text
F_formが108高めP/Mの原因である
```

とは断定しない。

F_formは、軸方向出力分布、DNB位置、局所熱流束基準換算、ケース構造と一体で読む必要がある。

#### x_eqの確認

108はx_eqが最も0に近い。

```text
x_eq:
108 = -0.0139909
161/164平均 = -0.1188
差 = +0.104809
```

ただし、PM_F1とx_eqの点群相関は弱い。

```text
PM_F1 vs x_eq:
R2 ≈ 0.039
```

したがって、x_eqは重要な熱収支状態量ではあるが、BT03時点では、

```text
x_eq単独で108/161/164のP/M差を説明できる
```

とは言わない。

x_eqは、F1(Tsub)を将来的に見直すための候補量として残す。

#### DNB履歴長・L/DHの確認

108は、DNB位置までの履歴長が明確に短い。

```text
z_DNB/DH:
108 = 139.659
161/164平均 = 324.090
差 = -184.431
```

また、全体のL/DHも小さい。

```text
L/DH:
108 = 189.184
161/164平均 = 362.417
差 = -173.233
```

点群相関では、PM_F1との対応は以下であった。

```text
PM_F1 vs z_DNB/DH:
R2 ≈ 0.284

PM_F1 vs L/DH:
R2 ≈ 0.390
```

したがって、履歴長またはL/DHは、108高めP/Mと対応している可能性がある。

ただし、108/161/164では、L/DH、DNB位置、F_form、x_eqが同時に変わっているため、どれか単独を原因とは断定しない。

#### 探索モデルの結果

探索的な線形整理では、以下の組合せが最も高いR2を示した。

```text
PM_F1 ~ Tsub + F_form + x_eq + z_DNB/DH
R2 ≈ 0.665
```

これは、108/161/164のP/M差が単独変数ではなく、Tsub、非一様加熱換算、熱平衡クオリティ、DNB履歴長の複合で整理される可能性を示す。

ただし、このモデルは探索的診断であり、補正式としては採用しない。

#### BT03の判断

BT03の判断は以下である。

```text
F1(Tsub)係数差だけでは、108高めP/Mを説明しにくい。

F_form差は大きいが、F_formはF1ではなく、非一様加熱・DNB位置・局所熱流束換算として読む。

x_eqは108で0に近いが、PM_F1との単独相関は弱いため、x_eq単独原因とは言わない。

z_DNB/DHおよびL/DHはPM_F1とある程度対応しており、履歴長・ケース構造として重要に見える。

ただし、108/161/164では、F_form、x_eq、z_DNB/DH、L/DHが同時に変化しているため、単独原因の断定はしない。
```

#### 現時点で言ってよいこと

```text
- BT03はcurrent_bundle入力で実行できた。
- F1(Tsub)の補正係数差だけでは、108高めP/Mを説明しにくい。
- F_form差、x_eq差、DNB履歴長差、L/DH差が同時に存在する。
- F_formはF1ではないため、F1の効き方として読まない。
- x_eqは単独説明因子というより、F1(Tsub)見直し候補の状態量である。
- z_DNB/DHおよびL/DHは、履歴長・ケース構造として見る価値がある。
```

#### まだ言ってはいけないこと

```text
- F1(Tsub)をすぐ置換すべきとは言わない。
- F_formが108高めP/Mの原因であるとは言わない。
- x_eq単独でP/M差を説明できるとは言わない。
- L/DHまたはz_DNB/DHが原因であるとは断定しない。
- BT03の探索モデルを補正式として採用しない。
```

#### 次アクション

BT03により、F1(Tsub)単独ではなく、F_form、x_eq、DNB履歴長、L/DHが同時に関係していることを確認した。

次はBT04として、F1(Tsub)の代替候補をいきなり実装するのではなく、候補構造を設計する。

BT04の目的は、以下の案を比較可能な形で整理することである。

```text
案A：
  現行F1(Tsub)を維持する。

案B：
  F1(Tsub)をF(x_eq)へ置換する。

案C：
  F1(Tsub)をF(z_DNB/DH)または履歴長ベースへ置換する。

案D：
  F1(Tsub)を維持しつつ、F_formまたは履歴長との交絡を別管理する。

案E：
  F1そのものを補正式化せず、108/161/164はモデル適用範囲・非一様加熱換算・履歴長診断として整理する。
```

BT04では、まだ係数を作らない。
まず、どの案が物理的に破綻しにくく、どの案が実装上危ないかを整理する。

---

---

### 2026-06-16　BT04：単管L/D仮説からバンドル履歴変数への橋渡し診断

#### 位置づけ

BT04では、単管T&M/BMI側で仮閉じしたL/D仮説を、バンドル108/161/164側へどのように引き継ぐべきかを確認した。

元々の問題意識は以下であった。

```text
バンドル108/161/164の差は、L/DHまたは履歴長で補正できそうに見える。
そこで、まず単管T&M/BMIでL/D効果を確認した。
しかし、単管ではL/D単独補正式の根拠は弱く、L/Dは沸騰履歴・熱履歴の代理変数として扱う方が安全と判断した。
そのため、バンドルではL/DHそのものではなく、DNBまでの履歴長、x_eq、Tsub、F1(Tsub)、F_formのどれを見るべきかを確認する。
```

BT04は、補正式を作る作業ではない。
目的は、単管で避けたL/D単独補正式に戻らず、バンドル側で見るべき履歴変数・状態量を整理することである。

#### 入力と出力

```text
入力：
H52Q_current_bundle_input_v1_20260615_180822.xlsx

出力：
BT04_bundle_history_bridge_diagnostic_20260616_090506.xlsx
run_report_BT04_bundle_history_bridge_diagnostic_20260616_090506.md
```

#### 前提

```text
- r8 resultブックは直接読まない。
- current_bundle_inputを読む。
- F2/F1F2は使わない。
- 比較対象はnoF1とF1のみ。
- バンドルでは x_Mes = x_eq として扱う。
- F1は単管基準のTsub補正である。
- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。
- 補正式は作らない。
- R2が高いモデルをそのまま採用しない。
```

#### 1. F1なしの元モデル誤差 PM_noF1

BT04で最初に見るべきなのは、F1を入れる前の元モデル誤差である。

PM_noF1と各軸の点群相関は以下であった。

```text
PM_noF1 vs L/DH:
  R2 ≈ 0.005

PM_noF1 vs z_DNB/DH:
  R2 ≈ 0.00005

PM_noF1 vs x_eq:
  R2 ≈ 0.626

PM_noF1 vs Tsub:
  R2 ≈ 0.806
```

この結果から、F1なしの元モデル誤差は、L/DHやDNBまでの履歴長ではほとんど整理されない。

一方、Tsubやx_eqとは強く対応している。

したがって、元々考えていた

```text
バンドル差はL/DHで補正できそう
```

という見方は、少なくともPM_noF1を見る限り弱い。

むしろ、F1なしの誤差は、入口サブクール・熱平衡クオリティ・熱状態量と関係している可能性が高い。

#### 2. F1後の残差 PM_F1

F1後のPM_F1では、相関の見え方が変わる。

```text
PM_F1 vs L/DH:
  R2 ≈ 0.390

PM_F1 vs z_DNB/DH:
  R2 ≈ 0.284

PM_F1 vs F_form:
  R2 ≈ 0.240

PM_F1 vs x_eq:
  R2 ≈ 0.039
```

F1後だけを見ると、L/DHやz_DNB/DHとの対応が見える。

ただし、これはL/DH補正式を作る根拠としては扱わない。

理由は、F1なしのPM_noF1ではL/DHやz_DNB/DHとの対応がほぼ無かったためである。

したがって、PM_F1で見えるL/DH相関は、

```text
F1後に残ったケース構造・非一様加熱換算・履歴長の見かけ相関
```

として扱う。

#### 3. F1の持ち上げ量 delta_PM

F1による持ち上げ量 `delta_PM = PM_F1 - PM_noF1` は、以下と対応した。

```text
delta_PM vs Tsub:
  R2 ≈ 0.829

delta_PM vs Fcorr:
  R2 ≈ 0.690

delta_PM vs x_eq:
  R2 ≈ 0.546

delta_PM vs z_DNB/DH:
  R2 ≈ 0.227

delta_PM vs L/DH:
  R2 ≈ 0.217
```

F1の持ち上げ量は、TsubおよびFcorrと強く対応する。

これは、F1がTsub補正であることと整合する。

x_eqとも中程度に対応しているが、Tsubとx_eqは共変している可能性があるため、

```text
F1効果はx_eqで説明できる
```

とはまだ言わない。

#### 4. F1の倍率効果 lift_ratio

F1/noF1の倍率効果 `lift_ratio = PM_F1 / PM_noF1` では、以下の結果であった。

```text
lift_ratio vs Tsub:
  R2 ≈ 0.886

lift_ratio vs x_eq:
  R2 ≈ 0.625

lift_ratio vs Fcorr:
  R2 ≈ 0.449

lift_ratio vs z_DNB/DH:
  R2 ≈ 0.055

lift_ratio vs L/DH:
  R2 ≈ 0.032
```

倍率効果も、履歴長やL/DHではなく、Tsubおよびx_eqと対応している。

したがって、F1の効き方を考えるうえでは、L/DHよりもTsub/x_eq側を見る方が筋がよい。

ただし、Tsubが最も強く、x_eqはその次であるため、x_eqがTsubに対して追加情報を持つかは、次段階で確認する必要がある。

#### 5. BT04で分かったこと

BT04の判断は以下である。

```text
F1なしの元モデル誤差 PM_noF1 は、L/DHやz_DNB/DHではほとんど整理されない。

PM_noF1は、Tsubおよびx_eqと強く対応する。

F1後のPM_F1だけを見るとL/DHやz_DNB/DHとの対応が見えるが、
これはF1後に残った見かけ相関として扱う。

F1の持ち上げ量 delta_PM および倍率効果 lift_ratio は、
Tsubと最も強く対応し、x_eqとも中程度に対応する。

したがって、単管で弱めたL/D単独補正式を、バンドル側で復活させる根拠は弱い。
```

#### 6. 現時点で言ってよいこと

```text
- バンドル108/161/164の差は、単純なL/DH補正式として扱うには根拠が弱い。
- F1なしの元モデル誤差は、L/DHやDNB履歴長よりもTsub/x_eq側と対応している。
- F1効果量も、L/DHやDNB履歴長よりもTsub/x_eq側と対応している。
- PM_F1でL/DH相関が見えるが、それはF1後残差の見かけ相関として扱う。
- x_eqは有力な状態量候補だが、Tsubとの共変を切り分ける必要がある。
```

#### 7. まだ言ってはいけないこと

```text
- L/DH補正式を作るべきとは言わない。
- z_DNB/DH補正式を作るべきとは言わない。
- x_eq補正式へ置換すべきとはまだ言わない。
- F1(Tsub)を捨てるべきとは言わない。
- PM_F1とL/DHの相関だけを見て、L/DH効果と断定しない。
- R2が高い探索モデルを補正式として採用しない。
```

#### 8. 次アクション

BT04により、元のL/DH補正式仮説はさらに弱まった。

次はBT05として、Tsubとx_eqの関係を切り分ける。

BT05で確認すべきことは以下である。

```text
1. PM_noF1をTsubで説明した後の残差が、x_eqでまだ整理されるか。
2. PM_noF1をx_eqで説明した後の残差が、Tsubでまだ整理されるか。
3. delta_PMをTsubまたはFcorrで説明した後の残差が、x_eqでまだ整理されるか。
4. lift_ratioをTsubまたはFcorrで説明した後の残差が、x_eqでまだ整理されるか。
5. x_eqがTsubの単なる代理なのか、Tsubにない追加情報を持つのか。
```

BT05の目的は、F1(Tsub)をx_eqへ置換することではない。

まず、

```text
x_eqがTsubに対して追加的な説明力を持つか
```

を確認する。

---

---

### 2026-06-16　BT05：Tsubとx_eqの切り分け診断

#### 位置づけ

BT04では、バンドル108/161/164について、F1なしの元モデル誤差およびF1効果量が、L/DHやz_DNB/DHよりもTsub/x_eq側と対応することを確認した。

ただし、BT04の段階では、x_eqが独立した説明力を持つのか、それともTsubと共変しているだけなのかは未確認であった。

そのためBT05では、以下を確認した。

```text
x_eqはTsubの単なる代理なのか。
それとも、Tsubにない追加説明力を持つのか。
```

BT05は、F1(Tsub)をF(x_eq)へ置換する作業ではない。
補正式も作らない。
目的は、x_eqを次の補正候補として扱ってよいかどうかの前段診断である。

#### 入力と出力

```text
入力：
H52Q_current_bundle_input_v1_20260615_180822.xlsx

出力：
BT05_Tsub_xeq_separation_diagnostic_20260616_091354.xlsx
run_report_BT05_Tsub_xeq_separation_diagnostic_20260616_091354.md
```

#### 前提

```text
- r8 resultブックは直接読まない。
- current_bundle_inputを読む。
- F2/F1F2は使わない。
- 比較対象はnoF1とF1のみ。
- バンドルでは x_Mes = x_eq として扱う。
- F1は単管基準のTsub補正である。
- BT05では補正式を作らず、F1(Tsub)も置換しない。
```

#### 1. Tsubとx_eqの関係

まず、Tsubとx_eqの共変を確認した。

```text
x_eq ~ Tsub:
  R2 ≈ 0.704
```

したがって、Tsubとx_eqはかなり強く共変している。

このため、x_eq単独でP/MやF1効果量と相関して見えたとしても、それはTsubの代理として見えている可能性がある。

#### 2. PM_noF1の確認

F1なしの元モデル誤差 `PM_noF1` について、Tsubとx_eqの説明力を比較した。

```text
PM_noF1:

Tsub only:
  R2 ≈ 0.806

x_eq only:
  R2 ≈ 0.626

Tsub + x_eq:
  R2 ≈ 0.810
```

x_eq単独でも一定の説明力を持つが、Tsub単独の方が強い。

また、Tsubにx_eqを追加したときの改善は小さい。

```text
x_eq after Tsub:
  ΔR2 ≈ 0.0049

Tsub after x_eq:
  ΔR2 ≈ 0.185
```

残差化しても同じ傾向であった。

```text
Tsubで説明した後の残差 vs x_eq:
  R2 ≈ 0.007

x_eqで説明した後の残差 vs Tsub:
  R2 ≈ 0.146
```

したがって、PM_noF1に対しては、x_eqはTsubに対する追加説明力をほとんど持たない。

むしろ、x_eqで説明した後にもTsub側の情報が残る。

#### 3. F1持ち上げ量 delta_PMの確認

F1による持ち上げ量 `delta_PM = PM_F1 - PM_noF1` についても同様に確認した。

```text
delta_PM:

Tsub only:
  R2 ≈ 0.829

x_eq only:
  R2 ≈ 0.546

Tsub + x_eq:
  R2 ≈ 0.831
```

x_eq単独でも中程度の説明力を持つが、Tsub単独の方が明確に強い。

Tsubにx_eqを追加したときの改善は小さい。

```text
x_eq after Tsub:
  ΔR2 ≈ 0.0021

Tsub after x_eq:
  ΔR2 ≈ 0.285
```

残差化しても、Tsubで説明した後にx_eqはほとんど残らない。

```text
Tsubで説明した後の残差 vs x_eq:
  R2 ≈ 0.0036

x_eqで説明した後の残差 vs Tsub:
  R2 ≈ 0.186
```

したがって、F1の持ち上げ量についても、主説明軸はx_eqではなくTsubである。

#### 4. F1倍率効果 lift_ratioの確認

F1/noF1の倍率効果 `lift_ratio = PM_F1 / PM_noF1` について確認した。

```text
lift_ratio:

Tsub only:
  R2 ≈ 0.886

x_eq only:
  R2 ≈ 0.625

Tsub + x_eq:
  R2 ≈ 0.886
```

ここでも、x_eq単独には見かけの説明力がある。

しかし、Tsubを入れた後にx_eqを加えても、ほぼ改善しない。

```text
x_eq after Tsub:
  ΔR2 ≈ 0.000001

Tsub after x_eq:
  ΔR2 ≈ 0.261
```

残差化でも同じである。

```text
Tsubで説明した後の残差 vs x_eq:
  R2 ≈ 0.000004

x_eqで説明した後の残差 vs Tsub:
  R2 ≈ 0.206
```

したがって、F1の倍率効果は、ほぼTsub側で説明される。

x_eqは、Tsubと共変しているために相関して見えている可能性が高い。

#### 5. Fcorrを含めた確認

F1効果量について、Fcorrを基準にした場合も確認した。

```text
delta_PM:
  x_eq after Fcorr:
    ΔR2 ≈ 0.039

  x_eq after Tsub + Fcorr:
    ΔR2 ≈ 0.0019

lift_ratio:
  x_eq after Fcorr:
    ΔR2 ≈ 0.195

  x_eq after Tsub + Fcorr:
    ΔR2 ≈ 0.00013
```

Fcorrだけを基準にすると、x_eqに追加説明力があるように見える。

しかし、Tsub + Fcorr を入れると、x_eqの追加説明力はほぼ消える。

このため、現行F1の係数Fcorrだけでは、Tsubの情報を完全に代表できていない可能性はある。

ただし、それは

```text
F1をx_eqへ置換すべき
```

という意味ではない。

より安全には、

```text
Fcorr列だけを見るのではなく、F1(Tsub)の元変数であるTsubそのものも含めて見る必要がある
```

と解釈する。

#### 6. PM_F1の確認

F1後の残差 `PM_F1` については、Tsubおよびx_eqの説明力はどちらも弱い。

```text
PM_F1:

Tsub only:
  R2 ≈ 0.020

x_eq only:
  R2 ≈ 0.039

Tsub + x_eq:
  R2 ≈ 0.040
```

したがって、F1後に残ったP/M差は、Tsubやx_eqだけでは説明しにくい。

これはBT03/BT04の判断と整合する。

つまり、F1後残差を見る場合は、Tsub/x_eqよりも、F_form、DNB位置、L/DH、ケース構造、非一様加熱換算などを別に見る必要がある。

#### 7. BT05で分かったこと

BT05の判断は以下である。

```text
Tsubとx_eqは強く共変している。

PM_noF1に対して、x_eq単独には説明力があるが、Tsubに追加したときの改善は小さい。

delta_PMおよびlift_ratioに対しても、x_eq単独には説明力があるが、Tsubに追加したときの改善はほぼ消える。

したがって、今回の108/161/164では、x_eqはTsubに対して独立した追加説明力をほとんど持たない。

x_eqは有力な状態量候補ではあるが、F1(Tsub)をF(x_eq)へ置換する根拠にはならない。
```

#### 8. 現時点で言ってよいこと

```text
- x_eqはTsubと強く共変している。
- x_eq単独ではPM_noF1やF1効果量と相関して見える。
- しかし、Tsubを入れた後にx_eqを加えても説明力はほとんど改善しない。
- F1効果量は、x_eqよりもTsub側でよく説明される。
- 現時点では、F1(Tsub)をF(x_eq)へ置換する根拠は弱い。
- x_eqは補正式置換候補ではなく、熱収支状態量・診断項として保留する。
```

#### 9. まだ言ってはいけないこと

```text
- x_eqは無意味であるとは言わない。
- x_eqを完全に捨てるとは言わない。
- F1(Tsub)をF(x_eq)へ置換すべきとは言わない。
- F1(Tsub)が完全に正しいとは言わない。
- F1後残差がTsub/x_eqで説明できるとは言わない。
```

#### 10. BT04からの認識更新

BT04では、x_eqがPM_noF1やF1効果量と中程度以上に対応していたため、x_eqをF1(Tsub)の代替候補として考える余地があった。

しかしBT05で、Tsubとx_eqを切り分けると、x_eqの追加説明力は小さいことが分かった。

したがって、BT04後の見方を以下のように更新する。

```text
BT04時点：
  x_eqはTsubと並ぶ有力状態量候補に見えた。

BT05後：
  x_eqはTsubと強く共変しており、
  今回の108/161/164では、Tsubに対する追加説明力は小さい。

更新後の扱い：
  x_eqはF1(Tsub)の置換候補ではなく、
  熱収支状態量・診断項として保留する。
```

#### 11. 採用・保留・撤回気味

```text
採用：
  PM_noF1とF1効果量は、x_eqよりTsubでよく説明される。

採用：
  x_eq単独相関は、Tsubとの共変による見かけを含む可能性が高い。

採用：
  Tsubを入れた後のx_eq追加説明力は小さい。

採用：
  F1(Tsub)をF(x_eq)へ置換する根拠は、現時点では弱い。

保留：
  x_eqを熱収支状態量・診断項として使うこと。

保留：
  F1後残差をF_form、DNB位置、L/DH、非一様加熱換算、ケース構造として見ること。

撤回気味：
  108/161/164のBT04結果から、F1(Tsub)をF(x_eq)へ置換する案。
```

#### 12. 次アクション

BT05により、x_eqはTsubに対する追加説明力が小さいことが分かった。

したがって、次に進むべき方向は、

```text
F1(Tsub)をF(x_eq)へ置換する
```

ではない。

次は、F1(Tsub)をいったん維持したうえで、F1後に残るPM_F1差を何として扱うかを整理する。

候補は以下である。

```text
1. F_formを含む非一様加熱換算の問題
2. DNB位置・z_DNB/DH・z_DNB/Lのケース構造
3. L/DHの見かけ相関
4. 108/161/164の適用範囲・代表性の問題
5. F1後残差を補正式化せず、診断課題として残す方針
```

次の作業は、BT06として以下を行う。

```text
BT06：
F1(Tsub)維持を前提に、PM_F1残差をどう扱うかを整理する。

目的：
  F1置換ではなく、
  F1後残差をF_form、DNB位置、L/DH、ケース構造、適用範囲のどれとして扱うべきかを決める。
```

BT06でも、まだ補正式は作らない。

---

---

### 2026-06-16　BT05コメント追記：単管x_eq診断とバンドルx_eq診断の接続課題

#### 背景

BT05では、バンドル108/161/164について、Tsubとx_eqの切り分け診断を行った。

その結果、バンドル側では、x_eq単独には一定の説明力があるように見えるものの、Tsubを入れた後にx_eqを追加しても説明力はほとんど改善しなかった。

このため、BT05時点では以下のように整理した。

```text
バンドル108/161/164では、
x_eqはTsubと強く共変しており、
F1(Tsub)をF(x_eq)へ置換する根拠は弱い。
```

ただし、この整理だけだと、単管側からの流れが少し落ちる可能性がある。

元々、単管T&M/BMI側では、x_eqは重要な役割を持っていた。

#### 単管側でのx_eqの位置づけ

単管側では、T&M source01 Table9〜12について、以下のような整理をしていた。

```text
Hsub linearでは、Table12 long側に正残差が残る。

しかし、Hsub非線形性、P、x_eqを含めると、
Table12 long正残差はほぼ消える。

この結果により、
Table12 long正残差を単純なL/D効果または熱履歴効果の主証拠とする判断は弱まった。
```

したがって、単管側では、x_eqは「何も効かなかった」のではない。

むしろ、x_eqは、

```text
L/Dで説明したくなる残差が、
熱収支状態量側で整理できる可能性を示した診断量
```

として重要であった。

ただし、単管側で実施済みなのは、主に以下の確認である。

```text
Hsub + P + x_eq を入れると残差が消えるか
```

であり、BT05でバンドルに対して行ったような、

```text
x_eqがTsubまたはHsub/Pに対して独立した追加説明力を持つか
```

という切り分けは、単管側ではまだ十分に行っていない。

したがって、単管側については以下のように整理する。

```text
単管：
  x_eq込み診断は実施済み。
  ただし、x_eqの独立効果の分解は未完了。
```

#### バンドル側でのx_eqの位置づけ

一方、バンドル側ではBT05により、Tsubとx_eqの切り分けを行った。

その結果、以下が確認された。

```text
PM_noF1：
  x_eq単独には説明力がある。
  しかし、Tsubを入れた後のx_eq追加説明力は小さい。

delta_PM / lift_ratio：
  x_eq単独には説明力がある。
  しかし、Tsubを入れた後のx_eq追加説明力はほぼ消える。

PM_F1：
  Tsubでもx_eqでも説明力は弱い。
```

したがって、バンドル108/161/164に限れば、x_eqはTsubに対する独立した補正変数というより、Tsubと共変している診断量として見える。

このため、バンドル側では、

```text
F1(Tsub)をF(x_eq)へ置換する根拠は弱い
```

と判断する。

#### 重要な論点：単管では効いたが、バンドルでは効かない可能性

ここで重要なのは、単管とバンドルでx_eqの見え方が違う可能性である。

単管では、Hsub + P + x_eqにより、L/D効果に見えた残差が整理された。

一方、バンドルでは、x_eqはTsubに対する追加説明力をほとんど持たなかった。

この違いは、単なる解析上の細部ではなく、補正式の移植性に関わる重要な論点である。

理由は以下である。

```text
補正式は基本的に単管データで作る。

しかし、その補正式をバンドルに適用したときに効かない場合、
それは単管とバンドルの差を示している可能性がある。
```

したがって、今後の整理では、

```text
単管ではx_eqが効いた。
しかし、バンドルではx_eqがTsubに対して追加説明力を持たなかった。
```

という可能性を、忘れないように保留課題として残す。

ただし、現時点ではまだ、

```text
単管ではx_eqが独立に効いた
```

とまでは言わない。

単管側では、x_eqがHsub/P/Tsubに対して独立した追加説明力を持つかを、BT05相当の方法でまだ切り分けていないためである。

#### 今後の作業上の扱い

このコメントにより、今後の流れを以下のように整理する。

```text
1. 元の流れのまま、バンドル側BT06へ進む。
   目的は、F1(Tsub)維持を前提に、PM_F1残差をどう扱うかを整理すること。

2. ただし、単管側には未完了タスクとして、
   ST-BT05相当のx_eq独立効果切り分け診断を残す。

3. 将来、単管データから補正式候補を作る場合は、
   その前に単管側で
     Hsub/P/Tsubを入れた後にx_eqがまだ効くか
   を確認する。

4. 単管側でx_eqが独立に効くが、バンドル側で効かない場合は、
   それを「補正式不成立」とだけ読むのではなく、
   単管とバンドルの構造差・非一様加熱・DNB位置・サブチャンネル効果の問題として整理する。
```

#### 採用・保留・未検証

```text
採用：
  バンドルBT05では、x_eqのTsubに対する追加説明力は小さい。

採用：
  バンドル108/161/164では、F1(Tsub)をF(x_eq)へ置換する根拠は弱い。

採用：
  単管側では、Hsub + P + x_eqによりTable12 long正残差がほぼ消えたという意味で、x_eqは重要な診断量だった。

保留：
  単管でx_eqが独立した補正変数として効くかどうか。

保留：
  単管で効くx_eq補正が、バンドルでは効かない可能性。

未検証：
  単管側に対するBT05相当の切り分け診断。
  具体的には、Hsub/P/Tsubで説明した後の残差にx_eqがまだ効くか。
```

#### 現時点の判断

現時点では、バンドル側の作業を止める必要はない。

BT06として、F1(Tsub)維持を前提に、PM_F1残差をF_form、DNB位置、L/DH、ケース構造、適用範囲のどれとして扱うかを整理する。

ただし、単管側については、将来の補正式化前に以下を確認する必要がある。

```text
単管側ST-BT05：
  Hsub/P/Tsubとx_eqの切り分け診断

目的：
  単管でx_eqが本当に独立した説明力を持つか、
  それともHsub/P/Tsubの代理として効いていたのかを確認する。
```

この未検証タスクを残したうえで、次は予定どおりBT06へ進む。

---

---

### 2026-06-16　BT06：F1(Tsub)維持前提でのPM_F1残差の扱い整理

#### 位置づけ

BT05では、バンドル108/161/164において、x_eqはTsubと強く共変しており、Tsubに対する追加説明力が小さいことを確認した。

そのため、BT06では以下の方針で進めた。

```text
F1(Tsub)を維持する。
F1(Tsub)をF(x_eq)へ置換しない。
そのうえで、F1後に残るPM_F1残差をどう扱うべきかを整理する。
```

BT06の目的は、補正式を作ることではない。

目的は、F1後残差を以下のどれとして扱うべきかを判断することである。

```text
1. F_formを含む非一様加熱換算の問題
2. DNB位置・z_DNB/DH・z_DNB/Lのケース構造
3. L/DHの見かけ相関
4. 108/161/164の適用範囲・代表性の問題
5. F1後残差を補正式化せず、診断課題として残す方針
```

#### 入力と出力

```text
入力：
H52Q_current_bundle_input_v1_20260615_180822.xlsx

出力：
BT06_PM_F1_residual_handling_diagnostic_20260616_102308.xlsx
run_report_BT06_PM_F1_residual_handling_diagnostic_20260616_102308.md
```

#### 前提

```text
- r8 resultブックは直接読まない。
- current_bundle_inputを読む。
- F2/F1F2は使わない。
- 比較対象はnoF1とF1のみ。
- F1(Tsub)は維持する。
- F1(Tsub)をF(x_eq)へ置換しない。
- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。
- 補正式は作らない。
- R2が高いモデルをそのまま採用しない。
```

#### 1. PM_F1のケース別残差

F1後のP/Mは以下であった。

```text
PM_F1:
108 = 1.06679
161 = 0.908841
164 = 0.892018
```

したがって、F1後は以下の構図である。

```text
108：
  PM_F1が1を少し上回る。
  ほぼ一致〜やや過大。

161：
  PM_F1が1を下回る。
  やや過小。

164：
  PM_F1が1を下回る。
  やや過小。
```

108と161/164平均の差は以下である。

```text
PM_F1:
108 - mean(161,164) = +0.166359
```

ただし、108の絶対誤差平均は161/164より小さい。

```text
abs_err_F1:
108 = 0.07184
161 = 0.09759
164 = 0.10961
```

したがって、BT06では以下のように読む。

```text
108だけが悪いわけではない。
むしろ108はPM=1に近い。

ただし、符号としては108が過大側、
161/164が過小側に残っており、
ケース間の系統差は残っている。
```

#### 2. PM_F1残差と各軸の対応

PM_F1と各軸の点群相関は以下であった。

```text
PM_F1 vs L/DH:
  R2 ≈ 0.390

PM_F1 vs z_DNB/DH:
  R2 ≈ 0.284

PM_F1 vs F_form:
  R2 ≈ 0.240

PM_F1 vs x_eq:
  R2 ≈ 0.039

PM_F1 vs Tsub:
  R2 ≈ 0.020
```

BT05で確認したとおり、F1後残差はTsubやx_eqではあまり説明されない。

一方で、L/DH、DNB位置までの履歴長、F_formとは中程度に対応している。

したがって、BT06時点では、F1後残差は以下の側に寄っていると読む。

```text
Tsub/x_eq側ではなく、
F_form・DNB位置・L/DH・ケース構造側
```

ただし、この時点で原因を断定しない。

#### 3. 軸同士の交絡

BT06で重要なのは、PM_F1との相関そのものよりも、軸同士の交絡である。

主な交絡は以下であった。

```text
z_DNB/DH vs L/DH:
  R2 ≈ 0.853

F_form vs L/DH:
  R2 ≈ 0.643

F_form vs z_DNB/DH:
  R2 ≈ 0.291

Tsub vs x_eq:
  R2 ≈ 0.704
```

特に、z_DNB/DHとL/DHの交絡が非常に強い。

したがって、PM_F1とL/DHの相関が見えたとしても、それを純粋なL/DH効果とは読めない。

同様に、F_formもL/DHやDNB位置と交絡している。

このため、

```text
F_formが原因である
L/DHが原因である
z_DNB/DHが原因である
```

とはまだ言わない。

#### 4. 残差化診断の読み

err_F1、すなわち `PM_F1 - 1` をTsubで説明した後でも、L/DH、z_DNB/DH、F_formとの対応は残った。

```text
err_F1 residual after Tsub:

vs L/DH:
  R2 ≈ 0.439

vs z_DNB/DH:
  R2 ≈ 0.334

vs F_form:
  R2 ≈ 0.262
```

Tsub + x_eqで説明した後でも、同じ傾向がむしろ強く残った。

```text
err_F1 residual after Tsub + x_eq:

vs L/DH:
  R2 ≈ 0.503

vs F_form:
  R2 ≈ 0.373

vs z_DNB/DH:
  R2 ≈ 0.343
```

このため、F1後残差は、Tsub/x_eqではなく、F_form・DNB位置・L/DH側のケース構造として残っている可能性が高い。

ただし、L/DHで残差化するとF_formやz_DNB/DHとの対応がほぼ消える。

これは、L/DHが多くのケース構造を代表してしまうことを意味する。

したがって、L/DHは便利な整理軸に見えるが、物理的には以下の複合代理になっている可能性がある。

```text
L/DH
DNB位置までの履歴長
z_DNB/L
F_form
非一様加熱分布
ケース番号
```

このため、L/DHを補正式にするのは危険である。

#### 5. 探索モデルの読み

探索的な線形整理では、以下の組合せが最も高い説明力を示した。

```text
PM_F1 ~ Tsub + x_eq + F_form + z_DNB/DH:
  R2 ≈ 0.665
```

ただし、このモデルは補正式ではない。

この結果は、F1後残差が単一変数ではなく、以下の複合で整理される可能性を示す診断結果である。

```text
Tsub
x_eq
F_form
DNB位置までの履歴長
```

BT05の結果を踏まえると、Tsub/x_eqはF1置換候補というより、状態量・共変量として読む。

また、F_formとz_DNB/DHはDNB位置および非一様加熱換算と絡んでいる。

したがって、探索モデルのR2が高いことを理由に、補正式候補へは進まない。

#### 6. 扱い候補の整理

BT06では、PM_F1残差の扱いを以下のように整理した。

##### H0：F1(Tsub)維持・追加補正式なし

現時点の基準方針である。

```text
F1後のPM_F1は全体として1近傍。
108はやや過大、161/164はやや過小。
系統差は残るが、大外れではない。
```

したがって、追加補正式を急ぐより、まず残差の性格を診断課題として保持する。

##### H1：F_form・非一様加熱換算として扱う

F_formは108と161/164で大きく異なる。

PM_F1との相関も中程度にある。

```text
PM_F1 vs F_form:
  R2 ≈ 0.240
```

ただし、F_formはF1ではない。

F_formは非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数であり、DNB位置やL/DHと交絡している。

したがって、F_formの定義や局所熱流束基準、DNB位置との関係を確認する価値はあるが、F_form原因説にはしない。

##### H2：DNB位置・z_DNB/DH・z_DNB/Lのケース構造として扱う

PM_F1はz_DNB/DHとも対応する。

```text
PM_F1 vs z_DNB/DH:
  R2 ≈ 0.284
```

これは、単管側で出てきた熱履歴仮説と接続しやすい。

ただし、z_DNB/DHはL/DHと強く交絡している。

```text
z_DNB/DH vs L/DH:
  R2 ≈ 0.853
```

したがって、z_DNB/DH補正式へ進むのも早い。

現時点では、DNB位置・履歴長・ケース構造として保留する。

##### H3：L/DH補正式として扱う

PM_F1とL/DHの相関は、単独軸としては最も高い。

```text
PM_F1 vs L/DH:
  R2 ≈ 0.390
```

しかし、BT04ではPM_noF1とL/DHはほとんど対応していなかった。

また、単管T&M/BMI側でも、L/D単独補正式を作る根拠は弱いと判断している。

そのため、F1後残差だけを根拠にL/DH補正式へ進むのは危険である。

現時点では、L/DHは診断項として残すが、補正式候補にはしない。

##### H4：x_eq置換として扱う

BT05で確認したとおり、今回のバンドル108/161/164では、x_eqはTsubに対する追加説明力が小さい。

また、PM_F1とx_eqの相関も弱い。

```text
PM_F1 vs x_eq:
  R2 ≈ 0.039
```

したがって、F1(Tsub)をF(x_eq)へ置換する方向には進まない。

ただし、単管側ではHsub + P + x_eqでTable12 long正残差がほぼ消えたため、x_eqを完全に捨てるわけではない。

x_eqは熱収支状態量・診断項として保留する。

##### H5：ケース代表性・適用範囲の問題として扱う

対象は108/161/164の3ケース群である。

3ケースだけで一般化すると危険である。

特に、以下が同時に変化している。

```text
F_form
DNB位置
z_DNB/DH
z_DNB/L
L/DH
Tsub
x_eq
```

したがって、PM_F1残差は、補正式化せず、代表性・条件範囲・非一様加熱換算の診断課題として残すのが安全である。

#### 7. BT06で分かったこと

BT06の判断は以下である。

```text
F1後のPM_F1は、108でやや過大、161/164でやや過小に残る。

ただし全体としては1近傍であり、大外れではない。

F1後残差は、Tsub/x_eqよりも、F_form、DNB位置、L/DH、ケース構造側と対応しやすい。

しかし、F_form、z_DNB/DH、L/DHは強く交絡している。

したがって、F_form原因説、z_DNB/DH原因説、L/DH原因説のどれか一つにはまだ決めない。

F1(Tsub)は維持する。
F1(Tsub)をF(x_eq)へ置換しない。
L/DH補正式にも進まない。

PM_F1残差は、F_form・DNB位置・L/DH・ケース構造・適用範囲の診断課題として残す。
```

#### 8. 現時点で言ってよいこと

```text
- F1後のP/Mは、108がやや過大、161/164がやや過小である。
- ただし、F1後のP/Mは全体として1近傍である。
- F1後残差は、Tsub/x_eqよりもF_form・DNB位置・L/DH側と対応しやすい。
- F_form、z_DNB/DH、L/DHは互いに交絡している。
- F_formはF1ではなく、非一様加熱分布の局所熱流束基準換算係数である。
- L/DHは診断項としては残すが、補正式候補にはしない。
- x_eqはF1置換候補ではなく、診断項として保留する。
```

#### 9. まだ言ってはいけないこと

```text
- F_formがPM_F1残差の原因であるとは言わない。
- z_DNB/DHがPM_F1残差の原因であるとは言わない。
- L/DHがPM_F1残差の原因であるとは言わない。
- L/DH補正式を作るとは言わない。
- F1(Tsub)をF(x_eq)へ置換するとは言わない。
- BT06の探索モデルを補正式として採用しない。
```

#### 10. BT05からの認識更新

BT05では、x_eqがTsubに対して追加説明力をほとんど持たないことを確認した。

BT06では、その上で、F1後残差がTsub/x_eq側ではなく、F_form・DNB位置・L/DH側に残っていることを確認した。

したがって、BT05後の認識を以下のように更新する。

```text
BT05後：
  x_eqはF1(Tsub)の置換候補としては弱い。
  ただしF1後残差の扱いは未整理だった。

BT06後：
  F1後残差は、x_eq/Tsubではなく、
  F_form・DNB位置・L/DH・ケース構造として残っている可能性が高い。
  ただし、それらは強く交絡しており、原因の単独断定はできない。
```

#### 11. 採用・保留・撤回気味

```text
採用：
  F1(Tsub)は維持する。

採用：
  F1(Tsub)をF(x_eq)へ置換する根拠は弱い。

採用：
  F1後残差は、Tsub/x_eqよりもF_form・DNB位置・L/DH側に残っている。

採用：
  F_form、z_DNB/DH、L/DHは強く交絡しているため、単独原因の断定はしない。

採用：
  L/DH補正式には進まない。

保留：
  F_form定義・非一様加熱換算・DNB位置の扱いを追加確認すること。

保留：
  PM_F1残差をモデル適用範囲・代表性の問題として扱うこと。

保留：
  単管側ST-BT05相当、すなわちHsub/P/Tsubとx_eqの切り分け診断。

撤回気味：
  F1(Tsub)をF(x_eq)へ置換する案。

撤回気味：
  PM_F1とL/DHの相関からL/DH補正式を作る案。
```

#### 12. 次アクション

BT06の結果から、次に進むなら、BT07として以下を確認するのが自然である。

```text
BT07：
F_form定義・非一様加熱換算・DNB位置の扱い確認

目的：
  PM_F1残差に対応して見えるF_form、z_DNB/DH、L/DHのうち、
  何が計算上の定義・換算方法に由来し、
  何が物理的な履歴差として残っているのかを整理する。
```

BT07で特に確認すべき点は以下である。

```text
1. F_formの定義が、DNB位置の局所熱流束基準と整合しているか。
2. F_form = 青面積 / オレンジ面積 の扱いが、108/161/164で同じ意味になっているか。
3. DNB位置が変わることで、F_formとz_DNB/DHがどの程度同時に変わるか。
4. 108のF_formが小さい理由は、出力分布形状なのか、DNB位置なのか。
5. 161/164のF_formが大きい理由は、DNB位置が出口寄りであることによるのか。
6. PM_F1残差を補正式ではなく、非一様加熱換算・DNB位置診断として残すべきか。
```

ただし、BT07でもまだ補正式は作らない。

また、別タスクとして、後で必ず単管側のST-BT05相当を行う。

```text
ST-BT05：
単管側で、Hsub/P/Tsubとx_eqの独立効果を切り分ける。

目的：
  単管ではHsub + P + x_eqが効いたように見えたが、
  x_eqがHsub/P/Tsubに対して独立に効いたのかを確認する。
```

---

---

### 2026-06-16　BT07：F_form定義・非一様加熱換算・DNB位置の扱い確認

#### 位置づけ

BT06では、F1後のPM_F1残差が、Tsub/x_eq側ではなく、F_form・DNB位置・L/DH・ケース構造側に残っている可能性が高いと整理した。

ただし、BT06時点では、F_formをどう読むべきかがまだ未整理であった。

そのためBT07では、以下を確認した。

```text
F_formはPM_F1残差の原因なのか。
それとも、DNB位置・軸方向出力分布・L/DH・ケース構造を含む診断項なのか。
```

BT07でも補正式は作らない。

また、F_formをF1の効き方として読まない。

F_formは、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。

#### 入力と出力

```text
入力：
H52Q_current_bundle_input_v1_20260615_180822.xlsx

出力：
BT07_Fform_DNB_position_diagnostic_20260616_112751.xlsx
run_report_BT07_Fform_DNB_position_diagnostic_20260616_112751.md
```

#### 前提

```text
- r8 resultブックは直接読まない。
- current_bundle_inputを読む。
- F2/F1F2は使わない。
- 比較対象はnoF1とF1のみ。
- F1(Tsub)は維持する。
- F1(Tsub)をF(x_eq)へ置換しない。
- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。
- BT07では補正式を作らない。
```

#### 1. F_form再計算可能性の確認

BT07では、まず `current_bundle_input` だけでF_formを青面積/オレンジ面積から再計算できるかを確認した。

結果は以下であった。

```text
F_form列：
  あり

DNB位置列：
  あり

L列：
  あり

DH列：
  あり

軸方向出力分布の元配列：
  見当たらない
```

したがって、BT07ではF_formそのものを青面積/オレンジ面積から再計算することはできなかった。

このため、BT07の位置づけを以下のように限定する。

```text
BT07はF_form式の再計算監査ではない。

BT07は、既に計算済みのF_formが、
PM_F1、DNB位置、L/DH、ケース構造とどう対応しているかを見る
F_form挙動診断である。
```

F_form定義そのものを監査するには、F_form作成元または軸方向出力分布データが別途必要である。

#### 2. ケース別F_formとDNB位置

ケース別の平均値は以下であった。

```text
108:
  F_form ≈ 0.669
  z_DNB/L ≈ 0.738
  z_DNB/DH ≈ 140
  L/DH ≈ 189
  PM_F1 ≈ 1.067

161:
  F_form = 1.000
  z_DNB/L ≈ 0.997
  z_DNB/DH ≈ 361
  L/DH ≈ 362
  PM_F1 ≈ 0.909

164:
  F_form ≈ 1.346
  z_DNB/L ≈ 0.791
  z_DNB/DH ≈ 287
  L/DH ≈ 362
  PM_F1 ≈ 0.892
```

108はF_formが1より小さい。

161はF_formがほぼ1である。

164はF_formが1より大きい。

この時点で、F_formはケース間で大きく異なる。

#### 3. 108と161/164の対比

108と161/164平均の差は以下である。

```text
PM_F1:
  108 - mean(161,164) ≈ +0.166

F_form:
  108 - mean(161,164) ≈ -0.504

z_DNB/L:
  108 - mean(161,164) ≈ -0.156

z_DNB/DH:
  108 - mean(161,164) ≈ -184

L/DH:
  108 - mean(161,164) ≈ -173
```

108はPM_F1が高めに残る一方で、F_form、z_DNB/DH、L/DHは小さい。

ただし、この差をそのまま

```text
F_formがPM_F1残差の原因である
```

とは読まない。

F_form、DNB位置、L/DH、ケース番号が同時に変化しているためである。

#### 4. PM_F1とF_formの対応

点群相関では、PM_F1とF_formには中程度の対応があった。

```text
PM_F1 vs F_form:
  R2 ≈ 0.240
```

これは、F_formがPM_F1残差と無関係ではないことを示す。

ただし、PM_F1との相関はL/DHやz_DNB/DHにも見える。

```text
PM_F1 vs L/DH:
  R2 ≈ 0.390

PM_F1 vs z_DNB/DH:
  R2 ≈ 0.284

PM_F1 vs F_form:
  R2 ≈ 0.240
```

したがって、F_formだけが特別にPM_F1残差を説明しているとは言えない。

BT07では、F_formはPM_F1残差と対応するが、原因とは断定しない。

#### 5. F_formとDNB位置の関係

BT07で特に重要なのは、F_formとDNB位置の関係である。

軸同士の相関は以下であった。

```text
F_form vs z_DNB/L:
  R2 ≈ 0.0046

F_form vs z_DNB/DH:
  R2 ≈ 0.291

F_form vs L/DH:
  R2 ≈ 0.643

z_DNB/DH vs L/DH:
  R2 ≈ 0.853
```

F_formは、z_DNB/Lだけではほとんど説明されない。

これは重要である。

108と164はどちらも `z_DNB/L < 0.8` 側に近いが、F_formは大きく異なる。

```text
108:
  z_DNB/L ≈ 0.738
  F_form ≈ 0.669

164:
  z_DNB/L ≈ 0.791
  F_form ≈ 1.346
```

したがって、F_formは単なるDNB相対位置ではない。

F_formは、DNB位置だけでなく、軸方向出力分布形状を含んだ量として読む必要がある。

#### 6. F_formとL/DHの交絡

F_formとL/DHには比較的強い対応がある。

```text
F_form vs L/DH:
  R2 ≈ 0.643
```

また、z_DNB/DHとL/DHの対応はさらに強い。

```text
z_DNB/DH vs L/DH:
  R2 ≈ 0.853
```

このため、PM_F1とL/DHの対応が見えるとしても、それは純粋なL/DH効果とは限らない。

L/DHは以下をまとめて代表している可能性がある。

```text
全加熱長
DNB位置までの履歴長
F_form
非一様加熱分布
ケース番号
```

したがって、BT07でもL/DH補正式には進まない。

#### 7. ケース内相関の確認

ケース内相関を見ると、161ではF_form、z_DNB/L、z_DNB/DH、L/DHがほぼ一定であり、ケース内の変動を説明する軸になっていなかった。

```text
161:
  F_form = 1
  z_DNB/L ≈ 0.997
  z_DNB/DH ≈ 361
  L/DH ≈ 362
```

108および164では、F_formやz_DNB位置に多少の変動があるが、点群全体で見えるF_form相関のかなりの部分は、ケース間差に由来している可能性が高い。

したがって、F_formの点群相関を、連続的なF_form補正式の根拠として読むのは危険である。

#### 8. F_formクラス別の整理

F_formクラス別に見ると、以下のようであった。

```text
Fform < 0.90:
  主に108
  PM_F1平均 ≈ 1.067

Fform ≈ 1:
  主に161、一部164
  PM_F1平均 ≈ 0.900

Fform > 1.10:
  主に164
  PM_F1平均 ≈ 0.902
```

F_formが小さい108ではPM_F1が高く、F_formが1以上の161/164ではPM_F1が低めに残る。

ただし、これはF_formそのものの連続効果というより、ケース構造を反映している可能性がある。

#### 9. BT07で分かったこと

BT07の判断は以下である。

```text
current_bundle_inputだけでは、F_formを青面積/オレンジ面積から再計算できない。

したがって、BT07はF_form式の再計算監査ではなく、F_form挙動診断である。

F_formはケース間で大きく異なる。

F_formはPM_F1残差と中程度に対応する。

しかし、F_formはz_DNB/Lだけではほとんど説明されない。

F_formは、DNB位置だけでなく、軸方向出力分布形状を含む量として読む必要がある。

F_form、z_DNB/DH、L/DHは交絡している。

したがって、F_form原因説、DNB位置原因説、L/DH原因説のどれか一つには決めない。

PM_F1残差は、非一様加熱換算・DNB位置・L/DH・ケース構造の診断課題として残す。
```

#### 10. 現時点で言ってよいこと

```text
- F_formはPM_F1残差と無関係ではない。
- ただし、F_formはF1ではない。
- F_formはDNB位置の相対位置だけでは説明されない。
- F_formは軸方向出力分布形状とDNB位置の組合せを含む可能性が高い。
- current_bundle_inputだけではF_formを再計算監査できない。
- F_form、z_DNB/DH、L/DHは交絡している。
- PM_F1残差は、補正式ではなく非一様加熱換算・DNB位置・ケース構造の診断課題として残す。
```

#### 11. まだ言ってはいけないこと

```text
- F_formがPM_F1残差の原因であるとは言わない。
- F_form補正式を作るとは言わない。
- F_formをF1の効き方として読むとは言わない。
- z_DNB/LだけでF_formを説明できるとは言わない。
- L/DHがPM_F1残差の原因であるとは言わない。
- L/DH補正式に戻るとは言わない。
```

#### 12. BT06からの認識更新

BT06では、F1後残差がF_form・DNB位置・L/DH側に残っている可能性があると整理した。

BT07では、そのうちF_formについて一段詳しく見た。

その結果、以下のように更新する。

```text
BT06時点：
  F1後残差はF_form・DNB位置・L/DH側に残っている可能性がある。

BT07後：
  F_formはPM_F1残差と対応して見えるが、
  F_formはz_DNB/Lだけでは説明されない。
  F_formは軸方向出力分布形状とDNB位置の組合せを含む量であり、
  L/DHやケース構造とも交絡している。

更新後の扱い：
  F_formは原因変数ではなく、
  非一様加熱換算・DNB位置・軸方向出力分布・ケース構造を含む診断項として扱う。
```

#### 13. 採用・保留・撤回気味

```text
採用：
  F1(Tsub)は維持する。

採用：
  F_formはF1ではない。

採用：
  F_formはPM_F1残差と中程度に対応する。

採用：
  F_formはz_DNB/Lだけでは説明されない。

採用：
  F_form、z_DNB/DH、L/DHは交絡している。

採用：
  current_bundle_inputだけでは、F_formの青面積/オレンジ面積再計算監査はできない。

保留：
  F_form作成元または軸方向出力分布データを確認すること。

保留：
  PM_F1残差を非一様加熱換算・DNB位置・ケース構造の問題として残すこと。

保留：
  単管側ST-BT05相当、すなわちHsub/P/Tsubとx_eqの切り分け診断。

撤回気味：
  F_form原因説。

撤回気味：
  F_formを使った補正式案。

撤回気味：
  PM_F1とL/DHの相関からL/DH補正式に戻る案。
```

#### 14. 次アクション

BT07の結果から、次の分岐は以下である。

```text
A. F_form作成元または軸方向出力分布データを確認できる場合：
   BT08として、F_form = 青面積 / オレンジ面積 の再計算監査を行う。

B. F_form作成元または軸方向出力分布データを確認できない場合：
   BT08では補正式化へ進まず、
   BT01〜BT07までのバンドル108/161/164整理をいったん統合し、
   現時点で何が言えて、何が保留かをまとめる。
```

BT08候補は以下である。

```text
BT08-A：
F_form再計算監査

目的：
  F_form = 青面積 / オレンジ面積 の定義が、
  108/161/164で同じ意味になっているかを確認する。

必要データ：
  軸方向出力分布
  DNB位置
  DNB位置局所出力
  DNB位置までの積分出力または平均出力
```

または、

```text
BT08-B：
BT01〜BT07バンドル診断の統合整理

目的：
  補正式化せず、
  108/161/164について、
  F1(Tsub)、x_eq、F_form、DNB位置、L/DH、非一様加熱換算の関係を
  研究ログとして統合する。
```

現時点では、F_form再計算に必要な軸方向出力分布元データが `current_bundle_input` に含まれていないため、すぐにBT08-Aへ進めるかは未確定である。

---

---

### 2026-06-16　BT08-A1d：F_formをlinear_v1として再定義・確定

#### 位置づけ

BT08-A1〜A1cにより、既存F_formには以下のような処理の混在があることが分かった。

```text
108：
  DNB位置近くに既存点があったため、
  線形補間しなくても近い値が得られていた。

164：
  DNB位置と既存点のズレが気になったため、
  f_DNB側は線形補間していた。

164通常ケースのBlue_area：
  本来はDNB位置まで線形補間して積分すべきところ、
  急いでいたため、SUM範囲に -0.01 のような暫定補正を入れていた可能性が高い。
  ただし、その補正量は線形積分値に合わせるには不十分だった。
```

このため、既存F_formをそのまま正本値として扱うのではなく、全ケースで同じ定義にそろえたF_formを作り直すことにした。

#### linear_v1の定義

BT08-A1dでは、F_formを以下の統一ルールで再定義した。

```text
x_DNB = DNB位置 / 加熱長

f_DNB = interp1(x, f, x_DNB)

Blue_area_linear =
  入口 x=0 から DNB位置 x_DNB まで、
  軸方向出力分布 f(x) を線形補間込みで積分した面積

Orange_area_linear =
  x_DNB × f_DNB

F_form_linear =
  Blue_area_linear / Orange_area_linear
```

この定義を `linear_v1` と呼ぶ。

#### 既存F_formとの関係

既存Fformは、作業当時の判断を含む値として `legacy` として残す。

`linear_v1` は、今後の正本候補として使う。

```text
F_form_legacy：
  current_bundle_inputに入っている既存Fform

F_form_linear：
  全ケースを線形補間・線形積分に統一して再計算したFform

F_form_diff_linear_minus_legacy：
  定義変更による差
```

#### linear_v1の計算結果

```text
108_70in:
  F_form_legacy = 0.65432795
  F_form_linear = 0.61982066
  diff = -0.03450729
  ratio = 0.947263

108_76in:
  F_form_legacy = 0.760494
  F_form_linear = 0.73367994
  diff = -0.02681406
  ratio = 0.964741

161_uniform:
  F_form_legacy = 1.000000
  F_form_linear = 1.000000
  diff = 0
  ratio = 1.000000

164_112in:
  F_form_legacy = 1.014
  F_form_linear = 0.8776443
  diff = -0.1363557
  ratio = 0.865527

164_134in_normal:
  F_form_legacy = 1.363
  F_form_linear = 1.2999932
  diff = -0.06300683
  ratio = 0.953773
```

#### 解釈

linear_v1では、全ケースでFformが既存値以下になった。

これは、既存FformではDNB位置を含む区間まで足す、または手作業補正を加えるなど、DNB位置より下流側の面積が部分的に含まれていた可能性があるためである。

linear_v1では、DNB位置で厳密に切るため、Blue_areaが小さくなり、その結果F_formも小さくなる。

特に164_112inでは差が大きく、legacyとの差は約 -0.136であった。

これは、164_112inの既存Fformが間違いというより、既存Fformが「DNB位置までの線形積分」ではなく、より大きいBlue_areaを使う定義だったことを示している。

#### 採用判断

```text
採用：
  F_form定義は linear_v1 とする。

採用：
  Excelを直接いじってFformを修正しない。

採用：
  MATLAB計算結果とMarkdownログでFform定義を確定する。

採用：
  既存Fformはlegacyとして残す。

採用：
  current_bundle_input_v2には、
  F_form_linear と F_form_legacy の両方を入れる。

採用：
  F_form_diff_linear_minus_legacy も残す。
```

#### まだやらないこと

```text
- この段階ではP/Mへの影響はまだ評価しない。
- current_bundle_inputはまだ直接更新しない。
- F_formを新しい補正式として解釈しない。
- F_formは非一様加熱分布をDNB位置の局所熱流束基準へ換算するための幾何・履歴情報として扱う。
```

#### current_bundle_input_v2に入れるべき列

```text
Fform_definition_version
Fform_source_book
Fform_source_sheet
Fform_case_label
Fform_DNB_z_ratio
Fform_q_DNB_linear
Fform_blue_area_linear
Fform_orange_area_linear
Fform_linear
Fform_legacy
Fform_diff_linear_minus_legacy
Fform_ratio_linear_to_legacy
Fform_status
Fform_definition_note
```

#### 結論

F_formは、今後 `linear_v1` を正本候補として扱う。

既存Fformは、過去のExcel作業に由来するlegacy値として残す。

今後はExcelを手作業で修正せず、MATLABコードとMarkdownログによりF_formの定義・値・出典を管理する。

---

---

## 2026-06-16 追記：BT08-A2b〜BT09-B、F_form linear_v1の入力化・マクロ再計算完了

### 位置づけ

BT08-A1dで `F_form` を `linear_v1` として再定義した後、その値を実際のマクロ計算へ反映するための一連の作業を行った。

ここでの目的は、単にF_formを直すことではなく、以下を明確に分離することだった。

```text
legacy F_form：
  これまでマクロブックに入っていた既存値。
  Excel手作業・暫定処理・区間込み積分などが混在していた可能性がある。

Fform_linear_v1：
  DNB位置で線形補間し、入口からDNB位置までを線形積分して求めた再定義値。
  今後の正本候補。
```

重要なのは、既存の `F_form` を直接上書きするのではなく、`Fform_legacy` と `Fform_linear` を両方残し、差分を追跡できる形にしたことである。

---

### BT08-A2：current_bundle_input_v2作成

最初に、`current_bundle_input_v1` に `Fform_linear` 関連列を追加する作業を行った。

ただし、最初のBT08-A2では、`tm_F1_108 / tm_F1_161 / tm_F1_164` のF1側3シートだけが対象になり、noF1側の `tm_108 / tm_161 / tm_164` は対象外になっていた。

これは失敗というより、シート名判定がF1側に寄っていたためである。

F_formはF1補正そのものではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数なので、noF1/F1の両方に同じFform定義を持たせる必要がある。

---

### BT08-A2b：noF1/F1両方を含むcurrent_bundle_input_v2b作成

BT08-A2bとして修正版を作成した。

対象シートは以下の6シートとした。

```text
tm_108
tm_161
tm_164
tm_F1_108
tm_F1_161
tm_F1_164
```

BT08-A2bでは、6シートすべてに以下のような列を追加した。

```text
Fform_definition_version
Fform_target_kind
Fform_case_label
Fform_DNB_z_ratio_linear
Fform_q_DNB_linear
Fform_blue_area_linear
Fform_orange_area_linear
Fform_linear
Fform_legacy
Fform_diff_linear_minus_legacy
Fform_ratio_linear_to_legacy
Fform_mapping_status
Fform_definition_note
```

結果として、noF1側58行、F1側58行、合計116行がすべてマップされた。

この時点で、`current_bundle_input_v2b` をFform管理用の正本候補として扱える状態になった。

---

### BT08-A3：マクロ投入用F_form差し替え表の確定

次に、マクロブックへFform_linearを投入するための差し替え表を作成した。

ここではまだマクロブックは編集していない。

作ったものは、以下の考え方である。

```text
original_value：
  legacy F_form

replace_value：
  Fform_linear_v1

差し替えキー：
  No

対象：
  noF1 58行
  F1 58行
```

BT08-A3のQCでは、以下が確認された。

```text
差し替え表の行数：
  116行

内訳：
  noF1 = 58行
  F1   = 58行

対象シート：
  6シート

マップ状態：
  116/116行すべてマップ済み

DNB位置対応差：
  最大 0.00012955455 程度で小さい

最大Fform変更量：
  0.1363557
```

このため、マクロ投入用のF_form差し替え表は確定してよいと判断した。

---

### BT09-0：マクロブック側のF_form入力位置確認

次に、マクロブック側でF_formがどこに入っているかを監査した。

F1なし版とF1あり版の2つを診断した。

結果として、両方とも構造は同じだった。

```text
対象シート：
  tm

No列：
  M列

F_form列：
  BG列

ヘッダ行：
  1行目

データ開始行：
  2行目
```

A3側では `tm_108 / tm_161 / tm_164 / tm_F1_...` のようにシートを分けて管理していたが、マクロブック側ではすべて `tm` シートにまとまっていた。

したがって、マクロブックへ反映する際は、シート名ではなく `No` をキーにするのが正しい。

---

### BT09-A：コピー版マクロブックへのFform_linear投入

BT09-Aでは、元マクロブックを直接編集せず、コピー版を作ってから `tm` シートの `BG列 = F_form` だけを `Fform_linear` に差し替えた。

処理対象は以下の2ブックである。

```text
F1なし版：
  celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし.xlsm

F1あり版：
  celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm
```

出力されたコピー版は以下である。

```text
F1なし linear版：
  celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm

F1あり linear版：
  celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm
```

BT09-Aでは、以下が確認された。

```text
処理したマクロブック数：
  2

置換行：
  noF1 = 58行
  F1   = 58行

旧値とA3 original_valueの不一致：
  0件

変更対象：
  tmシート BG列のみ

元マクロブック：
  上書きしていない

マクロ実行：
  まだ実行していない
```

この時点で、Fform_linearを投入したマクロブックコピーが準備できた。

---

### BT09-B：コピー版マクロブックで再計算

その後、ユーザー側でコピー版マクロブックを開き、マクロ再計算を実施した。

つまり、BT09-Bは完了した。

再計算後のブックは以下である。

```text
noF1再計算後：
  celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm

F1再計算後：
  celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm
```

---

### BT10一次診断：FformLinear化によるP/M影響

BT09-B後のマクロブックを読み取り、BT10として一次診断を行った。

#### noF1側

```text
108：
  PM 0.621831 → 0.653049
  ΔPM = +0.031218

161：
  PM 0.620980 → 0.620980
  ΔPM = 0

164：
  PM 0.570923 → 0.597862
  ΔPM = +0.026939
```

noF1では、108と164は少し上がった。
ただし、noF1全体としてはまだ過小評価側にある。

#### F1側

旧F1代表値は以下だった。

```text
108：
  PM = 1.06679

161：
  PM = 0.908841

164：
  PM = 0.892018
```

FformLinear再計算後は以下になった。

```text
108：
  PM = 1.123223
  ΔPM = +0.056433

161：
  PM = 0.908841
  ΔPM ≒ 0

164：
  PM = 0.939561
  ΔPM = +0.047543
```

---

### 現時点の解釈

FformLinear化により、F_form値はlegacyより小さくなった。
その結果、今回のマクロ実装では qP / PM が上昇した。

これは、マクロ内でF_formがqPに対して実質的に「割る側」に効いているためと考えられる。

重要な変化は以下である。

```text
旧F1：
  108はやや高め
  161/164は低め

F1 + FformLinear_v1：
  108はさらに過大側へ移動
  161は変化なし
  164はかなり改善
```

したがって、legacy Fformの暫定処理は、164の低め残差を一部作っていた可能性がある。

ただし、FformLinear化だけで全体が整理されたとは言えない。
108はむしろ悪化し、過大側に動いたためである。

---

### 判断

```text
採用：
  FformLinear_v1でマクロ再計算できた。

採用：
  FformLinear_v1は、legacy Fformより定義としては一貫している。

採用：
  マクロブックへの投入は、NoキーでtmシートBG列を差し替える方法で成立した。

採用：
  元マクロブックは上書きせず、コピー版で処理できた。

注意：
  FformLinear化により164は改善する。

注意：
  FformLinear化により108は過大側へ悪化する。

注意：
  161は一様加熱のためFform変更の影響を受けない。

保留：
  F1 + FformLinear_v1を最終採用してよいかは、108過大化の扱いを見て判断する。

保留：
  FformLinear後の残差構造を、Tsub / x_eq / z_DNB / L/DH / Fform_linear / Bundleで再診断する必要がある。
```

---

### 次にやること

次はBT10-Bとして、FformLinear後の残差構造を再診断する。

見るべきものは以下である。

```text
PM_F1_linear
residual_F1_linear = PM_F1_linear - 1

説明候補：
  Tsub
  x_eq
  z_DNB/DH
  z_DNB/L
  L/DH
  Fform_linear
  Bundle
```

特に確認したいのは以下である。

```text
1. 108の過大化は、FformLinear定義の問題か。
2. 164の改善は、legacy Fformの暫定処理による低め残差の解消と見てよいか。
3. 161が低いままなのは、Fformでは説明できない残差か。
4. F1(Tsub)維持判断は変わらないか。
5. FformLinear_v1を正本にするか、legacyと併記して感度扱いにするか。
```

---

---

## 2026-06-16 追記：BT10-B/BT10-C、FformLinear_v1再計算後の残差診断と採用判断

### 位置づけ

BT09-Bで、FformLinear_v1を投入したnoF1版・F1版マクロブックの再計算が完了した。

その後、BT10-BとしてFformLinear_v1再計算後の残差構造を再診断し、さらにBT10-Cとしてlegacy F_formとFformLinear_v1を比較し、FformLinear_v1を正本候補にするか、legacy併記の感度ケースとして扱うかを判断するための整理を行った。

この段階でも、補正式は作らない。

前提は以下である。

```text
- F1(Tsub)は維持する。
- F1(Tsub)をF(x_eq)へ置換しない。
- F_formはF1ではない。
- F_formは非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。
- FformLinear_v1は、F_form定義の一貫化であり、残差補正式ではない。
- qMは結果側量なので補正式入力には使わない。
- R2が高いモデルを補正式として採用しない。
```

---

### BT10-B：FformLinear_v1後の残差構造

BT10-Bでは、FformLinear_v1版のnoF1/F1マクロブックを読み、以下を確認した。

```text
PM_noF1_linear
PM_F1_linear
err_F1_linear = PM_F1_linear - 1
delta_PM_linear = PM_F1_linear - PM_noF1_linear
lift_ratio_linear = PM_F1_linear / PM_noF1_linear
```

F1 + FformLinear_v1後のケース平均は以下であった。

```text
108:
  PM_F1_linear = 1.123223
  err_F1_linear = +0.123223

161:
  PM_F1_linear = 0.908841
  err_F1_linear = -0.091159

164:
  PM_F1_linear = 0.939561
  err_F1_linear = -0.060439
```

この結果から、FformLinear_v1化により、164は改善した一方、108は過大側へ悪化した。

161は一様加熱であり、F_form変更の影響を受けないため、不変であった。

---

### BT10-B：残差はTsub/x_eq側ではなく、Fform/DNB位置/L_DH側に残る

BT10-Bでは、PM_F1_linearに対する単独説明力を確認した。

主な結果は以下である。

```text
PM_F1_linear vs Tsub:
  R2 ≈ 0.006

PM_F1_linear vs x_eq:
  R2 ≈ 0.032

PM_F1_linear vs Fform_linear:
  R2 ≈ 0.243

PM_F1_linear vs z_DNB/DH:
  R2 ≈ 0.444

PM_F1_linear vs z_DNB/L:
  R2 ≈ 0.221

PM_F1_linear vs L/DH:
  R2 ≈ 0.477
```

したがって、FformLinear_v1後のF1残差は、Tsub/x_eq側にはあまり残っていない。

むしろ、Fform_linear、DNB位置、L/DH、ケース構造側に残っている。

ただし、これは補正式を作る根拠ではない。

理由は、説明候補同士の交絡が強いためである。

```text
Fform_linear vs L/DH:
  R2 ≈ 0.714

z_DNB/DH vs L/DH:
  R2 ≈ 0.853

z_DNB/DH vs z_DNB/L:
  R2 ≈ 0.740

x_eq vs Tsub:
  R2 ≈ 0.704
```

特に、Fform_linear、z_DNB/DH、L/DHは強く交絡している。

したがって、PM_F1_linearとL/DHの相関が高く見えても、それを純粋なL/DH効果とは読まない。

同様に、Fform_linearまたはz_DNB/DHが原因であるとも断定しない。

---

### BT10-Bの判断

BT10-B時点の判断は以下である。

```text
FformLinear_v1後、164は改善し、108は過大側へ悪化する。

F1後残差は、Tsub/x_eq側ではなく、Fform_linear、DNB位置、L/DH、ケース構造側に残る。

ただし、Fform_linear、z_DNB/DH、L/DHは強く交絡している。

したがって、Fform補正式、L/DH補正式、z_DNB/DH補正式には進まない。
```

---

### BT10-C：legacy F_formとFformLinear_v1の比較

BT10-Cでは、legacy F_formとFformLinear_v1を比較した。

目的は、FformLinear_v1を正本候補にするか、legacy併記の感度ケースとして扱うかを判断することである。

F1後P/Mのbundle平均は以下であった。

```text
108:
  legacy       = 1.066789
  linear_v1    = 1.123223
  差           = +0.056434

161:
  legacy       = 0.908841
  linear_v1    = 0.908841
  差           = 0

164:
  legacy       = 0.892018
  linear_v1    = 0.939561
  差           = +0.047542
```

108は、legacyでもやや過大側であったが、FformLinear_v1によりさらに過大側へ動いた。

164は、legacyでは過小側であったが、FformLinear_v1によりPM=1へ近づいた。

161は一様加熱なので変化しない。

---

### 誤差指標の比較

BT10-Cでは、row重みおよびbundle平均の誤差指標も確認した。

row重み全体では以下である。

```text
row_weighted_all_MAE_F1:
  legacy    = 0.095726
  linear_v1 = 0.099594
  差        = +0.003868
  → MAEはわずかに悪化

row_weighted_all_RMSE_F1:
  legacy    = 0.128179
  linear_v1 = 0.126960
  差        = -0.001219
  → RMSEはわずかに改善

row_weighted_all_bias_F1:
  legacy    = -0.059125
  linear_v1 = -0.028289
  差        = +0.030836
  → 全体バイアスは0に近づくが、評価上は108過大化を含む
```

bundle平均を同じ重みで見ると以下である。

```text
bundle_mean_MAE_F1:
  legacy    = 0.088643
  linear_v1 = 0.091607
  差        = +0.002964
  → 少し悪化

bundle_mean_RMSE_F1:
  legacy    = 0.090242
  linear_v1 = 0.095126
  差        = +0.004884
  → 少し悪化

bundle_mean_bias_F1:
  legacy    = -0.044117
  linear_v1 = -0.009458
  差        = +0.034659
  → 平均バイアスは0に近づく
```

したがって、FformLinear_v1は一様に性能改善するわけではない。

164を改善する一方で、108を悪化させる。

全体バイアスは0に近づくが、MAEやbundle平均RMSEでは悪化側に見える。

---

### FformLinear_v1の扱い

BT10-Cでの推奨扱いは以下である。

```text
FformLinear_v1は、legacyより定義としては一貫している。

ただし、予測性能としては混在結果である。

164は改善する。
108は悪化する。
161は変化しない。

したがって、FformLinear_v1を「残差補正式」として採用してはいけない。

FformLinear_v1は、
  F_form定義の正規化候補
  または legacy併記の感度ケース
として扱う。
```

より具体的には、以下の2案が残る。

```text
Option 1:
  FformLinear_v1を正本候補とする。
  legacyは比較・感度として残す。
  ただし、108過大化を必ず併記する。

Option 2:
  短期的にはlegacyを主結果として残し、
  FformLinear_v1を感度ケースとして併記する。
  報告前の保守的運用としては安全。
```

現時点で避けるべき案は以下である。

```text
避ける：
  FformLinear後の残差を、さらにFform/L_DH/z_DNBで補正すること。

避ける：
  FformLinear作業を完全撤回し、legacyだけで進むこと。
```

完全撤回しない理由は、164低め残差の一部がlegacy F_form定義に由来していた可能性があるためである。

---

### 判断

BT10-C時点の判断を以下のように固定する。

```text
採用候補：
  FformLinear_v1は、F_form定義としてlegacyより一貫している。

採用：
  F1(Tsub)は維持する。

採用：
  F1(Tsub)をF(x_eq)へ置換しない。

採用：
  FformLinear_v1を残差補正式として扱わない。

採用：
  L/DH、z_DNB/DH、Fform_linearから新しい補正式を作らない。

注意：
  FformLinear_v1は164を改善する。

注意：
  FformLinear_v1は108を過大側へ悪化させる。

注意：
  161は一様加熱なので変化しない。

保留：
  FformLinear_v1を正本にするか、legacy主・linear感度にするか。

保留：
  108過大化を、軸方向出力分布・DNB位置・Fform定義のどの問題として扱うか。

撤回気味：
  FformLinear後の残差をさらに補正式化する案。
```

---

### 次アクション

次はBT11として、FformLinear_v1の扱いを作業方針として固定する。

候補は以下である。

```text
BT11-A：
  FformLinear_v1を正本候補として採用。
  legacyを感度比較として併記する。

BT11-B：
  legacyを主結果として残し、
  FformLinear_v1を感度ケースとして併記する。

BT11-C：
  FformLinear_v1とlegacyの両方を保持し、
  現時点ではどちらも最終正本にしない。
```

現時点での推奨は、BT11-Cに近い。

つまり、

```text
FformLinear_v1は定義としては正本候補。
ただし、性能面では混在するため、legacyとの比較を必ず併記する。

当面は、
  FformLinear_v1 = 定義正規化ケース
  legacy = 既往計算との比較ケース
として両方を保持する。
```

この判断をログに残した上で、次フェーズでは、FformLinear_v1を使って新たな補正式を作るのではなく、108過大化と164改善の物理的意味を、非一様加熱分布・DNB位置・局所熱流束基準換算の観点から確認する。

---
---

## 2026-06-16 追記：BT11-A、FformLinear_v1を正本採用し、legacy F_formは廃止扱いにする

### 位置づけ

BT10-B/BT10-Cでは、FformLinear_v1を投入したマクロ再計算結果を確認し、legacy F_formとの比較を行った。

BT10-Cでは一度、FformLinear_v1を「正本候補」としつつ、legacyを感度比較として併記する案も残した。

しかし、その後の整理により、legacy F_formは独立した物理モデルや感度ケースではなく、DNB位置の局所熱流束基準と整合しない暫定処理・定義ミスであったと判断した。

したがって、BT11-Aとして以下を採用する。

```text
FformLinear_v1：
  今後の正本として採用する。

legacy F_form：
  感度比較ケースとは扱わない。
  旧計算とのトレーサビリティ、作業履歴、ミスの記録としてのみ残す。
```

---

### 判断理由

F_formは、F1(Tsub)とは別の量であり、軸方向非一様加熱分布をDNB位置の局所熱流束基準へ換算するための係数である。

この定義から見ると、F_formは以下で扱うべきである。

```text
F_form = DNB位置までの加熱分布面積 / DNB位置局所熱流束で作る矩形面積
```

すなわち、

```text
FformLinear_v1 = Blue_area_linear / Orange_area_linear
```

が現在の定義として一貫している。

一方、legacy F_formには、青面積そのものに近い扱いや、手作業・暫定処理が混在していた可能性があり、DNB位置の局所熱流束基準換算としては不整合である。

そのため、legacy F_formを「別の物理仮定に基づく感度ケース」として扱うのは適切ではない。

legacyは、あくまで旧計算の再現・修正履歴・監査用に保持する。

---

### BT10-C結果の扱い

BT10-Cでは、FformLinear_v1により以下の変化が確認された。

```text
108：
  PM_F1 = 1.066789 → 1.123223
  過大側へ悪化

161：
  PM_F1 = 0.908841 → 0.908841
  一様加熱のため変化なし

164：
  PM_F1 = 0.892018 → 0.939561
  過小評価が改善
```

この結果だけを見ると、FformLinear_v1は性能面で一様に改善するわけではない。

しかし、これはFformLinear_v1を退ける理由にはしない。

理由は、FformLinear_v1は残差補正式ではなく、F_form定義の修正だからである。

```text
性能が改善するから採用するのではない。
定義として正しいため採用する。
```

ただし、FformLinear_v1により108が過大側へ悪化することは重要な診断結果である。

これは、F_formを戻す理由ではなく、108側に残る別の未整理要因として扱う。

---

### 採用・廃止・保留

```text
採用：
  FformLinear_v1を今後のF_form正本とする。

採用：
  F1(Tsub)は維持する。

採用：
  F1(Tsub)をF(x_eq)へ置換しない。

採用：
  FformLinear_v1を残差補正式として扱わない。

採用：
  FformLinear_v1後の残差を、さらにFform/L_DH/z_DNBで補正式化しない。

廃止扱い：
  legacy F_formを主解析や感度比較ケースとして使うこと。

保持：
  legacy F_formは、旧計算の再現、ミスの記録、変更履歴、監査用として残す。

保留：
  FformLinear_v1後に108が過大側へ悪化する理由。

保留：
  108過大化を、非一様加熱分布、DNB位置、局所熱流束基準、ケース代表性のどれとして整理するか。
```

---

### 今後の運用

今後のバンドル解析では、F_formはFformLinear_v1を用いる。

legacy F_formは、以下の場合に限って参照する。

```text
1. 旧計算との差分を説明する場合
2. 修正履歴を確認する場合
3. なぜ164の低め残差が一部改善したかを説明する場合
4. 過去のマクロブックやログとの整合を確認する場合
```

一方で、legacy F_formを以下のようには使わない。

```text
- 物理的な感度ケース
- 正本候補
- 代替モデル
- 108過大化を避けるための調整値
```

---

### BT11-Aの結論

BT11-Aとして、以下を固定する。

```text
FformLinear_v1をF_formの正本として採用する。

legacy F_formは、感度比較ではなく、旧定義ミス・暫定処理の記録として保持する。

FformLinear_v1により164は改善し、108は過大側へ悪化するが、これはF_formをlegacyへ戻す理由ではない。

108過大化は、FformLinear_v1後に残った別の診断課題として扱う。

この段階でも、Fform/L_DH/z_DNBによる追加補正式は作らない。
```

---

---

## 2026-06-16 追記：BT12-A、current_bundle_input_v2_FformLinearCanonical作成

### 位置づけ

BT11-Aで、FformLinear_v1をF_formの正本として採用し、legacy F_formは感度比較ではなく旧定義ミス・監査用として扱う方針にした。

そのため、以後のバンドル解析で旧 `current_bundle_input_v1` を読み続けないよう、BT12-Aとして `current_bundle_input_v2_FformLinearCanonical` を作成した。

### 入力

```text
H52Q_current_bundle_input_v1_20260615_180822.xlsx
BT08A3_macro_Fform_replace_package_20260616_145859.xlsx
```

### 出力

```text
H52Q_current_bundle_input_v2_FformLinearCanonical_20260616_181819.xlsx
run_report_BT12_current_bundle_input_v2_FformLinearCanonical_20260616_181819.md
```

### 処理内容

対象シートは以下の6シートである。

```text
tm_108
tm_161
tm_164
tm_F1_108
tm_F1_161
tm_F1_164
```

処理方針は以下である。

```text
F_form = FformLinear_v1
F_form_legacy_deprecated = 旧F_form
Fform_definition_version = linear_v1
Fform_status = canonical
legacy_Fform_status = deprecated_definition_error_audit_only
```

つまり、通常解析が読む `F_form` 列そのものを、FformLinear_v1正本値に置換した。

legacy F_formは感度比較ではなく、旧定義ミス・監査用としてのみ保持する。

### QC結果

BT12-AのQCは正常であった。

```text
target_rows:
  116

mapped_rows:
  116 / 116

no_map_rows:
  0

canonical_equals_linear:
  116 / 116

old_value_vs_map_original:
  large_diff = 0
```

したがって、noF1 58行、F1 58行の合計116行すべてで、F_form列がFformLinear_v1に正しく置換された。

### sheet別の主な変化

```text
108:
  Fform_old_mean = 0.669495
  Fform_new_mean = 0.636086
  delta_mean     = -0.033408

161:
  Fform_old_mean = 1.000000
  Fform_new_mean = 1.000000
  delta_mean     = 0

164:
  Fform_old_mean = 1.346381
  Fform_new_mean = 1.279881
  delta_mean     = -0.066500
```

FformLinear_v1への置換により、108と164ではF_formが低下した。

161は一様加熱であり、F_form=1のまま変化しない。

### 判断

BT12-Aにより、FformLinear_v1を正本とした `current_bundle_input_v2` の作成は成功した。

以後のバンドル解析では、旧 `H52Q_current_bundle_input_v1_20260615_180822.xlsx` ではなく、v2系の入力を読む。

ただし、BT12-Aのv2は、QCや管理列が多く、解析入力としてはやや重い。

そのため、BT12-Aは以下の扱いにする。

```text
BT12-A full版：
  FformLinear_v1正本化の作成履歴・QC確認用

次のBT12-B minimal版：
  今後のBT解析で読むための最小構成入力
```

### 次アクション

次はBT12-Bとして、BT12-A full版を元に、解析用6シートだけを残したminimal版を作成する。

BT12-Bでは、READMEやQCシートはworkbook内に入れず、QCはrun_reportに残す。

minimal版では、通常解析に必要な列と、F_form監査に必要な最低限の列だけを残す。

---

---

## 2026-06-16 追記：BT12-B不採用とBT12-C tmCompatible版の採用

### 位置づけ

BT12-Aでは、FformLinear_v1をF_form正本として反映した `current_bundle_input_v2_FformLinearCanonical` を作成した。

その後、BT12-Bとして、以後のBT解析で読みやすい最小構成版を作成した。

しかし、BT12-B minimal版は、tmシートの列を削りすぎていた。

current_bundle_inputの重要な役割は、tmシートがマクロブック由来の列構成と対応していることである。

そのため、列数を減らしてしまうと、以後の解析や監査で、元マクロブックとの対応が崩れる。

この判断により、BT12-B minimal版は今後の入力としては不採用とした。

---

### BT12-Bの扱い

BT12-Bの出力は以下であった。

```text
H52Q_current_bundle_input_v2_minimal_FformLinearCanonical_20260616_183149.xlsx
run_report_BT12B_current_bundle_input_v2_minimal_20260616_183149.md
```

BT12-Bでは、各tmシートが82列から25列へ削減されていた。

また、run_report上で `PM` がmissing required columnsとして検出されていた。

これは「次BTで確認すればよい」ではなく、入力ブックとして必要列まで削ってしまった状態と判断した。

したがって、BT12-B minimal版は以下の扱いにする。

```text
BT12-B minimal版：
  不採用

理由：
  tmシートの列を削りすぎた。
  マクロブック由来の列構成との対応を壊した。
  current_bundle_inputとしての監査性・継続性が落ちる。
```

ただし、BT12-Bは完全に無駄ではない。

「必要最小限にしすぎると、tm互換性が壊れる」という運用上の失敗例としてログに残す。

---

### BT12-Cの目的

BT12-Bの反省を受け、BT12-Cでは、v1のtm列構成を維持したまま、F_form列だけをFformLinear_v1へ置換する方針に変更した。

BT12-Cの目的は以下である。

```text
- tmシートの列数・列名・列順はv1と同じにする。
- tmシートに追加管理列を入れない。
- 変更はF_form列の値だけに限定する。
- README_BT12Cだけを追加し、正本化・legacy扱い・QCはそこへ逃がす。
- BT12-B minimal版は今後の入力には使わない。
- legacy F_formは感度比較ではなくdeprecated / audit only。
```

---

### 入力

```text
H52Q_current_bundle_input_v1_20260615_180822.xlsx
BT08A3_macro_Fform_replace_package_20260616_145859.xlsx
```

---

### 出力

```text
H52Q_current_bundle_input_v2_FformLinearCanonical_tmCompatible_20260616_184700.xlsx
run_report_BT12C_current_bundle_input_v2_tmCompatible_20260616_184700.md
```

---

### 対象シート

BT12-Cで処理した対象シートは以下の6シートである。

```text
tm_108
tm_161
tm_164
tm_F1_108
tm_F1_161
tm_F1_164
```

---

### BT12-CのQC結果

BT12-Cでは、対象6シートすべてで、v1と同じ列構成が維持された。

```text
target_rows:
  116

mapped_rows:
  116 / 116

no_map_rows:
  0

tm_column_structure_same:
  6 / 6

old_value_vs_map_original:
  large_diff = 0
```

また、各シートの列数は以下であった。

```text
tm_108:
  v1 = 70列
  v2 = 70列
  delta = 0

tm_161:
  v1 = 70列
  v2 = 70列
  delta = 0

tm_164:
  v1 = 70列
  v2 = 70列
  delta = 0

tm_F1_108:
  v1 = 70列
  v2 = 70列
  delta = 0

tm_F1_161:
  v1 = 70列
  v2 = 70列
  delta = 0

tm_F1_164:
  v1 = 70列
  v2 = 70列
  delta = 0
```

したがって、BT12-Cでは、tmシートの互換性を維持したまま、F_formだけを正本値に置換できた。

---

### F_formの置換結果

BT12-Cでは、F_form列のみをFformLinear_v1へ置換した。

bundle別の平均値は以下である。

```text
108:
  Fform_old_mean = 0.669495
  Fform_new_mean = 0.636086
  delta_mean     = -0.033408

161:
  Fform_old_mean = 1.000000
  Fform_new_mean = 1.000000
  delta_mean     = 0

164:
  Fform_old_mean = 1.346381
  Fform_new_mean = 1.279881
  delta_mean     = -0.066500
```

FformLinear_v1への置換により、108と164ではF_formが低下した。

161は一様加熱であり、F_form=1のまま変化しない。

---

### 管理情報の扱い

BT12-Aでは、F_form正本化に関する管理列をtmシート内に追加した。

しかし、BT12-Cでは、tmシートの互換性を優先し、追加管理列は入れない方針に変更した。

管理情報は、tmシートではなく `README_BT12C` とrun_reportへ逃がした。

```text
Fform_definition_version:
  linear_v1

Fform_status:
  canonical

legacy_Fform_status:
  deprecated_definition_error_audit_only

BT12B_status:
  rejected_as_input
```

この整理により、通常解析ではtmシートの既存列構成を保ったまま、F_form列を読めば正本値になる。

legacy F_formはtmシート内には残さない。

legacy F_formは、v1、BT08A3 map、run_report、working_logで追跡する。

---

### 判断

BT12-Cを、今後のバンドル解析入力として採用する。

```text
採用：
  H52Q_current_bundle_input_v2_FformLinearCanonical_tmCompatible_20260616_184700.xlsx

不採用：
  H52Q_current_bundle_input_v2_minimal_FformLinearCanonical_20260616_183149.xlsx
```

理由は以下である。

```text
BT12-C：
  v1のtm列構成を維持している。
  F_form列だけをFformLinear_v1へ置換している。
  管理情報はREADME_BT12Cへ逃がしている。
  以後のBT解析入力として使いやすい。

BT12-B：
  列を削りすぎた。
  tm互換性を壊した。
  今後の入力としては使わない。
```

---

### 次アクション

次はBT13として、BT12-C tmCompatible版を入力にして、108過大化診断へ進む。

BT13以降では、原則として以下の入力を読む。

```text
H52Q_current_bundle_input_v2_FformLinearCanonical_tmCompatible_20260616_184700.xlsx
```

BT13の目的は、FformLinear_v1を正本化した後でも残る108過大化を、以下の観点から診断することである。

```text
- 108と164の非一様加熱分布の違い
- DNB位置
- F_form値
- L/DH
- z_DNB/DH
- z_DNB/L
- Tsub
- x_eq
- qM
- qP
```

ただし、BT13でも新しい補正式は作らない。

まずは、正本入力に切り替えた後の診断として、108過大化がどの変数群と対応しているかを確認する。

---

---

## 2026-06-17 追記：BT13、tmCompatible v2入力の不整合発見

### 位置づけ

BT12-Cでは、`H52Q_current_bundle_input_v1_20260615_180822.xlsx` を元に、tmシートの列構成を維持したまま、`F_form` 列だけを `FformLinear_v1` に置換した。

そのうえで、BT13として、BT12-CのtmCompatible v2を入力にして、108/161/164のF1後残差を再診断した。

入力は以下である。

```text
H52Q_current_bundle_input_v2_FformLinearCanonical_tmCompatible_20260616_184700.xlsx
```

出力は以下である。

```text
BT13_tmCompatible_v2_residual_diagnostic_20260617_085431.xlsx
run_report_BT13_tmCompatible_v2_residual_diagnostic_20260617_085431.md
```

---

### BT13のQC結果

BT13のQCは、構造上は正常であった。

```text
row_count:
  58

bundle_count:
  3

PM_F1_missing:
  0

PM_noF1_missing:
  0

F_form_missing:
  0

Tsub_missing:
  0

x_eq_missing:
  0

z_DNB_DH_missing:
  0

L_DH_missing:
  0
```

したがって、ファイルの読み込み、No対応、列欠損という意味ではBT13は正常に走った。

---

### ただし、重要な不整合を発見した

BT13のbundle summaryでは、F1後のP/Mが以下であった。

```text
BT13 PM_F1:
108 = 1.0667888
161 = 0.90884087
164 = 0.89201812
```

これは、BT10-Cで確認したlegacy側の値と一致する。

一方、FformLinear_v1をマクロへ投入して再計算したBT10-B/BT10-Cの結果では、F1後のP/Mは以下であった。

```text
FformLinear_v1再計算後 PM_F1:
108 = 1.1232232
161 = 0.90884087
164 = 0.93956052
```

したがって、BT13の結果は、FformLinear_v1再計算後のPM/q_calcを読めていない。

---

### 原因

BT12-Cでは、tmシートの列構成を維持するため、v1を元にして `F_form` 列だけをFformLinear_v1へ置換した。

しかし、v1内の `q_calc`、`PM`、`PM_F1` などの計算済み列は、legacy F_formでマクロ計算された時点の値である。

そのため、BT12-CのtmCompatible v2は、以下のような不整合を持っていた。

```text
F_form列：
  FformLinear_v1正本値

q_calc / PM / PM_F1列：
  legacy F_formで計算された旧値
```

つまり、BT12-Cは「F_form列の正本化」としては成立したが、「FformLinear_v1再計算済みの解析入力」としては不十分だった。

---

### 判断

BT13の数値診断は、FformLinear_v1正本化後の残差診断としては採用しない。

理由は、入力ブック内で、F_form列とq_calc/PM列の整合が取れていないためである。

ただし、BT13は無駄ではない。

BT13により、current_bundle_inputを作る際に、単にF_form列だけを置換するのでは不十分であり、マクロ再計算済みブックからtmシートを再構成する必要があることが分かった。

---

### BT12-Cの扱い修正

BT12-Cの扱いを以下に修正する。

```text
BT12-C：
  tm互換を維持したF_form列置換テスト
  ただし、q_calc/PM列はlegacy値のままなので、解析入力としては不採用

BT12-B：
  列を削りすぎたため不採用

BT12-A：
  F_form列置換のQC用full版
  ただし、これもq_calc/PM列はlegacy値のまま

今後必要：
  FformLinear_v1でマクロ再計算済みのr125/r126ブックから、
  tm互換70列を取り直したcurrent_bundle_input_v2を作る
```

---

### 正しい次作業

次は、BT13-BまたはBT12-Dとして、FformLinear_v1再計算済みマクロブックを元に、current_bundle_inputを作り直す。

入力候補は以下である。

```text
noF1再計算後：
celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm

F1再計算後：
celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm
```

作るべきファイルは以下である。

```text
H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_YYYYMMDD_HHMMSS.xlsx
```

この新v2では、以下がすべてFformLinear_v1再計算後の値で揃っている必要がある。

```text
F_form
q_calc
PM
PM_noF1
PM_F1
Fcorr
Tsub
x_eq
DNB位置
L/DH
```

---

### 現時点の結論

BT13により、BT12-C tmCompatible v2は、F_form列だけを正本化した入力であり、FformLinear_v1再計算済みの解析入力ではないことが判明した。

したがって、BT13の残差診断は採用しない。

次は、FformLinear_v1再計算済みマクロブックからtm互換current_bundle_input_v2を作り直す。

---

---

## 2026-06-17 追記：BT13-B、FformLinear_v1再計算済みマクロからcurrent_bundle_input_v2を再作成

### 位置づけ

BT13では、BT12-Cで作成したtmCompatible v2を使って残差診断を行った。

しかし、BT13の確認により、BT12-C v2には以下の不整合があることが分かった。

```text
F_form列：
  FformLinear_v1正本値

q_calc / PM / PM_F1列：
  legacy F_formで計算された旧値
```

つまり、BT12-Cはtm列構成を維持しつつF_form列だけを置換する作業としては成立していたが、FformLinear_v1再計算済みの解析入力としては不十分だった。

そのため、BT13-Bでは、FformLinear_v1再計算済みのr125/r126マクロブックから、current_bundle_input_v2を作り直した。

---

### 入力

```text
template v1:
H52Q_current_bundle_input_v1_20260615_180822.xlsx

noF1 recalc macro:
celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm

F1 recalc macro:
celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm
```

source sheetはいずれも `tm` であった。

---

### 出力

```text
H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx

run_report_BT13B_current_bundle_input_v2_FformLinearRecalc_20260617_091038.md
```

---

### 処理方針

BT13-Bでは、BT12-A/B/Cのv2は入力として使わなかった。

列構成テンプレートとしてのみ、旧 `current_bundle_input_v1` を使った。

```text
- BT12-A/B/Cのv2は入力として使わない。
- FformLinear_v1再計算済みマクロからtmシートを取り直す。
- template v1と同じ列数・列名・列順を維持する。
- 追加管理列はtmに入れない。
- 補正式は作らない。
```

この方針により、tmシートのマクロブック互換性を保ちながら、F_form、q_calc、PMがすべてFformLinear_v1再計算後の値で揃う入力を作ることを狙った。

---

### QC結果

BT13-BのQCは正常であった。

```text
target_rows:
  116

sheet_count:
  6

tm_column_structure_same:
  6 / 6

PM_mean_vs_BT10C_linear:
  max_abs_delta = 3.8469362e-09
```

したがって、6シート合計116行が揃い、対象6シートすべてでtemplate v1と同じ列構成を維持できた。

また、PM平均はBT10-CのFformLinear_v1再計算結果と一致した。

---

### sheet別確認

対象6シートは以下である。

```text
tm_108
tm_161
tm_164
tm_F1_108
tm_F1_161
tm_F1_164
```

各シートは、template v1と同じ70列構成で出力された。

```text
tm_108:
  noF1 PM = 0.65304894
  F_form = 0.63608627

tm_161:
  noF1 PM = 0.62098048
  F_form = 1.00000000

tm_164:
  noF1 PM = 0.59786191
  F_form = 1.2798813

tm_F1_108:
  F1 PM = 1.1232232
  F_form = 0.63608627

tm_F1_161:
  F1 PM = 0.90884087
  F_form = 1.00000000

tm_F1_164:
  F1 PM = 0.93956052
  F_form = 1.2798813
```

これにより、BT13で見つかった `F_form` 列と `PM/q_calc` 列の不整合は解消した。

---

### 判断

BT13-Bで作成した以下のブックを、今後のバンドル解析入力として採用する。

```text
H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx
```

このブックは、以下を満たしている。

```text
- FformLinear_v1再計算済みマクロから作成している。
- F_form、q_calc、PMが再計算後の値で整合している。
- template v1と同じtm列構成を維持している。
- 追加管理列をtmシートに入れていない。
- F2/F1F2を含まない。
```

したがって、BT12-A/B/Cのv2は今後の解析入力としては使わない。

```text
BT12-A:
  F_form列置換のfull/QC確認用

BT12-B:
  minimal版。列を削りすぎたため不採用

BT12-C:
  tm互換だがF_form列だけ置換した版。
  q_calc/PMがlegacy値のままだったため不採用

BT13-B:
  FformLinear_v1再計算済みマクロから作成したtmCompatible版。
  今後の正本入力として採用
```

---

### BT13の扱い修正

BT13の残差診断は、F_form列とPM列が不整合な入力を読んでいたため、数値診断としては採用しない。

ただし、BT13は無駄ではなく、current_bundle_inputをF_form列だけ置換しても不十分であることを発見した重要なチェックとして残す。

---

### 次アクション

次は、BT13-CまたはBT14として、BT13-Bで作成した正本入力を使い、FformLinear_v1再計算後の残差診断を再実行する。

入力は以下に固定する。

```text
H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx
```

目的は、以下である。

```text
- FformLinear_v1再計算後のPM_F1残差を確認する。
- 108が過大側へ動いたことを正本入力で再確認する。
- 164が改善側へ動いたことを正本入力で再確認する。
- F1後残差が、Tsub/x_eq側ではなく、F_form・DNB位置・L/DH側に残るかを再診断する。
```

ただし、次の診断でも補正式は作らない。

---

---

## 2026-06-17 追記：BT13-C、FformLinear_v1再計算済み正本入力による残差診断の再実行

### 位置づけ

BT13では、BT12-Cで作成したtmCompatible v2を用いて残差診断を行った。

しかし、BT13で読んだ入力は、`F_form` 列だけがFformLinear_v1正本値に置換され、`q_calc / PM / PM_F1` はlegacy F_formで計算された旧値のまま残っていた。

そのため、BT13の数値診断は採用しないことにした。

その後、BT13-Bで、FformLinear_v1再計算済みr125/r126マクロブックから、tm互換のcurrent_bundle_input_v2を作り直した。

BT13-Cでは、そのBT13-B正本入力を使い、BT13相当の残差診断を再実行した。

---

### 入力

```text
H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx
```

---

### 出力

```text
BT13C_resid_diag_v2_20260617_091836.xlsx

run_report_BT13C_resid_diag_v2_20260617_091836.md
```

---

### 前提

```text
- F2/F1F2は使わない。
- 比較対象はnoF1とF1のみ。
- F1(Tsub)は維持する。
- F1(Tsub)をF(x_eq)へ置換しない。
- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。
- qM/qPは診断量であり、補正式入力には使わない。
- BT13-Cでは補正式を作らない。
```

---

### QC結果

BT13-CのQCは正常であった。

```text
row_count:
  58

bundle_count:
  3

PM_F1_missing:
  0

PM_noF1_missing:
  0

F_form_missing:
  0

Tsub_missing:
  0

x_eq_missing:
  0

z_DNB_DH_missing:
  0

L_DH_missing:
  0
```

また、BT13-Bで作成した `F_form/q_calc/PM` 整合済み入力を使用していることも確認した。

したがって、BT13で問題になった、

```text
F_form列：
  FformLinear_v1

q_calc / PM列：
  legacy計算値
```

という不整合は、BT13-Cでは解消されている。

---

### Bundle summary

FformLinear_v1再計算済み正本入力でのbundle平均は以下であった。

```text
108:
  PM_noF1 = 0.65304894
  PM_F1   = 1.1232232
  err_F1  = +0.1232232
  F_form  = 0.63608627
  Tsub    = 46.083809
  x_eq    = -0.013990909
  z_DNB/DH = 139.65871
  z_DNB/L  = 0.73821634
  L/DH     = 189.18399

161:
  PM_noF1 = 0.62098048
  PM_F1   = 0.90884087
  err_F1  = -0.091159126
  F_form  = 1.000000
  Tsub    = 63.843926
  x_eq    = -0.082322824
  z_DNB/DH = 361.35516
  z_DNB/L  = 0.99707054
  L/DH     = 362.41684

164:
  PM_noF1 = 0.59786191
  PM_F1   = 0.93956052
  err_F1  = -0.060439484
  F_form  = 1.2798813
  Tsub    = 54.954868
  x_eq    = -0.15527776
  z_DNB/DH = 286.82405
  z_DNB/L  = 0.79142031
  L/DH     = 362.41684
```

FformLinear_v1再計算後は、108が過大側、161/164が過小側に残る。

BT13以前のlegacy F_form計算時と比べると、108は過大側が強まり、164は改善側へ動いた。

---

### 108と161/164の対比

BT13-Cでは、108と161/164平均の差は以下であった。

```text
PM_F1:
  108 = 1.1232232
  161/164平均 = 0.92350252
  差 = +0.19972068

err_F1:
  108 = +0.1232232
  161/164平均 = -0.076497479
  差 = +0.19972068

abs_err_F1:
  108 = 0.1232232
  161/164平均 = 0.092075598
  差 = +0.031147605
```

legacy時代には108はほぼ一致側に近かったが、FformLinear_v1再計算後は、108の過大側が明確になった。

一方、164はlegacy時代よりPM_F1が1に近づき、改善している。

---

### F1後残差とTsub/x_eq

BT13-Cでは、F1後のPM_F1はTsubやx_eqではほとんど説明されなかった。

```text
PM_F1 vs Tsub:
  R2 = 0.006302

PM_F1 vs x_eq:
  R2 = 0.032173
```

これはBT05〜BT06までの判断と整合する。

すなわち、F1後に残ったPM差は、Tsub/x_eq側の問題としては整理しにくい。

したがって、F1(Tsub)をF(x_eq)へ置換する方向には進まない。

---

### F1後残差とF_form・DNB位置・L/DH

一方、F1後のPM_F1は、F_form、DNB位置、L/DH側とは対応が残った。

```text
PM_F1 vs F_form:
  R2 = 0.243220

PM_F1 vs z_DNB/DH:
  R2 = 0.443518

PM_F1 vs z_DNB/L:
  R2 = 0.220952

PM_F1 vs L/DH:
  R2 = 0.476817
```

さらに、Tsubで残差化した後でも、F_form、z_DNB/DH、L/DHとの対応は残った。

```text
err_F1 residual after Tsub:

vs F_form:
  R2 = 0.257010

vs z_DNB/DH:
  R2 = 0.476275

vs L/DH:
  R2 = 0.505045
```

Tsub+x_eqで残差化した後では、むしろL/DHやF_formとの対応が強く残った。

```text
err_F1 residual after Tsub + x_eq:

vs F_form:
  R2 = 0.417014

vs z_DNB/DH:
  R2 = 0.500330

vs L/DH:
  R2 = 0.613299
```

したがって、BT13-Cでも、F1後残差はTsub/x_eq側ではなく、F_form・DNB位置・L/DH側に残るという判断が支持された。

---

### ただし、交絡が強い

BT13-Cでは、変数間の交絡も強い。

```text
F_form vs L/DH:
  R2 = 0.714179

z_DNB/DH vs L/DH:
  R2 = 0.853086

z_DNB/DH vs z_DNB/L:
  R2 = 0.740313

F_form vs z_DNB/DH:
  R2 = 0.379195
```

したがって、PM_F1とL/DHやz_DNB/DHの相関が見えても、それを純粋なL/DH効果やDNB履歴長効果とは言えない。

F_formも、L/DHやDNB位置と強く絡んでいる。

そのため、BT13-C時点でも以下の判断を維持する。

```text
F_form原因説にはしない。
z_DNB/DH原因説にはしない。
L/DH原因説にはしない。
```

これらは、F1後残差を理解するための診断軸として扱う。

---

### q_exp / q_calc_F1との関係

BT13-Cでは、PM_F1とq_exp、q_calc_F1のR2も高かった。

```text
PM_F1 vs q_exp:
  R2 = 0.491671

PM_F1 vs q_calc_F1:
  R2 = 0.608484
```

また、q_expとq_calc_F1は非常に強く相関していた。

```text
q_exp vs q_calc_F1:
  R2 = 0.980474
```

ただし、q_expおよびq_calc_F1は結果側の量であり、補正式入力として使わない。

これは、108/161/164のq絶対値の大小関係が、実験値にも計算値にも強く入っていることを示す診断結果として扱う。

---

### 探索モデルの扱い

探索モデルでは、以下のような組合せでR2が高くなった。

```text
PM_F1 ~ Tsub + x_eq + F_form:
  R2 = 0.692284

PM_F1 ~ Tsub + x_eq + F_form + z_DNB/DH:
  R2 = 0.722248

PM_F1 ~ Tsub + x_eq + F_form + L/DH:
  R2 = 0.743553
```

ただし、これらは補正式候補ではない。

F_form、z_DNB/DH、L/DHは互いに交絡しており、ケース構造を強く含んでいる。

したがって、探索モデルのR2が高いことを理由に、F_form補正式、DNB履歴長補正式、L/DH補正式へは進まない。

---

### 判断

BT13-Cにより、BT13-Bで作成した正本入力を用いた残差診断が完了した。

判断は以下である。

```text
BT13-Cは採用する。

BT13は不整合入力を読んでいたため、数値診断としては採用しない。

BT13-Cでは、FformLinear_v1再計算後の整合済み入力を使い、108/161/164の残差を再診断できた。
```

BT13-Cの結果として、以下を採用する。

```text
- FformLinear_v1再計算後、108は過大側に残る。
- 161/164は過小側に残る。
- 164はlegacy時代より改善している。
- F1後残差は、Tsub/x_eq側ではなく、F_form・DNB位置・L/DH側に残る。
- ただし、F_form、z_DNB/DH、z_DNB/L、L/DHは強く交絡している。
- したがって、どれか一つを原因として断定しない。
```

---

### 現時点で言ってよいこと

```text
- BT13-Cは、BT13-B正本入力を使った再診断であり、採用できる。
- FformLinear_v1再計算後は、108のPM_F1が過大側に残る。
- 164はlegacy時代より改善する。
- F1後残差はTsub/x_eqではほとんど説明されない。
- F1後残差はF_form・DNB位置・L/DH側と対応する。
- ただし、F_form・DNB位置・L/DHは強く交絡している。
```

---

### まだ言ってはいけないこと

```text
- F_formが108過大側残差の原因であるとは言わない。
- z_DNB/DHが原因であるとは言わない。
- L/DHが原因であるとは言わない。
- F1(Tsub)をF(x_eq)へ置換すべきとは言わない。
- F_form補正式、DNB履歴長補正式、L/DH補正式を作るとは言わない。
- 探索モデルを補正式として採用しない。
```

---

### 次アクション

次はBT14として、F_form・DNB位置・非一様加熱分布側の扱いを整理する。

BT14で確認すべきことは以下である。

```text
1. F_formは正本化されたが、その定義は108/161/164で同じ意味になっているか。
2. F_formの違いは、出力分布形状によるものか、DNB位置によるものか。
3. 108のF_formが小さい理由を、108の出力分布・DNB位置・z_DNB/Lから説明できるか。
4. 164のF_formが大きい理由を、164の出力分布・DNB位置・z_DNB/Lから説明できるか。
5. PM_F1残差を、F_form補正式ではなく、非一様加熱換算・DNB位置診断として残すべきか。
```

ただし、BT14でも補正式は作らない。

---

---

## 2026-06-17 追記：BT14-A、F_form・DNB位置・非一様加熱分布側の扱い整理

### 位置づけ

BT13-Cでは、BT13-Bで作成したFformLinear_v1再計算済み正本入力を用いて、F1後残差を再診断した。

その結果、F1後残差はTsub/x_eq側ではなく、F_form・DNB位置・L/DH側に残ることを確認した。

ただし、F_form、z_DNB/DH、z_DNB/L、L/DHは強く交絡していた。

そのためBT14-Aでは、F_formを原因と断定する前に、F_formがDNB位置だけで決まっているのか、それとも軸方向出力分布形状やケース構造を強く含むのかを確認した。

---

### 入力

```text
H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx
```

---

### 出力

```text
BT14A_Fform_position_shape_diag_20260617_093233.xlsx

run_report_BT14A_Fform_position_shape_diag_20260617_093233.md
```

---

### 前提

```text
- F2/F1F2は使わない。
- F1(Tsub)は維持する。
- F1(Tsub)をF(x_eq)へ置換しない。
- F_formはF1ではなく、DNB位置の局所熱流束基準への非一様加熱換算係数である。
- BT14-AではF_form補正式、DNB位置補正式、L/DH補正式を作らない。
- current_bundle_inputには軸方向出力分布の元配列がないため、BT14-AはF_form再積分監査ではなく挙動診断である。
```

---

### QC結果

BT14-AのQCは、データ読み取りとしては正常であった。

```text
row_count:
  58

bundle_count:
  3

PM_F1_missing:
  0

F_form_missing:
  0

z_DNB/L_missing:
  0

z_DNB/DH_missing:
  0

L/DH_missing:
  0
```

一方、以下はCHECKとなった。

```text
axial_profile_available:
  CHECK
  not_in_current_input
```

これはエラーではなく、BT14-Aの位置づけを示すものである。

`current_bundle_input` には軸方向出力分布の元配列が入っていないため、BT14-AではF_formの青面積／オレンジ面積の再積分監査はできない。

したがって、BT14-Aは以下の位置づけで扱う。

```text
BT14-A：
  F_form挙動診断

BT14-Aではできないこと：
  F_formの再積分監査
  軸方向出力分布そのものからのF_form再計算
```

---

### Bundle summary

BT14-Aでのbundle平均は以下であった。

```text
108:
  PM_F1      = 1.1232232
  err_F1     = +0.1232232
  F_form     = 0.63608627
  z_DNB/DH   = 139.65871
  z_DNB/L    = 0.73821634
  L/DH       = 189.18399

161:
  PM_F1      = 0.90884087
  err_F1     = -0.091159126
  F_form     = 1.00000000
  z_DNB/DH   = 361.35516
  z_DNB/L    = 0.99707054
  L/DH       = 362.41684

164:
  PM_F1      = 0.93956052
  err_F1     = -0.060439484
  F_form     = 1.2798813
  z_DNB/DH   = 286.82405
  z_DNB/L    = 0.79142031
  L/DH       = 362.41684
```

FformLinear_v1再計算後でも、108は過大側、161/164は過小側に残る。

---

### Case summary

case_group別には以下であった。

```text
108_70in:
  PM_F1    = 1.1166142
  F_form   = 0.61982066
  z_DNB/L  = 0.7292863
  z_DNB/DH = 137.96929
  L/DH     = 189.18399

108_76in:
  PM_F1    = 1.1628772
  F_form   = 0.73367994
  z_DNB/L  = 0.79179655
  z_DNB/DH = 149.79523
  L/DH     = 189.18399

161_uniform:
  PM_F1    = 0.90884087
  F_form   = 1.00000000
  z_DNB/L  = 0.99707054
  z_DNB/DH = 361.35516
  L/DH     = 362.41684

164_134in_normal:
  PM_F1    = 0.94666661
  F_form   = 1.2999932
  z_DNB/L  = 0.79765643
  z_DNB/DH = 289.08413
  L/DH     = 362.41684

164_112in:
  PM_F1    = 0.79743867
  F_form   = 0.8776443
  z_DNB/L  = 0.66669791
  z_DNB/DH = 241.62255
  L/DH     = 362.41684
```

---

### 近いDNB相対位置でもF_formが大きく違う

BT14-Aで特に重要なのは、z_DNB/Lが近いのにF_formが大きく違うペアが存在することである。

代表例は以下である。

```text
108_76in vs 164_134in_normal:

delta_z_DNB/L:
  -0.0058598785

delta_F_form:
  -0.56631323

delta_PM_F1:
  +0.21621055
```

この2ケースは、DNB相対位置 `z_DNB/L` はほぼ同じである。

しかし、F_formは大きく異なる。

したがって、F_formはDNB相対位置だけで決まる量ではない。

F_formは、DNB位置に加えて、軸方向出力分布形状、局所熱流束基準、L/DH、ケース構造を強く含む量と読むべきである。

もう一つの例として、以下も同じ傾向を示す。

```text
108_70in vs 164_134in_normal:

delta_z_DNB/L:
  -0.068370133

delta_F_form:
  -0.68017251

delta_PM_F1:
  +0.1699476
```

このため、BT14-Aでは以下を採用する。

```text
F_formはDNB位置だけでは説明できない。
F_formには軸方向出力分布形状が強く入っている可能性が高い。
```

---

### F_formと各軸の関係

BT14-Aでは、F_formと各軸の関係を確認した。

```text
F_form vs z_DNB/L:
  R2 = 0.028403

F_form vs z_DNB/DH:
  R2 = 0.379195

F_form vs L/DH:
  R2 = 0.714179

F_form vs case_group_dummy:
  R2 = 1.000000
```

F_formは、z_DNB/L単独ではほとんど説明されない。

一方で、L/DHとは強く対応している。

ただし、これはL/DHが直接F_formを決めているという意味ではない。

108、161、164では、L/DH、軸方向出力分布、DNB位置、ケース番号が一体で変化している。

したがって、F_formとL/DHの高いR2は、ケース構造との交絡として読む。

---

### F_formとPM_F1残差

PM_F1との対応は以下であった。

```text
PM_F1 vs F_form:
  R2 = 0.243220

PM_F1 vs z_DNB/L:
  R2 = 0.220952

PM_F1 vs z_DNB/DH:
  R2 = 0.443518

PM_F1 vs L/DH:
  R2 = 0.476817
```

F_formとPM_F1には対応がある。

しかし、z_DNB/DHやL/DHの方がPM_F1とのR2は高い。

また、複数軸を組み合わせるとR2は上がる。

```text
PM_F1 ~ F_form + z_DNB/L:
  R2 = 0.397320

PM_F1 ~ F_form + z_DNB/DH:
  R2 = 0.454636

PM_F1 ~ F_form + L/DH:
  R2 = 0.505395

PM_F1 ~ F_form + z_DNB/L + L/DH:
  R2 = 0.516477
```

ただし、これらは補正式候補ではない。

BT14-Aでは、これらを以下のように読む。

```text
PM_F1残差は、F_form単独ではなく、
F_form、DNB位置、L/DH、ケース構造の複合と対応している。
```

---

### 交絡の確認

BT14-Aでは、変数間の交絡も強かった。

```text
F_form vs L/DH:
  R2 = 0.714179

F_form vs z_DNB/DH:
  R2 = 0.379195

z_DNB/DH vs L/DH:
  R2 = 0.853086

z_DNB/L vs z_DNB/DH:
  R2 = 0.740313
```

特に、z_DNB/DHとL/DHの交絡が非常に強い。

また、F_formとL/DHも強く対応している。

このため、PM_F1残差とF_form、z_DNB/DH、L/DHの対応が見えても、以下のどれか一つに原因を決めることはできない。

```text
F_form原因説
DNB位置原因説
L/DH原因説
```

---

### q_exp / q_calc_F1との関係

BT14-Aでは、F_formやL/DHとq_exp/q_calc_F1の対応も高かった。

```text
F_form vs q_exp:
  R2 = 0.739207

F_form vs q_calc_F1:
  R2 = 0.702657

L/DH vs q_exp:
  R2 = 0.889268

L/DH vs q_calc_F1:
  R2 = 0.909250
```

ただし、q_expやq_calc_F1は結果側の量である。

したがって、これらは補正式候補ではなく、ケース構造および熱流束レベルとの対応を示す診断量として扱う。

---

### BT14-Aの判断

BT14-Aの判断は以下である。

```text
BT14-Aは採用する。

ただし、BT14-AはF_form再積分監査ではなく、F_form挙動診断である。
```

BT14-Aで分かったことは以下である。

```text
- F_formはDNB相対位置 z_DNB/L だけでは説明できない。
- z_DNB/Lが近くても、108と164ではF_formが大きく異なるケースがある。
- したがって、F_formには軸方向出力分布形状が強く入っている可能性が高い。
- F_formはL/DHやケース構造と強く交絡している。
- PM_F1残差はF_form単独ではなく、F_form、DNB位置、L/DH、ケース構造の複合と対応している。
```

---

### 現時点で言ってよいこと

```text
- F_formはF1ではない。
- F_formは非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。
- F_formはDNB相対位置だけでは決まらない。
- F_formには軸方向出力分布形状、DNB位置、L/DH、ケース構造が含まれている可能性が高い。
- PM_F1残差は、F_form、DNB位置、L/DH、ケース構造と対応する。
- ただし、どれか一つを原因として断定しない。
```

---

### まだ言ってはいけないこと

```text
- F_formがPM_F1残差の原因であるとは言わない。
- z_DNB/Lが原因であるとは言わない。
- z_DNB/DHが原因であるとは言わない。
- L/DHが原因であるとは言わない。
- F_form補正式を作るとは言わない。
- DNB位置補正式を作るとは言わない。
- L/DH補正式を作るとは言わない。
- BT14-AだけでF_form定義が正しいと断定しない。
```

---

### 次アクション

BT14-Aでは、current_bundle_inputに軸方向出力分布の元配列がないため、F_formの再積分監査はできなかった。

したがって、次に進むならBT14-Bとして、F_form作成元の軸方向出力分布を用いた再積分監査を行う。

BT14-Bで確認すべきことは以下である。

```text
1. F_form = 青面積 / オレンジ面積 が、108/161/164で正しく計算されているか。
2. DNB位置の補間方法が妥当か。
3. 軸方向出力分布の積分範囲がDNB位置までになっているか。
4. 108_70in、108_76in、164_112in、164_134in_normalで、F_formが手計算・数値積分と一致するか。
5. FformLinear_v1が、マクロ入力に反映されている値と一致するか。
```

BT14-Bでも補正式は作らない。

BT14-Bの目的は、F_form定義と実装の監査である。

---

---

## 2026-06-17 追記：BT14-B2、F_form linear_v1実装照合の完了とBT14の閉じ

### 位置づけ

BT14-Aでは、`current_bundle_input` だけでは軸方向出力分布の元配列がなく、F_formの再積分監査まではできないことを確認した。

そのため、BT14-Bでは、過去に実施したBT08-A1dのF_form再積分監査結果を再利用し、F_form定義を `linear_v1` として正本化する方針にした。

ただし、最初のBT14-Bでは、BT13-B正本入力である `H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx` を読み込めず、`current_rows = 0` となった。

したがって、BT14-Bの時点では、F_form定義の正本化方針は妥当だったが、current inputとの照合は未完了であった。

BT14-B2では、この未完了だったcurrent input照合をやり直した。

---

### 入力

```text
current input:
H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx

BT08-A1d report:
run_report_BT08A1d_Fform_linear_finalize_20260616_144056.md

BT14-A report:
run_report_BT14A_Fform_position_shape_diag_20260617_093233.md

previous BT14-B report:
run_report_BT14B_Fform_reintegration_audit_closure_20260617_094603.md
```

---

### 出力

```text
BT14B2_Fform_consistency_check_20260617_095120.xlsx

run_report_BT14B2_Fform_consistency_check_20260617_095120.md
```

---

### F_form linear_v1定義

BT14-B2では、BT08-A1dで確定した以下の定義を正本として扱った。

```text
x_DNB = DNB位置 / 加熱長

f_DNB = interp1(x, f, x_DNB)

Blue_area_linear = integral_0^x_DNB f(x) dx

Orange_area_linear = x_DNB * f_DNB

F_form_linear = Blue_area_linear / Orange_area_linear
```

この定義は、F_formをF1として扱うものではない。

F_formは、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。

---

### QC結果

BT14-B2のQCは正常であった。

```text
target_sheet_map:
  6 / 6 OK

sheet_read:
  6 / 6 OK

current_rows:
  116 OK

current_Fform_vs_linear_v1:
  OK
  max_abs_delta = 3.078041e-08
```

対象6シートはすべて正しく読み込めた。

```text
tm_108:
  14 rows

tm_161:
  23 rows

tm_164:
  21 rows

tm_F1_108:
  14 rows

tm_F1_161:
  23 rows

tm_F1_164:
  21 rows
```

合計で、noF1 58行 + F1 58行 = 116行である。

したがって、BT14-Bで起きたcurrent input未読問題は解消した。

---

### canonical F_form linear_v1

BT08-A1d由来の正本F_formは以下である。

```text
108_70in:
  F_form_linear_v1 = 0.61982066

108_76in:
  F_form_linear_v1 = 0.73367994

161_uniform:
  F_form_linear_v1 = 1.00000000

164_112in:
  F_form_linear_v1 = 0.87764430

164_134in_normal:
  F_form_linear_v1 = 1.29999320
```

これらは、すべて線形補間・線形積分で統一した値である。

---

### current inputとの照合

BT13-B正本入力内のF_form平均は以下であった。

```text
108_70in:
  current F_form = 0.61982066

108_76in:
  current F_form = 0.73367994

161_uniform:
  current F_form = 1.00000000

164_112in:
  current F_form = 0.87764430

164_134in_normal:
  current F_form = 1.29999320
```

BT08-A1dのlinear_v1正本値との差は、最大でも以下であった。

```text
max_abs_delta:
  3.078041e-08
```

したがって、BT13-B正本入力のF_formは、BT08-A1dで確定したlinear_v1と一致している。

---

### consistency check

case別の照合結果はすべてOKであった。

```text
108_70in:
  OK_current_matches_linear_v1

108_76in:
  OK_current_matches_linear_v1

161_uniform:
  OK_current_matches_linear_v1

164_112in:
  OK_current_matches_linear_v1

164_134in_normal:
  OK_current_matches_linear_v1
```

これにより、F_form定義、F_form実装、current input反映の三者が整合した。

---

### near-position examples

BT14-B2でも、BT14-Aで見た重要な構図は維持された。

代表例は以下である。

```text
108_76in vs 164_134in_normal:

delta_z_DNB_ratio:
  -0.005952

delta_Fform_linear_v1:
  -0.56631326

delta_PM_F1_current:
  +0.21621055

delta_L_DH_current:
  -173.23285
```

この2ケースは、DNB相対位置が非常に近いにもかかわらず、F_formが大きく異なる。

したがって、F_formはDNB相対位置だけで決まる量ではない。

F_formには、軸方向出力分布形状、DNB位置、L/DH、ケース構造が含まれていると読むべきである。

ただし、この結果をもって、F_formがPM_F1残差の原因であるとは断定しない。

---

### BT14-B2の判断

BT14-B2の判断は以下である。

```text
BT14-B2は採用する。

BT14-Bで未完だったcurrent input照合は、BT14-B2で完了した。

BT13-B正本入力のF_formは、BT08-A1dのlinear_v1正本値と一致した。

したがって、F_form実装監査は閉じられる。
```

decision flagsでも、以下の判断になった。

```text
Fform_definition:
  adopt
  linear_v1

Fform_reintegration_audit:
  adopt
  reuse_BT08A1d

current_input_status:
  adopt
  matches_linear_v1

BT14_status:
  close_ready
  Fform_audit_closed

legacy_policy:
  adopt
  trace_only

Fform_causal_claim:
  do_not_claim
  not_cause_yet

formula_policy:
  do_not_create
  no_Fform_DNB_LDH_formula
```

---

### F_formの今後の扱い

今後のF_formの扱いを以下のように固定する。

```text
採用：
  F_form = linear_v1

採用：
  BT08-A1dの線形補間・線形積分定義を正本とする。

採用：
  BT13-B正本入力のF_formはlinear_v1と一致している。

採用：
  legacy F_formは履歴・比較用として残す。

不採用：
  legacy F_formを今後の感度解析入力に使うこと。

禁止：
  F_form補正式を作ること。
  DNB位置補正式を作ること。
  L/DH補正式を作ること。
  F_formをPM_F1残差の原因と断定すること。
```

---

### BT14全体の閉じ

BT14は以下の構成で閉じる。

```text
BT14-A:
  F_form・DNB位置・L/DHの挙動診断。
  F_formはDNB相対位置だけでは決まらず、
  軸方向出力分布形状、DNB位置、L/DH、ケース構造を含むと整理した。

BT14-B:
  BT08-A1dのlinear_v1定義を正本として再利用する方針を立てた。
  ただし、current inputの読み込みが0行で照合未完だったため、採用保留。

BT14-B2:
  BT14-Bの未完照合を修正。
  BT13-B正本入力のF_formがBT08-A1d linear_v1と一致することを確認。
  F_form実装監査を閉じる。
```

したがって、BT14全体としては、

```text
F_formはlinear_v1で正本化済み。
BT13-B正本入力にも反映済み。
F_formの定義・実装監査は完了。
ただし、F_formを残差原因とは断定しない。
```

と整理する。

---

### 現時点で言ってよいこと

```text
- F_formはF1ではない。
- F_formは非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。
- F_form定義はBT08-A1dのlinear_v1を正本とする。
- BT13-B正本入力のF_formはlinear_v1と一致している。
- legacy F_formは履歴・比較用であり、今後の解析入力には使わない。
- BT14-Aの結果から、F_formはDNB相対位置だけで決まる量ではない。
- F_formには軸方向出力分布形状、DNB位置、L/DH、ケース構造が含まれる可能性が高い。
```

---

### まだ言ってはいけないこと

```text
- F_formがPM_F1残差の原因であるとは言わない。
- F_form補正式を作るとは言わない。
- DNB位置補正式を作るとは言わない。
- L/DH補正式を作るとは言わない。
- BT14-A/B2だけでF_formが物理的な最終説明変数であるとは言わない。
```

---

### 次アクション

BT14はここで閉じる。

次に進むなら、BT15として以下を整理する。

```text
BT15：
  F_form正本化後の全体判断整理

目的：
  - BT13-Cの残差診断
  - BT14-AのF_form挙動診断
  - BT14-B2のF_form実装照合
  を統合し、今後の解析方針を整理する。
```

BT15でも、補正式は作らない。

---

---

## 2026-06-17 追記：BT15、F_form正本化後の全体判断整理

### 位置づけ

BT15では、BT13-C、BT14-A、BT14-B2の結果を統合し、F_form正本化後の全体判断を整理した。

BT15は補正式を作る作業ではない。

目的は、F_formをlinear_v1で正本化した後に、今後どの入力を使い、何を採用し、何を不採用とし、何をまだ主張しないかを固定することである。

---

### 入力

```text
current input:
H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx

BT13-C report:
run_report_BT13C_resid_diag_v2_20260617_091836.md

BT14-A report:
run_report_BT14A_Fform_position_shape_diag_20260617_093233.md

BT14-B2 report:
run_report_BT14B2_Fform_consistency_check_20260617_095120.md

previous BT14-B report:
run_report_BT14B_Fform_reintegration_audit_closure_20260617_094603.md
```

---

### 出力

```text
BT15_Fform_decision_package_20260617_100701.xlsx

run_report_BT15_Fform_decision_package_20260617_100701.md
```

---

### QC結果

BT15のQCは正常であった。

```text
current_input_exists:
  OK

BT13C_report_exists:
  OK

BT14A_report_exists:
  OK

BT14B2_report_exists:
  OK

current_rows:
  116 OK

bundle_summary_rows:
  3 OK

case_summary_rows:
  5 OK

BT15_formula_policy:
  no_new_formula OK

BT15_F1_policy:
  keep_F1_Tsub OK

BT15_Fform_policy:
  linear_v1 OK
```

これにより、BT13-B正本入力、BT13-C残差診断、BT14-A挙動診断、BT14-B2実装照合がそろった状態で、F_form正本化後の判断を整理できた。

---

### 採用する正本入力

今後のバンドル解析入力として、以下を採用する。

```text
H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx
```

この入力は、FformLinear_v1再計算済みのtmCompatible正本入力である。

F_form、q_calc、PMがFformLinear_v1再計算後の値で整合している。

---

### F_formの正本定義

F_formは以下の値を正本とする。

```text
108_70in:
  F_form_linear_v1 = 0.61982066

108_76in:
  F_form_linear_v1 = 0.73367994

161_uniform:
  F_form_linear_v1 = 1.00000000

164_112in:
  F_form_linear_v1 = 0.87764430

164_134in_normal:
  F_form_linear_v1 = 1.29999320
```

この定義は、BT08-A1dで定義した `linear_v1` である。

すなわち、線形補間・線形積分に基づく以下の定義を正本とする。

```text
x_DNB = DNB位置 / 加熱長

f_DNB = interp1(x, f, x_DNB)

Blue_area_linear = integral_0^x_DNB f(x) dx

Orange_area_linear = x_DNB * f_DNB

F_form_linear = Blue_area_linear / Orange_area_linear
```

F_formはF1ではない。

F_formは、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。

---

### BT13-Cの残差診断の扱い

BT13-Cでは、FformLinear_v1再計算済み正本入力を使って、F1後残差を再診断した。

bundle平均は以下であった。

```text
108:
  PM_noF1 = 0.65304894
  PM_F1   = 1.1232232
  err_F1  = +0.1232232
  F_form  = 0.63608627
  Tsub    = 46.083809
  x_eq    = -0.013990909
  z_DNB/L  = 0.73821634
  z_DNB/DH = 139.65871
  L/DH     = 189.18399

161:
  PM_noF1 = 0.62098048
  PM_F1   = 0.90884087
  err_F1  = -0.091159126
  F_form  = 1.00000000
  Tsub    = 63.843926
  x_eq    = -0.082322824
  z_DNB/L  = 0.99707054
  z_DNB/DH = 361.35516
  L/DH     = 362.41684

164:
  PM_noF1 = 0.59786191
  PM_F1   = 0.93956052
  err_F1  = -0.060439484
  F_form  = 1.2798813
  Tsub    = 54.954868
  x_eq    = -0.15527776
  z_DNB/L  = 0.79142031
  z_DNB/DH = 286.82405
  L/DH     = 362.41684
```

FformLinear_v1再計算後は、108が過大側、161/164が過小側に残る。

この傾向は診断結果として採用する。

ただし、これをF_form原因説とはしない。

---

### BT14-Aの扱い

BT14-Aでは、F_form、DNB位置、L/DHの挙動を診断した。

その結果、F_formはDNB相対位置だけでは決まらないことを確認した。

特に、108_76inと164_134in_normalは、z_DNB/Lが近いにもかかわらず、F_formが大きく異なる。

```text
108_76in vs 164_134in_normal:

delta_z_DNB_ratio:
  -0.005952

delta_Fform_linear_v1:
  -0.56631326

delta_PM_F1_current:
  +0.21621055

delta_L_DH_current:
  -173.23285
```

したがって、F_formはDNB相対位置だけではなく、軸方向出力分布形状、DNB位置、L/DH、ケース構造を含む量として扱う。

ただし、F_formがPM_F1残差の原因であるとは断定しない。

---

### BT14-B2の扱い

BT14-B2では、BT13-B正本入力のF_formが、BT08-A1dのlinear_v1正本値と一致するかを確認した。

結果はすべてOKであった。

```text
current_Fform_vs_linear_v1:
  OK
  max_abs_delta = 3.078041e-08
```

case別にも、すべて一致した。

```text
108_70in:
  OK_current_matches_linear_v1

108_76in:
  OK_current_matches_linear_v1

161_uniform:
  OK_current_matches_linear_v1

164_112in:
  OK_current_matches_linear_v1

164_134in_normal:
  OK_current_matches_linear_v1
```

これにより、F_form定義、F_form実装、current input反映の三者が整合した。

したがって、BT14は閉じる。

---

### 採用する判断

BT15で採用する判断は以下である。

```text
- F_formはBT08-A1dのlinear_v1を正本とする。
- BT13-B正本入力のF_formはlinear_v1と一致している。
- 今後のバンドル解析入力は、BT13-B正本入力を使う。
- legacy F_formは履歴・比較用であり、今後の解析入力には使わない。
- BT13-Cの残差診断は、正本入力による診断結果として採用する。
- F1(Tsub)は維持する。
- F1(Tsub)をF(x_eq)へ置換しない。
- F_form、DNB位置、L/DHは診断軸として扱う。
```

---

### 不採用・旧扱い

以下は不採用または旧扱いとする。

```text
BT12-A full版:
  F_form列置換のQC用。
  q_calc/PMはlegacyのままなので正本入力にはしない。

BT12-B minimal版:
  列を削りすぎたため不採用。

BT12-C F_form列だけ置換版:
  tm互換だが、F_formだけlinearで、PM/q_calcがlegacyだったため不採用。

BT13 初回残差診断:
  不整合入力を読んでいたため、数値診断としては不採用。

legacy F_form:
  旧定義であり、今後の解析入力には使わない。
  履歴・比較用としてのみ残す。

F2/F1F2:
  今回の比較対象外。
```

---

### まだ言ってはいけないこと

BT15時点でも、以下はまだ言わない。

```text
- F_formがPM_F1残差の原因である。
- DNB位置が原因である。
- L/DHが原因である。
- F_form補正式を作る。
- DNB位置補正式を作る。
- L/DH補正式を作る。
- F1(Tsub)をF(x_eq)へ置換する。
- F_formが最終的な物理説明変数である。
```

理由は、F_form、DNB位置、L/DH、ケース構造が強く交絡しているためである。

---

### リスク・保留事項

BT15後も、以下のリスクは残る。

```text
F_form原因説への飛躍:
  原因とは言わず、診断項として扱う。

L/DH補正式への飛躍:
  L/DHは複合代理として扱う。

x_eq置換への飛躍:
  F1(Tsub)維持を明記する。

BT13初回結果の混入:
  BT13は不整合入力として不採用にする。

legacy F_formの再利用:
  legacyは履歴・比較用に限定する。

3ケースでの一般化:
  追加ケースまたは外部データ確認まで一般化しない。
```

---

### BT15の結論

BT15により、F_form正本化後の判断を整理した。

今後のバンドル解析入力は、BT13-Bで作成した以下を正本とする。

```text
H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx
```

F_formはlinear_v1で固定する。

F1(Tsub)は維持する。

追加補正式は作らない。

108/161/164の残差は、補正式化ではなく、非一様加熱換算、DNB位置、L/DH、ケース構造、適用範囲の診断課題として残す。

---

### 次アクション

BT15は、F_form正本化後の判断ゲートとして閉じる。

次に進むなら、以下のいずれかである。

```text
BT16:
  F_form正本化後の判断を内部説明・発表用に整理する。

ST-BT05:
  単管側で、Hsub/P/Tsub後のx_eq独立効果を確認する。

source01原本確認:
  Table9/10/11/12の装置・系列・表注が数値診断と矛盾しないか確認する。

Bundle additional cases:
  108/161/164以外にも同じ傾向があるか確認する。
```

現時点では、BT16として内部説明・発表用の整理に進むのが自然である。

---

---

## 2026-06-17 追記：ST-BT05 v3、単管側におけるx_eq独立効果の確認

### 位置づけ

ST-BT05では、単管側で `x_eq` が本当に独立した説明力を持つのかを確認した。

ここまでの検討では、T&M source01 Table9〜12に対して、`Hsub + P + x_eq` を入れると、Table12 longの正残差がかなり整理されることが分かっていた。

しかし、それだけでは、`x_eq` が本当に独立に効いているのか、それとも `Hsub`、`P`、`Tsub` の代理として効いているだけなのかが分からなかった。

今回の目的は、バンドル側でのBT05と対応させて、単管側でも `Hsub/P/Tsub` 後に `x_eq` がまだ効くかを確認することである。

---

### v1とv2の扱い

ST-BT05 v1は採用しない。

v1では、`current_single_tube_input` の `ST_F1_T8_14_current` だけを読んだため、`Hsub_true` と `x_eq` が欠損し、目的の診断ができなかった。

ST-BT05 v2も採用しない。

v2では、`hlg` の結合元に `tm_F1_ST` を使ったため、結合後の対象が86行に縮退した。これはTable9〜12全体の比較として不十分だった。

したがって、ST-BT05の正本結果はv3とする。

---

### v3の入力

```text
v10 file:
TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx

v10 sheet:
target_rows_T8_12

r8 file:
20260612_計算結果比較r8_result_文献追加用.xlsx

r8 sheet:
tm_r124_F1_T8_14
```

v3では、v10の `target_rows_T8_12` と r8の `tm_r124_F1_T8_14` を `No_TableNo` で結合した。

そのうえで、`qP_F1`、`G`、`L/D`、`Hsub_true`、`hlg` から、予測側の熱平衡クオリティ `x_eq_qP_F1` を計算した。

---

### v3のQC

v3のQCは正常であった。

```text
v10_raw_rows:
  192 OK

r8_raw_rows:
  224 OK

join_rows_T8_12:
  192 OK

target_Table9_12_rows:
  176 OK

Hsub_missing:
  0 OK

P_missing:
  0 OK

Tsub_missing:
  0 OK

hlg_missing:
  0 OK

x_eq_missing:
  0 OK

model_OK_count:
  13/13 OK
```

これにより、Table9〜12の176行を対象として、Hsub、P、Tsub、x_eqを含む診断が可能になった。

---

### 主要結果

単管側では、`x_eq` は `Hsub/P/Tsub` 後にも追加説明力を持っていた。

代表的な結果は以下である。

```text
Hsub + P + Tsub:
  R2 = 0.81387261

Hsub + P + Tsub + x_eq:
  R2 = 0.92420685

delta_R2:
  0.11033425
```

また、残差化後の診断でも、`Hsub + P + Tsub` 後の残差に対して、`x_eq` はまだ説明力を持っていた。

```text
residual after Hsub + P + Tsub vs x_eq:
  R2 = 0.14678769
```

したがって、単管側では、`x_eq` または熱平衡状態に相当する変数が、`Hsub/P/Tsub` では吸収しきれない情報を持つ可能性がある。

---

### 注意点

ただし、`x_eq` を純粋な独立物理量として扱うのは危険である。

v3では、`x_eq` と `L/D` の相関が強かった。

```text
x_eq vs L/D:
  R2 = 0.74249103
```

また、`Hsub_true` と `Tsub` もほぼ同じ情報を持っていた。

```text
Hsub_true vs Tsub:
  R2 = 0.99309142
```

したがって、今回見えている `x_eq` の効果は、単純な平衡クオリティ効果ではなく、加熱長、L/D、二相発達履歴、熱履歴を含んだ複合的な状態量として読むべきである。

---

### バンドル側との比較

バンドル側では、BT05により、`x_eq` は `Tsub` に対する追加説明力が小さいと整理されていた。

一方、単管側では、今回のST-BT05 v3により、`Hsub/P/Tsub` 後でも `x_eq` が追加説明力を持つことが確認された。

したがって、現時点では以下の読みができる。

```text
単管：
  x_eq / 熱平衡状態 / 二相発達履歴が効く。

バンドル：
  x_eqはTsubに対して追加説明力が小さい。
  F1(Tsub)をF(x_eq)へ置換する根拠は弱い。

比較：
  単管では効くものが、バンドルでは同じようには効かない。
  これは単管とバンドルの差として読む価値がある。
```

これは失敗ではない。

むしろ当初の目的であった、

```text
単管で補正候補を見つける。
それをバンドルへ持ち込む。
効かなければ、単管とバンドルの差として読む。
```

という方針に対して、重要な結果である。

---

### 現時点の判断

```text
採用：
  ST-BT05 v3を採用する。

採用：
  単管では、Hsub/P/Tsub後にもx_eqが追加説明力を持つ。

保留：
  x_eqが純粋な独立効果なのか、
  L/D・沸騰履歴・二相発達の代理なのかは未確定。

バンドルへの扱い：
  x_eq補正式として即移植しない。
  単管とバンドルの差として読む。

不採用：
  ST-BT05 v1
  ST-BT05 v2

禁止：
  ST-BT05 v3だけでF(x_eq)補正式を作ること。
```

---

### 次の作業判断

ここで、単管・バンドル比較のための追加計算は一旦止める。

残る論点は以下である。

```text
1. 単管で見えたx_eq効果は、純粋なx_eq効果か、L/D・熱履歴の代理か。
2. バンドルでx_eqが効きにくい理由は何か。
3. F1(Tsub)を維持する判断でよいか。
4. L/D・熱履歴の検証は、Becker等の追加文献待ちでよいか。
```

次は、Claude Codeに全データを渡し、セカンドオピニオンを受ける。

---
