{
  config,
  lib,
  pkgs,
  systemConfig,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/locale
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "neon";
  networking.domain = "mnzn.dev";
  networking.hostId = "91312b0a";

  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    networks.default = {
      name = "enp6s0";
      DHCP = "ipv4";
      addresses = [
        {
          Address = "2a01:4f9:3080:360e::bad:babe/64";
        }
      ];
      gateway = ["fe80::1"];
      linkConfig.RequiredForOnline = "routable";
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "24.11"; # Did you read the comment?
}
