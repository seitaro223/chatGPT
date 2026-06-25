# TM03B0 — tm 投入用 Preview 入力表（Tin = IF97復元）

作成日: 2026-06-25 08:31 (UTC)
担当run: TM03B0（preview生成のみ）

---

## 1. 目的

TM02 `new_calc_manifest`（280点 = Table9-12 × source01 × x_report≤0.05）を、既存マクロブックの `tm` シートへ投入するための **preview入力表** を作成する。
Tinはmanifestにないため、**IAPWS-IF97 Region 1** で `Hsub_kJ_kg` と `Pressure` から復元する。

**本runで行わないこと（厳守）:**
- xlsm への投入をしない（preview出力のみ）。
- マクロ実行をしない。
- VBA・数式・物性表の改変、PM/F1/L-D補正計算はしない。

---

## 2. 入出力ファイル

| 役割 | ファイル |
| --- | --- |
| 入力 manifest | `TM02_main280_new_calculation_package_20260625_170657.xlsx`（`new_calc_manifest`, 280行） |
| Tin QA参照（過去handoff） | `ThompsonMacbeth_TM8_9_11_14_G1000_macrohandoff_TinFilled.xlsx`（`120_MACRO_INPUT_FINAL`, `122_IF97_TIN_LOG`） |
| 出力 preview (xlsx) | `tm_input_preview_20260625_083115.xlsx` |
| 出力 preview (csv) | `tm_input_preview_20260625_083115.csv` |
| 本レポート | `run_report_TM03B0_tm_input_preview_20260625_083115.md` |

`tm_input_preview_*.xlsx` の3シート: `tm_input_preview`（280行）／`QA_Tin_vs_handoff`（90行）／`QA_flags`（0行）。

---

## 3. 列対応（manifest → preview列 → tm目標列）

preview表は「貼りやすさ」より「監査しやすさ」を優先したtidy表。各列は接頭辞で投入先を明示:
- `tmX_…` = tmの入力列（値を投入）
- `seed_tmX_…` = 反復未知数の初期値（マクロが上書き）
- `const_tmX_…` = 固定モデル定数（全行同値）
- `QA_…` = 検算用中間量　`prov_…` = 出所確認

| preview列 | tm目標列 | manifest源 | 変換 |
| --- | --- | --- | --- |
| `tmA_No_TableNo` | A No_TableNo | ExptNo, TableNo | `ExptNo & "_" & TableNo`（例 `1.01_9`） |
| `tmB_P_Pa` | B P | Pressure_MPa | ×1e6 |
| `row_No_M` | M No | （連番） | 1..280 |
| `tmN_G_kg_m2s` | N G | G_SI_kg_m2s | なし |
| `tmQ_DH_m` | Q DH | D_mm | ÷1000 |
| `tmR_L_DNB_m` | R L_DNB | L_mm | ÷1000 |
| `tmBR_L_m` | BR L | L_mm | ÷1000（=R） |
| `tmT_Tin_K` | T Tin | Hsub_kJ_kg + Pressure | **IF97（§5）** |
| `tmBE_qM_W_m2` | BE q_M | qCHF_MW_m2 | ×1e6 |
| `tmBH_x_Mes` | BH x_Mes | x_report | なし |
| `seed_tmS_q_in_W_m2` | S q_in | （=q_M） | 初期値。マクロ二分探索が上書き |
| `seed_tmX_f` | X f | — | 0.01（マクロが上書き） |
| `seed_tmAC_Tw` | AC Tw | — | 600（マクロが上書き） |
| `seed_tmAG_y_star` | AG y_star | — | 1e-5（マクロが上書き） |
| `seed_tmAP_UB` | AP UB | — | 1（マクロが上書き） |
| `const_tmV_fbeta` | V f(beta) | — | 0.03 |
| `const_tmBG_Fform` | BG F_form | — | 1（F1なし） |
| `const_tmBI_Acorr` | BI A_corr | — | 0.046 |
| `const_tmBJ_sigcorr` | BJ σ_corr | — | 5625 |
| `const_tmBK_Fcorr` | BK Fcorr | — | 1 |
| `const_tmBQ_F2` | BQ F2 | — | 1 |

> 数式列（C–L物性, O=A, P=Pw, U,W,…,BB=q_P, BF=PM_ratio 等）は preview に含めない。tmのテーブル `テーブル2` が行追加時に自動充填するため（TM03A §7・§8）。

---

## 4. 単位変換（適用済み）

```
P_Pa  = Pressure_MPa * 1e6
G     = G_SI_kg_m2s              (変換なし; 既SI)
DH_m  = D_mm / 1000
L_m   = L_mm / 1000              -> tmR(L_DNB) と tmBR(L)
q_M_W = qCHF_MW_m2 * 1e6
x_Mes = x_report                 (変換なし)
```
原単位列（psia / in / 1e6 lb-hr-ft² / 1e6 BTU-hr-ft² / BTU-lb）はmanifest側にあるが、preview投入はSI列のみ使用（単位混在回避）。参考: 過去handoffの換算係数は psia→MPa 0.006894757, in→m 0.0254, q 3.15459, Hsub 2.326（`01_UNIT_CONVERSION`）。

---

## 5. Tin計算（IAPWS-IF97 Region 1）

過去handoffの `00_README` / `122_IF97_TIN_LOG` に従い、**hSubはエンタルピー差**として扱う:

```
sat   = IAPWS97(P=Pressure_MPa, x=0)      # 飽和液
Tsat  = sat.T            [K]
hf    = sat.h            [kJ/kg]           # 飽和液エンタルピ
h_in  = hf - Hsub_kJ_kg  [kJ/kg]           # 入口エンタルピ
Tin   = IAPWS97(P=Pressure_MPa, h=h_in).T  [K]   # Region 1 逆算
```
- ライブラリ: Python `iapws` 1.5.5（IAPWS-IF97）。圧力MPa・エンタルピkJ/kg・温度K。
- 中間量 `QA_Tsat_K_IF97 / QA_hf_sat_kJ_kg / QA_h_in_kJ_kg / QA_Tsub_K` を preview に保持。

---

## 6. Tin計算 QA

### 6.1 過去handoffとの一致（90点が重複: Table9/11/12 各30）
| 指標 | 値 |
| --- | --- |
| 重複点数 | 90 / 280（Table9:30, Table11:30, Table12:30。Table10の190点はhandoffに無く新規） |
| `|ΔTin|` 最大 | **0.0304 K** |
| `|ΔTin|` 平均 | **0.0092 K** |
| `|ΔHsub|` 最大 | **0.000 kJ/kg**（manifestとhandoffのHsub完全一致） |

最大差の点（すべてTable12の極大サブクール側, Tin≈296–299 K, h_in≈100 kJ/kg, 三重点近傍でIF97が最も非線形）:

| key | Tin_mine [K] | Tin_handoff [K] | ΔTin [K] |
| --- | --- | --- | --- |
| T12_22.01 | 296.62838 | 296.59801 | +0.0304 |
| T12_29.01 | 296.62838 | 296.59801 | +0.0304 |
| T12_25.01 | 297.75333 | 297.72296 | +0.0304 |
| T12_26.01 | 298.31579 | 298.28542 | +0.0304 |

> 解釈: 直接参照値（`122_IF97_TIN_LOG`記載の高精度値）との照合では一致は ~1e-11 K（同一IF97定式）。`120_MACRO_INPUT_FINAL` 保存値との残差0.03 Kは、過去パイプラインの中間値丸めに起因する極小差で、Tsub（数十〜数百K）に対して無視できる。**TinのIF97復元は再現性ありと判断。**

### 6.2 物理サニティ（280点全数）
| チェック | 結果 |
| --- | --- |
| `QA_flags` 行数（異常） | **0**（Tin≥Tsat / Tin<273.15 / 非Region1 / Tsub≤0 の該当なし） |
| 全点サブクール（Tsub>0） | **YES**, Tsub_min = 5.26 K（Table10のx_report≈0.05最小サブクール点） |
| h_in 最小 | 100.02 kJ/kg（三重点側でも正） |
| Tin レンジ | 294.31 〜 603.36 K |
| IF97 region | 全点 Region 1（圧縮液） |

### 6.3 テーブル別サマリ
| Tbl | N | Tsat [K] | Tin_min | Tin_max | Tsub_min | Tsub_max |
| --- | --- | --- | --- | --- | --- | --- |
| 9 | 30 | 598.25 | 294.31 | 535.48 | 62.77 | 303.94 |
| 10 | 190 | 608.62 | 295.44 | 603.36 | 5.26 | 313.19 |
| 11 | 30 | 618.01 | 297.04 | 548.63 | 69.38 | 320.97 |
| 12 | 30 | 626.58 | 296.63 | 554.39 | 72.19 | 329.95 |

各テーブルは単一圧力（9:1750, 10:2000, 11:2250, 12:2500 psia）なのでTsatは一定。Table10は管径・L/D・サブクール幅が広く、Tsubが5〜313 Kと最も分散。

---

## 7. 注意・人間確認が必要な点

1. **TsatはどのIF97を正とするか。** preview Tinはiapws IF97を使用。一方マクロ内部の Ts（C列）は `SatProp` 表をUDFで補間する別ソース。Tin（IF97）と Ts（SatProp）が混在すると `BL Tsub = Ts − Tin` に微小不整合が出る可能性。投入前に `SatProp` 由来 Tsat と IF97 Tsat の差を確認するのが望ましい（過去handoffも IF97 Tin を値貼りしており、同じ運用なら整合）。
2. **極大サブクール点（Table9/11/12のTin≈296–300 K, h_in≈100 kJ/kg）** は物理的に妥当だが長L/D・極大サブクール単管データであり、CHF高クオリティ改善の主データではない（handoff README注記と一致）。
3. **Table10の190点はhandoff未収録 → QA外部参照なし。** §6.2のサニティのみで担保。必要なら数点をPDF原典/別ルートで抜き取り検算。
4. seed初期値（S=q_M, f=0.01, Tw=600, y_star=1e-5, UB=1）と固定定数（V=0.03, BG=1, BI=0.046, BJ=5625, BK=1, BQ=1）の踏襲可否は TM03A §11 の通り未確定。

---

## 8. 採用・保留・未確定

**採用（確定）**
- 280点すべてに preview入力値を生成（欠損なし）。
- Tin = IF97 Region 1 で復元。handoff重複90点と最大0.03 K一致、Hsub完全一致。
- 全点サブクール・全点Region 1・異常フラグ0。

**保留**
- 投入先（既存xlsmコピーの新tm / 追記 / 入替え）。
- 一括 vs テーブル別・管径別の分割実行。

**未確定（人間確認待ち）**
- SatProp Tsat と IF97 Tsat の整合（Tsub定義の一貫性）。
- seed/固定定数の踏襲可否、No_TableNo命名規約。

---

## 9. 次工程（TM03B本体）
preview確定後、(1) xlsmをコピー → (2) `tm`テーブルへ投入 → (3) `Module6` 主マクロ実行（Solver4段＋二分探索）→ (4) `S/BB/BF/BM`＋`Log`回収。投入方式は案A（手貼り）開始→案B（COM自動）移行を推奨（TM03B spec v0）。
