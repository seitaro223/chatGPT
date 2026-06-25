# BT05 Tsub-x_eq separation diagnostic

作成日時: 20260616

## 1. 目的

BT04では、PM_noF1およびF1効果量がL/DHやz_DNB/DHよりもTsub/x_eq側と対応することを確認した。BT05では、x_eqがTsubの単なる代理なのか、それともTsubにない追加説明力を持つのかを確認する。

## 2. 入力と出力

- 入力: `H52Q_current_bundle_input_v1_20260615_180822.xlsx`
- 出力Excel: `BT05_Tsub_xeq_separation_diagnostic_20260616_091354.xlsx`

## 3. 前提

- r8 resultブックは直接読まない。
- current_bundle_inputを読む。
- F2/F1F2は使わない。
- 比較対象はnoF1とF1のみ。
- バンドルでは `x_Mes = x_eq` として扱う。
- F1は単管基準のTsub補正である。
- BT05では補正式を作らず、F1(Tsub)も置換しない。

## 4. Case summary

| case_id | N | PM_noF1_mean | PM_F1_mean | delta_PM_mean | lift_ratio_mean | Tsub_K_mean | x_eq_mean | Fcorr_mean | F_form_mean | z_DNB_over_DH_mean | L_over_DH_mean |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | 14 | 0.621831 | 1.06679 | 0.444958 | 1.76502 | 46.0838 | -0.0139909 | 1.04382 | 0.669495 | 139.659 | 189.184 |
| 161 | 23 | 0.62098 | 0.908841 | 0.28786 | 1.55271 | 63.8439 | -0.0823228 | 1.03744 | 1 | 361.355 | 362.417 |
| 164 | 21 | 0.570923 | 0.892018 | 0.321095 | 1.6679 | 54.9549 | -0.155278 | 1.04041 | 1.34638 | 286.824 | 362.417 |

## 5. Tsub-x_eq relation

| relation | N | R2 | RMSE | slope | intercept | pearson_r | reading |
| --- | --- | --- | --- | --- | --- | --- | --- |
| x_eq ~ Tsub_K | 58 | 0.703842 | 0.0718926 | -0.00432078 | 0.151183 | -0.838953 | Tsubとx_eqがどの程度共変しているか。強い場合、x_eq相関はTsub代理の可能性がある。 |

## 6. Model comparison

注：探索的診断であり、係数・R2を補正式として採用しない。

| response | model | predictors | N | k_predictors | R2 | RMSE | beta_0 | beta_1 | note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PM_F1 | context: Tsub + x_eq + F_form + z_DNB/DH | Tsub_K + x_eq + F_form + z_DNB_over_DH | 58 | 4 | 0.664947 | 0.06583 | 1.50767 | -0.00377495 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 | Tsub + Fcorr + x_eq | Tsub_K + Fcorr + x_eq | 58 | 3 | 0.21557 | 0.100727 | -12.6542 | 0.00316518 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 | Tsub + Fcorr | Tsub_K + Fcorr | 58 | 2 | 0.199278 | 0.101767 | -12.8421 | 0.00407778 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 | Fcorr + x_eq | Fcorr + x_eq | 58 | 2 | 0.142571 | 0.105309 | -6.28405 | 6.90559 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 | Tsub + x_eq | Tsub_K + x_eq | 58 | 2 | 0.0404493 | 0.111404 | 0.940062 | -0.000357583 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 | x_eq only | x_eq | 58 | 1 | 0.0385229 | 0.111516 | 0.925289 | -0.168968 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 | Tsub only | Tsub_K | 58 | 1 | 0.0198185 | 0.112595 | 0.90571 | 0.000624172 | DIAG_ONLY: 補正式係数として採用しない |
| PM_F1 | Fcorr only | Fcorr | 58 | 1 | 0.00619721 | 0.113375 | -0.262426 | 1.15696 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 | context: Tsub + x_eq + F_form + z_DNB/DH | Tsub_K + x_eq + F_form + z_DNB_over_DH | 58 | 4 | 0.92066 | 0.0420903 | 0.643347 | 0.00272421 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 | Tsub + Fcorr + x_eq | Tsub_K + Fcorr + x_eq | 58 | 3 | 0.880379 | 0.0516822 | -10.9622 | 0.0075276 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 | Tsub + Fcorr | Tsub_K + Fcorr | 58 | 2 | 0.87681 | 0.0524475 | -11.0778 | 0.00808882 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 | Tsub + x_eq | Tsub_K + x_eq | 58 | 2 | 0.810382 | 0.0650695 | 0.330443 | 0.00460126 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 | Tsub only | Tsub_K | 58 | 1 | 0.805504 | 0.065901 | 0.308498 | 0.00522845 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 | Fcorr + x_eq | Fcorr + x_eq | 58 | 2 | 0.641219 | 0.0895059 | 4.18756 | -3.51253 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 | x_eq only | x_eq | 58 | 1 | 0.625626 | 0.0914303 | 0.520532 | -0.894689 | DIAG_ONLY: 補正式係数として採用しない |
| PM_noF1 | Fcorr only | Fcorr | 58 | 1 | 0.43674 | 0.112148 | 13.8757 | -12.7615 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM | context: Tsub + x_eq + F_form + z_DNB/DH | Tsub_K + x_eq + F_form + z_DNB_over_DH | 58 | 4 | 0.92756 | 0.0349081 | 0.864325 | -0.00649915 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM | Tsub + Fcorr + x_eq | Tsub_K + Fcorr + x_eq | 58 | 3 | 0.835106 | 0.0526669 | -1.69193 | -0.00436243 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM | Tsub + Fcorr | Tsub_K + Fcorr | 58 | 2 | 0.833249 | 0.0529627 | -1.7643 | -0.00401104 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM | Tsub + x_eq | Tsub_K + x_eq | 58 | 2 | 0.831247 | 0.0532797 | 0.609618 | -0.00495884 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM | Tsub only | Tsub_K | 58 | 1 | 0.829178 | 0.0536053 | 0.597212 | -0.00460428 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM | Fcorr + x_eq | Fcorr + x_eq | 58 | 2 | 0.728487 | 0.067582 | -10.4716 | 10.4181 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM | Fcorr only | Fcorr | 58 | 1 | 0.689611 | 0.0722585 | -14.1382 | 13.9185 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM | x_eq only | x_eq | 58 | 1 | 0.546402 | 0.0873517 | 0.404757 | 0.725721 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM_per_Fcorr_minus1 | context: Tsub + x_eq + F_form + z_DNB/DH | Tsub_K + x_eq + F_form + z_DNB_over_DH | 58 | 4 | 0.864536 | 0.804693 | 18.2105 | -0.117191 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM_per_Fcorr_minus1 | Tsub + Fcorr + x_eq | Tsub_K + Fcorr + x_eq | 58 | 3 | 0.71539 | 1.16639 | 83.3704 | -0.0976071 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM_per_Fcorr_minus1 | Tsub + Fcorr | Tsub_K + Fcorr | 58 | 2 | 0.711171 | 1.175 | 81.5316 | -0.0886791 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM_per_Fcorr_minus1 | Tsub + x_eq | Tsub_K + x_eq | 58 | 2 | 0.70249 | 1.19253 | 12.4391 | -0.0792262 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM_per_Fcorr_minus1 | Tsub only | Tsub_K | 58 | 1 | 0.698807 | 1.19989 | 12.1601 | -0.0712523 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM_per_Fcorr_minus1 | Fcorr + x_eq | Fcorr + x_eq | 58 | 2 | 0.527556 | 1.50277 | -113.07 | 117.086 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM_per_Fcorr_minus1 | Fcorr only | Fcorr | 58 | 1 | 0.464094 | 1.60052 | -192.039 | 192.475 | DIAG_ONLY: 補正式係数として採用しない |
| delta_PM_per_Fcorr_minus1 | x_eq only | x_eq | 58 | 1 | 0.446619 | 1.62641 | 9.1661 | 11.0602 | DIAG_ONLY: 補正式係数として採用しない |
| lift_minus1_per_Fcorr_minus1 | Tsub + Fcorr + x_eq | Tsub_K + Fcorr + x_eq | 58 | 3 | 0.987406 | 0.868783 | 990.413 | -0.516651 | DIAG_ONLY: 補正式係数として採用しない |
| lift_minus1_per_Fcorr_minus1 | Tsub + Fcorr | Tsub_K + Fcorr | 58 | 2 | 0.987251 | 0.874098 | 989.167 | -0.5106 | DIAG_ONLY: 補正式係数として採用しない |
| lift_minus1_per_Fcorr_minus1 | context: Tsub + x_eq + F_form + z_DNB/DH | Tsub_K + x_eq + F_form + z_DNB_over_DH | 58 | 4 | 0.800859 | 3.45469 | 30.0272 | -0.277459 | DIAG_ONLY: 補正式係数として採用しない |
| lift_minus1_per_Fcorr_minus1 | Tsub + x_eq | Tsub_K + x_eq | 58 | 2 | 0.798924 | 3.47143 | 30.3868 | -0.267874 | DIAG_ONLY: 補正式係数として採用しない |
| lift_minus1_per_Fcorr_minus1 | Tsub only | Tsub_K | 58 | 1 | 0.798908 | 3.47157 | 30.4529 | -0.269761 | DIAG_ONLY: 補正式係数として採用しない |
| lift_minus1_per_Fcorr_minus1 | Fcorr + x_eq | Fcorr + x_eq | 58 | 2 | 0.567659 | 5.09028 | -49.3822 | 65.808 | DIAG_ONLY: 補正式係数として採用しない |
| lift_minus1_per_Fcorr_minus1 | x_eq only | x_eq | 58 | 1 | 0.56562 | 5.10227 | 19.3203 | 44.0726 | DIAG_ONLY: 補正式係数として採用しない |
| lift_minus1_per_Fcorr_minus1 | Fcorr only | Fcorr | 58 | 1 | 0.333926 | 6.31815 | -586.006 | 578.105 | DIAG_ONLY: 補正式係数として採用しない |
| lift_ratio | Tsub + Fcorr + x_eq | Tsub_K + Fcorr + x_eq | 58 | 3 | 0.994058 | 0.0288262 | 37.4815 | -0.0227853 | DIAG_ONLY: 補正式係数として採用しない |
| lift_ratio | Tsub + Fcorr | Tsub_K + Fcorr | 58 | 2 | 0.993931 | 0.0291335 | 37.4269 | -0.0225199 | DIAG_ONLY: 補正式係数として採用しない |
| lift_ratio | context: Tsub + x_eq + F_form + z_DNB/DH | Tsub_K + x_eq + F_form + z_DNB_over_DH | 58 | 4 | 0.887295 | 0.125547 | 2.43077 | -0.0142451 | DIAG_ONLY: 補正式係数として採用しない |
| lift_ratio | Tsub + x_eq | Tsub_K + x_eq | 58 | 2 | 0.886312 | 0.126093 | 2.41801 | -0.013699 | DIAG_ONLY: 補正式係数として採用しない |
| lift_ratio | Tsub only | Tsub_K | 58 | 1 | 0.886311 | 0.126094 | 2.41894 | -0.0137256 | DIAG_ONLY: 補正式係数として採用しない |
| lift_ratio | Fcorr + x_eq | Fcorr + x_eq | 58 | 2 | 0.644204 | 0.223067 | -8.37531 | 9.79649 | DIAG_ONLY: 補正式係数として採用しない |
| lift_ratio | x_eq only | x_eq | 58 | 1 | 0.624839 | 0.229057 | 1.85207 | 2.23767 | DIAG_ONLY: 補正式係数として採用しない |
| lift_ratio | Fcorr only | Fcorr | 58 | 1 | 0.449316 | 0.277515 | -32.0459 | 32.394 | DIAG_ONLY: 補正式係数として採用しない |

## 7. Incremental R2

x_eq after Tsub が大きければ、x_eqはTsubにない追加説明力を持つ可能性がある。Tsub after x_eq が大きければ、Tsub側に残る説明力が大きい。

| response | test | base_predictors | full_predictors | N | R2_base | R2_full | delta_R2 | RMSE_base | RMSE_full | delta_RMSE | note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PM_F1 | Tsub_after_x_eq | x_eq | x_eq + Tsub_K | 58 | 0.0385229 | 0.0404493 | 0.00192636 | 0.111516 | 0.111404 | -0.000111769 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| PM_F1 | x_eq_after_Fcorr | Fcorr | Fcorr + x_eq | 58 | 0.00619721 | 0.142571 | 0.136374 | 0.113375 | 0.105309 | -0.00806583 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| PM_F1 | x_eq_after_Tsub | Tsub_K | Tsub_K + x_eq | 58 | 0.0198185 | 0.0404493 | 0.0206308 | 0.112595 | 0.111404 | -0.00119125 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| PM_F1 | x_eq_after_Tsub_and_Fcorr | Tsub_K + Fcorr | Tsub_K + Fcorr + x_eq | 58 | 0.199278 | 0.21557 | 0.0162917 | 0.101767 | 0.100727 | -0.00104061 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| PM_noF1 | Tsub_after_x_eq | x_eq | x_eq + Tsub_K | 58 | 0.625626 | 0.810382 | 0.184756 | 0.0914303 | 0.0650695 | -0.0263608 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| PM_noF1 | x_eq_after_Fcorr | Fcorr | Fcorr + x_eq | 58 | 0.43674 | 0.641219 | 0.204479 | 0.112148 | 0.0895059 | -0.0226421 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| PM_noF1 | x_eq_after_Tsub | Tsub_K | Tsub_K + x_eq | 58 | 0.805504 | 0.810382 | 0.00487727 | 0.065901 | 0.0650695 | -0.00083153 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| PM_noF1 | x_eq_after_Tsub_and_Fcorr | Tsub_K + Fcorr | Tsub_K + Fcorr + x_eq | 58 | 0.87681 | 0.880379 | 0.00356886 | 0.0524475 | 0.0516822 | -0.000765295 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| delta_PM | Tsub_after_x_eq | x_eq | x_eq + Tsub_K | 58 | 0.546402 | 0.831247 | 0.284844 | 0.0873517 | 0.0532797 | -0.0340719 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| delta_PM | x_eq_after_Fcorr | Fcorr | Fcorr + x_eq | 58 | 0.689611 | 0.728487 | 0.0388761 | 0.0722585 | 0.067582 | -0.00467651 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| delta_PM | x_eq_after_Tsub | Tsub_K | Tsub_K + x_eq | 58 | 0.829178 | 0.831247 | 0.00206893 | 0.0536053 | 0.0532797 | -0.000325612 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| delta_PM | x_eq_after_Tsub_and_Fcorr | Tsub_K + Fcorr | Tsub_K + Fcorr + x_eq | 58 | 0.833249 | 0.835106 | 0.00185705 | 0.0529627 | 0.0526669 | -0.000295739 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| delta_PM_per_Fcorr_minus1 | Tsub_after_x_eq | x_eq | x_eq + Tsub_K | 58 | 0.446619 | 0.70249 | 0.255871 | 1.62641 | 1.19253 | -0.433882 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| delta_PM_per_Fcorr_minus1 | x_eq_after_Fcorr | Fcorr | Fcorr + x_eq | 58 | 0.464094 | 0.527556 | 0.0634613 | 1.60052 | 1.50277 | -0.097751 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| delta_PM_per_Fcorr_minus1 | x_eq_after_Tsub | Tsub_K | Tsub_K + x_eq | 58 | 0.698807 | 0.70249 | 0.00368258 | 1.19989 | 1.19253 | -0.00735787 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| delta_PM_per_Fcorr_minus1 | x_eq_after_Tsub_and_Fcorr | Tsub_K + Fcorr | Tsub_K + Fcorr + x_eq | 58 | 0.711171 | 0.71539 | 0.00421899 | 1.175 | 1.16639 | -0.00861333 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| lift_minus1_per_Fcorr_minus1 | Tsub_after_x_eq | x_eq | x_eq + Tsub_K | 58 | 0.56562 | 0.798924 | 0.233304 | 5.10227 | 3.47143 | -1.63084 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| lift_minus1_per_Fcorr_minus1 | x_eq_after_Fcorr | Fcorr | Fcorr + x_eq | 58 | 0.333926 | 0.567659 | 0.233734 | 6.31815 | 5.09028 | -1.22787 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| lift_minus1_per_Fcorr_minus1 | x_eq_after_Tsub | Tsub_K | Tsub_K + x_eq | 58 | 0.798908 | 0.798924 | 1.64528e-05 | 3.47157 | 3.47143 | -0.00014202 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| lift_minus1_per_Fcorr_minus1 | x_eq_after_Tsub_and_Fcorr | Tsub_K + Fcorr | Tsub_K + Fcorr + x_eq | 58 | 0.987251 | 0.987406 | 0.000154593 | 0.874098 | 0.868783 | -0.00531593 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| lift_ratio | Tsub_after_x_eq | x_eq | x_eq + Tsub_K | 58 | 0.624839 | 0.886312 | 0.261474 | 0.229057 | 0.126093 | -0.102964 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| lift_ratio | x_eq_after_Fcorr | Fcorr | Fcorr + x_eq | 58 | 0.449316 | 0.644204 | 0.194888 | 0.277515 | 0.223067 | -0.0544478 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| lift_ratio | x_eq_after_Tsub | Tsub_K | Tsub_K + x_eq | 58 | 0.886311 | 0.886312 | 1.39468e-06 | 0.126094 | 0.126093 | -7.73431e-07 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| lift_ratio | x_eq_after_Tsub_and_Fcorr | Tsub_K + Fcorr | Tsub_K + Fcorr + x_eq | 58 | 0.993931 | 0.994058 | 0.000127355 | 0.0291335 | 0.0288262 | -0.0003073 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |

## 8. Residualized correlations

Tsubで説明した後の残差がx_eqとまだ対応するか、またはx_eqで説明した後の残差がTsubとまだ対応するかを確認する。

| response | test | N | pearson_r | slope | intercept | R2 | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PM_F1 | res_after_Fcorr_vs_x_eq | 58 | -0.254304 | -0.218246 | -0.0201318 | 0.0646703 | residualized diagnostic only |
| PM_F1 | res_after_Tsub_Fcorr_vs_x_eq | 58 | -0.0775694 | -0.0597552 | -0.00551204 | 0.00601702 | residualized diagnostic only |
| PM_F1 | res_after_Tsub_vs_x_eq | 58 | -0.0789526 | -0.0672921 | -0.00620727 | 0.00623352 | residualized diagnostic only |
| PM_F1 | res_after_x_eq_vs_Tsub | 58 | -0.0243591 | -0.000105901 | 0.00596631 | 0.000593366 | residualized diagnostic only |
| PM_noF1 | res_after_Fcorr_vs_x_eq | 58 | -0.413625 | -0.351136 | -0.0323901 | 0.171085 | residualized diagnostic only |
| PM_noF1 | res_after_Tsub_Fcorr_vs_x_eq | 58 | -0.0925605 | -0.0367475 | -0.00338972 | 0.00856744 | residualized diagnostic only |
| PM_noF1 | res_after_Tsub_vs_x_eq | 58 | -0.0861778 | -0.0429898 | -0.00396553 | 0.00742661 | residualized diagnostic only |
| PM_noF1 | res_after_x_eq_vs_Tsub | 58 | 0.382303 | 0.0013627 | -0.0767725 | 0.146156 | residualized diagnostic only |
| delta_PM | res_after_Fcorr_vs_x_eq | 58 | 0.242955 | 0.13289 | 0.0122582 | 0.0590269 | residualized diagnostic only |
| delta_PM | res_after_Tsub_Fcorr_vs_x_eq | 58 | -0.0573886 | -0.0230077 | -0.00212232 | 0.00329346 | residualized diagnostic only |
| delta_PM | res_after_Tsub_vs_x_eq | 58 | -0.0598911 | -0.0243024 | -0.00224174 | 0.00358695 | residualized diagnostic only |
| delta_PM | res_after_x_eq_vs_Tsub | 58 | -0.431251 | -0.0014686 | 0.0827388 | 0.185977 | residualized diagnostic only |
| delta_PM_per_Fcorr_minus1 | res_after_Fcorr_vs_x_eq | 58 | 0.236236 | 2.86211 | 0.264011 | 0.0558076 | residualized diagnostic only |
| delta_PM_per_Fcorr_minus1 | res_after_Tsub_Fcorr_vs_x_eq | 58 | -0.0657253 | -0.584586 | -0.0539243 | 0.00431981 | residualized diagnostic only |
| delta_PM_per_Fcorr_minus1 | res_after_Tsub_vs_x_eq | 58 | -0.060175 | -0.546555 | -0.0504162 | 0.00362103 | residualized diagnostic only |
| delta_PM_per_Fcorr_minus1 | res_after_x_eq_vs_Tsub | 58 | -0.37005 | -0.0234635 | 1.3219 | 0.136937 | residualized diagnostic only |
| lift_minus1_per_Fcorr_minus1 | res_after_Fcorr_vs_x_eq | 58 | 0.406664 | 19.4493 | 1.79407 | 0.165376 | residualized diagnostic only |
| lift_minus1_per_Fcorr_minus1 | res_after_Tsub_Fcorr_vs_x_eq | 58 | -0.0598841 | -0.396232 | -0.0365499 | 0.0035861 | residualized diagnostic only |
| lift_minus1_per_Fcorr_minus1 | res_after_Tsub_vs_x_eq | 58 | 0.00492248 | 0.129357 | 0.0119323 | 2.42309e-05 | residualized diagnostic only |
| lift_minus1_per_Fcorr_minus1 | res_after_x_eq_vs_Tsub | 58 | -0.39883 | -0.079333 | 4.4695 | 0.159066 | residualized diagnostic only |
| lift_ratio | res_after_Fcorr_vs_x_eq | 58 | 0.408393 | 0.857911 | 0.0791368 | 0.166785 | residualized diagnostic only |
| lift_ratio | res_after_Tsub_Fcorr_vs_x_eq | 58 | -0.0787771 | -0.0173728 | -0.00160253 | 0.00620583 | residualized diagnostic only |
| lift_ratio | res_after_Tsub_vs_x_eq | 58 | 0.00190607 | 0.00181933 | 0.000167822 | 3.63312e-06 | residualized diagnostic only |
| lift_ratio | res_after_x_eq_vs_Tsub | 58 | -0.454325 | -0.00405708 | 0.22857 | 0.206411 | residualized diagnostic only |

## 9. PM_noF1 focus

| response | test | base_predictors | full_predictors | N | R2_base | R2_full | delta_R2 | RMSE_base | RMSE_full | delta_RMSE | note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PM_noF1 | Tsub_after_x_eq | x_eq | x_eq + Tsub_K | 58 | 0.625626 | 0.810382 | 0.184756 | 0.0914303 | 0.0650695 | -0.0263608 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| PM_noF1 | x_eq_after_Fcorr | Fcorr | Fcorr + x_eq | 58 | 0.43674 | 0.641219 | 0.204479 | 0.112148 | 0.0895059 | -0.0226421 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| PM_noF1 | x_eq_after_Tsub | Tsub_K | Tsub_K + x_eq | 58 | 0.805504 | 0.810382 | 0.00487727 | 0.065901 | 0.0650695 | -0.00083153 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| PM_noF1 | x_eq_after_Tsub_and_Fcorr | Tsub_K + Fcorr | Tsub_K + Fcorr + x_eq | 58 | 0.87681 | 0.880379 | 0.00356886 | 0.0524475 | 0.0516822 | -0.000765295 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |

## 10. F1 effect focus

| response | test | base_predictors | full_predictors | N | R2_base | R2_full | delta_R2 | RMSE_base | RMSE_full | delta_RMSE | note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| delta_PM | Tsub_after_x_eq | x_eq | x_eq + Tsub_K | 58 | 0.546402 | 0.831247 | 0.284844 | 0.0873517 | 0.0532797 | -0.0340719 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| delta_PM | x_eq_after_Fcorr | Fcorr | Fcorr + x_eq | 58 | 0.689611 | 0.728487 | 0.0388761 | 0.0722585 | 0.067582 | -0.00467651 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| delta_PM | x_eq_after_Tsub | Tsub_K | Tsub_K + x_eq | 58 | 0.829178 | 0.831247 | 0.00206893 | 0.0536053 | 0.0532797 | -0.000325612 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| delta_PM | x_eq_after_Tsub_and_Fcorr | Tsub_K + Fcorr | Tsub_K + Fcorr + x_eq | 58 | 0.833249 | 0.835106 | 0.00185705 | 0.0529627 | 0.0526669 | -0.000295739 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| lift_ratio | Tsub_after_x_eq | x_eq | x_eq + Tsub_K | 58 | 0.624839 | 0.886312 | 0.261474 | 0.229057 | 0.126093 | -0.102964 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| lift_ratio | x_eq_after_Fcorr | Fcorr | Fcorr + x_eq | 58 | 0.449316 | 0.644204 | 0.194888 | 0.277515 | 0.223067 | -0.0544478 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| lift_ratio | x_eq_after_Tsub | Tsub_K | Tsub_K + x_eq | 58 | 0.886311 | 0.886312 | 1.39468e-06 | 0.126094 | 0.126093 | -7.73431e-07 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |
| lift_ratio | x_eq_after_Tsub_and_Fcorr | Tsub_K + Fcorr | Tsub_K + Fcorr + x_eq | 58 | 0.993931 | 0.994058 | 0.000127355 | 0.0291335 | 0.0288262 | -0.0003073 | DIAG_ONLY: 追加説明力の確認であり補正式ではない |

## 11. Interpretation flags

| item | status | value | reading |
| --- | --- | --- | --- |
| BT05位置づけ | OK |  | Tsubとx_eqの切り分け診断。F1置換や補正式化ではない。 |
| Tsub_xeq_relation | diagnostic | R2=0.703842 | Tsubとx_eqの共変が強いほど、x_eq相関はTsub代理の可能性がある。 |
| compare_PM_noF1 | diagnostic | R2_Tsub=0.805504, R2_xeq=0.625626, R2_Tsub_xeq=0.810382 | Tsub単独、x_eq単独、両者併用の説明力を比較する。 |
| increment_PM_noF1 | diagnostic | dR2_xeq_after_Tsub=0.00487727, dR2_Tsub_after_xeq=0.184756 | x_eqがTsub後に残るか、Tsubがx_eq後に残るかを見る。 |
| residualized_PM_noF1 | diagnostic | resAfterTsub_vs_xeq_R2=0.00742661, resAfterXeq_vs_Tsub_R2=0.146156 | 残差化しても相関が残るかを見る。これも補正式ではない。 |
| compare_delta_PM | diagnostic | R2_Tsub=0.829178, R2_xeq=0.546402, R2_Tsub_xeq=0.831247 | Tsub単独、x_eq単独、両者併用の説明力を比較する。 |
| increment_delta_PM | diagnostic | dR2_xeq_after_Tsub=0.00206893, dR2_Tsub_after_xeq=0.284844 | x_eqがTsub後に残るか、Tsubがx_eq後に残るかを見る。 |
| residualized_delta_PM | diagnostic | resAfterTsub_vs_xeq_R2=0.00358695, resAfterXeq_vs_Tsub_R2=0.185977 | 残差化しても相関が残るかを見る。これも補正式ではない。 |
| compare_lift_ratio | diagnostic | R2_Tsub=0.886311, R2_xeq=0.624839, R2_Tsub_xeq=0.886312 | Tsub単独、x_eq単独、両者併用の説明力を比較する。 |
| increment_lift_ratio | diagnostic | dR2_xeq_after_Tsub=1.39468e-06, dR2_Tsub_after_xeq=0.261474 | x_eqがTsub後に残るか、Tsubがx_eq後に残るかを見る。 |
| residualized_lift_ratio | diagnostic | resAfterTsub_vs_xeq_R2=3.63312e-06, resAfterXeq_vs_Tsub_R2=0.206411 | 残差化しても相関が残るかを見る。これも補正式ではない。 |
| compare_PM_F1 | diagnostic | R2_Tsub=0.0198185, R2_xeq=0.0385229, R2_Tsub_xeq=0.0404493 | Tsub単独、x_eq単独、両者併用の説明力を比較する。 |
| increment_PM_F1 | diagnostic | dR2_xeq_after_Tsub=0.0206308, dR2_Tsub_after_xeq=0.00192636 | x_eqがTsub後に残るか、Tsubがx_eq後に残るかを見る。 |
| residualized_PM_F1 | diagnostic | resAfterTsub_vs_xeq_R2=0.00623352, resAfterXeq_vs_Tsub_R2=0.000593366 | 残差化しても相関が残るかを見る。これも補正式ではない。 |
| F1_effect_xeq_after_Fcorr_delta_PM | diagnostic | dR2_xeq_after_Fcorr=0.0388761, dR2_xeq_after_Tsub_Fcorr=0.00185705 | F1効果量について、現行FcorrまたはTsub+Fcorrで説明した後にx_eqが残るかを見る。 |
| F1_effect_xeq_after_Fcorr_lift_ratio | diagnostic | dR2_xeq_after_Fcorr=0.194888, dR2_xeq_after_Tsub_Fcorr=0.000127355 | F1効果量について、現行FcorrまたはTsub+Fcorrで説明した後にx_eqが残るかを見る。 |
| BT05判断ゲート | hold |  | x_eqに追加説明力が小さければ、F1(Tsub)置換は急がない。追加説明力が残る場合のみ、BT06で診断項としての扱いを設計する。 |

## 12. 次アクション

1. BT05_interpretation_flagsを確認する。
2. PM_noF1で、x_eq after Tsub がどの程度残るか確認する。
3. delta_PM / lift_ratioで、x_eq after Tsub または x_eq after Fcorr がどの程度残るか確認する。
4. x_eqがTsubの代理に近いなら、F1(Tsub)置換は急がない。
5. x_eqに追加説明力があるなら、BT06でF1(Tsub)を維持したままx_eqを診断項としてどう扱うか設計する。
