# ST-LD-00C F1 active/stuck reinterpretation

作成日時: 2026-06-19 09:18:27

## 1. 目的

ST-F1-00で確認したF1_fixedの効き幅・張り付き結果を踏まえ、ST-LD-00の読みを再解釈する。

このrunでは補正式を作らない。F1 active / weak / stuck 領域別に、PM_F1、L/D group、群内Tsub成分を分けて見る。

## 2. 入力

- input_file: `H52Q_current_single_tube_input_v1_20260615_183839.xlsx`
- noF1_sheet: `ST_noF1_T8_14_current`
- F1_sheet: `ST_F1_T8_14_current`

## 3. F1_fixed definition and regimes

```text
F1_fixed(Tsub) = 1 + A * exp( - (Tsub - T0)^2 / sigma )
A     = 0.053
T0    = 40 K
sigma = 5625
active_ge_1pct   : F1 - 1 >= 0.01
weak_0p1_to_1pct : 0.001 < F1 - 1 < 0.01
stuck_le_0p1pct  : F1 - 1 <= 0.001
```

## 4. Primary summary: Table9-12

| dataset | N | PM_noF1_mean | PM_F1_mean | abs_err_noF1_mean | abs_err_F1_mean | delta_abs_err_mean | improved_N | worsened_N | improved_frac | worsened_frac | before_under_N | before_over_N | before_under_improved_N | before_under_worsened_N | before_over_improved_N | before_over_worsened_N | F1_fixed_mean | F1_minus_1_mean | F1_minus_1_min | F1_minus_1_max | Tsub_mean | Tsub_min | Tsub_max | LD_mean | LD_min | LD_max | R2_PM_Tsub | slope_PM_per_100K | R2_PM_LD | slope_PM_per_LD | R2_PM_F1minus1 | slope_PM_per_F1minus1 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| primary_T9_12_all | 171 | 0.879947 | 1.14047 | 0.336033 | 0.18867 | -0.147363 | 118 | 53 | 0.690058 | 0.309942 | 114 | 57 | 93 | 21 | 25 | 32 | 1.02883 | 0.0288319 | 1.70616e-08 | 0.0528553 | 114.961 | 5.85325 | 329.979 | 0.317017 | 0.150114 | 0.69596 | 0.684518 | 0.22011 | 0.326092 | 0.766796 | 0.406875 | -8.8958 |


## 5. Reference summary: Table8-14

| dataset | N | PM_noF1_mean | PM_F1_mean | abs_err_noF1_mean | abs_err_F1_mean | delta_abs_err_mean | improved_N | worsened_N | improved_frac | worsened_frac | before_under_N | before_over_N | before_under_improved_N | before_under_worsened_N | before_over_improved_N | before_over_worsened_N | F1_fixed_mean | F1_minus_1_mean | F1_minus_1_min | F1_minus_1_max | Tsub_mean | Tsub_min | Tsub_max | LD_mean | LD_min | LD_max | R2_PM_Tsub | slope_PM_per_100K | R2_PM_LD | slope_PM_per_LD | R2_PM_F1minus1 | slope_PM_per_F1minus1 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| reference_T8_14_all | 224 | 0.918631 | 1.15328 | 0.347837 | 0.227568 | -0.120269 | 155 | 69 | 0.691964 | 0.308036 | 145 | 79 | 121 | 24 | 34 | 45 | 1.02785 | 0.0278524 | 7.23302e-09 | 0.0528553 | 119.936 | 5.85325 | 338.187 | 0.397878 | 0.150114 | 1.524 | 0.664787 | 0.277263 | 0.000370933 | 0.0174223 | 0.3751 | -11.0039 |


## 6. By Table

| group_type | group | N | PM_noF1_mean | PM_F1_mean | abs_err_noF1_mean | abs_err_F1_mean | delta_abs_err_mean | improved_N | worsened_N | improved_frac | worsened_frac | before_under_N | before_over_N | before_under_improved_N | before_under_worsened_N | before_over_improved_N | before_over_worsened_N | F1_fixed_mean | F1_minus_1_mean | F1_minus_1_min | F1_minus_1_max | Tsub_mean | Tsub_min | Tsub_max | LD_mean | LD_min | LD_max |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Table | T9 | 29 | 1.07062 | 1.21841 | 0.177766 | 0.219342 | 0.0415753 | 13 | 16 | 0.448276 | 0.551724 | 15 | 14 | 6 | 9 | 7 | 7 | 1.01936 | 0.0193599 | 2.23326e-07 | 0.0488622 | 161.289 | 18.6168 | 303.859 | 0.321012 | 0.150114 | 0.69596 |
| Table | T10 | 86 | 0.604575 | 0.998391 | 0.408222 | 0.0937419 | -0.31448 | 70 | 16 | 0.813953 | 0.186047 | 77 | 9 | 70 | 7 | 0 | 9 | 1.03948 | 0.039479 | 1.92294e-05 | 0.0528553 | 59.1226 | 5.85325 | 251.09 | 0.309093 | 0.150114 | 0.59055 |
| Table | T11 | 28 | 1.16641 | 1.2763 | 0.271188 | 0.276805 | 0.00561683 | 19 | 9 | 0.678571 | 0.321429 | 11 | 17 | 10 | 1 | 9 | 8 | 1.01691 | 0.0169124 | 4.27247e-08 | 0.0454768 | 176.175 | 69.3451 | 320.935 | 0.327116 | 0.1524 | 0.69596 |
| Table | T12 | 28 | 1.24179 | 1.36033 | 0.343072 | 0.36033 | 0.0172587 | 16 | 12 | 0.571429 | 0.428571 | 11 | 17 | 7 | 4 | 9 | 8 | 1.01786 | 0.0178595 | 1.70616e-08 | 0.0440721 | 177.27 | 72.2121 | 329.979 | 0.327116 | 0.1524 | 0.69596 |


## 7. By F1 regime

| group_type | group | N | PM_noF1_mean | PM_F1_mean | abs_err_noF1_mean | abs_err_F1_mean | delta_abs_err_mean | improved_N | worsened_N | improved_frac | worsened_frac | before_under_N | before_over_N | before_under_improved_N | before_under_worsened_N | before_over_improved_N | before_over_worsened_N | F1_fixed_mean | F1_minus_1_mean | F1_minus_1_min | F1_minus_1_max | Tsub_mean | Tsub_min | Tsub_max | LD_mean | LD_min | LD_max |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| F1_regime | active_ge_1pct | 127 | 0.697276 | 1.04391 | 0.309623 | 0.108498 | -0.201126 | 91 | 36 | 0.716535 | 0.283465 | 109 | 18 | 91 | 18 | 0 | 18 | 1.03805 | 0.0380549 | 0.0113693 | 0.0528553 | 66.3059 | 5.85325 | 133.054 | 0.253289 | 0.150114 | 0.59055 |
| F1_regime | weak_0p1_to_1pct | 15 | 1.03824 | 1.0732 | 0.0530734 | 0.0757644 | 0.022691 | 2 | 13 | 0.133333 | 0.866667 | 5 | 10 | 2 | 3 | 0 | 10 | 1.00643 | 0.00643292 | 0.00100532 | 0.00894276 | 150.673 | 140.047 | 189.342 | 0.174413 | 0.1524 | 0.3175 |
| F1_regime | stuck_le_0p1pct | 29 | 1.59804 | 1.59817 | 0.598044 | 0.598167 | 0.000122563 | 25 | 4 | 0.862069 | 0.137931 | 0 | 29 | 0 | 0 | 25 | 4 | 1.00003 | 2.69654e-05 | 1.70616e-08 | 0.000759307 | 309.567 | 194.537 | 329.979 | 0.669859 | 0.3175 | 0.69596 |


## 8. By Table and F1 regime

| group_type | group | N | PM_noF1_mean | PM_F1_mean | abs_err_noF1_mean | abs_err_F1_mean | delta_abs_err_mean | improved_N | worsened_N | improved_frac | worsened_frac | before_under_N | before_over_N | before_under_improved_N | before_under_worsened_N | before_over_improved_N | before_over_worsened_N | F1_fixed_mean | F1_minus_1_mean | F1_minus_1_min | F1_minus_1_max | Tsub_mean | Tsub_min | Tsub_max | LD_mean | LD_min | LD_max |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Table_F1_regime | T9_active_ge_1pct | 17 | 0.917339 | 1.1609 | 0.0925551 | 0.160898 | 0.0683433 | 5 | 12 | 0.294118 | 0.705882 | 13 | 4 | 5 | 8 | 0 | 4 | 1.03146 | 0.0314582 | 0.0166971 | 0.0488622 | 91.3852 | 18.6168 | 120.605 | 0.152266 | 0.150114 | 0.1524 |
| Table_F1_regime | T10_active_ge_1pct | 81 | 0.574929 | 0.992034 | 0.428074 | 0.0932708 | -0.334803 | 70 | 11 | 0.864198 | 0.135802 | 76 | 5 | 70 | 6 | 0 | 5 | 1.04177 | 0.0417718 | 0.0113693 | 0.0528553 | 51.0774 | 5.85325 | 133.054 | 0.310612 | 0.150114 | 0.59055 |
| Table_F1_regime | T11_active_ge_1pct | 14 | 0.901928 | 1.10962 | 0.106822 | 0.109801 | 0.00297925 | 9 | 5 | 0.642857 | 0.357143 | 10 | 4 | 9 | 1 | 0 | 4 | 1.03141 | 0.0314066 | 0.0166227 | 0.0454768 | 94.2923 | 69.3451 | 120.761 | 0.1524 | 0.1524 | 0.1524 |
| Table_F1_regime | T12_weak_0p1_to_1pct | 4 | 1.07291 | 1.10565 | 0.0778617 | 0.10565 | 0.0277883 | 0 | 4 | 0 | 1 | 1 | 3 | 0 | 1 | 0 | 3 | 1.00627 | 0.00627318 | 0.00588771 | 0.00671108 | 149.583 | 147.816 | 151.178 | 0.1524 | 0.1524 | 0.1524 |
| Table_F1_regime | T10_weak_0p1_to_1pct | 3 | 1.05761 | 1.07824 | 0.0605752 | 0.078238 | 0.0176629 | 0 | 3 | 0 | 1 | 1 | 2 | 0 | 1 | 0 | 2 | 1.00363 | 0.00363425 | 0.00100532 | 0.00623019 | 167.217 | 149.738 | 189.342 | 0.262467 | 0.1524 | 0.3175 |
| Table_F1_regime | T10_stuck_le_0p1pct | 2 | 1.12569 | 1.13608 | 0.125685 | 0.136078 | 0.0103929 | 0 | 2 | 0 | 1 | 0 | 2 | 0 | 0 | 0 | 2 | 1.00039 | 0.000389268 | 1.92294e-05 | 0.000759307 | 222.814 | 194.537 | 251.09 | 0.3175 | 0.3175 | 0.3175 |
| Table_F1_regime | T9_weak_0p1_to_1pct | 3 | 0.980316 | 1.03319 | 0.0231287 | 0.0422201 | 0.0190914 | 1 | 2 | 0.333333 | 0.666667 | 2 | 1 | 1 | 1 | 0 | 1 | 1.00888 | 0.00888121 | 0.00875811 | 0.00894276 | 140.242 | 140.047 | 140.632 | 0.1524 | 0.1524 | 0.1524 |
| Table_F1_regime | T11_weak_0p1_to_1pct | 5 | 1.03363 | 1.06821 | 0.0467086 | 0.0704983 | 0.0237897 | 1 | 4 | 0.2 | 0.8 | 1 | 4 | 1 | 0 | 0 | 4 | 1.00677 | 0.00677095 | 0.00528939 | 0.0081069 | 147.878 | 142.769 | 153.857 | 0.1524 | 0.1524 | 0.1524 |
| Table_F1_regime | T12_active_ge_1pct | 15 | 0.917539 | 1.13012 | 0.105284 | 0.130118 | 0.024834 | 7 | 8 | 0.466667 | 0.533333 | 10 | 5 | 7 | 3 | 0 | 5 | 1.03166 | 0.0316649 | 0.0158846 | 0.0440721 | 93.9957 | 72.2121 | 122.327 | 0.1524 | 0.1524 | 0.1524 |
| Table_F1_regime | T9_stuck_le_0p1pct | 9 | 1.39027 | 1.38878 | 0.390267 | 0.388775 | -0.00149177 | 7 | 2 | 0.777778 | 0.222222 | 0 | 9 | 0 | 0 | 7 | 2 | 1 | 3.13347e-07 | 2.23326e-07 | 3.93585e-07 | 300.346 | 297.748 | 303.859 | 0.69596 | 0.69596 | 0.69596 |
| Table_F1_regime | T11_stuck_le_0p1pct | 9 | 1.65158 | 1.6512 | 0.65158 | 0.651204 | -0.000376303 | 9 | 0 | 1 | 0 | 0 | 9 | 0 | 0 | 9 | 0 | 1 | 5.07639e-08 | 4.27247e-08 | 5.93793e-08 | 319.268 | 317.62 | 320.935 | 0.69596 | 0.69596 | 0.69596 |
| Table_F1_regime | T12_stuck_le_0p1pct | 9 | 1.85725 | 1.85721 | 0.857255 | 0.857208 | -4.65278e-05 | 9 | 0 | 1 | 0 | 0 | 9 | 0 | 0 | 9 | 0 | 1 | 2.02595e-08 | 1.70616e-08 | 2.39753e-08 | 328.367 | 326.661 | 329.979 | 0.69596 | 0.69596 | 0.69596 |


## 9. By L/D group and F1 regime

| group_type | group | N | PM_noF1_mean | PM_F1_mean | abs_err_noF1_mean | abs_err_F1_mean | delta_abs_err_mean | improved_N | worsened_N | improved_frac | worsened_frac | before_under_N | before_over_N | before_under_improved_N | before_under_worsened_N | before_over_improved_N | before_over_worsened_N | F1_fixed_mean | F1_minus_1_mean | F1_minus_1_min | F1_minus_1_max | Tsub_mean | Tsub_min | Tsub_max | LD_mean | LD_min | LD_max |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| LDgroup_F1_regime | short_active_ge_1pct | 58 | 0.910317 | 1.14834 | 0.104593 | 0.148387 | 0.0437932 | 25 | 33 | 0.431034 | 0.568966 | 41 | 17 | 25 | 16 | 0 | 17 | 1.03226 | 0.0322637 | 0.0158846 | 0.0488622 | 91.2281 | 18.6168 | 122.327 | 0.152321 | 0.150114 | 0.1524 |
| LDgroup_F1_regime | short_weak_0p1_to_1pct | 13 | 1.03049 | 1.06788 | 0.0476014 | 0.0708473 | 0.0232459 | 2 | 11 | 0.153846 | 0.846154 | 5 | 8 | 2 | 3 | 0 | 8 | 1.00706 | 0.00706318 | 0.00528939 | 0.00894276 | 146.784 | 140.047 | 153.857 | 0.1524 | 0.1524 | 0.1524 |
| LDgroup_F1_regime | middle_active_ge_1pct | 61 | 0.522822 | 0.95179 | 0.477366 | 0.0784967 | -0.398869 | 58 | 3 | 0.95082 | 0.0491803 | 60 | 1 | 58 | 2 | 0 | 1 | 1.04178 | 0.0417788 | 0.0113693 | 0.0527632 | 47.4487 | 5.85325 | 133.054 | 0.30506 | 0.295275 | 0.3175 |
| LDgroup_F1_regime | middle_weak_0p1_to_1pct | 2 | 1.08864 | 1.10773 | 0.0886418 | 0.107726 | 0.0190839 | 0 | 2 | 0 | 1 | 0 | 2 | 0 | 0 | 0 | 2 | 1.00234 | 0.00233628 | 0.00100532 | 0.00366724 | 175.956 | 162.571 | 189.342 | 0.3175 | 0.3175 | 0.3175 |
| LDgroup_F1_regime | middle_stuck_le_0p1pct | 2 | 1.12569 | 1.13608 | 0.125685 | 0.136078 | 0.0103929 | 0 | 2 | 0 | 1 | 0 | 2 | 0 | 0 | 0 | 2 | 1.00039 | 0.000389268 | 1.92294e-05 | 0.000759307 | 222.814 | 194.537 | 251.09 | 0.3175 | 0.3175 | 0.3175 |
| LDgroup_F1_regime | long_active_ge_1pct | 8 | 0.482942 | 0.989177 | 0.517058 | 0.0480595 | -0.468998 | 8 | 0 | 1 | 0 | 8 | 0 | 8 | 0 | 0 | 0 | 1.05165 | 0.0516464 | 0.0502655 | 0.0528553 | 29.4052 | 22.7382 | 36.0779 | 0.59055 | 0.59055 | 0.59055 |
| LDgroup_F1_regime | long_stuck_le_0p1pct | 27 | 1.63303 | 1.6324 | 0.633034 | 0.632396 | -0.0006382 | 25 | 2 | 0.925926 | 0.0740741 | 0 | 27 | 0 | 0 | 25 | 2 | 1 | 1.28124e-07 | 1.70616e-08 | 3.93585e-07 | 315.994 | 297.748 | 329.979 | 0.69596 | 0.69596 | 0.69596 |


## 10. By Table, L/D group, and F1 regime

| group_type | group | N | PM_noF1_mean | PM_F1_mean | abs_err_noF1_mean | abs_err_F1_mean | delta_abs_err_mean | improved_N | worsened_N | improved_frac | worsened_frac | before_under_N | before_over_N | before_under_improved_N | before_under_worsened_N | before_over_improved_N | before_over_worsened_N | F1_fixed_mean | F1_minus_1_mean | F1_minus_1_min | F1_minus_1_max | Tsub_mean | Tsub_min | Tsub_max | LD_mean | LD_min | LD_max |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Table_LDgroup_F1regime | T9_short_active_ge_1pct | 17 | 0.917339 | 1.1609 | 0.0925551 | 0.160898 | 0.0683433 | 5 | 12 | 0.294118 | 0.705882 | 13 | 4 | 5 | 8 | 0 | 4 | 1.03146 | 0.0314582 | 0.0166971 | 0.0488622 | 91.3852 | 18.6168 | 120.605 | 0.152266 | 0.150114 | 0.1524 |
| Table_LDgroup_F1regime | T10_short_active_ge_1pct | 12 | 0.901128 | 1.19851 | 0.118185 | 0.198514 | 0.080329 | 4 | 8 | 0.333333 | 0.666667 | 8 | 4 | 4 | 4 | 0 | 4 | 1.03515 | 0.0351533 | 0.018431 | 0.0488622 | 83.9714 | 18.6168 | 117.081 | 0.15221 | 0.150114 | 0.1524 |
| Table_LDgroup_F1regime | T11_short_active_ge_1pct | 14 | 0.901928 | 1.10962 | 0.106822 | 0.109801 | 0.00297925 | 9 | 5 | 0.642857 | 0.357143 | 10 | 4 | 9 | 1 | 0 | 4 | 1.03141 | 0.0314066 | 0.0166227 | 0.0454768 | 94.2923 | 69.3451 | 120.761 | 0.1524 | 0.1524 | 0.1524 |
| Table_LDgroup_F1regime | T12_short_weak_0p1_to_1pct | 4 | 1.07291 | 1.10565 | 0.0778617 | 0.10565 | 0.0277883 | 0 | 4 | 0 | 1 | 1 | 3 | 0 | 1 | 0 | 3 | 1.00627 | 0.00627318 | 0.00588771 | 0.00671108 | 149.583 | 147.816 | 151.178 | 0.1524 | 0.1524 | 0.1524 |
| Table_LDgroup_F1regime | T10_short_weak_0p1_to_1pct | 1 | 0.995558 | 1.01926 | 0.00444195 | 0.0192628 | 0.0148209 | 0 | 1 | 0 | 1 | 1 | 0 | 0 | 1 | 0 | 0 | 1.00623 | 0.00623019 | 0.00623019 | 0.00623019 | 149.738 | 149.738 | 149.738 | 0.1524 | 0.1524 | 0.1524 |
| Table_LDgroup_F1regime | T10_middle_active_ge_1pct | 61 | 0.522822 | 0.95179 | 0.477366 | 0.0784967 | -0.398869 | 58 | 3 | 0.95082 | 0.0491803 | 60 | 1 | 58 | 2 | 0 | 1 | 1.04178 | 0.0417788 | 0.0113693 | 0.0527632 | 47.4487 | 5.85325 | 133.054 | 0.30506 | 0.295275 | 0.3175 |
| Table_LDgroup_F1regime | T10_middle_weak_0p1_to_1pct | 2 | 1.08864 | 1.10773 | 0.0886418 | 0.107726 | 0.0190839 | 0 | 2 | 0 | 1 | 0 | 2 | 0 | 0 | 0 | 2 | 1.00234 | 0.00233628 | 0.00100532 | 0.00366724 | 175.956 | 162.571 | 189.342 | 0.3175 | 0.3175 | 0.3175 |
| Table_LDgroup_F1regime | T10_middle_stuck_le_0p1pct | 2 | 1.12569 | 1.13608 | 0.125685 | 0.136078 | 0.0103929 | 0 | 2 | 0 | 1 | 0 | 2 | 0 | 0 | 0 | 2 | 1.00039 | 0.000389268 | 1.92294e-05 | 0.000759307 | 222.814 | 194.537 | 251.09 | 0.3175 | 0.3175 | 0.3175 |
| Table_LDgroup_F1regime | T10_long_active_ge_1pct | 8 | 0.482942 | 0.989177 | 0.517058 | 0.0480595 | -0.468998 | 8 | 0 | 1 | 0 | 8 | 0 | 8 | 0 | 0 | 0 | 1.05165 | 0.0516464 | 0.0502655 | 0.0528553 | 29.4052 | 22.7382 | 36.0779 | 0.59055 | 0.59055 | 0.59055 |
| Table_LDgroup_F1regime | T9_short_weak_0p1_to_1pct | 3 | 0.980316 | 1.03319 | 0.0231287 | 0.0422201 | 0.0190914 | 1 | 2 | 0.333333 | 0.666667 | 2 | 1 | 1 | 1 | 0 | 1 | 1.00888 | 0.00888121 | 0.00875811 | 0.00894276 | 140.242 | 140.047 | 140.632 | 0.1524 | 0.1524 | 0.1524 |
| Table_LDgroup_F1regime | T11_short_weak_0p1_to_1pct | 5 | 1.03363 | 1.06821 | 0.0467086 | 0.0704983 | 0.0237897 | 1 | 4 | 0.2 | 0.8 | 1 | 4 | 1 | 0 | 0 | 4 | 1.00677 | 0.00677095 | 0.00528939 | 0.0081069 | 147.878 | 142.769 | 153.857 | 0.1524 | 0.1524 | 0.1524 |
| Table_LDgroup_F1regime | T12_short_active_ge_1pct | 15 | 0.917539 | 1.13012 | 0.105284 | 0.130118 | 0.024834 | 7 | 8 | 0.466667 | 0.533333 | 10 | 5 | 7 | 3 | 0 | 5 | 1.03166 | 0.0316649 | 0.0158846 | 0.0440721 | 93.9957 | 72.2121 | 122.327 | 0.1524 | 0.1524 | 0.1524 |
| Table_LDgroup_F1regime | T9_long_stuck_le_0p1pct | 9 | 1.39027 | 1.38878 | 0.390267 | 0.388775 | -0.00149177 | 7 | 2 | 0.777778 | 0.222222 | 0 | 9 | 0 | 0 | 7 | 2 | 1 | 3.13347e-07 | 2.23326e-07 | 3.93585e-07 | 300.346 | 297.748 | 303.859 | 0.69596 | 0.69596 | 0.69596 |
| Table_LDgroup_F1regime | T11_long_stuck_le_0p1pct | 9 | 1.65158 | 1.6512 | 0.65158 | 0.651204 | -0.000376303 | 9 | 0 | 1 | 0 | 0 | 9 | 0 | 0 | 9 | 0 | 1 | 5.07639e-08 | 4.27247e-08 | 5.93793e-08 | 319.268 | 317.62 | 320.935 | 0.69596 | 0.69596 | 0.69596 |
| Table_LDgroup_F1regime | T12_long_stuck_le_0p1pct | 9 | 1.85725 | 1.85721 | 0.857255 | 0.857208 | -4.65278e-05 | 9 | 0 | 1 | 0 | 0 | 9 | 0 | 0 | 9 | 0 | 1 | 2.02595e-08 | 1.70616e-08 | 2.39753e-08 | 328.367 | 326.661 | 329.979 | 0.69596 | 0.69596 | 0.69596 |


## 11. Model compare: primary

| dataset | model | N | k | R2 | RMSE |
| --- | --- | --- | --- | --- | --- |
| primary_T9_12_all | PM_F1 ~ Tsub | 171 | 2 | 0.684518 | 0.146087 |
| primary_T9_12_all | PM_F1 ~ L/D | 171 | 2 | 0.326092 | 0.213513 |
| primary_T9_12_all | PM_F1 ~ F1_minus_1 | 171 | 2 | 0.406875 | 0.200308 |
| primary_T9_12_all | PM_F1 ~ LD_group | 171 | 3 | 0.538679 | 0.176655 |
| primary_T9_12_all | PM_F1 ~ LD_group + Tsub | 171 | 4 | 0.725699 | 0.136219 |
| primary_T9_12_all | PM_F1 ~ LD_group + F1_minus_1 | 171 | 4 | 0.623221 | 0.15965 |


## 12. Model compare: by F1 regime

| dataset | model | N | k | R2 | RMSE |
| --- | --- | --- | --- | --- | --- |
| regime_active_ge_1pct | PM_F1 ~ Tsub | 127 | 2 | 0.179818 | 0.130561 |
| regime_active_ge_1pct | PM_F1 ~ L/D | 127 | 2 | 0.250365 | 0.12482 |
| regime_active_ge_1pct | PM_F1 ~ F1_minus_1 | 127 | 2 | 0.0681582 | 0.139165 |
| regime_active_ge_1pct | PM_F1 ~ LD_group | 127 | 3 | 0.444844 | 0.107415 |
| regime_active_ge_1pct | PM_F1 ~ LD_group + Tsub | 127 | 4 | 0.447475 | 0.107161 |
| regime_active_ge_1pct | PM_F1 ~ LD_group + F1_minus_1 | 127 | 4 | 0.446145 | 0.107289 |
| regime_weak_0p1_to_1pct | PM_F1 ~ Tsub | 15 | 2 | 0.0843118 | 0.0503879 |
| regime_weak_0p1_to_1pct | PM_F1 ~ L/D | 15 | 2 | 0.066159 | 0.0508849 |
| regime_weak_0p1_to_1pct | PM_F1 ~ F1_minus_1 | 15 | 2 | 0.104378 | 0.0498328 |
| regime_weak_0p1_to_1pct | PM_F1 ~ LD_group | 15 | 2 | 0.066159 | 0.0508849 |
| regime_weak_0p1_to_1pct | PM_F1 ~ LD_group + Tsub | 15 | 3 | 0.085034 | 0.0503681 |
| regime_weak_0p1_to_1pct | PM_F1 ~ LD_group + F1_minus_1 | 15 | 3 | 0.104405 | 0.049832 |
| regime_stuck_le_0p1pct | PM_F1 ~ Tsub | 29 | 2 | 0.658684 | 0.135476 |
| regime_stuck_le_0p1pct | PM_F1 ~ L/D | 29 | 2 | 0.294136 | 0.194825 |
| regime_stuck_le_0p1pct | PM_F1 ~ F1_minus_1 | 29 | 2 | 0.173486 | 0.210819 |
| regime_stuck_le_0p1pct | PM_F1 ~ LD_group | 29 | 2 | 0.294136 | 0.194825 |
| regime_stuck_le_0p1pct | PM_F1 ~ LD_group + Tsub | 29 | 3 | 0.764029 | 0.112645 |
| regime_stuck_le_0p1pct | PM_F1 ~ LD_group + F1_minus_1 | 29 | 3 | 0.295992 | 0.194569 |


## 13. Within decomposition: primary

| dataset | N | R2_within_PM_Tsub | slope_within_PM_per_100K | R2_group_only | R2_group_plus_TsubWithin | delta_R2_TsubWithin_afterGroup | reading |
| --- | --- | --- | --- | --- | --- | --- | --- |
| primary_T9_12_all | 171 | 0.405402 | 0.168876 | 0.538679 | 0.725699 | 0.18702 | within_Tsub_remaining |


## 14. Within decomposition: by F1 regime

| dataset | N | R2_within_PM_Tsub | slope_within_PM_per_100K | R2_group_only | R2_group_plus_TsubWithin | delta_R2_TsubWithin_afterGroup | reading |
| --- | --- | --- | --- | --- | --- | --- | --- |
| regime_active_ge_1pct | 127 | 0.00473853 | 0.0236541 | 0.444844 | 0.447475 | 0.00263062 | within_Tsub_small |
| regime_weak_0p1_to_1pct | 15 | 0.0202122 | 0.110652 | 0.066159 | 0.085034 | 0.018875 | borderline |
| regime_stuck_le_0p1pct | 29 | 0.665699 | 1.17303 | 0.294136 | 0.764029 | 0.469893 | within_Tsub_remaining |


## 15. Within decomposition: by Table

| dataset | N | R2_within_PM_Tsub | slope_within_PM_per_100K | R2_group_only | R2_group_plus_TsubWithin | delta_R2_TsubWithin_afterGroup | reading |
| --- | --- | --- | --- | --- | --- | --- | --- |
| T9 | 29 | 0.522278 | -0.345363 | 0.482914 | 0.752977 | 0.270063 | within_Tsub_remaining |
| T10 | 86 | 0.165945 | 0.0881909 | 0.366423 | 0.471563 | 0.105139 | within_Tsub_remaining |
| T11 | 28 | 0.0550457 | -0.074889 | 0.926263 | 0.930322 | 0.00405893 | within_Tsub_small |
| T12 | 28 | 0.00687891 | -0.0347092 | 0.929406 | 0.929892 | 0.000485606 | within_Tsub_small |


## 16. Automatic reading guide

```text
1. active_ge_1pctでPM_noF1<1が多く改善している場合、F1は過小側持ち上げとして効いている。
2. active_ge_1pctでPM_noF1>1が悪化している場合、片方向補正の副作用として読む。
3. stuck_le_0p1pctでPM_F1差が残る場合、それはF1が補正した結果ではなく、F1がほぼ効いていない元構造として読む。
4. stuck領域でL/D group差が見えても、直ちにL/D補正式へは進まない。
5. ST-LD-01へ進む前に、active/stuckで同じ向きの残差構造が再現するかを見る。
```

## 17. Figures

- `fig_STLD00C_v1_01_PM_F1_vs_Tsub_regime_20260619_091814.png`
- `fig_STLD00C_v1_02_PM_F1_vs_LD_regime_20260619_091814.png`
- `fig_STLD00C_v1_03_error_by_table_regime_20260619_091814.png`
- `fig_STLD00C_v1_04_within_Tsub_by_regime_20260619_091814.png`

## 18. 次アクション

```text
1. by_F1_regime を確認する。
2. by_table_regime と by_table_LD_regime で、Table11/12 longがstuck側にあるか確認する。
3. within_by_regime で、F1 active側とstuck側の群内Tsub成分を確認する。
4. ST-LD-00のTable11/12判定を、F1が効いて消えたのか、F1が効いていない領域の元構造なのかに分けて再解釈する。
5. 判断をworking_log r38へ追記する。
```
