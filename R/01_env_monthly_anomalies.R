# 01_env_monthly_anomalies.R
# Last updated: Sept 29, 2026
# Monthly BEUTI, chl a, SST and MLD near NRS05, with 2005-2024 climatology and anomalies.

library(ncdf4)

clim_start <- 2005
clim_end <- 2024

add_anom <- function(df, v) {
  base <- df[df$year >= clim_start & df$year <= clim_end, ]
  clim <- tapply(base[[v]], base$month, mean, na.rm = TRUE)
  df[[paste0(v, "_clim")]] <- as.numeric(clim[as.character(df$month)])
  df[[paste0(v, "_anom")]] <- df[[v]] - df[[paste0(v, "_clim")]]
  df
}

# BEUTI, 34N (Jacox et al. 2018)
b <- read.csv("data/raw/BEUTI_monthly.csv", check.names = FALSE)
beuti <- data.frame(year = b$year, month = b$month, beuti = b[["34N"]])
beuti <- add_anom(beuti, "beuti")

# chl a, Aqua MODIS L3m monthly 4 km chlor_a R2022.0, cell nearest NRS05 (33.896N, 119.563W), accessed 25 Jan 2026
ch <- read.csv("data/raw/chla_monthly_raw.csv")
d <- as.Date(sub(" .*", "", ch$time), format = "%m/%d/%Y")
chla <- data.frame(year = as.numeric(format(d, "%Y")), month = as.numeric(format(d, "%m")), chla = ch$chla)
chla <- add_anom(chla, "chla")

# SST, ERSST v5, 34N 120W
nc <- nc_open("data/raw/sst_mnmean.nc")
lat <- ncvar_get(nc, "lat")
lon <- ncvar_get(nc, "lon")
tm <- as.Date(ncvar_get(nc, "time"), origin = "1800-01-01")
x <- ncvar_get(nc, "sst")
nc_close(nc)
i <- which.min(abs(lon - 240))
j <- which.min(abs(lat - 34))
sst <- data.frame(year = as.numeric(format(tm, "%Y")), month = as.numeric(format(tm, "%m")), sst = x[i, j, ])
sst <- add_anom(sst, "sst")

# MLD, GODAS, 33.5N 119.5W
mld <- NULL
for (yr in 2005:2025) {
  nc <- nc_open(paste0("data/raw/dbss_obil_", yr, ".nc"))
  lat <- ncvar_get(nc, "lat")
  lon <- ncvar_get(nc, "lon")
  tm <- as.Date(ncvar_get(nc, "time"), origin = "1800-01-01")
  x <- ncvar_get(nc, "dbss_obil")
  nc_close(nc)
  i <- which.min(abs(lon - 240.5))
  j <- which.min(abs(lat - 33.5))
  mld <- rbind(mld, data.frame(year = as.numeric(format(tm, "%Y")), month = as.numeric(format(tm, "%m")), mld = x[i, j, ]))
}
mld <- add_anom(mld, "mld")

env <- merge(beuti, chla, by = c("year", "month"), all = TRUE)
env <- merge(env, sst, by = c("year", "month"), all = TRUE)
env <- merge(env, mld, by = c("year", "month"), all = TRUE)
env <- env[env$year >= 2005, ]
env <- env[order(env$year, env$month), ]
env$date <- as.Date(paste(env$year, env$month, 1, sep = "-"))
env <- env[, c("date", setdiff(names(env), "date"))]

write.csv(env, "output/env_monthly.csv", row.names = FALSE)
