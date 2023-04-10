#!/bin/bash

set -xeuo pipefail
cd $(dirname "$(readlink -f "$0")")

if [[ -x ./cobalt/cobalt ]];
then
    echo Cobalt is already restored.
    exit 0
fi

version=v0.18.3

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
mkdir -p cobalt
tar xf cobalt.tar.gz -C cobalt

exit 0
