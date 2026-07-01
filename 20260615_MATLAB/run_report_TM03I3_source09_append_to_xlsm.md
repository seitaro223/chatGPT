# TM03I3 source09 append to copied xlsm

## 入力確認
- 最新ログ確認: `20260615_H52Q_working_log_r77.md` はリポジトリ内で見つからなかった。TM03I2出力と既存r76方針に従って作業した。
- TM03I2プレビュー: `TM03I2_source09_append_rows_preview.csv`
- 元ブック名: `celataモデル_簡易計算_単管_櫻井検算r129_F1なし_09追加予定.xlsm`
- 出力ブック名: `celataモデル_簡易計算_単管_櫻井検算r129_F1なし_09追加予定_TM03I3_source09追記済みコピー.xlsm`

## 実施内容
- 元xlsmは上書きせず、コピー版を作成した。
- コピー版の `tm` シートで、既存最終行502の下へsource09 117点を追記した。
- 追記開始行: 503
- 追記終了行: 619
- 追記行数: 117
- 値入力列にはTM03I2プレビューCSVの値を投入した。`Tin` はTM03A方針に従い、プレビューCSVの `_Hsub_kJkg` から IF97 `h_in = h_f(P)-Hsub`、`Tin=T(P,h_in)` で算出して投入した。
- 数式列は既存最終行502からコピーし、行番号参照を追記先行へ平行移動した。
- Excelテーブル `テーブル2` の範囲を `A1:BR619` に拡張した。
- VBA、名前定義、既存シート構造は意図的に変更していない。
- マクロ実行、Excel再計算、計算結果確認、物理解釈は実施していない。

## 追記後の構造チェック
- `tm` シート最終行: 619
- `tm` シート列数: 70
- `テーブル2` 範囲: `A1:BR619`
- 予定ID衝突: 0 件
- source09行の識別方法: `No_TableNo` に `_10_source09` 接尾辞を付与した（例: `294.09_10_source09`）。
- 追記行の元情報はTM03I2プレビューCSV末尾メタ列（`_source`, `_table`, `_origin`, `_source_ExptNo`, `_flag_norm`, `_Hsub_kJkg`, `_L_over_D`, `_G_band2`, `_x_band2`）で外部保持した。

## 値入力列
No_TableNo(A), P(B), No(M), G(N), DH(Q), L_DNB(R), q_in(S), Tin(T), q_M(BE), F_form(BG), x_Mes(BH), Fcorr(BK), F2(BQ), L(BR)

## 数式コピー列
Ts(C), rhoG(D), rhoL(E), HG(F), HL(G), muG(H), muL(I), KL(J), CPL(K), sigma(L), A(O), Pw(P), Tf(U), Re(W), f_left(Y), f_rihgt(Z), f_balance(AA), DB(AB), y_plus(AD), Tm(AE), Tw_balance(AF), tauw(AH), Utau(AI), y_plus2(AJ), Q(AK), Pr(AL), T(y_plus)(AM), y_star_balance(AN), delta(AO), LB(AQ), YB(AR), YB_plus(AS), Karman_UB(AT), UBL(AU), UB_left(AV), CD(AW), UB_right(AX), UB_balance(AY), HG-HL(AZ), LB/UB(BA), q_P(BB), dq_chf(BC), dq_ratio(BD), PM_ratio(BF), Tsub(BL), q_P_MW(BM), Tsub2(BN), Fcorr2(BO), (Tsub-40)^2(BP)

## 502行テンプレート値を踏襲した列（値入力列でも数式列でもない列）
f(beta)(V), f(X), Tw(AC), y_star(AG), UB(AP), A_corr(BI), σ_corr(BJ)

## PR提出時の扱い
- 追記済みコピー版xlsmはバイナリ成果物のため、PRには含めない。
- 必要時は `python 20260615_MATLAB/TM03I3_build_source09_appended_copy.py` をローカルで実行して再生成する（Python依存: `openpyxl`, `iapws`）。
- 再生成されるファイル名は上記の出力ブック名と同じ。

## ユーザー側に残す作業
- Excelでコピー版xlsmを開く。
- 必要に応じてExcel再計算を実行する。
- 既存VBAマクロを手動実行する。
- VBAログ、計算結果、`PM_ratio` 等の結果列を確認する。
- 計算後に all B-like 117点、1900<=G<=4200 の40点、G<1900 の77点へ分けて評価する。
