# AI_READ_THIS_FIRST

## run_id

v16b_xeq_added_20260615_155159

## run_type

xeq_added_from_result_book

## input_files

- v10: `W:\out_TM8_14\TM8_14_explorelow_truehsub_v10_20260615_134041.xlsx`
- result: `20260612_計算結果比較r8_result_文献追加用.xlsx`

## 目的

resultブック `tm_r124_F1_T8_14` のAZ列 `HG-HL` を hlg として読み、xeq_qM と xeq_qP_F1 を計算した。

xeq_qM は実験DNB点確認用、xeq_qP_F1 は予測側・補正候補診断用である。

## QC

- hlg unit判定: J/kg
- hlg欠損: 0
- xeq_qM欠損: 0
- xeq_qP_F1欠損: 0
- source01 Table9-12 rows: 176

## モデル説明力 source01 Table9-12

- Hsub_linear R2: 0.775
- Hsub_quad R2: 0.821
- Hsub_cubic R2: 0.896
- Hsub_P_xeq R2: 0.907
- Hsub_LD_P_xeq R2: 0.910

## same-table short-long residual

- Table9 Hsub_linear: delta=-0.128, SE=0.027, CI95=[-0.180, -0.076]
- Table11 Hsub_linear: delta=0.074, SE=0.029, CI95=[0.017, 0.131]
- Table12 Hsub_linear: delta=0.242, SE=0.041, CI95=[0.163, 0.322]
- Table9 Hsub_quad: delta=-0.187, SE=0.024, CI95=[-0.234, -0.141]
- Table11 Hsub_quad: delta=-0.034, SE=0.028, CI95=[-0.088, 0.021]
- Table12 Hsub_quad: delta=0.105, SE=0.040, CI95=[0.027, 0.184]
- Table9 Hsub_cubic: delta=-0.035, SE=0.018, CI95=[-0.070, -0.000]
- Table11 Hsub_cubic: delta=-0.042, SE=0.023, CI95=[-0.088, 0.004]
- Table12 Hsub_cubic: delta=-0.028, SE=0.038, CI95=[-0.102, 0.046]
- Table9 Hsub_P_xeq: delta=-0.075, SE=0.020, CI95=[-0.113, -0.036]
- Table11 Hsub_P_xeq: delta=-0.019, SE=0.020, CI95=[-0.057, 0.020]
- Table12 Hsub_P_xeq: delta=-0.025, SE=0.027, CI95=[-0.079, 0.028]
- Table9 Hsub_LD_P_xeq: delta=-0.020, SE=0.020, CI95=[-0.059, 0.020]
- Table11 Hsub_LD_P_xeq: delta=-0.004, SE=0.019, CI95=[-0.041, 0.034]
- Table12 Hsub_LD_P_xeq: delta=-0.052, SE=0.026, CI95=[-0.104, -0.001]

## Table8 middle確認

- Table8 middle - Table9 all PM_F1差: -0.446
- Table8 middle - Table9 all Hsub+P+xeq残差差: -0.002
- Table8/9 Hsub+P+xeq R2: 0.833

## ChatGPTにしてほしいこと

v16bの結果を読み、x_eqでTable12 long残差が残るか、Hsub関数形で消えるか、Table8除外判断が維持されるかを説明してください。
