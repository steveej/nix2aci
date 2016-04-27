#!/usr/bin/env bash
set -eux

env
APPC_VERSION=${APPC_VERSION:-0.7.4}

wget https://github.com/appc/spec/releases/download/v${APPC_VERSION}/appc-v${APPC_VERSION}.tar.gz -qO- | tar xz -C ~/
