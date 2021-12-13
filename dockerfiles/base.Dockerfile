FROM rocker/tidyverse:4.1.2

# Install Jupyter and R
RUN /rocker_scripts/install_python.sh
RUN pip3 install --no-cache-dir jupyter

# Copy scripts
COPY scripts /uclatall_scripts
RUN chmod +x /uclatall_scripts/*.sh

# Install R packages 
RUN /uclatall_scripts/install_packages.sh
RUN sudo Rscript /uclatall_scripts/install_github.r

# Fix plot sizes
RUN echo 'options(repr.plot.width = 6, repr.plot.height = 4)' > ~/.Rprofile
