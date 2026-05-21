# -------------------------------------------------------------------------
# 1. Load Required Libraries & Set Seed
# -------------------------------------------------------------------------
if (!requireNamespace("msm", quietly = TRUE)) install.packages("msm")
library(msm)
set.seed(123)

# -------------------------------------------------------------------------
# 2. Simulate Synthetic Data
#    intervention genuinely shifts transition probabilities via int_effect
# -------------------------------------------------------------------------
n_patients <- 600
max_visits  <- 5
data_list   <- list()

for (i in 1:n_patients) {
  n_vis <- sample(3:max_visits, 1)
  years <- sort(runif(n_vis, 0, 5))
  intervention <- sample(c("A", "B", "C", "D", "E"), 1)
  int_effect   <- switch(intervention, A=1.0, B=1.4, C=1.8, D=0.7, E=0.5)

  states    <- numeric(n_vis); states[1] <- 1
  for (v in 2:n_vis) {
    if (states[v-1] == 1) {
      p_stay <- max(0.1, 0.5 / int_effect); p_mid <- 0.35
      p_bad  <- max(0.05, 1 - p_stay - p_mid)
      probs  <- c(p_stay, p_mid, p_bad) / sum(c(p_stay, p_mid, p_bad))
      states[v] <- sample(1:3, 1, prob = probs)
    } else if (states[v-1] == 2) {
      p_stay <- max(0.1, 0.6 / int_effect)
      p_bad  <- max(0.05, 1 - p_stay)
      probs  <- c(p_stay, p_bad) / sum(c(p_stay, p_bad))
      states[v] <- sample(2:3, 1, prob = probs)
    } else {
      states[v] <- 3   # absorbing state
    }
  }
  data_list[[i]] <- data.frame(
    id           = i,
    years        = years,
    state        = states,
    intervention = factor(intervention, levels = c("A", "B", "C", "D", "E")),
    td_cov1      = rnorm(n_vis),
    td_cov2      = rbinom(n_vis, 1, 0.5)
  )
}

df_msm <- do.call(rbind, data_list)
df_msm <- df_msm[order(df_msm$id, df_msm$years), ]

# Keep rows up to and including first absorbing-state visit per subject
df_msm <- do.call(rbind, lapply(split(df_msm, df_msm$id), function(d) {
  first_abs <- which(d$state == 3)
  if (length(first_abs) == 0) return(d)
  d[1:first_abs[1], ]
}))

# -------------------------------------------------------------------------
# 3. Define Q-matrix structure, then get data-driven starting values
#
# FIX 1 — crudeinits.msm() instead of hand-coded q_initial
#   msm's covariate log-likelihood surface has a flat ridge along beta=0
#   (all HRs = 1). Starting from hand-coded intensities like 0.2/0.3 puts
#   the optimizer right on that ridge and Nelder-Mead never escapes it.
#   crudeinits.msm() estimates starting intensities from the observed
#   transition counts and sojourn times, giving a genuinely informative
#   starting point that is already off the flat region.
# -------------------------------------------------------------------------
q_structure <- matrix(c(0, 0.2, 0.1,
                         0, 0.0, 0.3,
                         0, 0.0, 0.0), nrow = 3, byrow = TRUE)

q_init <- crudeinits.msm(state ~ years, subject = id,
                          data = df_msm, qmatrix = q_structure)

# -------------------------------------------------------------------------
# 4. Fit the MSM Model
#
# FIX 2 — method = "BFGS" instead of the default Nelder-Mead
#   With a 5-level factor covariate there are 4 × 3 = 12 covariate
#   parameters on top of the 3 baseline intensities. Nelder-Mead is a
#   derivative-free simplex method; it is notoriously slow and unreliable
#   in high-dimensional or ridge-shaped likelihood surfaces.
#   BFGS uses gradient information (computed by msm via numerical
#   differentiation), so it can follow the likelihood slope out of the
#   flat HR=1 region. Convergence code 0 confirms success.
# -------------------------------------------------------------------------
msm_model <- msm(
  state ~ years,
  subject    = id,
  data       = df_msm,
  qmatrix    = q_init,
  covariates = ~ intervention,
  method     = "BFGS",                                   # <-- key fix
  control    = list(fnscale = 2000, maxit = 10000, reltol = 1e-10)
)

# -------------------------------------------------------------------------
# 5. Extract Outputs
# -------------------------------------------------------------------------
cat("\n==================================================\n")
cat("1. BASELINE TRANSITION INTENSITY MATRIX (Q)\n")
cat("==================================================\n")
print(qmatrix.msm(msm_model))

cat("\n==================================================\n")
cat("2. PROBABILITY TRANSITION MATRIX (P over 1 year)\n")
cat("==================================================\n")
print(pmatrix.msm(msm_model, t = 1))

cat("\n==================================================\n")
cat("3. HAZARD RATIOS (reference group: A)\n")
cat("==================================================\n")
print(hazard.msm(msm_model))

cat("\nOptimiser convergence code (0 = success):", msm_model$opt$convergence, "\n")
