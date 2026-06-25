# TM03A Macro Input Interface Audit

作成日: 2026-06-25 08:31 (UTC)
担当run: TM03A（監査のみ。計算・改変・上書きは一切していない）

---

## 1. 目的

T&M Table9〜12の主解析入口 `source01_lowX_9_12 = 280点`（TM02で全点 `TO_BE_NEWLY_CALCULATED` としてパッケージ化済み）を、**既存のExcel VBAマクロブックで新規計算する**ための入力インターフェースを固定する。

本runの方針:

- VBA計算エンジンは残す（MATLABへ移植しない）。
- 新データの手貼り作業をなくし、MATLABからマクロブックへ入力できる形にする。
- **TM03Aは監査のみ。** xlsmは開いて読むだけで、上書き・編集保存・数式置換・VBA改変・実計算はしていない。F1再fit / PM診断 / L/D補正式作成も行っていない。

---

## 2. 入力ファイル

| 役割 | ファイル名 | 状態 |
| --- | --- | --- |
| マクロブック（計算エンジン） | `celataモデル_簡易計算_単管_櫻井検算r123_F1なし_Table8-14計算済み.xlsm` | 存在・読み取りのみ |
| 新規計算280点パッケージ | `TM02_main280_new_calculation_package_20260625_170657.xlsx` | 存在 |
| TM02 runレポート | `run_report_TM02_main280_new_calculation_package_20260625_170657.md` | 存在 |
| 作業ログ | `20260615_H52Q_working_log_r55.md` | 存在（537KB、参照のみ） |
| （参考）過去のマクロ入力ブリッジ元 | `ThompsonMacbeth_TM8_9_11_14_G1000_macrohandoff_TinFilled.xlsx` | 存在。**重要な手掛かり**（後述） |

すべて作業フォルダ `20260615_MATLAB/` に存在し、ファイル名は完全一致した。**該当ファイル不明の項目はなし。**

---

## 3. マクロブック構造

xlsmは **7シート**。すべて `visible`（非表示シートなし）。

| # | シート名 | 状態 | 行数 | 列数 | 役割分類 |
| --- | --- | --- | --- | --- | --- |
| 1 | `SatProp` | visible | 50 | 14 | **物性表**（圧力→飽和物性、SI単位） |
| 2 | `Cp_T_low` | visible | 337 | 5 | 物性表（低圧 Cp(T)） |
| 3 | `Cp_T_mid` | visible | 337 | 5 | 物性表（中圧 Cp(T)） |
| 4 | `Cp_T_high` | visible | 337 | 5 | 物性表（高圧 Cp(T)） |
| 5 | **`tm`** | visible | 225 | 70 | **主計算シート（確認済み）** |
| 6 | `Log` | visible | 2567 | 8 | マクロ反復ログ（出力・検算） |
| 7 | `TM_import_log` | visible | 20 | 2 | 過去のデータ取込み記録（監査の宝） |

- **主計算シートが `tm` であることを確認した。** Excelテーブル `テーブル2`（ListObject, ref `A1:BR225`）が `tm` 上にあり、全数式が構造化参照 `テーブル2[[#This Row],[列名]]` で書かれている。
- 名前定義（Defined Names）は2つだけで、両方とも壊れている: `L_tot -> #REF!`、`半径方向の出力 -> #REF!`。**実計算には未使用。** 入力インターフェース設計で考慮不要。
- 物性表シート候補 = `SatProp`, `Cp_T_low/mid/high`。出力・検算シート候補 = `Log`（反復履歴）。入力補助シート候補 = `TM_import_log`（取込みメタ記録）。

### 3.1 TM_import_log（過去のブリッジ実績 — 最重要）

`TM_import_log` に、過去（2026-06-12）に行われたデータ取込みの記録が残っていた。これが**入力インターフェースの実物の証拠**である。

| 項目 | 内容 |
| --- | --- |
| 入力元ブック | `ThompsonMacbeth_TM8_9_11_14_G1000_macrohandoff_TinFilled.xlsx` |
| 入力元シート | `120_MACRO_INPUT_FINAL` |
| 入力先シート | `tm` |
| 追記範囲 | 88〜225行（138行） |
| 内訳 | Table8:16, Table9:30, Table11:30, Table12:30, Table13:2, Table14:30 |
| 既存行(2〜87) | 上書きなし |
| **マクロ実行** | **実行していない（データ追記のみ。自動計算による更新のみ）** |
| 初期値の注記 | `q_in/f/Tw/y_star/UB は初期値。q_in=q_M と同値、f/Tw/y_star/UBは直上行(87行)の値をコピー` |

**結論:** 過去にもMATLAB/Python側で `120_MACRO_INPUT_FINAL` という入力シートを作り、それを `tm` に貼る運用が行われていた。ただし**そのときはマクロ未実行**で、貼った後の自動再計算だけだった（＝q_Pは正しい収束値になっていない）。TM03Bはこの運用を「自動投入 ＋ マクロ実行」まで完成させる作業に相当する。

---

## 4. 主計算シート `tm` の確認

- **ヘッダー行: 1行目**（70列、A=No_TableNo 〜 BR=L）。
- **データ開始行: 2行目。**
- **既存データ終了行: 225行**（= テーブル2の終端。実データ224点）。
  - 2〜87行: 元の櫻井検算データ（legacy）。
  - 88〜225行: 6/12にhandoffから取込んだTable8/9/11/12/13/14。
  - **Table10は現在 `tm` に存在しない**（新規280点の190点がTable10 → 大半が新規投入になる）。
- 代表行の数式・値は §5/CSVに収録。代表行(2行目)はP=13789520 Pa(=2000psia), G=2440.8, DH=0.001905 m, q_P=4.13e6 W/m2, PM_ratio=1.024。

### 4.1 計算エンジンの正体（VBAから判明）

`tm` は単なる数式シートではなく、**1行ごとに反復求解する求解器**である。VBA `Module6` の主マクロ
`AdjustSValue_BinarySearch_15_Fast_SaveEachRow_LogSheet_Final` が中核で、行範囲を `frmRowInput` フォームで指定して実行する。各行で:

1. 初期値を書込む: `f=0.01, y_star=0.00001, UB=1, Tw=600`。
2. **Excel Solver（GRG非線形）を4段**呼び出し、残差列をゼロにする（`Module2/Module6`）:
   - Solver1: `AA (f_balance) = 0` を `X (f)` で求解
   - Solver2: `AF (Tw_balance) = 0` を `AC (Tw)` で求解
   - Solver3: `AN (y_star_balance) = 0` を `AG (y_star)` で求解
   - Solver4: `AY (UB_balance) = 0` を `AP (UB)` で求解
3. その上で**外側の二分探索／可変ステップ探索**で `S (q_in)` を動かし、`q_P (BB) ≈ q_in (S)`（判定値 |100·(q_P−q_in)/q_in| < 1%）に収束させる。
4. 収束した `q_in` がモデル予測CHF。`Log`シートに反復履歴を記録。

物性列(C〜L)はワークシート配列数式から**VBA UDF**（`TsatFromP`等, `Module4`）を呼び、`SatProp` を圧力で線形補間する。`AE(Tm)=gettm2`, `AM=gettyp`, `AT=getublp`（`Module1`）も同様にUDF。

→ **したがって「入力を貼って通常再計算」だけでは正しい結果にならない。** Solver4段＋二分探索という**マクロ実行が必須**（詳細は§8）。

---

## 5. 入力列・数式列・出力列の分類

70列を6分類した（全列は同梱CSV `TM03A_macro_input_column_map_20260625_083115.csv` 参照）。要点のみ:

### A. EXTERNAL_INPUT_FROM_MANIFEST（manifestから投入すべき入力列）
| 列 | header | manifest候補 | 単位変換 |
| --- | --- | --- | --- |
| A | No_TableNo | ExptNo + '_' + TableNo | id文字列 |
| B | P | W Pressure_MPa | ×1e6 → Pa |
| M | No | （連番1..280） | なし |
| N | G | Y G_SI_kg_m2s | なし（既SI） |
| Q | DH | J D_mm | ÷1000 → m |
| R | L_DNB | X L_mm | ÷1000 → m |
| **T** | **Tin** | **H Hsub_kJ_kg (+P)** | **IF97でTin算出（manifestに直接値なし）** |
| BE | q_M | Z qCHF_MW_m2 | ×1e6 → W/m2 |
| BH | x_Mes | I x_report | なし |
| BR | L | X L_mm | ÷1000 → m（R と重複） |

### B. FORMULA_DERIVED（Excel数式で自動計算。投入も数式コピーも不要、テーブルが自動展開）
C,D,E,F,G,H,I,J,K,L（物性, UDF）, **O(A)=PI()·Q²/4**, **P(Pw)=PI()·Q**, U,W,Y,Z,AA,AB,AD,AE,AF,AH,AI,AJ,AK,AL,AM,AN,AO,AQ,AR,AS,AT,AU,AV,AW,AX,AY,AZ,BA,BC,BD,BL,BN,BO,BP。
> 重要: **流路面積A(O)・ぬれぶちPw(P)はDH(Q)から数式で自動算出**されるので投入不要。残差列 AA/AF/AN/AY は数式だがSolverのターゲット。

### C. VBA_DERIVED_OR_UPDATED（マクロが書き換える反復未知数）
- X (f), AC (Tw), AG (y_star), AP (UB) … Solver の ByChange 変数（初期値だけ与える）
- S (q_in) … 外側二分探索が更新（初期値=q_M）。**収束後は予測CHFそのもの＝出力でもある。**

### D. OUTPUT_TO_COLLECT（回収すべき出力列）
- **BB (q_P)** 予測CHF [W/m2]、**S (q_in)** 収束予測CHF、**BF (PM_ratio)=q_P/q_M**（主指標）、**BM (q_P_MW)**。
- 補助: BC (dq_chf), BD (dq_ratio %)、`Log` シートの反復履歴。

### E. LEGACY_DO_NOT_TOUCH（固定モデル定数。manifest由来ではない。既存値を複製するだけ）
- V (f(beta)=0.03), BG (F_form=1 … 本ブックは「F1なし」), BI (A_corr=0.046), BJ (σ_corr=5625), BK (Fcorr=1), BQ (F2=1)。

### F. UNKNOWN_HUMAN_CHECK（人間確認が必要）
- **T (Tin)**: manifestにTin値がない。後述§7/§11。
- BR (L): R(L_DNB)との重複。両方同値でよいか確認。
- V/BG/BI/BJ/BK/BQ の定数を新規280点でもそのまま使ってよいか（特にBG=1=F1なしの前提）。

---

## 6. TM02 new_calc_manifest との列対応

`new_calc_manifest`（280行 × 37列）には**原単位とSI単位の両方**が入っており、ブリッジに必要な値はほぼ揃っている。要求された最低限の対応:

| 要求項目 | manifest列 | → tm列 | 変換 | 確度 |
| --- | --- | --- | --- | --- |
| TableNo | B TableNo | (A に連結) | — | 高 |
| ExptNo | C ExptNo | (A に連結) | — | 高 |
| Pressure | F Pressure_psia / **W Pressure_MPa** | B (P, Pa) | MPa×1e6（または psia×6894.757） | 高 |
| Mass velocity | Q G_1e6_lb_hr_ft2 / **Y G_SI_kg_m2s** | N (G) | 既SIをそのまま | 高 |
| Tube diameter | O D_in / **J D_mm** | Q (DH, m) | mm÷1000（または in×0.0254） | 高 |
| Heated length | P L_in / **X L_mm** | R (L_DNB) & BR (L) | mm÷1000 | 高 |
| L/D | G L_over_D | （tmに専用列なし。R/Q比で再現） | — | 中 |
| Inlet subcooling / Hsub | **H Hsub_kJ_kg** | → T (Tin) を算出 | IF97で h_in=hf(P)−Hsub → Tin | **低** |
| Burnout heat flux / q_M | S qCHF_1e6_BTU_hr_ft2 / **Z qCHF_MW_m2** | BE (q_M, W/m2) | MW×1e6 | 高 |
| Exit quality / x_report | **I x_report** | BH (x_Mes) | なし | 高 |
| Flag | E flag_norm / AB flag_is_none | （取込み対象判定用、tmに列なし） | — | 中 |
| Source | D source / AC source_code | （同上） | — | 中 |

### 6.1 単位の整合（混在の確認結果）
- **manifestはSI列(W/X/Y/Z/H)を持つため、ブリッジはSI列だけ使えば単位混在を避けられる。** 原単位列(psia/in/lb/hr/ft2/BTU)は照合用。
- マクロ内部は**完全SI**（§7）。SatProp も P=Pa, T=K, ρ=kg/m³, h=J/kg, μ=Pa·s, k=W/mK, cp=J/kgK, σ=N/m。
- 唯一の単位スケール注意: manifest H/Z は **kJ/kg・MW/m²**。tm は **J/kg相当の温度系・W/m²**。q は ×1e6、Hsub は kJ/kg のまま IF97 へ。

---

## 7. 単位変換が必要な列（まとめ）

| tm列 | manifest源 | 変換式 |
| --- | --- | --- |
| B (P) | Pressure_MPa | `P_Pa = MPa * 1e6` |
| Q (DH) | D_mm | `DH_m = mm / 1000` |
| R (L_DNB), BR (L) | L_mm | `L_m = mm / 1000` |
| BE (q_M) | qCHF_MW_m2 | `q_W = MW * 1e6` |
| N (G) | G_SI_kg_m2s | 変換なし（既SI） |
| BH (x_Mes) | x_report | 変換なし |
| **T (Tin)** | Hsub_kJ_kg + Pressure | `h_in = h_f,sat(P) − Hsub; Tin = T_IF97_Region1(P, h_in)`（**要ライブラリ判断**） |

物性表は圧力(Pa)入力前提なので、**B(P)を正しくPaにすればC〜L物性は自動で正しくなる**。

---

## 8. VBAまたは数式依存の確認

| 質問 | 回答 |
| --- | --- |
| 入力列を差し替えれば下流数式列は再計算されるか | **部分的にYES。** 物性(C〜L)・A/Pw・残差等の**数式列はExcel自動再計算で更新される**。ただし反復未知数(X,AC,AG,AP)と q_in(S) は数式ではないため更新されない。 |
| 数式列を280点分コピーすればよいか | **テーブル `テーブル2` なので原則不要。** ListObjectの行を増やすと数式列は自動で全行に充填される。手作業の数式コピーは基本不要。 |
| マクロ実行が必要な列はあるか | **YES（必須）。** X(f),AC(Tw),AG(y_star),AP(UB) は Solver、S(q_in) は二分探索で求まる。マクロを走らせないと q_P/PM_ratio は意味を持たない（過去取込みも「マクロ未実行」のまま放置されていた）。 |
| 通常再計算だけで更新される列か | 物性・A・Pw・U・W・残差・Tsub 等の数式列のみ。**核心の予測CHFは更新されない。** |
| 入力行数が変わると壊れる参照はあるか | 低リスク。マクロは `FindHeaderCol`（ヘッダ名で列特定）＋ `Cells(Rows.Count, COL_dq_chf).End(xlUp)`（dq_chf列で最終行検出）で動的。テーブルも自動リサイズ。**ただし `BC(dq_chf)` 列がアンカーなので、この列が全投入行で非空(数式)である必要がある。** |

### VBAコード抽出結果
- **VBAは完全抽出できた**（oletools/VBA_Parser）。主要モジュール:
  - `Module1`: UDF `gettyp / getublp / gettm / gettm2`（Martinelli温度分布・Karman速度分布）。
  - `Module4`: 物性UDF `TsatFromP/RhoFFromP/RhoGFromP/HfFromP/HgFromP/MuFFromP/MuGFromP/KfFromP/CpFFromP/SigmaFromP/CpFromT/CpFromTP` + `SatProp`/`Cp_T*` を線形補間する内部関数。
  - `Module2`/`Module6`: Solver4段の呼び出し（`SolverReset/SolverOk/SolverSolve`, GRG Nonlinear）。
  - `Module6`: 主マクロ（二分探索＋各行保存＋Logシート）、`frmRowInput`（開始/終了行入力フォーム）。
  - `Module5`: `FindHeaderCol`、`Module7`: `CalcWholeRow / InitLogSheet / AppendLogRow`。
  - `Module3`: 収束グラフ作成（解析には不要）。
- **シート名・列の参照方法**: マクロは `ws_tm`（=シート`tm`）固定、列は**ヘッダ名検索**（`f, Tw, y_star, UB, q_in, delta, q_P, dq_chf, f_balance, Tw_balance, y_star_balance, UB_balance`）。Range/Cellsは行番号 `r` と取得列で動的指定。**ハードコードされた絶対セルや固定行数依存は見当たらない**（Solver の SetCell/ByChange も `Cells(r, COL).Address` で生成）。
- **依存外部アドイン: Excel Solver アドイン**（`SolverReset` 等）。これが有効でないとマクロは動かない（COM自動化でも要参照設定）。

---

## 9. 280点投入時のリスク

1. **マクロ実行が前提（最大リスク）。** 貼っただけでは未計算。Solver4段×280行×二分探索（最大80反復/行）は**処理時間が長い**（Module6は50行ごとに自動保存）。1行あたり複数秒 → 280行で数十分〜規模。
2. **Tin(T列)がmanifestに無い。** Hsub→Tin変換(IF97)の実装と、過去 `Tin_K_IF97` との一致確認が必要。ここを誤ると Tsub→Tf→反復全体がずれる。
3. **Table10が190点と新規。** 7種の管径が混在（D_mm = 1.905〜7.7724）。A/Pw はDHから自動だが、**DHを正しく投入できているかの検算が重要**。
4. **既存xlsmへの追記か、新ブックか。** 既存tmは224行のlegacy/handoffが入っている。280点は別ブック（xlsmコピー）に入れて計算するのが安全（指示「既存xlsmを上書きしない」と整合）。
5. **アンカー列 `dq_chf(BC)` の連続性。** 投入行で数式が途切れると `End(xlUp)` の最終行検出が狂う。テーブル自動展開で担保されるが要確認。
6. **初期値依存の収束。** Solver/二分探索は初期値（f=0.01,Tw=600,…）依存。一部の極端な点（Table10低L/D=20.98やx≈0.05付近）で収束失敗の可能性 → Logで要監視。
7. **固定定数の前提（BG=1=F1なし）。** 本ブックはF1なし版。280点もF1なしで計算する前提か要確認。

---

## 10. 推奨する TM03B 方針

`TM03B_manifest_to_macro_input_bridge_spec_v0.md`（同梱）に詳細。骨子:

1. MATLABで manifest 280点 → **マクロ入力テーブル（CSVまたはxlsx）** を生成（SI、`tm`の列順・列名に一致させる）。
2. Tin は IF97 で算出して投入列に含める（過去handoffの `Tin_K_IF97` を再現・照合）。
3. xlsmは**コピーして**新ブックを作り、そこの `tm` テーブルへ280行を投入（既存は上書きしない）。
4. **`Module6` の主マクロを実行**（開始行〜終了行を指定）してSolver＋二分探索を回す。
5. 収束後、`q_in(S)/q_P(BB)/PM_ratio(BF)/q_P_MW(BM)` ＋ `Log` を回収。

**進め方は案A（手貼り）と案B（COM自動投入）を中心に評価**（§最後）。案C（VBA→MATLAB全面移植）は現時点では重すぎる。

---

## 11. 人間確認が必要な点

1. **Tin算出方法（最重要）。** Hsub→Tin を IF97 Region1 で出すか、SatProp/Cp表ベースで出すか。過去 `Tin_K_IF97`（IF97使用）に合わせるべきか。MATLABのIF97/XSteam実装の有無。
2. **投入先**: 既存xlsmのコピーに新tmを作るか、tmの225行以降に追記するか、tmを空にして280行だけにするか。
3. **行範囲/実行単位**: 280行を一括でマクロ実行するか、Table別/管径別に分割するか（収束監視のため）。
4. **F1なし前提（BG=1）の確認。** 280点もF1なしで計算してよいか。
5. **固定定数** V=0.03, A_corr=0.046, σ_corr=5625, Fcorr=1, F2=1 を新規点でも踏襲してよいか。
6. **No_TableNo の命名規約**（`ExptNo_TableNo`）を280点でどう振るか（manifest key `T9_1.01` 形式との対応）。
7. **収束許容・初期値**（TOL=1%, f=0.01/Tw=600/...）を280点でも使うか。

---

## 12. 採用・保留・未確定

### 採用（この監査で確定したこと）
- 主計算シート = `tm`（テーブル `テーブル2`, A1:BR225）。ヘッダ1行、データ2行目開始。
- マクロブックは**完全SI**。物性はSatProp/Cp表をUDFで圧力(Pa)・温度(K)補間。
- manifestから投入する入力列は **A,B,M,N,Q,R,T,BE,BH,BR**（10列）。うち実質の物理入力は **B(P),N(G),Q(DH),R(L),T(Tin),BE(q_M),BH(x)**。
- A(面積)・Pw・物性・残差等は**数式自動計算**（投入不要、テーブルが自動展開）。
- 予測CHFは **Solver4段＋二分探索のマクロ実行が必須**（`Module6`）。出力は S/BB/BF/BM ＋ Log。
- VBAは全抽出済み。固定セル依存なし・ヘッダ名検索で行数変化に強い。

### 保留
- 投入を案A（手貼り）にするか案B（COM自動）にするか。
- 既存tmへの追記か新ブックか。
- 一括実行か分割実行か。

### 未確定（人間確認待ち）
- **Tin算出法（IF97 vs 表補間）と過去値との一致基準。** ← 最優先。
- F1なし(BG=1)・固定定数の踏襲可否。
- No_TableNo命名規約。

---

## 付録: 同梱成果物
- `TM03A_macro_input_column_map_20260625_083115.csv` … 全70列の分類・manifest対応・単位変換・代表値。
- `TM03B_manifest_to_macro_input_bridge_spec_v0.md` … 次作業の仕様書（v0）。
