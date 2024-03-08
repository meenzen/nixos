#!/usr/bin/env bash

set -eo pipefail

git add .
nix flake update --verbose
git add .
sudo nixos-rebuild switch --upgrade --verbose --flake .#the-machine
