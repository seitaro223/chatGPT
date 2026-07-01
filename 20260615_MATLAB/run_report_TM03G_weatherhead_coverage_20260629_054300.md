# TM03G Weatherhead / ANL coverage check

Created: 2026-06-29T05:43:00

## Purpose

Check whether the Weatherhead/ANL table extracted in `anl_1958_chf_claude.md` is already present in T&M Table10 source09, and whether it is included in the current calculated `main280/current_result` set.

This is a coverage / duplicate check. It does not make a new F1 fit and does not decide final adoption of Weatherhead points.

## Inputs

- Weatherhead/ANL extraction: `anl_1958_chf_claude.md`
- T&M Table10 canonical markdown: `thompson_macbeth_table10_2000psia_r1.md`
- current_result all280: `TM03EF_current_result_acceptance_QA_20260629_135859_records_all280.csv`
- current_result valid277: `TM03EF_current_result_acceptance_QA_20260629_135859_records_valid277.csv`

## 1. ANL / Weatherhead vs T&M Table10 source09

### Row counts

| set | N |
|---|---:|
| ANL/Weatherhead extracted rows | 232 |
| T&M Table10 `.09` source09 rows | 232 |
| ANL Table I, D=0.304 in | 106 |
| ANL Table II, D=0.436 in | 126 |
| T&M source09 D=0.304 in | 106 |
| T&M source09 D=0.436 in | 126 |

### Physical-key coverage

Matching key:

```text
DIA, LENGTH, G, Inlet Subcooling, Burnout Heat Flux
```

Result:

| item | count |
|---|---:|
| exact row matches | 230 |
| ambiguous but physically identical matches | 2 |
| unmatched ANL rows | 0 |
| key-count mismatches between ANL and T&M source09 | 0 |

The two ambiguous rows are physically identical duplicate conditions: ANL runs `8-39` and `8-48` both correspond to T&M rows `363.09` and `366.09` by the same physical key. This is not a missing-data problem; it is a one-to-one labeling ambiguity for duplicate points.

### Judgment

```text
Weatherhead/ANL extracted 232 rows are fully covered by T&M Table10 source09.
T&M Table10 source09 has the same 232-row physical-key multiset.
Therefore, Weatherhead should not be added as an independent new dataset without duplicate handling.
```

## 2. Low-quality subset in T&M source09

| item | count |
|---|---:|
| source09 all | 232 |
| source09 Exit Quality <= 0.05 | 117 |
| source09 Exit Quality <= 0 | 93 |

This confirms the previous interpretation that source09 is a sizable Weatherhead/ANL-equivalent series inside T&M Table10, not a small incidental subset.

## 3. Coverage in current main280 / current_result

| set | N all | N Table10 | source09 by No suffix | source09 by D/L physical check |
|---|---:|---:|---:|---:|
| current_result all280 | 280 | 190 | 0 | 0 |
| current_result valid277 | 277 | 187 | 0 | 0 |

Table10 diameters in current_result are:

```text
0.075, 0.143, 0.18, 0.186, 0.187, 0.226, 0.306
```

T&M source09 / Weatherhead uses D=0.304 in and D=0.436 in, L=18 in. These source09 physical conditions are not present in the current `main280/current_result` calculation set.

### Judgment

```text
Weatherhead/ANL is present in T&M Table10 raw source09.
However, Weatherhead/ANL source09 is not included in the current calculated main280/current_result set.
```

This is not necessarily an error. It means the current main280 calculation set is not an all-source Table10 inventory. If Weatherhead/source09 should be calculated later, it must be brought in deliberately as a new candidate calculation set, with duplicate control against T&M source09.

## 4. Working interpretation

```text
- Weatherhead is already represented in T&M Table10 as source09.
- Weatherhead should not be added again as an independent literature dataset.
- The present main280/current_result does not contain source09/Weatherhead points.
- Therefore, Weatherhead coverage is complete at the raw T&M Table10 level, but not in the current calculated set.
```

## 5. Recommended next handling

```text
1. Do not add Weatherhead as new independent data.
2. Keep Weatherhead/source09 as a raw Table10 duplicate/coverage confirmation.
3. If source09 is needed for F1 redesign or Table10 follow-up, create a separate source09 candidate calculation set later.
4. Do not mix source09 into the current main280 retroactively without a new task label and adoption rule.
```

## Outputs

- mapping: `TM03G_weatherhead_to_TM_source09_mapping_20260629_054300.csv`
- key_count_coverage: `TM03G_weatherhead_key_count_coverage_20260629_054300.csv`
- summary: `TM03G_weatherhead_summary_20260629_054300.csv`
- current_result_coverage: `TM03G_weatherhead_current_result_coverage_20260629_054300.csv`
- current_result_exact_matches: `TM03G_weatherhead_current_result_exact_matches_20260629_054300.csv`
