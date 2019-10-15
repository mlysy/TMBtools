
context("lm_eigen")

test_that("lm_eigen calculates correct regression output", {
  nreps <- 20
  for(ii in 1:nreps) {
    n <- sample(10:100, 1)
    p <- sample(3:6,1)
    X <- matrix(rnorm(n*p), n, p)
    y <- rnorm(n)
    M <- lm(y ~ X - 1)
    M2 <- lm_eigen(y, X)
    rownames(M2$vcov) <- colnames(M2$vcov) <- names(M2$coef) <- names(coef(M))
    expect_equal(coef(M), M2$coef)
    expect_equal(vcov(M), M2$vcov)
    expect_equal(sigma(M), M2$sigma)
  }
})
