{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}: {
  imports = [
    ../../modules
  ];
  disabledModules = [
    ../../modules/certs
  ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.qemuGuest.enable = true;
}
