# 05_period_comparisons.R
# Last updated: Sept 29, 2026
# One-way ANOVAs and pairwise two-sided t-tests across MHW periods (Table 1), with Shapiro-Wilk and Levene tests.

library(car)

dat <- read.csv("output/analysis_dataset.csv")
dat$mhw_period <- factor(dat$mhw_period, levels = c("Before MHW", "During MHW", "After MHW"))

vars <- c("ci", "ci_anom", "beuti", "beuti_anom", "chla", "chla_anom", "sst", "sst_anom", "mld", "mld_anom")

pairp <- function(v, a, b) {
  t.test(dat[[v]][dat$mhw_period == a], dat[[v]][dat$mhw_period == b], var.equal = TRUE)$p.value
}

out <- NULL
for (v in vars) {
  fit <- aov(dat[[v]] ~ dat$mhw_period)
  out <- rbind(out, data.frame(
    variable = v,
    anova_F = summary(fit)[[1]][1, "F value"],
    anova_p = summary(fit)[[1]][1, "Pr(>F)"],
    before_vs_during_p = pairp(v, "Before MHW", "During MHW"),
    before_vs_after_p = pairp(v, "Before MHW", "After MHW"),
    during_vs_after_p = pairp(v, "During MHW", "After MHW"),
    shapiro_W = shapiro.test(residuals(fit))$statistic,
    shapiro_p = shapiro.test(residuals(fit))$p.value,
    levene_p = leveneTest(dat[[v]] ~ dat$mhw_period)[1, "Pr(>F)"]
  ))
}

write.csv(out, "output/table1_period_comparisons.csv", row.names = FALSE)
