#!/usr/bin/env bash

set -eo pipefail

nix flake update
sudo nixos-rebuild switch --upgrade --flake .#nixos-vm
