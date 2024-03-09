#!/usr/bin/env bash

set -eo pipefail

nix --extra-experimental-features repl-flake repl ".#nixosConfigurations"
