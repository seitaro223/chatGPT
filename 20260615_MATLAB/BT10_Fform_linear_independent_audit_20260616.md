# BT10 F_form linear_v1 独立再実装 / 下層csv・md 全件diff監査

作成日時: 20260616
性格: 監査（audit）。採用/保留/撤回の判断はしない。補正式のフィットはしない。L/D効果の結論は書かない。
入力に result quantity（出口クオリティ等）は使っていない。level と gradient は混ぜていない。

## 0. 再実装した定義（既存コードは参照のみ・流用なし）

```text
x_DNB       = DNB位置 / 加熱長
f_DNB       = interp1(x, f, x_DNB)            線形補間
Blue_area   = ∫_0^{x_DNB} f(x) dx             台形＋最終区間を線形補間で部分積分
Orange_area = x_DNB * f_DNB
F_form      = Blue_area / Orange_area
```

f(x) 抽出元: `バンドルデータ整理r3.xlsx` シート `非一様加熱を一様加熱に補正108/161/164` 列E(z/L)・列F(f)。
再現スクリプト: `BT10_Fform_linear_independent_audit_20260616.py`

## 1. 全件 diff: 独立再計算 vs 記録済み F_form_linear

照合先: `BT08A3_macro_Fform_replace_map_20260616_145859.csv`(116行) /
`H52Q_current_bundle_input_v2b_FformLinear_...xlsx` の `Fform_linear` 列(116行) /
`BT08A2b_Fform_linear_master`(5マスタの Blue/Orange/Fform)。

| case | source_file | F_form_recomputed | recorded_linear | diff | ratio | flag |
| --- | --- | --- | --- | --- | --- | --- |
| 108_70in | r3:非一様...108 | 0.619821 | 0.619821 | +0.000000 | 1.000000 | ok |
| 108_76in | r3:非一様...108 | 0.733680 | 0.733680 | -0.000000 | 1.000000 | ok |
| 161_uniform | r3:非一様...161 | 1.000000 | 1.000000 | +0.000000 | 1.000000 | ok |
| 164_112in | r3:非一様...164 | 0.877644 | 0.877644 | +0.000000 | 1.000000 | ok |
| 164_134in_normal | r3:非一様...164 | 1.299993 | 1.299993 | -0.000000 | 1.000000 | ok |

行レベル全件（116行）の最大 |diff|:

| case | n_rows | max|diff| (linear列) | flag |
| --- | --- | --- | --- |
| 108_70in | 24 | 2.13e-11 | ok |
| 108_76in | 4 | 1.90e-11 | ok |
| 161_uniform | 46 | 0.00e+00 | ok |
| 164_112in | 2 | 2.52e-11 | ok |
| 164_134in_normal | 40 | 1.96e-11 | ok |

マスタ Blue/Orange 列も独立再計算と一致（|diff| < 1e-6, 全件）。
→ 閾値 |diff| > 0.005 を超えた linear ケース: なし。記録済み `Fform_linear` 列に -0.01型混入は検出されない。

## 2. 全件 diff: 独立再計算(linear_v1) vs 記録済み F_form_legacy

| case | F_form_recomputed | recorded_legacy | diff | ratio | flag |
| --- | --- | --- | --- | --- | --- |
| 108_70in | 0.619821 | 0.654328 | -0.034507 | 0.947263 | FLAG_gt_0.005 |
| 108_76in | 0.733680 | 0.760494 | -0.026814 | 0.964741 | FLAG_gt_0.005 |
| 161_uniform | 1.000000 | 1.000000 | +0.000000 | 1.000000 | ok |
| 164_112in | 0.877644 | 1.014000 | -0.136356 | 0.865527 | FLAG_gt_0.005 |
| 164_134in_normal | 1.299993 | 1.363000 | -0.063007 | 0.953773 | FLAG_gt_0.005 |

## 3. Blue_area 分解（legacy差の機械的内訳）

`blue_clean` = linear_v1 の Blue（x_DNB で止める）。
`blue_one_node_past` = SUM が x_DNB の1つ先のグリッド節点まで走った場合。
`legacy_blue_used` = legacy F_form が実際に使った Blue。

| case | x_DNB | node直後z | blue_clean | blue_1node_past | legacy_blue_used | legacy_blue の正体 |
| --- | --- | --- | --- | --- | --- | --- |
| 108_70in | 0.729167 | 0.755 | 0.715229 | 0.755174 | 0.755174 | = cumInt(z=0.755) = 1節点先まで混入 |
| 108_76in | 0.791667 | 0.833 | 0.808500 | 0.862749 | (該当なし) | legacy=0.760494 は Blue/Orange で再現不能（§5-c） |
| 161_uniform | 0.997024 | 1.000 | 0.997024 | 1.000000 | 1.000000 | 1節点先まで混入だが一様加熱でFは不変 |
| 164_112in | 0.666667 | 0.771 | 0.744301 | 0.859646 | 0.859646 | = cumInt(z=0.771) = 1節点先まで混入 |
| 164_134in_normal | 0.797619 | 0.831 | 0.883484 | 0.910106 | 0.926529 | = cumInt(z=0.870, **2節点先**) − **0.01** (§5-a) |

## 4. グリッド節点 cumInt 参照（混入位置の同定根拠）

108: x_DNB=0.729167 は node19(z=0.729)直後。cumInt(node19)=0.714965, cumInt(node20 z=0.755)=0.755174。
108: x_DNB=0.791667 は node21(z=0.781)〜node22(z=0.833)。cumInt(node22)=0.862749。
164: x_DNB=0.666667 は node19(z=0.662)〜node20(z=0.771)。cumInt(node20)=0.859646。
164: x_DNB=0.797619 は node20(z=0.771)〜node21(z=0.831)。cumInt(node21 1節点先)=0.910106, cumInt(node22 z=0.870, 2節点先)=0.936529。
  → 0.936529 − 0.926529 = **0.010000**（厳密）。

## 5. 疑わしい混入箇所リスト（ファイル・行・理由）

### 5-a. -0.01型 手動オフセット ＋ DNB下流側2節点混入（最有力）
- file: `164r1.xlsx`（経由: `run_report_BT08A1c_Fform_164_blue_area_audit_...md` §4 `user_confirmed_blue_area`）
- 対象: case `164_134in_normal`（x_DNB=0.797619）
- 値: legacy Blue_area = **0.926529**
- 理由: cumInt(z=0.870)=0.936529 は x_DNB の **2節点先** まで積分。さらに **0.936529 − 0.010000 = 0.926529** と一致。
  下流側面積の混入（2節点）と、SUMからの手動 −0.01 の二重。legacy F_form=1.363 の発生源。

### 5-b. DNB下流側1節点の面積混入（r3 全5ケース共通の分子）
- file: `バンドルデータ整理r3.xlsx` シート `02_xeq_recalc`、行5–9、列C「DNB位置まで累積(分子)」
  - C5: 108/0.72917 = 0.75517（= cumInt 1節点先, clean=0.715229）
  - C6: 108/0.79167 = 0.86275（= cumInt 1節点先, clean=0.808500）
  - C7: 161/0.99702 = 1（一様, Fは不変）
  - C8: 164/0.66667 = 0.85965（= cumInt 1節点先, clean=0.744301）
  - C9: 164/0.79762 = 0.91011（= cumInt 1節点先, clean=0.883484）
- 理由: 全ケースで x_DNB を含む区間の台形を「丸ごと1区間先の節点まで」加算。
  ※この分子は x_eq/z_heat_ratio 用。F_form 入力として混ぜていない（参照のみ）。同一の汚染Blueが下記5-c/5-dへ伝播。

### 5-c. SUM範囲ラベルと実体の不一致（108_70in）／ stray old値（108_76in）
- file: `F_Form_108整理版.xlsx` シート `108_Fform_check`
  - 行2: `Blue_end_x`(N2)=0.729 と表示しつつ `Blue_area`(O2)=0.755174 は z=0.755（1節点先）まで積分 → ラベルと SUM 実体が不一致。
    `F_form_corrected`(Q2)=0.654328 ＝ current_bundle の 108_70in legacy 発生源。
  - 行3: `F_form_old`(R3)=0.760494。current_bundle の 108_76in legacy はこの **F_form_old セルの値**。
    76in は Blue/Orange の再計算結果ではない（clean=0.733680, 1節点先=0.782909 のいずれとも不一致）。定義列の取り違え。

### 5-d. legacy 164_112in の1節点先混入
- file: `164r1.xlsx` / r3（§5-b C8 と同値）
- 値: legacy Blue_area = 0.859646（= cumInt 1節点先, clean=0.744301）→ legacy F_form=1.014 の発生源。

## 6. フラグ要約

| flag | 対象 | 値 |
| --- | --- | --- |
| linear_v1_reproduced | 全5マスタ・116行・Blue/Orange | max|diff| ≤ 2.13e-11 |
| linear_contamination_found | recorded Fform_linear 列 | なし |
| legacy_diff_gt_0.005 | 108_70in,108_76in,164_112in,164_134in_normal | -0.0345/-0.0268/-0.1364/-0.0630 |
| minus_0.01_manual_offset | 164_134in_normal (164r1 user_confirmed_blue) | 0.936529−0.926529=0.010000 |
| downstream_area_1node | r3 02_xeq_recalc C5,C6,C8,C9 / 108整理版 O2 / 164_112in | clean→1節点先 |
| downstream_area_2node | 164_134in_normal legacy blue | clean→cumInt(z=0.870) |
| label_vs_sum_mismatch | 108整理版 108_Fform_check N2 vs O2 | Blue_end_x=0.729 / Blue_area=0.755174 |
| wrong_column_carryover | 108_76in legacy | = F_form_old セル(R3)=0.760494 |
