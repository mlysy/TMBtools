# RcppTMBTest: Example of Co-Existing Rcpp and TMB Source Code

*Martin Lysy*

*March 17, 2019*

---

### Description

 A test package containing C++ source code linked with [Rcpp](http://www.rcpp.org/) along with a few [TMB](https://github.com/kaskr/adcomp/wiki) models.  Tested to pass `R CMD check --as-cran` on Unix/OSX and Windows environments.
 
### Installation
 
Install the R [devtools](https://CRAN.R-project.org/package=devtools) package and run:
```r
devtools::install_github("mlysy/RcppTMBTest")
testthat::test_package("RcppTMBTest", reporter = "progress") # optionally run the unit tests
```

### Usage

You may wish to check that the package indeed passes CRAN checks on your local platform by running the following from an R session in any of the package subdirectories:
```r
devtools::check()
```
Or without devtools, from the Terminal/Command Prompt running in the directory containing the RcppTMBTest folder:
```bash
R CMD build RcppTMBTest
R CMD check --as-cran RcppTMBTest_1.0.tar.gz
```

### Notes

- TMB and Rcpp code in an R package cannot be merged into a single shared library, as documented [here](https://github.com/kaskr/adcomp/issues/247).  Therefore, the approach taken here is to have a separate folder `src/TMB` containing the TMB source code, with separate compiling instructions provided in `Makevars[.win]`.
- RcppTMBTest shows how to include multiple TMB models using two different methods:
    1.  Put each TMB model in its own `.cpp` file.  However, this can considerably increase the size of the package binary, as discussed [here](https://github.com/kaskr/adcomp/issues/233).  
	2.  Put each TMB model in its own header file, and combine these into a single TMB `.cpp` file, in which the `objective_function<Type>::operator()` has switches indicating which model to use.  Please see file `TMB/TMBMain.cpp` for an example of this.  Based on the discussion [here](https://github.com/kaskr/adcomp/issues/247#issuecomment-473825191), there should be no performance hit for using this method instead of separate `.cpp` files as in method 1.  The approach employed here (based heavily on the solution [here](https://github.com/kaskr/adcomp/issues/233#issuecomment-306032192)) is something like:
	    ```c
		// --- ModelA.hpp ---

        #undef TMB_OBJECTIVE_PTR
		#define TMB_OBJECTIVE_PTR obj
		template <class Type>
		Type ModelA(objective_function<Type>* obj) {
		  // define your model exactly as you would for a single cpp file
		}
		#undef TMB_OBJECTIVE_PTR
		#define TMB_OBJECTIVE_PTR this
		
		// same for ModelB.hpp, ModelC.hpp etc.
		
		// --- TMBMain.cpp ---
		
		#include <TMB.hpp>
		#include "ModelA.hpp"
		#include "ModelB.hpp"
		
		template<class Type>
		Type objective_function<Type>::operator() () {
		  DATA_STRING(model_name);
		  if(model_name == "ModelA") {
		    return ModelA(this);
		  } else if(model_name == "ModelB") {
		    return ModelB(this);
		  } else {
		    error("Unknown model_name.");
		  }
		  return 0;
		}
		```
		The unit tests in `test/testthat/test-aMb.R` indicate that on the R side its a simple as e.g.:
		```r
		# create TMB object for ModelA
	    Adata <- list(model_name = "ModelA", # specify model
		              ...) # whatever you would do for a single cpp file ModelA.cpp
	    Apars <- list(...) # whatever you would do for a single cpp file
	    Aobj <- TMB::MakeADFun(data = Adata, parameters = Apars,
                               DLL = "TMBMain")
		```
		That is, the tests indicate that TMB does not get confused between `DATA_*` and `PARAMETER*` arguments across `.hpp` model files, i.e., `DATA_VECTOR(x)` in `ModelA` and `PARAMETER_MATRIX(x)` in `ModelB`, nor does `TMB::MakeADFun` expect you to specify the names of all arguments to all models at once, etc.
		
		**Conclusion:** It seems that there is very little advantage to using Method 1 for multiple TMB models, but a considerable advantage to using Method 2.  Pending the failure of tests I have not run yet (see [below](#todo)), it seems that Method 2 is uniformly preferable to Method 1.
- The Rcpp shared library automatically gets the name of the package (in this case, RcppTMBTest), whereas the TMB shared library(ies) should be called something else.  I have found that in order to avoid the CRAN check note [`Foreign function call to a different package`](https://stackoverflow.com/questions/24150185/foreign-function-calls-to-a-different-package-note), in the `NAMESPACE` file, it is necessary that *the `useDynLib` call to RcppTMBTest come first*, i.e., before any of those to the TMB shared libraries.  This package uses [roxygen2](https://CRAN.R-project.org/package=roxygen2/vignettes/roxygen2.html) to create the documentation, and provides an example of how to do this regardless of alphabetical order in the file `R/RcppTMBTest-package.R`.

### TODO

- Run tests with `OpenMP` enabled.
- Check other `DATA_*` and `PARAMETER*` macros, although it seems unlikely now that there will be an issue with these.  Perhaps focus on `DATA_UPDATE`?
