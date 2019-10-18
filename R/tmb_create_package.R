#' Create a \pkg{TMB} package.
#'
#' @param path Absolute or relative path to where the package is to be created.  If the path exists, it is used. If it does not exist, it is created, provided that the parent path exists.
#' @param tmb_files Optional character vector of \pkg{TMB} header files to include in the package.  See \strong{Details}.
#' @param fields,rstudio,check_name,open Same function as corresponding arguments in \code{usethis::create_package}.
#'
#' @return Nothing; called for its side effect.
#'
#' @details Calls \code{usethis::create_package} followed by \code{\link{use_tmb}} and \code{\link{export_models}}, which add the \pkg{TMB} infrastructure and initialize the provided \pkg{TMB} model list, respectively.  Please see documentation for these functions as to how exactly a \pkg{TMB}-enabled package should be set up.
#'
#' @seealso \code{\link{use_tmb}} for adding \pkg{TMB} infrastructure to an existing package,\code{\link{export_models}} for adding \pkg{TMB} model files after the package is created.
#' @export
tmb_create_package <- function(path,
                               tmb_files = character(),
                               fields = NULL,
                               rstudio = rstudioapi::isAvailable(),
                               check_name = TRUE,
                               open = interactive()) {
  ## if(!is.character(tmb_files)) {
  ##   stop("'tmb_files' must be a character vector.")
  ## }
  # create package skeleton
  ui_info("Creating package skeleton...")
  currwd <- getwd()
  # in case package creation fails, don't change directories
  on.exit(setwd(currwd))
  # run create_package silently, so need to disable invocations of ui prompts
  if(dir.exists(path)) {
    ui_stop("{ui_path(path)} already exists.")
  }
  dir.create(path, recursive = TRUE)
  use_silent({
    # open = FALSE avoids an error
    pkgdir <- usethis::create_package(path = path, fields = fields,
                                      rstudio = rstudio,
                                      ## check_name = check_name,
                                      open = FALSE)
  })
  setwd(pkgdir)
  file.remove("NAMESPACE")
  if(length(tmb_files) > 0) {
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
