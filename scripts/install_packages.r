#!/usr/bin/env Rscript

"Install packages from CRAN.

Usage:
  install_packages.r [PACKAGES ...]
  install_packages.r (-h | --help)
  install_packages.r --version

Options:
  -h --help     Show this screen.

" -> doc

library(docopt)
opt <- docopt(doc)

# get a list of all the packages to install, and their dependencies
# only install packages and dependencies that are not installed already
deps <- remotes::package_deps(opt$PACKAGES)
pkgs <- deps[which(is.na(deps$installed)), 1]

if (length(pkgs) < length(opt$PACKAGES)) {
  cat("\nSkipping already installed packages.\n")
}

if (length(pkgs) < 1) {
  cat("No packages to install.\n\n")
} else {
  cat("Installing packages\n\n")
  install.packages(
    pkgs,
    Ncpus = max(1L, parallel::detectCores()),
    repos = "https://cran.rstudio.com/",
    dependencies = FALSE
  )
}