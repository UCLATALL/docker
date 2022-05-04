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
    'r-clustofvar' \
    'r-cluster' \
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
    jtools \
    gganimate \
    ggdag \
    ggformula \
    ggpubr \
    gifski \
    mapdata \
    mapproj \
    mosaic \
    OCSdata \
    simstudy \
    tidymodels

## install R packages on GitHub
RUN /install_scripts/install_github.r "datacamp/testwhat"

ARG COURSEKATA_REF=0.3.3
RUN /install_scripts/install_github.r -u "UCLATALL/coursekata-r@${COURSEKATA_REF}"
RUN Rscript -e "options(warn = 2, repos = '${CRAN}', Ncpus = max(1L, parallel::detectCores())); coursekata::coursekata_install()"

## remove temp files added during R package installs
RUN Rscript -e 'sapply(list.files(path = tempdir(), pattern = "^(repos|libloc).*\\\\.rds$", full.names = TRUE), unlink)'

# lower permissions and ensure R kernel is the default
USER ${NB_UID}
ENV DEFAULT_KERNEL_NAME=ir