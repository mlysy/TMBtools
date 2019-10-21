# TMBtools: Tools for Developing R Packages Interfacing with TMB

*Martin Lysy*

---

## Overview
 
[**TMB**](https://github.com/kaskr/adcomp/wiki) is an R package providing a convenient interface to the [**CppAD**](https://coin-or.github.io/CppAD/doc/cppad.htm) C++ library for [automatic differentiation](https://en.wikipedia.org/wiki/Automatic_differentiation).  More specifically for the purpose of statistical inference, **TMB** provides an automatic and extremely efficient implementation of [Laplace's method](https://en.wikipedia.org/wiki/Laplace%27s_method) to approximately integrate out the latent variables of a model *p(x | theta) = \int p(x, z | theta) dz*  via numerical optimization.  **TMB** is extensively [documented](http://kaskr.github.io/adcomp/_book/Introduction.html), and numerous [examples](http://kaskr.github.io/adcomp/_book/Examples.html#example-overview) indicate that it can be used to effectively handle tens to thousands of latent variables in a model.

**TMB** was designed for users to compile and save standalone statistical models.  Distributing one or more **TMB** models as part of an R package requires a nontrivial compilation process (`Makevars[.win]`), and some amount of boilerplate code.  Thus, the purpose of **TMBtools** is to provide helper functions for the development of R packages which contain **TMB** source code, promoting effective **TMB** coding practices as discussed [below](#tmb-coding-practices).  The main package functions are:

- `tmb_create_package()`, which creates an R package infrastructure with the proper **TMB** compile instructions.

- `use_tmb()`, which adds **TMB** functionality to an existing package.

- `export_models()`, which updates the package's **TMB** compile instructions when new models are added.

**Note to Developers:** While **TMBtools** depends on a number of packages to facilitate its work, none of these dependencies are passed on to your package, except **TMB** itself.
 
## Installation
 
Install the R package [**devtools**](https://CRAN.R-project.org/package=devtools) package and run:
```r
devtools::install_github("mlysy/TMBtools")
testthat::test_package("TMBtools", reporter = "progress") # optionally run the unit tests
```

## Quickstart

As per the standard **TMB** [tutorial](https://github.com/kaskr/adcomp/wiki/Tutorial), a typical standalone **TMB** model defined in `ModelA.cpp` would look something like this:
```cpp
/// @file ModelA.cpp

#include <TMB.hpp>

template<class Type>
Type objective_function<Type>::operator() () {
  // model definition
}
```
And would be compiled and called from R as follows:
```r
TMB::compile("ModelA.cpp") # compile model
dynload(TMB::dynlib("ModelA")) # link to R session

# instantiate model object
modA <- TMB::MakeADFun(data = data_list,
                       parameters = param_list,
                       DLL = "ModelA")

modA$fn(other_param_list) # call its negative loglikelihood
modA$gr(other_param_list) # negative loglikelihood gradient
```
To create an R package containing `ModelA`, we must convert `ModelA.cpp` to a header file `ModelA.hpp` and make a few minor modifications:
```cpp
/// @file ModelA.hpp

// **DON'T** #include <TMB.hpp> as it is not include-guarded

#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR obj

// name of function below **MUST** match filename
// (here it's ModelA)
template <class Type>
Type ModelA(objective_function<Type>* obj) {
  // exactly same body as 
  // `objective_function<Type>::operator()`
  // in `ModelA.cpp`
}

#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PRT this
```
For `ModelA.hpp`, `ModelB.hpp`, etc. similarly defined and in the current directory (`base::getwd()`), the R package containg them is created with:
```r
TMBtools::tmb_create_package(path = "path/to/MyTMBPackage",
                             tmb_files = c("ModelA.hpp", "ModelB.hpp"))
```
Once **MyTMBPackage** is installed, models can be accessed with:
```r
library(MyTMBPackage) # package needs to be loaded

# instantiate ModelA object
modA <- TMB::MakeADFun(data = c(model = "ModelA", # which model to use
                                data_list),
                       parameters = param_list,
                       DLL = "MyTMBPackage_TMBExports") # package's DLL

modA$fn(other_param_list) # same usage as before

# instantiate ModelB object
modB <- TMB::MakeADFun(data = c(model = "ModelB", # use ModelB
                                data_list_B),
                       parameters = param_list_B,
                       DLL = "MyTMBPackage_TMBExports")

modB$fn(other_param_list_B)
```

For more usage details, e.g., how to add new models to an existing package, please see the package [vignette](http://htmlpreview.github.io/?https://github.com/mlysy/TMBtools/master/doc/TMBtools.html).

## Unit Tests

As a sanity check, you may create a fully operational example package, i.e., with unit tests passing `R CMD --as-cran check`, with the sample code below.  To run this code you will need to install the packages **devtools**, [**usethis**](https://CRAN.R-project.org/package=usethis), and [**numDeriv**](https://CRAN.R-project.org/package=numDeriv).
```r
TMBtools::create_tmb_package(path = "path/to/TMBExampleTest",
                             example_code = TRUE,
							 fields = list(
                             `Authors@R` = 'person("Your", "Name",
                                                   email = "valid@email.com",
                                                   role = c("aut", "cre"))'))

# R wrapper functions to TMB models
usethis::use_template(template = "norm_ADFun.R", package = "TMBtools",
                      save_as = file.path("R", "norm_ADFun.R"),
                      data = list(pkg = "TMBTestPackage"))
usethis::use_template(template = "gamma_ADFun.R", package = "TMBtools",
                      save_as = file.path("R", "gamma_ADFun.R"),
                      data = list(pkg = "TMBTestPackage"))

# testthat tests
usethis::use_testthat()
usethis::use_package(package = "numDeriv", type = "Suggests")
usethis::use_template(template = "test-norm_ADFun.R", package = "TMBtools",
                      save_as = file.path("tests", "testthat",
                                          "test-norm_ADFun.R"))
usethis::use_template(template = "test-gamma_ADFun.R", package = "TMBtools",
                      save_as = file.path("tests", "testthat",
                                          "test-gamma_ADFun.R"))

# update NAMESPACE and package documentation
pkgbuild::compile_dll() # need to compile src first
devtools::document()

# essentially equivalent to R CMD --as-cran check
devtools::check() # on your local platform

# on winbuilder (CRAN's Windows)
# must provide a valid email address
devtools::check_win_devel() 
```

## **TMB** Coding Practices

- **TMB** and other source code (e.g., [**Rcpp**]((http://www.rcpp.org/))) in an R package cannot be merged into a single shared library, as documented [here](https://github.com/kaskr/adcomp/issues/247).  Therefore, the approach taken here is to have a separate shared object for the **TMB** models, for which the source code is stored in `src/TMB`, and for which separate compiling instructions provided in `Makevars[.win]`.

	Developers can include whatever **Rcpp** code they like in the package.  The `Makevars[.win]` is set up so that R's normal C++ compiling is completely unaffected by the **TMB** part, and can be modified to provide e.g., additional `CXX_FLAGS` in the usual way.
	
	However, standard practice is that the name of the main shared library (the one that gets created by **Rcpp**) is that of the package, so the **TMB** shared object needs to be called something else.  I have found that in order to avoid the CRAN check note [`Foreign function call to a different package`](https://stackoverflow.com/questions/24150185/foreign-function-calls-to-a-different-package-note), in the `NAMESPACE` file, it is necessary that *the `useDynLib` call to the main shared library come first*, i.e., before **TMB**'s.  `TMBtools::tmb_create_package()` sets things up properly assuming that [roxygen2](https://CRAN.R-project.org/package=roxygen2/vignettes/roxygen2.html) is used to create the documentation, and `TMBtools::use_tmb()` provides instructions to do so when modifying the `NAMESPACE` is out of its control.

- **TMBtools** follows the recommendations provided [here](https://github.com/kaskr/adcomp/issues/233) to combine all the package's **TMB** models into a single standalone-type meta-model `src/TMB/MyTMBPackage`. The appropriate model is selected at instantiation time using the `model` element of the `data` argument to `TMB::MakeADFun`.  This results in much smaller package sizes compared to multiple standalone models, and doesn't appear to impact  [performance](https://github.com/kaskr/adcomp/issues/247#issuecomment-473825191).

- The meta-model implementation in **TMBtools** (based heavily on the approach advocated [here](https://github.com/kaskr/adcomp/issues/233#issuecomment-306032192)) is something like:

	```c
	/// @file MyTMBPackage_TMBExports.cpp
		
	#include <TMB.hpp>
	#include "ModelA.hpp"
	#include "ModelB.hpp"
		
	template<class Type>
	Type objective_function<Type>::operator() () {
	  DATA_STRING(model);
	  if(model == "ModelA") {
		return ModelA(this);
	  } else if(model == "ModelB") {
		return ModelB(this);
	  } else {
		error("Unknown model.");
	  }
	  return 0;
    }
	```
	
	The unit tests in `TMBtools/test/testthat/test-aMb.R` indicate  indicate that TMB does not get confused between `DATA_*` and `PARAMETER*` arguments across `.hpp` model files -- for example, `DATA_VECTOR(x)` in `ModelA` and `PARAMETER_MATRIX(x)` in `ModelB` -- nor does `TMB::MakeADFun` expect you to provide all arguments to all models at once.  In other words, the main function bodies of `ModelA.hpp` and `ModelB.hpp` can be defined exactly you would for standalone files `ModelA.cpp` and `ModelB.cpp`.


## TODO

- [ ] Run tests with `openMP` enabled.
- [ ] Add unit tests for `tmb_create_package()`, `use_tmb()`, and `export_models()`.
- [ ] Add examples for `use_tmb()` and `export_models()`.
