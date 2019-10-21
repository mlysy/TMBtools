#' Tools for developing \R packages interfacing with \pkg{TMB}.
#'
#' @details Currently, the packages provides two main functions \code{\link{tmb_create_package}} and \code{\link{export_models}}, for creating packages containing \pkg{TMB} source code, and updating the package's compile instructions when new \pkg{TMB} models are added.  Please see walkthrough in \code{vignette(p = "TMBtools")}.
#' @rawNamespace useDynLib(TMBtools, .registration = TRUE); useDynLib(TMBtools_TMBExports)
#' @importFrom usethis use_directory ui_line ui_info ui_value ui_todo ui_code_block ui_path ui_done ui_stop
#' @importFrom Rcpp evalCpp
"_PACKAGE"
