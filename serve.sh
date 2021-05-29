#!/bin/bash
set -xeuo pipefail
./build.sh
./cobalt serve --host 0.0.0.0
