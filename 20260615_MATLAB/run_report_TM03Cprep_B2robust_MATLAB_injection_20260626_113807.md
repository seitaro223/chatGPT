# TM03Cprep B2 robust MATLAB injection

## 1. 目的
MATLABでpreview/main280候補から対象点を選び、B2 robust bracket版xlsmのtmシートへ投入するrun packageを作る。Solver/VBA実行は行わない。

## 2. 背景
TM03B2ではq_high段階拡張のrobust bracket版によりB1b失敗点259.01_10と249.01_10の収束を確認済み。

## 3. なぜB3を保留しB2に戻したか
B3 summary runnerはWindows Excel環境でErr 429によりsummary作成前に停止したため、高機能runnerを保留し、動作確認済みのB2 robust版投入運用を優先する。

## 4. 入力ファイル
- C:\chatGPT\20260615_MATLAB\tm_input_preview_20260625_083115.xlsx
- C:\chatGPT\20260615_MATLAB\TM03B1b_newonly_candidate_points_20260625_235759.xlsx

## 5. テンプレートxlsm
- C:\chatGPT\20260615_MATLAB\TM03B2_macro_bracket_test_20260625_235759_run_done.xlsm
- 出力: C:\chatGPT\20260615_MATLAB\TM03Cprep_B2robust_B1b12_injected_20260626_113807.xlsm

## 6. MATLAB投入方法
Excel COM (`actxserver('Excel.Application')`)でxlsmを開き、VBAを保持したままtmシートへ入力した。保存形式は52 (`xlOpenXMLWorkbookMacroEnabled`)。

## 7. 投入対象点
開始行=226、終了行=237。

- 39.01_10
- 27.01_10
- 81.01_10
- 259.01_10
- 1.01_10
- 442.01_10
- 150.01_10
- 289.01_10
- 249.01_10
- 281.01_10
- 40.01_10
- 9.01_10

## 8. 列マッピング
QA workbookの`column_mapping` sheetを参照。固定値はV=0.03, X=0.01, AC=600, AG=1e-5, AP=1, BG=1, BI=0.046, BJ=5625, BK=1, BQ=1。S q_inはq_Mを初期値として投入。

## 9. 数式コピー方法
`tm`シートのA:BRについて、実績行88を各対象行へコピー後、入力21列を上書きした。

## 10. テーブル範囲拡張
`テーブル2`をA1:BR237へResizeした。実際のCOM報告範囲: 。

## 11. QA結果
QA workbook: C:\chatGPT\20260615_MATLAB\TM03Cprep_B2robust_B1b12_injection_QA_20260626_113807.xlsx

- 12_points_injected: 1
- order_matches: 1
- table_range_A1_BR237: 0

## 12. Windows Excel/VBAでの実行手順
1. `C:\chatGPT\20260615_MATLAB\TM03Cprep_B2robust_B1b12_injected_20260626_113807.xlsm`を開く。
2. マクロとSolverを有効化する。
3. `AdjustSValue_BracketRobust_TM03B2`を実行する。
4. 行入力フォームでは開始行=226、終了行=237を指定する。
5. 実行後、`TM03Cprep_B2robust_B1b12_injected_YYYYMMDD_HHMMSS_run_done.xlsm`として別名保存する。

## 13. 合格基準
- 12点すべてでVBA/Solverが途中停止しない。
- 12点すべてでq_in、q_P、PM_ratioが有限値。
- dq_ratioが概ね±1%以内。
- 259.01_10と249.01_10がOK。
- 9.01_10 controlがB1a/B2と同程度。
- Logが出る。

## 14. 次のTM03C-1へ進む条件
B1b 12点のMATLAB投入版がWindows Excel/VBAで合格した場合のみ、Table10 new-only 143点の分割投入・分割実行（50/50/43点）へ進む。
