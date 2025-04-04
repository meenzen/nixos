{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  fileSystems."/" = {
    device = "/dev/vda";
    fsType = "ext4";
  };

  system.stateVersion = "23.11";
  networking.hostName = "vm";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.qemuGuest.enable = true;

  meenzen.desktop.enable = true;
  meenzen.home-manager.extraConfig = {
    additionalPinnedApps = [
      "applications:google-chrome.desktop"
      "applications:rider.desktop"
    ];
  };
}
