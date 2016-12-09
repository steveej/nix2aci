#!/usr/bin/env bash
set -eux

env
APPC_VERSION=${APPC_VERSION:-0.7.4}
APPC_DIR=~/appc-v${APPC_VERSION}

wget https://github.com/appc/spec/releases/download/v${APPC_VERSION}/appc-v${APPC_VERSION}.tar.gz -qO- | tar xvz -C ~/
mv ${APPC_DIR}/actool ~/
rm -Rfv ${APPC_DIR}

chmod +x ~/actool
