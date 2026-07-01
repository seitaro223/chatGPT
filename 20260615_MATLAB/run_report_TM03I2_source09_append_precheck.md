# TM03I2 source09 append precheck

## 入力と方針
- 研究ログ `20260615_H52Q_working_log_r76.md` では、Tsub/Hsub正規化前に、qMだけで説明しないこと、入口サブクール条件を切り分けること、Table 10をPWR近傍主解析群に含めることが整理されている。
- 今回は xlsm 本体を直接編集せず、source09 / Weatherhead Table10 の B-like lowX 117点を現行 `tm` シートへ安全に投入するための列対応とプレビューを作成した。

## xlsm構造確認
- 対象ブック: `celataモデル_簡易計算_単管_櫻井検算r129_F1なし_09追加予定.xlsm`
- シート: SatProp, Cp_T_low, Cp_T_mid, Cp_T_high, tm, Log
- 入力シート名: `tm`
- `tm` ヘッダ行: 1
- `tm` データ開始行: 2
- `tm` 既存データ最終行: 502
- `tm` 既存列数: 70
- Excelテーブル: `テーブル2` 範囲 `A1:BR502`
- 名前定義: L_tot, 半径方向の出力
- 既存行識別: `No_TableNo` は例 `9.01_10`、`No` は実験番号、末尾 `_10`/`_11`/`_12` がTable相当。source列は既存tmに存在しないため、source09は投入IDで区別する必要がある。
- No/Table/source/Expt No/P/G/D/L/D/Hsub/x/qM: `No`=M, Tableは`No_TableNo`末尾, sourceは専用列なし, Expt No=`No`, P=B, G=N, D=`DH` Q, L/Dは専用列なし（DとL_DNBから診断）, Hsub専用列なし, x=`x_Mes` BH, qM=`q_M` BE。
- 数式/物性列: C:L, O:P, U:BD, BF, BL:BP などは既存数式コピー対象。値で潰さない。
- 値入力候補: A `No_TableNo`, B `P`, M `No`, N `G`, Q `DH`, R `L_DNB`, S `q_in`, BE `q_M`, BG `F_form`, BH `x_Mes`, BK `Fcorr`, BQ `F2`, BR `L`。
- 注意: VBA/名前定義/Excelテーブル `テーブル2` の構造を壊さないため、行追加時はテーブル範囲拡張と数式コピーが必要。今回はマクロ実行・再計算・保存なし。

## 検証結果
- 追加対象行数: 117 点
- 条件一致: x<=0.05 117/117, G<=4200 117/117, L/D>=40 117/117
- G分類: 1900<=G<=4200 は 40 点、G<1900 は 77 点
- source内キー重複 (`ExptNo`,`source`): 0 件
- 既存 `No_TableNo` との衝突（予定ID）: 0 件
- 欠損値: {'flag': 63}

## 単位変換
- Dia_in: inch -> m (`*0.0254`) として `DH` へ投入予定。
- Length_in: inch -> m (`*0.0254`) として `L_DNB`/`L` へ投入予定。
- qCHF_MW_m2: MW/m^2 -> W/m^2 (`*1e6`) として `q_in`/`q_M` へ投入予定。
- G_kg_m2_s は変換なしで `G` へ投入予定。
- P は Table10 2000 psia 相当の既存値 `13,789,520 Pa` を定数投入候補。

## 既存tm列へ入れられない列
source, Table10, Weatherhead/ANL由来, 元ID, flag_norm, Hsub_kJkg, L_over_D, G_band2, x_band2 は tm 既存70列に専用列がないため、プレビューCSV末尾のメタ列として保持した。xlsm本体へ入れる場合は別メタ管理表またはID埋め込みが必要。

## 判断保留が必要な列
- `Tin`: source09 CSVに直接列がない。HsubからTin相当を逆算するには圧力別物性と既存VBAの扱い確認が必要。
- `BI A_corr`, `BJ σ_corr`, `BK Fcorr`, `BG F_form`, `BQ F2`: 既存source01等の定数踏襲でよいか要確認。
- `No_TableNo` 形式: 既存形式との互換性を重視するなら `294.09_10`、source識別を優先するなら `294.09_10_source09`。プレビューは衝突回避のため後者。

## xlsm直接編集へ進んでよいか
条件・行数・キー重複は投入準備として問題なし。ただし `Tin` と補正式定数/ID形式の判断が未確定のため、現時点では本体直接編集ではなく、コピー版xlsmで追記テストする段階が安全。

## 次ステップ比較
| 案 | 長所 | 短所 | 評価 |
|---|---|---|---|
| A. Excel上で手動貼付 | 数式・テーブル拡張を目視確認しやすい | 117行×70列で貼付ミス、ID/数式の混在ミスが起きやすい | 小規模確認向き |
| B. 小さなVBA追記マクロ | ブック内のテーブル/VBA文脈で数式コピーしやすい | マクロ本体を増やす・実行ログ管理が必要。本作業の禁止事項に近い | Excel環境固定なら有力 |
| C. Python/openpyxlでコピー版xlsmへ追記 | 本体を守り、CSVから再現可能。差分/検証を自動化しやすい | xlsmのVBA保持・テーブル/数式/配列数式の扱いを慎重に検証する必要 | 推奨。まずコピー版で実施 |

推奨: C。コピー版xlsmに対して openpyxl で値列のみ投入し、直上行から数式列をコピー、テーブル範囲を拡張する小スクリプトを作る。その後Excelで開いて再計算・マクロ実行を確認する。
