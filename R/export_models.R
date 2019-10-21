#' Create C++ code to export \pkg{TMB} models from package.
#'
#' @param pkg Character string: any subdirectory of the package source code.
#' @return Invisible; called for its side effects.
#'
#' @details \pkg{TMB} models should be saved as C++ header files of the form \code{src/TMB/*.hpp}, and written almost exactly as with usual \pkg{TMB} \code{*.cpp} models.  So for example, \code{src/TMB/ModelA.hpp} would be written as:
#' \preformatted{
#' // __DO NOT__ '#include <TMB.hpp>' as file is not include-guarded
#'
#' #undef TMB_OBJECTIVE_PTR
#' #define TMB_OBJECTIVE_PTR obj
#'
#' // name of function _must_ match file name (ModelA)
#' template<class Type>
#' Type ModelA(objective_function<Type>* obj) {
#'
#'   // _exactly_ the same code as for usual 'ModelA.cpp'
#'
#' }
#'
#' #undef TMB_OBJECTIVE_PTR
#' #define TMB_OBJECTIVE_PTR this
#' }
#' The function \code{export_models} creates a file \code{src/TMB/pkgname_TMBExports.cpp} containing a single \pkg{TMB} model object which dispatches the appropriate \code{ModelA.hpp}, \code{ModelB.hpp}, etc. using \code{if/else} statements.  At the \R level, the correct model is invoked from \code{TMB::MakeADFun} exactly as for a single \pkg{TMB} model, except the \code{data} list argument gets an additional element \code{model} specifying the name of the model, e.g., \code{model = "ModelA"}.
#'
#' \code{export_models} assumes that each file of the form \code{src/TMB/*.hpp} contains \emph{exactly one} \pkg{TMB} model.  In order for these to \code{#include} additional \code{.hpp} files, these additional files must be placed either in a subfolder of \code{src/TMB}, or in (a subfolder of) \code{inst/include}.  The advantage of the latter approach is that the additional files are available to other \R packages via \code{LinkingTo: pkgname} is the other package's \code{DESCRIPTION}.  If the latter approach is used, the \code{TMB} compiler must be notified of the additional include directory.  This is done by setting the \code{TMB_FLAGS} in \code{src/Makevars[.win]} to
#' \preformatted{
#' TMB_FLAGS = -I"../../inst/include"
#' }
#' Other flags specific to the \pkg{TMB} compiler can be set here as well, as can the usual \code{CXX_FLAGS}, etc. for other source code in \code{src}, which is compiled independently of that in \pkg{src/TMB}.
#'
#' @seealso \code{\link{use_tmb}}
#' @export
export_models <- function(pkg = ".") {
  currwd <- getwd()
  on.exit(setwd(currwd))
  usethis::local_project(pkg, quiet = TRUE)
  root <- usethis::proj_get() #.package_root(pkg)
  setwd(root)
  pkg_name <- get_package(root)
  tmb_path <- file.path("src", "TMB")
  tmb_main <- file.path(tmb_path, paste0(pkg_name, "_TMBExports.cpp"))
  # if not TMB-generated don't overwrite
  check_tmb_generated(tmb_main)
  # determine template values:
  # include files
  model_files <- list.files(path = tmb_path, pattern = "[.]hpp$",
                            ignore.case = TRUE)
  incl_lines <- paste0('#include "', model_files, '"', collapse = '\n')
  # if statements
  # model names: no path and no extension
  model_names <- sub(pattern = "(.*?)\\..*$",
                     replacement = "\\1", basename(model_files))
  if(length(model_names) > 0) {
    if_lines <- paste0('if(model == "', model_names, '") {\n',
                       '    return ', model_names, '(this);\n',
                       '  }', collapse = ' else ')
    if_lines <- paste0(if_lines, ' else {\n',
                      '    error("Unknown model.");\n  }')
  } else {
    if_lines <- '  error("Unknown model.");'
  }
  use_template(template = "TMBExports.cpp", package = "TMBtools",
               data = list(pkg = pkg_name,
                           includes = incl_lines,
                           switches = if_lines),
               save_as = tmb_main)
}

## ' @param model_files Character vector of header files relative to \code{src/TMB} listing the \pkg{TMB} models to export.  If missing defaults to all \code{hpp} files in \code{src/TMB}.  \strong{Note:} Always use forward slash "/" to separate directories, even on Windows.


## # path to TMB templates
## .template_file <- function(...) {
##   system.file("templates", ..., package = "TMBtools")
## }

## # find package root: basically copied from devtools
## .package_root <- function(path = ".") {
##   if(!is.character(path) || length(path) != 1) {
##     stop("'path' must be a string.", call. = FALSE)
##   }
##   path <- sub("/*$", "", normalizePath(path, mustWork = FALSE))
##   if(!file.exists(path)) {
##     stop("Can't find '", path, "'.", call. = FALSE)
##   }
##   if(!file.info(path)$isdir) {
##     stop("'", path, "' is not a directory.", call. = FALSE)
##   }
##   while(!file.exists(file.path(path, "DESCRIPTION"))) {
##     path <- dirname(path)
##     if(identical(path, dirname(path))) {
##       stop("Could not find package root.", call. = FALSE)
##     }
##   }
##   path
## }

