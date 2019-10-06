#' Create a skeleton for a new package depending on \pkg{TMB}.
#'
#' @param name Character string: the package name and directory name for the package.  See \code{utils::package.skeleton}.
#' @param list Character vector naming the \R objects to put in the package.  See \code{utils::package.skeleton}.
#' @param environment An environment where objects are looked for.  See \code{utils::package.skeleton}.
#' @param path Path to put the package directory in.
#' @param force If \code{FALSE} will not overwrite an existing directory.
#' @param code_files A character vector with the paths to \R code files to build the package around.  \code{utils::package.skeleton}.
#' @param cpp_files  A character vector with the paths to C++ source files to add to the package, or a logical.  If a non-empty character vector or \code{TRUE}, the package will use \pkg{Rcpp} features.
#' @param tmb_files A charactor vector with the paths to \pkg{TMB} source files to add to the package.
#' @param example_code If \code{TRUE}, example \pkg{TMB} source code is added to the package.
#'
#' @details The created package is compatible with \pkg{roxygen2}-style documentation.  That is, a package passing \code{R CMD check --as-cran} is created out-of-the-box upon running the code in \strong{Examples}.
#' @examples
#' \dontrun{
#' # create package with example code
#' tmb_package_skeleton(name = "TMBTestPackage", example_code = TRUE)
#'
#' # for the following steps must have devtools package installed
#' setwd("TMBTestPackage")
#' # need to create shared library before running devtools::document()
#' pkgbuild::compile_dll()
#' devtools::document()
#' # essentially equivalent to R CMD check --as-cran
#' devtools::check()
#' }
#' @export
tmb_package_skeleton <- function(name = "anRpackage",
                                 list = character(),
                                 environment = .GlobalEnv,
                                 path = ".", force = FALSE,
                                 code_files = character(),
                                 cpp_files = character(),
                                 tmb_files = character(),
                                 example_code = TRUE) {
  # argument checks
  if(is.logical(cpp_files)) {
    use_Rcpp <- cpp_files
    cpp_files <- character()
  } else {
    if(!is.character(cpp_files)) {
      stop("'cpp_files' must be a character vector.")
    } else {
      use_Rcpp <- TRUE
    }
  }
  if(!is.character(tmb_files))
    stop("'tmb_files' must be a character vector.")

  # create package skeleton
  # need dummy object in case no R objects are given
  env <- parent.frame(1)
  dummy_name <- basename(tempfile("package_skeleton_dummy_object_"))
  assign(dummy_name, function() {}, envir = env)
  # make sure dummy object gets deleted
  on.exit(rm(list = dummy_name, envir = env))
  call <- match.call()
  call[[1]] <- quote(utils::package.skeleton)
  call <- call[ c(1L, which(names(call) %in% names(formals(utils::package.skeleton)))) ]
  tryCatch(suppressMessages(eval(call, envir = env)), error = function(e) {
    stop("error while calling `package.skeleton` : ", conditionMessage(e))
  })
  root <- file.path(path, name)
  # remove dummy object from package
  unlink(file.path(root, "R", paste0(dummy_name, ".R")))
  # remove R/TMBExports-internal.R if accidentally created
  if(file.exists(x <- file.path(root, "R", paste0(name, "-internal.R")))) {
    unlink(x)
  }
  # delete contents of man/ so package installs without errors
  file.remove(list.files(file.path(root, "man"), full.names = TRUE))
  message("Created basic package skeleton...")

  # update DESCRIPTION file
  desc <- file.path(root, "DESCRIPTION")
  if(file.exists(desc)) {
    imports <- "TMB"
    if(use_Rcpp) {
      imports <- c(imports,
                   sprintf("Rcpp (>= %s)",
                           utils::packageDescription("Rcpp")[["Version"]]))
    }
    linkingto <- c("TMB", if(use_Rcpp) "Rcpp")
    x <- read.dcf(desc)
    x[, "License"] <- "GPL (>= 2)"
    x <- cbind(x, "Imports" = paste0(imports, collapse = ", "))
    x <- cbind(x, "LinkingTo" = paste0(linkingto, collapse = ", "))
    x <- cbind(x, "Encoding" = "UTF-8")
    # the following avoids NOTE from R CMD check --as-cran
    x[, "Description"] <- paste0(x[, "Description"], ".")
    message("Updated 'DESCRIPTION'...")
    write.dcf(x, file = desc)
  }

  # update NAMESPACE file
  nspc <- file.path(root, "NAMESPACE")
  x <- readLines(.template_file("NAMESPACE"))
  if(getRversion() >= "3.4.0") {
    usedl <- sprintf("useDynLib(%s, .registration=TRUE)", name)
  } else {
    usedl <- sprintf("useDynLib(%s)", name)
  }
  usedl <- c(usedl, sprintf("useDynLib(%s_TMBExports)", name))
  x <- c(x, paste0(usedl, collapse = "; "), "importFrom(Rcpp, evalCpp)")
  cat(x, sep = "\n", file = nspc)
  message("Updated 'NAMESPACE'...")

  # create corresponding *-package.R file
  x <- readLines(.template_file("package.R"))
  if(use_Rcpp) {
    x <- sub("@@use_Rcpp@@", "@importFrom Rcpp evalCpp", x)
  } else {
    x <- x[!grepl("@@use_Rcpp@@", x)]
  }
  x <- sub("@@usedl@@", paste0(usedl, collapse = "; "), x)
  cat(x, sep = "\n", file = file.path(root, "R", paste0(name, "-package.R")))
  message("Added 'R/", name,
          "-package.R' with 'roxygen2'-style 'NAMESPACE' directives...")

  # add files to src
  if(!dir.exists(x <- file.path(root, "src", "TMB"))) {
    dir.create(x, recursive = TRUE)
  }
  if(length(cpp_files) > 0) {
    file.copy(from = cpp_files, to = file.path(root, "src"), recursive = TRUE)
    message("Added 'cpp_files' to 'src'...")
  } else {
    # include a dummy file, otherwise useDynLib(name) will fail.
    init_file <- file.path(root, "src", "init_dummy_file.cpp")
    x <- readLines(.template_file("init_dummy_file.cpp"))
    x <- gsub("@@pkg@@", name, x)
    x <- sub("@@usedl_pkg@@", usedl[1], x)
    cat(x, sep = "\n", file = init_file)
  }

  # add files to src/TMB
  if(length(tmb_files) > 0) {
    file.copy(from = tmb_files, to = file.path(root, "src", "TMB"),
              recursive = TRUE)
    message("Added 'tmb_files' to 'src/TMB'...")
  }
  file.copy(from = .template_file(c("Makevars", "Makevars.win")),
            to = file.path(root, "src"), recursive = TRUE)
  file.copy(from = .template_file("compile.R"),
            to = file.path(root, "src", "TMB"), recursive = TRUE)
  message("Added TMB system files 'src/Makevars[.win]' and 'src/TMB/compile.R'...")

  # example code
  if(example_code) {
    file.copy(from = .template_file(c("NormNLL.hpp", "GammaNLL.hpp")),
              to = file.path(root, "src", "TMB"), recursive = TRUE)
    x <- readLines(.template_file("tmb_examples.R"))
    x <- gsub("@@pkg@@", name, x)
    cat(x, sep = "\n", file = file.path(root, "R", "tmb_examples.R"))
    message("Added TMB example code...")
  }

  # create name_TMBExports.cpp
  export_models(pkg = root)
  message("Exported TMB models via 'src/TMB/", name, "_TMBExports.cpp'...")
  # create Read_and_delete_me file
  x <- readLines(.template_file("Read_and_delete_me"))
  if(length(cpp_files) == 0) {
    x <- gsub("@@use_Rcpp@@", "", x)
  } else {
    x <- x[-(grep("@@use_Rcpp@@", x)+0:2)]
  }
  x <- gsub("@@usedl_pkg@@", usedl[1], x)
  x <- gsub("@@usedl_tmb@@", usedl[2], x)
  cat(x, sep = "\n", file = file.path(root, "Read-and-delete-me"))
  message("Done.  Additional TMB-specific notes in 'Read-and-delete-me'.")
  invisible(NULL)
}

# path to TMB templates
.template_file <- function(...) {
  system.file("templates", ..., package = "RcppTMBTest")
}
