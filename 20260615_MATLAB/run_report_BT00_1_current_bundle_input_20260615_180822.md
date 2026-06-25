# BT00-1 current bundle input

作成日時: 20260615

## 1. 目的

r8レガシー・ブリッジブックを直接読み続けるのではなく、バンドル108/161/164の現行解析で使うシートだけを切り出したcurrent入力ブックを作成した。

## 2. 入力と出力

- 入力: `20260612_計算結果比較r8_result_文献追加用.xlsx`
- 出力: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`

## 3. current bundle の位置づけ

- r8はレガシー・ブリッジブックとして扱う。
- current bundleはBT01/BT02/BT03以降の入力として使う。
- tm系シートの列構成は極力そのまま保持した。
- F2/F1F2関係は含めない。
- README_CURRENT、DATA_DICTIONARY_CURRENT、SOURCE_MANIFESTを追加した。

## 4. Included sheets

| action | correction | case_id | source_sheet | current_sheet | n_rows | n_cols | read_status | note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| include | noF1 | 108 | tm_108 | tm_108 | 14 | 70 | included | readtable成功。列構成を保持してcurrentへ転記。 |
| include | noF1 | 161 | tm_161 | tm_161 | 23 | 70 | included | readtable成功。列構成を保持してcurrentへ転記。 |
| include | noF1 | 164 | tm_164 | tm_164 | 21 | 70 | included | readtable成功。列構成を保持してcurrentへ転記。 |
| include | F1 | 108 | tm_F1_108 | tm_F1_108 | 14 | 70 | included | readtable成功。列構成を保持してcurrentへ転記。 |
| include | F1 | 161 | tm_F1_161 | tm_F1_161 | 23 | 70 | included | readtable成功。列構成を保持してcurrentへ転記。 |
| include | F1 | 164 | tm_F1_164 | tm_F1_164 | 21 | 70 | included | readtable成功。列構成を保持してcurrentへ転記。 |

## 5. Excluded families

| action | correction | case_id | source_sheet | current_sheet | n_rows | n_cols | read_status | note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| exclude_family | F2 |  |  |  |  |  | not_read | F2関係は今回のcurrent bundleでは使用しない。 |
| exclude_family | F1F2 |  |  |  |  |  | not_read | F1F2関係は今回のcurrent bundleでは使用しない。 |
| exclude_family | F1F2/F2旧診断 |  |  |  |  |  | not_read | 過去検討・旧補正・補助診断はr8側に残し、currentには入れない。 |

## 6. 重要な列の認識

- `F1`: 単管データに基づくTsub補正。
- `F_form`: F1ではない。非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。
- `x_Mes`: バンドル側では熱平衡クオリティ `x_eq` として扱う。
- `F2` / `F1F2`: current bundleでは使用しない。

## 7. 次アクション

1. 出力されたcurrent bundleブックを確認する。
2. BT01/BT02をcurrent bundle入力で再現する。
3. 問題なければBT03以降はcurrent bundleを入力にする。
4. 次にBT00-2としてcurrent single-tube入力を作成する。
