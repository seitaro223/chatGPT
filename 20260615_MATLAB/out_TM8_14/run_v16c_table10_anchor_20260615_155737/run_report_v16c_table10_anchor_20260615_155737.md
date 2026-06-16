# AI_READ_THIS_FIRST

## run_id

v16c_table10_anchor_20260615_155737

## run_type

table10_anchor_check

## input_files

- v16b: `W:\out_TM8_14\run_v16b_xeq_added_20260615_155159\summary_tables.xlsx`

## 目的

v16bでは Hsub+P+x_eq でTable12 long正残差がほぼ消えた。

ただしTable10は86点あり、回帰面を支配している可能性がある。
そのため、Table10を含めた場合、除いた場合、Table別均等重みにした場合で、Table12残差がどう変わるかを確認した。

## モデル説明力

- A_all_T9_10_11_12 / Hsub_P_xeq: N=176, R2=0.907, RMSE=0.076
- A_all_T9_10_11_12 / Hsub_LD_P_xeq: N=176, R2=0.910, RMSE=0.075
- B_without_Table10 / Hsub_P_xeq: N=90, R2=0.954, RMSE=0.058
- B_without_Table10 / Hsub_LD_P_xeq: N=90, R2=0.957, RMSE=0.056
- C_table_equal_weight / Hsub_P_xeq: N=176, R2=0.926, RMSE=0.078
- C_table_equal_weight / Hsub_LD_P_xeq: N=176, R2=0.928, RMSE=0.076

## same-table short-long residual

- A_all_T9_10_11_12 / Hsub_P_xeq / Table9: delta=-0.075, SE=0.020, CI95=[-0.113, -0.036]
- A_all_T9_10_11_12 / Hsub_P_xeq / Table11: delta=-0.019, SE=0.020, CI95=[-0.057, 0.020]
- A_all_T9_10_11_12 / Hsub_P_xeq / Table12: delta=-0.025, SE=0.027, CI95=[-0.079, 0.028]
- A_all_T9_10_11_12 / Hsub_LD_P_xeq / Table9: delta=-0.020, SE=0.020, CI95=[-0.059, 0.020]
- A_all_T9_10_11_12 / Hsub_LD_P_xeq / Table11: delta=-0.004, SE=0.019, CI95=[-0.041, 0.034]
- A_all_T9_10_11_12 / Hsub_LD_P_xeq / Table12: delta=-0.052, SE=0.026, CI95=[-0.104, -0.001]
- B_without_Table10 / Hsub_P_xeq / Table9: delta=0.036, SE=0.015, CI95=[0.006, 0.065]
- B_without_Table10 / Hsub_P_xeq / Table11: delta=0.035, SE=0.016, CI95=[0.003, 0.066]
- B_without_Table10 / Hsub_P_xeq / Table12: delta=-0.047, SE=0.025, CI95=[-0.095, 0.001]
- B_without_Table10 / Hsub_LD_P_xeq / Table9: delta=0.005, SE=0.014, CI95=[-0.022, 0.032]
- B_without_Table10 / Hsub_LD_P_xeq / Table11: delta=0.028, SE=0.016, CI95=[-0.004, 0.059]
- B_without_Table10 / Hsub_LD_P_xeq / Table12: delta=-0.033, SE=0.025, CI95=[-0.083, 0.016]
- C_table_equal_weight / Hsub_P_xeq / Table9: delta=-0.048, SE=0.018, CI95=[-0.085, -0.012]
- C_table_equal_weight / Hsub_P_xeq / Table11: delta=-0.006, SE=0.019, CI95=[-0.042, 0.031]
- C_table_equal_weight / Hsub_P_xeq / Table12: delta=-0.030, SE=0.026, CI95=[-0.081, 0.022]
- C_table_equal_weight / Hsub_LD_P_xeq / Table9: delta=-0.014, SE=0.019, CI95=[-0.051, 0.024]
- C_table_equal_weight / Hsub_LD_P_xeq / Table11: delta=0.004, SE=0.018, CI95=[-0.032, 0.041]
- C_table_equal_weight / Hsub_LD_P_xeq / Table12: delta=-0.045, SE=0.026, CI95=[-0.096, 0.006]

## Table10 residual summary

- A_all_T9_10_11_12 / Hsub_P_xeq: N=86, mean=-0.015, SD=0.078
- A_all_T9_10_11_12 / Hsub_LD_P_xeq: N=86, mean=-0.015, SD=0.077
- B_without_Table10 / Hsub_P_xeq: N=0, mean=NaN, SD=NaN
- B_without_Table10 / Hsub_LD_P_xeq: N=0, mean=NaN, SD=NaN
- C_table_equal_weight / Hsub_P_xeq: N=86, mean=-0.034, SD=0.082
- C_table_equal_weight / Hsub_LD_P_xeq: N=86, mean=-0.032, SD=0.079

## ChatGPTにしてほしいこと

Table10を含めた場合、除いた場合、Table均等重みの場合で、Table12 long残差が消える判断が維持されるか説明してください。
また、Table10が回帰面を支配していたかどうかを判断してください。
