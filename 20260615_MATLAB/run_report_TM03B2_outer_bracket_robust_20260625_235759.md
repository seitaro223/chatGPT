# TM03B2 — 外側二分探索のロバスト化（high-bracket 拡張 + 非物理ガード）

作成日: 2026-06-25 23:57 (UTC)
担当run: TM03B2（VBA改造 + 試験準備）

---

## 1. 目的
固定上限 `q_high = 12,000,000 W/m²` で解が探索範囲外になる点（高 q_M / 高 G）を、**非物理解に落とさず**扱えるようにする。対象は `Module6.AdjustSValue_BinarySearch_15_Fast_SaveEachRow_LogSheet_Final` の外側二分探索。

## 2. 失敗の診断（なぜ 259.01_10 / 249.01_10 が落ちたか）
既存マクロは外側探索の上限を `upperB = 12000000`（12 MW/m²）に固定していた。

| 点 | q_M | 想定 root q_in | 旧上限 | 症状 |
| --- | --- | --- | --- | --- |
| 259.01_10 | 12.90 MW/m² | ≳ 12〜13 MW/m² | 12 MW/m² | bracket 不能 → 上限張り付き／反復上限 |
| 249.01_10 | 14.76 MW/m² | ≳ 15 MW/m² | 12 MW/m² | root が上限超 → 収束せず（FAIL） |
| 9.01_10 (control) | 4.04 MW/m² | ≈ 4.12 MW/m² | 12 MW/m² | 範囲内 → 正常収束 |

root（q_P(q_in)=q_in を満たす自己整合 q_in）が固定上限を超えると、二分区間に解が入らず、旧コードは `delta<0` 側で `lowerB` を上げ続け区間が上限近傍に潰れる。結果、非物理／未収束のまま `min誤差` 値が採用され得た。

## 3. 改造内容（要求 1〜6 への対応）
新モジュール **`Module6B_TM03B2`**（ファイル `TM03B2_Module6B_robust_bracket.bas`）の `AdjustSValue_BracketRobust_TM03B2`。

1. **bracket 確認を前置**: 固定二分探索の前に `q_low` / `q_high` を評価し、解が挟めているか符号で確認。
2. **q_high の段階拡張**: `q_high` で挟めない場合、`q_high *= 1.5`（`EXPAND_FACTOR`）を繰り返す。`12 → 18 → 27 → 40.5 → 60.75(→上限60)` MW/m²。
3. **FAIL_BRACKET_HIGH**: `Q_HIGH_MAX = 60,000,000`（または拡張20回）でも挟めなければ `FAIL_BRACKET_HIGH` を Log に記録し**次行へ**（非物理値を採用しない）。
4. **非物理ガード**: 収束しても `q_P ≤ 0` / `PM_ratio ≤ 0` / `y_star ≤ 0` は成功扱いせず `FAIL_NONPHYSICAL`。`#VALUE!/#NUM!` は番兵値で非物理判定。
5. **Log 拡充**: 失敗理由・最終 `q_low/q_high`・最終 `dq_ratio`・Solver 結果コードを各 phase（BRACKET / BISECT / SUMMARY）で `ws_Log` に残す（列: RowNo, No_TableNo, phase, iter, q_low, q_high, q_in, q_P, delta, y_star, PM_ratio, dq_ratio_pct, solver_max_code, status, note）。
6. **高速化は最小限**: 旧コードの accel/decel 可変ステップは外し、**素直な bisection** に置換（ロジック変更の影響を見やすくするため）。

### bracket の符号定義（旧コードと整合）
旧コードの更新規則（`delta<0 → lowerB上げ`, `delta≥0 & F>0 → upperB=curS`, それ以外 `lowerB=curS`、F = q_P − q_in）から、写像は root 付近で **q_P′ > 1（拡大的）** と仮定される。これを踏襲し:

```
physical = (delta >= 0)
too_high = physical AND (q_P - q_in) > 0     ' root は当該 q_in より下
too_low  = (delta < 0) OR (physical AND (q_P - q_in) <= 0)
```
`q_low` で too_low、`q_high` で too_high を満たすよう拡張 → その区間で bisection（`too_high(m)→q_high=m`、それ以外 `q_low=m`）。収束判定は物理点で `|dq_ratio%| < TOL_PCT(=1)`。

## 4. 変更前後の比較（外側ロジック）
| 項目 | 旧 (Module6) | 新 (Module6B_TM03B2) |
| --- | --- | --- |
| 上限 | 固定 12 MW/m² | 12 MW/m² から **動的拡張**（上限 60 MW/m²） |
| bracket 確認 | なし（暗黙） | **明示**（q_low/q_high 評価） |
| 範囲外の扱い | 上限張り付き／min誤差採用 | **FAIL_BRACKET_HIGH** で記録・スキップ |
| 非物理解 | 区別なし（採用され得る） | **FAIL_NONPHYSICAL** で除外 |
| 内側 Solver | f→(Tw,y\_star,UB) 各行 | 同じ（再利用、結果コードを記録） |
| 収束探索 | 二分＋可変ステップ | **二分のみ**（最小限） |
| Log | 8列・反復のみ | 15列・BRACKET/BISECT/**SUMMARY** |

> 内側の Solver 呼び出し（GRG, Tw/y\_star/UB を各 balance=0 に）と `f` の1回求解、物性 UDF、数式列は**一切変更していない**。変えたのは外側の q_in 探索のみ。

## 5. マクロ実行の可否
**本環境（Linux, Excel/Solver/COM なし）では VBA 実行不可。** また、`vbaProject.bin` は圧縮済みバイナリのため openpyxl 等では**新モジュールを xlsm に書き込めない**。よって:
- 改造コードは **`.bas` ソース**として提供（手動インポート）。
- 試験用 xlsm には 3 点（259.01_10 / 249.01_10 / 9.01_10）を投入済み。ただし**中身は旧 Module6 のまま**（`Module6B_TM03B2 present? = False` を確認済み）。ユーザが `.bas` をインポートして実行する。

### 手動手順（Windows + Excel + Solver）
1. `TM03B2_macro_bracket_test_20260625_235759.xlsm` を開く（マクロ＋ソルバー有効化）。
2. VBE → ファイル → **`TM03B2_Module6B_robust_bracket.bas` をインポート**（`Module6B_TM03B2` が追加される）。Solver 参照（SOLVER.XLAM）が有効か確認。
3. マクロ **`AdjustSValue_BracketRobust_TM03B2`** を実行。
4. `frmRowInput` に **開始行=226 / 終了行=228**。
5. 実行後、`ws_Log`（Log シート）の SUMMARY 行で各点の status / 最終 q_low,q_high / dq_ratio / solver_max_code を確認し、`TM03B2_bracket_test_points_*.xlsx` の `result_template` を埋める。
6. （任意）比較のため旧 `Module6` を同じ 226–228 行で実行し、挙動差を確認。

## 6. 試験対象と期待挙動
| 点 | inject行 | 旧挙動 | 期待（新） |
| --- | --- | --- | --- |
| 259.01_10 | 226 | FAIL_BRACKET_HIGH（root≳12.9MW>12MW） | q_high を ~18–27 MW へ拡張し **OK 収束**（n_expand≈1–2） |
| 249.01_10 | 227 | FAIL（root≳14.76MW>12MW） | q_high を ~18–27 MW へ拡張し **OK 収束**（n_expand≈1–2） |
| 9.01_10 | 228 | 正常収束（≈4.12MW） | **拡張なしで OK**、q_in≈4.12MW を再現（control 不変であること） |

合格目安: (a) 259/249 が `FAIL→OK` に変わり q_in/q_P/PM が有限、(b) control 9.01_10 が旧と同じ ≈4.12 MW に収束（ロジック変更が既収束点を壊していないこと）、(c) Log に BRACKET/BISECT/SUMMARY が残る。

## 7. tunable（既定値）
| 定数 | 値 | 意味 |
| --- | --- | --- |
| `TOL_PCT` | 1.0 | 収束判定 |dq_ratio%| |
| `ITER_LIMIT` | 80 | bisection 反復上限 |
| `Q_LOW_INIT` | 1.0e5 | 下限初期 |
| `Q_HIGH_INIT` | 1.2e7 | 上限初期（旧固定値） |
| `Q_HIGH_MAX` | 6.0e7 | 上限拡張の天井 |
| `EXPAND_FACTOR` | 1.5 | q_high 拡張倍率 |
| `EXPAND_LIMIT` | 20 | q_high 拡張回数上限 |

## 8. 注意・前提・限界
- **写像の単調性仮定**: too_high の符号は旧コードと同じ「root 付近で q_P′>1」前提。overlap 点で旧コードが収束していた以上、同方向で問題ないが、もし新たに方向が逆の点が出たら SUMMARY の dq_ratio 推移で検知できる。
- **Solver 依存**: 内側 GRG Solver と SOLVER.XLAM 参照は従来どおり必須。`SolveZero` は例外時にコード 999 を返す。
- **本環境で未実行**: 期待値は解析的見積り。最終確認は Windows 実行が必要。
- **新モジュールは別名 Sub**（`AdjustSValue_BracketRobust_TM03B2`）。旧 `Module6` は残し、A/B 比較可能。常用化する場合は旧 Sub を退避推奨。
- 物性列・UDF・数式・固定定数・内側 Solver は不変。

## 9. 該当ファイル不明
- `TM03B1a_macro_reinject_validation_20260625_083115_run_done.xlsm` … **不明**（未配置。B1a の実行結果反映版は見つからず。代替は使用しない）。
- `20260615_H52Q_working_log_r57.md` … **不明**（`r55` のみ存在。参照用のため処理に影響なし）。
> いずれも本runの改造・試験準備には不要。

## 10. 次へ進めるか（提案）
- **まず本runの 3 点を Windows 実行**して、259/249 が `OK` に変わり control 9.01_10 が不変であることを確認。
- 確認できれば次は **案C**（TM03C 前に Solver 収束条件・Log 回収・自動集計を整備）→ その上で **案A**（TM03C 分割280点、Table10 new-only 先行）が安全。
- もし 259/249 が拡張後も `FAIL_NONPHYSICAL` 等になる場合は **案B**（TM03B1c で極端条件・Flag=G をさらに少数試験）に戻り、`Q_HIGH_MAX` や符号仮定を再点検。

## 11. 採用・保留・未確定
**採用（確定）**
- 外側探索を bracket確認＋high拡張＋非物理ガード＋Log拡充へ改造（`.bas` 提供）。
- 内側 Solver / 数式 / UDF / 固定定数は不変。
- 試験用 xlsm に 3 点（226–228行）を preview 由来値で投入（元xlsm 未改変、新規コピー）。

**保留**
- 実行結果（259/249 の OK 化、control 不変）の確定 = Windows 実行待ち（`<PENDING>`）。
- 常用化時に旧 Sub を退避するか。

**未確定（人間確認待ち）**
- `Q_HIGH_MAX=60MW` / `EXPAND_FACTOR=1.5` の妥当性（実行 Log で調整）。
- bisection 化による速度（旧 accel/decel 比）の許容可否。

---

## 付録: 同梱成果物
- `TM03B2_Module6B_robust_bracket.bas` … 改造 VBA（インポート用）。
- `TM03B2_macro_bracket_test_20260625_235759.xlsm` … 3 点投入済み試験用コピー（**要 .bas インポート**。元xlsm未改変）。
- `TM03B2_bracket_test_points_20260625_235759.xlsx` … `test_points` / `input_values` / `result_template`（実行後記入）。
