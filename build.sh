#!/usr/bin/env bash

nix-build . \
  --arg pkgs 'import /home/steveej/src/github/NixOS/nixpkgs {}' \
  "$@"
