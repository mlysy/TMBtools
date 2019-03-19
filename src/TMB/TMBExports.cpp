/// @file TMBExports.cpp

#define TMB_LIB_INIT R_init_TMBExports
#include <TMB.hpp>
#include "MatrixIP/xRy_dpd.h"
#include "MatrixIP/Rxz_dpd.h"
#include "MatrixIP/xRz_pdd.h"
#include "MatrixIP/xRy_pdp.h"
#include "MatrixIP/ySx_pdp.h"

/// Various matrix-weighted innner products.
template<class Type>
Type objective_function<Type>::operator() () {
  DATA_STRING(model_name);
  if(model_name == "xRy_dpd") {
    return xRy_dpd(this);
  } else if(model_name == "Rxz_dpd") {
    return Rxz_dpd(this);
  } else if(model_name == "xRz_pdd") {
    return xRz_pdd(this);
  } else if(model_name == "xRy_pdp") {
    return xRy_pdp(this);
  } else if(model_name == "ySx_pdp") {
    return ySx_pdp(this);
  } else {
    error("Unknown model_type.");
  }
  return 0;
}
