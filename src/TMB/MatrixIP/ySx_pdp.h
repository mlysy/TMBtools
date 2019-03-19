#ifndef ySx_pdp_h
#define ySx_pdp_h 1

#include "MatrixIP.h"

#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR obj
template <class Type>
Type ySx_pdp(objective_function<Type>* obj) {
  PARAMETER_VECTOR(y);
  PARAMETER_VECTOR(x);
  DATA_MATRIX(S);
  return MatrixIP(y, x, S);
}
#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR this

#endif
