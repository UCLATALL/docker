#!/bin/bash

set -e

docker build . \
  -f r-notebook.Dockerfile \
  -t uclatall/r-notebook:local-test \
  --no-cache

docker build . \
  -f deepnote.Dockerfile \
  -t uclatall/deepnote:local-test \
  --no-cache