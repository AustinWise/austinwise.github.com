#!/bin/bash
set -e
docker build -t austinweb .
docker run -it --rm -p 4000:4000 -p 4001:4001 -v `pwd`:/app austinweb /app/serve.sh
