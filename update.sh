#!/usr/bin/env bash

set -eo pipefail

git add .
nix flake update --verbose
sudo nixos-rebuild switch --upgrade --verbose --flake .#nixos-vm
