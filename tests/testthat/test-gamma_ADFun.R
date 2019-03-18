
context("gamma_ADFun")

test_that("gamma_ADFun calculates correct neg. loglikelihood", {
  nreps <- 100
  for(ii in 1:nreps) {
    n <- sample(10:100, 1)
    x <- rexp(n)
    gamma_obj <- gamma_ADFun(x)
    alpha <- rexp(1)
    beta <- rexp(1)
    ll1 <- -sum(dgamma(x = x, shape = alpha, scale = beta, log = TRUE))
    ll2 <- gamma_obj$fn(c(alpha, beta))
    expect_equal(ll1, ll2)
  }
})
