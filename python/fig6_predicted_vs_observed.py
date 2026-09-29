# fig6_predicted_vs_observed.py
# Last updated: Sept 29, 2026
# Fig 6: predicted vs observed CI anomaly for Models 1-3 (n = 69).

import pandas as pd
import matplotlib.pyplot as plt

plt.rcParams["font.size"] = 16

pred = pd.read_csv("output/fig6_predictions.csv")
r2 = pd.read_csv("output/fig6_models_n69.csv").set_index("model").adj_r2

periods = ["Before MHW", "During MHW", "After MHW"]
cols = {"Before MHW": "#4A90E2", "During MHW": "#E24A4A", "After MHW": "#A8D5E2"}
titles = {"m1": "Model 1: MHW period", "m2": "Model 2: BEUTI only", "m3": "Model 3: MHW + BEUTI"}
lim = (-0.025, 0.022)

fig, axes = plt.subplots(1, 3, figsize=(20, 7.5), sharey=True)

for ax, m in zip(axes, ["m1", "m2", "m3"]):
    for p in periods:
        d = pred[pred.mhw_period == p]
        ax.scatter(d["pred_" + m], d.ci_anom, color=cols[p], edgecolor="black", lw=0.5, s=70, alpha=0.8, label=p)
    ax.plot(lim, lim, color="red", lw=2)
    ax.set_xlim(lim)
    ax.set_ylim(lim)
    ax.set_aspect("equal")
    ax.set_title(f"{titles[m]}\n(Adj. $R^2$ = {r2[m]:.3f})", fontweight="bold")
    ax.set_xlabel("Predicted CI anomaly")
    ax.grid(ls="--", alpha=0.3)

axes[0].set_ylabel("Observed CI anomaly")
h, l = axes[0].get_legend_handles_labels()
fig.legend(h, l, loc="upper center", bbox_to_anchor=(0.5, 0.02), ncol=3, frameon=True)
plt.tight_layout()
plt.savefig("figures/fig6_predicted_vs_observed.png", dpi=300, bbox_inches="tight")
