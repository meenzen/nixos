{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./fontconfig.nix
    ./insecure-packages.nix
    ./jetbrains-toolbox.nix
    ./nix-consistency.nix
    ./shebang.nix
    ./unpatched-binaries.nix
  ];
}
