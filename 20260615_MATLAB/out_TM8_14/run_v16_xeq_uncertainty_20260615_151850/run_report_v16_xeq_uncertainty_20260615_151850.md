# AI_READ_THIS_FIRST

## run_id

v16_xeq_uncertainty_20260615_151850

## run_type

xeq_uncertainty_functionform_internal_qc

## input_files

- v10: `W:\out_TM8_14\TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx`

## このrunの目的

r5でT&M Table8-12数値診断ゲートを仮閉じしたが、Claudeレビューと櫻井コメントを受けて、source01原本確認前に内部で潰せる論点を確認する。

特に、x_Mesではなく、補正式候補として使える熱平衡クオリティ x_eq で再診断する。

あわせて、Table9/11/12の残差平均にn, SD, SE, CIを付け、Hsub線形フィットのテール影響も確認する。

## 前回までの判断

- v15では、Table8を除外し、source01 Table9-12を対象にした。
- Table9ではHsub補正後long側正残差は出ず、Table11では小さく、Table12では明確に残った。
- qMは結果側の量なので、補正式入力には使わないと整理した。
- 今回は、x_Mesも補正式入力には使わず、最終的な補正軸候補であるx_eqで確認する。

## QC確認

- x_eq列検出: false
- 検出されたx_eq列名: `NOT_FOUND`
- source01 Table9-12行数: 176
- Table8/9 explore_low行数: 46
- source01 Table9-12 真Hsub欠損: 0
- source01 Table9-12 PM_F1欠損: 0
- source01 Table9-12 x_eq欠損: 176

## 重要警告

x_eq列が検出できなかったため、x_eqを含むモデルは実行されていない。

この場合は、column_inventory.csvを確認し、x_eq列名をスクリプトのxeqCandidatesに追加するか、target_rows_T8_12にx_eq列を追加して再実行する。

## 主要結果

### source01 Table9-12 モデル説明力

- Hsub linear R2: 0.775
- Hsub quadratic R2: 0.821
- Hsub cubic R2: 0.896
- Hsub + L/D R2: 0.816
- Hsub + P + x_eq R2: NaN
- Hsub + L/D + P + x_eq R2: NaN

### same-table short-long残差差：Hsub linear

- Table9  long-short residual: -0.128
- Table11 long-short residual: 0.074
- Table12 long-short residual: 0.242
- Table12 SE_delta: 0.041
- Table12 CI95 approx: [0.163, 0.322]

### same-table short-long残差差：Hsub quadratic

- Table9  long-short residual: -0.187
- Table11 long-short residual: -0.034
- Table12 long-short residual: 0.105

### same-table short-long残差差：Hsub + P + x_eq

- Table9  long-short residual: NaN
- Table11 long-short residual: NaN
- Table12 long-short residual: NaN

### Table8 middleの確認

- Table8 middle - Table9 all residual, Hsub linear: -0.254
- Table8 middle - Table9 all residual, Hsub + P + x_eq: NaN

## MATLAB側の機械的まとめ

x_eq列が検出されていれば、x_Mesではなくx_eqを使って、source01 Table9/11/12のshort-long残差を再評価した。

また、Hsub linearだけでなく、Hsub quadratic/cubicを用いて、高Hsub端での関数形ミスがTable12 long正残差を作っていないかを確認した。

Table9/11/12の残差差にはn, SD, SE, CIを付け、残差差が点推定だけでなく不確かさ込みで意味を持つかを確認できるようにした。

Table8 middleについても、x_eq/P軸で見たときに、Table9との差がどう変わるかを確認した。

## DECISION_GATE

### このrunで判断を更新してよい項目

- x_Mesではなくx_eqで見ても、Table12 long正残差が残るか。
- Hsub関数形を二次・三次にしても、Table12 long正残差が残るか。
- Table9/11/12の残差差が、圧力順に並んでいるか。
- Table12 long正残差が、SE/CI込みで信号として扱えそうか。
- Table8 middleの除外判断が、x_eq/Pに替えても維持されるか。

### このrunではまだ判断してはいけない項目

- L/D補正式を採用すること。
- Table12 long正残差を純粋なL/D効果と断定すること。
- Table12 long正残差を純粋な圧力効果と断定すること。
- x_Mesを補正式入力に使うこと。
- qMを補正式入力に使うこと。

### 次のrunまたは次フェーズに送るべき保留

- qPの定義と、qP側に既に含まれているL/D項または長さ補正の確認。
- Hsub算出経路の表間整合確認。
- source01原本で、Table9/11/12が同一装置・同一系列の長さ違いか確認すること。
- Table12 longが単一管・単一キャンペーンの系統差ではないか確認すること。

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
- `csv/column_inventory.csv`
- `csv/S_by_table_LD.csv`
- `csv/S_xeq_xmes.csv`
- `csv/S_model_compare.csv`
- `csv/S_pair_uncertainty.csv`
- `csv/S_pressure_trend.csv`
- `csv/E_by_table_LD.csv`
- `csv/E_xeq_xmes.csv`
- `csv/E_model_compare.csv`
- `csv/E_T8_contrast.csv`
- `csv/decision_summary.csv`
