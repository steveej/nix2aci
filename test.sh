#!/usr/bin/env bash
set -eux

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

test-build() {
  nix-build -A "$1"
  actool validate "$ROOT_DIR/result/"*.aci
}

test-build busybox
test-build busyboxStatic
test-build busyboxThin
