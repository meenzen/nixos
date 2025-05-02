{
  config,
  inputs,
  lib,
  pkgs,
  systemConfig,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix

    ./minecraft.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "lithium";
  networking.domain = "localdomain";
  networking.hostId = "cd913f25";
  system.stateVersion = "24.11";

  meenzen.server.enable = true;
  meenzen.minecraft.enable = true;
}
