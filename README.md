# Blue whale call index and the 2019 NE Pacific marine heatwave

Code and data for:

> [Authors]. [Year]. [Title]. Endangered Species Research. [DOI]

This repo reproduces the call index (CI), environmental anomalies, statistics, tables, and figures in the paper. MATLAB builds the daily CI from raw acoustic data, R does the data processing and statistics, and Python makes Figs 2–6. Fig 1 is made in R.

## Folders

```
matlab/     daily LTSAs and daily call index from raw NRS05 audio
R/          monthly data, anomalies, statistics, table csvs, Fig 1
python/     Figs 2-6
data/raw/   input data
output/     everything the R scripts write
figures/    figure files
```

## Running it

Run everything from the top folder of the repo.

### 1. MATLAB (optional)

The daily CI files in `data/raw/` were made with these scripts, so you only need this step to rebuild CI from the raw audio. Run once per deployment:

1. `step1_make_daily_LTSAs.m`: daily calibrated LTSAs (1 min, 1 Hz). Set the file prefix, calibration file, and hydrophone sensitivity at the top for each deployment.
2. `step2_daily_spectra_by_solar_elevation.m`: daily spectrum level sums and minute counts.
3. `step3_daily_call_index.m`: daily blue whale B call index, one csv per deployment.

Requires the Signal Processing Toolbox (`pwelch`, `hanning`).

### 2. R

```
Rscript R/01_env_monthly_anomalies.R
Rscript R/02_ci_monthly_anomalies.R
Rscript R/03_build_analysis_dataset.R
Rscript R/04_descriptives.R
Rscript R/05_period_comparisons.R
Rscript R/06_ccf.R
Rscript R/07_regression_models.R
Rscript R/08_model3_diagnostics.R
Rscript R/fig1_map.R
```

| Script | Output | In the paper |
|---|---|---|
| 01 | `env_monthly.csv` | BEUTI, chl a, SST, MLD and anomalies (2005-2024 climatology) |
| 02 | `ci_monthly.csv` | monthly CI and CI anomaly |
| 03 | `analysis_dataset.csv` | dataset used for all analyses |
| 04 | `descriptives_*.csv`, `ci_by_month.csv` | Sections 2.3, 3.1 |
| 05 | `table1_period_comparisons.csv` | Table 1 |
| 06 | `table3_ccf.csv` | Table 3 |
| 07 | `table2_models.csv`, `model_coefficients.csv`, `model1_tukey.csv`, `vif.csv`, `ftest_m3_m6.csv`, `rmse.csv`, `fig6_*.csv` | Table 2, Section 3.4, Fig 6 |
| 08 | `model3_diagnostics.csv`, `model3_neweywest.csv` | Section 3.4 |
| fig1_map | `figures/fig1_map.png` | Fig 1 |

The first time `fig1_map.R` runs, ggOceanMaps downloads about 90 MB of bathymetry data and asks where to keep it.

### 3. Python

```
python python/fig2_timeseries_2005_2025.py
python python/fig3_timeseries_2017_2023.py
python python/fig4_ci_anomaly_boxplot.py
python python/fig5_env_anomaly_boxplots.py
python python/fig6_predicted_vs_observed.py
```

These read from `output/`, so run the R scripts first.

## Data

Included in `data/raw/`:

- `NRS05_Channel_Islands_*_daily_CI_with_ratio_and_month.csv`: daily CI for the four NRS05 deployments (2015-2017, 2018-2020, 2019-2021, 2021-2023), from the MATLAB scripts. Where deployments overlap, the earlier deployment is used. The CI_Ratio column is not used.
- `BEUTI_monthly.csv`: Biologically Effective Upwelling Transport Index, 34N (Jacox et al. 2018). https://mjacox.com/upwelling-indices/
- `chla_monthly_raw.csv`: chlorophyll a from NASA Aqua MODIS Level-3 mapped monthly 4 km chlor_a, version R2022.0 (https://doi.org/10.5067/AQUA/MODIS/L3M/CHL/2022.0), single 4 km cell nearest NRS05 (33.896N, 119.563W), accessed 25 Jan 2026. NASA's later R2022.0.3 reprocessing changed some values from 2021 on, so current downloads will not match this file exactly after 2020.

Not included (too large), download and put in `data/raw/`:

- SST: NOAA ERSST v5 monthly, https://psl.noaa.gov/data/gridded/data.noaa.ersst.v5.html. Save as `sst_mnmean.nc`. Extracted at 34N, 120W. ERSST is updated regularly, so values can shift slightly between downloads.
- MLD: NCEP GODAS monthly `dbss_obil`, one file per year for 2005-2025, https://psl.noaa.gov/data/gridded/data.godas.html. Save as `dbss_obil_YYYY.nc`. Extracted at 33.5N, 119.5W.

Raw acoustic data: NOAA Noise Reference Station NRS05 (Channel Islands, 33.897N, 119.58W), NOAA passive bioacoustic archive, https://console.cloud.google.com/storage/browser/noaa-passive-bioacoustic/nrs

## Software

- MATLAB [version], Signal Processing Toolbox
- R 4.3.3: ncdf4 1.22, car 3.1-2, lmtest 0.9-40, sandwich 3.1-0, ggOceanMaps 3.0.2, cowplot 1.1.3
- Python 3.12: pandas 3.0.2, numpy 2.4.4, matplotlib 3.10.8

## Credits

`step1_make_daily_LTSAs.m`, `step1_fn_daily_file_list.m` and `step3_fn_call_index.m` were written by John Ryan (MBARI), with changes by Carrie Wall. `step3_daily_call_index.m` is adapted from code by W. Oestreich. `step2_fn_SolarAzEl.m` is by Darin Koblick (MATLAB File Exchange).
