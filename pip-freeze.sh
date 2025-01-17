#!/bin/bash

# Start an ephemeral docker container, and install primary dependencies.
# Then run pip freeze to generate the full requirements.txt so dependabot
# can identify all the dependencies.

if [ ! -f /.dockerenv ]; then
  if ! command -v docker &> /dev/null; then
    echo "Unable to find docker, exiting."
    exit 1
  fi
  docker run -ti --rm -v $PWD:/app python:3.12-bookworm /app/pip-freeze.sh
  exit 0
fi

set -eoux pipefail

pip install -r /app/requirements.in

pip freeze > /app/requirements.txt

