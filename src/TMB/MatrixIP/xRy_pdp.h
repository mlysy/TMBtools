#ifndef xRy_pdp_h
#define xRy_pdp_h 1

#include "MatrixIP.h"

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
