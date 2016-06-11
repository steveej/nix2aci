#!/usr/bin/env bash
set -eux

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

nix-build
actool validate "$ROOT_DIR/result/"*.aci
