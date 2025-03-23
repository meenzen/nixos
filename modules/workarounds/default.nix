{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./insecure-packages.nix
    ./libraries.nix
    ./nix-consistency.nix
    ./shebang.nix
    ./unpatched-binaries.nix
  ];
}
