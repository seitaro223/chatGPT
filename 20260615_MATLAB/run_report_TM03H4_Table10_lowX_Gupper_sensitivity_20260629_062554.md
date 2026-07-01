# TM03H4 Table10 lowX G上限感度診断

作成時刻: 2026-06-29T06:25:55

## 目的

Table10 source01 lowX/current_resultについて、まず `x <= 0.05` を固定する。
そのうえで、G下限は切らず、G上限 `4200 kg/m2s` の有無だけを感度条件として確認した。

これは補正式作成ではなく、Table10低クオリティ集合の中で、超高G側を分けるべきかを見る診断である。

## 入力

- valid current_result: `/mnt/data/TM03EF_current_result_acceptance_QA_20260629_135859_records_valid277.csv`
- excluded: `/mnt/data/TM03EF_current_result_acceptance_QA_20260629_135859_excluded.csv`

## 対象

- Table10 valid OK: 187 点
- x<=0.05: 187 点
- x>0.05: 0 点
- G<=4200: 117 点
- G>4200: 70 点
- Table10 excluded/fail in main280: 3 点

## 主条件

```text
A: x <= 0.05, all G
B: x <= 0.05, G <= 4200
C: x <= 0.05, G > 4200
```

G下限は設けていない。

## 主結果: PM_noF1 への単純R2

```text
A: x<=0.05, all G
  Tsub R2      = 0.418
  x R2         = 0.774
  G R2         = 0.015
  Tsub+x R2    = 0.828
  Tsub+x+G R2  = 0.851

B: x<=0.05, G<=4200
  Tsub R2      = 0.455
  x R2         = 0.768
  G R2         = 0.014
  Tsub+x R2    = 0.839
  Tsub+x+G R2  = 0.856

C: x<=0.05, G>4200
  Tsub R2      = 0.670
  x R2         = 0.901
  G R2         = 0.065
  Tsub+x R2    = 0.904
  Tsub+x+G R2  = 0.906
```

## 読み

1. Table10 current_result は全点 `x <= 0.05` であり、まずこの低クオリティ集合を基準にするのが自然。
2. `G <= 4200` と `G > 4200` を分けると、どちらでも x 側の説明力が強い。
3. G単独の説明力は限定的であり、G上限カットは主条件ではなく感度条件として扱うのがよい。
4. G下限は切っていない。低Gでも `x<=0.05` であれば、DNB的に扱いたい気泡流〜スラグ流側の候補を落とす可能性があるため。

## 判断

現時点では、Table10 lowXに対しては以下の方針が安全。

```text
主条件:
  x <= 0.05, G下限なし

感度条件:
  x <= 0.05, G <= 4200
  x <= 0.05, G > 4200

使わない方針:
  R2が良くなるようにxしきい値とGしきい値を同時最適化すること
  PWR代表G下限だけでTable10 lowX点を機械的に落とすこと
```

## 出力

- summary: `TM03H4_Table10_lowX_Gupper_sensitivity_20260629_062554_summary.csv`
- model_R2: `TM03H4_Table10_lowX_Gupper_sensitivity_20260629_062554_model_R2.csv`
- incremental_R2: `TM03H4_Table10_lowX_Gupper_sensitivity_20260629_062554_incremental_R2.csv`
- quality/G cell summary: `TM03H4_Table10_lowX_Gupper_sensitivity_20260629_062554_quality_Gcell_summary.csv`
- records with bins: `TM03H4_Table10_lowX_Gupper_sensitivity_20260629_062554_records_with_bins.csv`

