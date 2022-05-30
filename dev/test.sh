#!/bin/bash

set -e

$(dirname $0)/build.sh
docker run --rm -p 8888:8888 uclatall/r-notebook:local-test