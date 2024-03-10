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
    ../../shared/workaround.nix
    ../../shared/locale.nix
    ../../shared/fonts.nix
    ../../shared/users.nix
    ../../shared/services.nix
    ../../shared/programs.nix
    ../../shared/desktop.nix
    ../../shared/networking.nix
    ../../shared/system-packages.nix
    ../../shared/cleanup.nix
    ../../shared/gaming.nix

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
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };
  # Enable Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # System Hostname
  networking.hostName = "the-machine";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20; # Limit the number of generations to keep
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
    ];
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  boot.kernelParams = ["nvidia_drm.modeset=1"];

  # might be required
  boot.initrd.kernelModules = ["nvidia"];
  boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # ZRam
  zramSwap.enable = true;

  # Mounts
  fileSystems."/games" = {
    device = "/dev/disk/by-uuid/0f7c57b0-a681-4b2a-b89d-6940465b22d2";
    fsType = "ext4";
    options = [
      "defaults"
      "discard"
      "noatime"
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
