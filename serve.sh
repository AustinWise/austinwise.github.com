#!/bin/bash

set -xeuo pipefail
cd $(dirname "$(readlink -f "$0")")

bash ./restore.sh

./cobalt/cobalt serve -c input/_cobalt.yml -d _site --host 0.0.0.0
