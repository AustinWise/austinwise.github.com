#!/bin/bash
set -xeuo pipefail
cd $(dirname "$(readlink -f "$0")")
./build.sh
./cobalt/cobalt serve -c input/_cobalt.yml -d _site --host 0.0.0.0
