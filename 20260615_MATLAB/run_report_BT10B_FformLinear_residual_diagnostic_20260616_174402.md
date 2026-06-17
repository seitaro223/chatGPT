# BT10-B FformLinear_v1 residual diagnostic

作成日時: 20260616

## 1. 目的

BT09-Bで再計算したFformLinear_v1版のnoF1/F1マクロブックを読み、F1後の残差構造を再診断する。補正式は作らず、Tsub、x_eq、Fform_linear、DNB位置、L/DH、ケース構造との対応を見る。

## 2. 入力

- noF1 FformLinear: `celataモデル_簡易計算_単管_櫻井検算r125_バンドルF1なし_FformLinear_v1_20260616_152518.xlsm`
- F1 FformLinear: `celataモデル_簡易計算_単管_櫻井検算r126_バンドルF1あり_FformLinear_v1_20260616_152518.xlsm`

## 3. 前提

```text
- F1(Tsub)は維持する。
- F1(Tsub)をF(x_eq)へ置換しない。
- F_formはF1ではない。
- F_formは非一様加熱分布をDNB位置の局所熱流束基準へ換算する係数である。
- qMは結果側量なので補正式入力には使わない。
- R2が高いモデルを補正式として採用しない。
```

## 4. Bundle summary

| Bundle | N | No_min | No_max | PM_noF1_linear_mean | PM_F1_linear_mean | err_F1_linear_mean | delta_PM_linear_mean | lift_ratio_linear_mean | qP_F1_MWm2_mean | qM_MWm2_mean | Fform_linear_mean | Tsub_mean | Fcorr_mean | x_eq_mean | z_DNB_DH_mean | z_DNB_L_mean | L_DH_mean |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108 | 14 | 229 | 254 | 0.65304894 | 1.1232232 | 0.1232232 | 0.47017426 | 1.7702032 | 3.408174 | 3.0362535 | 0.63608627 | 46.083809 | 1.04382 | -0.013990909 | 139.65871 | 0.73821634 | 189.18399 |
| 161 | 23 | 268 | 317 | 0.62098048 | 0.90884087 | -0.091159126 | 0.2878604 | 1.5527097 | 1.29514 | 1.4135983 | 1 | 63.843926 | 1.0374395 | -0.082322824 | 361.35516 | 0.99707054 | 362.41684 |
| 164 | 21 | 319 | 381 | 0.59786191 | 0.93956052 | -0.060439484 | 0.34169861 | 1.672137 | 1.1240311 | 1.1887617 | 1.2798813 | 54.954868 | 1.0404115 | -0.15527776 | 286.82405 | 0.79142031 | 362.41684 |

## 5. Case summary

| case_label | N | No_min | No_max | PM_noF1_linear_mean | PM_F1_linear_mean | err_F1_linear_mean | delta_PM_linear_mean | lift_ratio_linear_mean | qP_F1_MWm2_mean | qM_MWm2_mean | Fform_linear_mean | Tsub_mean | Fcorr_mean | x_eq_mean | z_DNB_DH_mean | z_DNB_L_mean | L_DH_mean |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108_70in | 12 | 229 | 254 | 0.65672421 | 1.1166142 | 0.11661421 | 0.45989 | 1.7564697 | 3.431708 | 3.0738852 | 0.61982066 | 47.1332 | 1.0435061 | -0.011302126 | 137.96929 | 0.7292863 | 189.18399 |
| 108_76in | 2 | 252 | 253 | 0.63099733 | 1.1628772 | 0.16287716 | 0.53187983 | 1.8526041 | 3.2669701 | 2.8104627 | 0.73367994 | 39.787462 | 1.0457036 | -0.030123609 | 149.79523 | 0.79179655 | 189.18399 |
| 161_uniform | 23 | 268 | 317 | 0.62098048 | 0.90884087 | -0.091159126 | 0.2878604 | 1.5527097 | 1.29514 | 1.4135983 | 1 | 63.843926 | 1.0374395 | -0.082322824 | 361.35516 | 0.99707054 | 362.41684 |
| 164_112in | 1 | 339 | 339 | 0.33017459 | 0.79743867 | -0.20256133 | 0.46726408 | 2.415203 | 0.90756354 | 1.1380982 | 0.8776443 | 19.778147 | 1.0427746 | 0.095434412 | 241.62255 | 0.66669791 | 362.41684 |
| 164_134in_normal | 20 | 319 | 381 | 0.61124627 | 0.94666661 | -0.053333392 | 0.33542033 | 1.6349837 | 1.1348545 | 1.1912949 | 1.2999932 | 56.713704 | 1.0402933 | -0.16781337 | 289.08413 | 0.79765643 | 362.41684 |

## 6. Bundle/case contrasts

| contrast | A_bundle | B_bundles | diff_PM_F1_linear | diff_err_F1_linear | diff_delta_PM_linear | diff_lift_ratio_linear | diff_Fform_linear | diff_Tsub | diff_x_eq | diff_z_DNB_DH | diff_z_DNB_L | diff_L_DH |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 108_minus_mean_161_164 | 108 | 161,164 | 0.19902251 | 0.19902251 | 0.15539476 | 0.15777984 | -0.50385439 | -13.315588 | 0.10480938 | -184.43089 | -0.15602909 | -173.23285 |
| 164_minus_mean_108_161 | 164 | 108,161 | -0.076471522 | -0.076471522 | -0.037318723 | 0.010680532 | 0.46183818 | -0.0089993124 | -0.10712089 | 36.317116 | -0.076223126 | 86.616425 |
| 161_minus_mean_108_164 | 161 | 108,164 | -0.12255099 | -0.12255099 | -0.11807604 | -0.16846037 | 0.042016206 | 13.324587 | 0.0023115104 | 148.11378 | 0.23225222 | 86.616425 |

## 7. Single predictor R2

| target | predictor | N | R2 | slope | note |
| --- | --- | --- | --- | --- | --- |
| PM_noF1_linear | Tsub | 58 | 0.76972761 | 0.0051701821 | diagnostic |
| PM_noF1_linear | Fcorr | 58 | 0.40139795 | -12.375865 | diagnostic |
| PM_noF1_linear | x_eq | 58 | 0.6272693 | -0.90623278 | diagnostic |
| PM_noF1_linear | Fform_linear | 58 | 0.0074581732 | -0.051820917 | nonuniform_heating_conversion_not_F1 |
| PM_noF1_linear | z_DNB_DH | 58 | 0.0051217839 | -0.00012545137 | history_or_geometry_proxy_diagnostic |
| PM_noF1_linear | z_DNB_L | 58 | 0.00011820959 | 0.014342383 | history_or_geometry_proxy_diagnostic |
| PM_noF1_linear | L_DH | 58 | 0.014888672 | -0.00024881148 | history_or_geometry_proxy_diagnostic |
| PM_noF1_linear | qM_MWm2 | 58 | 0.11510475 | 0.065327883 | diagnostic_only_result_side |
| PM_noF1_linear | qP_F1_MWm2 | 58 | 0.12690114 | 0.054672879 | diagnostic_only_prediction_side |
| PM_F1_linear | Tsub | 58 | 0.0063023797 | 0.00038305746 | diagnostic |
| PM_F1_linear | Fcorr | 58 | 0.01668268 | 2.0658331 | diagnostic |
| PM_F1_linear | x_eq | 58 | 0.032173408 | -0.16804888 | diagnostic |
| PM_F1_linear | Fform_linear | 58 | 0.24322033 | -0.24230542 | nonuniform_heating_conversion_not_F1 |
| PM_F1_linear | z_DNB_DH | 58 | 0.44351822 | -0.00095586127 | history_or_geometry_proxy_diagnostic |
| PM_F1_linear | z_DNB_L | 58 | 0.22095238 | -0.50771342 | history_or_geometry_proxy_diagnostic |
| PM_F1_linear | L_DH | 58 | 0.47681733 | -0.001152903 | history_or_geometry_proxy_diagnostic |
| PM_F1_linear | qM_MWm2 | 58 | 0.49167126 | 0.11055126 | diagnostic_only_result_side |
| PM_F1_linear | qP_F1_MWm2 | 58 | 0.60848407 | 0.098025288 | diagnostic_only_prediction_side |
| err_F1_linear | Tsub | 58 | 0.0063023797 | 0.00038305746 | diagnostic |
| err_F1_linear | Fcorr | 58 | 0.01668268 | 2.0658331 | diagnostic |
| err_F1_linear | x_eq | 58 | 0.032173408 | -0.16804888 | diagnostic |
| err_F1_linear | Fform_linear | 58 | 0.24322033 | -0.24230542 | nonuniform_heating_conversion_not_F1 |
| err_F1_linear | z_DNB_DH | 58 | 0.44351822 | -0.00095586127 | history_or_geometry_proxy_diagnostic |
| err_F1_linear | z_DNB_L | 58 | 0.22095238 | -0.50771342 | history_or_geometry_proxy_diagnostic |
| err_F1_linear | L_DH | 58 | 0.47681733 | -0.001152903 | history_or_geometry_proxy_diagnostic |
| err_F1_linear | qM_MWm2 | 58 | 0.49167126 | 0.11055126 | diagnostic_only_result_side |
| err_F1_linear | qP_F1_MWm2 | 58 | 0.60848407 | 0.098025288 | diagnostic_only_prediction_side |
| delta_PM_linear | Tsub | 58 | 0.81541712 | -0.0047871247 | diagnostic |
| delta_PM_linear | Fcorr | 58 | 0.67540694 | 14.441698 | diagnostic |
| delta_PM_linear | x_eq | 58 | 0.51429062 | 0.7381839 | diagnostic |
| delta_PM_linear | Fform_linear | 58 | 0.12452213 | -0.1904845 | nonuniform_heating_conversion_not_F1 |
| delta_PM_linear | z_DNB_DH | 58 | 0.27730672 | -0.00083040989 | history_or_geometry_proxy_diagnostic |
| delta_PM_linear | z_DNB_L | 58 | 0.19353027 | -0.52205581 | history_or_geometry_proxy_diagnostic |
| delta_PM_linear | L_DH | 58 | 0.24290974 | -0.00090409156 | history_or_geometry_proxy_diagnostic |
| delta_PM_linear | qM_MWm2 | 58 | 0.068159607 | 0.04522338 | diagnostic_only_result_side |
| delta_PM_linear | qP_F1_MWm2 | 58 | 0.098594584 | 0.043352409 | diagnostic_only_prediction_side |
| lift_ratio_linear | Tsub | 58 | 0.8870762 | -0.013657807 | diagnostic |
| lift_ratio_linear | Fcorr | 58 | 0.4515401 | 32.299765 | diagnostic |
| lift_ratio_linear | x_eq | 58 | 0.61875983 | 2.2148128 | diagnostic |
| lift_ratio_linear | Fform_linear | 58 | 0.020396325 | -0.21087643 | nonuniform_heating_conversion_not_F1 |
| lift_ratio_linear | z_DNB_DH | 58 | 0.058065867 | -0.0010394138 | history_or_geometry_proxy_diagnostic |
| lift_ratio_linear | z_DNB_L | 58 | 0.065057003 | -0.82795208 | history_or_geometry_proxy_diagnostic |
| lift_ratio_linear | L_DH | 58 | 0.034091518 | -0.00092646457 | history_or_geometry_proxy_diagnostic |
| lift_ratio_linear | qM_MWm2 | 58 | 0.0038956723 | -0.029573749 | diagnostic_only_result_side |
| lift_ratio_linear | qP_F1_MWm2 | 58 | 0.0022406241 | -0.017876681 | diagnostic_only_prediction_side |

## 8. Model R2

| target | model_name | predictors | N | R2 | RMSE | note |
| --- | --- | --- | --- | --- | --- | --- |
| PM_noF1_linear | PM_noF1 ~ Tsub | Tsub | 58 | 0.76972761 | 0.072536398 | F1前の元誤差とTsub |
| PM_noF1_linear | PM_noF1 ~ x_eq | x_eq | 58 | 0.6272693 | 0.092285323 | F1前の元誤差とx_eq |
| PM_noF1_linear | PM_noF1 ~ Tsub + x_eq | Tsub+x_eq | 58 | 0.78029968 | 0.070851719 | x_eqの追加説明力を見る |
| PM_F1_linear | PM_F1 ~ Tsub | Tsub | 58 | 0.0063023797 | 0.12337765 | F1後残差とTsub |
| PM_F1_linear | PM_F1 ~ x_eq | x_eq | 58 | 0.032173408 | 0.12176099 | F1後残差とx_eq |
| PM_F1_linear | PM_F1 ~ Fform | Fform_linear | 58 | 0.24322033 | 0.10766985 | F1後残差と非一様加熱換算 |
| PM_F1_linear | PM_F1 ~ zDNB_DH | z_DNB_DH | 58 | 0.44351822 | 0.092328304 | F1後残差とDNBまでの履歴長 |
| PM_F1_linear | PM_F1 ~ L_DH | L_DH | 58 | 0.47681733 | 0.089523295 | F1後残差とL/DH |
| PM_F1_linear | PM_F1 ~ Fform + zDNB_DH | Fform_linear+z_DNB_DH | 58 | 0.4546355 | 0.091401394 | Fformと履歴長 |
| PM_F1_linear | PM_F1 ~ Tsub + x_eq + Fform + zDNB_DH | Tsub+x_eq+Fform_linear+z_DNB_DH | 58 | 0.72224781 | 0.065228611 | 探索診断。補正式ではない |
| PM_F1_linear | PM_F1 ~ Tsub + x_eq + Fform + L_DH | Tsub+x_eq+Fform_linear+L_DH | 58 | 0.74355344 | 0.062676945 | 探索診断。補正式ではない |
| err_F1_linear | err_F1 ~ Fform | Fform_linear | 58 | 0.24322033 | 0.10766985 | F1後誤差とFform |
| err_F1_linear | err_F1 ~ zDNB_DH | z_DNB_DH | 58 | 0.44351822 | 0.092328304 | F1後誤差と履歴長 |
| err_F1_linear | err_F1 ~ L_DH | L_DH | 58 | 0.47681733 | 0.089523295 | F1後誤差とL/DH |
| err_F1_linear | err_F1 ~ Fform + zDNB_DH | Fform_linear+z_DNB_DH | 58 | 0.4546355 | 0.091401394 | 複合診断 |
| err_F1_linear | err_F1 ~ Fform + zDNB_L + L_DH | Fform_linear+z_DNB_L+L_DH | 58 | 0.51647688 | 0.086063302 | FformとDNB位置構造 |
| delta_PM_linear | delta_PM ~ Tsub | Tsub | 58 | 0.81541712 | 0.05842225 | F1持ち上げ量とTsub |
| delta_PM_linear | delta_PM ~ Fcorr | Fcorr | 58 | 0.67540694 | 0.077473323 | F1持ち上げ量とFcorr |
| delta_PM_linear | delta_PM ~ x_eq | x_eq | 58 | 0.51429062 | 0.094769985 | F1持ち上げ量とx_eq |
| delta_PM_linear | delta_PM ~ Tsub + x_eq | Tsub+x_eq | 58 | 0.82093851 | 0.057541829 | x_eq追加説明力 |
| lift_ratio_linear | lift_ratio ~ Tsub | Tsub | 58 | 0.8870762 | 0.12499453 | F1倍率とTsub |
| lift_ratio_linear | lift_ratio ~ x_eq | x_eq | 58 | 0.61875983 | 0.22966647 | F1倍率とx_eq |
| lift_ratio_linear | lift_ratio ~ Tsub + x_eq | Tsub+x_eq | 58 | 0.88711881 | 0.12497094 | x_eq追加説明力 |

## 9. Residualized R2

| target | base_model | residual_checked_against | N | R2 | slope | note |
| --- | --- | --- | --- | --- | --- | --- |
| err_F1_linear | Tsub | Fform_linear | 58 | 0.25700995 | -0.24829346 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Tsub | z_DNB_DH | 58 | 0.4762745 | -0.00098740408 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Tsub | z_DNB_L | 58 | 0.24352304 | -0.53133259 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Tsub | L_DH | 58 | 0.50504506 | -0.0011827936 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Tsub | x_eq | 58 | 0.012797065 | -0.10564998 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Tsub | Fcorr | 58 | 0.039813078 | 3.1812831 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Tsub,x_eq | Fform_linear | 58 | 0.41701395 | -0.30936691 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Tsub,x_eq | z_DNB_DH | 58 | 0.50033032 | -0.00098992643 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Tsub,x_eq | z_DNB_L | 58 | 0.18906251 | -0.45793875 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Tsub,x_eq | L_DH | 58 | 0.6132988 | -0.0012749355 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Tsub,x_eq | Fcorr | 58 | 0.040052941 | 3.1211519 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | L_DH | Fform_linear | 58 | 0.015612577 | 0.044404518 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | L_DH | z_DNB_DH | 58 | 0.0015188768 | -4.0460112e-05 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | L_DH | z_DNB_L | 58 | 0.0059201166 | -0.06011199 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | L_DH | x_eq | 58 | 0.32144762 | -0.38421018 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | L_DH | Tsub | 58 | 0.10565127 | 0.0011344247 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | L_DH | Fcorr | 58 | 0.0069531795 | -0.9646743 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Fform_linear | z_DNB_DH | 58 | 0.17342902 | -0.00051997774 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Fform_linear | z_DNB_L | 58 | 0.19784164 | -0.41793898 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Fform_linear | L_DH | 58 | 0.09901846 | -0.00045704565 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Fform_linear | x_eq | 58 | 0.21555499 | -0.37839976 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Fform_linear | Tsub | 58 | 0.031787477 | 0.00074838384 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Fform_linear | Fcorr | 58 | 0.0035931062 | 0.83403076 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Fform_linear,z_DNB_DH | z_DNB_L | 58 | 0.0054676791 | 0.058981287 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Fform_linear,z_DNB_DH | L_DH | 58 | 0.0027082787 | -6.4166283e-05 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Fform_linear,z_DNB_DH | x_eq | 58 | 0.26271314 | -0.35462669 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Fform_linear,z_DNB_DH | Tsub | 58 | 0.12536809 | 0.0012616782 | base_modelで説明した後に、まだ残る対応を見る |
| err_F1_linear | Fform_linear,z_DNB_DH | Fcorr | 58 | 0.010961309 | -1.2366219 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Tsub | Fform_linear | 58 | 0.25700995 | -0.24829346 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Tsub | z_DNB_DH | 58 | 0.4762745 | -0.00098740408 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Tsub | z_DNB_L | 58 | 0.24352304 | -0.53133259 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Tsub | L_DH | 58 | 0.50504506 | -0.0011827936 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Tsub | x_eq | 58 | 0.012797065 | -0.10564998 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Tsub | Fcorr | 58 | 0.039813078 | 3.1812831 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Tsub,x_eq | Fform_linear | 58 | 0.41701395 | -0.30936691 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Tsub,x_eq | z_DNB_DH | 58 | 0.50033032 | -0.00098992643 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Tsub,x_eq | z_DNB_L | 58 | 0.18906251 | -0.45793875 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Tsub,x_eq | L_DH | 58 | 0.6132988 | -0.0012749355 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Tsub,x_eq | Fcorr | 58 | 0.040052941 | 3.1211519 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | L_DH | Fform_linear | 58 | 0.015612577 | 0.044404518 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | L_DH | z_DNB_DH | 58 | 0.0015188768 | -4.0460112e-05 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | L_DH | z_DNB_L | 58 | 0.0059201166 | -0.06011199 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | L_DH | x_eq | 58 | 0.32144762 | -0.38421018 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | L_DH | Tsub | 58 | 0.10565127 | 0.0011344247 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | L_DH | Fcorr | 58 | 0.0069531795 | -0.9646743 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Fform_linear | z_DNB_DH | 58 | 0.17342902 | -0.00051997774 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Fform_linear | z_DNB_L | 58 | 0.19784164 | -0.41793898 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Fform_linear | L_DH | 58 | 0.09901846 | -0.00045704565 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Fform_linear | x_eq | 58 | 0.21555499 | -0.37839976 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Fform_linear | Tsub | 58 | 0.031787477 | 0.00074838384 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Fform_linear | Fcorr | 58 | 0.0035931062 | 0.83403076 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Fform_linear,z_DNB_DH | z_DNB_L | 58 | 0.0054676791 | 0.058981287 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Fform_linear,z_DNB_DH | L_DH | 58 | 0.0027082787 | -6.4166283e-05 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Fform_linear,z_DNB_DH | x_eq | 58 | 0.26271314 | -0.35462669 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Fform_linear,z_DNB_DH | Tsub | 58 | 0.12536809 | 0.0012616782 | base_modelで説明した後に、まだ残る対応を見る |
| PM_F1_linear | Fform_linear,z_DNB_DH | Fcorr | 58 | 0.010961309 | -1.2366219 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Tsub | Fform_linear | 58 | 0.24867667 | -0.11565106 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Tsub | z_DNB_DH | 58 | 0.41455733 | -0.00043621473 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Tsub | z_DNB_L | 58 | 0.19802956 | -0.22688365 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Tsub | L_DH | 58 | 0.45318292 | -0.00053054525 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Tsub | x_eq | 58 | 0.0088589206 | -0.041624246 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Tsub | Fcorr | 58 | 0.0044169771 | 0.50175739 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Tsub,x_eq | Fform_linear | 58 | 0.3741091 | -0.13971293 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Tsub,x_eq | z_DNB_DH | 58 | 0.42928959 | -0.00043720849 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Tsub,x_eq | z_DNB_L | 58 | 0.15541817 | -0.19796776 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Tsub,x_eq | L_DH | 58 | 0.53327406 | -0.00056684755 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Tsub,x_eq | Fcorr | 58 | 0.0041333662 | 0.47806674 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | L_DH | Fform_linear | 58 | 0.0053484195 | 0.034349699 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | L_DH | z_DNB_DH | 58 | 0.0067302073 | -0.00011256422 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | L_DH | z_DNB_L | 58 | 0.027442689 | -0.17105259 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | L_DH | x_eq | 58 | 0.40314109 | 0.56867303 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | L_DH | Tsub | 58 | 0.82822704 | -0.0041979123 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | L_DH | Fcorr | 58 | 0.62266057 | 12.065213 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Fform_linear | z_DNB_DH | 58 | 0.10927468 | -0.00048774708 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Fform_linear | z_DNB_L | 58 | 0.16532897 | -0.45148108 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Fform_linear | L_DH | 58 | 0.04327568 | -0.00035705448 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Fform_linear | x_eq | 58 | 0.35372891 | 0.57281994 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Fform_linear | Tsub | 58 | 0.82299376 | -0.0044999292 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Fform_linear | Fcorr | 58 | 0.67148164 | 13.473336 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Fform_linear,z_DNB_DH | z_DNB_L | 58 | 1.6729713e-05 | -0.0041225639 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Fform_linear,z_DNB_DH | L_DH | 58 | 5.4220775e-05 | 1.1472379e-05 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Fform_linear,z_DNB_DH | x_eq | 58 | 0.46336842 | 0.59511945 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Fform_linear,z_DNB_DH | Tsub | 58 | 0.79650122 | -0.0040184513 | base_modelで説明した後に、まだ残る対応を見る |
| delta_PM_linear | Fform_linear,z_DNB_DH | Fcorr | 58 | 0.59690343 | 11.531032 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Tsub | Fform_linear | 58 | 2.8000512e-05 | 0.0026255954 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Tsub | z_DNB_DH | 58 | 0.0034578877 | 8.5236617e-05 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Tsub | z_DNB_L | 58 | 0.00016905151 | 0.01418275 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Tsub | L_DH | 58 | 0.0068225013 | 0.00013927405 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Tsub | x_eq | 58 | 0.00011176467 | -0.010002786 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Tsub | Fcorr | 58 | 0.21394589 | -7.4712955 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Tsub,x_eq | Fform_linear | 58 | 4.0490641e-05 | -0.00315675 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Tsub,x_eq | z_DNB_DH | 58 | 0.0034398367 | 8.4997805e-05 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Tsub,x_eq | z_DNB_L | 58 | 0.00037542718 | 0.021131572 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Tsub,x_eq | L_DH | 58 | 0.0059968357 | 0.00013055019 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Tsub,x_eq | Fcorr | 58 | 0.21435296 | -7.4769886 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | L_DH | Fform_linear | 58 | 0.00018096363 | 0.019521614 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | L_DH | z_DNB_DH | 58 | 0.005135645 | -0.00030380401 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | L_DH | z_DNB_L | 58 | 0.021544032 | -0.4682628 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | L_DH | x_eq | 58 | 0.5440561 | 2.0411071 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | L_DH | Tsub | 58 | 0.83897908 | -0.013054014 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | L_DH | Fcorr | 58 | 0.39964214 | 29.864471 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Fform_linear | z_DNB_DH | 58 | 0.023904012 | -0.0006600679 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Fform_linear | z_DNB_L | 58 | 0.054469042 | -0.74982212 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Fform_linear | L_DH | 58 | 0.0041743086 | -0.00032086557 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Fform_linear | x_eq | 58 | 0.53154073 | 2.0317461 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Fform_linear | Tsub | 58 | 0.86387626 | -0.013339867 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Fform_linear | Fcorr | 58 | 0.43085212 | 31.227737 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Fform_linear,z_DNB_DH | z_DNB_L | 58 | 0.0021013239 | -0.14441205 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Fform_linear,z_DNB_DH | L_DH | 58 | 0.0013340003 | 0.00017786166 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Fform_linear,z_DNB_DH | x_eq | 58 | 0.56937174 | 2.061924 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Fform_linear,z_DNB_DH | Tsub | 58 | 0.81284395 | -0.012688283 | base_modelで説明した後に、まだ残る対応を見る |
| lift_ratio_linear | Fform_linear,z_DNB_DH | Fcorr | 58 | 0.37584471 | 28.599218 | base_modelで説明した後に、まだ残る対応を見る |

## 10. Predictor pair R2

| var_y | var_x | N | R2 | slope | note |
| --- | --- | --- | --- | --- | --- |
| Fform_linear | z_DNB_DH | 58 | 0.37919515 | 0.0017989013 | 説明候補同士の交絡確認 |
| Fform_linear | z_DNB_L | 58 | 0.028403178 | 0.37050116 | 説明候補同士の交絡確認 |
| Fform_linear | L_DH | 58 | 0.714179 | 0.0028718193 | 説明候補同士の交絡確認 |
| Fform_linear | x_eq | 58 | 0.20725959 | -0.86812289 | 説明候補同士の交絡確認 |
| Fform_linear | Tsub | 58 | 0.023568878 | 0.0015077103 | 説明候補同士の交絡確認 |
| Fform_linear | Fcorr | 58 | 0.024386952 | -5.0836762 | 説明候補同士の交絡確認 |
| z_DNB_DH | z_DNB_L | 58 | 0.74031307 | 647.49717 | 説明候補同士の交絡確認 |
| z_DNB_DH | L_DH | 58 | 0.85308561 | 1.0744197 | 説明候補同士の交絡確認 |
| z_DNB_DH | x_eq | 58 | 0.056102907 | -154.61109 | 説明候補同士の交絡確認 |
| z_DNB_DH | Tsub | 58 | 0.076633406 | 0.9306397 | 説明候補同士の交絡確認 |
| z_DNB_DH | Fcorr | 58 | 0.10113095 | -3543.7675 | 説明候補同士の交絡確認 |
| z_DNB_L | L_DH | 58 | 0.36015737 | 0.00092767023 | 説明候補同士の交絡確認 |
| z_DNB_L | x_eq | 58 | 0.0027702911 | -0.045654174 | 説明候補同士の交絡確認 |
| z_DNB_L | Tsub | 58 | 0.075872777 | 0.0012305105 | 説明候補同士の交絡確認 |
| z_DNB_L | Fcorr | 58 | 0.087950952 | -4.391504 | 説明候補同士の交絡確認 |
| L_DH | x_eq | 58 | 0.11164253 | -187.49304 | 説明候補同士の交絡確認 |
| L_DH | Tsub | 58 | 0.050854476 | 0.65171763 | 説明候補同士の交絡確認 |
| L_DH | Fcorr | 58 | 0.075292901 | -2628.5882 | 説明候補同士の交絡確認 |
| x_eq | Tsub | 58 | 0.70384199 | -0.0043207799 | 説明候補同士の交絡確認 |
| x_eq | Fcorr | 58 | 0.52872654 | 12.413401 | 説明候補同士の交絡確認 |
| Tsub | Fcorr | 58 | 0.77174002 | -2911.9652 | 説明候補同士の交絡確認 |

## 11. Decision flags

| item | status | value | reading |
| --- | --- | --- | --- |
| input_rows | OK | 58 | noF1/F1をNoで結合した行数。期待値は58。 |
| join_status | OK | 58 rows | 108/161/164の対象58行が結合された。 |
| PM_F1_linear_bundle | diagnostic | 108=1.12322, 161=0.908841, 164=0.939561 | FformLinear後のF1 P/M。 |
| Fform_linear_bundle | diagnostic | 108=0.636086, 164=1.27988 | FformLinear後のFform代表値。 |
| F1_policy | keep | F1(Tsub) | BT05/BT06の判断どおり、F1(Tsub)を維持する前提で読む。 |
| Fform_policy | diagnostic | linear_v1 | FformLinearは定義としては正本候補。ただし残差補正式とは別。 |
| correlation_policy | caution | R2 is diagnostic only | R2が高くても補正式として採用しない。 |
| next | next | BT10-C or BT11 | BT10-B結果を見て、FformLinear_v1を正本候補にするか、legacy併記感度にするか判断する。 |

## 12. Next steps

| step | action | detail |
| --- | --- | --- |
| 1 | Review BT10-B | Check bundle_summary, case_summary, and decision_flags. |
| 2 | Check whether 108 overprediction remains | FformLinear is expected to improve 164 but worsen 108. Confirm magnitude. |
| 3 | Check residual side | Determine whether residuals are tied to Fform/DNB/L_DH rather than Tsub/x_eq. |
| 4 | Avoid immediate formula | Do not create L/DH, z_DNB/DH, or Fform correction from this alone. |
| 5 | Decide FformLinear status | Choose between adopting FformLinear_v1 as current canonical input or treating it as sensitivity alongside legacy. |
| 6 | Update working log | Append BT10-B results to working log after interpretation. |
| 7 | Next analysis | Proceed to BT10-C or BT11 for final judgment of FformLinear impact. |

## 13. 判断メモ

```text
- FformLinear_v1後に、164は改善し、108は過大側へ動いた。
- BT10-Bでは、その後の残差がTsub/x_eq側に残るのか、Fform/DNB位置/L_DH側に残るのかを見る。
- ここで得られたR2は診断であり、補正式ではない。
```
