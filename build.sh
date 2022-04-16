#!/bin/bash

set -euo pipefail
set -x

cd $(dirname "$(readlink -f "$0")")

version=v0.16.5

os=$(uname -s | tr A-Z a-z) 
vendor=unknown
case $os in
    darwin)
        arch=x86_64
        vendor=apple
        ;;
    linux)
        os=linux-gnu
        arch=$(uname -m)
        ;;
    *)
        echo unknown OS: $os
        exit 1
        ;;
esac

curl -o cobalt.tar.gz -SsfL https://github.com/cobalt-org/cobalt.rs/releases/download/${version}/cobalt-${version}-${arch}-${vendor}-${os}.tar.gz
# shasum -a 256 -c checksum-${os}-${arch}.txt
if ! shasum -a 256 -c checksum-${os}-${arch}.txt ; then
    echo actual SHA256:
    shasum -a 256 cobalt.tar.gz
    exit 1
fi
tar xf cobalt.tar.gz

./cobalt build -c input/_cobalt.yml -d _site
