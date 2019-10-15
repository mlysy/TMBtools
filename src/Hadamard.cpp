#include <Rcpp.h>
using namespace Rcpp;

// Elementwise multiplication of two matrices, i.e., Hadamard product.
// [[Rcpp::export(".hadamard")]]
SEXP hadamard(NumericMatrix A, NumericMatrix B) {
  NumericVector C = A * B;
  C.attr("dim") = Dimension(A.nrow(), B.ncol());
  return C;
}
