# TM03B3 Robust Runner Prep

作成日: 2026-06-25 23:57 (UTC)
担当run: TM03B3 / TM03C-Prep（本番分割実行前の robust 版 VBA 運用整備）

---

## 1. 目的
280点分割実行（TM03C）へ進む前に、TM03B2 の robust bracket 探索を**本番運用に耐える形**へ整備する。今回は280点を実行しない。整備項目:
- TM03B2 の robust bracket 探索を維持
- Excel 設定の cleanup を確実化（エラー終了時も復帰）
- 行ごとの summary 出力
- 行単位 fail-and-continue（1点失敗で全体停止しない）
- 行ごとに OK / FAIL / 要確認を機械判定
- B1b の12点を robust 版で再実行する準備

**厳守**: 元xlsm 上書きしない／既存 Module6 は消さない／内側 Solver・数式列・UDF・固定定数・物理式は不変／F1再fit・F(x_eq)化・L/D補正なし／280点一括はまだしない。

## 2. 入力ファイル
| 役割 | ファイル | 状態 |
| --- | --- | --- |
| TM03B2 robust VBA | `TM03B2_Module6B_robust_bracket.bas` | あり（ベース） |
| B1b 投入済み xlsm | `TM03B1b_macro_newonly_trial_20260625_235759.xlsm` | あり |
| B1b 候補点 | `TM03B1b_newonly_candidate_points_20260625_235759.xlsx` | あり |
| B1b 結果サマリ枠 | `TM03B1b_newonly_result_summary_20260625_235759.xlsx` | あり |
| TM03B2 レポート | `run_report_TM03B2_outer_bracket_robust_20260625_235759.md` | あり |
| 元xlsm（F1なし） | `celataモデル_..._r123_F1なし_Table8-14計算済み.xlsm` | 読み取りのみ・未改変 |
| preview（投入値の源） | `tm_input_preview_20260625_083115.xlsx` | あり |
| B1a run_done（control 実測参照） | `TM03B1a_macro_reinject_validation_20260625_083115_run_done.xlsm` | あり（流用） |

**該当ファイル不明（未配置）**:
- `TM03B2_macro_bracket_test_20260625_235759_run_done.xlsm` … 不明（B2の259/249/9.01_10 の実測数値は未取得。robust版OKはユーザ報告に基づく）。
- `TM03B1b_macro_newonly_trial_20260625_235759_run_done.xlsm` … 不明（B1b 12点の実測数値は未取得）。
- `20260615_H52Q_working_log_r58.md` … 不明（`r55`,`r57` のみ存在。参照用、処理に影響なし）。
> 代替の別ファイルは使用していない。

## 3. TM03B2 から引き継ぐロジック（不変）
- q_low/q_high の bracket 確認
- q_high の 1.5倍段階拡張
- `Q_HIGH_INIT = 1.2e7`、`Q_HIGH_MAX = 6.0e7`、`EXPAND_FACTOR = 1.5`、`EXPAND_LIMIT = 20`
- 非物理ガード（q_P≤0 / PM_ratio≤0 / y_star≤0）
- `FAIL_BRACKET_HIGH` / `FAIL_NONPHYSICAL`
- BRACKET / BISECT / SUMMARY の Log
- 内側 Solver（f→Tw→y_star→UB を各 balance=0）、数式、UDF、固定定数は不変。`TOL_PCT=1`、`ITER_LIMIT=80`。

## 4. 追加した運用整備（TM03B3）
新モジュール **`Module6C_TM03B3`** / メイン Sub **`AdjustSValue_RobustRunner_TM03B3`**（旧 `Module6`・`Module6B_TM03B2` と名前衝突なし）。

| 機能 | 内容 |
| --- | --- |
| Excel cleanup | 開始時に ScreenUpdating/EnableEvents/DisplayAlerts/Calculation/DisplayStatusBar を**保存**、`On Error GoTo CleanFail` で**どこで落ちても復帰** |
| fail-and-continue | `ProcessRowSafe` が行内で例外を捕捉し status を返す。1点失敗でも次行へ。致命時のみ全体停止（CleanFail） |
| status 機械判定 | OK / FAIL_BRACKET_HIGH / FAIL_BRACKET_LOW / FAIL_NONPHYSICAL / FAIL_SOLVER / FAIL_FORMULA / FAIL_RUNTIME / SKIPPED |
| summary シート | `TM03_run_summary` を get-or-create（あればクリア再作成）、1行1レコード |
| Log モード | `LOG_DETAIL=True` / `LOG_SUMMARY_ONLY=False`（将来 summary のみへ切替可能な設計） |
| 保存頻度 | `SAVE_EVERY_N_ROWS=10`（定数化のみ。最適化は今回しない） |
| 進捗表示 | `Application.StatusBar` に行/総数・OK/FAIL 件数 |

## 5. cleanup 設計
```
sv_* = Application.<各設定>           ' 保存
On Error GoTo CleanFail
Application.<各設定> = 実行用
...本体...
RestoreApp(sv_*)                      ' 正常終了
Exit Sub
CleanFail:
  RestoreApp(sv_*)                    ' 致命エラーでも必ず復帰
  MsgBox 致命的エラー
```
`RestoreApp` は `On Error Resume Next` で Calculation/DisplayAlerts/EnableEvents/ScreenUpdating/DisplayStatusBar を戻し、`StatusBar=False`。行単位の例外は `ProcessRowSafe` 内 `On Error GoTo RowFail` で吸収するため、本体ループは原則 CleanFail に飛ばない（summary 書込み等の致命のみ）。

## 6. summary 出力設計（`TM03_run_summary`）
固定31列（存在しない値は空欄、列名は固定）:
`RunID, Timestamp, RowNo, No_TableNo, TableNo, ExptNo, Status, q_M_MWm2, q_in_final_MWm2, q_P_final_MWm2, PM_ratio, dq_ratio_pct, q_low_final_MWm2, q_high_final_MWm2, n_expand, n_bisect, solver_max_code, f_final, Tw_final, y_star_final, UB_final, Tsub, x_Mes, P_MPa, G, DH_mm, L_DNB_m, F_form, Fcorr, error_message, elapsed_sec`
- `TableNo`/`ExptNo` は `No_TableNo`（=`ExptNo_TableNo`）を `InStrRev(_,"_")` で分割。
- 熱流束系は MW/m² 換算（W は /1e6）。エラー番兵は空欄化。
- 列リストは成果物 `TM03B3_robust_runner_trial_points_*.xlsx` の `summary_expected_columns` と一致。

## 7. failure status 設計
| status | 条件 |
| --- | --- |
| OK | 物理点で収束（|dq_ratio%|<1）、非物理でない |
| FAIL_BRACKET_HIGH | Q_HIGH_MAX まで拡張しても too_high にできない |
| FAIL_BRACKET_LOW | q_low(1e5) で既に too_high（root が下限未満。想定外） |
| FAIL_NONPHYSICAL | 収束しても q_P≤0 / PM≤0 / y_star≤0 |
| FAIL_SOLVER | 内側 Solver が例外（code≥900） |
| FAIL_FORMULA | q_P/delta/y_star/PM セルが #VALUE!/#NUM! |
| FAIL_RUNTIME | VBA 実行時例外、または反復上限内に未収束 |
| SKIPPED | No_TableNo 空行 |
各行 `error_message` に理由、`solver_max_code` に内側 Solver の最大結果コードを残す。

## 8. B1b 12点 再実行試験の準備
- 元xlsm から**新規コピー** `TM03B3_macro_robust_runner_trial_20260625_235759.xlsm` を作成（B1b run_done へは追記・改造しない）。
- B1b と同じ12点を **226〜237行** に preview 由来値で投入済み（既存 tm 行のコピーではない）。table `テーブル2` を `A1:BR237` に拡張。VBA 33モジュール・Module6 健在。
- 投入12点（行）:

| 行 | No_TableNo | 役割 | B1b旧 | B2 robust期待 |
| --- | --- | --- | --- | --- |
| 226 | 39.01_10 | 低Tsub(5.3K) | OK | OK |
| 227 | 27.01_10 | 高Tsub(313K) | OK | OK |
| 228 | 81.01_10 | x≈+0.05 | OK | OK |
| 229 | 259.01_10 | x最負/高G | **FAIL** | **OK** |
| 230 | 1.01_10 | 小径 | OK | OK |
| 231 | 442.01_10 | 大径/低G | OK | OK |
| 232 | 150.01_10 | 低G/低qM | OK | OK |
| 233 | 289.01_10 | 高G(10565) | OK | OK |
| 234 | 249.01_10 | 高qM(14.76MW) | **FAIL** | **OK** |
| 235 | 281.01_10 | Flag=G | OK | OK |
| 236 | 40.01_10 | Flag=G/低Tsub | OK | OK |
| 237 | 9.01_10 | **control** | OK | OK (B1a実測 PM=1.0209, q_in=4.113MW) |

> ⚠ Linux 環境では `vbaProject.bin` に新 VBA を書き込めないため、**この xlsm は旧 Module6 のまま**。`Module6C_TM03B3` は含まれない（`present? = False` 確認済み）。**要 `.bas` インポート**。

## 9. Windows 実行手順
1. `TM03B3_macro_robust_runner_trial_20260625_235759.xlsm` を開く。
2. マクロと Solver アドインを有効化（SOLVER.XLAM 参照）。
3. VBE → ファイル → **`TM03B3_Module6C_robust_runner.bas` をインポート**。
4. マクロ **`AdjustSValue_RobustRunner_TM03B3`** を実行。
5. `frmRowInput` に **開始行=226 / 終了行=237**。
6. 実行後、**`TM03_run_summary`**（12行）と `Log`（BRACKET/BISECT/SUMMARY）を確認。`TM03B3_robust_runner_trial_points_*.xlsx` の `result_template` を埋める。
7. **別名保存**: `TM03B3_macro_robust_runner_trial_20260625_235759_run_done.xlsm`。
8. （任意）旧 `Module6` で同 226–237 を実行し挙動差を確認。

## 10. 合格基準
- 12点すべてでマクロが途中停止しない。
- `TM03_run_summary` に **12行**出る。
- 12点すべてで q_in / q_P / PM_ratio が**有限値**。
- 12点すべてで dq_ratio が概ね **±1%以内**。
- **259.01_10 と 249.01_10 が OK** になる（旧 FAIL→OK）。
- **control 9.01_10** が B1a/B2 同程度（PM≈1.021, q_in≈4.11MW）に戻る。
- 失敗行があっても Status と error_message が残る。
> PM の良し悪しはまだ主目的でない。robust runner として成立しているかを見る。

## 11. 280点分割実行へ進む条件
TM03B3 の12点試験が上記合格基準を満たし、**`TM03_run_summary` が機能**していれば TM03C へ:
- **TM03C-1**: Table10 new-only 143点を分割（50+50+43）。
- **TM03C-2**: overlap・Table9/11/12 を実行。
- **TM03C-3**: main280 統合し noF1 PM を回収。
> summary 出力が機能しない場合は TM03C へ進まない。

## 12. 採用・保留・未確定
**採用（確定）**
- robust runner `Module6C_TM03B3`（`.bas`）作成。TM03B2 ロジック維持＋cleanup＋fail-continue＋summary＋status＋Logモード＋保存頻度。
- B1b 12点を新規コピーへ投入（226–237、preview由来、元xlsm未改変）。
- control 9.01_10 の cross-run 基準値を B1a run_done から取得（PM=1.0209, q_in=4.113MW）。

**保留**
- 12点 robust 実行の実測（Windows 実行待ち、`<PENDING>`）。
- 速度改善（保存頻度・LOG_SUMMARY_ONLY 切替）は TM03C 直前に検討。

**未確定（人間確認待ち）**
- B1b/B2 run_done 不在のため、旧/修正の数値比較は control(9.01_10) 以外 PENDING。
- `Q_HIGH_MAX`/`EXPAND_FACTOR` の実運用妥当性（summary の n_expand で確認）。

---

## 付録: 成果物
- `TM03B3_Module6C_robust_runner.bas` … 本番前整備版 VBA（インポート用）。
- `TM03B3_macro_robust_runner_trial_20260625_235759.xlsm` … 12点(226–237)投入済み（**要 .bas インポート**、元xlsm未改変）。
- `TM03B3_robust_runner_trial_points_20260625_235759.xlsx` … `trial_points`/`input_values`/`expected_from_B1b_old`/`expected_from_B2_fixed`/`result_template`/`summary_expected_columns`。
- `run_report_TM03B3_robust_runner_prep_20260625_235759.md` … 本レポート。

### 優先順位（再掲）
1. 安全に止まる → 2. Excel設定を必ず戻す → 3. 失敗行を明示 → 4. summaryを出す → 5. B1b 12点を robust 版で通す → 6. その後で速度改善。
