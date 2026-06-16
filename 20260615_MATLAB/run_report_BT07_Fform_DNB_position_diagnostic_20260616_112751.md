# BT07 F_form / DNB position diagnostic

作成日時: 20260616

## 1. 目的

BT06で、F1後のPM_F1残差はTsub/x_eq側ではなく、F_form・DNB位置・L/DH・ケース構造側に残っている可能性が高いと整理した。BT07では、F_formを補正式候補にするのではなく、F_formが何を代表しているかを確認する。

## 2. 入力と出力

- 入力: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`
- 出力Excel: `BT07_Fform_DNB_position_diagnostic_20260616_112751.xlsx`

## 3. 前提

- r8 resultブックは直接読まない。
- current_bundle_inputを読む。
- F2/F1F2は使わない。
- 比較対象はnoF1とF1のみ。
- F1(Tsub)は維持する。
- F1(Tsub)をF(x_eq)へ置換しない。
- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。
- BT07では補正式を作らない。

## 4. Reconstructability check

current_bundle_inputだけでF_formを青面積/オレンジ面積から再計算できるかを確認する。

| item | value |
| --- | --- |
| has_F_form_column, has_DNB_position_column, has_L_column, has_DH_column, has_raw_axial_power_profile_columns, matched_raw_profile_like_columns, BT07_reconstructability_reading | true, true, true, true, false, , current_bundle_inputにはF_form再計算に必要な軸方向出力分布元配列が見当たらない。BT07はF_form挙動診断であり、青面積/オレンジ面積の再計算監査ではない。 |

## 5. Case summary

| case_id | N | PM_noF1_mean | PM_noF1_sd | PM_noF1_se | PM_noF1_ci95_low | PM_noF1_ci95_high | PM_F1_mean | PM_F1_sd | PM_F1_se | PM_F1_ci95_low | PM_F1_ci95_high | err_F1_mean | err_F1_sd | err_F1_se | err_F1_ci95_low | err_F1_ci95_high | abs_err_F1_mean | abs_err_F1_sd | abs_err_F1_se | abs_err_F1_ci95_low | abs_err_F1_ci95_high | q_exp_MWm2_mean | q_exp_MWm2_sd | q_exp_MWm2_se | q_exp_MWm2_ci95_low | q_exp_MWm2_ci95_high | q_calc_F1_MWm2_mean | q_calc_F1_MWm2_sd | q_calc_F1_MWm2_se | q_calc_F1_MWm2_ci95_low | q_calc_F1_MWm2_ci95_high | delta_PM_mean | delta_PM_sd | delta_PM_se | delta_PM_ci95_low | delta_PM_ci95_high | lift_ratio_mean | lift_ratio_sd | lift_ratio_se | lift_ratio_ci95_low | lift_ratio_ci95_high | Tsub_K_mean | Tsub_K_sd | Tsub_K_se | Tsub_K_ci95_low | Tsub_K_ci95_high | Fcorr_mean | Fcorr_sd | Fcorr_se | Fcorr_ci95_low | Fcorr_ci95_high | x_eq_mean | x_eq_sd | x_eq_se | x_eq_ci95_low | x_eq_ci95_high | F_form_mean | F_form_sd | F_form_se | F_form_ci95_low | F_form_ci95_high | z_DNB_over_DH_mean | z_DNB_over_DH_sd | z_DNB_over_DH_se | z_DNB_over_DH_ci95_low | z_DNB_over_DH_ci95_high | z_DNB_over_L_mean | z_DNB_over_L_sd | z_DNB_over_L_se | z_DNB_over_L_ci95_low | z_DNB_over_L_ci95_high | L_over_DH_mean | L_over_DH_sd | L_over_DH_se | L_over_DH_ci95_low | L_over_DH_ci95_high | Tw_minus_Tsat_K_mean | Tw_minus_Tsat_K_sd | Tw_minus_Tsat_K_se | Tw_minus_Tsat_K_ci95_low | Tw_minus_Tsat_K_ci95_high | Tm_minus_Tsat_K_mean | Tm_minus_Tsat_K_sd | Tm_minus_Tsat_K_se | Tm_minus_Tsat_K_ci95_low | Tm_minus_Tsat_K_ci95_high | PM_F1_div_Fform_DIAG_ONLY_mean | PM_F1_div_Fform_DIAG_ONLY_sd | PM_F1_div_Fform_DIAG_ONLY_se | PM_F1_div_Fform_DIAG_ONLY_ci95_low | PM_F1_div_Fform_DIAG_ONLY_ci95_high | PM_F1_times_Fform_DIAG_ONLY_mean | PM_F1_times_Fform_DIAG_ONLY_sd | PM_F1_times_Fform_DIAG_ONLY_se | PM_F1_times_Fform_DIAG_ONLY_ci95_low | PM_F1_times_Fform_DIAG_ONLY_ci95_high |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | 14 | 0.621831 | 0.111232 | 0.0297279 | 0.563564 | 0.680097 | 1.06679 | 0.0580947 | 0.0155265 | 1.03636 | 1.09722 | 0.0667888 | 0.0580947 | 0.0155265 | 0.0363569 | 0.0972206 | 0.0718408 | 0.0511934 | 0.013682 | 0.0450241 | 0.0986575 | 3.03625 | 0.248877 | 0.0665152 | 2.90588 | 3.16662 | 3.23576 | 0.276934 | 0.0740137 | 3.0907 | 3.38083 | 0.444958 | 0.106084 | 0.0283521 | 0.389388 | 0.500528 | 1.76502 | 0.315514 | 0.0843247 | 1.59975 | 1.9303 | 46.0838 | 16.4092 | 4.38554 | 37.4882 | 54.6795 | 1.04382 | 0.00305646 | 0.000816874 | 1.04222 | 1.04542 | -0.0139909 | 0.0533628 | 0.0142618 | -0.0419441 | 0.0139623 | 0.669495 | 0.0385528 | 0.0103037 | 0.649299 | 0.68969 | 139.659 | 4.29443 | 1.14773 | 137.409 | 141.908 | 0.738216 | 0.0226998 | 0.00606677 | 0.726325 | 0.750107 | 189.184 | 2.94946e-14 | 7.88276e-15 | 189.184 | 189.184 | 38.4377 | 11 | 2.93989 | 32.6755 | 44.1999 | -6.60519 | 8.31953 | 2.22349 | -10.9632 | -2.24716 | 1.5961 | 0.094818 | 0.0253412 | 1.54643 | 1.64576 | 0.715079 | 0.0685831 | 0.0183296 | 0.679153 | 0.751005 |
| 161 | 23 | 0.62098 | 0.165839 | 0.0345797 | 0.553204 | 0.688757 | 0.908841 | 0.0951175 | 0.0198334 | 0.869967 | 0.947714 | -0.0911591 | 0.0951175 | 0.0198334 | -0.130033 | -0.0522857 | 0.0975897 | 0.0881952 | 0.01839 | 0.0615454 | 0.133634 | 1.4136 | 0.265937 | 0.0554516 | 1.30491 | 1.52228 | 1.29514 | 0.313911 | 0.0654549 | 1.16685 | 1.42343 | 0.28786 | 0.126478 | 0.0263725 | 0.23617 | 0.339551 | 1.55271 | 0.368396 | 0.0768159 | 1.40215 | 1.70327 | 63.8439 | 29.5582 | 6.16331 | 51.7638 | 75.924 | 1.03744 | 0.00980728 | 0.00204496 | 1.03343 | 1.04145 | -0.0823228 | 0.13147 | 0.0274134 | -0.136053 | -0.0285926 | 1 | 0 | 0 | 1 | 1 | 361.355 | 1.16242e-13 | 2.42381e-14 | 361.355 | 361.355 | 0.997071 | 1.13517e-16 | 2.367e-17 | 0.997071 | 0.997071 | 362.417 | 5.8121e-14 | 1.21191e-14 | 362.417 | 362.417 | 25.7316 | 10.5819 | 2.20647 | 21.4069 | 30.0563 | 1.51983 | 13.9945 | 2.91806 | -4.19956 | 7.23922 | 0.908841 | 0.0951175 | 0.0198334 | 0.869967 | 0.947714 | 0.908841 | 0.0951175 | 0.0198334 | 0.869967 | 0.947714 |
| 164 | 21 | 0.570923 | 0.157352 | 0.034337 | 0.503623 | 0.638224 | 0.892018 | 0.102851 | 0.022444 | 0.848028 | 0.936008 | -0.107982 | 0.102851 | 0.022444 | -0.151972 | -0.0639917 | 0.109608 | 0.101029 | 0.0220463 | 0.0663976 | 0.152819 | 1.18876 | 0.228245 | 0.0498072 | 1.09114 | 1.28638 | 1.06698 | 0.256473 | 0.0559669 | 0.957289 | 1.17668 | 0.321095 | 0.112573 | 0.0245654 | 0.272947 | 0.369243 | 1.6679 | 0.413703 | 0.0902773 | 1.49095 | 1.84484 | 54.9549 | 25.1314 | 5.48413 | 44.206 | 65.7038 | 1.04041 | 0.00662273 | 0.0014452 | 1.03758 | 1.04324 | -0.155278 | 0.145518 | 0.0317546 | -0.217517 | -0.0930388 | 1.34638 | 0.076158 | 0.016619 | 1.31381 | 1.37895 | 286.824 | 10.357 | 2.26007 | 282.394 | 291.254 | 0.79142 | 0.0285775 | 0.00623612 | 0.779198 | 0.803643 | 362.417 | 5.82472e-14 | 1.27106e-14 | 362.417 | 362.417 | 27.4893 | 11.3148 | 2.46909 | 22.6499 | 32.3287 | 1.85786 | 12.4909 | 2.72575 | -3.4846 | 7.20032 | 0.662738 | 0.0674192 | 0.0147121 | 0.633903 | 0.691574 | 1.20437 | 0.170464 | 0.0371983 | 1.13146 | 1.27728 |

## 6. F_form and DNB position map

| case_id | N | F_form_mean | F_form_min | F_form_max | z_DNB_over_L_mean | z_DNB_over_L_min | z_DNB_over_L_max | z_DNB_over_DH_mean | z_DNB_over_DH_min | z_DNB_over_DH_max | L_over_DH_mean | L_over_DH_min | L_over_DH_max | PM_F1_mean | PM_F1_min | PM_F1_max | err_F1_mean | err_F1_min | err_F1_max | q_exp_MWm2_mean | q_exp_MWm2_min | q_exp_MWm2_max | q_calc_F1_MWm2_mean | q_calc_F1_MWm2_min | q_calc_F1_MWm2_max | x_eq_mean | x_eq_min | x_eq_max | Tsub_K_mean | Tsub_K_min | Tsub_K_max | Fform_class_mode | DNBpos_class_mode | Fform_physical_reading |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | 14 | 0.669495 | 0.654328 | 0.760494 | 0.738216 | 0.729286 | 0.791797 | 139.659 | 137.969 | 149.795 | 189.184 | 189.184 | 189.184 | 1.06679 | 0.970505 | 1.14582 | 0.0667888 | -0.0294947 | 0.145821 | 3.03625 | 2.61941 | 3.47599 | 3.23576 | 2.67436 | 3.591 | -0.0139909 | -0.0942051 | 0.0695054 | 46.0838 | 22.2634 | 78.5114 | Fform_lt_0p90 | zL_lt_0p80 | F_form<1: DNB位置の局所熱流束が上流平均より高い側にある可能性。出力分布形状確認が必要。 |
| 161 | 23 | 1 | 1 | 1 | 0.997071 | 0.997071 | 0.997071 | 361.355 | 361.355 | 361.355 | 362.417 | 362.417 | 362.417 | 0.908841 | 0.718839 | 1.0358 | -0.0911591 | -0.281161 | 0.0358021 | 1.4136 | 0.934295 | 1.8026 | 1.29514 | 0.671608 | 1.77269 | -0.0823228 | -0.400012 | 0.108004 | 63.8439 | 22.2226 | 119.263 | Fform_near_1 | zL_ge_0p95 | F_form≈1: DNB位置局所値と上流平均が近い、または一様加熱相当。 |
| 164 | 21 | 1.34638 | 1.014 | 1.363 | 0.79142 | 0.666698 | 0.797656 | 286.824 | 241.623 | 289.084 | 362.417 | 362.417 | 362.417 | 0.892018 | 0.665928 | 1.00667 | -0.107982 | -0.334072 | 0.00666768 | 1.18876 | 0.762405 | 1.52775 | 1.06698 | 0.507707 | 1.46528 | -0.155278 | -0.495474 | 0.0954344 | 54.9549 | 19.7781 | 110.814 | Fform_gt_1p10 | zL_lt_0p80 | F_form>1: DNB位置の局所熱流束が上流平均より低い側にある可能性。出口寄り/下降側か要確認。 |

## 7. 108 versus mean(161,164)

| name | value_108 | value_161 | value_164 | mean_161_164 | delta_108_minus_mean_161_164 | ratio_108_over_mean_161_164 |
| --- | --- | --- | --- | --- | --- | --- |
| PM_F1 | 1.06679 | 0.908841 | 0.892018 | 0.900429 | 0.166359 | 1.18476 |
| err_F1 | 0.0667888 | -0.0911591 | -0.107982 | -0.0995705 | 0.166359 | -0.670769 |
| abs_err_F1 | 0.0718408 | 0.0975897 | 0.109608 | 0.103599 | -0.0317582 | 0.693451 |
| F_form | 0.669495 | 1 | 1.34638 | 1.17319 | -0.503696 | 0.570661 |
| z_DNB_over_L | 0.738216 | 0.997071 | 0.79142 | 0.894245 | -0.156029 | 0.825519 |
| z_DNB_over_DH | 139.659 | 361.355 | 286.824 | 324.09 | -184.431 | 0.430926 |
| L_over_DH | 189.184 | 362.417 | 362.417 | 362.417 | -173.233 | 0.522007 |
| Tsub_K | 46.0838 | 63.8439 | 54.9549 | 59.3994 | -13.3156 | 0.77583 |
| x_eq | -0.0139909 | -0.0823228 | -0.155278 | -0.1188 | 0.104809 | 0.117768 |
| q_exp_MWm2 | 3.03625 | 1.4136 | 1.18876 | 1.30118 | 1.73507 | 2.33346 |
| q_calc_F1_MWm2 | 3.23576 | 1.29514 | 1.06698 | 1.18106 | 2.0547 | 2.73971 |

## 8. Point-level correlations

点群相関は探索的診断であり、補正式係数ではない。

| level | response | axis | N | pearson_r | slope | intercept | R2 | note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| point_level | PM_F1 | L_over_DH | 58 | -0.624516 | -0.000958115 | 1.24805 | 0.39002 |  |
| point_level | PM_F1 | Tw_minus_Tsat_K | 58 | 0.586971 | 0.00563953 | 0.774876 | 0.344535 |  |
| point_level | PM_F1 | z_DNB_over_DH | 58 | -0.533305 | -0.000703351 | 1.13842 | 0.284414 |  |
| point_level | PM_F1 | F_form | 58 | -0.489712 | -0.210416 | 1.16089 | 0.239818 |  |
| point_level | PM_F1 | Tm_minus_Tsat_K | 58 | -0.488316 | -0.00444357 | 0.939458 | 0.238452 |  |
| point_level | PM_F1 | z_DNB_over_L | 58 | -0.2799 | -0.277799 | 1.17982 | 0.0783443 |  |
| point_level | PM_F1 | x_eq | 58 | -0.196273 | -0.168968 | 0.925289 | 0.0385229 |  |
| point_level | PM_F1 | Tsub_K | 58 | 0.140778 | 0.000624172 | 0.90571 | 0.0198185 |  |
| point_level | abs_err_F1 | Tw_minus_Tsat_K | 58 | -0.435187 | -0.00313394 | 0.187974 | 0.189387 |  |
| point_level | abs_err_F1 | x_eq | 58 | 0.416689 | 0.268872 | 0.120528 | 0.17363 |  |
| point_level | abs_err_F1 | Tm_minus_Tsat_K | 58 | 0.397951 | 0.00271425 | 0.0965918 | 0.158365 |  |
| point_level | abs_err_F1 | Tsub_K | 58 | -0.324457 | -0.00107824 | 0.156473 | 0.105273 |  |
| point_level | abs_err_F1 | L_over_DH | 58 | 0.158056 | 0.00018175 | 0.0374566 | 0.0249817 |  |
| point_level | abs_err_F1 | F_form | 58 | 0.116423 | 0.0374942 | 0.0565207 | 0.0135542 |  |
| point_level | abs_err_F1 | z_DNB_over_DH | 58 | 0.103414 | 0.000102227 | 0.0670149 | 0.0106944 |  |
| point_level | abs_err_F1 | z_DNB_over_L | 58 | 0.0119759 | 0.00890891 | 0.0880632 | 0.000143422 |  |
| point_level | delta_PM | Tsub_K | 58 | -0.910592 | -0.00460428 | 0.597212 | 0.829178 |  |
| point_level | delta_PM | x_eq | 58 | 0.73919 | 0.725721 | 0.404757 | 0.546402 |  |
| point_level | delta_PM | Tm_minus_Tsat_K | 58 | 0.607427 | 0.00630369 | 0.339825 | 0.368968 |  |
| point_level | delta_PM | Tw_minus_Tsat_K | 58 | -0.482333 | -0.00528497 | 0.493377 | 0.232645 |  |
| point_level | delta_PM | z_DNB_over_DH | 58 | -0.476117 | -0.000716109 | 0.538938 | 0.226687 |  |
| point_level | delta_PM | L_over_DH | 58 | -0.465985 | -0.000815295 | 0.599199 | 0.217142 |  |
| point_level | delta_PM | z_DNB_over_L | 58 | -0.369976 | -0.418764 | 0.698005 | 0.136882 |  |
| point_level | delta_PM | F_form | 58 | -0.317899 | -0.155774 | 0.500697 | 0.101059 |  |
| point_level | err_F1 | L_over_DH | 58 | -0.624516 | -0.000958115 | 0.248049 | 0.39002 |  |
| point_level | err_F1 | Tw_minus_Tsat_K | 58 | 0.586971 | 0.00563953 | -0.225124 | 0.344535 |  |
| point_level | err_F1 | z_DNB_over_DH | 58 | -0.533305 | -0.000703351 | 0.138416 | 0.284414 |  |
| point_level | err_F1 | F_form | 58 | -0.489712 | -0.210416 | 0.160894 | 0.239818 |  |
| point_level | err_F1 | Tm_minus_Tsat_K | 58 | -0.488316 | -0.00444357 | -0.0605422 | 0.238452 |  |
| point_level | err_F1 | z_DNB_over_L | 58 | -0.2799 | -0.277799 | 0.179818 | 0.0783443 |  |
| point_level | err_F1 | x_eq | 58 | -0.196273 | -0.168968 | -0.074711 | 0.0385229 |  |
| point_level | err_F1 | Tsub_K | 58 | 0.140778 | 0.000624172 | -0.0942897 | 0.0198185 |  |
| point_level | lift_ratio | Tsub_K | 58 | -0.941441 | -0.0137256 | 2.41894 | 0.886311 |  |
| point_level | lift_ratio | x_eq | 58 | 0.790467 | 2.23767 | 1.85207 | 0.624839 |  |
| point_level | lift_ratio | Tm_minus_Tsat_K | 58 | 0.763805 | 0.0228551 | 1.65295 | 0.583398 |  |
| point_level | lift_ratio | Tw_minus_Tsat_K | 58 | -0.715611 | -0.0226085 | 2.31115 | 0.512099 |  |
| point_level | lift_ratio | z_DNB_over_L | 58 | -0.249102 | -0.812965 | 2.34492 | 0.0620516 |  |
| point_level | lift_ratio | z_DNB_over_DH | 58 | -0.235153 | -0.0010198 | 1.93208 | 0.0552968 |  |
| point_level | lift_ratio | L_over_DH | 58 | -0.180038 | -0.000908255 | 1.93685 | 0.0324139 |  |
| point_level | lift_ratio | F_form | 58 | -0.111762 | -0.157907 | 1.81078 | 0.0124908 |  |
| point_level | q_calc_F1_MWm2 | L_over_DH | 58 | -0.947776 | -0.011831 | 5.474 | 0.89828 |  |
| point_level | q_calc_F1_MWm2 | z_DNB_over_DH | 58 | -0.832558 | -0.00893413 | 4.19017 | 0.693153 |  |
| point_level | q_calc_F1_MWm2 | F_form | 58 | -0.815032 | -2.8494 | 4.66039 | 0.664278 |  |
| point_level | q_calc_F1_MWm2 | Tw_minus_Tsat_K | 58 | 0.598044 | 0.046752 | 0.304812 | 0.357656 |  |
| point_level | q_calc_F1_MWm2 | Tm_minus_Tsat_K | 58 | -0.490385 | -0.0363086 | 1.66938 | 0.240478 |  |
| point_level | q_calc_F1_MWm2 | z_DNB_over_L | 58 | -0.48061 | -3.88115 | 5.01925 | 0.230986 |  |
| point_level | q_calc_F1_MWm2 | x_eq | 58 | 0.128327 | 0.898883 | 1.76387 | 0.0164678 |  |
| point_level | q_calc_F1_MWm2 | Tsub_K | 58 | 0.0096062 | 0.000346547 | 1.66143 | 9.2279e-05 |  |
| point_level | q_exp_MWm2 | L_over_DH | 58 | -0.94301 | -0.00998635 | 4.92551 | 0.889268 |  |
| point_level | q_exp_MWm2 | F_form | 58 | -0.829369 | -2.45981 | 4.29593 | 0.687853 |  |
| point_level | q_exp_MWm2 | z_DNB_over_DH | 58 | -0.824886 | -0.00750942 | 3.83294 | 0.680436 |  |
| point_level | q_exp_MWm2 | Tw_minus_Tsat_K | 58 | 0.580927 | 0.0385269 | 0.589827 | 0.337476 |  |
| point_level | q_exp_MWm2 | Tm_minus_Tsat_K | 58 | -0.484243 | -0.0304167 | 1.71416 | 0.234492 |  |
| point_level | q_exp_MWm2 | z_DNB_over_L | 58 | -0.472785 | -3.23897 | 4.5098 | 0.223525 |  |
| point_level | q_exp_MWm2 | x_eq | 58 | 0.156063 | 0.927388 | 1.80941 | 0.0243558 |  |
| point_level | q_exp_MWm2 | Tsub_K | 58 | 0.0201992 | 0.000618187 | 1.68904 | 0.000408008 |  |

## 9. Axis-axis correlations

F_form、z_DNB/L、z_DNB/DH、L/DHの交絡を確認する。

| axis_1 | axis_2 | N | pearson_r | slope | intercept | R2 | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Tw_minus_Tsat_K | Tm_minus_Tsat_K | 58 | -0.948081 | -0.897947 | 29.1486 | 0.898858 |  |
| z_DNB_over_DH | L_over_DH | 58 | 0.923626 | 1.07442 | -63.6043 | 0.853086 |  |
| z_DNB_over_L | z_DNB_over_DH | 58 | 0.860414 | 0.00114335 | 0.539013 | 0.740313 |  |
| Tsub_K | x_eq | 58 | -0.838953 | -162.897 | 41.3123 | 0.703842 |  |
| Tsub_K | Tm_minus_Tsat_K | 58 | -0.829088 | -1.70162 | 55.7957 | 0.687387 |  |
| F_form | L_over_DH | 58 | 0.801604 | 0.00286218 | 0.128016 | 0.64257 |  |
| x_eq | Tm_minus_Tsat_K | 58 | 0.739017 | 0.00781162 | -0.0897518 | 0.546146 |  |
| Tsub_K | Tw_minus_Tsat_K | 58 | 0.711516 | 1.54185 | 10.9542 | 0.506256 |  |
| x_eq | Tw_minus_Tsat_K | 58 | -0.635887 | -0.00709679 | 0.11665 | 0.404353 |  |
| z_DNB_over_L | L_over_DH | 58 | 0.600131 | 0.00092767 | 0.562716 | 0.360157 |  |
| F_form | z_DNB_over_DH | 58 | 0.539854 | 0.00165705 | 0.580243 | 0.291442 |  |
| F_form | x_eq | 58 | -0.449453 | -0.900516 | 0.96257 | 0.202008 |  |
| L_over_DH | Tw_minus_Tsat_K | 58 | -0.429013 | -2.68672 | 399.686 | 0.184052 |  |
| z_DNB_over_DH | Tw_minus_Tsat_K | 58 | -0.411557 | -2.99819 | 369.109 | 0.169379 |  |
| L_over_DH | x_eq | 58 | -0.33413 | -187.493 | 303.307 | 0.111643 |  |
| z_DNB_over_L | Tw_minus_Tsat_K | 58 | -0.293078 | -0.00283715 | 0.943641 | 0.0858947 |  |
| F_form | Tw_minus_Tsat_K | 58 | -0.286669 | -0.00641017 | 1.23432 | 0.0821792 |  |
| L_over_DH | Tm_minus_Tsat_K | 58 | 0.283721 | 1.68286 | 321.139 | 0.0804973 |  |
| z_DNB_over_DH | Tsub_K | 58 | 0.276827 | 0.93064 | 228.426 | 0.0766334 |  |
| z_DNB_over_L | Tsub_K | 58 | 0.27545 | 0.00123051 | 0.790804 | 0.0758728 |  |
| z_DNB_over_DH | Tm_minus_Tsat_K | 58 | 0.24723 | 1.70583 | 281.401 | 0.0611225 |  |
| z_DNB_over_DH | x_eq | 58 | -0.236861 | -154.611 | 266.595 | 0.0561029 |  |
| L_over_DH | Tsub_K | 58 | 0.225509 | 0.651718 | 283.885 | 0.0508545 |  |
| F_form | Tm_minus_Tsat_K | 58 | 0.20931 | 0.00443286 | 1.04705 | 0.0438107 |  |
| z_DNB_over_L | Tm_minus_Tsat_K | 58 | 0.139811 | 0.00128188 | 0.860538 | 0.0195472 |  |
| F_form | Tsub_K | 58 | 0.122719 | 0.00126632 | 0.974294 | 0.0150599 |  |
| F_form | z_DNB_over_L | 58 | 0.0677707 | 0.156542 | 0.91099 | 0.00459287 |  |
| z_DNB_over_L | x_eq | 58 | -0.0526336 | -0.0456542 | 0.855918 | 0.00277029 |  |

## 10. Within-case correlations

ケース内の変動で同じ傾向が出るかを見る。F_formがケース固定に近い場合、点群相関はケース差を見ている可能性が高い。

| level | case_id | response | axis | N | pearson_r | slope | intercept | R2 | note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| within_case | 108 | PM_F1 | L_over_DH | 14 |  |  | 1.06679 |  | x_constant_or_nearly_constant |
| within_case | 108 | PM_F1 | x_eq | 14 | -0.57343 | -0.624278 | 1.05805 | 0.328822 |  |
| within_case | 108 | PM_F1 | F_form | 14 | 0.418323 | 0.630365 | 0.644763 | 0.174994 |  |
| within_case | 108 | PM_F1 | z_DNB_over_DH | 14 | 0.418323 | 0.00565904 | 0.276455 | 0.174994 |  |
| within_case | 108 | PM_F1 | z_DNB_over_L | 14 | 0.418323 | 1.0706 | 0.276455 | 0.174994 |  |
| within_case | 108 | PM_F1 | Tsub_K | 14 | 0.114228 | 0.00040441 | 1.04815 | 0.013048 |  |
| within_case | 108 | abs_err_F1 | L_over_DH | 14 |  |  | 0.0718408 |  | x_constant_or_nearly_constant |
| within_case | 108 | abs_err_F1 | x_eq | 14 | -0.497204 | -0.47699 | 0.0651673 | 0.247212 |  |
| within_case | 108 | abs_err_F1 | F_form | 14 | 0.432908 | 0.574848 | -0.313017 | 0.187409 |  |
| within_case | 108 | abs_err_F1 | z_DNB_over_L | 14 | 0.432908 | 0.97631 | -0.648887 | 0.187409 |  |
| within_case | 108 | abs_err_F1 | z_DNB_over_DH | 14 | 0.432908 | 0.00516064 | -0.648887 | 0.187409 |  |
| within_case | 108 | abs_err_F1 | Tsub_K | 14 | -4.79118e-05 | -1.49475e-07 | 0.0718477 | 2.29554e-09 |  |
| within_case | 108 | err_F1 | L_over_DH | 14 |  |  | 0.0667888 |  | x_constant_or_nearly_constant |
| within_case | 108 | err_F1 | x_eq | 14 | -0.57343 | -0.624278 | 0.0580545 | 0.328822 |  |
| within_case | 108 | err_F1 | F_form | 14 | 0.418323 | 0.630365 | -0.355237 | 0.174994 |  |
| within_case | 108 | err_F1 | z_DNB_over_L | 14 | 0.418323 | 1.0706 | -0.723545 | 0.174994 |  |
| within_case | 108 | err_F1 | z_DNB_over_DH | 14 | 0.418323 | 0.00565904 | -0.723545 | 0.174994 |  |
| within_case | 108 | err_F1 | Tsub_K | 14 | 0.114228 | 0.00040441 | 0.048152 | 0.013048 |  |
| within_case | 161 | PM_F1 | F_form | 23 |  |  | 0.908841 |  | x_constant_or_nearly_constant |
| within_case | 161 | PM_F1 | z_DNB_over_L | 23 |  |  | 0.908841 |  | x_constant_or_nearly_constant |
| within_case | 161 | PM_F1 | z_DNB_over_DH | 23 |  |  | 0.908841 |  | x_constant_or_nearly_constant |
| within_case | 161 | PM_F1 | L_over_DH | 23 |  |  | 0.908841 |  | x_constant_or_nearly_constant |
| within_case | 161 | PM_F1 | x_eq | 23 | -0.608379 | -0.440158 | 0.872606 | 0.370126 |  |
| within_case | 161 | PM_F1 | Tsub_K | 23 | 0.36339 | 0.00116938 | 0.834183 | 0.132052 |  |
| within_case | 161 | abs_err_F1 | F_form | 23 |  |  | 0.0975897 |  | x_constant_or_nearly_constant |
| within_case | 161 | abs_err_F1 | z_DNB_over_L | 23 |  |  | 0.0975897 |  | x_constant_or_nearly_constant |
| within_case | 161 | abs_err_F1 | z_DNB_over_DH | 23 |  |  | 0.0975897 |  | x_constant_or_nearly_constant |
| within_case | 161 | abs_err_F1 | L_over_DH | 23 |  |  | 0.0975897 |  | x_constant_or_nearly_constant |
| within_case | 161 | abs_err_F1 | x_eq | 23 | 0.622371 | 0.417511 | 0.13196 | 0.387346 |  |
| within_case | 161 | abs_err_F1 | Tsub_K | 23 | -0.387535 | -0.00115632 | 0.171414 | 0.150183 |  |
| within_case | 161 | err_F1 | F_form | 23 |  |  | -0.0911591 |  | x_constant_or_nearly_constant |
| within_case | 161 | err_F1 | z_DNB_over_L | 23 |  |  | -0.0911591 |  | x_constant_or_nearly_constant |
| within_case | 161 | err_F1 | z_DNB_over_DH | 23 |  |  | -0.0911591 |  | x_constant_or_nearly_constant |
| within_case | 161 | err_F1 | L_over_DH | 23 |  |  | -0.0911591 |  | x_constant_or_nearly_constant |
| within_case | 161 | err_F1 | x_eq | 23 | -0.608379 | -0.440158 | -0.127394 | 0.370126 |  |
| within_case | 161 | err_F1 | Tsub_K | 23 | 0.36339 | 0.00116938 | -0.165817 | 0.132052 |  |
| within_case | 164 | PM_F1 | L_over_DH | 21 |  |  | 0.892018 |  | x_constant_or_nearly_constant |
| within_case | 164 | PM_F1 | x_eq | 21 | -0.587491 | -0.415236 | 0.827541 | 0.345145 |  |
| within_case | 164 | PM_F1 | F_form | 21 | 0.452067 | 0.610515 | 0.070032 | 0.204365 |  |
| within_case | 164 | PM_F1 | z_DNB_over_L | 21 | 0.452067 | 1.627 | -0.395625 | 0.204365 |  |
| within_case | 164 | PM_F1 | z_DNB_over_DH | 21 | 0.452067 | 0.00448931 | -0.395625 | 0.204365 |  |
| within_case | 164 | PM_F1 | Tsub_K | 21 | 0.427771 | 0.00175067 | 0.795811 | 0.182988 |  |
| within_case | 164 | abs_err_F1 | L_over_DH | 21 |  |  | 0.109608 |  | x_constant_or_nearly_constant |
| within_case | 164 | abs_err_F1 | x_eq | 21 | 0.595761 | 0.413619 | 0.173834 | 0.354931 |  |
| within_case | 164 | abs_err_F1 | F_form | 21 | -0.456534 | -0.605622 | 0.925006 | 0.208423 |  |
| within_case | 164 | abs_err_F1 | z_DNB_over_L | 21 | -0.456534 | -1.61396 | 1.38693 | 0.208423 |  |
| within_case | 164 | abs_err_F1 | z_DNB_over_DH | 21 | -0.456534 | -0.00445333 | 1.38693 | 0.208423 |  |
| within_case | 164 | abs_err_F1 | Tsub_K | 21 | -0.438526 | -0.00176288 | 0.206487 | 0.192305 |  |
| within_case | 164 | err_F1 | L_over_DH | 21 |  |  | -0.107982 |  | x_constant_or_nearly_constant |
| within_case | 164 | err_F1 | x_eq | 21 | -0.587491 | -0.415236 | -0.172459 | 0.345145 |  |
| within_case | 164 | err_F1 | F_form | 21 | 0.452067 | 0.610515 | -0.929968 | 0.204365 |  |
| within_case | 164 | err_F1 | z_DNB_over_L | 21 | 0.452067 | 1.627 | -1.39562 | 0.204365 |  |
| within_case | 164 | err_F1 | z_DNB_over_DH | 21 | 0.452067 | 0.00448931 | -1.39562 | 0.204365 |  |
| within_case | 164 | err_F1 | Tsub_K | 21 | 0.427771 | 0.00175067 | -0.204189 | 0.182988 |  |

## 11. Case-mean correlations

N=3のケース平均相関であり、採用根拠ではない。ケース構造の強さを見せるための参考値。

| level | response | axis | N | pearson_r | slope | intercept | R2 | note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| case_mean_N3 | PM_F1 | L_over_DH | 3 | -0.996187 | -0.000960322 | 1.24847 | 0.992389 |  |
| case_mean_N3 | PM_F1 | z_DNB_over_DH | 3 | -0.911449 | -0.00077896 | 1.16045 | 0.83074 |  |
| case_mean_N3 | PM_F1 | F_form | 3 | -0.90054 | -0.256521 | 1.21376 | 0.810972 |  |
| case_mean_N3 | PM_F1 | x_eq | 3 | 0.898201 | 1.22566 | 1.05867 | 0.806766 |  |
| case_mean_N3 | PM_F1 | Tsub_K | 3 | -0.818767 | -0.00888976 | 1.44447 | 0.670379 |  |
| case_mean_N3 | PM_F1 | z_DNB_over_L | 3 | -0.590833 | -0.416705 | 1.30685 | 0.349084 |  |
| case_mean_N3 | abs_err_F1 | F_form | 3 | 0.975803 | 0.0556271 | 0.0370914 | 0.952191 |  |
| case_mean_N3 | abs_err_F1 | x_eq | 3 | -0.974619 | -0.266156 | 0.0706921 | 0.949883 |  |
| case_mean_N3 | abs_err_F1 | L_over_DH | 3 | 0.950266 | 0.000183327 | 0.0371583 | 0.903006 |  |
| case_mean_N3 | abs_err_F1 | z_DNB_over_DH | 3 | 0.794048 | 0.000135811 | 0.0573473 | 0.630512 |  |
| case_mean_N3 | abs_err_F1 | Tsub_K | 3 | 0.6668 | 0.00144887 | 0.0133817 | 0.444622 |  |
| case_mean_N3 | abs_err_F1 | z_DNB_over_L | 3 | 0.391938 | 0.0553205 | 0.04642 | 0.153616 |  |
| case_mean_N3 | err_F1 | L_over_DH | 3 | -0.996187 | -0.000960322 | 0.248466 | 0.992389 |  |
| case_mean_N3 | err_F1 | z_DNB_over_DH | 3 | -0.911449 | -0.00077896 | 0.160447 | 0.83074 |  |
| case_mean_N3 | err_F1 | F_form | 3 | -0.90054 | -0.256521 | 0.213761 | 0.810972 |  |
| case_mean_N3 | err_F1 | x_eq | 3 | 0.898201 | 1.22566 | 0.0586711 | 0.806766 |  |
| case_mean_N3 | err_F1 | Tsub_K | 3 | -0.818767 | -0.00888976 | 0.444471 | 0.670379 |  |
| case_mean_N3 | err_F1 | z_DNB_over_L | 3 | -0.590833 | -0.416705 | 0.306846 | 0.349084 |  |

## 12. F_form class summary

| Fform_class | N | cases | PM_F1_mean | PM_F1_sd | err_F1_mean | err_F1_sd | F_form_mean | F_form_sd | z_DNB_over_L_mean | z_DNB_over_L_sd | z_DNB_over_DH_mean | z_DNB_over_DH_sd | L_over_DH_mean | L_over_DH_sd | q_exp_MWm2_mean | q_exp_MWm2_sd | q_calc_F1_MWm2_mean | q_calc_F1_MWm2_sd |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Fform_gt_1p10 | 20 | 164 | 0.902164 | 0.094125 | -0.0978357 | 0.094125 | 1.363 | 2.27813e-16 | 0.797656 | 0 | 289.084 | 5.83201e-14 | 362.417 | 5.83201e-14 | 1.19129 | 0.233871 | 1.08112 | 0.254603 |
| Fform_lt_0p90 | 14 | 108 | 1.06679 | 0.0580947 | 0.0667888 | 0.0580947 | 0.669495 | 0.0385528 | 0.738216 | 0.0226998 | 139.659 | 4.29443 | 189.184 | 2.94946e-14 | 3.03625 | 0.248877 | 3.23576 | 0.276934 |
| Fform_near_1 | 24 | 161,164 | 0.899685 | 0.103276 | -0.100315 | 0.103276 | 1.00058 | 0.00285774 | 0.983305 | 0.067437 | 356.366 | 24.4403 | 362.417 | 5.8066e-14 | 1.40212 | 0.266101 | 1.27385 | 0.324239 |

## 13. Interpretation flags

| item | status | value | reading |
| --- | --- | --- | --- |
| BT07_position | OK |  | F_form定義・非一様加熱換算・DNB位置の扱い確認。補正式化ではない。 |
| Fform_reconstructability | diagnostic | false | current_bundle_inputだけでF_formを再計算できるかを確認。raw profileが無ければ挙動診断に留める。 |
| Fform_case_pattern | diagnostic | Fform: 108=0.669495, 161=1, 164=1.34638 / zDNB_L: 108=0.738216, 161=0.997071, 164=0.79142 | F_formはケースで大きく異なる。z_DNB/Lだけでは単純に読めない可能性がある。 |
| Fform_PM_relation | diagnostic | PM_F1 vs F_form R2=0.239818 | F_formはPM_F1と中程度に対応するが、原因とは断定しない。 |
| Fform_position_confounding | diagnostic | Fform-zL R2=0.00459287, Fform-zDNB_DH R2=0.291442, Fform-LDH R2=0.64257, zDNB_DH-LDH R2=0.853086 | F_form、DNB位置、L/DHは交絡する。特にL/DHは多くのケース構造を代表しうる。 |
| Fform_not_F1 | hold |  | F_formはF1ではない。F1の効き方として読まず、非一様加熱換算として読む。 |
| Fform_cause_judgement | hold |  | F_form原因説には進まない。F_formはDNB位置・軸方向出力分布・局所熱流束基準換算の複合診断項として保留する。 |
| LDH_formula_judgement | reject_formula |  | PM_F1残差とL/DHが対応しても、単管・BT04・BT06の流れからL/DH補正式には戻らない。 |
| recommended_next | next |  | F_form作成元または軸方向出力分布を確認できるなら、青面積/オレンジ面積の再計算監査へ進む。無ければ、PM_F1残差は非一様加熱換算/DNB位置/ケース構造の診断課題として残す。 |

## 14. 次アクション

1. BT07_interpretation_flagsを確認する。
2. F_formを原因として採用できるかではなく、F_formがDNB位置・軸方向出力分布・L/DHのどれを代理しているかを読む。
3. current_bundle_inputだけでF_formを再計算できない場合は、F_form作成元または軸方向出力分布データを確認する。
4. F_form定義・DNB位置・局所熱流束基準に矛盾がなければ、PM_F1残差は補正式化せず、非一様加熱換算/DNB位置/ケース構造の診断課題として残す。
5. 単管側ST-BT05相当は、別タスクとして後で実施する。
