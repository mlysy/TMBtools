#--- helper functions ----------------------------------------------------------

# formats useDynLib
use_dynlib <- function(dynlibs) {
  out <- paste0("useDynLib(", dynlibs, ")")
  out <- paste0(out, collapse = "; ")
  out
}

# adds a file to the package
use_file <- function(fl, ...) {
  if(!file.exists(fl)) ui_stop("File {ui_path(fl)} doesn't exist.")
  file.copy(from = fl,
            to = file.path(usethis::proj_get(), ..., basename(fl)))
}

# silently executes usethis commands
use_silent <- function(code) {
  if(!missing(code)) {
    withr::with_options(list(usethis.quiet = TRUE), code = code)
  }
}

# needs init if src has no files (except directories)
check_needs_init <- function(root) {
  src_files <- dir(path = file.path(root, "src"), full.names = TRUE)
  length(src_files) == 0 || all(dir.exists(src_files))
}

# identical to usethis::use_template, except:
# 1. package defaults to TMBtools
# 2. never overwrites if file exists
use_template <- function(template, save_as = template,
                         data = list(), ignore = FALSE,
                         open = FALSE, package = "TMBtools") {
  usethis::local_project()
  if(file.exists(file.path(usethis::proj_get(), save_as))) {
    ui_line("File {ui_path(save_as)} already exists.  Not overwritten.")
  } else {
    usethis::use_template(template = template,
                          save_as = save_as,
                          data = data, ignore = ignore,
                          open = open, package = package)
  }
}
