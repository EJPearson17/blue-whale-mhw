# 07_regression_models.R
# Last updated: Sept 29, 2026
# Models 0-6 for CI anomaly (Table 2), coefficients, Tukey HSD for Model 1, VIFs, nested F-test, RMSE, and fitted values for Fig 6.

library(car)

dat <- read.csv("output/analysis_dataset.csv")
dat$mhw_period <- factor(dat$mhw_period, levels = c("Before MHW", "During MHW", "After MHW"))

f <- list(
  m0 = ci_anom ~ 1,
  m1 = ci_anom ~ mhw_period,
  m2 = ci_anom ~ beuti_anom_lag3,
  m3 = ci_anom ~ mhw_period + beuti_anom_lag3,
  m4 = ci_anom ~ mhw_period * beuti_anom_lag3,
  m5 = ci_anom ~ beuti_anom_lag3 + chla_anom + sst_anom + mld_anom_lag5,
  m6 = ci_anom ~ mhw_period + beuti_anom_lag3 + chla_anom + sst_anom + mld_anom_lag5
)

fits <- lapply(f, function(x) lm(x, data = dat))

# common sample for AICc (n = 67)
d67 <- dat[complete.cases(dat[, c("ci_anom", "beuti_anom_lag3", "chla_anom", "sst_anom", "mld_anom_lag5")]), ]
fits67 <- lapply(f, function(x) lm(x, data = d67))

aicc <- function(m) {
  k <- length(coef(m)) + 1
  n <- nobs(m)
  AIC(m) + 2 * k * (k + 1) / (n - k - 1)
}

tab <- data.frame(model = names(f),
                  n = sapply(fits, nobs),
                  K = sapply(fits, function(m) length(coef(m)) + 1),
                  r2 = sapply(fits, function(m) summary(m)$r.squared),
                  adj_r2 = sapply(fits, function(m) summary(m)$adj.r.squared),
                  sigma = sapply(fits, function(m) summary(m)$sigma),
                  AICc_n67 = sapply(fits67, aicc))
tab$dAICc <- tab$AICc_n67 - min(tab$AICc_n67)
write.csv(tab, "output/table2_models.csv", row.names = FALSE)

coefs <- NULL
for (nm in names(fits)) {
  s <- summary(fits[[nm]])$coefficients
  coefs <- rbind(coefs, data.frame(model = nm, term = rownames(s), estimate = s[, 1], se = s[, 2], t = s[, 3], p = s[, 4]))
}
write.csv(coefs, "output/model_coefficients.csv", row.names = FALSE)

tk <- TukeyHSD(aov(ci_anom ~ mhw_period, data = dat))$mhw_period
write.csv(data.frame(comparison = rownames(tk), tk), "output/model1_tukey.csv", row.names = FALSE)

v5 <- vif(fits$m5)
v6 <- vif(fits$m6)
vifs <- rbind(data.frame(model = "m5", term = names(v5), vif = as.numeric(v5)),
              data.frame(model = "m6", term = rownames(v6), vif = v6[, "GVIF"]))
write.csv(vifs, "output/vif.csv", row.names = FALSE)

ft <- anova(fits67$m3, fits67$m6)
write.csv(data.frame(comparison = "m3 vs m6 (n = 67)", df1 = ft$Df[2], df2 = ft$Res.Df[2], F = ft$F[2], p = ft$"Pr(>F)"[2]),
          "output/ftest_m3_m6.csv", row.names = FALSE)

rmse <- sapply(fits, function(m) sqrt(mean(residuals(m)^2)))
write.csv(data.frame(model = names(rmse), rmse = rmse), "output/rmse.csv", row.names = FALSE)

# Fig 6: Models 1-3 refit on the same months (n = 69)
d69 <- dat[complete.cases(dat[, c("ci_anom", "beuti_anom_lag3")]), ]
pred <- d69[, c("date", "mhw_period", "ci_anom")]
fig6 <- NULL
for (nm in c("m1", "m2", "m3")) {
  m <- lm(f[[nm]], data = d69)
  pred[[paste0("pred_", nm)]] <- fitted(m)
  fig6 <- rbind(fig6, data.frame(model = nm, n = nobs(m), adj_r2 = summary(m)$adj.r.squared))
}
write.csv(pred, "output/fig6_predictions.csv", row.names = FALSE)
write.csv(fig6, "output/fig6_models_n69.csv", row.names = FALSE)
