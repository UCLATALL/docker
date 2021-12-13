FROM uclatall/base:latest

ENV NB_USER=rstudio

RUN /uclatall_scripts/install_binder.sh
CMD jupyter notebook --ip 0.0.0.0

USER ${NB_USER}
WORKDIR /home/${NB_USER}
