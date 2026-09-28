# ==============================================================================
# Statistical Analysis Code
# ==============================================================================
# Purpose:
#   Reproduce the beta-regression and hurdle-model analyses using the county-
#   level analytic dataset stored in "Data.xlsx".
#
# Input file:
#   Data.xlsx
#
# Software environment used for the submitted analysis:
#   R version 4.5.2 (2025-10-31 ucrt)
#   Platform: x86_64-w64-mingw32/x64
#   Operating system: Windows 10 x64 (build 19045)
#   Matrix products: default
#   LAPACK version: 3.12.1
#
# Instructions:
#   1. Place this script and "Data.xlsx" in the same working directory.
#   2. Install the required packages if they are not already installed.
#   3. Set the R working directory to the folder containing both files.
#   4. Run this script from beginning to end.
# ==============================================================================

# ---- Required packages -------------------------------------------------------
library(readxl)
library(dplyr)
library(betareg)
library(logistf)
library(MASS)
library(sandwich)
library(lmtest)

# ---- Import and prepare data -------------------------------------------------
data_path <- "Data.xlsx"

dat <- read_excel(data_path)

dat <- dat %>%
  mutate(
    # MMR coverage on the 0-1 scale for beta regression. Values of exactly 0 or
    # 1 are moved slightly inside the open interval (0, 1), as required by
    # betareg.
    coverage = ifelse(
      MMR_Coverage_Prop == 1,
      0.999,
      ifelse(MMR_Coverage_Prop == 0, 0.001, MMR_Coverage_Prop)
    ),

    # MMR coverage in percentage points for the count and hurdle models.
    coverage_pct = MMR_Coverage_Prop * 100,

    # Nonmedical exemption rate in percentage points.
    exemption = Exemption_Pct,

    # Outbreak indicator: 1 for counties with 3 or more cases; 0 otherwise.
    outbreak = as.integer(Cases_2025 >= 3),

    # Covariates and derived variables.
    log_foreign = log(forgn_born_popn_pct_23 + 0.01),
    log_physician = log(phys_nf_prim_care_pc_exc_rsdt_23 + 0.01),
    log_pop = log(popn_est_23),
    log_density = log(popn_densty_per_squr_mi_20 + 0.01),
    metro = as.integer(RUCC_2023 %in% c(1, 2, 3)),
    uninsured = pers_noins_lt65_pct_22,
    college = pers_4yrs_collg_ge25_pct_23,
    gop_share = gop_vote_share_pct_24
  ) %>%
  filter(
    complete.cases(
      coverage,
      coverage_pct,
      exemption,
      Cases_2025,
      outbreak,
      log_foreign,
      metro,
      uninsured,
      college,
      gop_share,
      log_physician,
      log_density,
      log_pop,
      State
    )
  )

# Counties with an outbreak, used for the count component of the hurdle models.
dat_outbreak <- dat %>% filter(Cases_2025 >= 3)

# ---- Covariates --------------------------------------------------------------
# Covariates used in every model; Census Division fixed effects were not used.
covars <- paste(
  "log_density + log_foreign + metro + uninsured + college +",
  "gop_share + log_physician"
)

# ---- Model 1: beta regression (exemption -> coverage) -----------------------
f1 <- as.formula(paste("coverage ~ exemption +", covars))
m1 <- betareg(f1, data = dat, link = "logit")

# State-clustered HC1 standard errors.
m1_vcov <- vcovCL(m1, cluster = dat$State, type = "HC1")
m1_res <- coeftest(m1, vcov = m1_vcov)

cat("\n--- Model 1: beta regression (outcome = MMR coverage) ---\n")
print(m1_res)

# ---- Hurdle models -----------------------------------------------------------
# Binary component: Firth penalized logistic regression for outbreak versus no
# outbreak.
# Count component: negative binomial regression for measles case counts among
# outbreak counties, with the natural logarithm of county population as an
# offset.

run_hurdle <- function(outcome_var) {
  f0 <- as.formula(paste("outbreak ~", outcome_var, "+", covars))
  f2 <- as.formula(
    paste("Cases_2025 ~", outcome_var, "+", covars, "+ offset(log_pop)")
  )

  fit0 <- logistf(f0, data = dat)
  fit2 <- glm.nb(f2, data = dat_outbreak)

  # State-clustered HC1 standard errors for the count component.
  vcov2 <- vcovCL(fit2, cluster = dat_outbreak$State, type = "HC1")
  res2 <- coeftest(fit2, vcov = vcov2)

  list(zero = fit0, count = fit2, count_res = res2)
}

# ---- Model 2: coverage -> outbreak and case count ---------------------------
m2 <- run_hurdle("coverage_pct")

cat("\n--- Model 2 binary component: Firth logistic (outcome = outbreak) ---\n")
print(summary(m2$zero))

cat("\n--- Model 2 count component: negative binomial (outcome = case count) ---\n")
print(m2$count_res)

# ---- Model 3: exemption -> outbreak and case count --------------------------
m3 <- run_hurdle("exemption")

cat("\n--- Model 3 binary component: Firth logistic (outcome = outbreak) ---\n")
print(summary(m3$zero))

cat("\n--- Model 3 count component: negative binomial (outcome = case count) ---\n")
print(m3$count_res)

# ---- Model 4: exemption + coverage -> outbreak and case count ---------------
f4_zero <- as.formula(
  paste("outbreak ~ exemption + coverage_pct +", covars)
)
f4_count <- as.formula(
  paste(
    "Cases_2025 ~ exemption + coverage_pct +",
    covars,
    "+ offset(log_pop)"
  )
)

m4_zero <- logistf(f4_zero, data = dat)
m4_count <- glm.nb(f4_count, data = dat_outbreak)

# State-clustered HC1 standard errors for the count component.
m4_vcov <- vcovCL(m4_count, cluster = dat_outbreak$State, type = "HC1")
m4_res <- coeftest(m4_count, vcov = m4_vcov)

cat("\n--- Model 4 binary component: Firth logistic (outcome = outbreak) ---\n")
print(summary(m4_zero))

cat("\n--- Model 4 count component: negative binomial (outcome = case count) ---\n")
print(m4_res)

# ---- Session information ----------------------------------------------------
# Print the session information from the environment in which the script is run.
cat("\n--- Session information ---\n")
sessionInfo()

# Recorded session information for the analysis environment:
#
# R version 4.5.2 (2025-10-31 ucrt)
# Platform: x86_64-w64-mingw32/x64
# Running under: Windows 10 x64 (build 19045)
# Matrix products: default
# LAPACK version: 3.12.1
#
# Attached base packages:
# stats_4.5.2, graphics_4.5.2, grDevices_4.5.2, utils_4.5.2,
# datasets_4.5.2, methods_4.5.2, base_4.5.2
#
# Other attached packages:
# dplyr_1.2.1, readxl_1.5.0, spdep_1.4-2, sf_1.1-1, spData_2.3.5,
# car_3.1-5, carData_3.0-5, betareg_3.2-4, lmtest_0.9-40, zoo_1.8-14,
# sandwich_3.1-1, logistf_1.26.1, MASS_7.3-65
#
# Loaded via a namespace (and not attached):
# shape_1.4.6.1, formula.tools_1.7.1, lattice_0.22-7,
# LearnBayes_2.15.2, vctrs_0.7.3, tools_4.5.2, Rdpack_2.6.4,
# generics_0.1.4, stats4_4.5.2, flexmix_2.3-20, tibble_3.3.0,
# proxy_0.4-29, pan_1.9, pkgconfig_2.0.3, jomo_2.7-6, Matrix_1.7-4,
# KernSmooth_2.23-26, data.table_1.18.2.1, lifecycle_1.0.5,
# deldir_2.0-4, compiler_4.5.2, codetools_0.2-20,
# marginaleffects_0.32.0, class_7.3-23, glmnet_4.1-10, Formula_1.2-5,
# mice_3.18.0, pillar_1.11.1, nloptr_2.2.1, tidyr_1.3.2,
# rsconnect_1.5.1, classInt_0.4-11, spatialreg_1.4-3, wk_0.9.5,
# reformulas_0.4.4, iterators_1.0.14, multcomp_1.4-29, rpart_4.1.24,
# boot_1.3-32, abind_1.4-8, foreach_1.5.2, mitml_0.4-5,
# nlme_3.1-168, tidyselect_1.2.1, mvtnorm_1.3-3, purrr_1.2.2,
# splines_4.5.2, operator.tools_1.6.3.1, grid_4.5.2, cli_3.6.5,
# magrittr_2.0.4, survival_3.8-3, TH.data_1.1-5, broom_1.0.13,
# e1071_1.7-17, backports_1.5.0, sp_2.2-1, igraph_2.2.0,
# nnet_7.3-20, lme4_1.1-37, cellranger_1.1.0, modeltools_0.2-24,
# coda_0.19-4.1, rbibutils_2.3, s2_1.1.9, mgcv_1.9-3, rlang_1.2.0,
# Rcpp_1.1.0, glue_1.8.0, DBI_1.2.3, rstudioapi_0.17.1,
# minqa_1.2.8, R6_2.6.1, units_1.0-1
