#' Add \pkg{TMB} functionality to an existing package.
#'
#' @return Nothing; called for its side effects.
#' @details Adds the following to the package:
#'
#' \itemize{
#'   \item \code{src/TMB/compile.R}: runs the C++ compiler on \pkg{TMB} model files (see \code{\link{export_models}}).
#'   \item \code{src/Makevars[.win]}: ensures that \pkg{TMB} compilation does not affect that of other source files in \code{src}.
#'   \item \code{src/init_dummy_file.cpp}: needed to set \code{R_registerRoutines} if the package contains no other source code apart from what's in \code{src/TMB}.
#'   \item \code{Imports: TMB} and \code{LinkingTo: TMB} are added to the package's \code{DESCRIPTION}.
#'   \item An optional file \code{R/pkgname-package.R} with \pkg{roxygen2} \code{NAMESPACE} directives, if such a file does not exist.  Otherwise, prints instructions as to how the \code{NAMESPACE} must be modified (see below).
#' }
#'
#' Because of how \pkg{TMB} source files are compiled, at present the package must create two shared object (\code{.so}, \code{.dll}) files: \code{pkgname_TMBExports.so} for the \pkg{TMB} models, and \code{pkgname.so} for the usual package source code.  In the \code{NAMESPACE} file, it is imperative that the latter be `useDynLib`ed before the former.  The fail-safe \pkg{roxygen2} instruction for this is
#' \preformatted{
#' #' @rawNamespace useDynLib(pkgname, .registration = TRUE); useDynLib(pkgname_TMBExports)
#' }
#'
#' @seealso \code{\link{export_models}} for details on adding \pkg{TMB} model files after running \code{use_tmb}.
#' @export
use_tmb <- function() {
  root <- use_silent(usethis::proj_get())
  pkg <- get_package(root)
  # create TMB infrastructure
  ui_info("Adding TMB infrastructure...")
  use_directory("src")
  use_directory(file.path("src", "TMB"))
  add_init <- check_needs_init(root) # check if C++ init file is needed
  use_template(template = "compile.R", package = "TMBtools",
               save_as = file.path("src", "TMB", "compile.R"),
               data = list(pkg = pkg))
  use_template(template = "Makevars", package = "TMBtools",
               save_as = file.path("src", "Makevars"))
  use_template(template = "Makevars.win", package = "TMBtools",
               save_as = file.path("src", "Makevars.win"))
  # determine useDynLibs
  dynlibs <- paste0(pkg,
                    c(ifelse(getRversion() >= "3.4.0",
                             ", .registration=TRUE", ""),
                      "_TMBExports"))
  # update DESCRIPTION file
  ui_info("Updating DESCRIPTION...")
  use_silent({
    usethis::use_package(package = "TMB", type = "LinkingTo",
                         min_version = TRUE)
    usethis::use_package(package = "TMB", type = "Imports",
                         min_version = TRUE)
    usethis::use_package(package = "TMB", type = "LinkingTo",
                         min_version = NULL)
  })
  ## use_description(fields = list(License = "GPL (>= 2)"))
  if(add_init) {
    # add C++ init file
    ## ui_info("Adding C++ init file...")
    use_template(template = "init_dummy_file.cpp", package = "TMBtools",
                 save_as = file.path("src", "init_dummy_file.cpp"),
                 data = list(usedl = use_dynlib(dynlibs[1]), pkg = pkg))
  }
  # update Namespace directives
  add_tmb_namespace(root, pkg, dynlibs)
  if(add_init) {
    ui_todo("Delete {ui_path('src/init_dummy_file.cpp')} if C++ files are later added to {ui_path('src')}.")
  }
  invisible(NULL)
}

