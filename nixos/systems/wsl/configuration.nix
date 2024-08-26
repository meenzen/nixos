{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../modules
  ];
  disabledModules = [
    ../../modules/bootloader
    ../../modules/certs
    ../../modules/desktop
    ../../modules/cloudflare-warp
    ../../modules/firmware-update
    ../../modules/gaming
    ../../modules/networking
    ../../modules/vpn
  ];

  wsl = {
    enable = true;
    defaultUser = systemConfig.user.username;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
