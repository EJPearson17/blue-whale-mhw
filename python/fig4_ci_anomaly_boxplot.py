# fig4_ci_anomaly_boxplot.py
# Last updated: Sept 29, 2026
# Fig 4: CI anomaly by MHW period.

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

plt.rcParams["font.size"] = 16

dat = pd.read_csv("output/analysis_dataset.csv")
periods = ["Before MHW", "During MHW", "After MHW"]
cols = ["#4A90E2", "#E24A4A", "#A8D5E2"]
vals = [dat.ci_anom[dat.mhw_period == p].dropna().values for p in periods]

rng = np.random.default_rng(1)
fig, ax = plt.subplots(figsize=(10, 10))

bp = ax.boxplot(vals, widths=0.55, patch_artist=True, showfliers=False,
                medianprops=dict(color="navy", lw=2.5),
                whiskerprops=dict(lw=1.5), capprops=dict(lw=1.5))
for box, c in zip(bp["boxes"], cols):
    box.set_facecolor(c)
    box.set_alpha(0.85)

for i, v in enumerate(vals):
    ax.scatter(i + 1 + rng.uniform(-0.08, 0.08, len(v)), v, color="gray", alpha=0.6, s=30, zorder=3)
    ax.scatter(i + 1, v.mean(), marker="D", s=180, color="gold", edgecolor="black", zorder=4,
               label="Mean" if i == 0 else None)

ax.axhline(0, color="gray", ls="--", lw=1, alpha=0.7)
ax.set_xticks([1, 2, 3])
ax.set_xticklabels(periods)
ax.set_xlabel("MHW period", fontweight="bold")
ax.set_ylabel("Call index anomaly", fontweight="bold")
ax.grid(axis="y", ls=":", alpha=0.6)
ax.legend(loc="upper right")
plt.tight_layout()
plt.savefig("figures/fig4_ci_anomaly_boxplot.png", dpi=300)
