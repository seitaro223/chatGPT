# AI_READ_THIS_FIRST

## run_id

v12_scope_split_20260615_141333

## run_type

scope_split_decision_gate

## input_files

- v10: `W:\out_TM8_14\TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx`
- v11: `W:\out_TM8_14\TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx`

## このrunの目的

v10/v11までの結果を使って、PWR_near Table10-12 と explore_low Table8-9 を同じ補正式候補に混ぜてよいかを判断する。

特に、PWR_near Table12に残る正残差と、explore_low Table8 middle低下を同じL/D問題として扱うべきかを確認する。

## 前回までの判断

- v9では、PWR_near Table12 long側の真Hsub補正後正残差は、L/Dを入れると大きく低減した。
- v10では、explore_low Table8/9を含めると、Hsub補正後残差は同じL/D方向には並ばなかった。
- v11では、Table8 middle低下は、L/DではなくxMesとPの違いでかなり説明できる可能性が高いと整理した。

## QC確認

- v10/v11の既存出力を読み込み、主要表を再集約した。
- このrunでは新規の結合・再計算は行わず、判断ゲート用の再整理を行った。
- 元のQCはv10/v11のQC結果を前提とする。

## 主要結果

### PWR_near側

- PWR_nearのHsub-only補正後 long-short 残差差: 0.114
- したがって、PWR_nearではlong側が上に残る傾向は維持される。

### explore_low側

- explore_lowのHsub-only補正後 long-short 残差差: -0.120
- explore_lowのHsub-only補正後 middle-short 残差差: -0.290
- Table8 middle PM_F1: 0.738
- Table8 middle Hsub-only残差: -0.165

### Table8 middle低下の分解

- Hsub only R2: 0.544
- Hsub + P R2: 0.824
- Hsub + xMes R2: 0.916
- Hsub + P + xMes R2: 0.922
- Hsub + P + xMes + Table8 dummy R2: 0.922
- Hsub + P + xMes + qM R2: 0.967

Table8 middle - Table9 all の差:

- PM_F1差: -0.446
- P差: -1.021 MPa
- xMes差: 0.271
- Hsub差: -392.044 kJ/kg
- qM差: -2.216 MW/m2

## MATLAB側の機械的まとめ

PWR_nearでは、Hsub補正後もlong側に正残差が残る。

一方、explore_lowでは、Table8 middleが低く、short-middle-longのL/D方向の単純な並びは出ない。

ただし、Table8 middleの低下はxMesとPを入れるとかなり説明でき、Table8 dummyを追加しても説明力はほとんど改善しない。

このため、explore_low Table8/9は、L/D補正式の支持または反証データとして単純には扱いにくい。

## DECISION_GATE

### このrunで判断を更新してよい項目

- PWR_near Table12の正残差と、explore_low Table8 middle低下は、いったん別問題として扱う。
- explore_low Table8/9は、L/D補正式の支持・反証データとして単純には使わない。
- explore_lowは、xMes/P依存を確認する診断データとして扱う。

### このrunではまだ判断してはいけない項目

- PWR_near Table12の正残差を純粋なL/D効果と断定すること。
- L/D補正式を採用すること。
- explore_lowを理由にPWR_near Table12の保留を否定すること。

### 次のrunに送るべき保留

- PWR_near Table12に限定して、正残差がTable12固有か、圧力・物性・xMes・qMで説明できるかをさらに整理する。
- 補正式候補に進むなら、PWR_near限定のローカル補正として扱うかを検討する。

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
- `csv/decision_summary.csv`
- `csv/v10_direction_check.csv`
- `csv/v10_Table8_middle_context.csv`
- `csv/v11_group_summary.csv`
- `csv/v11_group_contrast.csv`
- `csv/v11_model_compare_PM_F1.csv`
- `csv/v11_match_summary.csv`
