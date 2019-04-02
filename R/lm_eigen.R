#' Calculate some regression output using \pkg{RcppEigen}.
#'
#' @param y Response vector.
#' @param X Design matrix, including intercept column if desired.
#' @return List with elements:
#' \describe{
#'   \item{\code{coef}}{Regression parameter estimates.}
#'   \item{\code{vcov}}{Estimate of variance-covariance matrix.}
#'   \item{\code{sigma}}{Standard error.}
#' }
#' @export
lm_eigen <- function(y, X) {
  if(!is.matrix(X) || (nrow(X) != length(y))) {
    stop("y and X have incompatible dimensions.")
  }
  .lm_eigen(y = y, X = X)
}
