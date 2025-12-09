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
  networking.hostName = "framework";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  boot.initrd.luks.devices."luks-d72b6916-393c-4db9-8194-6d48d1cf5189".device = "/dev/disk/by-uuid/d72b6916-393c-4db9-8194-6d48d1cf5189";

  meenzen.distributed-build.enable = true;
  meenzen.desktop.enable = true;
  meenzen.plasma.tiling.enable = true;
  meenzen.hyprland.enable = false;
  meenzen.latest-kernel.enable = false;
  meenzen.virt-manager.enable = true;
  meenzen.verapdf.enable = true;
  meenzen.certs.enable = true;
  meenzen.cloudflare-warp.enable = true;
  meenzen.openfortivpn.enable = true;
  meenzen.beeper.enable = true;
  meenzen.hardware.bluetooth.enable = true;
  meenzen.hardware.uhk.enable = true;
  meenzen.hardware.esp32.enable = true;
  meenzen.home-manager.extraConfig = {
    additionalPinnedApps = [
      "applications:google-chrome.desktop"
      "applications:rider.desktop"
    ];
    additionalShownSystemTrayItems = [
      "org.kde.plasma.battery"
    ];
  };
  meenzen.printing.enable = true;
  meenzen.plymouth.enable = true;
  meenzen.remote-desktop.enable = true;
  meenzen.winboat.enable = true;
  services.teamviewer.enable = true;
}
