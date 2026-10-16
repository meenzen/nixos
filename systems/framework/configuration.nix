{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel

    inputs.disko.nixosModules.disko
    ./disko.nix

    ./hardware-configuration.nix
  ];

  system.stateVersion = "26.05";
  networking = {
    hostName = "framework";
    hostId = "b2bb15e5";
    networkmanager.enable = true;
    firewall.enable = true;
  };
  boot.zfs.forceImportRoot = false;

  meenzen = {
    secure-boot.enable = true;
    distributed-build.enable = false;
    profiles.desktop.enable = true;
    plasma = {
      tiling.enable = true;
      panel = {
        extraPinnedApps = [
          "applications:google-chrome.desktop"
          "applications:rider.desktop"
        ];
        extraShownTrayItems = [
          "org.kde.plasma.battery"
        ];
      };
    };
    hyprland.enable = false;
    latest-kernel.enable = true;
    virt-manager.enable = true;
    beeper.enable = true;
    hardware = {
      bluetooth.enable = true;
      esp32.enable = true;
    };
    printing.enable = true;
    plymouth.enable = true;
    remote-desktop.enable = true;
    work.enable = true;
  };
}
