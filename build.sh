#!/bin/bash

set -euo pipefail
set -x

curl -o cobalt -SsL https://github.com/AustinWise/cobalt.rs/releases/download/austin-v1/cobalt

sha256sum -c cobalt_checksum.txt

./cobalt build
