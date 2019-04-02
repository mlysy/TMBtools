#ifndef GammaNLL_hpp
#define GammaNLL_hpp 1

// negative log-likelihood of the gamma distribution
#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR obj
template<class Type>
Type GammaNLL(objective_function<Type>* obj) {
  DATA_VECTOR(x); // data vector
  PARAMETER(alpha); // shape parameter
  PARAMETER(beta); // scale parameter
  return -sum(dgamma(x, alpha, beta, true));
}
#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR this

#endif
