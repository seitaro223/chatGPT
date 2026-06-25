# H52Q / T&M Table8〜14 正本Markdown有無の確認

作成日: 2026-06-25
目的: TM00（`TM00_all_tables_common_lowX_inventory`）実装の前に、Table8/9/11〜14について Table10正本Markdownと同等に使えるファイルがあるかを確認する。
結論: **Table10以外（Table8/9/11/12/13/14）の正本Markdownは存在しない。→ TM00実装には進まず、不足ファイル一覧を出す。**

---

## 1. 判定結果（サマリ）

| Table | 正本Markdown | ファイル | 状態 |
|---|---|---|---|
| **Table10** | ✅ あり | `thompson_macbeth_table10_2000psia_r1.md` | 使用可（649行, source01/07/09/11） |
| Table8 | ❌ なし | — | Excelに"middle"部分集合のみ（§3） |
| Table9 | ❌ なし | — | Excel raw のみ（1750 psia） |
| Table11 | ❌ なし | — | Excel raw のみ（OCR, 2250 psia） |
| Table12 | ❌ なし | — | Excel 選別済み30点のみ |
| Table13 | ❌ なし | — | どこにも実質なし（2点のみ） |
| Table14 | ❌ なし | — | Excel 選別済み30点のみ |

探索方法: プロジェクト全体を再帰探索（`*.md` 全62本、`*thompson* / *macbeth* / *table8|9|11|12|13|14*` 全拡張子、`EXPT NO + DIA` 形式の正本表ヘッダ grep）。
T&M正本表形式（`| EXPT NO | DIA | LENGTH | G | Inlet Subcool | Burnout HF | Exit Quality | flag |`）を持つMarkdownは **`thompson_macbeth_table10_2000psia_r1.md` ただ1本**（T10R01c run_reportが同データを引用しているのみ）。`anl_1958_chf_claude.md` はWeatherhead/ANL（source09照合用）であり、T&M正本表ではない。

---

## 2. あるファイル（Table10のみ）— 一覧

| 項目 | 内容 |
|---|---|
| Table番号 | Table10 |
| ファイル名 | `thompson_macbeth_table10_2000psia_r1.md` |
| 行数 | データ649行（ファイル656行） |
| source種類 | source01 / source07 / source09 / source11（ExptNo接尾辞 `.01/.07/.09/.11` = T&M Reference番号） |
| 主要列 | `EXPT NO, DIA(in), LENGTH(in), G ×10⁶ lb/hr/ft², Inlet Subcool(Btu/lb), Burnout HF ×10⁶ Btu/hr/ft², Exit Quality(lb/lb), flag(C/G/H/J/DJ)` |
| 圧力 | 全行 2000 psia 固定 |
| 単位系 | 米国慣用単位（in, ×10⁶ lb/hr/ft², Btu/lb） |

→ これがTM00の「正本Markdown標準」。他Tableはこの粒度・列定義・検証水準に達していない。

---

## 3. ないファイルの現状（データの所在＝Excelのみ・正本Markdown級ではない）

Table8/9/11〜14の生データは **Excelワークブック内にしか存在せず**、いずれもTable10正本Markdownと同等には使えない。

### 3.1 `ThompsonMacbeth_TM8_9_11_14_G1000_macrohandoff_TinFilled.xlsx`（OCR/画像読取り段階）

| シート | 内容 | 行数 | 注意 |
|---|---|---|---|
| `10_raw_TM` | Table11(/14)系 raw | ~100 | `OCR_Check` 列に「Image-read」= **PDF画像からの読取り**、未検証 |
| `52_raw_T9_all` | Table9 raw | ~62 | 圧力 **1750 psia**（2000ではない） |
| `50_raw_T8_mid` | **Table8 "middle"のみ** | ~16 | Table8全体ではなく中間L/D帯の部分集合 |
| `90_ALL_RAW_UNIFIED` | TM_Table11_14 統合 raw | ~180 | `case_id`= `1.01_11` 形式（Table10の `.09` 方式と**不統一**） |

- 列名: `SourcePaper, TableNo, PDFPage, ReportPage, ExptNo, Flag, Pressure_psia, Dia_in, Length_in, MassVelocity_1e6, InletSubcool_Btu, BurnoutFlux_1e6, ExitQuality, OCR_Check`
- ファイル名が示すとおり対象は **Table 8/9/11/14** であり、**Table12・Table13のraw統合は含まれていない。**

### 3.2 `20260612_計算結果比較r8_staging_TM8_14_v1.xlsx`（選別済み・計算用ステージング）

- シート `SRC_tm_r123_noF1_T8_14` / `SRC_tm_r124_F1_T8_14`: 各 **224行**。No_TableNo の Table別内訳:

  | Table | 10 | 9 | 11 | 12 | 14 | 8 | 13 |
  |---|---|---|---|---|---|---|---|
  | 行数 | 86 | 30 | 30 | 30 | 30 | 16 | 2 |

- これは**raw全表ではなく、既にExcelマクロ側で選別・物性付与された部分集合**（Table10=旧86点と一致）。列は物性計算用（`No_TableNo, P, Ts, rhoG, rhoL, HG, HL, ...`）で、正本表の生計測列とは別物。
- → 「Table8〜14のデータは存在するが、それは選別後・計算用であり、正本Markdownの代替にはならない」。

---

## 4. 不足ファイル一覧（TM00前に整備が必要）

Table10と同水準の正本Markdownとして、以下が**不足**:

| 必要ファイル（案） | 対象 | 現状の最良ソース | ギャップ |
|---|---|---|---|
| `thompson_macbeth_table8_*psia_r1.md` | Table8 全体 | `50_raw_T8_mid`(16点, middleのみ, OCR) | **全体が無い**。middle部分集合のみ |
| `thompson_macbeth_table9_1750psia_r1.md` | Table9 | `52_raw_T9_all`(~62点, OCR) | 正本MD未整備。圧力1750 |
| `thompson_macbeth_table11_2250psia_r1.md` | Table11 | `10_raw_TM`/`90_ALL_RAW_UNIFIED`(OCR) | 正本MD未整備。圧力2250 |
| `thompson_macbeth_table12_*psia_r1.md` | Table12 | staging選別30点のみ | **raw統合が無い** |
| `thompson_macbeth_table13_*psia_r1.md` | Table13 | 全データで2点のみ | **実質データ欠落** |
| `thompson_macbeth_table14_*psia_r1.md` | Table14 | staging選別30点/`90_ALL`一部 | raw統合の正本MD未整備 |

---

## 5. TM00実装に進めない理由（明示）

1. **正本Markdownが Table10 にしか無い。** TM00は「T&M全テーブル正本MarkdownからのlowX棚卸し」を前提とするため、入力の5/6が欠落している。
2. Excel側のrawは **OCR/画像読取り段階で未検証**（`OCR_Check`=Image-read）。Table10 md の検証水準と揃わない。
3. **Table8はmiddle部分集合のみ、Table13は実質欠落**。全表横断の母集合が作れない。
4. **source列・キー命名が不統一**（Table10= `.01/.07/.09/.11` のReference接尾辞、TM8_9_11_14= `_11` 等のTableタグ）。同一source定義で比較できない。
5. **圧力が表ごとに異なる**（T9=1750, T10=2000, T11=2250 psia）。`Pressure` 列を必須にし、2000 psia固定の前提は使えない。

---

## 6. 次アクション提案（TM00の前に）

- **優先**: Table9/11/12/14 の正本Markdown化（Table10 md と同じ列・単位・flag・ExptNo接尾辞source方式で起こす）。元PDF/報告書ページは Excel に記録あり（`PDFPage/ReportPage` 列, 例: T9=p58-59, T11=p81/74）。
- Table8 は middle以外の全L/D帯を補完してから正本化（部分集合のままTM00に入れない）。
- Table13 は元データ自体を確認（2点しか無いなら、TM00対象から外すか別扱いを明記）。
- 全表で **source定義を Table10方式（Reference接尾辞）に統一**してからTM00へ。
- 正本Markdownが揃うまで、`T10R03` の TM00一般化（前監査§11）には着手しない。

**結論: 正本MarkdownはTable10のみ存在。Table8/9/11/12/13/14は不足。TM00実装は保留し、本不足一覧の整備を先行する。**
