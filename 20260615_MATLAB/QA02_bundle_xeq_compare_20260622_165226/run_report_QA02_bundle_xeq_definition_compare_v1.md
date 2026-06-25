# H52Q-QA-02 バンドル108/161/164のx_eq定義比較

## 目的

- 西田さん側の認識：NFI報告書に記載されたCOBRA-EN出力 `Xloc`。
- 櫻井側の認識：実験CHF条件から計算した熱平衡クオリティ。
- 両者をケースごとに横並びにし、108/161/164のクオリティ帯の見え方が変わるか確認する。

## 入力

- current bundle workbook: `H52Q_current_bundle_input_v2_FformLinearRecalc_tmCompatible_20260617_091038.xlsx`
- NFI Xloc csv: `NFI_Xloc_from_NFK_TT_26001_report_v1.csv`

## 定義

- `xeq_expBasis`: current_bundleの `x_Mes` 列。実験CHF条件から計算した熱平衡クオリティとして扱う。
- `Xloc_NFI_COBRA`: NFI報告書の表3.2-3〜3.2-5に記載された、最小DNBR位置の局所熱平衡クオリティ。
- `delta_xeq_exp_minus_NFI = xeq_expBasis - Xloc_NFI_COBRA`。

## 試験別サマリ

| test | N | mean xeq_expBasis | mean Xloc_NFI | mean delta | median delta | max abs delta | frac exp x<=0 | frac NFI x<=0 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 108 | 14 | -0.01399 | -0.04003 | 0.02604 | 0.02965 | 0.05361 | 0.571 | 0.786 |
| 161 | 23 | -0.08232 | 0.14877 | -0.23110 | -0.21547 | 0.49011 | 0.565 | 0.000 |
| 164 | 21 | -0.15528 | 0.00550 | -0.16077 | -0.12036 | 0.51537 | 0.810 | 0.619 |

## 読み方

1. `xeq_expBasis` と `Xloc_NFI_COBRA` が同程度なら、両者は同じクオリティ帯を見ている。
2. `Xloc_NFI_COBRA` が大きく正側、`xeq_expBasis` が負側〜0近傍なら、NFI側の「高クオリティ」という認識はCOBRA最小DNBR位置に依存している可能性がある。
3. L/DやDNB位置の議論に入る前に、どちらのクオリティ定義を横軸にしているかを明示する。
4. このrunでは補正式を作らない。クオリティ定義の棚卸しだけを行う。

## 出力

- `QA02_bundle_xeq_definition_compare_v1.xlsx`
- `fig_QA02_01_xeq_expBasis_vs_NFI_Xloc.png`
- `fig_QA02_02_delta_xeq_by_case.png`
- `fig_QA02_03_xeq_distribution_by_test.png`
