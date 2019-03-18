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
- Currently RcppTMBTest shows how to have two TMB models in separate `.cpp` files.  However, this can considerably increase the size of the package binary, as discussed [here](https://github.com/kaskr/adcomp/issues/233).  The solution proposed there is to have a single TMB `objective_function<Type>::operator()` with switches indicating which model to use.
- The Rcpp shared library automatically gets the name of the package (in this case, RcppTMBTest), whereas the TMB shared library(ies) should be called something else.  I have found that in order to avoid the CRAN check note [`Foreign function call to a different package`](https://stackoverflow.com/questions/24150185/foreign-function-calls-to-a-different-package-note), in the `NAMESPACE` file, it is necessary that *the `useDynLib` call to RcppTMBTest come first*, i.e., before any of those to the TMB shared libraries.  This package uses [roxygen2](https://CRAN.R-project.org/package=roxygen2/vignettes/roxygen2.html) to create the documentation, and provides an example of how to do this regardless of alphabetical order in the file `R/RcppTMBTest-package.R`.
