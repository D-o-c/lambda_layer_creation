#!/bin/bash

# Set the directory where the Dockerfile and requirements.txt are located
DIRECTORY="$(pwd)"

# Change it as per your requirement
LAYER_NAME="lambda-layer"

# Remove old layers
rm -rf $DIRECTORY/layers/*

# Build the Docker image
docker build -t lambda-layer "$DIRECTORY" --platform linux/amd64

# Run the Docker container to create the layer
docker run --name lambda-layer-container -v "$DIRECTORY:/app" lambda-layer

# create layers directory, if not created.

mkdir -p layers

# Move the zip file in layers directory.

mv "$DIRECTORY/$LAYER_NAME.zip" "$DIRECTORY/layers/$LAYER_NAME.zip"

# Stop the conainer
docker stop lambda-layer-container

# Remove the running conainer
docker rm lambda-layer-container

# Cleanup: remove the Docker image
docker rmi --force lambda-layer