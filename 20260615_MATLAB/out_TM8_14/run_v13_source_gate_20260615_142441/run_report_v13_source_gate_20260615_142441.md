# AI_READ_THIS_FIRST

## run_id

v13_source_gate_20260615_142441

## run_type

source_gate_decision

## input_files

- v10: `W:\out_TM8_14\TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx`

## このrunの目的

Table8 middle が低く出る理由について、P/xMes条件差だけでなく source差が混じっている可能性を確認する。

特に、Table8 が source03、Table9以降が source01 である場合、Table8 middleをL/D検証用の中間点として単純に扱ってよいかを判断する。

## 前回までの判断

- v12では、PWR_near Table12の正残差と explore_low Table8 middle低下を、いったん別問題として扱う方針にした。
- explore_low Table8/9は、L/D補正式の支持・反証データとして単純には使わないと整理した。
- ただし、Table8がsource03で、他がsource01であるなら、Table8 middle低下にはsource差・装置差・整理系列差も混じる可能性がある。

## QC確認

- v10の target_rows_T8_12 を読み込み、No_TableNoから SourceID を抽出した。
- SourceIDは、No_TableNo内の `.01_` や `.03_` のような部分から機械的に抽出した。
- このrunでは新規の物理量計算は行わず、source/Table/L-D/P_scope の交絡確認を行った。

## 主要結果

### source概要

- Table8 middle の主source: `03`
- Table9 の主source: `01`
- PWR_near Table10-12 の主source: `01`
- Table8 middle のsource種類数: 1
- Table9 のsource種類数: 1
- PWR_near のsource種類数: 1

### source03の分布

- source03のTable: 8
- source03のL/D band: middle
- source03のP_scope: explore_low_T8_9
- source03がTable8だけに閉じているか: true
- source03がmiddleだけに閉じているか: true

### Table8 middle と Table9 all の差

- Table8 middle PM_F1平均: 0.738
- Table9 all PM_F1平均: 1.184
- PM_F1差, Table8 middle - Table9 all: -0.446
- P差, Table8 middle - Table9 all: -1.021 MPa
- xMes差, Table8 middle - Table9 all: 0.271
- Hsub平均, Table8 middle: 398.982 kJ/kg
- Hsub平均, Table9 all: 791.026 kJ/kg
- qM平均, Table8 middle: 1.921 MW/m2
- qM平均, Table9 all: 4.137 MW/m2

## MATLAB側の機械的まとめ

Table8 middle は Table9 と比べて PM_F1 が低い。

ただし、Table8 middle は P/xMes/Hsub/qM がTable9と異なるだけでなく、sourceも異なる可能性がある。

source03がTable8 middleにほぼ閉じている場合、source差、Table差、L/D band差、P/xMes条件差を分離できない。

したがって、Table8 middleはL/D検証用の中間点としてはさらに使いにくい。

## DECISION_GATE

### このrunで判断を更新してよい項目

- Table8 middle低下には、P/xMes条件差に加えて source差・装置差・整理系列差が混じる可能性がある。
- Table8 middleは、L/D補正式の支持・反証データとして単純には使わない。
- explore_low Table8/9は、PWR_near Table12のL/D/熱履歴保留を否定する材料にはしない。

### このrunではまだ判断してはいけない項目

- source03だからTable8 middleが低い、と断定すること。
- Table8 middle低下を純粋なsource効果と断定すること。
- Table8 middle低下を理由に、PWR_near Table12の正残差を否定すること。
- L/D補正式を採用すること。

### 次のrunに送るべき保留

- PWR_near Table10-12はsourceが揃っているなら、PWR_near内でTable12残差を再整理する。
- PWR_near限定で、Table12 long正残差がTable12固有か、P/xMes/qM/物性差か、L/D/熱履歴成分かを再確認する。

## ChatGPTにしてほしいこと

このrun_report.mdを読んで、以下を日本語で説明してください。

1. 今どこまで進んだか
2. このrunで新しく分かったこと
3. 前回判断から変わったこと
4. まだ言ってはいけないこと
5. 危ない解釈
6. 次にやるべきこと
7. result / internal / 保留の扱い
8. 櫻井がコメントすべき最小ポイント

## 添付保存物

- `summary_tables.xlsx`
- `csv/basic.csv`
- `csv/by_source.csv`
- `csv/by_source_table.csv`
- `csv/by_source_table_LD.csv`
- `csv/source_gate.csv`
- `csv/T8_middle_contrast.csv`
- `csv/decision_summary.csv`
