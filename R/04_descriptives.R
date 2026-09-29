# 04_descriptives.R
# Last updated: Sept 29, 2026
# Summary statistics for the full dataset, by MHW period, and CI by calendar month.

dat <- read.csv("output/analysis_dataset.csv")
dat$mhw_period <- factor(dat$mhw_period, levels = c("Before MHW", "During MHW", "After MHW"))

raw <- c("ci", "beuti", "chla", "sst", "mld")
anom <- c("ci_anom", "beuti_anom", "chla_anom", "sst_anom", "mld_anom")

full <- NULL
for (v in raw) {
  x <- dat[[v]]
  full <- rbind(full, data.frame(variable = v, n = sum(!is.na(x)), mean = mean(x, na.rm = TRUE),
                                 sd = sd(x, na.rm = TRUE), min = min(x, na.rm = TRUE), max = max(x, na.rm = TRUE)))
}
write.csv(full, "output/descriptives_full.csv", row.names = FALSE)

byp <- NULL
for (v in c(raw, anom)) {
  for (p in levels(dat$mhw_period)) {
    x <- dat[[v]][dat$mhw_period == p]
    byp <- rbind(byp, data.frame(variable = v, period = p, n = sum(!is.na(x)),
                                 mean = mean(x, na.rm = TRUE), sd = sd(x, na.rm = TRUE)))
  }
}
write.csv(byp, "output/descriptives_by_period.csv", row.names = FALSE)

ci_month <- NULL
for (m in 1:12) {
  x <- dat$ci[dat$month == m]
  ci_month <- rbind(ci_month, data.frame(month = m, n = sum(!is.na(x)), mean = mean(x, na.rm = TRUE), sd = sd(x, na.rm = TRUE)))
}
write.csv(ci_month, "output/ci_by_month.csv", row.names = FALSE)
