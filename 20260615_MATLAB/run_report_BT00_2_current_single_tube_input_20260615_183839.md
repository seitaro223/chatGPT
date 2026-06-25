# BT00-2 current single-tube input

作成日時: 20260615

## 1. 目的

単管側のT&M/BMI整理について、今後参照してよい入力・診断データを current_single_tube_input として切り出した。

## 2. 入力と出力

- r8 result: `20260612_計算結果比較r8_result_文献追加用.xlsx`
- v10 trueHsub: `TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx`
- v11 middle decomp: `TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx`
- 出力: `H52Q_current_single_tube_input_v1_20260615_183839.xlsx`

## 3. current single-tube の位置づけ

- r8 resultブックを直接読み続けない。
- 単管noF1/F1の現行元データを保持する。
- v10/v11診断ブックを診断currentとして保持する。
- L/D補正式は作らない。
- L/Dは履歴代理・診断項として保留する。
- qMおよびx_Mesは補正式入力としては使わない。
- x_eqは前向き計算で使える状態量として、バンドル側へ送る候補にする。

## 4. Source manifest

| action | source_group | source_file | source_sheet | current_sheet | n_rows | n_cols | read_status | note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| include_primary | r8_result | 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_r123_noF1_T8_14 | ST_noF1_T8_14_current | 224 | 70 | included | 単管noF1の現行元データ。 readtable成功。 |
| include_primary | r8_result | 20260612_計算結果比較r8_result_文献追加用.xlsx | tm_r124_F1_T8_14 | ST_F1_T8_14_current | 224 | 70 | included | 単管F1の現行元データ。 readtable成功。 |
| include_diagnostic | v10_trueHsub | TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx | basic | V10_basic | 11 | 2 | included | 真Hsub付きTable8〜12診断。 readtable成功。 |
| include_diagnostic | v10_trueHsub | TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx | Hsub_mapping_used | V10_Hsub_mapping_used | 192 | 5 | included | 真Hsub付きTable8〜12診断。 readtable成功。 |
| include_diagnostic | v10_trueHsub | TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx | model_compare_by_scope | V10_model_compare_by_scope | 19 | 8 | included | 真Hsub付きTable8〜12診断。 readtable成功。 |
| include_diagnostic | v10_trueHsub | TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx | model_coefficients | V10_model_coefficients | 64 | 5 | included | 真Hsub付きTable8〜12診断。 readtable成功。 |
| include_diagnostic | v10_trueHsub | TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx | by_scope_LD | V10_by_scope_LD | 5 | 15 | included | 真Hsub付きTable8〜12診断。 readtable成功。 |
| include_diagnostic | v10_trueHsub | TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx | by_scope_table_LD | V10_by_scope_table_LD | 8 | 17 | included | 真Hsub付きTable8〜12診断。 readtable成功。 |
| include_diagnostic | v10_trueHsub | TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx | same_table_pairs | V10_same_table_pairs | 3 | 18 | included | 真Hsub付きTable8〜12診断。 readtable成功。 |
| include_diagnostic | v10_trueHsub | TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx | Table8_middle_context | V10_Table8_middle_context | 3 | 9 | included | 真Hsub付きTable8〜12診断。 readtable成功。 |
| include_diagnostic | v10_trueHsub | TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx | direction_check | V10_direction_check | 2 | 6 | included | 真Hsub付きTable8〜12診断。 readtable成功。 |
| include_diagnostic | v10_trueHsub | TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx | target_rows_T8_12 | V10_target_rows_T8_12 | 192 | 40 | included | 真Hsub付きTable8〜12診断。 readtable成功。 |
| include_diagnostic | v11_middleDecomp | TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx | basic | V11_basic | 10 | 2 | included | Table8 middle低下理由分解診断。 readtable成功。 |
| include_diagnostic | v11_middleDecomp | TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx | group_summary | V11_group_summary | 5 | 26 | included | Table8 middle低下理由分解診断。 readtable成功。 |
| include_diagnostic | v11_middleDecomp | TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx | group_contrast | V11_group_contrast | 4 | 12 | included | Table8 middle低下理由分解診断。 readtable成功。 |
| include_diagnostic | v11_middleDecomp | TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx | model_compare_PM_F1 | V11_model_compare_PM_F1 | 12 | 7 | included | Table8 middle低下理由分解診断。 readtable成功。 |
| include_diagnostic | v11_middleDecomp | TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx | model_coefficients_PM_F1 | V11_model_coefficients_PM_F1 | 46 | 4 | included | Table8 middle低下理由分解診断。 readtable成功。 |
| include_diagnostic | v11_middleDecomp | TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx | model_compare_PM_noF1 | V11_model_compare_PM_noF1 | 12 | 7 | included | Table8 middle低下理由分解診断。 readtable成功。 |
| include_diagnostic | v11_middleDecomp | TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx | model_coefficients_PM_noF1 | V11_model_coefficients_PM_noF1 | 46 | 4 | included | Table8 middle低下理由分解診断。 readtable成功。 |
| include_diagnostic | v11_middleDecomp | TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx | resid_by_group | V11_resid_by_group | 3 | 15 | included | Table8 middle低下理由分解診断。 readtable成功。 |
| include_diagnostic | v11_middleDecomp | TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx | match_Hsub_P_xMes | V11_match_Hsub_P_xMes | 16 | 27 | included | Table8 middle低下理由分解診断。 readtable成功。 |
| include_diagnostic | v11_middleDecomp | TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx | match_Hsub_xMes | V11_match_Hsub_xMes | 16 | 27 | included | Table8 middle低下理由分解診断。 readtable成功。 |
| include_diagnostic | v11_middleDecomp | TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx | match_P_xMes | V11_match_P_xMes | 16 | 27 | included | Table8 middle低下理由分解診断。 readtable成功。 |
| include_diagnostic | v11_middleDecomp | TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx | match_summary | V11_match_summary | 3 | 6 | included | Table8 middle低下理由分解診断。 readtable成功。 |
| include_diagnostic | v11_middleDecomp | TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx | interpretation_flags | V11_interpretation_flags | 8 | 3 | included | Table8 middle低下理由分解診断。 readtable成功。 |
| include_diagnostic | v11_middleDecomp | TM8_14_table8_middle_decomp_v11_20260615_134832.xlsx | explore_rows_with_resid | V11_explore_rows_with_resid | 46 | 68 | included | Table8 middle低下理由分解診断。 readtable成功。 |

## 5. Diagnostic scope

| item | scope_type | current_treatment | note |
| --- | --- | --- | --- |
| Table8 | data_scope | reference_only | source03に閉じる。middleのみ。P/x_eq/Hsub/qMも異なるため、L/D検証点として単純には使わない。 |
| Table9 | data_scope | source01_lower_check | source01で約12MPa。PWR下限側チェックとして使う。 |
| Table10 | data_scope | source01_PWR_near_main | PWR_near主解析群。Table10点数が多いため、支配性には注意。 |
| Table11 | data_scope | source01_PWR_near_main | PWR_near主解析群。真Hsubでshort-long差はおおむね説明可能。 |
| Table12 | data_scope | source01_PWR_near_main | Hsub linearではlong残差が残るが、Hsub+P+x_eqではほぼ消える。 |
| Table13/14 | data_scope | high_check | 高圧側チェック。主補正式判断には使わない。 |
| BMI-1116 | literature_scope | context | 0.075 in短管/長管は同一系列だが、入口サブクール差が大きく、純粋なL/d比較ではない。 |
| WAPD-188 | literature_scope | context | L/D項はあるが、本当はboiling length等の履歴変数かもしれない。 |
| L/D | variable_policy | diagnostic_only | 補正式候補ではなく、熱履歴・沸騰履歴の代理指標として保留する。 |
| Hsub | variable_policy | main_diagnostic_axis | 真Hsubを優先する。proxyは定量判断に使わない。 |
| P | variable_policy | diagnostic_axis | 圧力・物性・hfgを通じた状態量として扱う。 |
| x_eq | variable_policy | forward_state_candidate | 前向き計算で使える熱収支状態量として、バンドル側へ送る。 |
| x_Mes | variable_policy | not_formula_input | 結果側量として扱う。補正式入力には使わない。 |
| qM | variable_policy | diag_only_not_formula_input | 結果側量。補正式入力には使わない。 |

## 6. 採用・保留・撤回気味

| state | content |
| --- | --- |
| 採用 | T&M Table9〜12のTable12 long正残差は、Hsub linearでは見えるが、Hsub + P + x_eqでほぼ消える。 |
| 採用 | Table10を除いても、Table別均等重みにしても、Table12 long正残差は復活しない。 |
| 採用 | T&M単管データからL/D補正式を作る根拠は弱い。 |
| 採用 | Hsub + P + x_eqは補正式ではなく、原因切り分け用の診断式として扱う。 |
| 採用 | qMおよびx_Mesは補正式入力には使わない。 |
| 採用 | x_eqは、バンドル側で使える前向き計算量として、F1(Tsub)の代替・説明候補にする。 |
| 採用 | BMI-1116により、0.075 in短管/長管は比較不能ではないが、純粋なL/d比較ではない。 |
| 保留 | F1(Tsub)を維持するか、将来的にF(x_eq)または履歴長ベースに置換するか。 |
| 保留 | qP側に既に入っているL/D項・長さ補正の有無。 |
| 保留 | Hsub算出経路の表間整合。 |
| 保留 | source01原本で、Table9/10/11/12の装置・系列・表注・条件定義に矛盾がないか。 |
| 撤回気味 | T&M単管データから直接L/D補正式を作る案。 |
| 撤回気味 | Table12 long正残差をL/D/熱履歴効果の主証拠として扱う案。 |

## 7. 次アクション

1. 出力された current_single_tube ブックを確認する。
2. 問題なければ working log にBT00-2完了を追記する。
3. 次に current_bundle 入力を使ってBT01/BT02再現、またはBT03へ進む。
4. 単管側は補正式化せず、x_eq・履歴長をバンドル議論へ送る。
