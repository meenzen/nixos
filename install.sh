#!/usr/bin/env bash

set -eo pipefail

git add .
sudo nixos-rebuild switch --upgrade --verbose --flake .
