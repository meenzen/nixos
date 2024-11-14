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
  disabledModules = [
    ../../modules/bootloader
    ../../modules/desktop
    ../../modules/firmware-update
    ../../modules/networking
    ../../modules/vpn
  ];

  wsl = {
    enable = true;
    defaultUser = systemConfig.user.username;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  custom.home-manager.homeModule = ../../../home-manager/cli.nix;
}
