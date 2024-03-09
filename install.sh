#!/usr/bin/env bash

set -eo pipefail

LIGHT_BLUE='\033[1;34m'
NO_COLOR='\033[0m'

print () {
    echo -e "${LIGHT_BLUE}$1${NO_COLOR}"
}

print "=> Starrting Update"

print "==> Formatting Code"
alejandra .

print "==> Rebuilding NixOS"
git add .
sudo nixos-rebuild switch --upgrade --verbose --flake .
