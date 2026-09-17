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
    ./hardware-configuration.nix
  ];

  system.stateVersion = "23.11";
  networking = {
    hostName = "framework";
    networkmanager.enable = true;
    firewall.enable = true;
  };
  boot.initrd.luks.devices."luks-d72b6916-393c-4db9-8194-6d48d1cf5189".device = "/dev/disk/by-uuid/d72b6916-393c-4db9-8194-6d48d1cf5189";

  meenzen = {
    distributed-build.enable = false;
    desktop.enable = true;
    plasma.tiling.enable = true;
    hyprland.enable = false;
    latest-kernel.enable = true;
    virt-manager.enable = true;
    beeper.enable = true;
    hardware = {
      bluetooth.enable = true;
      uhk.enable = true;
      esp32.enable = true;
    };
    home-manager.extraConfig = {
      additionalPinnedApps = [
        "applications:google-chrome.desktop"
        "applications:rider.desktop"
      ];
      additionalShownSystemTrayItems = [
        "org.kde.plasma.battery"
      ];
    };
    printing.enable = true;
    plymouth.enable = true;
    remote-desktop.enable = true;
    winboat.enable = false;
    work.enable = true;
  };
}
