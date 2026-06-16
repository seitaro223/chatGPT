# BT04 bundle history bridge diagnostic

作成日時: 20260616

## 1. 目的

単管T&M/BMIでは、L/D単独補正式を作る根拠は弱い一方で、L/Dや加熱長は沸騰履歴・熱履歴の代理として意味を持つ可能性があると整理した。BT04では、この流れを受けて、バンドル108/161/164で、L/DHそのもの、DNBまでの実効履歴長、x_eq、F1(Tsub)、F_formのどれを見るのが筋がよいかを診断した。

## 2. 入力と出力

- 入力: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`
- 出力Excel: `BT04_bundle_history_bridge_diagnostic_20260616_090506.xlsx`

## 3. 前提

- r8 resultブックは直接読まない。
- current_bundle_inputを読む。
- F2/F1F2は使わない。
- 比較対象はnoF1とF1のみ。
- バンドルでは `x_Mes = x_eq` として扱う。
- F1は単管基準のTsub補正。
- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。
- 補正式は作らない。
- R2が高いモデルをそのまま採用しない。

## 4. Response summary

| kind | name | value_108 | value_161 | value_164 | mean_161_164 | delta_108_minus_mean_161_164 | ratio_108_over_mean_161_164 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| response | PM_noF1 | 0.621831 | 0.62098 | 0.570923 | 0.595952 | 0.0258787 | 1.04342 |
| response | PM_F1 | 1.06679 | 0.908841 | 0.892018 | 0.900429 | 0.166359 | 1.18476 |
| response | delta_PM | 0.444958 | 0.28786 | 0.321095 | 0.304478 | 0.140481 | 1.46138 |
| response | lift_ratio | 1.76502 | 1.55271 | 1.6679 | 1.6103 | 0.154722 | 1.09608 |
| response | delta_PM_per_Fcorr_minus1 | 10.0971 | 7.33701 | 7.73091 | 7.53396 | 2.56317 | 1.34022 |
| response | lift_minus1_per_Fcorr_minus1 | 17.2956 | 13.5172 | 15.7977 | 14.6574 | 2.63813 | 1.17999 |
| response | q_exp_MWm2 | 3.03625 | 1.4136 | 1.18876 | 1.30118 | 1.73507 | 2.33346 |
| response | q_calc_noF1_MWm2 | 1.90032 | 0.911914 | 0.702336 | 0.807125 | 1.0932 | 2.35444 |
| response | q_calc_F1_MWm2 | 3.23576 | 1.29514 | 1.06698 | 1.18106 | 2.0547 | 2.73971 |

## 5. Axis summary

| kind | name | value_108 | value_161 | value_164 | mean_161_164 | delta_108_minus_mean_161_164 | ratio_108_over_mean_161_164 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| axis | L_over_DH | 189.184 | 362.417 | 362.417 | 362.417 | -173.233 | 0.522007 |
| axis | z_DNB_over_DH | 139.659 | 361.355 | 286.824 | 324.09 | -184.431 | 0.430926 |
| axis | z_DNB_over_L | 0.738216 | 0.997071 | 0.79142 | 0.894245 | -0.156029 | 0.825519 |
| axis | x_eq | -0.0139909 | -0.0823228 | -0.155278 | -0.1188 | 0.104809 | 0.117768 |
| axis | Tsub_K | 46.0838 | 63.8439 | 54.9549 | 59.3994 | -13.3156 | 0.77583 |
| axis | Fcorr | 1.04382 | 1.03744 | 1.04041 | 1.03893 | 0.00489451 | 1.00471 |
| axis | F_form | 0.669495 | 1 | 1.34638 | 1.17319 | -0.503696 | 0.570661 |
| axis | Tw_minus_Tsat_K | 38.4377 | 25.7316 | 27.4893 | 26.6105 | 11.8273 | 1.44446 |
| axis | Tm_minus_Tsat_K | -6.60519 | 1.51983 | 1.85786 | 1.68885 | -8.29404 | -3.91107 |

## 6. Response-axis correlation

注：点群相関は探索的診断であり、補正式係数ではない。

| level | response | axis | axis_group | N | pearson_r | slope | intercept | R2 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| point_level | PM_noF1 | L_over_DH | geometry_length | 58 | -0.0708506 | -0.00014282 | 0.64885 | 0.0050198 |
| point_level | PM_noF1 | z_DNB_over_DH | effective_history | 58 | 0.00736248 | 1.27582e-05 | 0.599478 | 5.42061e-05 |
| point_level | PM_noF1 | z_DNB_over_L | effective_history | 58 | 0.108097 | 0.140965 | 0.481813 | 0.0116851 |
| point_level | PM_noF1 | x_eq | thermal_state | 58 | -0.790965 | -0.894689 | 0.520532 | 0.625626 |
| point_level | PM_noF1 | Tsub_K | thermal_state | 58 | 0.897499 | 0.00522845 | 0.308498 | 0.805504 |
| point_level | PM_noF1 | Fcorr | F1_Tsub | 58 | -0.660863 | -12.7615 | 13.8757 | 0.43674 |
| point_level | PM_noF1 | F_form | nonuniform_heat | 58 | -0.0967869 | -0.0546417 | 0.660197 | 0.0093677 |
| point_level | PM_noF1 | Tw_minus_Tsat_K | model_internal | 58 | 0.865376 | 0.0109245 | 0.281499 | 0.748875 |
| point_level | PM_noF1 | Tm_minus_Tsat_K | model_internal | 58 | -0.898868 | -0.0107473 | 0.599633 | 0.807964 |
| point_level | PM_F1 | L_over_DH | geometry_length | 58 | -0.624516 | -0.000958115 | 1.24805 | 0.39002 |
| point_level | PM_F1 | z_DNB_over_DH | effective_history | 58 | -0.533305 | -0.000703351 | 1.13842 | 0.284414 |
| point_level | PM_F1 | z_DNB_over_L | effective_history | 58 | -0.2799 | -0.277799 | 1.17982 | 0.0783443 |
| point_level | PM_F1 | x_eq | thermal_state | 58 | -0.196273 | -0.168968 | 0.925289 | 0.0385229 |
| point_level | PM_F1 | Tsub_K | thermal_state | 58 | 0.140778 | 0.000624172 | 0.90571 | 0.0198185 |
| point_level | PM_F1 | Fcorr | F1_Tsub | 58 | 0.0787224 | 1.15696 | -0.262426 | 0.00619721 |
| point_level | PM_F1 | F_form | nonuniform_heat | 58 | -0.489712 | -0.210416 | 1.16089 | 0.239818 |
| point_level | PM_F1 | Tw_minus_Tsat_K | model_internal | 58 | 0.586971 | 0.00563953 | 0.774876 | 0.344535 |
| point_level | PM_F1 | Tm_minus_Tsat_K | model_internal | 58 | -0.488316 | -0.00444357 | 0.939458 | 0.238452 |
| point_level | delta_PM | L_over_DH | geometry_length | 58 | -0.465985 | -0.000815295 | 0.599199 | 0.217142 |
| point_level | delta_PM | z_DNB_over_DH | effective_history | 58 | -0.476117 | -0.000716109 | 0.538938 | 0.226687 |
| point_level | delta_PM | z_DNB_over_L | effective_history | 58 | -0.369976 | -0.418764 | 0.698005 | 0.136882 |
| point_level | delta_PM | x_eq | thermal_state | 58 | 0.73919 | 0.725721 | 0.404757 | 0.546402 |
| point_level | delta_PM | Tsub_K | thermal_state | 58 | -0.910592 | -0.00460428 | 0.597212 | 0.829178 |
| point_level | delta_PM | Fcorr | F1_Tsub | 58 | 0.830428 | 13.9185 | -14.1382 | 0.689611 |
| point_level | delta_PM | F_form | nonuniform_heat | 58 | -0.317899 | -0.155774 | 0.500697 | 0.101059 |
| point_level | delta_PM | Tw_minus_Tsat_K | model_internal | 58 | -0.482333 | -0.00528497 | 0.493377 | 0.232645 |
| point_level | delta_PM | Tm_minus_Tsat_K | model_internal | 58 | 0.607427 | 0.00630369 | 0.339825 | 0.368968 |
| point_level | lift_ratio | L_over_DH | geometry_length | 58 | -0.180038 | -0.000908255 | 1.93685 | 0.0324139 |
| point_level | lift_ratio | z_DNB_over_DH | effective_history | 58 | -0.235153 | -0.0010198 | 1.93208 | 0.0552968 |
| point_level | lift_ratio | z_DNB_over_L | effective_history | 58 | -0.249102 | -0.812965 | 2.34492 | 0.0620516 |
| point_level | lift_ratio | x_eq | thermal_state | 58 | 0.790467 | 2.23767 | 1.85207 | 0.624839 |
| point_level | lift_ratio | Tsub_K | thermal_state | 58 | -0.941441 | -0.0137256 | 2.41894 | 0.886311 |
| point_level | lift_ratio | Fcorr | F1_Tsub | 58 | 0.670311 | 32.394 | -32.0459 | 0.449316 |
| point_level | lift_ratio | F_form | nonuniform_heat | 58 | -0.111762 | -0.157907 | 1.81078 | 0.0124908 |
| point_level | lift_ratio | Tw_minus_Tsat_K | model_internal | 58 | -0.715611 | -0.0226085 | 2.31115 | 0.512099 |
| point_level | lift_ratio | Tm_minus_Tsat_K | model_internal | 58 | 0.763805 | 0.0228551 | 1.65295 | 0.583398 |
| point_level | delta_PM_per_Fcorr_minus1 | L_over_DH | geometry_length | 58 | -0.503426 | -0.0148478 | 12.9061 | 0.253438 |
| point_level | delta_PM_per_Fcorr_minus1 | z_DNB_over_DH | effective_history | 58 | -0.499749 | -0.0126707 | 11.7045 | 0.249749 |
| point_level | delta_PM_per_Fcorr_minus1 | z_DNB_over_L | effective_history | 58 | -0.369818 | -7.05611 | 14.215 | 0.136765 |
| point_level | delta_PM_per_Fcorr_minus1 | x_eq | thermal_state | 58 | 0.668296 | 11.0602 | 9.1661 | 0.446619 |
| point_level | delta_PM_per_Fcorr_minus1 | Tsub_K | thermal_state | 58 | -0.835947 | -0.0712523 | 12.1601 | 0.698807 |
| point_level | delta_PM_per_Fcorr_minus1 | Fcorr | F1_Tsub | 58 | 0.681245 | 192.475 | -192.039 | 0.464094 |
| point_level | delta_PM_per_Fcorr_minus1 | F_form | nonuniform_heat | 58 | -0.370366 | -3.05928 | 11.3448 | 0.137171 |
| point_level | delta_PM_per_Fcorr_minus1 | Tw_minus_Tsat_K | model_internal | 58 | -0.404993 | -0.074804 | 10.3477 | 0.164019 |
| point_level | delta_PM_per_Fcorr_minus1 | Tm_minus_Tsat_K | model_internal | 58 | 0.491582 | 0.0859961 | 8.1733 | 0.241653 |
| point_level | lift_minus1_per_Fcorr_minus1 | L_over_DH | geometry_length | 58 | -0.148689 | -0.015528 | 20.2332 | 0.0221085 |
| point_level | lift_minus1_per_Fcorr_minus1 | z_DNB_over_DH | effective_history | 58 | -0.206578 | -0.0185457 | 20.4636 | 0.0426746 |
| point_level | lift_minus1_per_Fcorr_minus1 | z_DNB_over_L | effective_history | 58 | -0.231613 | -15.6477 | 28.714 | 0.0536446 |
| point_level | lift_minus1_per_Fcorr_minus1 | x_eq | thermal_state | 58 | 0.752077 | 44.0726 | 19.3203 | 0.56562 |
| point_level | lift_minus1_per_Fcorr_minus1 | Tsub_K | thermal_state | 58 | -0.893816 | -0.269761 | 30.4529 | 0.798908 |
| point_level | lift_minus1_per_Fcorr_minus1 | Fcorr | F1_Tsub | 58 | 0.577863 | 578.105 | -586.006 | 0.333926 |
| point_level | lift_minus1_per_Fcorr_minus1 | F_form | nonuniform_heat | 58 | -0.0962848 | -2.81616 | 18.1996 | 0.00927077 |
| point_level | lift_minus1_per_Fcorr_minus1 | Tw_minus_Tsat_K | model_internal | 58 | -0.701319 | -0.458674 | 28.756 | 0.491849 |
| point_level | lift_minus1_per_Fcorr_minus1 | Tm_minus_Tsat_K | model_internal | 58 | 0.724335 | 0.448676 | 15.398 | 0.524662 |
| point_level | q_exp_MWm2 | L_over_DH | geometry_length | 58 | -0.94301 | -0.00998635 | 4.92551 | 0.889268 |
| point_level | q_exp_MWm2 | z_DNB_over_DH | effective_history | 58 | -0.824886 | -0.00750942 | 3.83294 | 0.680436 |
| point_level | q_exp_MWm2 | z_DNB_over_L | effective_history | 58 | -0.472785 | -3.23897 | 4.5098 | 0.223525 |
| point_level | q_exp_MWm2 | x_eq | thermal_state | 58 | 0.156063 | 0.927388 | 1.80941 | 0.0243558 |
| point_level | q_exp_MWm2 | Tsub_K | thermal_state | 58 | 0.0201992 | 0.000618187 | 1.68904 | 0.000408008 |
| point_level | q_exp_MWm2 | Fcorr | F1_Tsub | 58 | 0.0758717 | 7.6969 | -6.28133 | 0.00575651 |
| point_level | q_exp_MWm2 | F_form | nonuniform_heat | 58 | -0.829369 | -2.45981 | 4.29593 | 0.687853 |
| point_level | q_exp_MWm2 | Tw_minus_Tsat_K | model_internal | 58 | 0.580927 | 0.0385269 | 0.589827 | 0.337476 |
| point_level | q_exp_MWm2 | Tm_minus_Tsat_K | model_internal | 58 | -0.484243 | -0.0304167 | 1.71416 | 0.234492 |
| point_level | q_calc_noF1_MWm2 | L_over_DH | geometry_length | 58 | -0.791006 | -0.00628309 | 3.08898 | 0.625691 |
| point_level | q_calc_noF1_MWm2 | z_DNB_over_DH | effective_history | 58 | -0.667606 | -0.00455864 | 2.35494 | 0.445698 |
| point_level | q_calc_noF1_MWm2 | z_DNB_over_L | effective_history | 58 | -0.346512 | -1.78059 | 2.60615 | 0.120071 |
| point_level | q_calc_noF1_MWm2 | x_eq | thermal_state | 58 | -0.15632 | -0.69675 | 1.01034 | 0.0244358 |
| point_level | q_calc_noF1_MWm2 | Tsub_K | thermal_state | 58 | 0.354927 | 0.00814756 | 0.615593 | 0.125973 |
| point_level | q_calc_noF1_MWm2 | Fcorr | F1_Tsub | 58 | -0.193765 | -14.7439 | 16.4091 | 0.0375448 |
| point_level | q_calc_noF1_MWm2 | F_form | nonuniform_heat | 58 | -0.711536 | -1.5829 | 2.72975 | 0.506283 |
| point_level | q_calc_noF1_MWm2 | Tw_minus_Tsat_K | model_internal | 58 | 0.819036 | 0.0407425 | -0.124643 | 0.670819 |
| point_level | q_calc_noF1_MWm2 | Tm_minus_Tsat_K | model_internal | 58 | -0.741581 | -0.0349389 | 1.06347 | 0.549943 |
| point_level | q_calc_F1_MWm2 | L_over_DH | geometry_length | 58 | -0.947776 | -0.011831 | 5.474 | 0.89828 |
| point_level | q_calc_F1_MWm2 | z_DNB_over_DH | effective_history | 58 | -0.832558 | -0.00893413 | 4.19017 | 0.693153 |
| point_level | q_calc_F1_MWm2 | z_DNB_over_L | effective_history | 58 | -0.48061 | -3.88115 | 5.01925 | 0.230986 |
| point_level | q_calc_F1_MWm2 | x_eq | thermal_state | 58 | 0.128327 | 0.898883 | 1.76387 | 0.0164678 |
| point_level | q_calc_F1_MWm2 | Tsub_K | thermal_state | 58 | 0.0096062 | 0.000346547 | 1.66143 | 9.2279e-05 |
| point_level | q_calc_F1_MWm2 | Fcorr | F1_Tsub | 58 | 0.103796 | 12.412 | -11.2282 | 0.0107735 |
| point_level | q_calc_F1_MWm2 | F_form | nonuniform_heat | 58 | -0.815032 | -2.8494 | 4.66039 | 0.664278 |
| point_level | q_calc_F1_MWm2 | Tw_minus_Tsat_K | model_internal | 58 | 0.598044 | 0.046752 | 0.304812 | 0.357656 |
| point_level | q_calc_F1_MWm2 | Tm_minus_Tsat_K | model_internal | 58 | -0.490385 | -0.0363086 | 1.66938 | 0.240478 |

## 7. PM_noF1 focus

F1なしの元モデル誤差が、L/DH、DNBまでの履歴長、x_eqなどで整理されるかを見る。

| level | response | axis | axis_group | N | pearson_r | slope | intercept | R2 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| point_level | PM_noF1 | Tm_minus_Tsat_K | model_internal | 58 | -0.898868 | -0.0107473 | 0.599633 | 0.807964 |
| point_level | PM_noF1 | Tsub_K | thermal_state | 58 | 0.897499 | 0.00522845 | 0.308498 | 0.805504 |
| point_level | PM_noF1 | Tw_minus_Tsat_K | model_internal | 58 | 0.865376 | 0.0109245 | 0.281499 | 0.748875 |
| point_level | PM_noF1 | x_eq | thermal_state | 58 | -0.790965 | -0.894689 | 0.520532 | 0.625626 |
| point_level | PM_noF1 | Fcorr | F1_Tsub | 58 | -0.660863 | -12.7615 | 13.8757 | 0.43674 |
| point_level | PM_noF1 | z_DNB_over_L | effective_history | 58 | 0.108097 | 0.140965 | 0.481813 | 0.0116851 |
| point_level | PM_noF1 | F_form | nonuniform_heat | 58 | -0.0967869 | -0.0546417 | 0.660197 | 0.0093677 |
| point_level | PM_noF1 | L_over_DH | geometry_length | 58 | -0.0708506 | -0.00014282 | 0.64885 | 0.0050198 |
| point_level | PM_noF1 | z_DNB_over_DH | effective_history | 58 | 0.00736248 | 1.27582e-05 | 0.599478 | 5.42061e-05 |

## 8. F1 effect focus

F1による持ち上げ量・倍率が、x_eq、Tsub、Fcorr、履歴長などで整理されるかを見る。

| level | response | axis | axis_group | N | pearson_r | slope | intercept | R2 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| point_level | delta_PM | Tsub_K | thermal_state | 58 | -0.910592 | -0.00460428 | 0.597212 | 0.829178 |
| point_level | delta_PM | Fcorr | F1_Tsub | 58 | 0.830428 | 13.9185 | -14.1382 | 0.689611 |
| point_level | delta_PM | x_eq | thermal_state | 58 | 0.73919 | 0.725721 | 0.404757 | 0.546402 |
| point_level | delta_PM | Tm_minus_Tsat_K | model_internal | 58 | 0.607427 | 0.00630369 | 0.339825 | 0.368968 |
| point_level | delta_PM | Tw_minus_Tsat_K | model_internal | 58 | -0.482333 | -0.00528497 | 0.493377 | 0.232645 |
| point_level | delta_PM | z_DNB_over_DH | effective_history | 58 | -0.476117 | -0.000716109 | 0.538938 | 0.226687 |
| point_level | delta_PM | L_over_DH | geometry_length | 58 | -0.465985 | -0.000815295 | 0.599199 | 0.217142 |
| point_level | delta_PM | z_DNB_over_L | effective_history | 58 | -0.369976 | -0.418764 | 0.698005 | 0.136882 |
| point_level | delta_PM | F_form | nonuniform_heat | 58 | -0.317899 | -0.155774 | 0.500697 | 0.101059 |
| point_level | delta_PM_per_Fcorr_minus1 | Tsub_K | thermal_state | 58 | -0.835947 | -0.0712523 | 12.1601 | 0.698807 |
| point_level | delta_PM_per_Fcorr_minus1 | Fcorr | F1_Tsub | 58 | 0.681245 | 192.475 | -192.039 | 0.464094 |
| point_level | delta_PM_per_Fcorr_minus1 | x_eq | thermal_state | 58 | 0.668296 | 11.0602 | 9.1661 | 0.446619 |
| point_level | delta_PM_per_Fcorr_minus1 | L_over_DH | geometry_length | 58 | -0.503426 | -0.0148478 | 12.9061 | 0.253438 |
| point_level | delta_PM_per_Fcorr_minus1 | z_DNB_over_DH | effective_history | 58 | -0.499749 | -0.0126707 | 11.7045 | 0.249749 |
| point_level | delta_PM_per_Fcorr_minus1 | Tm_minus_Tsat_K | model_internal | 58 | 0.491582 | 0.0859961 | 8.1733 | 0.241653 |
| point_level | delta_PM_per_Fcorr_minus1 | Tw_minus_Tsat_K | model_internal | 58 | -0.404993 | -0.074804 | 10.3477 | 0.164019 |
| point_level | delta_PM_per_Fcorr_minus1 | F_form | nonuniform_heat | 58 | -0.370366 | -3.05928 | 11.3448 | 0.137171 |
| point_level | delta_PM_per_Fcorr_minus1 | z_DNB_over_L | effective_history | 58 | -0.369818 | -7.05611 | 14.215 | 0.136765 |
| point_level | lift_minus1_per_Fcorr_minus1 | Tsub_K | thermal_state | 58 | -0.893816 | -0.269761 | 30.4529 | 0.798908 |
| point_level | lift_minus1_per_Fcorr_minus1 | x_eq | thermal_state | 58 | 0.752077 | 44.0726 | 19.3203 | 0.56562 |
| point_level | lift_minus1_per_Fcorr_minus1 | Tm_minus_Tsat_K | model_internal | 58 | 0.724335 | 0.448676 | 15.398 | 0.524662 |
| point_level | lift_minus1_per_Fcorr_minus1 | Tw_minus_Tsat_K | model_internal | 58 | -0.701319 | -0.458674 | 28.756 | 0.491849 |
| point_level | lift_minus1_per_Fcorr_minus1 | Fcorr | F1_Tsub | 58 | 0.577863 | 578.105 | -586.006 | 0.333926 |
| point_level | lift_minus1_per_Fcorr_minus1 | z_DNB_over_L | effective_history | 58 | -0.231613 | -15.6477 | 28.714 | 0.0536446 |
| point_level | lift_minus1_per_Fcorr_minus1 | z_DNB_over_DH | effective_history | 58 | -0.206578 | -0.0185457 | 20.4636 | 0.0426746 |
| point_level | lift_minus1_per_Fcorr_minus1 | L_over_DH | geometry_length | 58 | -0.148689 | -0.015528 | 20.2332 | 0.0221085 |
| point_level | lift_minus1_per_Fcorr_minus1 | F_form | nonuniform_heat | 58 | -0.0962848 | -2.81616 | 18.1996 | 0.00927077 |
| point_level | lift_ratio | Tsub_K | thermal_state | 58 | -0.941441 | -0.0137256 | 2.41894 | 0.886311 |
| point_level | lift_ratio | x_eq | thermal_state | 58 | 0.790467 | 2.23767 | 1.85207 | 0.624839 |
| point_level | lift_ratio | Tm_minus_Tsat_K | model_internal | 58 | 0.763805 | 0.0228551 | 1.65295 | 0.583398 |
| point_level | lift_ratio | Tw_minus_Tsat_K | model_internal | 58 | -0.715611 | -0.0226085 | 2.31115 | 0.512099 |
| point_level | lift_ratio | Fcorr | F1_Tsub | 58 | 0.670311 | 32.394 | -32.0459 | 0.449316 |
| point_level | lift_ratio | z_DNB_over_L | effective_history | 58 | -0.249102 | -0.812965 | 2.34492 | 0.0620516 |
| point_level | lift_ratio | z_DNB_over_DH | effective_history | 58 | -0.235153 | -0.0010198 | 1.93208 | 0.0552968 |
| point_level | lift_ratio | L_over_DH | geometry_length | 58 | -0.180038 | -0.000908255 | 1.93685 | 0.0324139 |
| point_level | lift_ratio | F_form | nonuniform_heat | 58 | -0.111762 | -0.157907 | 1.81078 | 0.0124908 |

## 9. History versus geometry

単純なL/DHと、DNBまでの実効履歴長 z_DNB/DH、z_DNB/L、x_eq を比較する。

| response | R2_L_over_DH | R2_z_DNB_over_DH | R2_z_DNB_over_L | R2_x_eq | R2_Tsub | R2_Fcorr | R2_F_form | best_single_axis | best_single_R2 | history_beats_geometry | xeq_beats_geometry |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PM_noF1 | 0.0050198 | 5.42061e-05 | 0.0116851 | 0.625626 | 0.805504 | 0.43674 | 0.0093677 | Tsub_K | 0.805504 | false | true |
| PM_F1 | 0.39002 | 0.284414 | 0.0783443 | 0.0385229 | 0.0198185 | 0.00619721 | 0.239818 | L_over_DH | 0.39002 | false | false |
| delta_PM | 0.217142 | 0.226687 | 0.136882 | 0.546402 | 0.829178 | 0.689611 | 0.101059 | Tsub_K | 0.829178 | true | true |
| lift_ratio | 0.0324139 | 0.0552968 | 0.0620516 | 0.624839 | 0.886311 | 0.449316 | 0.0124908 | Tsub_K | 0.886311 | true | true |

## 10. Exploratory model comparison

注：探索的な線形整理であり、係数・R2を補正式として採用しない。

| model | response | predictors | N | k_predictors | R2 | RMSE | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PM_F1 ~ Tsub + x_eq + F_form + z_DNB/DH | PM_F1 | Tsub_K + x_eq + F_form + z_DNB_over_DH | 58 | 4 | 0.664947 | 0.06583 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ x_eq + F_form + z_DNB/DH | PM_F1 | x_eq + F_form + z_DNB_over_DH | 58 | 3 | 0.556876 | 0.0757058 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ L/DH | PM_F1 | L_over_DH | 58 | 1 | 0.39002 | 0.0888228 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ z_DNB/DH | PM_F1 | z_DNB_over_DH | 58 | 1 | 0.284414 | 0.096205 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ F_form | PM_F1 | F_form | 58 | 1 | 0.239818 | 0.0991575 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ x_eq | PM_F1 | x_eq | 58 | 1 | 0.0385229 | 0.111516 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ Tsub | PM_F1 | Tsub_K | 58 | 1 | 0.0198185 | 0.112595 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 ~ x_eq + F_form + z_DNB/DH | PM_noF1 | x_eq + F_form + z_DNB_over_DH | 58 | 3 | 0.88806 | 0.0499954 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 ~ Tsub | PM_noF1 | Tsub_K | 58 | 1 | 0.805504 | 0.065901 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 ~ x_eq + z_DNB/DH | PM_noF1 | x_eq + z_DNB_over_DH | 58 | 2 | 0.659946 | 0.0871386 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 ~ x_eq | PM_noF1 | x_eq | 58 | 1 | 0.625626 | 0.0914303 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 ~ L/DH + z_DNB/DH | PM_noF1 | L_over_DH + z_DNB_over_DH | 58 | 2 | 0.0410961 | 0.146327 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 ~ z_DNB/L | PM_noF1 | z_DNB_over_L | 58 | 1 | 0.0116851 | 0.148554 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 ~ F_form | PM_noF1 | F_form | 58 | 1 | 0.0093677 | 0.148728 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 ~ L/DH | PM_noF1 | L_over_DH | 58 | 1 | 0.0050198 | 0.149054 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 ~ z_DNB/DH | PM_noF1 | z_DNB_over_DH | 58 | 1 | 5.42061e-05 | 0.149426 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM ~ x_eq + Tsub | delta_PM | x_eq + Tsub_K | 58 | 2 | 0.831247 | 0.0532797 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM ~ Tsub | delta_PM | Tsub_K | 58 | 1 | 0.829178 | 0.0536053 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM ~ Fcorr | delta_PM | Fcorr | 58 | 1 | 0.689611 | 0.0722585 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM ~ x_eq | delta_PM | x_eq | 58 | 1 | 0.546402 | 0.0873517 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM ~ z_DNB/DH | delta_PM | z_DNB_over_DH | 58 | 1 | 0.226687 | 0.114055 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM ~ L/DH | delta_PM | L_over_DH | 58 | 1 | 0.217142 | 0.114757 | DIAG_ONLY: 補正式係数として採用しない |
| lift_ratio ~ x_eq + Tsub | lift_ratio | x_eq + Tsub_K | 58 | 2 | 0.886312 | 0.126093 | DIAG_ONLY: 補正式係数として採用しない |
| lift_ratio ~ Tsub | lift_ratio | Tsub_K | 58 | 1 | 0.886311 | 0.126094 | DIAG_ONLY: 補正式係数として採用しない |
| lift_ratio ~ x_eq | lift_ratio | x_eq | 58 | 1 | 0.624839 | 0.229057 | DIAG_ONLY: 補正式係数として採用しない |
| lift_ratio ~ Fcorr | lift_ratio | Fcorr | 58 | 1 | 0.449316 | 0.277515 | DIAG_ONLY: 補正式係数として採用しない |
| lift_ratio ~ z_DNB/DH | lift_ratio | z_DNB_over_DH | 58 | 1 | 0.0552968 | 0.363482 | DIAG_ONLY: 補正式係数として採用しない |
| lift_ratio ~ L/DH | lift_ratio | L_over_DH | 58 | 1 | 0.0324139 | 0.367858 | DIAG_ONLY: 補正式係数として採用しない |

## 11. Interpretation flags

| item | status | value | reading |
| --- | --- | --- | --- |
| BT04位置づけ | OK |  | 単管L/D仮説からバンドル履歴変数への橋渡し診断。補正式化ではない。 |
| PM_noF1_best_axis | diagnostic | Tsub_K, R2=0.805504 | どの軸と最も対応するかを見る。過読しない。 |
| PM_F1_best_axis | diagnostic | L_over_DH, R2=0.39002 | どの軸と最も対応するかを見る。過読しない。 |
| delta_PM_best_axis | diagnostic | Tsub_K, R2=0.829178 | どの軸と最も対応するかを見る。過読しない。 |
| lift_ratio_best_axis | diagnostic | Tsub_K, R2=0.886311 | どの軸と最も対応するかを見る。過読しない。 |
| PM_noF1_L_vs_history_vs_xeq | diagnostic | R2_LDH=0.0050198, R2_zDNB_DH=5.42061e-05, R2_xeq=0.625626 | 単管で避けたL/D単独補正式に戻らないため、L/DH・z_DNB/DH・x_eqを比較する。 |
| delta_PM_xeq_Tsub_Fcorr_history | diagnostic | R2_xeq=0.546402, R2_Tsub=0.829178, R2_Fcorr=0.689611, R2_zDNB_DH=0.226687 | F1が何に反応して持ち上げているかを見る。Tsub/Fcorrとの共変に注意。 |
| lift_ratio_xeq_Tsub_Fcorr_history | diagnostic | R2_xeq=0.624839, R2_Tsub=0.886311, R2_Fcorr=0.449316, R2_zDNB_DH=0.0552968 | 倍率効果でF1の効きやすさと状態量の関係を見る。 |
| best_model_PM_noF1 | DIAG_ONLY | PM_noF1 ~ x_eq + F_form + z_DNB/DH, R2=0.88806 | 探索的モデル。補正式として採用しない。 |
| best_model_PM_F1 | DIAG_ONLY | PM_F1 ~ Tsub + x_eq + F_form + z_DNB/DH, R2=0.664947 | 探索的モデル。補正式として採用しない。 |
| best_model_delta_PM | DIAG_ONLY | delta_PM ~ x_eq + Tsub, R2=0.831247 | 探索的モデル。補正式として採用しない。 |
| best_model_lift_ratio | DIAG_ONLY | lift_ratio ~ x_eq + Tsub, R2=0.886312 | 探索的モデル。補正式として採用しない。 |
| BT04判断ゲート | hold |  | PM_noF1・F1効果量・PM_F1を分け、L/DHではなく履歴長やx_eqで読むべきか判断する。 |

## 12. 次アクション

1. BT04_interpretation_flagsを確認する。
2. PM_noF1が、L/DH・z_DNB/DH・x_eqのどれと対応するかを見る。
3. delta_PM / lift_ratioが、x_eq・Tsub・Fcorr・履歴長のどれと対応するかを見る。
4. L/DHだけが高く見える場合でも、単管で避けたL/D単独補正式に戻らない。
5. F_formが効いて見える場合は、F1置換より先に非一様加熱換算の扱いを固定する。
6. BT04の結果をworking logへ追記し、その後にBT05へ進むか判断する。
