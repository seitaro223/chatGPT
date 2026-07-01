# TM03H10 Table10 lowX採用候補の再評価

作成時刻: 20260630_235447

## 目的

old86を正解集合として復元するのではなく、現行VBAで収束したTable10 source01 lowX current187をベースに、物理的・研究スコープ上の抽出条件を確認する。


## 入力

- /mnt/data/TM03H5_Table10_scatter_legacy_nonlinear/TM03H5_Table10_scatter_legacy_nonlinear_20260629_064139_current187_records_with_old86_tag.csv


## 比較スコープ

- A: G<=4200 全点
- B: G<=4200 かつ L/D>=40
- C: B かつ x>-0.20（deep subcooled除外感度）
- D: 参考 old86近似窓 1.8<=G<=3.0, 60<=L/D<=80（lowX current187内）


## 主要集計

### A_G<=4200_all

- N = 117

- PM mean/std = 1.373 / 0.443

- PM range = 0.114 to 2.721

- high PM(PM>=2.2) = 4

- deep x(x<=-0.20) = 12

- old86 overlap = 47

- Tsub range = 21.4 to 313.2 K

- x range = -0.457 to 0.049

- G range = 521 to 4164 kg/m2/s

- L/D range = 21.0 to 365.3

### B_G<=4200_LD>=40

- N = 113

- PM mean/std = 1.352 / 0.411

- PM range = 0.114 to 2.470

- high PM(PM>=2.2) = 2

- deep x(x<=-0.20) = 10

- old86 overlap = 47

- Tsub range = 21.4 to 313.2 K

- x range = -0.457 to 0.049

- G range = 521 to 4164 kg/m2/s

- L/D range = 64.5 to 365.3

### C_B_plus_x>-0.20

- N = 103

- PM mean/std = 1.279 / 0.348

- PM range = 0.114 to 1.853

- high PM(PM>=2.2) = 0

- deep x(x<=-0.20) = 0

- old86 overlap = 42

- Tsub range = 21.4 to 313.2 K

- x range = -0.191 to 0.049

- G range = 521 to 4164 kg/m2/s

- L/D range = 64.5 to 365.3

### D_old86like_window_lowX

- N = 47

- PM mean/std = 1.272 / 0.434

- PM range = 0.435 to 2.470

- high PM(PM>=2.2) = 2

- deep x(x<=-0.20) = 5

- old86 overlap = 46

- Tsub range = 33.6 to 250.7 K

- x range = -0.457 to 0.049

- G range = 2455 to 4069 kg/m2/s

- L/D range = 64.5 to 80.0

### Excluded_G>4200

- N = 70

- PM mean/std = 1.429 / 0.877

- PM range = 0.074 to 3.605

- high PM(PM>=2.2) = 22

- deep x(x<=-0.20) = 29

- old86 overlap = 0

- Tsub range = 20.9 to 256.2 K

- x range = -0.459 to 0.050

- G range = 4204 to 10565 kg/m2/s

- L/D range = 21.0 to 108.8

### Excluded_G<=4200_LD<40

- N = 4

- PM mean/std = 1.964 / 0.888

- PM range = 0.812 to 2.721

- high PM(PM>=2.2) = 2

- deep x(x<=-0.20) = 2

- old86 overlap = 0

- Tsub range = 28.0 to 132.2 K

- x range = -0.338 to -0.047

- G range = 2102 to 2712 kg/m2/s

- L/D range = 21.0 to 21.0


## R2概要

### A_G<=4200_all

- Tsub_linear: R2=0.455, N=117

- Tsub_quadratic: R2=0.720, N=117

- x_linear: R2=0.768, N=117

- Tsub+x: R2=0.839, N=117

- Tsub2+x: R2=0.907, N=117

- Tsub2+x+LD: R2=0.919, N=117

### B_G<=4200_LD>=40

- Tsub_linear: R2=0.569, N=113

- Tsub_quadratic: R2=0.864, N=113

- x_linear: R2=0.754, N=113

- Tsub+x: R2=0.864, N=113

- Tsub2+x: R2=0.964, N=113

- Tsub2+x+LD: R2=0.973, N=113

### C_B_plus_x>-0.20

- Tsub_linear: R2=0.569, N=103

- Tsub_quadratic: R2=0.900, N=103

- x_linear: R2=0.690, N=103

- Tsub+x: R2=0.825, N=103

- Tsub2+x: R2=0.946, N=103

- Tsub2+x+LD: R2=0.962, N=103

### D_old86like_window_lowX

- Tsub_linear: R2=0.900, N=47

- Tsub_quadratic: R2=0.927, N=47

- x_linear: R2=0.892, N=47

- Tsub+x: R2=0.937, N=47

- Tsub2+x: R2=0.990, N=47

- Tsub2+x+LD: R2=0.990, N=47


## residual診断

- A_G<=4200_all: Tsub2 residual vs L/D R2=0.024, vs x R2=0.392, vs G R2=0.044

- B_G<=4200_LD>=40: Tsub2 residual vs L/D R2=0.017, vs x R2=0.386, vs G R2=0.121

- C_B_plus_x>-0.20: Tsub2 residual vs L/D R2=0.006, vs x R2=0.220, vs G R2=0.068

- D_old86like_window_lowX: Tsub2 residual vs L/D R2=0.392, vs x R2=0.130, vs G R2=0.067


## 判断

- G>4200を外すと、強負クオリティ高P/M群の大半は主解析外になる。

- L/D<40の4点は、G<=4200内でも短すぎる点として主解析から外す候補にできる。

- B条件（G<=4200 かつ L/D>=40）が、現時点のTable10 lowX主候補として自然。

- C条件（さらに x>-0.20）はdeep subcooled除外感度であり、主条件ではない。

- D条件はold86近似窓の参考比較であり、old86を正解集合として復元するための条件ではない。

- qMは採用条件・補正式入力には使わない。
