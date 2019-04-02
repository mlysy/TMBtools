#' Example of using \pkg{TMB} in a package.
#'
#' This function is an \R wrapper to the univariate normal \pkg{TMB} model found in \code{src/TMB/NormNLL.hpp}.
#'
#' @param x Numeric vector of observations.
#' @return A list as returned by \code{TMB::MakeADFun}.
#' @export
norm_ADFun <- function(x) {
  if(!is.numeric(x)) stop("x must be a numeric vector.")
  TMB::MakeADFun(data = list(model_name = "NormNLL", x = x),
                 DLL = "@@pkg@@_TMBExports",
                 parameters = list(mu = 0, sigma = 1), silent = TRUE)
}
