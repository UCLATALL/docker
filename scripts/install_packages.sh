#!/bin/bash

## build ARGs
NCPUS=${NCPUS:--1}

## set -e

install2.r --error --skipinstalled -n $NCPUS \
  tidymodels \
  simstudy \
  psych \
  lme4 \
  car \
  OCSdata \
  remotes \
  ggpubr \
  repr 

rm -rf /tmp/downloaded_packages
