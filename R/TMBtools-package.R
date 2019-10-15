#' Tootls for developing \R packages interfacing with \pkg{TMB}.
#'
#' @details Currently, the packages provides two main functions \code{\link{tmb_package_skeleton}} and \code{export_models}, for creating packages containing \pkg{TMB} source code, and updating the package's compile instructions when new \pkg{TMB} models are added.  Please see walkthrough in \code{vignette(p = "TMBtools")}.
#' @rawNamespace useDynLib(TMBtools); useDynLib(TMBtools_TMBExports)
#' @importFrom Rcpp evalCpp
"_PACKAGE"
