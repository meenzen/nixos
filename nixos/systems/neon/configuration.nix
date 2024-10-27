{
  config,
  lib,
  pkgs,
  systemConfig,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "neon";
  networking.domain = "mnzn.dev";
  networking.hostId = "91312b0a";

  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks."30-wan" = {
      name = "enp6s0";
      DHCP = "no";
      addresses = [
        {
          Address = "95.217.150.38/26";
        }
        {
          Address = "2a01:4f9:3080:360e::bad:babe/64";
        }
      ];
      gateway = [
        "95.217.150.1"
        "fe80::1"
      ];
      linkConfig.RequiredForOnline = "routable";
    };
  };

  system.stateVersion = "24.11";
}
