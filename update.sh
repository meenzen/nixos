#!/usr/bin/env bash

set -eo pipefail

sudo nixos-rebuild switch --flake .
