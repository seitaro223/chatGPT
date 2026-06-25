# H52Q / T&M抽出条件 横断監査

作成日: 2026-06-25
対象プロジェクト: `20260615_MATLAB`（再帰探索）
作成目的: 今後の `TM00_all_tables_common_lowX_inventory` 仕様の前提整理（新規解析は実行しない）

---

## 0. 監査の前提（必ず最初に明記）

- 今回の監査では、**mdだけでなく、サブフォルダ内のmファイルとxlsx出力も探索対象にした。**
- **初期段階では `run_report_*.md` が存在せず、xlsxのみ出力されていた**ことが実際に確認できたため、mdの有無だけでは作業履歴を判断していない。
- 抽出条件の確定には、できるだけ **MATLABスクリプト内の実装を優先**した（`x_report<=0.05`、`G×1356.23`、source判定などは実装行を直接引用）。
- xlsxのみ確認できるrun、および**Excelマクロ側（プロジェクト外のr8ブック）で既に抽出済みだった集合**については、条件の確度を下げて扱った。
- 重要な構造的事実: **旧86点もTable8〜14のステージングも、このMATLABフォルダ内のmファイルで「新規抽出」されたものではない。** Excelマクロ計算ブック（`20260612_計算結果比較r8_*.xlsx`）で既に選別・計算済みのデータを、MATLAB側は読み込んで層別・診断しているだけである。MATLABが純粋に正本Markdownから抽出条件を実装し直したのは、**Table10再監査（T10R系, 2026-06-25）が初めて**である。

---

## 1. 目的

Weatherhead文献（ANL-6675相当）が届いた段階で、T&M／Weatherhead／Becker等を**同じ基準・同じ単位系・同じ列定義**で比較できるようにするため、まずT&M側の過去の抽出条件・除外条件・層別条件を棚卸しする。新規データの追加や新規解析は行わず、`TM00_all_tables_common_lowX_inventory` の仕様根拠を整える。

暫定方針（本監査で妥当性を確認する対象）:

```text
入口条件:        x_report <= 0.05
最初から切らない: source, G, L/D, flag
層別軸:          Table, source, G_SI, L/D, D_mm, Hsub, flag
```

---

## 2. 調査対象ファイル

### 2.1 探索方法

- **ルートフォルダ**: `/home/user/chatGPT/20260615_MATLAB`
- **サブフォルダ再帰探索**: 実施した（`out_TM8_14/` 配下の `run_v12`〜`run_v16c`、`H52Q_consult_figures_*`、`QA02_*` を含む）。
- **対象拡張子**: `.md .m .xlsx .xlsm .csv .png .pdf`、および `run_report_*.md` / `T10R*.m` / `TM*.m` / `ST*.m` / `BT*.m`。
- **総ファイル数**: 390
  - mdファイル数: 62（うち `run_report_*.md` = 57）
  - mファイル数: 86
  - xlsxファイル数: 82 / xlsmファイル数: 2
  - csv: 44 / png+pdf: 113
- **同名・近名ファイルの整理方針**: ファイル名のrun番号（v1〜v16c, T10R00〜03 など）とタイムスタンプ（`YYYYMMDD_HHMMSS`）で時系列整理した。古い候補は破棄せず「古い候補」として下表に残した。

mファイルの系列（prefix別）:

| prefix | 系列の意味 | 時期 |
|---|---|---|
| `h52q_tm8_14_*` (v1〜v16) | T&M Table8〜14 横断診断（PM vs Hsub/L/D等） | 2026-06-15 午前〜午後 |
| `BT*` | バンドル（bundle）F1/Fform診断系 | 06-15〜06-18 |
| `ST*`, `STF*`, `STLD*` | 単管（single tube）F1/Tsub/L-D診断系 | 06-17〜06-19 |
| `T10R00〜T10R03` | **Table10再監査（正本Markdownから直接抽出）** | 2026-06-25 |
| `QA01/QA02` | 報告書転記クオリティ・x_eq定義照合 | 06-22〜06-24 |

### 2.2 mdがない初期runの扱い

**最重要の構造的発見**。`run_report_*.md` が出力されるのは **v12（`run_v12_scope_split`, 2026-06-15 14:13）以降**である。それ以前の `h52q_tm8_14_*` v1〜v11 は **xlsxのみ出力で run_report md を持たない。**

- **run_reportが存在するrun**: v12, v13, v14, v15, v16, v16b, v16c（`out_TM8_14/run_v*/run_report*.md`）、および BT系・ST系・T10R系の各 `run_report_*.md`（計57本）。
- **xlsxのみ出力だった初期run（mdなし、未実施と誤判定しないこと）**:

  | run | mファイル | 出力xlsx（`out_TM8_14/`） | 時刻 |
  |---|---|---|---|
  | diag_v1 | `h52q_tm8_14_diag_v1.m` | `TM8_14_diag_output_20260615_093617.xlsx` | 09:36 |
  | compare_v2 | `h52q_tm8_14_compare_v2.m` | `TM8_14_compare_v2_20260615_093937.xlsx` | 09:39 |
  | confounds_v3 | `h52q_tm8_14_confounds_v3.m` | `TM8_14_confounds_v3_20260615_*.xlsx` | 09:51,10:05 |
  | shortlong_v4 | `h52q_tm8_14_shortlong_v4.m` | `TM8_14_shortlong_v4_20260615_101033.xlsx` | 10:10 |
  | integrated_v5 | `h52q_tm8_14_integrated_v5.m` | `TM8_14_integrated_v5_20260615_102324.xlsx` | 10:23 |
  | pwrnear_v6 | `h52q_tm8_14_pwrnear_v6.m` | `TM8_14_pwrnear_v6_20260615_103144.xlsx` | 10:31 |
  | tsub_residual_v7b | `h52q_tm8_14_tsub_residual_v7b.m` | `TM8_14_tsub_residual_v7b_*.xlsx` | 10:54 |
  | true_hsub_v8a/8b | `..._true_hsub_v8a_make_input.m` / `_v8b.m` | `TM8_14_true_hsub_*_v8*.xlsx` | 11:21,13:01 |
  | residual_decomp_v9 | `h52q_tm8_14_residual_decomp_v9.m` | `TM8_14_residual_decomp_v9_*.xlsx` | 13:07 |
  | explorelow_v10 | `h52q_tm8_14_explorelow_truehsub_v10.m` | `TM8_14_explorelow_truehsub_v10_*.xlsx` | 13:40 |
  | table8_middle_v11 | `h52q_tm8_14_table8_middle_decomp_v11.m` | `TM8_14_table8_middle_decomp_v11_*.xlsx` | 13:48 |

- **mファイルから復元した初期runの実装事実**:
  - 入力は正本Markdownではなく、**Excelステージングブック** `20260612_計算結果比較r8_staging_TM8_14_v1.xlsx`（シート `STG_added138_noF1/F1`, `SRC_tm_r123_noF1_T8_14`, `SRC_tm_r124_F1_T8_14`）および `..._result_文献追加用.xlsx`。
  - 初期runは `readtable(..., "Sheet", ...)` → `writetable(..., "Sheet", ...)` で診断表を出すのみ。**`x<=0.05` や G/L-Dの抽出ゲートは持たず**、PM（計算CHF/実測CHF）を Hsub・L/D・P・xMes で層別する診断だった。抽出（どの224行・追加138行・Table10の86行を選ぶか）は**上流のExcelマクロ(r8)で確定済み**。
- **xlsxから確認した出力シート**: `basic`, `by_table`, `by_LD`, `by_table_LD`, `F1_compare_all`, `Table8_middle`, `axis_correlations` 等（writetable呼び出しから復元）。

---

## 3. 過去に使われた抽出条件一覧

| 条件名 | 対象Table | 対象source | 条件 | 使ったrun/md | 現在の扱い | 備考 |
|---|---|---|---|---|---|---|
| 圧力スコープ分割 | T8〜14 | source01中心 | explore_low 10≤P<13 / PWR_near 13≤P≤17.5 / high_check 17.5<P≤20 MPa | pwrnear_v6〜v16c | **層別として残す**（P帯） | `classifyPressureV6`（v6 mファイル）で実装 |
| PWR近傍主解析群 | T10,11,12 | source01 | P_band==PWR_near & TableNo∈{10,11,12} | v6, v14, v15, v16c | 主解析群（source01近傍） | v14: 146点（T10=86,T11=30,T12=30） |
| source01限定ゲート | T9〜12 | source01のみ | source種類==1 に限定 | v14, v15 | **撤回気味**（全source棚卸しへ転換） | §12参照 |
| Table8除外（source03閉じ） | T8 | source03 | Table8 middleがsource03に閉じる→L/D検証点に使わない | v13 | 保留（単純なL/D検証には使わない） | source/Table/L-D/P交絡が分離不能 |
| Table9復帰（PWR下限） | T9 | source01 | 約12 MPa=explore_low下限をPWR下限チェックに復帰 | v15 | チェック群として復帰 | 「完全なPWR_near主解析群」とは断定しない |
| 旧Table10 86点 | T10 | source01 | （Excelマクロr8で確定済み・下記§4） | v14/v15/v16c, T10R02 | **legacy集合として別管理** | mファイル新規抽出ではなくアンカー照合で検出 |
| lowX入口条件 | T10（→全Table予定） | 全source | `x_report <= 0.05` | T10R02, T10R03 | **今後の共通入口候補** | T10R系で初めて実装 |
| G層別ビン | T10 | 全source | legacy 1.6–3.0 / PWR 1.77–2.95 ×10⁶lb/hr/ft² | T10R03 | **層別軸**（採用条件ではない） | `G_legacy_1p6_3p0`,`G_PWR_1p77_2p95` |
| G_SI換算 | 全 | 全source | `G_kg/m²/s = G_T&M × 1356.23` | T10R02, T10R03 | **採用**（層別軸の単位） | 実装値1356.23（依頼値1356と整合） |
| F1後 Tm>Tsat フラグ | T10 | source01 | F1適用後に Tm>Tsat となる点 | T10R01c, T10R02 | QCフラグ（自動除外しない） | noF1では0点、F1後40点（§4） |

### 3.1 抽出条件の証拠種別

確度区分: **A**=md/m/xlsxの2種以上で確認 / **B**=mファイルで直接確認 / **C**=xlsx・ファイル名から推定（m未確認）/ **D**=ログ記述のみ（実装未確認）。

| run名 | 条件の出典 | mdで確認 | mファイルで確認 | xlsxシートで確認 | 確度 | 備考 |
|---|---|---|---|---|---|---|
| T10R03 | `x_report<=0.05` 入口 | ✓(run_report §4) | ✓ `T.lowX=T.x_report<=0.05`(行136) | ✓ `all_lowX`シート(307行) | **A** | 共通入口の正本実装 |
| T10R02/03 | G_SI=G×1356.23 | ✓ | ✓ `G_kgm2s=G_1e6*1356.23` | ✓ G列 | **A** | 依頼値1356とほぼ一致 |
| T10R02 | 旧86点=アンカー検出 | ✓(run_report §3) | ✓ `anchor_from_tm_ST_like_sheets`(行59) | ✓ `legacy_selected_anchor`(86) | **A** | 抽出*再現*ではなく*照合* |
| T10R02 | F1後Tm>Tsat=40点 | ✓ | ✓ `addAuditFlags` | ✓ overlap `F1_only_Tm_gt_Tsat`(40) | **A** | noF1は0点 |
| T10R01c | noF1ではTm>Tsatなし | ✓(run_report) | ✓ | ✓ | **A** | F1適用が原因のQC |
| v14/v15 | source01 Table10-12=146/176点 | ✓(run_report QC) | ✓ `pwrnear_v6.m` P_band&Table | ✓ summary_tables.xlsx | **A** | |
| v13 | Table8=source03閉じ | ✓(run_report) | ✓(`h52q_tm8_14_source_gate_report_v13.m`) | ✓ `by_source_table.csv` | **A** | |
| v6 | P帯スコープ分割 | ✓(run_report v12+) | ✓ `classifyPressureV6` | ✓ `by_pressure_band` | **A** | v6自体はmdなしだがv12で引用 |
| diag_v1〜v11 | Excel既抽出を読むのみ | ✗(mdなし) | ✓ readtable/writetable | ✓ out_TM8_14/*.xlsx | **B** | xlsx-only初期run |
| 旧86点の*元の*選別基準 | source01・G1.8-3.0・L/D64-80 | △(後続mdで範囲を逆算) | ✗(r8マクロはフォルダ外) | △(`tm_ST`86行) | **C/D** | **元の選別ロジックは未確認** |
| Table11/12の*元の*選別基準 | L/D大の点を追加 | △(v15 run_report記述) | ✗(r8マクロ) | △ | **C/D** | 温度感は§5.2 |

---

## 4. Table10旧86点の扱い

- **検出方法（実装事実, 確度A）**: T10R02は旧86点を新規抽出していない。`scanWorkbooks` が既存ブックの「tm_ST系シート（おおむね86行）」をアンカーとして、`legacyMode = "anchor_from_tm_ST_like_sheets"` でExptNoを拾う（v4: legacy IDs used=86, anchor detected=86）。
- **元の選別基準（確度C/D）**: 元の86点選別はExcelマクロ計算ブック（r8, 本フォルダ外）で確定。MATLABからは**範囲の逆算しかできない**。T10R02の `legacy_selected_anchor` 集合の実測範囲:
  - source: **source01のみ**、flag: **none**
  - G: **1.8 – 3.0** ×10⁶lb/hr/ft²（SI換算 ≈ **2440 – 4070 kg/m²/s**）→ PWR近傍の**狭いG帯**
  - L/D: **64.52 – 80**（L=6–23.25 in, D=0.075–0.306 in）
  - x_report: **-0.457 – 0.137**（frac_x_le_005=**0.55**）→ **純粋なlowX集合ではない**
  - Hsub: 41.4 – 1197
- **F1後 Tm>Tsat で40点（確度A）**: T10R01c/T10R02により、**noF1ではTm>Tsatは0点、F1適用後だけ40点**がTm>Tsatになる。これは元データ異常ではなく、**現行F1を適用した結果生じるQCフラグ**。
- **86 − 40 = 46点の扱い**: T10R02の `legacy_F1_TmOK_or_unknown` = **46点**（Tm>Tsatでない/未確認の旧86点側）。F1固定運用では40点を除外/別管理し、46点が「F1後Tm≤Tsat」側。逆に **F1を作り直すなら40点も自動除外せず監査フラグ付きで保持**する方針（T10R01b §10, T10R02 §10）。
- **位置づけ**: 旧86点は**初期検討用の厳選集合（legacy）**。今後の共通抽出条件の正本ではない。**別管理**する。

---

## 5. Table11/12追加時の条件

- **目的（確度: run_report記述=B寄り）**: v14/v15で Table11/12 は各30点、source01、PWR_near。狙いは **L/Dの大きい（long側）点を見る**こと。v14は「Table12 long側に残る正残差」を、v15は Table9/11/12 の short–long 残差傾向を比較している。
- **旧86点と同じ厳しいG帯で選んだのか → No（確度C/D）**: 旧86点は G 1.8–3.0 の狭帯・L/D 64–80 に絞った初期厳選。一方 Table11/12 は **「long側=大L/Dを見たい」目的で後から追加**したもので、旧86点ほど厳密な抽出思想ではない（T10R01b §2 が明記）。元の選別ロジックはr8マクロ側で未確認のため確度はC/D。
- **source01として扱った根拠**: ExptNo接尾辞 `.01` が T&M Reference 1（source01）であり、Table10短管群と同系列。v13〜v15で「source種類==1」を確認済み。
- **結論（依頼の理解で良いか）**: ✅ **「Table11/12は旧86点ほど厳しいG条件で選んだわけではなく、L/Dの大きい点を見たい目的で追加した」という理解で妥当。** ただし"元の選別式"自体はExcel側にあり、MATLAB実装としては未確認（C/D）。

---

## 6. Table8/9/10/11/12の現在の扱い

| Table | source | 圧力帯 | 現在の扱い | 根拠run |
|---|---|---|---|---|
| **Table8** | source03 | explore_low (10≤P<13) | source03にほぼ閉じ、source/Table/L-D/P交絡が分離不能 → **L/D検証点として単純には使わない** | v13 |
| **Table9** | source01 | 約12 MPa（explore_low下限） | **PWR下限側のsource01チェックとして復帰**。完全なPWR_near主解析群とは断定しない | v15 |
| **Table10** | source01(+正本では07/09/11も同居) | PWR_near | 旧86点=初期検討用legacy集合。正本Markdownでは**649行のraw_all**として再整理（T10R00〜03） | T10R00–03 |
| **Table11/12** | source01 | PWR_near | **source01 PWR近傍主解析群**（long側=大L/Dを見る追加群） | v14, v15 |

補足: 「Table10」は文脈で2つを指し分ける必要がある。(a) Excel側の旧86点（source01のPWR近傍厳選）と、(b) 正本Markdown `thompson_macbeth_table10_2000psia_r1.md` の **Table10全体=649行**（source01/07/09/11が同居）。今後の棚卸しは(b)を基準にする。

---

## 7. lowX条件の整理

- **方針の出所（確度A）**: `x_report <= 0.05` を**入口条件**とする方針は **T10R02 / T10R03（2026-06-25）で初めて実装**。mファイル行: `T.lowX = T.x_report <= 0.05;`（T10R03 行136）。
  - 注意: この入口条件は**初期TM8-14（v1〜v16）には無い**。初期はPM全点を層別していた。lowX入口はTable10再監査由来の新概念。
- **報告書転記クオリティ確認（QA01, 確度A）**: 単管 Table9〜12 の**報告書転記値 `x_Mes`** を見ると、Table9/10/11/12 とも **frac_x_le_005 = 1.0**（全点 x≤0.05）。平均は -0.05〜-0.07 で**負側〜0近傍**に収まる。→ lowX入口が単管T9-12の実態と整合。
- **Table10 raw_all のlowX内訳（確度A, T10R03 QC）**:
  - all_lowX (`x_report<=0.05`) = **307点**
  - source01 lowX = **190点**
  - source09 lowX = **117点**
  - other-source lowX = **0点**
- **確認したい整理 → 妥当**: ✅ 今後の共通入口は **まず `x_report <= 0.05`**。source・G・L/D・flag では最初から切らない。これらは層別軸として扱う。

---

## 8. G条件の整理

- **過去にG条件を使った箇所**:
  - 旧86点: G **1.8–3.0** ×10⁶lb/hr/ft²（狭帯・初期厳選の結果, 確度C/D）
  - T10R03のGビン: `G_legacy_1p6_3p0`（1.6–3.0）, `G_PWR_1p77_2p95`（1.77–2.95）— ただし**採用条件ではなく層別ビン**として実装（確度A）
- **Table11/12追加時のG**: 旧86点ほど絞っていない（L/D目的の追加, §5）。
- **方針転換**: Gを「採用条件」から「**層別軸**」へ移したのは T10R03（`x_report<=0.05`のみを入口にし、Gビンは事後層別）。
- **G_SI換算（確度A）**: `G_kg/m²/s = G_T&M × 1356.23`（T10R02/03 mファイル `G_kgm2s = G_1e6 * 1356.23`）。依頼の `×1356` と整合（実装は有効桁1356.23）。
- **今後方針 → 妥当**: ✅ **GはSI（G_SI=G×1356）に換算し、G_SIを層別軸にする。Gでは最初から切らない。**

---

## 9. L/D条件の整理

- **source09が旧抽出から外れた理由はL/D<60か → ほぼYes（確度A）**:
  - 旧86点（legacy）の L/D = **64.52 – 80**（=全点 **L/D ≳ 60**）。
  - source09 の L/D = **41.28 – 59.21**（D=0.304/0.436 in, L=18 in 固定）→ **全点 L/D < 60**。
  - → 旧86点が L/D 60–80 帯に絞られていたため、**source09はL/D<60で構造的に枠外**になっていた。これが「source09が旧抽出から外れた」最有力理由。
- **source09 lowX は全点 L/D<60 か → Yes**: source09_lowX(117点)の L/D は 41.28–59.21（T10R03 §7）。
- **L/Dを採用条件から層別軸へ**: T10R03で実装済み（入口は `x<=0.05` のみ、L/Dは層別）。
- **今後方針 → 妥当**: ✅ **L/D<60のsource09も除外しない。L/Dは層別軸。**
- **今後の層別例（依頼どおりで妥当）**:

  ```text
  L/D < 60
  60 <= L/D < 100
  100 <= L/D < 200
  200 <= L/D < 300
  300 <= L/D
  ```
  参考: Table10 raw_all の L/D 実測レンジは 20.98–365.3（source01側に300超が存在: source01_lowX_notLegacy_F1_TmOK が L/D 80–365.3）。上記ビンは実データを覆う。

---

## 10. Weatherhead / source09の扱い

- **source09 = T&M Reference 9 = ANL/Weatherhead 相当（確度A）**:
  - T&M正本 Table10 の ExptNo接尾辞 `.09` が出典コード source09。実測レンジ: **D 0.304 / 0.436 in、L 18 in 固定、2000 psia、G 0.126–2.0、flag none/J/DJ、232点**。
  - 届いた `anl_1958_chf_claude.md`（ANL 1958, Type304, L=18 in, 2000 psia）は **Table I=内径0.304 in、Table II=内径0.436 in**。→ **D・L・圧力・本数の構造がsource09と完全一致**。T10R00の粗照合でも「ANL Table I 0.304 in = 232行」がsource09(232点)と一致。
  - したがって **Weatherhead ANL-6675 ≈ T&M Reference 9 ≈ source09** とみなせる（キー単位での完全照合は次runの宿題, T10R00 §8）。
- **方針 → 妥当**: ✅
  - Weatherhead全部を新規追加しない。
  - まず **T&M source09 と照合**する（D, L, G, Δh_sub, flag）。
  - T&Mに既収録（source09の232点）と一致する点は**重複追加しない**。
  - **Weatherhead-only点**（T&M source09に無い点）があれば、**別枠で採用可否を検討**。
- **注意**: 単位系を揃えること。ANL md は Δh_sub[Btu/lb]・Δh_sat,exit[Btu/lb]、T&M は Inlet Subcool[Btu/lb]・Exit Quality[lb/lb]。出口側は ANL=エンタルピ差、T&M=クオリティで、列定義変換が必要（重複判定キーは D, L, G, Δh_sub が安全）。

---

## 11. 今後のTM00共通棚卸し条件案

`TM00_all_tables_common_lowX_inventory` の仕様案（T10R03を全Table8〜14へ一般化）:

```text
入力:   T&M正本Markdown（Table8〜14。Table10は thompson_macbeth_table10_2000psia_r1.md を既に保有。
        Table8/9/11〜14の正本Markdownが未整備なら、まず正本化が前提条件）
入口条件（唯一の採用ゲート）:
        x_report <= 0.05
最初から切らない:
        source, G, L/D, flag, Table
派生列（全行に必ず付与）:
        G_SI   = G_T&M × 1356.23   [kg/m^2/s]
        D_mm   = D_in × 25.4
        L/D    = L_in / D_in
        Hsub   （正本のInlet Subcool[Btu/lb] → kJ/kg換算; ×2.326）
        qCHF_MWm2 = qCHF_1e6 × 3.15459
        source（ExptNo接尾辞 .01/.07/.09/.11 → source01/07/09/11）
        flag  （C/G/H/J/DJ をそのまま保持）
層別軸:  Table, source, G_SI（ビン: <1.6 / 1.6–3.0 / 3.0–4.0 / >4.0 ×10^6 等）,
        L/D（<60 / 60–100 / 100–200 / 200–300 / >=300）, D_mm, Hsub, flag
監査フラグ（除外しない・印だけ付ける）:
        legacy_selected_flag（旧86点アンカー一致）
        F1後 Tm>Tsat フラグ（F1固定運用時のみ別管理候補）
        flag ∈ {C,G,H}（要監査だが自動除外しない）
出力:   raw_all / all_lowX / source別 / G別 / L/D別 / flag別 summary シート + run_report md
```

### 流用できる既存スクリプトと改修点

- **最有力の土台**: `T10R03_Table10_allsource_lowX_inventory_v1.m`（入口`x<=0.05`のみ・全source棚卸し・G/L-D/flag層別・G_SI換算が既に実装済み, 確度A）。
- **改修点（TM00化）**:
  1. **入力をTable10単一からTable8〜14ループへ**: 現状 `parseTable10Md` 相当が1ファイル固定。`TableNo` ごとに正本Markdownを読み、`TableNo` 列を付けて縦結合する。
  2. **source07/11も保持**: 現状 `source01/source09` を明示分岐（行158-159, 182-183）。`source07`/`source11` も層別に含める（`x<=0.05` で自然に0件でも列は持つ）。
  3. **Hsub換算列の追加**: T10R03は `Hsub_kJkg` を持つ（×2.326想定）。全Table共通で確認。
  4. **L/Dビンの正式実装**: 現状Gビンはあるが、§9のL/Dビンを `categorical` で追加。
  5. **legacy/Tm>Tsat監査フラグの移植**: `T10R02` の `addAuditFlags`（legacyアンカー照合・F1後Tm>Tsat）を関数として取り込み、**除外ではなく印**として付ける。
  6. **Weatherhead照合フック**: source09行に対し ANL md とのキー照合列（matched_in_ANL）を追加できる差し込み口を用意（実照合はTM00後の別run）。

---

## 12. 採用・保留・撤回気味

**採用（確定的に今後も使う）**
- `x_report <= 0.05` を共通入口にする（確度A）。
- G_SI = G×1356.23 を層別軸の単位にする（確度A）。
- Table10 raw_all=649点を固定（確度A）。
- L/D・G・source・flag は層別軸（採用条件にしない）。
- source09 ≈ Weatherhead/ANL-6675。Weatherheadはまず照合対象。

**保留**
- 旧86点の*厳密な*元選別ロジック（Excel r8マクロ側・未確認, 確度C/D）。
- F1後 Tm>Tsat 40点を最終的に切るか残すか（F1を固定するか作り直すかに依存）。
- Table8/9/11〜14 の正本Markdown整備（Table10以外はMarkdown正本が未確認）。
- Table12 long側の正残差の物理解釈（L/D vs P/xMes/qM）。

**撤回気味（過去に採用したが今は引っ込めた条件）**
- **source01限定ゲート**: v14/v15では「source種類==1」に絞っていたが、T10R03で**全source棚卸しへ転換**。→ source01限定は撤回気味。
- **狭いG帯(1.8–3.0)での採用ゲート**: 旧86点ではG帯で実質的に絞っていたが、今後はGで切らず層別軸化。→ 採用条件としては撤回。
- **L/D 60–80 への暗黙の限定**: 旧86点はL/D 64–80に収まっていた（=source09をL/D<60で締め出していた）。今後はL/D<60も残す。→ 撤回。
- **qMを説明変数に使うこと**: v15で「qMは結果側の量、補正式入力に使わない（DIAG_ONLY）」と明記済み。→ 補正式入力としては不採用（診断専用）。

---

## 13. 未確認事項

1. 旧86点・Table11/12の**元の選別式そのもの**（Excel r8マクロ内。本MATLABフォルダ外で実装未確認、確度C/D）。
2. **Table8/9/11/12/13/14 の正本Markdown**の有無（Table10のみ `thompson_macbeth_..._r1.md` を確認。他Tableは正本MD未確認。TM00を「正本MarkdownからのlowX棚卸し」とするなら、まず各Tableの正本化が前提）。
3. Weatherheadとsource09の**キー単位の完全照合**（D, L, G, Δh_sub）。今回は構造一致までで、行単位の重複/欠落リストは未作成（T10R00 §8の宿題）。
4. Hsub換算係数（Btu/lb→kJ/kg, ×2.326想定）と qCHF係数（×3.15459）の**全Table一貫適用**の確認。
5. source07（4点, flag C, x>0.05でlowX外）とsource11（25点, L/D≈174, x>0.05）の**棚卸し上の扱い**（lowX入口では0件になるが、層別表には残すか）。
6. F1後Tm>Tsat 40点と「46点」の対応関係の確定（F1運用方針が決まってから）。

---

## 14. TM00作成時の注意点（誤判定回避）

- **旧86点の条件 ≠ T&M全体の正本条件**。旧86点はsource01・G1.8-3.0・L/D64-80の初期厳選legacy。これをTM00共通条件に流用しない（**別管理**, `legacy_selected_flag`で印だけ付ける）。
- **Table10だけの条件をTable11/12へ機械適用しない**。Table11/12は「大L/Dを見る」緩い追加群。旧86点と同じG/L-Dではない。
- **WeatherheadをT&M source09と重複照合せずに追加しない**。まずD/L/G/Δh_subで照合し、既収録は重複追加しない。Weatherhead-only点だけ別枠検討。
- **G・L/Dで最初から強く切らない**。入口は `x_report<=0.05` のみ。G・L/Dは層別軸。
- **mdがない初期runを「未実施」と誤判定しない**。v1〜v11はxlsx-only。run_reportはv12から。
- **後期run_reportの条件＝過去全体の条件、と誤解しない**。source01限定やG帯ゲートは過去の局面的判断であり、現在は撤回気味。
- **抽出条件の確定はmファイル実装を優先**。Excel既抽出（旧86点・Table8-14ステージング）は確度C/Dとして扱い、範囲は逆算値であることを明示する。
- **この段階でF1再fitやL/D補正式作成へ進まない**。TM00は棚卸し（inventory）まで。採用点決定・PM計算・補正式は監査レポート承認後。

---

## 最終的に確認したい判断（妥当性チェック結果）

| 判断 | 妥当性 | 根拠 |
|---|---|---|
| 共通入口は まず `x_report<=0.05` のみ | ✅ 妥当 | T10R03実装(確度A)、QA01で単管T9-12が全点x≤0.05 |
| source/G/L-D/flag で最初から切らない | ✅ 妥当 | T10R03は入口lowXのみ、他は層別軸 |
| GはSI換算(G_SI=G×1356)し層別軸に | ✅ 妥当 | mファイル `×1356.23`(確度A) |
| L/Dも層別軸、L/D<60のsource09も除外しない | ✅ 妥当 | source09はL/D41-59で旧抽出から構造的に外れていた |
| 旧86点は初期検討用legacyとして別管理 | ✅ 妥当 | アンカー検出86点、x_le_005=0.55で純lowXでない |
| WeatherheadはまずT&M source09と重複照合、only点は別枠 | ✅ 妥当 | source09≈ANL Table I/II(D0.304/0.436,L18,2000psia)構造一致 |

**総括**: 暫定方針（§1）は本監査の証拠と整合し、妥当である。実装上の唯一の前提整備は「Table8/9/11〜14の正本Markdown化」と「旧選別ロジックがExcel側にあり確度C/Dである点の明示」である。TM00の土台には `T10R03_Table10_allsource_lowX_inventory_v1.m` を全Table対応へ一般化するのが最短。
