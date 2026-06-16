# BT03 current_bundle: F1 / F_form / x_eq / history separation

作成日時: 20260615

## 1. 目的

BT01/BT02で確認した「F1後のP/Mは108が相対的に高く、161/164がやや低い」という状態について、F1(Tsub)、Fcorr、F_form、x_eq、z_DNB/DH、z_DNB/L、L/DHを分けて確認した。

## 2. 入力と出力

- 入力: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`
- 出力Excel: `BT03_current_bundle_F1_Fform_xeq_history_separation_20260615_184941.xlsx`

## 3. 前提

- r8 resultブックは直接読まない。
- current_bundle_inputを読む。
- F2/F1F2は使わない。
- 比較対象はnoF1とF1のみ。
- バンドルでは `x_Mes = x_eq` として扱う。
- F1は単管基準のTsub補正。
- F_formはF1ではなく、非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数。
- 補正式は作らない。

## 4. Case summary

| case_id | N | q_exp_MWm2_mean | q_calc_noF1_MWm2_mean | q_calc_F1_MWm2_mean | PM_noF1_mean | PM_F1_mean | delta_PM_mean | qcalc_lift_ratio_mean | Tsub_K_mean | Fcorr_mean | F1_formula_from_Tsub_mean | F_form_mean | x_eq_mean | z_DNB_over_DH_mean | z_DNB_over_L_mean | L_over_DH_mean |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | 14 | 3.03625 | 1.90032 | 3.23576 | 0.621831 | 1.06679 | 0.444958 | 1.76502 | 46.0838 | 1.04382 | 1.04382 | 0.669495 | -0.0139909 | 139.659 | 0.738216 | 189.184 |
| 161 | 23 | 1.4136 | 0.911914 | 1.29514 | 0.62098 | 0.908841 | 0.28786 | 1.55271 | 63.8439 | 1.03744 | 1.03744 | 1 | -0.0823228 | 361.355 | 0.997071 | 362.417 |
| 164 | 21 | 1.18876 | 0.702336 | 1.06698 | 0.570923 | 0.892018 | 0.321095 | 1.6679 | 54.9549 | 1.04041 | 1.04041 | 1.34638 | -0.155278 | 286.824 | 0.79142 | 362.417 |

## 5. 108 contrast against mean(161,164)

| metric | value_108 | value_161 | value_164 | mean_161_164 | delta_108_minus_mean_161_164 | ratio_108_over_mean_161_164 |
| --- | --- | --- | --- | --- | --- | --- |
| q_exp_MWm2_mean | 3.03625 | 1.4136 | 1.18876 | 1.30118 | 1.73507 | 2.33346 |
| q_calc_noF1_MWm2_mean | 1.90032 | 0.911914 | 0.702336 | 0.807125 | 1.0932 | 2.35444 |
| q_calc_F1_MWm2_mean | 3.23576 | 1.29514 | 1.06698 | 1.18106 | 2.0547 | 2.73971 |
| PM_noF1_mean | 0.621831 | 0.62098 | 0.570923 | 0.595952 | 0.0258787 | 1.04342 |
| PM_F1_mean | 1.06679 | 0.908841 | 0.892018 | 0.900429 | 0.166359 | 1.18476 |
| delta_PM_mean | 0.444958 | 0.28786 | 0.321095 | 0.304478 | 0.140481 | 1.46138 |
| qcalc_lift_ratio_mean | 1.76502 | 1.55271 | 1.6679 | 1.6103 | 0.154722 | 1.09608 |
| PM_lift_ratio_mean | 1.76502 | 1.55271 | 1.6679 | 1.6103 | 0.154722 | 1.09608 |
| Tsub_K_mean | 46.0838 | 63.8439 | 54.9549 | 59.3994 | -13.3156 | 0.77583 |
| Fcorr_mean | 1.04382 | 1.03744 | 1.04041 | 1.03893 | 0.00489451 | 1.00471 |
| F1_formula_from_Tsub_mean | 1.04382 | 1.03744 | 1.04041 | 1.03893 | 0.00489451 | 1.00471 |
| F_form_mean | 0.669495 | 1 | 1.34638 | 1.17319 | -0.503696 | 0.570661 |
| x_eq_mean | -0.0139909 | -0.0823228 | -0.155278 | -0.1188 | 0.104809 | 0.117768 |
| z_DNB_over_DH_mean | 139.659 | 361.355 | 286.824 | 324.09 | -184.431 | 0.430926 |
| z_DNB_over_L_mean | 0.738216 | 0.997071 | 0.79142 | 0.894245 | -0.156029 | 0.825519 |
| L_over_DH_mean | 189.184 | 362.417 | 362.417 | 362.417 | -173.233 | 0.522007 |
| Tw_minus_Tsat_K_mean | 38.4377 | 25.7316 | 27.4893 | 26.6105 | 11.8273 | 1.44446 |
| Tm_minus_Tsat_K_mean | -6.60519 | 1.51983 | 1.85786 | 1.68885 | -8.29404 | -3.91107 |

## 6. Bucket summary

| bucket | variable | value_108 | mean_161_164 | delta | ratio | reading |
| --- | --- | --- | --- | --- | --- | --- |
| F1_Tsub | Tsub_K_mean | 46.0838 | 59.3994 | -13.3156 | 0.77583 | 108は161/164よりTsubが低い。F1(Tsub)上は差がある。 |
| F1_Tsub | Fcorr_mean | 1.04382 | 1.03893 | 0.00489451 | 1.00471 | Fcorr差は小さい。F1(Tsub)係数だけでPM差を説明しにくい可能性。 |
| F1_Tsub | F1_formula_from_Tsub_mean | 1.04382 | 1.03893 | 0.00489451 | 1.00471 | A_corrとsigma_corrが取得できた場合のF1再計算値。Fcorrと一致するかを確認する。 |
| nonuniform_heat | F_form_mean | 0.669495 | 1.17319 | -0.503696 | 0.570661 | F_form差は大きい。ただしF_formはF1ではなく非一様加熱換算である。 |
| thermal_state | x_eq_mean | -0.0139909 | -0.1188 | 0.104809 | 0.117768 | 108はx_eqが0に近い。ただしx_eq単独でPM差を説明できるとは限らない。 |
| history | z_DNB_over_DH_mean | 139.659 | 324.09 | -184.431 | 0.430926 | 108はDNB位置までの履歴長が短い。履歴長候補として見る。 |
| history | z_DNB_over_L_mean | 0.738216 | 0.894245 | -0.156029 | 0.825519 | 108は相対的に上流側DNB寄り。z_DNB/DHとは別に見る。 |
| history | L_over_DH_mean | 189.184 | 362.417 | -173.233 | 0.522007 | 108は全体L/DHが小さい。DNBまでの実効長と分けて読む。 |
| wall_thermal | Tw_minus_Tsat_K_mean | 38.4377 | 26.6105 | 11.8273 | 1.44446 | 108は壁面過熱が大きい。結果側・モデル内部量として読む。 |
| wall_thermal | Tm_minus_Tsat_K_mean | -6.60519 | 1.68885 | -8.29404 | -3.91107 | 108はTm-Tsatが低い。温度場・モデル内部量として読む。 |

## 7. Point-level correlation diagnostics

注：相関は探索的診断であり、補正式係数ではない。

| level | target | state_var | N | pearson_r | slope | intercept | R2 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| point_level | PM_F1 | Tsub_K | 58 | 0.140778 | 0.000624172 | 0.90571 | 0.0198185 |
| point_level | PM_F1 | Fcorr | 58 | 0.0787224 | 1.15696 | -0.262426 | 0.00619721 |
| point_level | PM_F1 | F1_formula_from_Tsub | 58 | 0.0787224 | 1.15696 | -0.262426 | 0.00619721 |
| point_level | PM_F1 | F_form | 58 | -0.489712 | -0.210416 | 1.16089 | 0.239818 |
| point_level | PM_F1 | x_eq | 58 | -0.196273 | -0.168968 | 0.925289 | 0.0385229 |
| point_level | PM_F1 | z_DNB_over_DH | 58 | -0.533305 | -0.000703351 | 1.13842 | 0.284414 |
| point_level | PM_F1 | z_DNB_over_L | 58 | -0.2799 | -0.277799 | 1.17982 | 0.0783443 |
| point_level | PM_F1 | L_over_DH | 58 | -0.624516 | -0.000958115 | 1.24805 | 0.39002 |
| point_level | PM_F1 | Tw_minus_Tsat_K | 58 | 0.586971 | 0.00563953 | 0.774876 | 0.344535 |
| point_level | PM_F1 | Tm_minus_Tsat_K | 58 | -0.488316 | -0.00444357 | 0.939458 | 0.238452 |
| point_level | delta_PM | Tsub_K | 58 | -0.910592 | -0.00460428 | 0.597212 | 0.829178 |
| point_level | delta_PM | Fcorr | 58 | 0.830428 | 13.9185 | -14.1382 | 0.689611 |
| point_level | delta_PM | F1_formula_from_Tsub | 58 | 0.830428 | 13.9185 | -14.1382 | 0.689611 |
| point_level | delta_PM | F_form | 58 | -0.317899 | -0.155774 | 0.500697 | 0.101059 |
| point_level | delta_PM | x_eq | 58 | 0.73919 | 0.725721 | 0.404757 | 0.546402 |
| point_level | delta_PM | z_DNB_over_DH | 58 | -0.476117 | -0.000716109 | 0.538938 | 0.226687 |
| point_level | delta_PM | z_DNB_over_L | 58 | -0.369976 | -0.418764 | 0.698005 | 0.136882 |
| point_level | delta_PM | L_over_DH | 58 | -0.465985 | -0.000815295 | 0.599199 | 0.217142 |
| point_level | delta_PM | Tw_minus_Tsat_K | 58 | -0.482333 | -0.00528497 | 0.493377 | 0.232645 |
| point_level | delta_PM | Tm_minus_Tsat_K | 58 | 0.607427 | 0.00630369 | 0.339825 | 0.368968 |
| point_level | qcalc_lift_ratio | Tsub_K | 58 | -0.941441 | -0.0137256 | 2.41894 | 0.886311 |
| point_level | qcalc_lift_ratio | Fcorr | 58 | 0.670311 | 32.394 | -32.0459 | 0.449316 |
| point_level | qcalc_lift_ratio | F1_formula_from_Tsub | 58 | 0.670311 | 32.394 | -32.0459 | 0.449316 |
| point_level | qcalc_lift_ratio | F_form | 58 | -0.111762 | -0.157907 | 1.81078 | 0.0124908 |
| point_level | qcalc_lift_ratio | x_eq | 58 | 0.790467 | 2.23767 | 1.85207 | 0.624839 |
| point_level | qcalc_lift_ratio | z_DNB_over_DH | 58 | -0.235153 | -0.0010198 | 1.93208 | 0.0552968 |
| point_level | qcalc_lift_ratio | z_DNB_over_L | 58 | -0.249102 | -0.812965 | 2.34492 | 0.0620516 |
| point_level | qcalc_lift_ratio | L_over_DH | 58 | -0.180038 | -0.000908255 | 1.93685 | 0.0324139 |
| point_level | qcalc_lift_ratio | Tw_minus_Tsat_K | 58 | -0.715611 | -0.0226085 | 2.31115 | 0.512099 |
| point_level | qcalc_lift_ratio | Tm_minus_Tsat_K | 58 | 0.763805 | 0.0228551 | 1.65295 | 0.583398 |
| point_level | PM_lift_ratio | Tsub_K | 58 | -0.941441 | -0.0137256 | 2.41894 | 0.886311 |
| point_level | PM_lift_ratio | Fcorr | 58 | 0.670311 | 32.394 | -32.0459 | 0.449316 |
| point_level | PM_lift_ratio | F1_formula_from_Tsub | 58 | 0.670311 | 32.394 | -32.0459 | 0.449316 |
| point_level | PM_lift_ratio | F_form | 58 | -0.111762 | -0.157907 | 1.81078 | 0.0124908 |
| point_level | PM_lift_ratio | x_eq | 58 | 0.790467 | 2.23767 | 1.85207 | 0.624839 |
| point_level | PM_lift_ratio | z_DNB_over_DH | 58 | -0.235153 | -0.0010198 | 1.93208 | 0.0552968 |
| point_level | PM_lift_ratio | z_DNB_over_L | 58 | -0.249102 | -0.812965 | 2.34492 | 0.0620516 |
| point_level | PM_lift_ratio | L_over_DH | 58 | -0.180038 | -0.000908255 | 1.93685 | 0.0324139 |
| point_level | PM_lift_ratio | Tw_minus_Tsat_K | 58 | -0.715611 | -0.0226085 | 2.31115 | 0.512099 |
| point_level | PM_lift_ratio | Tm_minus_Tsat_K | 58 | 0.763805 | 0.0228551 | 1.65295 | 0.583398 |

## 8. Case-mean correlation diagnostics

注：ケース平均相関はN=3なので、順位や符号を強く読まない。

| level | target | state_var | N | pearson_r | slope | intercept | R2 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| case_mean_N3 | PM_F1 | Tsub_K | 3 | -0.818767 | -0.00888976 | 1.44447 | 0.670379 |
| case_mean_N3 | PM_F1 | Fcorr | 3 | 0.841106 | 25.3999 | -25.4742 | 0.707459 |
| case_mean_N3 | PM_F1 | F1_formula_from_Tsub | 3 | 0.841106 | 25.3999 | -25.4742 | 0.707459 |
| case_mean_N3 | PM_F1 | F_form | 3 | -0.90054 | -0.256521 | 1.21376 | 0.810972 |
| case_mean_N3 | PM_F1 | x_eq | 3 | 0.898201 | 1.22566 | 1.05867 | 0.806766 |
| case_mean_N3 | PM_F1 | z_DNB_over_DH | 3 | -0.911449 | -0.00077896 | 1.16045 | 0.83074 |
| case_mean_N3 | PM_F1 | z_DNB_over_L | 3 | -0.590833 | -0.416705 | 1.30685 | 0.349084 |
| case_mean_N3 | PM_F1 | L_over_DH | 3 | -0.996187 | -0.000960322 | 1.24847 | 0.992389 |
| case_mean_N3 | PM_F1 | Tw_minus_Tsat_K | 3 | 0.976901 | 0.0136806 | 0.537901 | 0.954336 |
| case_mean_N3 | PM_F1 | Tm_minus_Tsat_K | 3 | -0.998645 | -0.0200947 | 0.934264 | 0.997291 |
| case_mean_N3 | delta_PM | Tsub_K | 3 | -0.948573 | -0.00884382 | 0.837368 | 0.899791 |
| case_mean_N3 | delta_PM | Fcorr | 3 | 0.960491 | 24.9066 | -25.5654 | 0.922544 |
| case_mean_N3 | delta_PM | F1_formula_from_Tsub | 3 | 0.960491 | 24.9066 | -25.5654 | 0.922544 |
| case_mean_N3 | delta_PM | F_form | 3 | -0.738991 | -0.180758 | 0.533019 | 0.546108 |
| case_mean_N3 | delta_PM | x_eq | 3 | 0.735377 | 0.861679 | 0.423568 | 0.540779 |
| case_mean_N3 | delta_PM | z_DNB_over_DH | 3 | -0.99096 | -0.000727241 | 0.542287 | 0.982001 |
| case_mean_N3 | delta_PM | z_DNB_over_L | 3 | -0.796527 | -0.482396 | 0.757596 | 0.634456 |
| case_mean_N3 | delta_PM | L_over_DH | 3 | -0.97965 | -0.000810935 | 0.598374 | 0.959714 |
| case_mean_N3 | delta_PM | Tw_minus_Tsat_K | 3 | 0.997257 | 0.0119922 | -0.0150932 | 0.994521 |
| case_mean_N3 | delta_PM | Tm_minus_Tsat_K | 3 | -0.971961 | -0.0167941 | 0.333237 | 0.944707 |
| case_mean_N3 | qcalc_lift_ratio | Tsub_K | 3 | -0.998825 | -0.0119549 | 2.31893 | 0.997651 |
| case_mean_N3 | qcalc_lift_ratio | Fcorr | 3 | 0.996082 | 33.1593 | -32.8423 | 0.99218 |
| case_mean_N3 | qcalc_lift_ratio | F1_formula_from_Tsub | 3 | 0.996082 | 33.1593 | -32.8423 | 0.99218 |
| case_mean_N3 | qcalc_lift_ratio | F_form | 3 | -0.444837 | -0.139685 | 1.8023 | 0.19788 |
| case_mean_N3 | qcalc_lift_ratio | x_eq | 3 | 0.44004 | 0.661937 | 1.71739 | 0.193635 |
| case_mean_N3 | qcalc_lift_ratio | z_DNB_over_DH | 3 | -0.972278 | -0.000916013 | 1.90243 | 0.945324 |
| case_mean_N3 | qcalc_lift_ratio | z_DNB_over_L | 3 | -0.961417 | -0.747487 | 2.29144 | 0.924323 |
| case_mean_N3 | qcalc_lift_ratio | L_over_DH | 3 | -0.84046 | -0.000893143 | 1.93399 | 0.706373 |
| case_mean_N3 | qcalc_lift_ratio | Tw_minus_Tsat_K | 3 | 0.902754 | 0.0139365 | 1.23608 | 0.814965 |
| case_mean_N3 | qcalc_lift_ratio | Tm_minus_Tsat_K | 3 | -0.820823 | -0.0182074 | 1.64229 | 0.673751 |
| case_mean_N3 | PM_lift_ratio | Tsub_K | 3 | -0.998825 | -0.0119549 | 2.31893 | 0.997651 |
| case_mean_N3 | PM_lift_ratio | Fcorr | 3 | 0.996082 | 33.1593 | -32.8423 | 0.99218 |
| case_mean_N3 | PM_lift_ratio | F1_formula_from_Tsub | 3 | 0.996082 | 33.1593 | -32.8423 | 0.99218 |
| case_mean_N3 | PM_lift_ratio | F_form | 3 | -0.444837 | -0.139685 | 1.8023 | 0.19788 |
| case_mean_N3 | PM_lift_ratio | x_eq | 3 | 0.44004 | 0.661937 | 1.71739 | 0.193635 |
| case_mean_N3 | PM_lift_ratio | z_DNB_over_DH | 3 | -0.972278 | -0.000916013 | 1.90243 | 0.945324 |
| case_mean_N3 | PM_lift_ratio | z_DNB_over_L | 3 | -0.961417 | -0.747487 | 2.29144 | 0.924323 |
| case_mean_N3 | PM_lift_ratio | L_over_DH | 3 | -0.84046 | -0.000893143 | 1.93399 | 0.706373 |
| case_mean_N3 | PM_lift_ratio | Tw_minus_Tsat_K | 3 | 0.902754 | 0.0139365 | 1.23608 | 0.814965 |
| case_mean_N3 | PM_lift_ratio | Tm_minus_Tsat_K | 3 | -0.820823 | -0.0182074 | 1.64229 | 0.673751 |

## 9. Exploratory model comparison

注：探索的な線形整理であり、係数・R2を補正式として採用しない。

| model | predictors | N | k_predictors | R2 | RMSE | note |
| --- | --- | --- | --- | --- | --- | --- |
| PM_F1 ~ Tsub + F_form + x_eq + z_DNB/DH | Tsub_K + F_form + x_eq + z_DNB_over_DH | 58 | 4 | 0.664947 | 0.06583 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ F_form + x_eq | F_form + x_eq | 58 | 2 | 0.457074 | 0.0837987 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ x_eq + z_DNB/DH | x_eq + z_DNB_over_DH | 58 | 2 | 0.394665 | 0.088484 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ L/DH | L_over_DH | 58 | 1 | 0.39002 | 0.0888228 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ Tsub + z_DNB/DH | Tsub_K + z_DNB_over_DH | 58 | 2 | 0.374499 | 0.0899458 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ F_form + z_DNB/DH | F_form + z_DNB_over_DH | 58 | 2 | 0.34189 | 0.0922605 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ Fcorr + z_DNB/DH | Fcorr + z_DNB_over_DH | 58 | 2 | 0.293601 | 0.0955854 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ z_DNB/DH | z_DNB_over_DH | 58 | 1 | 0.284414 | 0.096205 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ Tsub + F_form | Tsub_K + F_form | 58 | 2 | 0.280786 | 0.0964486 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ Fcorr + F_form | Fcorr + F_form | 58 | 2 | 0.240073 | 0.0991408 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ F_form | F_form | 58 | 1 | 0.239818 | 0.0991575 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ Fcorr + x_eq | Fcorr + x_eq | 58 | 2 | 0.142571 | 0.105309 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ z_DNB/L | z_DNB_over_L | 58 | 1 | 0.0783443 | 0.109182 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ Tsub + x_eq | Tsub_K + x_eq | 58 | 2 | 0.0404493 | 0.111404 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ x_eq | x_eq | 58 | 1 | 0.0385229 | 0.111516 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ Tsub | Tsub_K | 58 | 1 | 0.0198185 | 0.112595 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 ~ Fcorr | Fcorr | 58 | 1 | 0.00619721 | 0.113375 | DIAG_ONLY: 補正式係数として採用しない |

## 10. Interpretation flags

| item | status | value | reading |
| --- | --- | --- | --- |
| current_bundle切替 | OK |  | BT01/BT02はcurrent_bundleで再現済みなので、BT03もcurrent_bundle入力で進める。 |
| PM_F1_108差 | observed | delta108-mean161164=0.166359 | 108のF1後P/Mは161/164平均より高い。 |
| Fcorr差 | small | delta=0.00489451 | Fcorr差はPM差に比べて小さい。F1(Tsub)係数だけで108高めP/Mを説明するのは弱そう。 |
| F_form差 | large_but_not_F1 | delta=-0.503696 | F_form差は大きいが、F_formはF1ではない。非一様加熱・DNB位置・局所熱流束換算として読む。 |
| x_eq差 | state_difference | delta=0.104809 | 108はx_eqが0に近い。熱収支状態量として重要だが、単独原因とは断定しない。 |
| z_DNB/DH差 | history_candidate | delta=-184.431 | 108はDNB位置までの履歴長が短い。履歴長候補として見る。 |
| L/DH差 | history_or_geometry_candidate | delta=-173.233 | 108は全体L/DHも小さい。ただしz_DNB/DHと分けて読む。 |
| PM_F1_vs_Fcorr_R2 | diagnostic | R2=0.00619721 | PM_F1とFcorrの点群相関は弱い。 |
| PM_F1_vs_F_form_R2 | diagnostic | R2=0.239818 | PM_F1とF_formには中程度の対応があるが、原因とは断定しない。 |
| PM_F1_vs_x_eq_R2 | diagnostic | R2=0.0385229 | PM_F1とx_eqの点群相関は弱い。x_eq単独説明は弱い。 |
| PM_F1_vs_z_DNB/DH_R2 | diagnostic | R2=0.284414 | PM_F1とDNB履歴長には中程度の対応がある。 |
| PM_F1_vs_L/DH_R2 | diagnostic | R2=0.39002 | PM_F1とL/DHには比較的大きい対応があるが、ケース構造との交絡に注意。 |
| model_compare_best_DIAG_ONLY | diagnostic | best=PM_F1 ~ Tsub + F_form + x_eq + z_DNB/DH, R2=0.664947 | 探索的整理。補正式として採用しない。 |
| BT03判断 | hold |  | BT03では、F1(Tsub)だけでなく、F_form、x_eq、DNB履歴長、L/DHが同時に変化していることを確認する。単独原因の断定はしない。 |

## 11. 次アクション

1. BT03_interpretation_flagsを確認する。
2. Fcorr/F1(Tsub)だけで108高めP/Mを説明できるかを見る。
3. F_formはF1ではないため、非一様加熱・DNB位置・局所熱流束換算として読む。
4. z_DNB/DH、z_DNB/L、L/DHは履歴長・ケース構造として読む。
5. x_eqは単独因子ではなく、熱収支状態量としてF1(Tsub)見直し候補にする。
6. BT03の結果をworking logへ追記してから、必要ならBT04でF1(Tsub)代替候補の設計に進む。
