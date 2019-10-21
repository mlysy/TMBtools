\dontrun{
# create package with example code
tmb_create_package(path = "TMBTestPackage",
                   example_code = TRUE)

# the following steps will add R functions and tests
# for which the resulting package will pass R CMD check --as-cran
# need to have the following packages installed:
# - devtools
# - usethis
# - numDeriv
# run the following from within any of the TMBTestPackage subdfolders

# wrapper functions to TMB models
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

# create roxygen documentation
pkgbuild::compile_dll() # need to compile src first
devtools::document()

# essentially equivalent to R CMD check --as-cran
devtools::check()
}
