#!/bin/bash

set -euo pipefail
set -x

cd $(dirname "$(readlink -f "$0")")

curl -o cobalt.tar.gz -SsL  https://github.com/cobalt-org/cobalt.rs/releases/download/v0.16.5/cobalt-v0.16.5-x86_64-unknown-linux-gnu.tar.gz
sha256sum -c cobalt_checksum.txt
tar xf cobalt.tar.gz

./cobalt build -c input/_cobalt.yml -d _site
