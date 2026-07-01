# TM03H6: Table10 negative-quality high-P/M cluster diagnostic

## Purpose

TM03H5 showed that the legacy old86 set and the current187 set are not the same population.  
The user pointed to the high-P/M cluster in the overlay plot and hypothesized that this cluster may be at strongly negative quality.

TM03H6 tests that hypothesis quantitatively.

## Inputs

- `TM03H5_Table10_scatter_legacy_nonlinear_20260629_064139_current187_records_with_old86_tag.csv`
- `TM03H5_Table10_scatter_legacy_nonlinear_20260629_064139_old86_records_scope.csv`
- `TM03H3_Table10_raw_quality_scope_20260629_151620_raw_records_with_scope_tags.csv`

## Main findings

### 1. The hand-marked high-P/M region is a strongly negative-quality group

Approximate hand-marked region definition used here:

```text
PM_noF1 >= 2.2
60 <= Tsub <= 200 K
```

Count:

```text
yellow candidate N = 19
high-P/M cluster PM>=2.2 N = 26
high-P/M and x<=-0.20 N = 26
high-P/M and x<=-0.30 N = 23
```

The high-P/M cluster is therefore not just random scatter.  It is essentially a strongly negative-quality group.

### 2. The old86 set is close to a source01 + G-band selection, not a lowX selection

Old86 G range in raw Table10:

```text
G_1e6_lb_hr_ft2 min = 1.80
G_1e6_lb_hr_ft2 max = 3.00
```

Raw source01 rows satisfying `1.8 <= G_1e6 <= 3.0`:

```text
N_raw = 104
N_old86_inside = 86
```

This supports the memory that the old86 set may have been selected primarily by G, not by quality.  
However, it was not exactly G-only: there are source01 rows inside the same G range that are not in old86.

### 3. Old86 contains high-quality points, while current187 contains many negative-quality points

```text
old86 total N = 86
old86 x>0.05 N = 39
old86 overlap with current187 N = 47
old86-only N = 39
current-only N = 140
```

The old86-only 39 points are all on the x>0.05 side.  
The current-only side contains many strongly negative-quality points, including almost all of the high-P/M cluster.

### 4. Removing strongly negative quality points changes the apparent Tsub correlation

Selected threshold sensitivity, using current187 noF1:

```text
all current187:
  Tsub linear R2 = 0.418
  Tsub quadratic R2 = 0.696
  x linear R2 = 0.774

keep x > -0.30:
  Tsub linear R2 = 0.409
  Tsub quadratic R2 = 0.691
  x linear R2 = 0.633

keep x > -0.20:
  Tsub linear R2 = 0.566
  Tsub quadratic R2 = 0.882
  x linear R2 = 0.538

keep x > -0.10:
  Tsub linear R2 = 0.584
  Tsub quadratic R2 = 0.906
  x linear R2 = 0.465
```

This supports the interpretation that the current187 Tsub trend is distorted by a strongly negative-quality high-P/M group.

## Interpretation

The user's hand-marked region is very likely a strongly negative-quality subgroup.  
This subgroup is mostly current-only, not old86.  
Therefore, the old86 Tsub correlation and the current187 Tsub correlation should not be compared as if they used the same population.

A safe interpretation is:

```text
old86 was probably close to a G-band selected set, not a quality-limited set.
It included x>0.05 points and did not include many of the strongly negative-quality high-P/M points.
current187 is x<=0.05 by construction, but includes many x<=0 points, including a strongly negative-quality high-P/M subgroup.
This subgroup is a plausible cause of the apparent Table10 scatter and the weaker linear Tsub correlation.
```

## Output files

- `TM03H6_group_summary_20260629_070106.csv`
- `TM03H6_current187_xbin_scope_crosstab_20260629_070106.csv`
- `TM03H6_old86_xbin_scope_crosstab_20260629_070106.csv`
- `TM03H6_current187_quality_bin_summary_20260629_070106.csv`
- `TM03H6_old86_selection_probe_20260629_070106.csv`
- `TM03H6_raw_source01_in_oldG_not_old86_20260629_070106.csv`
- `TM03H6_highPM_negative_quality_candidates_20260629_070106.csv`
- `TM03H6_negative_x_threshold_sensitivity_20260629_070106.csv`
- `TM03H6_combined_current_old_records_20260629_070106.csv`

## Figures

- `fig_TM03H6_01_current187_PM_vs_Tsub_by_xbin_20260629_070106.png`
- `fig_TM03H6_02_overlay_scope_yellow_20260629_070106.png`
- `fig_TM03H6_03_current187_PM_vs_x_scope_20260629_070106.png`
- `fig_TM03H6_04_negative_x_threshold_R2_20260629_070106.png`
