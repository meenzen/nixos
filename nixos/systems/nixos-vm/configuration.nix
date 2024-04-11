{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/workaround.nix
    ../../modules/locale.nix
    ../../modules/fonts.nix
    ../../modules/users.nix
    ../../modules/services.nix
    ../../modules/programs.nix
    ../../modules/desktop.nix
    ../../modules/networking.nix
    ../../modules/system-packages.nix
    ../../modules/cleanup.nix

    ./hardware-configuration.nix
  ];

  # Allow installing unfree packages
  nixpkgs.config.allowUnfree = true;

  # Additional Binary Cache
  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  # Enable Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # System Hostname
  networking.hostName = "nixos-vm";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "23.11";
}
