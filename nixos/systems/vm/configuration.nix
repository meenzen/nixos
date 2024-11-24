{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules
  ];

  system.stateVersion = "23.11";

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.qemuGuest.enable = true;

  meenzen.home-manager.extraConfig = {
    additionalPinnedApps = [
      "applications:google-chrome.desktop"
      "applications:rider.desktop"
    ];
  };
}
