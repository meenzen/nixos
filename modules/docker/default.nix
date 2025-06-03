{
  config,
  lib,
  pkgs,
  inputs,
  systemConfig,
  ...
}: let
  cfg = config.meenzen.docker;
in {
  options.meenzen.docker = {
    enable = lib.mkEnableOption "Enable Docker";
    enablePodman = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use Podman instead of Docker.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users."${systemConfig.user.username}".extraGroups = ["docker" "podman"];

    meenzen.oci-containers = {
      enable = cfg.enablePodman;
      enableDockerCompat = false;
    };

    environment.systemPackages = [
      pkgs.dive
      pkgs.docker
      pkgs.docker-compose
    ];

    virtualisation.docker = {
      enable = !cfg.enablePodman;
      daemon.settings = {
        # use a mirror that is not rate limited
        "registry-mirrors" = ["https://mirror.gcr.io"];

        # custom address pools to avoid conflicts with the corporate network
        "bip" = "192.168.180.1/24";
        "default-address-pools" = [
          {
            base = "192.168.181.0/24";
            size = 24;
          }
          {
            base = "192.168.182.0/24";
            size = 24;
          }
          {
            base = "192.168.183.0/24";
            size = 24;
          }
          {
            base = "192.168.184.0/24";
            size = 24;
          }
          {
            base = "192.168.185.0/24";
            size = 24;
          }
          {
            base = "192.168.186.0/24";
            size = 24;
          }
          {
            base = "192.168.187.0/24";
            size = 24;
          }
          {
            base = "192.168.188.0/24";
            size = 24;
          }
          {
            base = "192.168.189.0/24";
            size = 24;
          }
        ];
      };
    };
  };
}
