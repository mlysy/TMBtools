#define TMB_LIB_INIT R_init_GammaNLL
#include <TMB.hpp>

// negative log-likelihood of the gamma distribution
template<class Type>
Type objective_function<Type>::operator() () {
  DATA_VECTOR(x); // data vector
  PARAMETER(alpha); // shape parameter
  PARAMETER(beta); // scale parameter
  return -sum(dgamma(x, alpha, beta, true));
}

