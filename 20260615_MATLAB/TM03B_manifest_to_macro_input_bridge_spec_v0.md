# TM03B Manifest → Macro Input Bridge Spec (v0)

前提run: TM03A（マクロ入力インターフェース監査）。本v0はTM03Aの確定事項に基づく**仕様ドラフト**。
目的: TM02 `new_calc_manifest` の280点を、既存Excel VBAマクロブック（`celataモデル_..._r123_F1なし_Table8-14計算済み.xlsm`）の `tm` シートへ安全に投入し、マクロで新規計算する。

---

## 1. TM03Bでやること
1. MATLABで `new_calc_manifest`（280行）を読み、**マクロ投入用テーブル**を生成する。
   - 列は `tm` の入力列に一致（A,B,M,N,Q,R,T,BE,BH,BR）＋固定定数列（V,BG,BI,BJ,BK,BQ）。
   - 単位はすべてSIへ変換（§5）。
2. **Tin(K)を算出**して T列に入れる（manifestはHsubのみ。§5/§11）。
3. 既存xlsmを**コピー**して新ブックを作り、`tm` テーブル `テーブル2` へ280行を投入（既存xlsmは上書き禁止）。
4. `Module6` の主マクロ `AdjustSValue_BinarySearch_15_Fast_SaveEachRow_LogSheet_Final` を実行（開始行〜終了行指定）。
5. 収束後、出力列と `Log` を回収して結果ブック/CSVに保存。

## 2. TM03Bでまだやらないこと
- VBA計算ロジックのMATLAB移植（案C）。
- PM診断、F1再fit、L/D補正式の作成。
- legacy 176点との差分解釈、Table10 new_only 143点の影響分析（計算後の別run）。
- 数式・UDF・Solver設定の改変。

## 3. MATLABから作るべき入力ブック/CSVの仕様
- 形式: `tm` の**列名・列順に一致**したテーブル（推奨xlsx 1シート、または UTF-8 CSV）。
- 行: 280行（manifest順、または TableNo→ExptNo順）。
- 必須列（値を入れる）:

| tm列 | header | 値 | 単位 |
| --- | --- | --- | --- |
| A | No_TableNo | `ExptNo & "_" & TableNo` 例 `1.01_9` | 文字列 |
| B | P | `Pressure_MPa*1e6` | Pa |
| M | No | 連番 1..280 | int |
| N | G | `G_SI_kg_m2s` | kg/m²/s |
| Q | DH | `D_mm/1000` | m |
| R | L_DNB | `L_mm/1000` | m |
| T | Tin | IF97算出（§5） | K |
| BE | q_M | `qCHF_MW_m2*1e6` | W/m² |
| BH | x_Mes | `x_report` | – |
| BR | L | `L_mm/1000`（=R） | m |

- 固定定数列（全行同値）: V=0.03, BG=1, BI=0.046, BJ=5625, BK=1, BQ=1。
- 反復未知数の初期値（任意。マクロが上書きする）: S=q_M, X=0.01, AC=600, AG=0.00001, AP=1。
- **数式列は出力しない**（C–L物性, O/A, P/Pw, U,W,Y,Z,AA,AB,AD–AO以外の数式, AQ–BA, BC, BD, BL, BM, BN, BO, BP）。テーブル自動展開に任せる。

## 4. マクロブックへ投入すべき列
- §3の「必須列」＋「固定定数列」のみ。
- **アンカー注意**: 投入行で `BC(dq_chf)` 列が数式で埋まること（`End(xlUp)` の最終行検出に使われる）。テーブルへ行追加すれば自動で数式が入る。

## 5. 変換すべき単位
```
P_Pa   = Pressure_MPa * 1e6           # manifest W
G      = G_SI_kg_m2s                  # manifest Y（変換なし）
DH_m   = D_mm / 1000                  # manifest J
L_m    = L_mm / 1000                  # manifest X  → R と BR
q_M_W  = qCHF_MW_m2 * 1e6             # manifest Z
x_Mes  = x_report                     # manifest I（変換なし）
# Tin（manifestに値なし。算出が必要）：
h_f_sat = h_f(P)                      # 飽和液エンタルピ
h_in    = h_f_sat - Hsub_kJ_kg*1000   # [J/kg]
Tin_K   = T_IF97_Region1(P, h_in)     # ← 実装/ライブラリ要決定（§11）
```
- 原単位列（psia/in/lb-hr-ft²/BTU）は照合専用。投入はSI列を使う（単位混在回避）。

## 6. 触ってはいけない列（LEGACY / 改変禁止）
- 固定モデル定数: V(f(beta)=0.03), BG(F_form=1=F1なし), BI(A_corr=0.046), BJ(σ_corr=5625), BK(Fcorr=1), BQ(F2=1) … 値を**変えない**（既存と同値で複製）。
- UDF/数式/Solver設定/`SatProp`・`Cp_T*`物性表 … 一切改変しない。
- 既存 `tm` 2〜225行のlegacy/handoffデータ … 上書きしない（新ブックで作業）。

## 7. 数式コピーが必要な範囲
- 原則**不要**。`tm` はListObject `テーブル2`（A1:BR225）。行を追加すると数式列（C–L, O, P, 残差, q_P 等）は**全行自動充填**される。
- もしテーブル外に貼る運用にする場合のみ、数式列を投入行数ぶん手動フィルする必要がある（非推奨）。

## 8. マクロ実行が必要そうか
- **必須。** 反復未知数 X(f)/AC(Tw)/AG(y_star)/AP(UB) はSolver、S(q_in)は二分探索で決まる。貼って再計算だけでは予測CHFは出ない。
- 実行マクロ: `Module6.AdjustSValue_BinarySearch_15_Fast_SaveEachRow_LogSheet_Final`（`frmRowInput`で開始/終了行を指定）。
- 依存: **Excel Solverアドインが有効**であること（COM自動化時は参照設定が必要）。
- 性能: Solver4段 × 最大80反復 × 280行 → **長時間**。Table別/管径別の分割実行を検討。50行ごとに自動保存される。

## 9. 出力回収すべき列
| 列 | header | 意味 |
| --- | --- | --- |
| S | q_in | 収束した予測CHF [W/m²]（外側二分探索の解） |
| BB | q_P | モデル予測熱流束 [W/m²] |
| BF | PM_ratio | q_P / q_M（**主指標**） |
| BM | q_P_MW | 予測CHF [MW/m²] |
| BC,BD | dq_chf, dq_ratio | 収束残差（診断） |
| (X,AC,AG,AP) | f,Tw,y_star,UB | 収束した内部状態（診断・再現用） |
| `Log`シート | 反復履歴 | 収束/失敗の監視 |

## 10. 人間確認後に確定すべき点
- **Tin算出法**（IF97 vs 表補間）と過去 `Tin_K_IF97` への一致基準 ← 最優先。
- 投入先（新ブックの新tm / 追記 / tm入替え）。
- 一括 vs 分割実行。
- F1なし(BG=1)・固定定数の踏襲可否。
- No_TableNo命名規約（`ExptNo_TableNo`）。
- 収束許容(TOL=1%)・初期値の踏襲可否。

---

## 11. 投入方式の選択肢（TM03A最終提案）

### 案A: MATLABで入力CSV/xlsxを作り、人間がマクロブックに貼る
- **長所**: 実装が軽い。過去の `120_MACRO_INPUT_FINAL` と同じ運用で実績あり。Excel/Solverを人が直接操作でき、収束監視・例外対応が容易。MATLABはExcel COM不要。
- **短所**: 貼付け＋マクロ実行が手作業。再現性は手順書頼み。
- **適性**: 「まず1回、280点を確実に計算したい」段階に最適。**推奨の出発点。**

### 案B: MATLABからExcel COMでマクロブックへ自動投入＋マクロ実行
- **長所**: 完全自動・再現可能。投入→`Application.Run`でマクロ起動→出力回収まで一気通貫。
- **短所**: Windows＋Excel＋SolverアドインのCOM参照が必要。`actxserver('Excel.Application')` でSolver参照を有効化する手当てが要る。エラー処理（Solver未収束、COM例外）が重い。本環境(Linux)では実行不可、ユーザ側Windowsで実行前提。
- **適性**: 案Aで手順を固めた後、280点を繰り返し回す段階で移行。

### 案C: VBA計算ロジックをMATLABへ全面移植
- **現時点では非推奨（重すぎる）。** Solver4段の非線形求解＋二分探索＋IF97/UDF/物性補間をすべて再実装し、既存マクロと数値一致を検証する必要がある。TM03の目的（入力IF固定）を超える。将来の独立課題。

### 提案
**案Aで開始し、手順が固まり次第 案B へ移行**する二段構え。理由:
1. 既に `120_MACRO_INPUT_FINAL` 運用の実績があり、案Aは最小リスクで280点を計算可能。
2. 最大の不確実性は投入機構ではなく **Tin算出（§5/§11）**。まず案Aで数点を試算し、過去 `Tin_K_IF97` と一致するか・収束するかを確認するのが先。
3. それが確認できれば、同じ入力テーブル生成ロジックを案Bへ載せ替えるだけで自動化できる。
