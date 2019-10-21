
context("gamma_ADFun")

test_that("gamma_ADFun calculates correct negloglik, gradient, and hessian", {
  nll_fun <- function(theta, y) {
    -sum(dgamma(x = y, shape = theta[1], scale = theta[2], log = TRUE))
  }
  nreps <- 20
  for(ii in 1:nreps) {
    # simulate data/parameters
    n <- sample(10:100, 1)
    x <- rexp(n)
    theta <- c(alpha = rexp(1), beta = rexp(1))
    # nll/g/h with R + numDeriv
    ll1 <- nll_fun(theta, x)
    gg1 <- numDeriv::grad(func = nll_fun, x = theta, y = x)
    hh1 <- numDeriv::hessian(func = nll_fun, x = theta, y = x)
    # nll/g/h with TMB
    nll_obj <- gamma_ADFun(x)
    ll2 <- nll_obj$fn(theta)
    gg2 <- nll_obj$gr(theta)[1,]
    hh2 <- nll_obj$he(theta)
    # check they are identical
    expect_equal(ll1, ll2)
    expect_equal(gg1, gg2)
    expect_equal(hh1, hh2)
  }
})
