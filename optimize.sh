#!/usr/bin/env bash

set -eo pipefail

LIGHT_BLUE='\033[1;34m'
NO_COLOR='\033[0m'

print () {
    echo -e "${LIGHT_BLUE}$1${NO_COLOR}"
}

print "=> Starting Storage Optimization"

print "==> Running \"nix-collect-garbage --delete-older-than 7d\""
nix-collect-garbage --delete-older-than 7d

print "==> Running \"nix-store --optimise\""
nix-store --optimise

print "=> Done!"
