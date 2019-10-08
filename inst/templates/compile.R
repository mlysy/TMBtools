tmb_flags <- commandArgs(trailingOnly = TRUE)
if(length(tmb_flags) == 0) tmb_flags <- ""

if(length(Sys.glob("*.cpp")) > 0) {
  # compile tmb models
  invisible(sapply(Sys.glob("*.cpp"),
                   TMB::compile, PKG_CXXFLAGS = tmb_flags,
                   safebounds = FALSE, safeunload = FALSE))
  # copy dynlibs to src
  invisible(file.copy(from = Sys.glob(paste0("*", .Platform$dynlib.ext)),
                      to = "..", overwrite = TRUE))
}

# cleanup done in ../Makevars[.win]
