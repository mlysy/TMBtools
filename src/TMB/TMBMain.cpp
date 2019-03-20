/// @file TMBMain.cpp

#define TMB_LIB_INIT R_init_TMBMain
#include <TMB.hpp>
#include "MatrixIP/xRy_dpd.hpp"
#include "MatrixIP/Rxz_dpd.hpp"
#include "MatrixIP/xRz_pdd.hpp"
#include "MatrixIP/xRy_pdp.hpp"
#include "MatrixIP/ySx_pdp.hpp"

/// Various matrix-weighted innner products.
///
/// Each of the models returns a matrix-weighted inner product of the form `a.transpose() * M * b`, but using different TMB macros to specify the variable types and names.  For example, model `xRy_dpd` is essentially implemented as
/// @code{.cpp}
/// template <class Type>
/// Type objective_function<Type>::operator() () {
///   DATA_VECTOR(x);
///   PARAMETER_MATRIX(R);
///   DATA_VECTOR(y);
///   return x.transpose() * R * y;
/// }
/// @endcode
/// That is, the first three letters of the model define the variable names for `a`, `M`, and `b`, and the last three letters define the variable type for each of these (`d` for data and `p` for parameter).
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
