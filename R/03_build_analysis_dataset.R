# 03_build_analysis_dataset.R
# Last updated: Sept 29, 2026
# Merges monthly CI and environmental anomalies for Jan 2017 - Jan 2023, assigns MHW periods, and adds lags.

ci <- read.csv("output/ci_monthly.csv")
env <- read.csv("output/env_monthly.csv")

dat <- data.frame(date = seq(as.Date("2017-01-01"), as.Date("2023-01-01"), by = "month"))
dat$year <- as.numeric(format(dat$date, "%Y"))
dat$month <- as.numeric(format(dat$date, "%m"))

dat <- merge(dat, ci[, c("year", "month", "ci", "n_days", "ci_anom")], by = c("year", "month"), all.x = TRUE)
dat <- merge(dat, env[, c("year", "month", "beuti", "beuti_anom", "chla", "chla_anom",
                          "sst", "sst_anom", "mld", "mld_anom")], by = c("year", "month"), all.x = TRUE)
dat <- dat[order(dat$date), ]

dat$mhw_period <- "Before MHW"
dat$mhw_period[dat$date >= as.Date("2019-06-01")] <- "During MHW"
dat$mhw_period[dat$date >= as.Date("2020-06-01")] <- "After MHW"

lagn <- function(x, k) c(rep(NA, k), head(x, -k))
dat$beuti_anom_lag3 <- lagn(dat$beuti_anom, 3)
dat$mld_anom_lag5 <- lagn(dat$mld_anom, 5)

dat <- dat[, c("date", "year", "month", "mhw_period", "ci", "n_days", "ci_anom",
               "beuti", "beuti_anom", "beuti_anom_lag3", "chla", "chla_anom",
               "sst", "sst_anom", "mld", "mld_anom", "mld_anom_lag5")]

write.csv(dat, "output/analysis_dataset.csv", row.names = FALSE)
