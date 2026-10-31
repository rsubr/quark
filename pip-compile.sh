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
  TTY_FLAGS='-i'
  [ -t 0 ] && TTY_FLAGS='-ti'
  docker run ${TTY_FLAGS} --rm -v ${PWD}:${BASEDIR} python:3.15-trixie ${BASEDIR}/pip-compile.sh
  exit 0
fi

set -eoux pipefail


pip install pip-tools
pip-compile --upgrade --generate-hashes -v \
    -o ${BASEDIR}/requirements.txt ${BASEDIR}/requirements.in
