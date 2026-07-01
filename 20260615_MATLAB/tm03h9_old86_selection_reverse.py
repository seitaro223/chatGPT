from pathlib import Path
from datetime import datetime
import zipfile
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

stamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
outdir = Path(f'/mnt/data/TM03H9_old86_selection_reverse_{stamp}')
outdir.mkdir(parents=True, exist_ok=True)

raw_path = Path('/mnt/data/TM03H3_Table10_raw_quality_scope/TM03H3_Table10_raw_quality_scope_20260629_151620_raw_records_with_scope_tags.csv')
old_path = Path('/mnt/data/TM03H5_Table10_scatter_legacy_nonlinear/TM03H5_Table10_scatter_legacy_nonlinear_20260629_064139_old86_records_scope.csv')
cur_path = Path('/mnt/data/TM03H8_Table10_Gupper_LD_scope_20260629_074812/TM03H8_current187_enriched_with_LD_policy_20260629_074812.csv')

raw = pd.read_csv(raw_path)
old = pd.read_csv(old_path)
cur = pd.read_csv(cur_path)

raw['ExptNo_norm'] = raw['ExptNo'].round(2)
old_set = set(old['ExptNo_norm'].round(2))
raw['old86_member'] = raw['ExptNo_norm'].isin(old_set)
raw['qM'] = raw['BurnoutHF_1e6_BTU_hr_ft2']
raw['x'] = raw['ExitQuality']
raw['G_raw'] = raw['G_1e6_lb_hr_ft2']
raw['qM_over_Graw'] = raw['qM'] / raw['G_raw']
raw['low_LD_lt40'] = raw['L_over_D'] < 40

source01 = raw[raw['source'].eq('source01')].copy()

# Candidate windows
windows = []
def add_window(name, mask):
    df = source01[mask].copy()
    old_n = int(df['old86_member'].sum())
    n = int(len(df))
    windows.append({
        'window': name,
        'N': n,
        'old86_N': old_n,
        'not_old86_N': n-old_n,
        'precision_old86_in_window': old_n/n if n else np.nan,
        'recall_old86': old_n/86 if 86 else np.nan,
        'G_min': df['G_raw'].min() if n else np.nan,
        'G_max': df['G_raw'].max() if n else np.nan,
        'LD_min': df['L_over_D'].min() if n else np.nan,
        'LD_max': df['L_over_D'].max() if n else np.nan,
        'qM_min': df['qM'].min() if n else np.nan,
        'qM_max': df['qM'].max() if n else np.nan,
        'x_min': df['x'].min() if n else np.nan,
        'x_max': df['x'].max() if n else np.nan,
    })

add_window('source01_all', source01.index==source01.index)
add_window('G_1p8_3p0', source01['G_raw'].between(1.8,3.0))
add_window('G_1p8_3p0_and_LD_ge60', source01['G_raw'].between(1.8,3.0) & (source01['L_over_D']>=60))
add_window('G_1p8_3p0_and_60leLDle80', source01['G_raw'].between(1.8,3.0) & source01['L_over_D'].between(60,80))
add_window('G_1p8_3p0_and_64leLDle80', source01['G_raw'].between(1.8,3.0) & source01['L_over_D'].between(64,80))
add_window('G_1p99_3p0_and_60leLDle80', source01['G_raw'].between(1.99,3.0) & source01['L_over_D'].between(60,80))
add_window('G_2p02_3p0_and_60leLDle80', source01['G_raw'].between(2.02,3.0) & source01['L_over_D'].between(60,80))
add_window('G_1p8_3p0_and_60leLDle80_and_xle0p137', source01['G_raw'].between(1.8,3.0) & source01['L_over_D'].between(60,80) & (source01['x']<=0.137))
add_window('G_1p8_3p0_and_60leLDle80_and_qMge0p80', source01['G_raw'].between(1.8,3.0) & source01['L_over_D'].between(60,80) & (source01['qM']>=0.80))
window_summary = pd.DataFrame(windows)
window_summary.to_csv(outdir / f'TM03H9_old86_window_rule_summary_{stamp}.csv', index=False)

# Main G/L window and 9 not-old records
main_mask = source01['G_raw'].between(1.8,3.0) & source01['L_over_D'].between(60,80)
main = source01[main_mask].copy()
not9 = main[~main['old86_member']].copy().sort_values('ExptNo_norm')
old_in_main = main[main['old86_member']].copy().sort_values('ExptNo_norm')

cols = ['ExptNo_norm','Dia_in','Length_in','L_over_D','G_raw','G_kg_m2_s','InletSubcool_BTUlb','qM','qM_over_Graw','x','flag_norm','lowX_le_005','old86_member']
not9[cols].to_csv(outdir / f'TM03H9_GLD_window_not_old86_9records_{stamp}.csv', index=False)
old_in_main[cols].to_csv(outdir / f'TM03H9_GLD_window_old86_86records_{stamp}.csv', index=False)
main[cols].to_csv(outdir / f'TM03H9_GLD_window_all95_with_old86_tag_{stamp}.csv', index=False)

# Current G<=4200 and LD<40 exclusion candidates
ldlt40 = cur[(cur['G_le_4200']) & (cur['L_over_D'] < 40)].copy().sort_values('ExptNo_norm')
ld_cols = ['ExptNo_norm','PM_noF1','Tsub','x','G_kg_m2s','G_1e6_lb_hr_ft2','Dia_in','Length_in','L_over_D','BurnoutHF_1e6_BTU_hr_ft2','ExitQuality','old86_member','LD_band_detail']
ldlt40[ld_cols].to_csv(outdir / f'TM03H9_Gle4200_LDlt40_4records_exclusion_candidates_{stamp}.csv', index=False)

# Summaries comparing old86 and not-old within G/L window
summary_cols = ['G_raw','L_over_D','InletSubcool_BTUlb','qM','qM_over_Graw','x']
compare_rows=[]
for member, df in [('not_old86_9', not9), ('old86_86', old_in_main), ('all95', main)]:
    row={'group': member, 'N': len(df)}
    for c in summary_cols:
        row[f'{c}_mean'] = df[c].mean()
        row[f'{c}_median'] = df[c].median()
        row[f'{c}_min'] = df[c].min()
        row[f'{c}_max'] = df[c].max()
    row['x_gt_0p05_N'] = int((df['x']>0.05).sum())
    row['x_gt_0p10_N'] = int((df['x']>0.10).sum())
    row['qM_lt_0p85_N'] = int((df['qM']<0.85).sum())
    row['G_lt_2p0_N'] = int((df['G_raw']<2.0).sum())
    compare_rows.append(row)
compare = pd.DataFrame(compare_rows)
compare.to_csv(outdir / f'TM03H9_not9_vs_old86_distribution_summary_{stamp}.csv', index=False)

# Series summary
series_summary = main.groupby(['Dia_in','Length_in','L_over_D','old86_member']).agg(
    N=('ExptNo_norm','count'),
    G_min=('G_raw','min'), G_max=('G_raw','max'),
    qM_min=('qM','min'), qM_max=('qM','max'), qM_mean=('qM','mean'),
    x_min=('x','min'), x_max=('x','max'), x_mean=('x','mean')
).reset_index()
series_summary.to_csv(outdir / f'TM03H9_GLD_window_series_old86_summary_{stamp}.csv', index=False)

# Threshold sensitivity for qM, G, x within the G/L window
thr_rows=[]
def threshold_metrics(label, sel):
    tp = int((sel & main['old86_member']).sum())
    fp = int((sel & ~main['old86_member']).sum())
    fn = int((~sel & main['old86_member']).sum())
    tn = int((~sel & ~main['old86_member']).sum())
    nsel = int(sel.sum())
    thr_rows.append({
        'rule': label,
        'selected_N': nsel,
        'TP_old86': tp, 'FP_not_old86': fp, 'FN_missed_old86': fn, 'TN': tn,
        'precision': tp/nsel if nsel else np.nan,
        'recall': tp/(tp+fn) if (tp+fn) else np.nan,
        'accuracy_within95': (tp+tn)/len(main) if len(main) else np.nan,
    })
for th in [0.65,0.67,0.674,0.70,0.75,0.80,0.85,0.90,1.0]:
    threshold_metrics(f'qM >= {th:.3f}', main['qM'] >= th)
for th in [1.90,1.96,1.99,2.00,2.02,2.03,2.10]:
    threshold_metrics(f'G >= {th:.2f}', main['G_raw'] >= th)
for th in [0.05,0.10,0.117,0.137,0.15,0.188]:
    threshold_metrics(f'x <= {th:.3f}', main['x'] <= th)
# combined illustrative, not for adoption
threshold_metrics('G >= 2.02', main['G_raw'] >= 2.02)
threshold_metrics('G >= 2.02 OR ExptNo 9/10', (main['G_raw']>=2.02)|main['ExptNo_norm'].isin([9.01,10.01]))
threshold_metrics('(G >= 2.02 OR ExptNo 9/10) AND NOT(x>0.10 and qM<0.70)', ((main['G_raw']>=2.02)|main['ExptNo_norm'].isin([9.01,10.01])) & ~((main['x']>0.10)&(main['qM']<0.70)))
threshold_metrics('x <= 0.137', main['x']<=0.137)
thr_df = pd.DataFrame(thr_rows)
thr_df.to_csv(outdir / f'TM03H9_threshold_sensitivity_within_GLD95_{stamp}.csv', index=False)

# Figures
# 1: current G<=4200 with LD<40 highlighted
fig, ax = plt.subplots(figsize=(9,6))
base = cur[cur['G_le_4200']].copy()
ax.scatter(base['Tsub'], base['PM_noF1'], alpha=0.65, label=f'G<=4200 all N={len(base)}')
if len(ldlt40):
    ax.scatter(ldlt40['Tsub'], ldlt40['PM_noF1'], marker='x', s=90, label=f'L/D<40 candidates N={len(ldlt40)}')
ax.axhline(1.0, linestyle='--', linewidth=1)
ax.axhline(2.2, linestyle=':', linewidth=1)
ax.set_xlabel('Tsub [K]')
ax.set_ylabel('P/M noF1')
ax.set_title('TM03H9 Table10 G<=4200: L/D<40 exclusion candidates')
ax.legend()
ax.grid(True, alpha=0.3)
fig.tight_layout()
fig.savefig(outdir / f'fig_TM03H9_01_Gle4200_PM_vs_Tsub_LDlt40_{stamp}.png', dpi=160)
plt.close(fig)

# 2: old86 membership in G/L window by qM vs G
fig, ax = plt.subplots(figsize=(9,6))
for name, df in [('old86', old_in_main), ('not old86 in G/L window', not9)]:
    ax.scatter(df['G_raw'], df['qM'], alpha=0.75, label=f'{name} N={len(df)}')
ax.set_xlabel('G [10^6 lb/hr/ft2]')
ax.set_ylabel('qM = Burnout Heat Flux [10^6 BTU/hr/ft2]')
ax.set_title('TM03H9 old86 membership in G 1.8-3.0 and 60<=L/D<=80')
ax.legend()
ax.grid(True, alpha=0.3)
fig.tight_layout()
fig.savefig(outdir / f'fig_TM03H9_02_old86_qM_vs_G_in_GLD95_{stamp}.png', dpi=160)
plt.close(fig)

# 3: old86 membership by x vs qM
fig, ax = plt.subplots(figsize=(9,6))
for name, df in [('old86', old_in_main), ('not old86 in G/L window', not9)]:
    ax.scatter(df['x'], df['qM'], alpha=0.75, label=f'{name} N={len(df)}')
ax.axvline(0.05, linestyle='--', linewidth=1)
ax.axvline(0.137, linestyle=':', linewidth=1)
ax.set_xlabel('Exit Quality x')
ax.set_ylabel('qM = Burnout Heat Flux [10^6 BTU/hr/ft2]')
ax.set_title('TM03H9 old86 membership: qM vs exit quality')
ax.legend()
ax.grid(True, alpha=0.3)
fig.tight_layout()
fig.savefig(outdir / f'fig_TM03H9_03_old86_qM_vs_x_in_GLD95_{stamp}.png', dpi=160)
plt.close(fig)

# 4: G vs L/D map source01 old86/candidates
fig, ax = plt.subplots(figsize=(9,6))
ax.scatter(source01['L_over_D'], source01['G_raw'], alpha=0.25, label=f'source01 all N={len(source01)}')
ax.scatter(old_in_main['L_over_D'], old_in_main['G_raw'], marker='o', alpha=0.75, label='old86 in G/L window')
ax.scatter(not9['L_over_D'], not9['G_raw'], marker='x', s=80, label='not old86 9 in G/L window')
ax.axhline(1.8, linestyle='--', linewidth=1)
ax.axhline(3.0, linestyle='--', linewidth=1)
ax.axhline(2.02, linestyle=':', linewidth=1)
ax.axvline(60, linestyle='--', linewidth=1)
ax.axvline(80, linestyle='--', linewidth=1)
ax.set_xlabel('L/D')
ax.set_ylabel('G [10^6 lb/hr/ft2]')
ax.set_title('TM03H9 source01 Table10: old86 approximate G-L/D window')
ax.legend()
ax.grid(True, alpha=0.3)
fig.tight_layout()
fig.savefig(outdir / f'fig_TM03H9_04_G_vs_LD_old86_window_{stamp}.png', dpi=160)
plt.close(fig)

# Report
ws = window_summary
comp = compare
not9_disp = not9[cols]
ldlt40_disp = ldlt40[ld_cols]

def md_table(df, max_rows=20, floatfmt='.3f'):
    return df.head(max_rows).to_markdown(index=False, floatfmt=floatfmt)

report = f"""# TM03H9: Table10 old86 selection reverse check

作成: {stamp} UTC

## 目的

Table10の旧86点が、G条件・L/D条件・qM条件の組合せで説明できるかを確認した。
あわせて、G<=4200内のL/D<40の4点を主解析除外候補として一覧化した。

## 入力

- raw Table10 inventory: `{raw_path}`
- old86 scope: `{old_path}`
- current187 enriched H8: `{cur_path}`

## 1. L/D<40 の4点

`current187` のうち `G<=4200` かつ `L/D<40` は {len(ldlt40)} 点で、すべて旧86点ではなかった。
この4点はL/Dが約21で、旧86点の主なL/D範囲から大きく外れているため、主解析から外す候補として扱いやすい。

{md_table(ldlt40_disp, max_rows=10)}

## 2. old86はG×L/Dでかなり説明できる

旧86点は、source01 Table10内では次の窓でかなり説明できる。

```text
1.8 <= G <= 3.0 [10^6 lb/hr/ft2]
60 <= L/D <= 80
```

この窓では全95点のうち86点がold86で、not-old86は9点である。old86のrecallは100%、precisionは90.5%である。

{md_table(window_summary[['window','N','old86_N','not_old86_N','precision_old86_in_window','recall_old86','G_min','G_max','LD_min','LD_max','qM_min','qM_max','x_min','x_max']], max_rows=20)}

## 3. 説明できていない9点

G×L/D窓内でold86に入らなかった9点は以下である。

{md_table(not9_disp, max_rows=20)}

この9点の特徴は、old86 86点と比べて、低G・低qM・高x側に寄っていることである。

{md_table(compare, max_rows=10)}

## 4. qM条件の読み

9点はqMが低めである。

```text
not-old86 9点: qM = {not9['qM'].min():.3f} ～ {not9['qM'].max():.3f}, 平均 {not9['qM'].mean():.3f}
old86 86点  : qM = {old_in_main['qM'].min():.3f} ～ {old_in_main['qM'].max():.3f}, 平均 {old_in_main['qM'].mean():.3f}
```

したがって、「DNB型らしい高qM側を選んでいた」という見方は、群平均としては支持される。
ただし、qMしきい値だけではold86を再現できない。old86側にもqMが0.535〜0.85程度の点が多数含まれるためである。

qMは補正式入力ではなく、旧86点の選定条件を逆算するための診断量として扱う。

## 5. Gしきい値の方が9点の説明には強い

G×L/D窓内で単純なしきい値を動かすと、qMよりもG下限の方がold86再現に効いた。
特に `G>=2.02` は、85点を選び、そのうち84点がold86である。ただしold86の低G 2点を落とし、not-old86 1点を残すため、完全一致ではない。

{md_table(thr_df.sort_values(['accuracy_within95','precision','recall'], ascending=False), max_rows=20)}

## 6. 現時点の判断

- L/D<40の4点は、主解析除外候補としてかなり自然である。
- old86は、まず `G 1.8〜3.0` と `60<=L/D<=80` でほぼ囲える。
- 残る9点は、低G・低qM・高x側に寄っている。
- ただしqMしきい値だけではold86を再現できない。
- old86は、単純な qM フィルタではなく、G×L/Dの窓を基本に、系列端の低G/低qM/高x側を一部落とした集合に見える。
- qMは補正式入力ではなく、旧86点の選定履歴を復元するための診断量に留める。

## 次アクション候補

次は、`G<=4200` かつ `L/D<40` の4点を除外候補として扱い、Table10 lowXの主解析候補を以下で比較するのがよい。

```text
A: G<=4200 全点
B: G<=4200 かつ L/D>=40
C: G<=4200 かつ L/D>=60
D: old86近似窓: 1.8<=G<=3.0 かつ 60<=L/D<=80
```

この比較では、Tsub線形・2次、x、外れ点、PM高値の残り方を確認する。
"""
report_path = outdir / f'run_report_TM03H9_old86_selection_reverse_{stamp}.md'
report_path.write_text(report, encoding='utf-8')

# Zip all outputs
zip_path = Path(f'/mnt/data/TM03H9_old86_selection_reverse_{stamp}.zip')
with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as z:
    for p in outdir.iterdir():
        z.write(p, arcname=f'{outdir.name}/{p.name}')
    z.write(Path(__file__), arcname=f'{outdir.name}/tm03h9_old86_selection_reverse.py')

print(outdir)
print(zip_path)
print(report_path)
