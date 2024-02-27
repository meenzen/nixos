#!/usr/bin/env bash

set -eo pipefail

git add .
nix flake update
sudo nixos-rebuild switch --upgrade --flake .#nixos-vm
