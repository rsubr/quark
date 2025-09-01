#!/bin/bash

# Start an ephemeral docker container, and install pip-tools. Then run
# pip-compile to generate the full requirements.txt so dependabot can identify
# all the dependencies.

BASEDIR='/app'

if [ ! -f /.dockerenv ]; then
  if ! command -v docker &> /dev/null; then
    echo "Unable to find docker, exiting."
    exit 1
  fi
  docker run -ti --rm -v ${PWD}:${BASEDIR} python:3.12-slim-bookworm ${BASEDIR}/pip-compile.sh
  exit 0
fi

set -eoux pipefail


pip install pip-tools
pip-compile --generate-hashes -v \
    -o ${BASEDIR}/requirements.txt ${BASEDIR}/requirements.in
