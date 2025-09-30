#!/bin/bash

name=$1
docker build -f Dockerfile.$name -t takerman.$name:latest .
docker tag takerman.$name:latest ghcr.io/takermanltd/takerman.$name:latest
echo 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 | docker login ghcr.io -u takerman --password-stdin
docker push ghcr.io/takermanltd/takerman.$name:latest
