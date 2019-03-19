#ifndef xRy_dpd_h
#define xRy_dpd_h 1

#include "MatrixIP.h"

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
