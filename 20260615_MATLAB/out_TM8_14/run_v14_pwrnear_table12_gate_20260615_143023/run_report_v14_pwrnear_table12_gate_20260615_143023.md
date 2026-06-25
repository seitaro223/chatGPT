# AI_READ_THIS_FIRST

## run_id

v14_pwrnear_table12_gate_20260615_143023

## run_type

pwrnear_source01_table12_decision_gate

## input_files

- v10: `W:\out_TM8_14\TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx`

## このrunの目的

explore_low Table8/9を外し、source01で揃っているPWR_near Table10-12のみを対象に、Table12 long正残差を再整理する。

Table12 long側の正残差が、Table12固有差、P/xMes/qM差、L/D/熱履歴成分のどれに近いかを判断するためのゲートrunである。

## 前回までの判断

- v13では、Table8 middleはsource03に閉じており、L/D検証点として単純には使わないと整理した。
- explore_low Table8/9は、PWR_near Table12の正残差を否定する材料にはしない。
- したがって、今回はPWR_near Table10-12、source01限定に戻る。

## QC確認

- PWR_near Table10-12かつ source01 のみに限定した。
- 対象行数: 146
- Table10行数: 86
- Table11行数: 30
- Table12行数: 30
- source種類数: 1
- 真Hsub欠損: 0
- PM_F1欠損: 0

## 主要結果

### モデル説明力

- Hsub only R2: 0.806
- Hsub + L/D R2: 0.881
- Hsub + P R2: 0.814
- Hsub + xMes R2: 0.855
- Hsub + qM R2: 0.923
- Hsub + P + xMes + qM R2: 0.935
- Hsub + L/D + P + xMes + qM R2: 0.935
- Hsub + Table12 dummy R2: 0.814
- Hsub + L/D + Table12 dummy R2: 0.895

### Table12 short-long差

- raw PM_F1 long-short: 0.722
- Hsub only residual long-short: 0.201
- Hsub + L/D residual long-short: 0.048
- Hsub + P residual long-short: 0.239
- Hsub + xMes residual long-short: 0.108
- Hsub + qM residual long-short: 0.058
- Hsub + P + xMes + qM residual long-short: 0.095
- Hsub + L/D + P + xMes + qM residual long-short: 0.090

### Table11との比較

- Table11 raw PM_F1 long-short: 0.535
- Table11 Hsub only residual long-short: 0.034
- Table11 Hsub + L/D residual long-short: -0.129
- Table12 long - Table11 long raw PM_F1: 0.206
- Table12 long - Table11 long Hsub only residual: 0.168
- Table12 long - Table11 long Hsub+LD+P+xMes+qM residual: 0.127

## MATLAB側の機械的まとめ

PWR_near source01に限定しても、Table12 long側の正残差が残るかを確認した。

Hsubのみ、Hsub+P、Hsub+xMes、Hsub+qM、Hsub+L/D、Table12 dummyのどれで残差が減るかを比較した。

Table11とTable12のshort-long差の違い、Table12 longとTable11 longの差も確認した。

## DECISION_GATE

### このrunで判断を更新してよい項目

- PWR_near source01限定で、Table12 long正残差がどの説明変数で減るか。
- Table12 long正残差を、P/xMes/qM差、Table12固有差、L/D/熱履歴成分のどれとして保留するのが妥当か。

### このrunではまだ判断してはいけない項目

- L/D補正式を採用すること。
- Table12 long正残差を純粋なL/D効果と断定すること。
- Table12固有差、圧力差、物性差のどれか一つに断定すること。

### 次のrunに送るべき保留

- 補正式候補に進むか、PWR_near限定の診断項に留めるか。
- Table12 long正残差を、文献追加やBecker到着後の検証対象として残すか。

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
- `csv/by_table_LD.csv`
- `csv/model_compare.csv`
- `csv/model_coefficients.csv`
- `csv/same_table_pairs.csv`
- `csv/T12long_vs_T11long.csv`
- `csv/T12long_baseline_compare.csv`
- `csv/decision_summary.csv`
