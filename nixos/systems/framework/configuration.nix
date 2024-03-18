# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
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
    ../../modules/bluetooth.nix
    #../../modules/gaming.nix
    ../../modules/cloudflare-warp

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
  };

  # Allow installing unfree packages
  nixpkgs.config.allowUnfree = true;

  # Additional Binary Cache
  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://crane.cachix.org"
      "https://nix.computer.surgery/conduit"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
      "conduit:ZGAf6P6LhNvnoJJ3Me3PRg7tlLSrPxcQ2RiE5LIppjo="
    ];
  };

  # Enable Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"]; #

  # System Hostname
  networking.hostName = "framework";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20; # Limit the number of generations to keep
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-d72b6916-393c-4db9-8194-6d48d1cf5189".device = "/dev/disk/by-uuid/d72b6916-393c-4db9-8194-6d48d1cf5189";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # ZRam
  zramSwap.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
