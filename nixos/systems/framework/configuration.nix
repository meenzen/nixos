{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel

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
    ../../modules/certs
    ../../modules/cloudflare-warp
    ../../modules/hardware/bluetooth.nix

    ./hardware-configuration.nix
  ];

  # Allow installing unfree packages
  nixpkgs.config.allowUnfree = true;

  # Additional Binary Cache
  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://crane.cachix.org"
      "https://attic.conduit.rs/conduit"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
      "conduit:ddcaWZiWm0l0IXZlO8FERRdWvEufwmd0Negl1P+c0Ns="
    ];
  };

  # Enable Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # System Hostname
  networking.hostName = "framework";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-d72b6916-393c-4db9-8194-6d48d1cf5189".device = "/dev/disk/by-uuid/d72b6916-393c-4db9-8194-6d48d1cf5189";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # enable firmware update manager
  services.fwupd.enable = true;

  # VirtualBox
  virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.host.enableExtensionPack = true;

  system.stateVersion = "23.11";
}
