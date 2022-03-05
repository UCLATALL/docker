#!/usr/bin/env Rscript

options(warn = 2)

"Install packages from GitHub.

Usage:
  install_github.r [-u] [PACKAGES ...]
  install_github.r (-h | --help)
  install_github.r --version

Options:
  -u --upgrade  Allow packages to upgrade.
  -h --help     Show this screen.

" -> doc

opt <- docopt::docopt(doc)

# set the repositories to pull from
default_cran <- "https://packagemanager.rstudio.com/cran/latest"
repos <- Sys.getenv("CRAN", unset = default_cran)

# separate the repo from the commit ref (if given)
to_install <- lapply(opt$PACKAGES, function(pkg) {
  parts <- strsplit(pkg, "@", fixed = TRUE)[[1]]
  if (length(parts) > 2) {
    stop(paste(
      paste0('Invalid package name "', pkg, '".'),
      'Use format [org]/[repo]@[ref] where "@[ref]" is optional.'
    ))
  }

  output <- list(name = parts[[1]])
  if (length(parts) > 1) {
    output$ref <- parts[[2]]
  }

  return(output)
})

# install away
invisible(lapply(to_install, function(pkg_info) {
  remotes::install_github(
    pkg_info$name,
    pkg_info$ref,
    repos = repos,
    Ncpus = max(1L, parallel::detectCores()),
    upgrade = opt$ upgrade
  )
}))