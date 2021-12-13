FROM uclatall/base:latest

# Install R kernel and set as default
RUN sudo Rscript -e "install.packages(c('IRkernel'), repos='https://cran.rstudio.com/')"
RUN sudo Rscript -e "IRkernel::installspec()"
ENV DEFAULT_KERNEL_NAME=ir