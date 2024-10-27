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

  environment.systemPackages = with pkgs; [
    vim
    wget
    duf
    htop
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = systemConfig.user.authorizedKeys;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "24.11"; # Did you read the comment?
}
