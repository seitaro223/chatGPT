#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TM03F2: Table別G範囲・G帯別Tsub相関確認

目的:
  TM03EF records_valid277.csv を入力として、Table9〜12のG範囲と、
  G帯別の PM_noF1 ~ Tsub_K の対応を確認する。

注意:
  これはF1係数作成やG補正式作成ではない。
  追加データ受入QA、およびF1(Tsub)成立性の予備確認である。

使い方例:
  python TM03F2_Gband_Tsub_sensitivity.py \
    --valid-csv output\\TM03EF_current_result_acceptance_QA_YYYYMMDD_HHMMSS_records_valid277.csv \
    --outdir output

依存:
  標準ライブラリのみ
"""

from __future__ import annotations

import argparse
import csv
import glob
import math
import os
from collections import defaultdict
from datetime import datetime
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple


def parse_float(x: Any) -> Optional[float]:
    if x is None:
        return None
    s = str(x).strip()
    if s == "" or s.lower() in {"nan", "none", "null"}:
        return None
    try:
        return float(s)
    except ValueError:
        return None


def safe_int_from_float(x: Any) -> Optional[int]:
    v = parse_float(x)
    if v is None:
        return None
    return int(round(v))


def mean(xs: Sequence[float]) -> Optional[float]:
    if not xs:
        return None
    return sum(xs) / len(xs)


def sample_std(xs: Sequence[float]) -> Optional[float]:
    if len(xs) < 2:
        return None
    m = mean(xs)
    assert m is not None
    return math.sqrt(sum((x - m) ** 2 for x in xs) / (len(xs) - 1))


def percentile(xs: Sequence[float], p: float) -> Optional[float]:
    if not xs:
        return None
    arr = sorted(xs)
    if len(arr) == 1:
        return arr[0]
    pos = (len(arr) - 1) * p
    lo = int(math.floor(pos))
    hi = int(math.ceil(pos))
    if lo == hi:
        return arr[lo]
    frac = pos - lo
    return arr[lo] * (1 - frac) + arr[hi] * frac


def fmt(x: Optional[float], nd: int = 4) -> str:
    if x is None:
        return ""
    if isinstance(x, float) and (math.isnan(x) or math.isinf(x)):
        return ""
    return f"{x:.{nd}f}"


def fmt_count(x: int) -> str:
    return str(int(x))


def solve_linear_system(a: List[List[float]], b: List[float]) -> Optional[List[float]]:
    """Gauss-Jordan solver for small systems."""
    n = len(b)
    aug = [row[:] + [b[i]] for i, row in enumerate(a)]
    for col in range(n):
        pivot = max(range(col, n), key=lambda r: abs(aug[r][col]))
        if abs(aug[pivot][col]) < 1e-12:
            return None
        aug[col], aug[pivot] = aug[pivot], aug[col]
        pv = aug[col][col]
        aug[col] = [v / pv for v in aug[col]]
        for r in range(n):
            if r == col:
                continue
            factor = aug[r][col]
            if factor:
                aug[r] = [aug[r][c] - factor * aug[col][c] for c in range(n + 1)]
    return [aug[i][-1] for i in range(n)]


def r2_ols(rows: Sequence[Dict[str, Any]], y_col: str, x_cols: Sequence[str]) -> Tuple[int, Optional[float], List[Optional[float]]]:
    """OLS R2 with intercept. Returns N, R2, coefficients [intercept, x1,...]."""
    y: List[float] = []
    xmat: List[List[float]] = []
    for row in rows:
        yy = parse_float(row.get(y_col))
        if yy is None or yy <= 0 and y_col.startswith("ln_"):
            continue
        xs: List[float] = []
        ok = True
        for c in x_cols:
            vv = parse_float(row.get(c))
            if vv is None:
                ok = False
                break
            xs.append(vv)
        if ok and yy is not None and math.isfinite(yy) and all(math.isfinite(v) for v in xs):
            y.append(yy)
            xmat.append([1.0] + xs)
    n = len(y)
    p = 1 + len(x_cols)
    if n <= p:
        return n, None, [None] * p

    xtx = [[0.0] * p for _ in range(p)]
    xty = [0.0] * p
    for xi, yi in zip(xmat, y):
        for i in range(p):
            xty[i] += xi[i] * yi
            for j in range(p):
                xtx[i][j] += xi[i] * xi[j]
    beta = solve_linear_system(xtx, xty)
    if beta is None:
        return n, None, [None] * p

    ybar = sum(y) / n
    ss_tot = sum((yi - ybar) ** 2 for yi in y)
    ss_res = 0.0
    for xi, yi in zip(xmat, y):
        pred = sum(beta[j] * xi[j] for j in range(p))
        ss_res += (yi - pred) ** 2
    if ss_tot <= 1e-15:
        return n, None, beta
    return n, 1.0 - ss_res / ss_tot, beta


def read_records(path: str) -> List[Dict[str, Any]]:
    with open(path, newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    out = []
    for r in rows:
        rr = dict(r)
        rr["TableNo_int"] = safe_int_from_float(rr.get("TableNo"))
        pm = parse_float(rr.get("PM_noF1"))
        rr["ln_PM_noF1"] = math.log(pm) if pm is not None and pm > 0 else None
        out.append(rr)
    return out


def find_latest_valid_csv(outdir: str) -> Optional[str]:
    patterns = [
        os.path.join(outdir, "*records_valid277.csv"),
        os.path.join(outdir, "*_records_valid277.csv"),
        os.path.join(outdir, "*valid277*.csv"),
    ]
    candidates: List[str] = []
    for pat in patterns:
        candidates.extend(glob.glob(pat))
    candidates = sorted(set(candidates), key=os.path.getmtime, reverse=True)
    return candidates[0] if candidates else None


def band_predicates() -> List[Tuple[str, str, Any]]:
    return [
        ("all", "all valid277", lambda g: True),
        ("G_lt_1900", "G < 1900", lambda g: g is not None and g < 1900),
        ("G_1900_4200", "1900 <= G <= 4200", lambda g: g is not None and 1900 <= g <= 4200),
        ("G_gt_4200", "G > 4200", lambda g: g is not None and g > 4200),
        ("G_ge_2400", "G >= 2400", lambda g: g is not None and g >= 2400),
        ("G_2400_4200", "2400 <= G <= 4200", lambda g: g is not None and 2400 <= g <= 4200),
        ("G_1900_2400", "1900 <= G < 2400", lambda g: g is not None and 1900 <= g < 2400),
        ("G_4200_999999", "G > 4200", lambda g: g is not None and g > 4200),
    ]


def summarize_rows(rows: Sequence[Dict[str, Any]]) -> Dict[str, Any]:
    gs = [parse_float(r.get("G")) for r in rows]
    gs = [x for x in gs if x is not None]
    tsubs = [parse_float(r.get("Tsub_K")) for r in rows]
    tsubs = [x for x in tsubs if x is not None]
    pms = [parse_float(r.get("PM_noF1")) for r in rows]
    pms = [x for x in pms if x is not None]
    return {
        "N": len(rows),
        "G_min": min(gs) if gs else None,
        "G_p25": percentile(gs, 0.25),
        "G_median": percentile(gs, 0.50),
        "G_p75": percentile(gs, 0.75),
        "G_max": max(gs) if gs else None,
        "Tsub_min": min(tsubs) if tsubs else None,
        "Tsub_median": percentile(tsubs, 0.50),
        "Tsub_max": max(tsubs) if tsubs else None,
        "PM_mean": mean(pms),
        "PM_median": percentile(pms, 0.50),
        "PM_std": sample_std(pms),
    }


def write_csv(path: str, rows: Sequence[Dict[str, Any]], fieldnames: Sequence[str]) -> None:
    with open(path, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        for r in rows:
            w.writerow({k: r.get(k, "") for k in fieldnames})


def markdown_table(rows: Sequence[Dict[str, Any]], cols: Sequence[str]) -> str:
    if not rows:
        return "(no rows)"
    lines = []
    lines.append("| " + " | ".join(cols) + " |")
    lines.append("|" + "|".join(["---"] * len(cols)) + "|")
    for r in rows:
        vals = []
        for c in cols:
            v = r.get(c, "")
            if isinstance(v, float):
                if c.startswith("R2"):
                    vals.append(fmt(v, 4))
                elif c.startswith("G") or c.startswith("Tsub"):
                    vals.append(fmt(v, 1))
                elif c.startswith("PM"):
                    vals.append(fmt(v, 4))
                else:
                    vals.append(fmt(v, 4))
            else:
                vals.append(str(v))
        lines.append("| " + " | ".join(vals) + " |")
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--valid-csv", default=None, help="TM03EF *_records_valid277.csv")
    ap.add_argument("--outdir", default="output", help="output directory")
    args = ap.parse_args()

    outdir = args.outdir
    os.makedirs(outdir, exist_ok=True)

    valid_csv = args.valid_csv
    if valid_csv is None:
        valid_csv = find_latest_valid_csv(outdir)
    if valid_csv is None or not os.path.exists(valid_csv):
        raise FileNotFoundError("valid277 CSV not found. Pass --valid-csv path explicitly.")

    rows_all = read_records(valid_csv)
    rows = [r for r in rows_all if r.get("Status") == "OK" and r.get("TableNo_int") in {9, 10, 11, 12}]
    created = datetime.now().strftime("%Y%m%d_%H%M%S")
    stem = f"TM03F2_Gband_Tsub_sensitivity_{created}"

    # Table G summary
    table_summary: List[Dict[str, Any]] = []
    for t in [9, 10, 11, 12]:
        sub = [r for r in rows if r.get("TableNo_int") == t]
        s = summarize_rows(sub)
        count_lt1900 = sum(1 for r in sub if (parse_float(r.get("G")) is not None and parse_float(r.get("G")) < 1900))
        count_1900_4200 = sum(1 for r in sub if (parse_float(r.get("G")) is not None and 1900 <= parse_float(r.get("G")) <= 4200))
        count_gt4200 = sum(1 for r in sub if (parse_float(r.get("G")) is not None and parse_float(r.get("G")) > 4200))
        count_ge2400 = sum(1 for r in sub if (parse_float(r.get("G")) is not None and parse_float(r.get("G")) >= 2400))
        count_2400_4200 = sum(1 for r in sub if (parse_float(r.get("G")) is not None and 2400 <= parse_float(r.get("G")) <= 4200))
        table_summary.append({
            "TableNo": t,
            **s,
            "N_G_lt_1900": count_lt1900,
            "N_G_1900_4200": count_1900_4200,
            "N_G_gt_4200": count_gt4200,
            "N_G_ge_2400": count_ge2400,
            "N_G_2400_4200": count_2400_4200,
        })

    # Band summary by table and all tables
    band_summary: List[Dict[str, Any]] = []
    groups: List[Tuple[str, List[Dict[str, Any]]]] = [("AllTables", rows)]
    groups += [(f"Table{t}", [r for r in rows if r.get("TableNo_int") == t]) for t in [9, 10, 11, 12]]
    for group_name, group_rows in groups:
        for band_id, band_label, pred in band_predicates():
            sub = [r for r in group_rows if pred(parse_float(r.get("G")))]
            s = summarize_rows(sub)
            n1, r2_tsub, b1 = r2_ols(sub, "PM_noF1", ["Tsub_K"])
            n2, r2_lntsub, b2 = r2_ols(sub, "ln_PM_noF1", ["Tsub_K"])
            n3, r2_g, b3 = r2_ols(sub, "PM_noF1", ["G"])
            n4, r2_tsub_g, b4 = r2_ols(sub, "PM_noF1", ["Tsub_K", "G"])
            band_summary.append({
                "Group": group_name,
                "BandID": band_id,
                "Band": band_label,
                **s,
                "N_R2": n1,
                "R2_PM_Tsub": r2_tsub,
                "slope_PM_Tsub": b1[1] if len(b1) > 1 else None,
                "R2_lnPM_Tsub": r2_lntsub,
                "R2_PM_G": r2_g,
                "R2_PM_Tsub_G": r2_tsub_g,
                "delta_R2_add_G_after_Tsub": (r2_tsub_g - r2_tsub) if r2_tsub is not None and r2_tsub_g is not None else None,
            })

    # Key comparison for Table10
    key_rows = [r for r in band_summary if r["Group"] == "Table10" and r["BandID"] in {"all", "G_1900_4200", "G_2400_4200", "G_lt_1900", "G_gt_4200", "G_ge_2400"}]

    table_cols = ["TableNo", "N", "G_min", "G_p25", "G_median", "G_p75", "G_max", "N_G_lt_1900", "N_G_1900_4200", "N_G_gt_4200", "N_G_ge_2400", "N_G_2400_4200"]
    band_cols = ["Group", "BandID", "Band", "N", "G_min", "G_median", "G_max", "Tsub_min", "Tsub_max", "PM_mean", "PM_std", "R2_PM_Tsub", "R2_lnPM_Tsub", "R2_PM_G", "R2_PM_Tsub_G", "delta_R2_add_G_after_Tsub"]

    table_csv = os.path.join(outdir, f"{stem}_table_G_summary.csv")
    band_csv = os.path.join(outdir, f"{stem}_Gband_Tsub_summary.csv")
    write_csv(table_csv, table_summary, table_cols)
    write_csv(band_csv, band_summary, band_cols)

    md_path = os.path.join(outdir, f"run_report_{stem}.md")
    with open(md_path, "w", encoding="utf-8") as f:
        f.write(f"# TM03F2 Table別G範囲・G帯別Tsub相関確認\n\n")
        f.write(f"Created: {datetime.now().isoformat(timespec='seconds')}\n\n")
        f.write("## Inputs\n\n")
        f.write(f"- valid277 CSV: `{valid_csv}`\n")
        f.write("- Purpose: Table10でTsub相関が弱めに見える理由として、G範囲の広さ・低G/超高G混入を確認する。\n")
        f.write("- This is QA / feasibility check only. No F1 coefficient or G correction is fitted.\n\n")

        f.write("## G band definitions\n\n")
        f.write("```text\n")
        f.write("G < 1900              : 低G側\n")
        f.write("1900 <= G <= 4200     : 広めの高流量比較帯\n")
        f.write("G > 4200              : Table10の超高G側を分ける帯\n")
        f.write("G >= 2400             : 従来PWR近傍G条件\n")
        f.write("2400 <= G <= 4200     : 従来PWR近傍G条件を上限4200でそろえた比較帯\n")
        f.write("```\n\n")

        f.write("## Table G summary\n\n")
        f.write(markdown_table(table_summary, table_cols))
        f.write("\n\n")

        f.write("## Key Table10 comparison\n\n")
        f.write(markdown_table(key_rows, band_cols))
        f.write("\n\n")

        f.write("## All G-band x Table summary\n\n")
        compact = [r for r in band_summary if r["BandID"] in {"all", "G_1900_4200", "G_2400_4200"}]
        f.write(markdown_table(compact, band_cols))
        f.write("\n\n")

        f.write("## Preliminary reading guide\n\n")
        f.write("```text\n")
        f.write("If 1900<=G<=4200 raises Table10 R2 substantially:\n")
        f.write("  Table10 all may be blurred by low-G and ultra-high-G mixing.\n\n")
        f.write("If 2400<=G<=4200 gives similar tendency:\n")
        f.write("  The old PWR-near G condition is consistent with the broader high-flow reading.\n\n")
        f.write("If R2 does not improve much:\n")
        f.write("  Table10 scatter is not explained by G range alone. Keep Hsub/x_eq/P/q level/series differences as candidates.\n")
        f.write("```\n\n")

        f.write("## Outputs\n\n")
        f.write(f"- table G summary CSV: `{table_csv}`\n")
        f.write(f"- G-band Tsub summary CSV: `{band_csv}`\n")
        f.write(f"- run report: `{md_path}`\n")

    print(md_path)
    print(table_csv)
    print(band_csv)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
