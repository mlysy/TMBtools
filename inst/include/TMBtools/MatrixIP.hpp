/// @file MatrixIP.hpp

#ifndef MatrixIP_hpp
#define MatrixIP_hpp 1

/// Matrix-weighted inner product.
///
/// For vectors `x` and `y` of length `n`, and `n x n` matrix `M`, calculates `x.transpose() * M * y`.
/// @param[in] x First vector.
/// @param[in] y Second vector.
/// @param[in] M Weight matrix.
/// @return `M`-weighted inner product between `x` and `y` (scalar).
template <class Type>
Type MatrixIP(const vector<Type>& x, const vector<Type>& y,
	      const matrix<Type>& M) {
  return (x.array() * (M * y).array()).sum();
}

#endif
