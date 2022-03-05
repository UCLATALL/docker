ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER

USER root

# R pre-requisites
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    cargo \
    fonts-dejavu \
    gcc \
    gfortran \
    libgit2-dev \
    pkg-config \
    unixodbc \
    unixodbc-dev \
    # needed for sf, terra
    gdal-bin proj-bin libgdal-dev libproj-dev \
    # needed to determine Ubuntu release for RSPM
    lsb-release \
    && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# R packages available on conda-forge 
# including IRKernel which gets installed globally.
RUN mamba install --quiet --yes \
    'ffmpeg' \
    'gdal' \
    'libgit2' \
    'r-base' \
    'r-irkernel' \
    'r-lme4' \
    'r-maps' \
    'r-minqa' \
    'r-profvis' \
    'r-psych' \
    'r-statmod' \
    'r-terra' \
    'r-tidyverse' \
    && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# setup custom R package installer for CRAN packages
ENV CRAN="https://packagemanager.rstudio.com/cran/__linux__/focal/latest" \
    _R_SHLIB_STRIP_=true
RUN Rscript -e "install.packages(c('remotes', 'docopt'), repos = '${CRAN}')"
COPY /scripts /install_scripts
RUN chmod +x /install_scripts/install_github.r

# install R packages on CRAN
RUN /install_scripts/install_cran.r \
    av \
    car \
    dagitty \
    gganimate \
    ggdag \
    ggformula \
    gifski \
    mapdata \
    mapproj \
    mosaic \
    OCSdata \
    simstudy

## install R packages on GitHub
RUN /install_scripts/install_github.r "datacamp/testwhat"

## the coursekata-r install is two-stage for a reason: 
## - the first stage installs all of the dependencies and caches them
## - don't change the code on the next two lines -- let it be cached
RUN /install_scripts/install_github.r "UCLATALL/coursekata-r"
RUN Rscript -e "options(warn = 2, repos = '${CRAN}', Ncpus = max(1L, parallel::detectCores())); coursekata::coursekata_install()"
## - not all dependencies will update at the same time, and sometimes we will just add functions to the package without dependencies
## - the second stage will only update dependencies that are behind (i.e. it will use the cache where it can)
## - use the specific ref you want to install (use the commit hash or tag), this breaks the Docker cache just for this line
## - this second step is redundant if running with no Docker cache --- the whole point is for the first stage to cache
ARG COURSEKATA_REF=0.3.1
RUN /install_scripts/install_github.r -u "UCLATALL/coursekata-r@${COURSEKATA_REF}"
RUN Rscript -e "options(warn = 2, repos = '${CRAN}', Ncpus = max(1L, parallel::detectCores())); coursekata::coursekata_install()"

## remove temp files added during R package installs
RUN Rscript -e 'sapply(list.files(path = tempdir(), pattern = "^(repos|libloc).*\\\\.rds$", full.names = TRUE), unlink)'

# lower permissions and ensure R kernel is the default
USER ${NB_UID}
ENV DEFAULT_KERNEL_NAME=ir