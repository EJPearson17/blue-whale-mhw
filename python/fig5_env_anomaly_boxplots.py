# fig5_env_anomaly_boxplots.py
# Last updated: Sept 29, 2026
# Fig 5: BEUTI, chl a, SST and MLD anomalies by MHW period.

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

plt.rcParams["font.size"] = 16

dat = pd.read_csv("output/analysis_dataset.csv")
periods = ["Before MHW", "During MHW", "After MHW"]
cols = ["#4A90E2", "#E24A4A", "#A8D5E2"]

panels = [("beuti_anom", "A. BEUTI anomaly", "BEUTI anomaly"),
          ("chla_anom", "B. Chl $a$ anomaly (mg m$^{-3}$)", "Chl $a$ anomaly (mg m$^{-3}$)"),
          ("sst_anom", "C. SST anomaly (°C)", "SST anomaly (°C)"),
          ("mld_anom", "D. MLD anomaly (m)", "MLD anomaly (m)")]

rng = np.random.default_rng(1)
fig, axes = plt.subplots(2, 2, figsize=(15, 13))

for ax, (v, title, ylab) in zip(axes.flat, panels):
    vals = [dat[v][dat.mhw_period == p].dropna().values for p in periods]
    bp = ax.boxplot(vals, widths=0.55, patch_artist=True, showfliers=False,
                    medianprops=dict(color="navy", lw=2.5),
                    whiskerprops=dict(lw=1.5), capprops=dict(lw=1.5))
    for box, c in zip(bp["boxes"], cols):
        box.set_facecolor(c)
        box.set_alpha(0.75)
    for i, x in enumerate(vals):
        ax.scatter(i + 1 + rng.uniform(-0.08, 0.08, len(x)), x, color="gray", alpha=0.4, s=30, zorder=3)
        ax.scatter(i + 1, x.mean(), marker="D", s=150, color="gold", edgecolor="black", zorder=4)
    ax.axhline(0, color="gray", ls="--", lw=1, alpha=0.7)
    ax.set_xticks([1, 2, 3])
    ax.set_xticklabels(periods)
    ax.set_title(title, fontweight="bold")
    ax.set_ylabel(ylab)

for ax in axes[1]:
    ax.set_xlabel("MHW period")

plt.tight_layout()
plt.savefig("figures/fig5_env_anomaly_boxplots.png", dpi=300)
