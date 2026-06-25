# ST-LD-00 v3 single-tube Tsub between/within decomposition

作成日時: 2026-06-18 15:31:00

## 1. 目的

単管F1後PM_F1に残るTsub相関を、L/D group間差とgroup内Tsub傾きに分解する。

ST-LD-01へ進む前の判定ゲートであり、補正式作成ではない。

## 2. 入力と採用シート

- input_file: `H52Q_current_single_tube_input_v1_20260615_183839.xlsx`
- chosen_sheet: `ST_F1_T8_14_current`
- Table column: `No_TableNo`
- PM_F1 column: `PM_ratio`
- Tsub column: `Tsub`
- L/D column: `L_DNB`
- L/D band column: ``
- Source column: ``

## 3. Sheet scan

| sheet | n_rows | n_cols | primary_rows | status |
| --- | --- | --- | --- | --- |
| README_CURRENT | 18 | 2 | 0 | too_small |
| DATA_DICTIONARY_CURRENT | 250 | 6 | 0 | skip: missing required column(s) |
| SOURCE_MANIFEST | 26 | 9 | 0 | skip: missing required column(s) |
| QUALITY_NOTES | 12 | 2 | 0 | too_small |
| ST_SCOPE_CURRENT | 14 | 4 | 0 | too_small |
| ST_ADOPT_HOLD_RETRACT | 13 | 2 | 0 | too_small |
| ST_noF1_T8_14_current | 224 | 70 | 171 | OK: valid rows=224, primary rows=171 |
| ST_F1_T8_14_current | 224 | 70 | 171 | OK: valid rows=224, primary rows=171 |
| V10_basic | 11 | 2 | 0 | too_small |
| V10_Hsub_mapping_used | 192 | 5 | 0 | skip: missing required column(s) |
| V10_model_compare_by_scope | 19 | 8 | 0 | skip: missing required column(s) |
| V10_model_coefficients | 64 | 5 | 0 | skip: missing required column(s) |
| V10_by_scope_LD | 5 | 15 | 0 | skip: missing required column(s) |
| V10_by_scope_table_LD | 8 | 17 | 0 | skip: missing required column(s) |
| V10_same_table_pairs | 3 | 18 | 0 | too_small |
| V10_Table8_middle_context | 3 | 9 | 0 | too_small |
| V10_direction_check | 2 | 6 | 0 | too_small |
| V10_target_rows_T8_12 | 192 | 40 | 165 | OK: valid rows=192, primary rows=165 |
| V11_basic | 10 | 2 | 0 | too_small |
| V11_group_summary | 5 | 26 | 0 | skip: valid rows < 5 |
| V11_group_contrast | 4 | 12 | 0 | too_small |
| V11_model_compare_PM_F1 | 12 | 7 | 0 | skip: missing required column(s) |
| V11_model_coefficients_PM_F1 | 46 | 4 | 0 | too_small |
| V11_model_compare_PM_noF1 | 12 | 7 | 0 | skip: missing required column(s) |
| V11_model_coefficients_PM_noF1 | 46 | 4 | 0 | too_small |
| V11_resid_by_group | 3 | 15 | 0 | too_small |
| V11_match_Hsub_P_xMes | 16 | 27 | 0 | skip: missing required column(s) |
| V11_match_Hsub_xMes | 16 | 27 | 0 | skip: missing required column(s) |
| V11_match_P_xMes | 16 | 27 | 0 | skip: missing required column(s) |
| V11_match_summary | 3 | 6 | 0 | too_small |
| V11_interpretation_flags | 8 | 3 | 0 | too_small |
| V11_explore_rows_with_resid | 46 | 68 | 27 | OK: valid rows=46, primary rows=27 |


## 4. Primary result: Table9-12

| dataset | N | R2_PM_Tsub_all | slope_PM_Tsub_per_100K_all | R2_PM_LD_all | slope_PM_LD_all | R2_between_groupMeanPM_groupMeanTsub | slope_between_PM_per_100K | R2_between_groupMeanPM_groupMeanLD | slope_between_PM_per_LD | R2_within_PMwithin_Tsubwithin | slope_within_PM_per_100K | R2_within_PMwithin_LDwithin | slope_within_PM_per_LD | R2_group_only | R2_group_plus_Tsub_within | delta_R2_Tsub_within_after_group | tentative_flag | reading |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| primary_Table9_12 | 171 | 0.684518 | 0.22011 | 0.326092 | 0.766796 | 0.988935 | 0.261466 | 0.66363 | 0.813961 | 0.405402 | 0.168876 | 0.455261 | 5.70467 | 0.538679 | 0.725699 | 0.18702 | CHECK_F1_EXTRAPOLATION | 群内Tsub効果が残る可能性。L/D補正式前にST-HSUBまたはF1再フィット検討。 |


### 4.1 L/D group stats

| dataset | LD_group | N | PM_mean | PM_sd | PM_se | Tsub_mean | Tsub_sd | LD_mean | LD_sd |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| primary_Table9_12 | short | 71 | 1.13361 | 0.123144 | 0.0146145 | 101.4 | 29.637 | 0.152336 | 0.000380923 |
| primary_Table9_12 | middle | 65 | 0.962258 | 0.097122 | 0.0120465 | 56.7986 | 53.9395 | 0.305826 | 0.00973934 |
| primary_Table9_12 | long | 35 | 1.48537 | 0.328598 | 0.0555432 | 250.488 | 122.58 | 0.671866 | 0.0449092 |


### 4.2 Group-wise PM_F1 vs Tsub slopes

| dataset | LD_group | N | R2_PM_Tsub | slope_PM_per_K | slope_PM_per_100K | intercept |
| --- | --- | --- | --- | --- | --- | --- |
| primary_Table9_12 | short | 71 | 0.279495 | -0.00219668 | -0.219668 | 1.35635 |
| primary_Table9_12 | middle | 65 | 0.414329 | 0.001159 | 0.1159 | 0.896429 |
| primary_Table9_12 | long | 35 | 0.768157 | 0.00234947 | 0.234947 | 0.896862 |


### 4.3 Model comparison

| dataset | model | N | k | R2 | RMSE |
| --- | --- | --- | --- | --- | --- |
| primary_Table9_12 | PM ~ Tsub | 171 | 2 | 0.684518 | 0.146087 |
| primary_Table9_12 | PM ~ L/D | 171 | 2 | 0.326092 | 0.213513 |
| primary_Table9_12 | PM ~ LD_group | 171 | 3 | 0.538679 | 0.176655 |
| primary_Table9_12 | PM ~ LD_group + Tsub_within | 171 | 4 | 0.725699 | 0.136219 |
| primary_Table9_12 | PM ~ LD_group + LD_within | 171 | 4 | 0.748701 | 0.130383 |
| primary_Table9_12 | PM ~ LD_group + raw_Tsub | 171 | 4 | 0.725699 | 0.136219 |


## 5. Reference result: Table8-14

| dataset | N | R2_PM_Tsub_all | slope_PM_Tsub_per_100K_all | R2_PM_LD_all | slope_PM_LD_all | R2_between_groupMeanPM_groupMeanTsub | slope_between_PM_per_100K | R2_between_groupMeanPM_groupMeanLD | slope_between_PM_per_LD | R2_within_PMwithin_Tsubwithin | slope_within_PM_per_100K | R2_within_PMwithin_LDwithin | slope_within_PM_per_LD | R2_group_only | R2_group_plus_Tsub_within | delta_R2_Tsub_within_after_group | tentative_flag | reading |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| reference_Table8_14 | 224 | 0.664787 | 0.277263 | 0.000370933 | 0.0174223 | 0.983929 | 0.260016 | 0.679073 | 0.450016 | 0.570842 | 0.289795 | 0.430156 | -0.97968 | 0.235336 | 0.671839 | 0.436502 | CHECK_F1_EXTRAPOLATION | 群内Tsub効果が残る可能性。L/D補正式前にST-HSUBまたはF1再フィット検討。 |


## 6. Per-table summary

| dataset | N | R2_PM_Tsub_all | slope_PM_Tsub_per_100K_all | R2_PM_LD_all | slope_PM_LD_all | R2_between_groupMeanPM_groupMeanTsub | slope_between_PM_per_100K | R2_between_groupMeanPM_groupMeanLD | slope_between_PM_per_LD | R2_within_PMwithin_Tsubwithin | slope_within_PM_per_100K | R2_within_PMwithin_LDwithin | slope_within_PM_per_LD | R2_group_only | R2_group_plus_Tsub_within | delta_R2_Tsub_within_after_group | tentative_flag | reading |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Table9 | 29 | 0.289909 | 0.0917536 | 0.481436 | 0.453681 | NaN | NaN | NaN | NaN | 0.522278 | -0.345363 | 0.808304 | -256.974 | 0.482914 | 0.752977 | 0.270063 | CHECK_F1_EXTRAPOLATION | 群内Tsub効果が残る可能性。L/D補正式前にST-HSUBまたはF1再フィット検討。 |
| Table10 | 86 | 0.204041 | 0.117345 | 0.104899 | -0.40005 | 0.692439 | 0.338533 | 0.479704 | -0.378114 | 0.165945 | 0.0881909 | 0.0138862 | 1.45666 | 0.366423 | 0.471563 | 0.105139 | CHECK_F1_EXTRAPOLATION | 群内Tsub効果が残る可能性。L/D補正式前にST-HSUBまたはF1再フィット検討。 |
| Table11 | 28 | 0.852365 | 0.244849 | 0.926263 | 1.01642 | NaN | NaN | NaN | NaN | 0.0550457 | -0.074889 | NaN | NaN | 0.926263 | 0.930322 | 0.00405893 | ST_LD01_OK_CANDIDATE | 群内Tsub効果は小さめ。PM_F1のTsub相関は群間差由来の可能性。ST-LD-01へ進む候補。 |
| Table12 | 28 | 0.879002 | 0.312561 | 0.929406 | 1.34712 | NaN | NaN | NaN | NaN | 0.00687891 | -0.0347092 | NaN | NaN | 0.929406 | 0.929892 | 0.000485606 | ST_LD01_OK_CANDIDATE | 群内Tsub効果は小さめ。PM_F1のTsub相関は群間差由来の可能性。ST-LD-01へ進む候補。 |


## 7. 判断フラグ

- tentative_flag: `CHECK_F1_EXTRAPOLATION`
- reading: 群内Tsub効果が残る可能性。L/D補正式前にST-HSUBまたはF1再フィット検討。

判定の読み方:

```text
ST_LD01_OK_CANDIDATE:
  群内Tsub効果は小さめ。
  PM_F1のTsub相関はshort/long群間差由来の可能性。
  ST-LD-01へ進む候補。

CHECK_F1_EXTRAPOLATION:
  群内Tsub効果が残る可能性。
  L/D補正式候補の前にST-HSUBまたはF1再フィットを検討。

BORDERLINE:
  中間的。図、Table別、群別傾きを見て判断。
```

## 8. Figures

- `fig_STLD00_v3_01_PM_F1_vs_Tsub_by_LDgroup_20260618_153049.png`
- `fig_STLD00_v3_02_group_mean_PM_Tsub_LD_20260618_153049.png`
- `fig_STLD00_v3_03_within_PM_vs_within_Tsub_20260618_153049.png`
- `fig_STLD00_v3_04_model_R2_decomposition_20260618_153049.png`

## 9. 次アクション

```text
1. primary_summary / primary_group_slopes / primary_model_compareを確認する。
2. 群内Tsub傾きが小さければ、ST-LD-01へ進む。
3. 群内Tsub傾きが残るなら、ST-HSUBまたはF1再フィット検討へ進む。
4. 判断をworking_log r36へ追記する。
```
