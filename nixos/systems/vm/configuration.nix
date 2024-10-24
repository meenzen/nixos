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

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.qemuGuest.enable = true;

  custom.home-manager.extraConfig = {
    additionalPinnedApps = [
      "applications:google-chrome.desktop"
      "applications:rider.desktop"
    ];
  };
}
