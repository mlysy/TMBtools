#ifndef xRy_dpd_hpp
#define xRy_dpd_hpp 1

#include "MatrixIP.hpp"

#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR obj
template <class Type>
Type xRy_dpd(objective_function<Type>* obj) {
  DATA_VECTOR(x);
  DATA_VECTOR(y);
  PARAMETER_MATRIX(R);
  return MatrixIP(x, y, R);
}
#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR this

#endif
