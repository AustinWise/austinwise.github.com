#!/bin/bash
set -e
docker build -t austinweb .
docker run -it --rm -v `pwd`:/app austinweb "/app/update_deps.sh"
