#' Create a skeleton for a new package depending on \pkg{TMB}.
#'
#' @param name Character string: the package name and directory name for the package.
#' @param path Path to put the package directory in.
#' @param use_rcpp  If \code{TRUE}, the package is set up to use \pkg{Rcpp} features.  If \code{FALSE}, it is assumed that the package will contain no additional C++ source code aside from what is used with \pkg{TMB}.  See \strong{Details}.
#' @param tmp_init If \code{TRUE}, adds a placeholder C++ file to the package, to be deleted once actual C++ code is added.  Has no effect if \code{use_rcpp = FALSE}.  See \strong{Details}.
#' @param example_code If \code{TRUE}, example \pkg{TMB} source code is added to the package.
#'
#' @details The generated package skeleton contains a folder \code{src/TMB} which is where the \pkg{TMB} model \code{.cpp} files are expected to live.  Different \pkg{TMB} models are combined into a single automatically generated source file with zero performance loss but considerable memory saving.  See \code{\link{export_models}} for details.
#'
#' The package is compatible with, but not dependent on \pkg{roxygen2}-style documentation.  That is, a package passing \code{R CMD check --as-cran} is created out-of-the-box with \code{example_code = TRUE}, or upon creating the documentation with \code{roxygen2::roxygenize}.  See \strong{Examples} for details.
#'
#' For packages containing C++ source code not associated with \pkg{TMB} models, setting \code{use_rcpp = TRUE} enables \pkg{Rcpp} interfacing features, as well as adding \code{useDynLib(MyPackage)} to the package \code{NAMESPACE}.  This last step is required regardless of whether one uses \pkg{Rcpp} or not, but must come \emph{before} the \code{NAMESPACE} command \code{useDynLib(MyPackage_TMBExports)} required to import the C++ functions associated with the \pkg{TMB} models.  For \pkg{roxygen2}-style documentation, the order can be guaranteed by adding the following tag somewhere in the package documentation:
#' \preformatted{
#' #' @rawNamespace useDynLib(MyPackage, .registration = TRUE); useDynLib(MyPackage_TMBExports)
#' }
#' This is automatically added by \code{tmb_package_skeleton} to \code{R/MyPackage-package.R}.
#'
#' Note however that \code{useDynLib(Mypackage)} requires the package to register at least one C++ function, i.e., \code{R CMD INSTALL} will not work if \code{src} is empty.  Therefore, \code{tmb_package_skeleton} creates a placeholder file \code{src/init.cpp} to register a minimal function (\code{int register_init(void) {return 0;}}) through the \code{Rcpp} mechanism, which can be safely deleted once real \code{src} code is added to the package.
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
                                 path = ".",
                                 use_rcpp = FALSE,
                                 example_code = TRUE) {
  # create package skeleton
  root <- file.path(path, name)
  ## currwd <- getwd()
  ## on.exit(setwd(currwd))
  suppressMessages(usethis::create_package(path = root, open = FALSE))
  message("Created basic package skeleton...")

  # update DESCRIPTION file
  .update_descr(root, use_rcpp)

  # construct useDynLib directive
  usedl <- .get_usedl(name)

  # update NAMESPACE file
  .update_nspc(root, use_rcpp)

  # create corresponding *-package.R file
  file.copy(from = .template_file("package.R"),
            to = file.path(root, "R", paste0(name, "-package.R")))
  .update_roxy(root, use_rcpp)

  # add files to src
  if(!dir.exists(x <- file.path(root, "src", "TMB"))) {
    dir.create(x, recursive = TRUE)
  }
  if(length(cpp_files) > 0) {
    file.copy(from = cpp_files, to = file.path(root, "src"), recursive = TRUE)
    message("Added 'cpp_files' to 'src'...")
  } else {
    # include a dummy file, otherwise useDynLib(name) will fail.
    init_file <- file.path(root, "src", "init.cpp")
    x <- readLines(.template_file("init.cpp"))
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

# update description
# TODO: use descr package
.update_descr <- function(root, use_rcpp) {
  desc <- file.path(root, "DESCRIPTION")
  if(file.exists(desc)) {
    imports <- "TMB"
    if(use_rcpp) {
      imports <- c(imports,
                   sprintf("Rcpp (>= %s)",
                           utils::packageDescription("Rcpp")[["Version"]]))
    }
    linkingto <- c("TMB", if(use_rcpp) "Rcpp")
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
}

.get_usedl <- function(name) {
  if(getRversion() >= "3.4.0") {
    usedl <- sprintf("useDynLib(%s, .registration=TRUE)", name)
  } else {
    usedl <- sprintf("useDynLib(%s)", name)
  }
  c(usedl, sprintf("useDynLib(%s_TMBExports)", name))
}

.update_nspc <- function(root, usedl, use_rcpp) {
  name <- basename(root)
  usedl <- paste0(usedl, collapse = "; ")
  nspc <- file.path(root, "NAMESPACE")
  x <- readLines(nspc)
  # try to replace useDynlib if it exists
  idl <- grepl(paste0("^[[:space:]]*useDynLib[[:space:]]*\\([[:space:]]*",
                      name,
                      "[[:space:]]\\)"), x)
  if(any(idl)) {
    x[idl] <- usedl
  } else {
    x <- c(x, usedl)
  }
  # add rcpp functionality
  if(use_rcpp) {
    # find Rcpp line
    ircpp <- grepl(paste0("^importFrom[[:space:]]*",
                          "\\([[:space:]]*Rcpp[[:space:]]*,[[:space:]]",
                          "(evalCpp|sourceCpp)[[:space:]]*\\)"),
                   x = x)
    if(any(ircpp)) {
      x[ircpp] <- "importFrom(Rcpp,evalCpp)"
    } else {
      x <- c(x, "importFrom(Rcpp,evalCpp)")
    }
  }
  cat(x, sep = "\n", file = nspc)
  message("Updated 'NAMESPACE'...")
}

# TODO: can't use template substitution...
.update_roxy <- function(root, use_rcpp) {
  x <- readLines(.template_file("package.R"))
  if(use_rcpp) {
    x <- sub("@@use_Rcpp@@", "@importFrom Rcpp evalCpp", x)
  } else {
    x <- x[!grepl("@@use_Rcpp@@", x)]
  }
  x <- sub("@@usedl@@", paste0(usedl, collapse = "; "), x)
  cat(x, sep = "\n", file = file.path(root, "R", paste0(name, "-package.R")))
  message("Added 'R/", name,
          "-package.R' with 'roxygen2'-style 'NAMESPACE' directives...")
}
