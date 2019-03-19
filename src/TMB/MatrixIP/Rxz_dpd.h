#ifndef Rxz_dpd_h
#define Rxz_dpd_h 1

#include "MatrixIP.h"

#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR obj
template <class Type>
Type Rxz_dpd(objective_function<Type>* obj) {
  DATA_VECTOR(R);
  DATA_VECTOR(z);
  PARAMETER_MATRIX(x);
  return MatrixIP(R, z, x);
}
#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR this

#endif
