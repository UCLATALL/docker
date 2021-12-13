#!/bin/bash
set -e

## force install of last working version of rstudio, if necessary
# RSTUDIO_VERSION=1.3.959 /rocker_scripts/install_rstudio.sh

## NOTE: this runs as user NB_USER!
PYTHON_VENV_PATH=${PYTHON_VENV_PATH:-/opt/venv/reticulate}
DEFAULT_USER=${DEFAULT_USER:-rstudio}
NB_USER=${NB_USER:-${DEFAULT_USER}}
NB_UID=${NB_UID:-1000}
WORKDIR=${WORKDIR:-/home/${NB_USER}}
usermod -l ${NB_USER} ${DEFAULT_USER}
# Create a venv dir owned by unprivileged user & set up notebook in it
# This allows non-root to install python libraries if required
mkdir -p ${PYTHON_VENV_PATH} && chown -R ${NB_USER} ${PYTHON_VENV_PATH}

# And set ENV for R! It doesn't read from the environment...
echo "PATH=${PATH}" >> ${R_HOME}/etc/Renviron.site
echo "export PATH=${PATH}" >> ${WORKDIR}/.profile

## This gets run as user
su ${NB_USER}
cd ${WORKDIR}
python3 -m venv ${PYTHON_VENV_PATH}
pip3 install --no-cache-dir jupyter-rsession-proxy

# Install libzmq for pbdZMQ (needed to install kernel)
apt-get update
apt-get install -y gnupg
echo "deb http://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-stable/Debian_9.0/ ./" >> /etc/apt/sources.list
wget https://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-stable/Debian_9.0/Release.key -O- | sudo apt-key add
apt-get install -y libzmq3-dev

# Install kernel
NCPUS=${NCPUS:--1}
install2.r --error --skipinstalled -n $NCPUS \
  pbdZMQ \
  IRkernel

R --quiet -e "IRkernel::installspec(prefix = '${PYTHON_VENV_PATH}')"
rm -rf /tmp/downloaded_packages