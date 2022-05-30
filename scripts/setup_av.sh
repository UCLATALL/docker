#!/bin/bash

# the setup_* files are derived from https://github.com/rocker-org/rocker-versioned2
# they were modified 2020-05-29 to only include the system dependencies and move the
# R installs out

set -e

# always set this for scripts but don't declare as ENV
export DEBIAN_FRONTEND=noninteractive

## build ARGs
NCPUS=${NCPUS:--1}

# a function to install apt packages only if they are not installed
function apt_install() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            apt-get update
        fi
        apt-get install -y --no-install-recommends "$@"
    fi
}

apt_install \
    cargo \
    libavfilter-dev

# Clean up
rm -rf /var/lib/apt/lists/*