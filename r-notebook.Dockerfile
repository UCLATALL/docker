FROM jupyter/r-notebook:5cb007f03275
  
# install system dependencies
USER root
RUN apt-get update && \
    apt-get install -y \
    # these are used for installing some R packages
    gdal-bin \
    pkg-config

# install user packages
USER $NB_UID

RUN conda install --quiet --yes \
    r-statmod \
    r-minqa \
    gdal \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR

## setup custom R package installer
ENV _R_SHLIB_STRIP_=true
COPY /scripts/install_packages.r /install_scripts/install_packages.r
RUN Rscript -e "install.packages(c('remotes', 'docopt'), repos = 'https://cran.rstudio.com/')"

## install R packages on CRAN
### for some reason these have trouble in the big group
RUN /install_scripts/install_packages.r \
    terra \
    ggforce \
    profvis

RUN /install_scripts/install_packages.r \
    ### these fail if gdal-config is not installed
    leaflet \
    raster \
    Rcpp \
    ### coursekata dependencies that take longer to install, 
    ### included here because install_packages does a parallel install
    farver \
    icudt \
    stringr \
    vroom \
    ### user-requested packages
    car \
    digest \
    ggforce \
    ggformula \
    ggpubr \
    haven \
    lme4 \
    mapdata \
    mapproj \
    maps \
    mosaic \
    OCSdata \
    profvis \
    psych \
    remotes \
    repr \
    simstudy \
    tidymodels \
    tidyverse 

## install R packages on CRAN
RUN Rscript -e "remotes::install_github('datacamp/testwhat', repos = 'https://cran.rstudio.com/', Ncpus = max(1L, parallel::detectCores()))"

## the coursekata-r install is two-stage for a reason: 
## - the first stage installs all of the dependencies and caches them
## - don't change the code on the next two lines -- let it be cached
RUN Rscript -e "remotes::install_github('UCLATALL/coursekata-r', repos = 'https://cran.rstudio.com/', Ncpus = max(1L, parallel::detectCores()), upgrade = FALSE)"
RUN Rscript -e "options(repos = 'https://cran.rstudio.com/', Ncpus = max(1L, parallel::detectCores())); coursekata::coursekata_install()"
# ## - not all dependencies will update at the same time, and sometimes we will just add functions to the package without dependencies
# ## - the second stage will only update dependencies that are behind (i.e. it will use the cache where it can)
# ## - use the specific ref you want to install (use the commit hash or tag), this breaks the Docker cache just for this line
# ## - this second step is redundant if running with no Docker cache --- the whole point is for the first stage to cache
ARG COURSEKATA_REF=0.3.0
RUN Rscript -e "remotes::install_github('UCLATALL/coursekata-r', '${COURSEKATA_REF}', Ncpus = max(1L, parallel::detectCores()), repos = 'https://cran.rstudio.com/', upgrade = FALSE)"
RUN Rscript -e "options(repos = 'https://cran.rstudio.com/', Ncpus = max(1L, parallel::detectCores())); coursekata::coursekata_install()"

## remove temp files added during R package installs
RUN Rscript -e 'sapply(list.files(path = tempdir(), pattern = "^(repos|libloc).*\\\\.rds$", full.names = TRUE), unlink)'

# ensure R kernel is the default
ENV DEFAULT_KERNEL_NAME=ir
