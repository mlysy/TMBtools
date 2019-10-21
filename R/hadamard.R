#' Calculate the Hadamard product between two matrices.
#'
#' Commonly referred to as elementwise matrix multiplication.
#'
#' @param A First matrix.
#' @param B Second matrix of same dimensions as \code{A}.
#' @return Elementwise product between the two matices.
#' @export
hadamard <- function(A, B) {
  if(!is.matrix(A) || !is.matrix(B) || !identical(dim(A), dim(B))) {
    stop("A and B must be matrices of the same dimension.")
  }
  .hadamard(A = A, B = B)
}
