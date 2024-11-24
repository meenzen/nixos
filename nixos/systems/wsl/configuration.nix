{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../modules
  ];

  system.stateVersion = "23.11";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  wsl = {
    enable = true;
    defaultUser = systemConfig.user.username;
  };

  meenzen.home-manager.homeModule = "${inputs.self}/home-manager/cli.nix";
}
