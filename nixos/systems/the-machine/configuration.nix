{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime

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
    ../../modules/gaming.nix
    ../../modules/hardware/nvidia.nix

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
  networking.hostName = "the-machine";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  # Mounts
  fileSystems."/games" = {
    device = "/dev/disk/by-uuid/0f7c57b0-a681-4b2a-b89d-6940465b22d2";
    fsType = "ext4";
    options = [
      "defaults"
      "discard"
      "noatime"
      "nofail"
    ];
  };

  # Wootility
  hardware.wooting.enable = true;

  system.stateVersion = "23.11";
}
