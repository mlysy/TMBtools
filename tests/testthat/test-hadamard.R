
context("hadamard")

test_that("hadamard calculates elementwise matrix multiplication correctly", {
  nreps <- 20
  for(ii in 1:nreps) {
    n <- sample(10:100, 1)
    p <- sample(10:100,1)
    A <- matrix(rnorm(n*p), n, p)
    B <- matrix(rnorm(n*p), n, p)
    C_r <- A * B
    C_cpp <- hadamard(A, B)
    expect_equal(C_r, C_cpp)
  }
})
