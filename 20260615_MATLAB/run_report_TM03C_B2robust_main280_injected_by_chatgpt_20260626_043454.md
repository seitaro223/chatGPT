# TM03C B2 robust main280 injected by ChatGPT

## Purpose
Statically injected main280 rows 226-505 into B2 robust xlsm without launching Excel, without MATLAB, without Solver, and without adding new VBA.

## Inputs
- Template xlsm: `TM03Cprep_B2robust_B1b12_injected_20260626_113807.xlsm`
- main280 input xlsx: `TM03C_main280_input_20260626_130059.xlsx`

## Outputs
- Injected xlsm: `TM03C_B2robust_main280_injected_by_chatgpt_20260626_043454.xlsm`
- QA workbook: `TM03C_B2robust_main280_injected_by_chatgpt_QA_20260626_043454.xlsx`

## Method
- Loaded template with `keep_vba=True`; VBA project before save: `True`, after save: `True`.
- Copied `tm!A88:BR88` to rows 226-505.
- Converted openpyxl ArrayFormula objects in C:L to ordinary formula text because they use structured table row references.
- Overwrote the 21 input columns after formula/style copy.
- Resized `テーブル2` to `A1:BR505`.

## QA summary
- 280_points_injected: True (280)
- No_TableNo_order_matches_input: True
- No_TableNo_no_duplicates: True (0)
- rows_226_to_505: True
- table_range_A1_BR505: True (A1:BR505)
- input_21_columns_match_spec: True
- S_equals_BE_equals_q_M: True
- fixed_values_match_spec: True
- vba_project_preserved: True (before=True, after=True)
- formula_value_cells_nonblank: True (19600)
- table_resize_operation: True (A1:BR505)

## Next step
Open the generated `.xlsm` in Windows Excel, enable macros and Solver, and run the existing B2 robust macro for Batch 1 only: start row 226, end row 275.
