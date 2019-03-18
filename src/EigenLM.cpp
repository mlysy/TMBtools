// [[Rcpp::depends(RcppEigen)]]
#include <RcppEigen.h>
using namespace Rcpp;
using namespace Eigen;

/// Calculate some basic regression output
// [[Rcpp::export(".lm_eigen")]]
Rcpp::List lm_eigen(Eigen::VectorXd y, Eigen::MatrixXd X) {
  // problem dimensions
  int p = X.cols();
  int n = X.rows();
  MatrixXd XtX = X.adjoint() * X;
  LLT<MatrixXd> llt(XtX);
  VectorXd bhat = llt.solve(X.adjoint() * y);
  VectorXd z = y - X * bhat;
  double sig2 = z.dot(z) / (n-p-0.0);
  MatrixXd vcov = sig2 * llt.solve(MatrixXd::Identity(p,p));
  return List::create(_["coef"] = bhat,
		      _["vcov"] = vcov,
		      _["sigma"] = sqrt(sig2));
}
