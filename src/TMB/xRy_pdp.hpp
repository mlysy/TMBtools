#ifndef xRy_pdp_hpp
#define xRy_pdp_hpp 1

#include "TMBtools/MatrixIP.hpp"

#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR obj
template <class Type>
Type xRy_pdp(objective_function<Type>* obj) {
  PARAMETER_VECTOR(x);
  PARAMETER_VECTOR(y);
  DATA_MATRIX(R);
  return MatrixIP(x, y, R);
}
#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR this

#endif
