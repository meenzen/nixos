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

    ../../modules
    ./hardware-configuration.nix
  ];

  # nixos-generate-config --root /tmp/config --no-filesystems
  # echo "<encryption-key>" > /tmp/secret.key
  # sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko nixos/systems/the-machine/disko.nix
  # sudo nixos-install --flake '.#the-machine'

  system.stateVersion = "24.05";
  networking.hostId = "94822ea4";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  boot.loader.systemd-boot.windows."11" = {
    title = "Micros~1 Spyware";
    efiDeviceHandle = "HD1b65535a3";
  };

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

  meenzen.desktop.enable = true;
  meenzen.hardware.nvidia.enable = true;
  meenzen.hardware.bluetooth.enable = true;
  meenzen.hardware.wooting.enable = true;
  meenzen.gaming.enable = true;
  meenzen.home-manager.extraConfig = {
    additionalPinnedApps = [
      "applications:steam.desktop"
      "applications:com.heroicgameslauncher.hgl.desktop"
    ];
  };
}
