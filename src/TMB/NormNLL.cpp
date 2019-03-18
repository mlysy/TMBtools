#define TMB_LIB_INIT R_init_NormNLL
#include <TMB.hpp>

// negative log-likelihood of the normal distribution
template<class Type>
Type objective_function<Type>::operator() () {
  DATA_VECTOR(x); // data vector
  PARAMETER(mu); // mean parameter
  PARAMETER(sigma); // standard deviation parameter
  return -sum(dnorm(x,mu,sigma,true)); // negative log likelihood
}
