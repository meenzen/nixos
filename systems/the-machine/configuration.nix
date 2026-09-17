{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime

    inputs.disko.nixosModules.disko
    ./disko.nix

    ./hardware-configuration.nix
  ];

  system.stateVersion = "24.05";

  # nixos-generate-config --root /tmp/config --no-filesystems
  # echo "<encryption-key>" > /tmp/secret.key
  # sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko nixos/systems/the-machine/disko.nix
  # sudo nixos-install --flake '.#the-machine'

  networking = {
    hostName = "the-machine";
    hostId = "94822ea4";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  boot = {
    zfs.forceImportRoot = false;
    loader.systemd-boot.windows."11" = {
      title = "Micros~1 Spyware";
      efiDeviceHandle = "HD1b65535a4";
    };
  };

  fileSystems = {
    "/games" = {
      device = "/dev/disk/by-uuid/0f7c57b0-a681-4b2a-b89d-6940465b22d2";
      fsType = "ext4";
      options = [
        "defaults"
        "discard"
        "noatime"
        "nofail"
      ];
    };
    "/bigboi" = {
      device = "/dev/disk/by-uuid/8cc465c3-eed0-419d-a42c-29e1b0bdf22d";
      fsType = "btrfs";
      options = [
        "defaults"
        "noatime"
        "commit=120"
        "discard=async"
        "compress-force=zstd:1"
        "space_cache=v2"
      ];
    };
  };

  services.btrfs.autoScrub.enable = true;
  environment.systemPackages = [
    pkgs.compsize
  ];

  meenzen = {
    desktop.enable = true;
    plasma.tiling.enable = true;
    remote-desktop.enable = true;
    hardware = {
      nvidia.enable = true;
      bluetooth.enable = true;
      wooting.enable = true;
    };
    gaming.enable = true;
    virt-manager.enable = true;
    printing.enable = true;
    services.local-ai.enable = true;
    home-manager.extraConfig = {
      additionalPinnedApps = [
        "applications:steam.desktop"
        "applications:com.heroicgameslauncher.hgl.desktop"
      ];
    };
  };

  programs.ausweisapp = {
    enable = true;
    openFirewall = true;
  };
}
