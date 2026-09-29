# 08_model3_diagnostics.R
# Last updated: Sept 29, 2026
# Residual checks for Model 3: Shapiro-Wilk, Durbin-Watson, Breusch-Godfrey, and Newey-West standard errors (3-month lag).

library(lmtest)
library(sandwich)

dat <- read.csv("output/analysis_dataset.csv")
dat$mhw_period <- factor(dat$mhw_period, levels = c("Before MHW", "During MHW", "After MHW"))

m3 <- lm(ci_anom ~ mhw_period + beuti_anom_lag3, data = dat)

sw <- shapiro.test(residuals(m3))
dw <- dwtest(m3)
bg <- bgtest(m3, order = 3)

diag <- data.frame(test = c("Shapiro-Wilk", "Durbin-Watson", "Breusch-Godfrey (order 3)"),
                   statistic = c(sw$statistic, dw$statistic, bg$statistic),
                   p = c(sw$p.value, dw$p.value, bg$p.value))
write.csv(diag, "output/model3_diagnostics.csv", row.names = FALSE)

nw <- coeftest(m3, vcov = NeweyWest(m3, lag = 3, prewhite = FALSE, adjust = FALSE), df = Inf)
ols <- summary(m3)$coefficients
out <- data.frame(term = rownames(ols), estimate = ols[, 1], se_ols = ols[, 2], p_ols = ols[, 4],
                  se_nw = nw[, 2], p_nw = nw[, 4])
write.csv(out, "output/model3_neweywest.csv", row.names = FALSE)
