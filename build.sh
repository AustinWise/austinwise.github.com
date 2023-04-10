#!/bin/bash

set -xeuo pipefail
cd $(dirname "$(readlink -f "$0")")

bash ./restore.sh

./cobalt/cobalt build -c input/_cobalt.yml -d _site
