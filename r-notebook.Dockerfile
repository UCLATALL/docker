ARG BASE_CONTAINER=jupyter/datascience-notebook:python-3.9.13
FROM ${BASE_CONTAINER}

LABEL org.opencontainers.image.licenses="AGPL-3.0-or-later" \
      org.opencontainers.image.source="https://github.com/UCLATALL/docker" \
      org.opencontainers.image.vendor="UCLATALL" \
      org.opencontainers.image.authors="Adam Blake <adamblake@g.ucla.edu>"

# ensure errors get piped
# https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# custom install scripts
COPY scripts /install_scripts

# setup R
ENV TZ=Etc/UTC
ENV CRAN=https://packagemanager.rstudio.com/cran/__linux__/focal/latest
ENV LANG=en_US.UTF-8
ENV R_HOME=/opt/conda/lib/R
ENV R_LIBS_USER=/opt/conda/lib/R/library
ENV _R_SHLIB_STRIP_=true

## add a default CRAN mirror
RUN echo "options(repos = c(CRAN = '${CRAN}'), download.file.method = 'libcurl')" >>"${R_HOME}/etc/Rprofile.site"

## set HTTPUserAgent for RSPM (https://docs.rstudio.com/rspm/admin/serving-binaries/#binaries-r-configuration-linux)
RUN echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' >> "${R_HOME}/etc/Rprofile.site"

## install system dependencies for different R packages
RUN /install_scripts/setup_av.sh
RUN /install_scripts/setup_geospatial.sh
RUN /install_scripts/setup_tidyverse.sh

# install packages
## user-requested Python packages
RUN mamba install --quiet --yes \
    av \
    ffmpeg \
    numpy \
    pandas \
    plotly \
    r-av \
    statsmodels \
    && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

## dependencies for R install scripts: install_cran.r and install_github.r
RUN Rscript -e "options(warn = 2); install.packages(c('remotes', 'docopt'))"

## user-requested R packages
RUN /install_scripts/install_cran.r \
    car \
    ClustOfVar \
    cluster \
    dagitty \
    jtools \
    gganimate \
    ggdag \
    ggformula \
    ggpubr \
    gifski \
    lme4 \
    mapdata \
    mapproj \
    maps \
    minqa \
    mosaic \
    OCSdata \
    plotly \
    profvis \
    psych \
    simstudy \
    statmod \
    tidymodels \
    tidyverse

### note the -u flag to make sure this package and its dependencies are always updated
ARG COURSEKATA_REF=0.3.3
RUN /install_scripts/install_github.r -u "UCLATALL/coursekata-r@${COURSEKATA_REF}"
RUN Rscript -e "options(warn = 2, Ncpus = max(1L, parallel::detectCores())); coursekata::coursekata_install()"

### needed to run test code in the book as Solution Correctness Tests
RUN /install_scripts/install_github.r "datacamp/testwhat"

## run python from R
RUN /install_scripts/install_cran.r \
    RcppTOML \
    here \
    reticulate

# add default kernel and interface for Deepnote and Jupyter
ENV DEFAULT_KERNEL_NAME=ir
ENV DOCKER_STACKS_JUPYTER_CMD=notebook

# ensure lower permissions and ensure R kernel is the default
USER ${NB_UID}
WORKDIR ${HOME}