#!/bin/bash

IMAGE_NAME="docker-audio-copy"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)/../"

# Run Docker image
docker run -it --rm \
  -v "${XAUTHORITY:-${HOME}/.Xauthority}:/home/ubuntu/.Xauthority:ro" \
  -v /run/user/$(id -u)/pulse:/run/user/1000/pulse \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v $PROJECT_DIR/.wine:/mnt/wine \
  -e DISPLAY \
  --entrypoint=bash \
  $IMAGE_NAME
