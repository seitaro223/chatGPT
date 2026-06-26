# TM03B3a Err 429 回避版 robust runner 作成レポート

## 1. Err 429 の想定原因

Windows Excel で `frmRowInput` 表示後、`TM03_run_summary` 作成前または初期化中に `Err 429: ActiveX コンポーネントはオブジェクトを作成できません。` が発生したため、VBA 内の ActiveX/COM 生成、特に `CreateObject(...)` 系が第一候補と考えました。

ただし今回確認した `TM03B3_Module6C_robust_runner.bas` には `CreateObject(...)`、`Scripting.Dictionary`、`FileSystemObject`、`VBScript.RegExp`、`WScript.Shell` はありませんでした。そのため、直接原因は `.bas` 内の `CreateObject` ではなく、フォーム・参照設定・環境依存の COM/ActiveX 初期化、または workbook 側の別モジュール/フォーム初期化である可能性があります。

## 2. CreateObject 依存の有無

検索対象:

- `TM03B3_Module6C_robust_runner.bas`
- 参考: `TM03B2_Module6B_robust_bracket.bas`

検索語:

- `CreateObject(`
- `Scripting.Dictionary`
- `FileSystemObject`
- `RegExp`
- `WScript`
- `Shell`
- `Dictionary`
- `Collection`
- `New`

結果:

- `CreateObject(...)`: 該当なし
- `Scripting.Dictionary`: 該当なし
- `FileSystemObject`: 該当なし
- `RegExp`: 該当なし
- `WScript`: 該当なし
- `Shell`: 該当なし
- `Dictionary`: 該当なし
- `Collection`: 該当なし
- `New`: 該当なし
- `frmRowInput`: TM03B3 / TM03B2 既存版にあり

該当したフォーム依存箇所:

| ファイル | 行 | 内容 |
|---|---:|---|
| `TM03B3_Module6C_robust_runner.bas` | 103 | `frmRowInput.Show vbModal` |
| `TM03B3_Module6C_robust_runner.bas` | 104 | `frmRowInput.txtStartRow.Value` / `txtEndRow.Value` の数値確認 |
| `TM03B3_Module6C_robust_runner.bas` | 107-108 | フォーム入力から `startRow` / `endRow` を取得 |
| `TM03B2_Module6B_robust_bracket.bas` | 67 | `frmRowInput.Show vbModal` |
| `TM03B2_Module6B_robust_bracket.bas` | 68 | `frmRowInput.txtStartRow.Value` / `txtEndRow.Value` の数値確認 |
| `TM03B2_Module6B_robust_bracket.bas` | 71-72 | フォーム入力から `startRow` / `endRow` を取得 |

## 3. 削除・置換した CreateObject 依存

既存 TM03B3 `.bas` には `CreateObject` 依存が存在しなかったため、削除対象はありません。

TM03B3a では、Err 429 を誘発し得る環境依存要素を避けるため、以下を徹底しました。

- `CreateObject(...)` は未使用。
- `Scripting.Dictionary` は未使用。
- `FileSystemObject` は未使用。
- `VBScript.RegExp` は未使用。
- `WScript.Shell` は未使用。
- header 管理は既存の `FindHeaderCol` と単純な列変数を継続使用。
- summary / debug trace シートは `ThisWorkbook.Worksheets` と `Worksheets.Add` のみで作成。

## 4. frmRowInput を使わない NoForm 版

新規ファイルを作成しました。

- `TM03B3a_Module6C_noactivex_noform_debug.bas`
- モジュール名: `Module6C_TM03B3a`
- メイン Sub: `AdjustSValue_RobustRunner_TM03B3a_NoForm`

NoForm 固定実行のため、行範囲はコード内定数にしました。

```vba
Private Const START_ROW As Long = 226
Private Const END_ROW   As Long = 237
```

`frmRowInput.Show` は主実行 Sub では使用しません。B1b 12点のみを対象にします。

## 5. lastStep / currentRow デバッグ

`gLastStep` と `gCurrentRow` を追加し、致命的エラー時の MsgBox に以下を表示するようにしました。

- `Err.Number`
- `Err.Description`
- `lastStep`
- `currentRow`

追加した marker:

- `STEP 01: macro entered`
- `STEP 02: workbook/sheets resolved`
- `STEP 03: columns resolved`
- `STEP 04: app settings saved`
- `STEP 05: app settings changed`
- `STEP 06: before EnsureSummarySheet`
- `STEP 07: after EnsureSummarySheet`
- `STEP 08: before InitDetailLog`
- `STEP 09: after InitDetailLog`
- `STEP 10: before row loop`
- `STEP 11: before ProcessRowSafe`
- `STEP 12: after ProcessRowSafe`
- `STEP 13: before SolverReset`
- `STEP 14: after SolverSolve`
- `STEP 15: before RestoreApp`
- `STEP 16: normal end`

可能な場合は `TM03_debug_trace` シートにも逐次書きます。ただし debug trace 作成前に落ちても MsgBox の `lastStep/currentRow` で切り分けできるようにしています。

## 6. summary 作成の純 VBA 化

`TM03_run_summary` の作成・初期化は、以下のみで実装しています。

- `ThisWorkbook.Worksheets`
- `ThisWorkbook.Worksheets.Add`
- `Cells`
- `Rows`

ActiveX/COM 生成は使っていません。

また、summary の末尾列に `lastStep` を追加し、行単位 FAIL 時にも直近 step が残るようにしました。

## 7. 内側 Solver・数式・UDF・固定定数・物理式は不変

TM03B3a では以下を変更していません。

- 内側 Solver の `SolverReset` / `SolverOk` / `SolverOptions` / `SolverSolve` の構成
- `CalcWholeRow` 呼び出し
- 数式列
- UDF
- 固定定数
- 物理式
- robust bracket 探索の基本ロジック
- F1 再 fit、F(x_eq) 化、L/D 補正式作成は未実施

変更点は、NoForm 固定行範囲、ActiveX/COM 非依存化、summary/debug trace の純 VBA 作成、lastStep/currentRow デバッグ追加、Excel 設定復帰の維持です。

## 8. Windows 実行手順

1. `TM03B3_macro_robust_runner_trial_20260625_235759.xlsm` を開く。
2. マクロと Solver を有効化する。
3. VBE で `TM03B3a_Module6C_noactivex_noform_debug.bas` をインポートする。
4. `AdjustSValue_RobustRunner_TM03B3a_NoForm` を実行する。
5. 開始行・終了行はコード内で 226〜237 固定。
6. 実行後、`TM03_run_summary` が header + 12 data rows になるか確認する。
7. `Log` と `TM03_debug_trace` を確認する。
8. 実行済み workbook を別名保存する。

推奨保存名:

```text
TM03B3a_macro_robust_runner_trial_20260625_235759_run_done.xlsm
```

## 9. 合格基準

- Err 429 が出ない。
- `TM03_run_summary` が作成される。
- `TM03_run_summary` に 12 行出る。
- 12点すべてが途中停止せず処理される。
- `259.01_10` と `249.01_10` が OK になる。
- `9.01_10 control` が PM≈1.021、q_in≈4.11 MW/m2 付近に戻る。
- FAIL があっても、`Status`、`error_message`、`lastStep` が残る。
- Excel 設定が実行後に復帰する。

## 10. 次に TM03C へ進める条件

TM03C へ進む前に、Windows Excel 側で B1b 12点の TM03B3a 試験を完了し、以下を確認してください。

1. Err 429 が再発しない。
2. `TM03_run_summary` に 12 data rows がある。
3. `TM03_debug_trace` で `STEP 16: normal end` まで到達している。
4. 重要点 `259.01_10` / `249.01_10` が OK。
5. `9.01_10 control` が期待値近傍。
6. FAIL がある場合でも、行単位で処理継続し、原因が `Status` / `error_message` / `lastStep` から判断できる。
7. Excel 設定が実行後に復帰している。

上記を満たした場合のみ、280点実行または TM03C 検討へ進んでください。
