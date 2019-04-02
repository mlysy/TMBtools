#ifndef NormNLL_hpp
#define NormNLL_hpp 1

// negative log-likelihood of the normal distribution
#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR obj
template<class Type>
Type NormNLL(objective_function<Type>* obj) {
  DATA_VECTOR(x); // data vector
  PARAMETER(mu); // mean parameter
  PARAMETER(sigma); // standard deviation parameter
  return -sum(dnorm(x,mu,sigma,true)); // negative log likelihood
}
#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR this

#endif
