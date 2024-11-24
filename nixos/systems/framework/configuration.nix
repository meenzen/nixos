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

    ../../modules
    ./hardware-configuration.nix
  ];

  system.stateVersion = "23.11";
  boot.initrd.luks.devices."luks-d72b6916-393c-4db9-8194-6d48d1cf5189".device = "/dev/disk/by-uuid/d72b6916-393c-4db9-8194-6d48d1cf5189";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  meenzen.virtualbox.enable = true;
  meenzen.certs.enable = true;
  meenzen.cloudflare-warp.enable = true;
  meenzen.hardware.bluetooth.enable = true;
  meenzen.hardware.uhk.enable = true;
  meenzen.home-manager.extraConfig = {
    additionalPinnedApps = [
      "applications:google-chrome.desktop"
      "applications:rider.desktop"
    ];
    additionalShownSystemTrayItems = [
      "org.kde.plasma.battery"
    ];
  };
}
