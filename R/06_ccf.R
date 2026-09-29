# 06_ccf.R
# Last updated: Sept 29, 2026
# Cross-correlations between each environmental anomaly and CI anomaly at lags of 0-5 months (Table 3).

dat <- read.csv("output/analysis_dataset.csv")

lagn <- function(x, k) c(rep(NA, k), head(x, length(x) - k))

out <- NULL
for (v in c("beuti_anom", "chla_anom", "sst_anom", "mld_anom")) {
  for (k in 0:5) {
    ct <- cor.test(dat$ci_anom, lagn(dat[[v]], k))
    out <- rbind(out, data.frame(variable = v, lag = k, n = ct$parameter + 2, r = ct$estimate, p = ct$p.value))
  }
}

write.csv(out, "output/table3_ccf.csv", row.names = FALSE)
