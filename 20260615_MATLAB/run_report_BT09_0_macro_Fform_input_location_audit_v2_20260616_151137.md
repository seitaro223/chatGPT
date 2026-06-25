# BT09-0 v2 macro F_form input location audit

作成日時: 20260616

## 1. 目的

マクロブック側でF_formがどのシート・どの列に入力されているかを監査する。この段階ではマクロブックを編集しない。

## 2. 入力

- A3 package: `BT08A3_macro_Fform_replace_package_20260616_145859.xlsx`
- macro workbook: `celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm`

## 3. v2修正点

```text
v1では has_F_form_like が行ベクトルになる場合があり、table縦結合で次元不一致エラーになった。
v2では any(A(:)) に統一し、必ずスカラー論理値として保存するよう修正した。
```

## 4. QC flags

| item | status | value | reading |
| --- | --- | --- | --- |
| macro_sheet_count | diagnostic | 6 | マクロブック内のシート数。 |
| A3_rows | OK | 116 | A3差し替え行数。 |
| Fform_header_candidates | OK | 1 | F_formに見えるセル候補あり。 |
| No_header_candidates | OK | 1 | Noに見えるセル候補あり。 |
| replacement_location_candidates | OK | 1 | 差し替え位置候補あり。 |
| exact_sheet_name_matches | diagnostic | 0/6 | A3側シート名とマクロシート名の完全一致数。 |
| feasible_A3_sheets | diagnostic | 0/6 | A3シート別に差し替え候補が見つかった数。 |
| high_confidence_candidates | OK | 1 | 高信頼候補あり。 |
| edit_policy | adopt | read_only_audit | BT09-0では編集しない。 |
| next | next | BT09-A | コピー版マクロブックへの差し替えへ進むか判断。 |

## 5. Sheet name matches

| expected_sheet_from_A3 | exact_match_in_macro | contains_match_count | contains_matches |
| --- | --- | --- | --- |
| tm_108 | false | 6 | SatProp, Cp_T_low, Cp_T_mid, Cp_T_high, tm, Log |
| tm_161 | false | 6 | SatProp, Cp_T_low, Cp_T_mid, Cp_T_high, tm, Log |
| tm_164 | false | 6 | SatProp, Cp_T_low, Cp_T_mid, Cp_T_high, tm, Log |
| tm_F1_108 | false | 6 | SatProp, Cp_T_low, Cp_T_mid, Cp_T_high, tm, Log |
| tm_F1_161 | false | 6 | SatProp, Cp_T_low, Cp_T_mid, Cp_T_high, tm, Log |
| tm_F1_164 | false | 6 | SatProp, Cp_T_low, Cp_T_mid, Cp_T_high, tm, Log |

## 6. Sheet feasibility

| A3_sheet | target_kind | N_replace_rows | min_No | max_No | exact_macro_sheet_exists | N_location_candidates | best_Fform_cell | best_Fform_col | best_Fform_header_row | best_confidence | feasibility_status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| tm_108 | noF1 | 14 | 229 | 254 | false | 0 |  |  |  |  | sheet_not_found |
| tm_161 | noF1 | 23 | 268 | 317 | false | 0 |  |  |  |  | sheet_not_found |
| tm_164 | noF1 | 21 | 319 | 381 | false | 0 |  |  |  |  | sheet_not_found |
| tm_F1_108 | F1 | 14 | 229 | 254 | false | 0 |  |  |  |  | sheet_not_found |
| tm_F1_161 | F1 | 23 | 268 | 317 | false | 0 |  |  |  |  | sheet_not_found |
| tm_F1_164 | F1 | 21 | 319 | 381 | false | 0 |  |  |  |  | sheet_not_found |

## 7. F_form header candidates

| file | sheet | row | col | excel_cell | value | hit_type |
| --- | --- | --- | --- | --- | --- | --- |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | tm | 1 | 59 | BG1 | F_form | Fform_like_header_or_cell |

## 8. No header candidates

| file | sheet | row | col | excel_cell | value | hit_type |
| --- | --- | --- | --- | --- | --- | --- |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | tm | 1 | 13 | M1 | No | No_like_header_or_cell |

## 9. Replacement location candidates

| macro_sheet | Fform_header_row | Fform_header_col | Fform_header_cell | No_header_row | No_header_col | No_header_cell | data_start_row_guess | exact_A3_sheet_match | replacement_row_rule_guess | replacement_col_rule_guess | confidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| tm | 1 | 59 | F_form | 1 | 13 | No | 2 | false | macro_excel_row = A3.data_row_index + data_start_row_guess - 1 | macro_col = Fform_header_col | high |

## 10. Keyword hits preview

| file | sheet | row | col | excel_cell | value | hit_type |
| --- | --- | --- | --- | --- | --- | --- |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | tm | 1 | 54 | BB1 | q_P | keyword_hit |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | tm | 1 | 57 | BE1 | q_M | keyword_hit |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | tm | 1 | 58 | BF1 | PM_ratio | keyword_hit |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | tm | 1 | 59 | BG1 | F_form | keyword_hit |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | tm | 1 | 65 | BM1 | q_P_MW | keyword_hit |
| celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm | Log | 1 | 4 | D1 | q_P | keyword_hit |

## 11. Next steps

| step | action | detail |
| --- | --- | --- |
| 1 | Check F_form candidates | Open B09_replace_location_candidates and identify the exact F_form column. |
| 2 | Check No alignment | Confirm whether No column exists on the same header row as F_form. |
| 3 | Check sheet matching | Compare macro sheet names with A3 sheet names: tm_108, tm_161, tm_164, tm_F1_108, tm_F1_161, tm_F1_164. |
| 4 | Do not edit original | Original macro workbook remains unchanged: celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり.xlsm |
| 5 | Prepare copy | BT09-A should copy the macro workbook before replacement. |
| 6 | Use A3 package | Use A3_macro_replace_map from BT08A3_macro_Fform_replace_package_20260616_145859.xlsx for replacement values. |
| 7 | Run macro manually | After copy replacement, run macro manually if required. |
| 8 | Upload run report | Upload BT09-A or macro recalculation report for interpretation. |

## 12. 判断メモ

```text
- このBT09-0 v2は監査専用であり、マクロブックを編集していない。
- F_form候補列とNo候補列の位置が確認できたら、BT09-Aでコピー版マクロブックへの差し替えを行う。
- 今回のマクロブックがF1なし版の場合、まずnoF1側の差し替え位置確認として扱う。
```
