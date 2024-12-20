#!/bin/bash

IMAGE_NAME="docker-audio-copy"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)/../"

# Build Docker image
docker build -t $IMAGE_NAME:latest $PROJECT_DIR
