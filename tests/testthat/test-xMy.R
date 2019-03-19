
context("matrix-weighted inner products")

sim_a <- function(n) rnorm(n)
sim_b <- function(n) rnorm(n)
sim_M <- function(n) matrix(rnorm(n^2), n, n)

# R functions
aMb2vec <- function(a, M, b) c(a, M, b)
vec2aMb <- function(vec) {
  n <- -1 + sqrt(1+length(vec))
  list(a = vec[1:n], M = matrix(vec[n+1:(n^2)], n, n),
       b = vec[n+n^2+1:n])
}
aMb_fun <- function(a, M, b) sum(a * (M %*% b))
aMb_fun_pd <- function(x, a, M, b, n) {
  if(missing(a)) {
    a <- x[1:n]
    x <- x[-(1:n)]
  }
  if(missing(M)) {
    M <- matrix(x[1:n^2], n, n)
    x <- x[-(1:n^2)]
  }
  if(missing(b)) {
    b <- x[1:n]
  }
  aMb_fun(a, M, b)
}

# lists to use for do.call
get_dclists <- function(hname, a, M, b, n) {
  # parse header name
  tmp <- strsplit(hname, split = "")[[1]]
  vnames <- tmp[1:3]
  vtypes <- tmp[5:7]
  # variable list
  vlist <- list(a, M, b)
  names(vlist) <- vnames
  # MakeADFun::data
  odata <- vlist[vtypes == "d"]
  # R::data
  fdata <- setNames(vlist, c("a", "M", "b"))
  # MakeADFun::params
  plist <- list(sim_a(n), sim_M(n), sim_b(n))
  names(plist) <- vnames
  opars <- plist[vtypes == "p"]
  # R grad/hess
  ghlist <- c(list(x = unlist(vlist[vtypes == "p"], use.names = FALSE)),
              fdata[vtypes == "d"])
  list(data = c(model_name = hname, odata), parameters = opars,
       nl = fdata, gh = ghlist, ad = vlist[vtypes == "p"])
}

hnames <- c("xRy_dpd", "Rxz_dpd", "xRz_pdd", "xRy_pdp", "ySx_pdp")

for(hname in hnames) {
  test_that(paste0(hname,
                   " calculates negloglik, gradient, and hessian correctly"), {
    nreps <- 20
    for(ii in 1:nreps) {
      n <- sample(2:5,1)
      a <- sim_a(n)
      b <- sim_b(n)
      M <- sim_M(n)
      dcl <- get_dclists(hname, a, M, b, n)
      aMb_obj <- TMB::MakeADFun(data = dcl$data,
                                parameters = dcl$parameters,
                                DLL = "TMBExports", silent = TRUE)
      # in R
      ll1 <- do.call(aMb_fun, dcl$nl)
      gg1 <- do.call(numDeriv::grad, c(func = aMb_fun_pd, dcl$gh, n = n))
      hh1 <- do.call(numDeriv::hessian, c(func = aMb_fun_pd, dcl$gh, n = n))
      # in TMB
      ll2 <- aMb_obj$fn(unlist(dcl$ad, use.names = FALSE))
      gg2 <- aMb_obj$gr(unlist(dcl$ad, use.names = FALSE))[1,]
      hh2 <- aMb_obj$he(unlist(dcl$ad, use.names = FALSE))
      expect_equal(ll1, ll2, tolerance = 1e-6)
      expect_equal(gg1, gg2, tolerance = 1e-6)
      expect_equal(hh1, hh2, tolerance = 1e-6)
    }
  })
}
