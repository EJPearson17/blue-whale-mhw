# fig3_timeseries_2017_2023.py
# Last updated: Sept 29, 2026
# Fig 3: monthly CI and raw BEUTI, chl a, SST, MLD for the study period, shaded by MHW period.

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

plt.rcParams["font.size"] = 16

dat = pd.read_csv("output/analysis_dataset.csv", parse_dates=["date"])

start = pd.Timestamp("2017-01-01")
end = pd.Timestamp("2023-01-01")
spans = [("Before MHW", "2017-01-01", "2019-06-01", "#4A90E2", 0.25),
         ("During MHW", "2019-06-01", "2020-06-01", "#E24A4A", 0.30),
         ("After MHW", "2020-06-01", "2023-02-01", "#A8D5E2", 0.30)]

panels = [("ci", "Call Index (CI)"),
          ("beuti", "BEUTI"),
          ("chla", "Chl $a$ (mg m$^{-3}$)"),
          ("sst", "SST (°C)"),
          ("mld", "MLD (m)")]

fig, axes = plt.subplots(5, 1, figsize=(14, 13), sharex=True)

for ax, (v, lab), letter in zip(axes, panels, "abcde"):
    for name, a, b, col, al in spans:
        ax.axvspan(pd.Timestamp(a), pd.Timestamp(b), color=col, alpha=al, lw=0)
    ax.plot(dat.date, dat[v], "k-o", ms=4, lw=1)
    ax.set_ylabel(lab)
    ax.text(0.01, 0.85, letter, transform=ax.transAxes, fontweight="bold")
    ax.grid(alpha=0.3)
    ax.set_xlim(start, end + pd.Timedelta(days=15))

for name, a, b, col, al in spans:
    mid = pd.Timestamp(a) + (min(pd.Timestamp(b), end) - pd.Timestamp(a)) / 2
    axes[0].text(mid, 1.08, name, transform=axes[0].get_xaxis_transform(), ha="center")

axes[-1].xaxis.set_major_locator(mdates.YearLocator(1))
axes[-1].xaxis.set_major_formatter(mdates.DateFormatter("%Y"))
axes[-1].set_xlabel("Date", fontweight="bold")
fig.align_ylabels(axes)
plt.tight_layout()
plt.savefig("figures/fig3_timeseries_2017_2023.png", dpi=300)
