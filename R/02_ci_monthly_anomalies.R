# 02_ci_monthly_anomalies.R
# Last updated: Sept 29, 2026
# Combines daily CI from the NRS05 deployments, averages to monthly, and computes CI anomalies.

files <- sort(list.files("data/raw", pattern = "daily_CI_with_ratio_and_month.csv$", full.names = TRUE))

daily <- NULL
for (f in files) {
  x <- read.csv(f)
  # CI_Ratio column not used
  daily <- rbind(daily, data.frame(date = as.Date(x$Date, format = "%d-%b-%Y"), ci = x$CI))
}

# where deployments overlap, keep the earlier deployment
daily <- daily[!duplicated(daily$date), ]
daily <- daily[!is.na(daily$ci), ]

daily$year <- as.numeric(format(daily$date, "%Y"))
daily$month <- as.numeric(format(daily$date, "%m"))

ci <- aggregate(ci ~ year + month, data = daily, FUN = mean)
n <- aggregate(ci ~ year + month, data = daily, FUN = length)
names(n)[3] <- "n_days"
ci <- merge(ci, n, by = c("year", "month"))
ci <- ci[order(ci$year, ci$month), ]

clim <- tapply(ci$ci, ci$month, mean)
ci$ci_clim <- as.numeric(clim[as.character(ci$month)])
ci$ci_anom <- ci$ci - ci$ci_clim

ci$date <- as.Date(paste(ci$year, ci$month, 1, sep = "-"))
ci <- ci[, c("date", "year", "month", "ci", "n_days", "ci_clim", "ci_anom")]

write.csv(ci, "output/ci_monthly.csv", row.names = FALSE)
