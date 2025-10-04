#!/bin/bash

# Build Docker images for TAKERMAN AI Server

name=$1

if [ -z "$name" ]; then
    echo "Usage: $0 <image-name>"
    echo "Example: $0 jupyter"
    exit 1
fi

echo "Building TAKERMAN AI Server Docker image: $name"

# Build and tag the image
docker build -f Dockerfile.$name -t takerman.$name:latest .
docker tag takerman.$name:latest ghcr.io/takermanltd/takerman.$name:latest

# Login and push (if GitHub token is provided)
if [ -n "$GITHUB_TOKEN" ]; then
    echo "Logging into GitHub Container Registry..."
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u takerman --password-stdin
    docker push ghcr.io/takermanltd/takerman.$name:latest
    echo "✅ Image pushed to ghcr.io/takermanltd/takerman.$name:latest"
else
    echo "⚠️  GITHUB_TOKEN not provided - skipping push to registry"
    echo "   Set it with: export GITHUB_TOKEN=your_github_pat"
    echo "   Local image available as: takerman.$name:latest"
fi
