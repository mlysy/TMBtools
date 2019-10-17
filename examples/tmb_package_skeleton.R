\dontrun{
# create package with example code
tmb_package_skeleton(name = "TMBTestPackage", example_code = TRUE)
#'
# for the following steps must have devtools package installed
setwd("TMBTestPackage")
# need to create shared library before running devtools::document()
pkgbuild::compile_dll()
devtools::document()
# essentially equivalent to R CMD check --as-cran
devtools::check()
}
