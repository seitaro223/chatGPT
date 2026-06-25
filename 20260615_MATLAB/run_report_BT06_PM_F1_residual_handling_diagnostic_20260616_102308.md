# BT06 PM_F1 residual handling diagnostic

作成日時: 20260616

## 1. 目的

BT05で、x_eqはTsubに対する追加説明力が小さく、F1(Tsub)をF(x_eq)へ置換する根拠は弱いと判断した。BT06では、F1(Tsub)をいったん維持したうえで、F1後に残るPM_F1残差を、F_form、DNB位置、z_DNB/DH、z_DNB/L、L/DH、ケース構造、適用範囲のどれとして扱うべきかを整理した。

## 2. 入力と出力

- 入力: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`
- 出力Excel: `BT06_PM_F1_residual_handling_diagnostic_20260616_102308.xlsx`

## 3. 前提

- r8 resultブックは直接読まない。
- current_bundle_inputを読む。
- F2/F1F2は使わない。
- 比較対象はnoF1とF1のみ。
- F1(Tsub)は維持する。
- F1(Tsub)をF(x_eq)へ置換しない。
- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。
- 補正式は作らない。
- R2が高いモデルをそのまま採用しない。

## 4. Case summary

| case_id | N | PM_noF1_mean | PM_noF1_sd | PM_noF1_se | PM_noF1_ci95_low | PM_noF1_ci95_high | PM_F1_mean | PM_F1_sd | PM_F1_se | PM_F1_ci95_low | PM_F1_ci95_high | err_F1_mean | err_F1_sd | err_F1_se | err_F1_ci95_low | err_F1_ci95_high | abs_err_F1_mean | abs_err_F1_sd | abs_err_F1_se | abs_err_F1_ci95_low | abs_err_F1_ci95_high | delta_PM_mean | delta_PM_sd | delta_PM_se | delta_PM_ci95_low | delta_PM_ci95_high | lift_ratio_mean | lift_ratio_sd | lift_ratio_se | lift_ratio_ci95_low | lift_ratio_ci95_high | q_exp_MWm2_mean | q_exp_MWm2_sd | q_exp_MWm2_se | q_exp_MWm2_ci95_low | q_exp_MWm2_ci95_high | q_calc_F1_MWm2_mean | q_calc_F1_MWm2_sd | q_calc_F1_MWm2_se | q_calc_F1_MWm2_ci95_low | q_calc_F1_MWm2_ci95_high | Tsub_K_mean | Tsub_K_sd | Tsub_K_se | Tsub_K_ci95_low | Tsub_K_ci95_high | Fcorr_mean | Fcorr_sd | Fcorr_se | Fcorr_ci95_low | Fcorr_ci95_high | x_eq_mean | x_eq_sd | x_eq_se | x_eq_ci95_low | x_eq_ci95_high | F_form_mean | F_form_sd | F_form_se | F_form_ci95_low | F_form_ci95_high | z_DNB_over_DH_mean | z_DNB_over_DH_sd | z_DNB_over_DH_se | z_DNB_over_DH_ci95_low | z_DNB_over_DH_ci95_high | z_DNB_over_L_mean | z_DNB_over_L_sd | z_DNB_over_L_se | z_DNB_over_L_ci95_low | z_DNB_over_L_ci95_high | L_over_DH_mean | L_over_DH_sd | L_over_DH_se | L_over_DH_ci95_low | L_over_DH_ci95_high | Tw_minus_Tsat_K_mean | Tw_minus_Tsat_K_sd | Tw_minus_Tsat_K_se | Tw_minus_Tsat_K_ci95_low | Tw_minus_Tsat_K_ci95_high | Tm_minus_Tsat_K_mean | Tm_minus_Tsat_K_sd | Tm_minus_Tsat_K_se | Tm_minus_Tsat_K_ci95_low | Tm_minus_Tsat_K_ci95_high |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | 14 | 0.621831 | 0.111232 | 0.0297279 | 0.563564 | 0.680097 | 1.06679 | 0.0580947 | 0.0155265 | 1.03636 | 1.09722 | 0.0667888 | 0.0580947 | 0.0155265 | 0.0363569 | 0.0972206 | 0.0718408 | 0.0511934 | 0.013682 | 0.0450241 | 0.0986575 | 0.444958 | 0.106084 | 0.0283521 | 0.389388 | 0.500528 | 1.76502 | 0.315514 | 0.0843247 | 1.59975 | 1.9303 | 3.03625 | 0.248877 | 0.0665152 | 2.90588 | 3.16662 | 3.23576 | 0.276934 | 0.0740137 | 3.0907 | 3.38083 | 46.0838 | 16.4092 | 4.38554 | 37.4882 | 54.6795 | 1.04382 | 0.00305646 | 0.000816874 | 1.04222 | 1.04542 | -0.0139909 | 0.0533628 | 0.0142618 | -0.0419441 | 0.0139623 | 0.669495 | 0.0385528 | 0.0103037 | 0.649299 | 0.68969 | 139.659 | 4.29443 | 1.14773 | 137.409 | 141.908 | 0.738216 | 0.0226998 | 0.00606677 | 0.726325 | 0.750107 | 189.184 | 2.94946e-14 | 7.88276e-15 | 189.184 | 189.184 | 38.4377 | 11 | 2.93989 | 32.6755 | 44.1999 | -6.60519 | 8.31953 | 2.22349 | -10.9632 | -2.24716 |
| 161 | 23 | 0.62098 | 0.165839 | 0.0345797 | 0.553204 | 0.688757 | 0.908841 | 0.0951175 | 0.0198334 | 0.869967 | 0.947714 | -0.0911591 | 0.0951175 | 0.0198334 | -0.130033 | -0.0522857 | 0.0975897 | 0.0881952 | 0.01839 | 0.0615454 | 0.133634 | 0.28786 | 0.126478 | 0.0263725 | 0.23617 | 0.339551 | 1.55271 | 0.368396 | 0.0768159 | 1.40215 | 1.70327 | 1.4136 | 0.265937 | 0.0554516 | 1.30491 | 1.52228 | 1.29514 | 0.313911 | 0.0654549 | 1.16685 | 1.42343 | 63.8439 | 29.5582 | 6.16331 | 51.7638 | 75.924 | 1.03744 | 0.00980728 | 0.00204496 | 1.03343 | 1.04145 | -0.0823228 | 0.13147 | 0.0274134 | -0.136053 | -0.0285926 | 1 | 0 | 0 | 1 | 1 | 361.355 | 1.16242e-13 | 2.42381e-14 | 361.355 | 361.355 | 0.997071 | 1.13517e-16 | 2.367e-17 | 0.997071 | 0.997071 | 362.417 | 5.8121e-14 | 1.21191e-14 | 362.417 | 362.417 | 25.7316 | 10.5819 | 2.20647 | 21.4069 | 30.0563 | 1.51983 | 13.9945 | 2.91806 | -4.19956 | 7.23922 |
| 164 | 21 | 0.570923 | 0.157352 | 0.034337 | 0.503623 | 0.638224 | 0.892018 | 0.102851 | 0.022444 | 0.848028 | 0.936008 | -0.107982 | 0.102851 | 0.022444 | -0.151972 | -0.0639917 | 0.109608 | 0.101029 | 0.0220463 | 0.0663976 | 0.152819 | 0.321095 | 0.112573 | 0.0245654 | 0.272947 | 0.369243 | 1.6679 | 0.413703 | 0.0902773 | 1.49095 | 1.84484 | 1.18876 | 0.228245 | 0.0498072 | 1.09114 | 1.28638 | 1.06698 | 0.256473 | 0.0559669 | 0.957289 | 1.17668 | 54.9549 | 25.1314 | 5.48413 | 44.206 | 65.7038 | 1.04041 | 0.00662273 | 0.0014452 | 1.03758 | 1.04324 | -0.155278 | 0.145518 | 0.0317546 | -0.217517 | -0.0930388 | 1.34638 | 0.076158 | 0.016619 | 1.31381 | 1.37895 | 286.824 | 10.357 | 2.26007 | 282.394 | 291.254 | 0.79142 | 0.0285775 | 0.00623612 | 0.779198 | 0.803643 | 362.417 | 5.82472e-14 | 1.27106e-14 | 362.417 | 362.417 | 27.4893 | 11.3148 | 2.46909 | 22.6499 | 32.3287 | 1.85786 | 12.4909 | 2.72575 | -3.4846 | 7.20032 |

## 5. 108 versus mean(161,164)

| name | value_108 | value_161 | value_164 | mean_161_164 | delta_108_minus_mean_161_164 | ratio_108_over_mean_161_164 |
| --- | --- | --- | --- | --- | --- | --- |
| PM_F1 | 1.06679 | 0.908841 | 0.892018 | 0.900429 | 0.166359 | 1.18476 |
| err_F1 | 0.0667888 | -0.0911591 | -0.107982 | -0.0995705 | 0.166359 | -0.670769 |
| abs_err_F1 | 0.0718408 | 0.0975897 | 0.109608 | 0.103599 | -0.0317582 | 0.693451 |
| delta_PM | 0.444958 | 0.28786 | 0.321095 | 0.304478 | 0.140481 | 1.46138 |
| lift_ratio | 1.76502 | 1.55271 | 1.6679 | 1.6103 | 0.154722 | 1.09608 |
| q_exp_MWm2 | 3.03625 | 1.4136 | 1.18876 | 1.30118 | 1.73507 | 2.33346 |
| q_calc_F1_MWm2 | 3.23576 | 1.29514 | 1.06698 | 1.18106 | 2.0547 | 2.73971 |
| F_form | 0.669495 | 1 | 1.34638 | 1.17319 | -0.503696 | 0.570661 |
| z_DNB_over_DH | 139.659 | 361.355 | 286.824 | 324.09 | -184.431 | 0.430926 |
| z_DNB_over_L | 0.738216 | 0.997071 | 0.79142 | 0.894245 | -0.156029 | 0.825519 |
| L_over_DH | 189.184 | 362.417 | 362.417 | 362.417 | -173.233 | 0.522007 |
| Tsub_K | 46.0838 | 63.8439 | 54.9549 | 59.3994 | -13.3156 | 0.77583 |
| Fcorr | 1.04382 | 1.03744 | 1.04041 | 1.03893 | 0.00489451 | 1.00471 |
| x_eq | -0.0139909 | -0.0823228 | -0.155278 | -0.1188 | 0.104809 | 0.117768 |

## 6. PM_F1 residual correlations

点群相関は探索的診断であり、補正式係数ではない。

| level | response | axis | axis_group | N | pearson_r | slope | intercept | R2 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| point_level | PM_F1 | F_form | nonuniform_heat | 58 | -0.489712 | -0.210416 | 1.16089 | 0.239818 |
| point_level | PM_F1 | z_DNB_over_DH | effective_history | 58 | -0.533305 | -0.000703351 | 1.13842 | 0.284414 |
| point_level | PM_F1 | z_DNB_over_L | relative_DNB_position | 58 | -0.2799 | -0.277799 | 1.17982 | 0.0783443 |
| point_level | PM_F1 | L_over_DH | geometry_length | 58 | -0.624516 | -0.000958115 | 1.24805 | 0.39002 |
| point_level | PM_F1 | Tsub_K | F1_Tsub | 58 | 0.140778 | 0.000624172 | 0.90571 | 0.0198185 |
| point_level | PM_F1 | Fcorr | F1_Tsub | 58 | 0.0787224 | 1.15696 | -0.262426 | 0.00619721 |
| point_level | PM_F1 | x_eq | thermal_state | 58 | -0.196273 | -0.168968 | 0.925289 | 0.0385229 |
| point_level | PM_F1 | Tw_minus_Tsat_K | model_internal | 58 | 0.586971 | 0.00563953 | 0.774876 | 0.344535 |
| point_level | PM_F1 | Tm_minus_Tsat_K | model_internal | 58 | -0.488316 | -0.00444357 | 0.939458 | 0.238452 |
| point_level | err_F1 | F_form | nonuniform_heat | 58 | -0.489712 | -0.210416 | 0.160894 | 0.239818 |
| point_level | err_F1 | z_DNB_over_DH | effective_history | 58 | -0.533305 | -0.000703351 | 0.138416 | 0.284414 |
| point_level | err_F1 | z_DNB_over_L | relative_DNB_position | 58 | -0.2799 | -0.277799 | 0.179818 | 0.0783443 |
| point_level | err_F1 | L_over_DH | geometry_length | 58 | -0.624516 | -0.000958115 | 0.248049 | 0.39002 |
| point_level | err_F1 | Tsub_K | F1_Tsub | 58 | 0.140778 | 0.000624172 | -0.0942897 | 0.0198185 |
| point_level | err_F1 | Fcorr | F1_Tsub | 58 | 0.0787224 | 1.15696 | -1.26243 | 0.00619721 |
| point_level | err_F1 | x_eq | thermal_state | 58 | -0.196273 | -0.168968 | -0.074711 | 0.0385229 |
| point_level | err_F1 | Tw_minus_Tsat_K | model_internal | 58 | 0.586971 | 0.00563953 | -0.225124 | 0.344535 |
| point_level | err_F1 | Tm_minus_Tsat_K | model_internal | 58 | -0.488316 | -0.00444357 | -0.0605422 | 0.238452 |
| point_level | abs_err_F1 | F_form | nonuniform_heat | 58 | 0.116423 | 0.0374942 | 0.0565207 | 0.0135542 |
| point_level | abs_err_F1 | z_DNB_over_DH | effective_history | 58 | 0.103414 | 0.000102227 | 0.0670149 | 0.0106944 |
| point_level | abs_err_F1 | z_DNB_over_L | relative_DNB_position | 58 | 0.0119759 | 0.00890891 | 0.0880632 | 0.000143422 |
| point_level | abs_err_F1 | L_over_DH | geometry_length | 58 | 0.158056 | 0.00018175 | 0.0374566 | 0.0249817 |
| point_level | abs_err_F1 | Tsub_K | F1_Tsub | 58 | -0.324457 | -0.00107824 | 0.156473 | 0.105273 |
| point_level | abs_err_F1 | Fcorr | F1_Tsub | 58 | 0.0910892 | 1.0034 | -0.94787 | 0.00829725 |
| point_level | abs_err_F1 | x_eq | thermal_state | 58 | 0.416689 | 0.268872 | 0.120528 | 0.17363 |
| point_level | abs_err_F1 | Tw_minus_Tsat_K | model_internal | 58 | -0.435187 | -0.00313394 | 0.187974 | 0.189387 |
| point_level | abs_err_F1 | Tm_minus_Tsat_K | model_internal | 58 | 0.397951 | 0.00271425 | 0.0965918 | 0.158365 |
| point_level | delta_PM | F_form | nonuniform_heat | 58 | -0.317899 | -0.155774 | 0.500697 | 0.101059 |
| point_level | delta_PM | z_DNB_over_DH | effective_history | 58 | -0.476117 | -0.000716109 | 0.538938 | 0.226687 |
| point_level | delta_PM | z_DNB_over_L | relative_DNB_position | 58 | -0.369976 | -0.418764 | 0.698005 | 0.136882 |
| point_level | delta_PM | L_over_DH | geometry_length | 58 | -0.465985 | -0.000815295 | 0.599199 | 0.217142 |
| point_level | delta_PM | Tsub_K | F1_Tsub | 58 | -0.910592 | -0.00460428 | 0.597212 | 0.829178 |
| point_level | delta_PM | Fcorr | F1_Tsub | 58 | 0.830428 | 13.9185 | -14.1382 | 0.689611 |
| point_level | delta_PM | x_eq | thermal_state | 58 | 0.73919 | 0.725721 | 0.404757 | 0.546402 |
| point_level | delta_PM | Tw_minus_Tsat_K | model_internal | 58 | -0.482333 | -0.00528497 | 0.493377 | 0.232645 |
| point_level | delta_PM | Tm_minus_Tsat_K | model_internal | 58 | 0.607427 | 0.00630369 | 0.339825 | 0.368968 |
| point_level | lift_ratio | F_form | nonuniform_heat | 58 | -0.111762 | -0.157907 | 1.81078 | 0.0124908 |
| point_level | lift_ratio | z_DNB_over_DH | effective_history | 58 | -0.235153 | -0.0010198 | 1.93208 | 0.0552968 |
| point_level | lift_ratio | z_DNB_over_L | relative_DNB_position | 58 | -0.249102 | -0.812965 | 2.34492 | 0.0620516 |
| point_level | lift_ratio | L_over_DH | geometry_length | 58 | -0.180038 | -0.000908255 | 1.93685 | 0.0324139 |
| point_level | lift_ratio | Tsub_K | F1_Tsub | 58 | -0.941441 | -0.0137256 | 2.41894 | 0.886311 |
| point_level | lift_ratio | Fcorr | F1_Tsub | 58 | 0.670311 | 32.394 | -32.0459 | 0.449316 |
| point_level | lift_ratio | x_eq | thermal_state | 58 | 0.790467 | 2.23767 | 1.85207 | 0.624839 |
| point_level | lift_ratio | Tw_minus_Tsat_K | model_internal | 58 | -0.715611 | -0.0226085 | 2.31115 | 0.512099 |
| point_level | lift_ratio | Tm_minus_Tsat_K | model_internal | 58 | 0.763805 | 0.0228551 | 1.65295 | 0.583398 |

## 7. Axis-axis correlations

F_form、z_DNB/DH、z_DNB/L、L/DHなどの交絡を確認する。

| axis_1 | axis_2 | group_1 | group_2 | N | pearson_r | slope | intercept | R2 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Tw_minus_Tsat_K | Tm_minus_Tsat_K | model_internal | model_internal | 58 | -0.948081 | -0.897947 | 29.1486 | 0.898858 |
| z_DNB_over_DH | L_over_DH | effective_history | geometry_length | 58 | 0.923626 | 1.07442 | -63.6043 | 0.853086 |
| Tsub_K | Fcorr | F1_Tsub | F1_Tsub | 58 | -0.878487 | -2911.97 | 3084.94 | 0.77174 |
| z_DNB_over_DH | z_DNB_over_L | effective_history | relative_DNB_position | 58 | 0.860414 | 647.497 | -276.074 | 0.740313 |
| Tsub_K | x_eq | F1_Tsub | thermal_state | 58 | -0.838953 | -162.897 | 41.3123 | 0.703842 |
| Tsub_K | Tm_minus_Tsat_K | F1_Tsub | model_internal | 58 | -0.829088 | -1.70162 | 55.7957 | 0.687387 |
| F_form | L_over_DH | nonuniform_heat | geometry_length | 58 | 0.801604 | 0.00286218 | 0.128016 | 0.64257 |
| x_eq | Tm_minus_Tsat_K | thermal_state | model_internal | 58 | 0.739017 | 0.00781162 | -0.0897518 | 0.546146 |
| Fcorr | Tm_minus_Tsat_K | F1_Tsub | model_internal | 58 | 0.730628 | 0.000452385 | 1.0402 | 0.533817 |
| Fcorr | x_eq | F1_Tsub | thermal_state | 58 | 0.727136 | 0.0425932 | 1.04398 | 0.528727 |
| Tsub_K | Tw_minus_Tsat_K | F1_Tsub | model_internal | 58 | 0.711516 | 1.54185 | 10.9542 | 0.506256 |
| x_eq | Tw_minus_Tsat_K | thermal_state | model_internal | 58 | -0.635887 | -0.00709679 | 0.11665 | 0.404353 |
| z_DNB_over_L | L_over_DH | relative_DNB_position | geometry_length | 58 | 0.600131 | 0.00092767 | 0.562716 | 0.360157 |
| F_form | z_DNB_over_DH | nonuniform_heat | effective_history | 58 | 0.539854 | 0.00165705 | 0.580243 | 0.291442 |
| Fcorr | Tw_minus_Tsat_K | F1_Tsub | model_internal | 58 | -0.53306 | -0.000348484 | 1.05031 | 0.284153 |
| F_form | x_eq | nonuniform_heat | thermal_state | 58 | -0.449453 | -0.900516 | 0.96257 | 0.202008 |
| L_over_DH | Tw_minus_Tsat_K | geometry_length | model_internal | 58 | -0.429013 | -2.68672 | 399.686 | 0.184052 |
| z_DNB_over_DH | Tw_minus_Tsat_K | effective_history | model_internal | 58 | -0.411557 | -2.99819 | 369.109 | 0.169379 |
| L_over_DH | x_eq | geometry_length | thermal_state | 58 | -0.33413 | -187.493 | 303.307 | 0.111643 |
| z_DNB_over_DH | Fcorr | effective_history | F1_Tsub | 58 | -0.318011 | -3543.77 | 3966.57 | 0.101131 |
| z_DNB_over_L | Fcorr | relative_DNB_position | F1_Tsub | 58 | -0.296565 | -4.3915 | 5.42754 | 0.087951 |
| z_DNB_over_L | Tw_minus_Tsat_K | relative_DNB_position | model_internal | 58 | -0.293078 | -0.00283715 | 0.943641 | 0.0858947 |
| F_form | Tw_minus_Tsat_K | nonuniform_heat | model_internal | 58 | -0.286669 | -0.00641017 | 1.23432 | 0.0821792 |
| L_over_DH | Tm_minus_Tsat_K | geometry_length | model_internal | 58 | 0.283721 | 1.68286 | 321.139 | 0.0804973 |
| z_DNB_over_DH | Tsub_K | effective_history | F1_Tsub | 58 | 0.276827 | 0.93064 | 228.426 | 0.0766334 |
| z_DNB_over_L | Tsub_K | relative_DNB_position | F1_Tsub | 58 | 0.27545 | 0.00123051 | 0.790804 | 0.0758728 |
| L_over_DH | Fcorr | geometry_length | F1_Tsub | 58 | -0.274396 | -2628.59 | 3054.48 | 0.0752929 |
| z_DNB_over_DH | Tm_minus_Tsat_K | effective_history | model_internal | 58 | 0.24723 | 1.70583 | 281.401 | 0.0611225 |
| z_DNB_over_DH | x_eq | effective_history | thermal_state | 58 | -0.236861 | -154.611 | 266.595 | 0.0561029 |
| L_over_DH | Tsub_K | geometry_length | F1_Tsub | 58 | 0.225509 | 0.651718 | 283.885 | 0.0508545 |
| F_form | Tm_minus_Tsat_K | nonuniform_heat | model_internal | 58 | 0.20931 | 0.00443286 | 1.04705 | 0.0438107 |
| z_DNB_over_L | Tm_minus_Tsat_K | relative_DNB_position | model_internal | 58 | 0.139811 | 0.00128188 | 0.860538 | 0.0195472 |
| F_form | Fcorr | nonuniform_heat | F1_Tsub | 58 | -0.128408 | -4.39212 | 5.61369 | 0.0164886 |
| F_form | Tsub_K | nonuniform_heat | F1_Tsub | 58 | 0.122719 | 0.00126632 | 0.974294 | 0.0150599 |
| F_form | z_DNB_over_L | nonuniform_heat | relative_DNB_position | 58 | 0.0677707 | 0.156542 | 0.91099 | 0.00459287 |
| z_DNB_over_L | x_eq | relative_DNB_position | thermal_state | 58 | -0.0526336 | -0.0456542 | 0.855918 | 0.00277029 |

## 8. Residualized correlations

err_F1 = PM_F1 - 1 を、Tsub/x_eqやF_form、z_DNB/DHで説明した後、残差がどの軸とまだ対応するかを見る。

| target | base_model | base_predictors | test_axis | N | pearson_r | slope | intercept | R2 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| err_F1 | after_Tsub | Tsub_K | F_form | 58 | -0.512088 | -0.217839 | 0.22778 | 0.262234 |
| err_F1 | after_Tsub | Tsub_K | z_DNB_over_DH | 58 | -0.578033 | -0.000754748 | 0.211976 | 0.334122 |
| err_F1 | after_Tsub | Tsub_K | z_DNB_over_L | 58 | -0.321883 | -0.316285 | 0.272046 | 0.103609 |
| err_F1 | after_Tsub | Tsub_K | L_over_DH | 58 | -0.662864 | -0.00100682 | 0.322788 | 0.439389 |
| err_F1 | after_Tsub | Tsub_K | Tsub_K | 58 | 5.25767e-18 | 2.1968e-20 | -6.37742e-19 | 0 |
| err_F1 | after_Tsub | Tsub_K | x_eq | 58 | -0.0789526 | -0.0672921 | -0.00620727 | 0.00623352 |
| err_F1 | after_Tsub_xeq | Tsub_K + x_eq | F_form | 58 | -0.610924 | -0.257133 | 0.268868 | 0.373228 |
| err_F1 | after_Tsub_xeq | Tsub_K + x_eq | z_DNB_over_DH | 58 | -0.585457 | -0.000756355 | 0.212427 | 0.34276 |
| err_F1 | after_Tsub_xeq | Tsub_K + x_eq | z_DNB_over_L | 58 | -0.277242 | -0.269538 | 0.231837 | 0.0768632 |
| err_F1 | after_Tsub_xeq | Tsub_K + x_eq | L_over_DH | 58 | -0.709004 | -0.00106551 | 0.341604 | 0.502687 |
| err_F1 | after_Tsub_xeq | Tsub_K + x_eq | Tsub_K | 58 | 7.78355e-17 | 1.11201e-19 | 8.9302e-19 | 0 |
| err_F1 | after_Tsub_xeq | Tsub_K + x_eq | x_eq | 58 | 1.00325e-17 | 2.60675e-17 | 1.14281e-17 | 0 |
| err_F1 | after_Fform | F_form | F_form | 58 | 1.03963e-16 | 1.0146e-17 | 4.29989e-17 | 0 |
| err_F1 | after_Fform | F_form | z_DNB_over_DH | 58 | -0.308449 | -0.000354681 | 0.0996147 | 0.0951407 |
| err_F1 | after_Fform | F_form | z_DNB_over_L | 58 | -0.282965 | -0.24486 | 0.210611 | 0.080069 |
| err_F1 | after_Fform | F_form | L_over_DH | 58 | -0.266045 | -0.000355867 | 0.114092 | 0.0707799 |
| err_F1 | after_Fform | F_form | Tsub_K | 58 | 0.230392 | 0.000890625 | -0.0501765 | 0.0530804 |
| err_F1 | after_Fform | F_form | x_eq | 58 | -0.477558 | -0.358451 | -0.0330648 | 0.228062 |
| err_F1 | after_zDNB_DH | z_DNB_over_DH | F_form | 58 | -0.238562 | -0.0867101 | 0.0906673 | 0.0569119 |
| err_F1 | after_zDNB_DH | z_DNB_over_DH | z_DNB_over_DH | 58 | 1.13881e-16 | 7.10371e-20 | 2.75754e-17 | 0 |
| err_F1 | after_zDNB_DH | z_DNB_over_DH | z_DNB_over_L | 58 | 0.211559 | 0.177619 | -0.152775 | 0.0447572 |
| err_F1 | after_zDNB_DH | z_DNB_over_DH | L_over_DH | 58 | -0.155973 | -0.000202421 | 0.0648965 | 0.0243277 |
| err_F1 | after_zDNB_DH | z_DNB_over_DH | Tsub_K | 58 | 0.340943 | 0.00127874 | -0.0720422 | 0.116242 |
| err_F1 | after_zDNB_DH | z_DNB_over_DH | x_eq | 58 | -0.381348 | -0.277714 | -0.0256173 | 0.145427 |
| err_F1 | after_LDH | L_over_DH | F_form | 58 | 0.0139595 | 0.0046845 | -0.00489829 | 0.000194866 |
| err_F1 | after_LDH | L_over_DH | z_DNB_over_DH | 58 | 0.0557154 | 5.73892e-05 | -0.0161181 | 0.00310421 |
| err_F1 | after_LDH | L_over_DH | z_DNB_over_L | 58 | 0.121497 | 0.0941783 | -0.0810055 | 0.0147616 |
| err_F1 | after_LDH | L_over_DH | L_over_DH | 58 | 3.536e-16 | 3.79804e-19 | -1.12353e-16 | 1.11022e-16 |
| err_F1 | after_LDH | L_over_DH | Tsub_K | 58 | 0.360573 | 0.00124859 | -0.0703439 | 0.130013 |
| err_F1 | after_LDH | L_over_DH | x_eq | 58 | -0.518483 | -0.348608 | -0.0321568 | 0.268825 |
| err_F1 | after_Fform_zDNB | F_form + z_DNB_over_DH | F_form | 58 | 2.47065e-17 | 3.73397e-17 | -5.30551e-17 | 0 |
| err_F1 | after_Fform_zDNB | F_form + z_DNB_over_DH | z_DNB_over_DH | 58 | 2.37922e-17 | 7.53794e-20 | -3.47764e-17 | 0 |
| err_F1 | after_Fform_zDNB | F_form + z_DNB_over_DH | z_DNB_over_L | 58 | 0.0813201 | 0.0654747 | -0.0563167 | 0.00661296 |
| err_F1 | after_Fform_zDNB | F_form + z_DNB_over_DH | L_over_DH | 58 | -0.0562707 | -7.00334e-05 | 0.0224528 | 0.00316639 |
| err_F1 | after_Fform_zDNB | F_form + z_DNB_over_DH | Tsub_K | 58 | 0.346136 | 0.00124499 | -0.0701407 | 0.11981 |
| err_F1 | after_Fform_zDNB | F_form + z_DNB_over_DH | x_eq | 58 | -0.510554 | -0.356562 | -0.0328906 | 0.260666 |
| err_F1 | after_Tsub_xeq_Fform | Tsub_K + x_eq + F_form | F_form | 58 | 8.50465e-16 | 2.28538e-16 | -2.42097e-16 | 0 |
| err_F1 | after_Tsub_xeq_Fform | Tsub_K + x_eq + F_form | z_DNB_over_DH | 58 | -0.0970023 | -7.47715e-05 | 0.0210001 | 0.00940944 |
| err_F1 | after_Tsub_xeq_Fform | Tsub_K + x_eq + F_form | z_DNB_over_L | 58 | -0.0357679 | -0.0207481 | 0.017846 | 0.00127935 |
| err_F1 | after_Tsub_xeq_Fform | Tsub_K + x_eq + F_form | L_over_DH | 58 | -0.120548 | -0.000108092 | 0.0346544 | 0.0145319 |
| err_F1 | after_Tsub_xeq_Fform | Tsub_K + x_eq + F_form | Tsub_K | 58 | -3.66798e-16 | -9.76269e-19 | 5.32595e-17 | 0 |
| err_F1 | after_Tsub_xeq_Fform | Tsub_K + x_eq + F_form | x_eq | 58 | 4.89996e-17 | 4.39763e-17 | 3.63564e-19 | 0 |
| err_F1 | after_Tsub_xeq_zDNB | Tsub_K + x_eq + z_DNB_over_DH | F_form | 58 | -0.370227 | -0.123562 | 0.129201 | 0.137068 |
| err_F1 | after_Tsub_xeq_zDNB | Tsub_K + x_eq + z_DNB_over_DH | z_DNB_over_DH | 58 | 1.66478e-16 | 1.36361e-19 | 7.61224e-18 | 0 |
| err_F1 | after_Tsub_xeq_zDNB | Tsub_K + x_eq + z_DNB_over_DH | z_DNB_over_L | 58 | 0.27966 | 0.215593 | -0.185438 | 0.0782096 |
| err_F1 | after_Tsub_xeq_zDNB | Tsub_K + x_eq + z_DNB_over_DH | L_over_DH | 58 | -0.20727 | -0.000246995 | 0.079187 | 0.0429607 |
| err_F1 | after_Tsub_xeq_zDNB | Tsub_K + x_eq + z_DNB_over_DH | Tsub_K | 58 | -1.41886e-17 | 1.53129e-20 | 4.18553e-17 | 0 |
| err_F1 | after_Tsub_xeq_zDNB | Tsub_K + x_eq + z_DNB_over_DH | x_eq | 58 | 3.40727e-17 | 4.34108e-17 | 4.84987e-17 | 0 |

## 9. Exploratory model comparison

探索的線形整理であり、補正式として採用しない。

| model | response | predictors | N | k_predictors | R2 | RMSE | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PM_F1 ~ Tsub + x_eq + F_form + z_DNB/DH | PM_F1 | Tsub_K + x_eq + F_form + z_DNB_over_DH | 58 | 4 | 0.664947 | 0.06583 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ Tsub + x_eq + F_form | PM_F1 | Tsub_K + x_eq + F_form | 58 | 3 | 0.658402 | 0.0664698 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ Tsub + x_eq + L/DH | PM_F1 | Tsub_K + x_eq + L_over_DH | 58 | 3 | 0.589693 | 0.0728486 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ z_DNB/DH + L/DH | PM_F1 | z_DNB_over_DH + L_over_DH | 58 | 2 | 0.402908 | 0.0878794 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ Tsub + x_eq + z_DNB/DH | PM_F1 | Tsub_K + x_eq + z_DNB_over_DH | 58 | 3 | 0.396669 | 0.0883374 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ F_form + L/DH | PM_F1 | F_form + L_over_DH | 58 | 2 | 0.390353 | 0.0887986 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ L/DH | PM_F1 | L_over_DH | 58 | 1 | 0.39002 | 0.0888228 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ F_form + z_DNB/DH | PM_F1 | F_form + z_DNB_over_DH | 58 | 2 | 0.34189 | 0.0922605 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ z_DNB/DH | PM_F1 | z_DNB_over_DH | 58 | 1 | 0.284414 | 0.096205 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ F_form | PM_F1 | F_form | 58 | 1 | 0.239818 | 0.0991575 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ z_DNB/L | PM_F1 | z_DNB_over_L | 58 | 1 | 0.0783443 | 0.109182 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ Tsub + x_eq | PM_F1 | Tsub_K + x_eq | 58 | 2 | 0.0404493 | 0.111404 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ x_eq | PM_F1 | x_eq | 58 | 1 | 0.0385229 | 0.111516 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ Tsub | PM_F1 | Tsub_K | 58 | 1 | 0.0198185 | 0.112595 | DIAG_ONLY: 補正式係数として採用しない |
| abs_err_F1 ~ Tsub + x_eq + F_form + z_DNB/DH | abs_err_F1 | Tsub_K + x_eq + F_form + z_DNB_over_DH | 58 | 4 | 0.373193 | 0.0674874 | DIAG_ONLY: 補正式係数として採用しない |
| abs_err_F1 ~ L/DH | abs_err_F1 | L_over_DH | 58 | 1 | 0.0249817 | 0.084171 | DIAG_ONLY: 補正式係数として採用しない |
| abs_err_F1 ~ F_form | abs_err_F1 | F_form | 58 | 1 | 0.0135542 | 0.0846628 | DIAG_ONLY: 補正式係数として採用しない |
| abs_err_F1 ~ z_DNB/DH | abs_err_F1 | z_DNB_over_DH | 58 | 1 | 0.0106944 | 0.0847855 | DIAG_ONLY: 補正式係数として採用しない |
| err_F1 ~ Tsub + x_eq + F_form + z_DNB/DH | err_F1 | Tsub_K + x_eq + F_form + z_DNB_over_DH | 58 | 4 | 0.664947 | 0.06583 | DIAG_ONLY: 補正式係数として採用しない |
| err_F1 ~ L/DH | err_F1 | L_over_DH | 58 | 1 | 0.39002 | 0.0888228 | DIAG_ONLY: 補正式係数として採用しない |
| err_F1 ~ z_DNB/DH | err_F1 | z_DNB_over_DH | 58 | 1 | 0.284414 | 0.096205 | DIAG_ONLY: 補正式係数として採用しない |
| err_F1 ~ F_form | err_F1 | F_form | 58 | 1 | 0.239818 | 0.0991575 | DIAG_ONLY: 補正式係数として採用しない |

## 10. Handling candidates

| candidate_id | candidate | status | support | risk | current_reading |
| --- | --- | --- | --- | --- | --- |
| H0 | F1(Tsub)維持・追加補正式なし | primary_hold | PM_F1: 108=1.067, 161=0.909, 164=0.892。全体として1近傍だが系統差は残る。 | 残差を放置しすぎると、108高め/161-164低めの系統差を見落とす。 | 現時点の基準方針。補正式化より先に、残差の性格を診断課題として保持する。 |
| H1 | F_form・非一様加熱換算として扱う | possible_but_not_causal | PM_F1 vs F_form R2=0.240。F_formは108と161/164で大きく異なる。 | F_formはDNB位置やL/DHと交絡する。F_form-zDNB R2=0.291, F_form-LDH R2=0.643。F1の効き方として読まない。 | F_form定義・局所熱流束基準・DNB位置との関係を確認する価値はある。ただし原因断定しない。 |
| H2 | DNB位置・z_DNB/DH・z_DNB/Lのケース構造として扱う | possible_but_confounded | PM_F1 vs z_DNB/DH R2=0.284。DNB位置までの履歴長は108と161/164で大きく異なる。 | z_DNB/DHはL/DHやF_formと交絡する。zDNB-LDH R2=0.853。 | 単管側の熱履歴仮説とは接続しやすい。ただし3ケースだけで履歴長補正式にしない。 |
| H3 | L/DH補正式として扱う | reject_for_now | PM_F1 vs L/DH R2=0.390 は見える。 | BT04でPM_noF1はL/DHとほぼ対応せず、単管側でもL/D単独補正式は弱い。F1後残差だけでL/DH効果とは言わない。 | L/DHは診断項として残すが、補正式候補には進めない。 |
| H4 | x_eq置換として扱う | reject_for_now | PM_F1 vs x_eq R2=0.039, PM_F1 vs Tsub R2=0.020。BT05ではx_eqのTsub追加説明力が小さい。 | 単管ではx_eq込み診断が効いたが、バンドル108/161/164ではF1置換根拠にならない。 | x_eqは熱収支状態量・診断項として保留。F1(Tsub)をF(x_eq)へ置換しない。 |
| H5 | ケース代表性・適用範囲の問題として扱う | important_hold | 対象は108/161/164の3ケース群。PM_F1は1近傍だが、108は高め、161/164は低め。 | 3ケースだけで一般化すると危険。F_form、DNB位置、L/DH、Tsub、x_eqが同時に変化する。 | 補正式化せず、代表性・条件範囲・非一様加熱換算の診断課題として残す。 |

## 11. Interpretation flags

| item | status | value | reading |
| --- | --- | --- | --- |
| BT06位置づけ | OK |  | F1(Tsub)維持を前提に、PM_F1残差の扱いを整理する。補正式化ではない。 |
| PM_F1_case_pattern | diagnostic | 108=1.06679, 161=0.908841, 164=0.892018 | F1後は108が1よりやや高く、161/164が1より低い。大外れではないが、系統差は残る。 |
| PM_F1_axis_R2 | diagnostic | Fform=0.239818, zDNB_DH=0.284414, LDH=0.39002, xeq=0.0385229, Tsub=0.0198185 | PM_F1残差はTsub/x_eqよりF_form・履歴長・L/DH側と対応しやすい。ただし原因断定しない。 |
| best_PM_F1_model | DIAG_ONLY | PM_F1 ~ Tsub + x_eq + F_form + z_DNB/DH, R2=0.664947 | 探索モデル。補正式として採用しない。 |
| F_form_reading | hold |  | F_formはF1ではない。非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数として読む。 |
| L_DH_reading | reject_formula |  | PM_F1とL/DHに見かけ相関があっても、BT04・単管側の判断からL/DH補正式には進まない。 |
| x_eq_reading | reject_replacement |  | BT05により、今回のバンドルではx_eqはTsubへの追加説明力が小さい。F1(Tsub)をF(x_eq)へ置換しない。 |
| recommended_handling | primary |  | F1(Tsub)を維持し、PM_F1残差はF_form・DNB位置・L/DH・ケース構造・適用範囲の診断課題として残す。 |
| next_step | next |  | BT06結果を見て、必要ならBT07としてF_form定義・非一様加熱換算・DNB位置の扱いを確認する。 |

## 12. 次アクション

1. BT06_interpretation_flagsを確認する。
2. F1後残差を補正式化すべきか、診断課題として残すべきか判断する。
3. F_formとDNB位置・L/DHの交絡が強い場合は、F_form原因説やL/DH原因説を避ける。
4. 次に進む場合は、F_form定義・非一様加熱換算・DNB位置の扱いを確認する。
5. 単管側のST-BT05相当、すなわちHsub/P/Tsubとx_eqの切り分け診断は、後で忘れずに実施する。
