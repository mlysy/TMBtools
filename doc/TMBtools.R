params <-
list(local_pkg = FALSE, reinstall = FALSE)

## ----setup, include = FALSE---------------------------------------------------
# knitr options
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
# package links
pkg_link <- function(pkg, link) {
  if(link == "github") {
    link <- paste0("https://github.com/mlysy/", pkg)
  } else if(link == "cran") {
    link <- paste0("https://CRAN.R-project.org/package=", pkg)
  }
  paste0("[**", pkg, "**](", link, ")")
}

# tmb system files
tmb_sysfile <- function(...) {
  system.file("templates", ..., package = "TMBtools")
}


if(params$local_pkg) {
  tmbdir <- "/Users/mlysy/Documents/R/test/TMB"
} else {
  # install package to temporary folder
  tmbdir <- tempfile(pattern = "TMBtools_vignette")
}
pkgname <- "MyTMBPackage"

## ---- echo = FALSE, results = "asis"------------------------------------------
cat("```cpp",
    readLines("NormalNLL.cpp"),
    "```", sep = "\n")

## ---- echo = FALSE, results = "asis"------------------------------------------
cat("```cpp",
    readLines(tmb_sysfile("NormalNLL.hpp")),
    "```", sep = "\n")

## ---- eval = FALSE------------------------------------------------------------
#  # in a directory where you want to create the package, which also contains NormalNLL.hpp
#  TMBtools::tmb_create_package("MyTMBPackage",
#                               tmb_files = "NormalNLL.hpp")

## ---- echo = FALSE------------------------------------------------------------
if(!params$local_pkg || params$reinstall) {
  TMBtools::tmb_create_package(file.path(tmbdir, pkgname),
                               tmb_files = "NormalNLL.hpp", open = FALSE)
}

## ---- eval = FALSE------------------------------------------------------------
#  devtools::install() # must have devtools installed

## ---- include = FALSE---------------------------------------------------------
if(params$local_pkg) {
  if(params$reinstall) {
    devtools::install(file.path(tmbdir, pkgname))
  }
  ## suppressMessages(require(MyTMBPackage))
} else {
  pkgbuild::compile_dll(file.path(tmbdir, pkgname))
  devtools::load_all(file.path(tmbdir, pkgname))
  dyn.load(TMB::dynlib(file.path(tmbdir, pkgname,
                                 "src", paste0(pkgname, "_TMBExports"))))
}

## -----------------------------------------------------------------------------
# might have to quit & restart R first, then
# require(MyTMBPackage) 

# create the negative loglikelihood object
x <- rnorm(100) # data
normal_nll <- TMB::MakeADFun(data = list(model = "NormalNLL", x = x),
                             parameters = c(mu = 0, sigma = 1),
                             DLL = "MyTMBPackage_TMBExports", silent = TRUE)

# call the function and its gradients
theta <- list(mu = -1, sigma = 2) # parameter values
normal_nll$fn(theta) # negative loglikelihood at theta
-sum(dnorm(x, mean = theta$mu, sd = theta$sigma, log = TRUE)) # R check
normal_nll$gr(theta) # nll gradient at theta
normal_nll$he(theta) # hessian at theta

## ---- eval = FALSE------------------------------------------------------------
#  TMBtools::export_models()

## ---- echo = FALSE, results = "asis"------------------------------------------
cat("```cpp",
    readLines("MyTMBPackage_TMBExports.cpp"),
    "```", sep = "\n")

## ---- echo = FALSE, results = "asis"------------------------------------------
cat("```bash",
    readLines(tmb_sysfile("Makevars")),
    "```", sep = "\n")

