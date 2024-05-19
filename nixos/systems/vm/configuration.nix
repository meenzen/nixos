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
  disabledModules = [
    ../../modules/certs
  ];

  # the initial password is 'password123'

  networking.hostName = "vm";
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.qemuGuest.enable = true;
}
