# fig2_timeseries_2005_2025.py
# Last updated: Sept 29, 2026
# Fig 2: monthly CI (2017-2023) and raw BEUTI, chl a, SST, MLD (2005-2025), shaded by MHW period.

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

plt.rcParams["font.size"] = 16

env = pd.read_csv("output/env_monthly.csv", parse_dates=["date"])
dat = pd.read_csv("output/analysis_dataset.csv", parse_dates=["date"])
env = env[(env.date >= "2005-01-01") & (env.date <= "2025-01-01")]

start = pd.Timestamp("2005-01-01")
end = pd.Timestamp("2025-01-01")
spans = [("Before MHW", "2017-01-01", "2019-06-01", "#4A90E2", 0.25),
         ("During MHW", "2019-06-01", "2020-06-01", "#E24A4A", 0.30),
         ("After MHW", "2020-06-01", end, "#A8D5E2", 0.30)]

panels = [(dat, "ci", "Call Index (CI)"),
          (env, "beuti", "BEUTI"),
          (env, "chla", "Chl $a$ (mg m$^{-3}$)"),
          (env, "sst", "SST (°C)"),
          (env, "mld", "MLD (m)")]

fig, axes = plt.subplots(5, 1, figsize=(14, 13), sharex=True)

for ax, (d, v, lab), letter in zip(axes, panels, "abcde"):
    for name, a, b, col, al in spans:
        ax.axvspan(pd.Timestamp(a), pd.Timestamp(b), color=col, alpha=al, lw=0)
    ax.plot(d.date, d[v], "k-o", ms=4, lw=1)
    ax.set_ylabel(lab)
    ax.text(0.01, 0.85, letter, transform=ax.transAxes, fontweight="bold")
    ax.grid(alpha=0.3)
    ax.set_xlim(start, end)

for name, a, b, col, al in spans:
    mid = pd.Timestamp(a) + (pd.Timestamp(b) - pd.Timestamp(a)) / 2
    y = 1.28 if name == "During MHW" else 1.08
    axes[0].text(mid, y, name, transform=axes[0].get_xaxis_transform(), ha="center")

axes[-1].xaxis.set_major_locator(mdates.YearLocator(2))
axes[-1].xaxis.set_major_formatter(mdates.DateFormatter("%Y"))
axes[-1].set_xlabel("Date", fontweight="bold")
fig.align_ylabels(axes)
plt.tight_layout()
plt.savefig("figures/fig2_timeseries_2005_2025.png", dpi=300)
