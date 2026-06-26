# TM03C B2 robust main280 injection by Codex

This directory keeps only the text/code needed to generate the TM03C main280 injected workbook.
Generated binary artifacts are not committed because the PR system does not support them.

## How to generate locally

```bash
python -m pip install --user openpyxl
python 20260615_MATLAB/TM03C_inject_main280_by_codex.py
```

The script uses `TM03C_main280_input_*.xlsx` when present; otherwise it falls back to `tm_input_preview_20260625_083115.xlsx`.

The script generates, but does not track:

- `TM03C_B2robust_main280_injected_by_codex_YYYYMMDD_HHMMSS.xlsm`
- `TM03C_B2robust_main280_injected_by_codex_QA_YYYYMMDD_HHMMSS.xlsx`
- `run_report_TM03C_B2robust_main280_injected_by_codex_YYYYMMDD_HHMMSS.md`

## Important constraints

- No Excel is launched.
- MATLAB is not used.
- Solver is not run.
- No new VBA module is added.
- Existing B2 robust VBA is preserved via `openpyxl.load_workbook(..., keep_vba=True)`.

## Expected next step after generation

Open the generated `.xlsm` in Windows Excel, enable macros and Solver, and run the existing B2 robust macro for Batch 1 only:

- start row: `226`
- end row: `275`
