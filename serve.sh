#!/bin/bash
set -xeuo pipefail
./build.sh
./cobalt serve -c input/_cobalt.yml -d _site --host 0.0.0.0
