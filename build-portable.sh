#!/bin/bash

# Start an ephemeral docker container, and use miniconda to install a portable
# version of python and quark dependencies that can run from /opt/quark.

BASEDIR=/opt/quark
ARCH=$(arch)
PYTHON_VERSION=3.12
QUARK_VERSION=25.04

if [ ! -f /.dockerenv ]; then
  if ! command -v docker &> /dev/null; then
    echo "Unable to find docker, exiting."
    exit 1
  fi

  # Runs on docker host
  set -eoux pipefail

  # may need to sudo this to clean up the build directory
  rm -rf ./build/opt

  docker run -ti --rm \
    -v ${PWD}/build/opt:/opt -v ${PWD}:/app \
    python:3.12-bookworm /app/build-portable.sh

  # Create a tarball with portable quark
  tar czf ./build/quark-linux-${ARCH}-${QUARK_VERSION}.tar.gz -C ./build opt/quark

  exit 0
fi

# Runs inside docker
set -eoux pipefail

wget -q -O /tmp/Miniconda3-latest-Linux.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-${ARCH}.sh

# Install miniconda in /opt/minicoda
bash /tmp/Miniconda3-latest-Linux.sh -b -p /opt/miniconda

# Add conda environment details to bash
/opt/miniconda/bin/conda init bash && . ~/.bashrc

conda create --prefix $BASEDIR python=$PYTHON_VERSION --yes
conda activate $BASEDIR

pip install -r /app/requirements.txt

# Install playwright browsers and deps
export PLAYWRIGHT_BROWSERS_PATH=$BASEDIR/pw-browsers
playwright install --only-shell --with-deps chromium

# Save build details in $BASEDIR
cp /app/requirements.txt $BASEDIR/requirements.txt
echo $QUARK_VERSION > $BASEDIR/.version

# Set ENV
cat <<EOT > $BASEDIR/env.sh
# Source this in bash for quark ENV vars
# Eg. source /opt/quark/env.sh

BASEDIR=/opt/quark

export PW_BROWSERS_PATH=$BASEDIR/pw-browsers
export PATH=$BASEDIR/bin:$PATH

EOT
