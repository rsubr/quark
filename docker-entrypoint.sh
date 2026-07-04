#!/bin/bash
set -e

if [ "${ENABLE_VIRTUAL_DISPLAY:-false}" = "true" ]; then
  echo "ENABLE_VIRTUAL_DISPLAY=true — starting virtual display on :99"
  Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp &

  for i in $(seq 1 25); do
    [ -e /tmp/.X11-unix/X99 ] && break
    sleep 0.2
  done

  export DISPLAY=:99
fi

exec "$@"
