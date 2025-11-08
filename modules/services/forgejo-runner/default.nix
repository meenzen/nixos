{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.forgejo-runner;
in {
  options.meenzen.services.forgejo-runner = {
    enable = lib.mkEnableOption "Enable Forgejo Runner";
    concurrency = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "The number of concurrent jobs to run";
    };
    cleanupSchedule = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "The schedule for cleaning up old data";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      forgejoRunnerToken = {
        file = "${inputs.self}/secrets/forgejoRunnerToken.age";
      };
    };

    virtualisation.docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = cfg.cleanupSchedule;
        flags = ["--all"];
      };
      daemon.settings = {
        # use a mirror that is not rate limited
        "registry-mirrors" = ["https://mirror.gcr.io"];

        # ipv6 support
        fixed-cidr-v6 = "fd00::/80";
        ipv6 = true;
      };
    };
    networking.firewall.interfaces."docker+".allowedUDPPorts = [53 5353];
    networking.firewall.trustedInterfaces = ["docker0" "br-+"];

    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances.default = {
        enable = true;
        name = config.networking.hostName;
        url = "https://${config.meenzen.services.forgejo.domain}/";
        tokenFile = config.age.secrets.forgejoRunnerToken.path;
        labels = [
          "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
          "ubuntu-24.04:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
          "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
          "nixos-latest:docker://nixos/nix"
        ];
        settings = {
          runner.capacity = cfg.concurrency;
          container = {
            enable_ipv6 = true;
            docker_host = "automount";
          };
        };
      };
    };
  };
}
