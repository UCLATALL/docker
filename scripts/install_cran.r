#!/usr/bin/env Rscript

options(warn = 2)

"Install packages from CRAN.

Usage:
  install_cran.r [-u] PACKAGES...
  install_cran.r (-h | --help)
  install_cran.r --version

Options:
  -u --upgrade  Allow packages to upgrade.
  -h --help     Show this screen.

" -> doc

opt <- docopt::docopt(doc)

# set the repositories to pull from
default_cran <- "https://packagemanager.rstudio.com/cran/latest"
repos <- Sys.getenv("CRAN", unset = default_cran)

if (opt$upgrade) {
  pkgs <- opt$PACKAGES
} else {
  # only install packages and dependencies that are not installed already
  deps <- remotes::package_deps(opt$PACKAGES)
  pkgs <- deps[which(is.na(deps$installed)), "package"]
  installed <- opt$PACKAGES[!(opt$PACKAGES %in% pkgs)]

  if (length(installed) > 0) {
    cat(
      "\n",
      "Skipping already installed packages:\n",
      paste(installed, sep = ", "), "\n"
    )
  }
}

if (length(pkgs) < 1) {
  cat("No packages to install.\n\n")
} else {
  cat("Installing packages\n\n")
  install.packages(
    pkgs,
    Ncpus = max(1L, parallel::detectCores()),
    repos = repos
  )
}