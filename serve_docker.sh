#!/bin/bash
set -e
docker run -it --rm -p 3000:3000 -v `pwd`:/app netlify/build:focal /app/serve.sh
