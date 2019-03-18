
context("norm_ADFun")

test_that("norm_ADFun calculates correct neg. loglikelihood", {
  nreps <- 100
  for(ii in 1:nreps) {
    n <- sample(10:100, 1)
    x <- rnorm(n)
    norm_obj <- norm_ADFun(x)
    mu <- rnorm(1)
    sigma <- rexp(1)
    ll1 <- -sum(dnorm(x = x, mean = mu, sd = sigma, log = TRUE))
    ll2 <- norm_obj$fn(c(mu, sigma))
    expect_equal(ll1, ll2)
  }
})
