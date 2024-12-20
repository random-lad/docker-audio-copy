#!/bin/bash

IMAGE_NAME="docker-audio-copy"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)/../"

# Run Docker image
docker run -it --rm \
  --name docker-audio-copy \
  --device /dev/sr0 \
  -v $PROJECT_DIR/.wine:/mnt/wine \
  -v /run/user/$(id -u)/pulse:/run/user/1000/pulse \
  -v "${XAUTHORITY:-${HOME}/.Xauthority}:/home/ubuntu/.Xauthority:ro" \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -e DISPLAY \
  $IMAGE_NAME
