#' Create a \pkg{TMB} package.
#'
#' @param path Absolute or relative path to where the package is to be created.  If the path exists, it is used. If it does not exist, it is created, provided that the parent path exists.
#' @param tmb_files Optional character vector of \pkg{TMB} header files to include in the package.  See \strong{Details}.
#' @param fields,open Same function as corresponding arguments in \code{usethis::create_package}.
#' @param example_code Adds example \pkg{TMB} files to the package (see \strong{Examples}).
#'
#' @return Nothing; called for its side effect.
#'
#' @details Calls \code{usethis::create_package} followed by \code{\link{use_tmb}} and \code{\link{export_models}}, which add the \pkg{TMB} infrastructure and initialize the provided \pkg{TMB} model list, respectively.  Please see documentation for these functions as to how exactly a \pkg{TMB}-enabled package should be set up.
#'
#' @example examples/tmb_create_package.R
#' @seealso \code{\link{use_tmb}} for adding \pkg{TMB} infrastructure to an existing package,\code{\link{export_models}} for adding \pkg{TMB} model files after the package is created.
#' @export
tmb_create_package <- function(path,
                               tmb_files = character(),
                               fields = NULL,
                               open = interactive(),
                               example_code = FALSE) {
  ## if(!is.character(tmb_files)) {
  ##   stop("'tmb_files' must be a character vector.")
  ## }
  # create package skeleton
  ui_info("Creating package skeleton...")
  currwd <- getwd()
  # in case package creation fails, don't change directories
  on.exit(setwd(currwd))
  # check if path is inside another project
  check_pkg_nested(path)
  # run create_package silently, so need to disable invocations of ui prompts
  if(dir.exists(path)) {
    ui_stop("{ui_path(path)} already exists.")
  }
  dir.create(path, recursive = TRUE)
  # add license
  if(is.null(fields) || is.null(fields$License)) {
    fields$License <- "GPL (>= 2)"
  }
  use_silent({
    ## create_package(path = path, fields = fields)
    pkgdir <- usethis::create_package(path = path,
                                      fields = fields,
                                      rstudio = FALSE,
                                      ## check_name = check_name,
                                      open = FALSE)
  })
  setwd(pkgdir)
  file.remove("NAMESPACE")
  if(example_code) {
    tmb_files <- c(tmb_files,
                   system.file("templates", "NormalNLL.hpp",
                               package = "TMBtools"),
                   system.file("templates", "GammaNLL.hpp",
                               package = "TMBtools"))
  }
  if(length(tmb_files) > 0) {
    if(anyDuplicated(basename(tmb_files))) {
      ui_stop("TMB filenames {ui_path(basename(tmb_files))} must be unique.")
    }
    # copy TMB files
    use_silent(usethis::proj_set(pkgdir))
    ui_info("Copying TMB files...")
    use_directory("src")
    use_directory("src/TMB")
    setwd(currwd)
    sapply(tmb_files, use_file, "src", "TMB")
    setwd(pkgdir)
    if(!open) use_silent(usethis::proj_set(NULL))
  }
  use_tmb()
  export_models()
  if(open) {
    usethis::proj_set(pkgdir)
    on.exit(setwd(pkgdir))
  }
}


## create_package <- function(path, fields) {
##   path <- fs::path_expand(path)
##   name <- fs::path_file(path)
##   fs::dir_create(path)
##   old_project <- usethis::proj_set(path, force = TRUE)
##   on.exit(usethis::proj_set(old_project), add = TRUE)
##   use_directory("R")
##   usethis::use_description(fields)
##   invisible(usethis::proj_get())
## }

## {
##     path <- user_path_prep(path)
##     check_path_is_directory(path_dir(path))
##     name <- path_file(path)
##     if (check_name) {
##         check_package_name(name)
##     }
##     check_not_nested(path_dir(path), name)
##     create_directory(path)
##     old_project <- proj_set(path, force = TRUE)
##     on.exit(proj_set(old_project), add = TRUE)
##     use_directory("R")
##     use_description(fields, check_name = check_name)
##     use_namespace()
##     if (rstudio) {
##         use_rstudio()
##     }
##     if (open) {
##         if (proj_activate(path)) {
##             on.exit()
##         }
##     }
##     invisible(proj_get())
## }
