#!/bin/bash
set -e
docker build -t austinweb .
docker run -it --rm -p 3000:3000 -v `pwd`:/app austinweb /app/serve.sh
