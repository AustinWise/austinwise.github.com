#!/bin/bash
set -e
docker run -it --rm -p 1024:1024 -v `pwd`:/app netlify/build:noble /app/serve.sh --host 0.0.0.0
