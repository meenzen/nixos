{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.oci-containers;
in {
  options.meenzen.oci-containers = {
    enable = lib.mkEnableOption "Enable OCI container support";
    autoPrune = lib.mkOption {
      type = lib.types.bool;
      default = config.meenzen.server.enable;
      description = "Enable automatic pruning.";
    };
    github = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.meenzen.server.enable;
        description = "Enable GitHub registry support.";
      };
      registry = lib.mkOption {
        type = lib.types.str;
        default = "ghcr.io";
        description = "The hostname of the GitHub registry.";
      };
      registryUser = lib.mkOption {
        type = lib.types.str;
        default = "meenzen";
        description = "The username to use for the GitHub registry.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.dive # look into docker image layers
      pkgs.podman-tui # status of containers in the terminal
      pkgs.podman-compose
    ];
    environment.sessionVariables.PODMAN_COMPOSE_WARNING_LOGS = "false";

    virtualisation.docker.enable = false;
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune = {
        enable = cfg.autoPrune;
        dates = "daily";
        flags = ["--all"];
      };
    };

    # Allow DNS and mDNS so that containers can resolve hostnames
    networking.firewall.interfaces."podman+".allowedUDPPorts = [53 5353];

    age.secrets = lib.mkIf cfg.github.enable {
      githubRegistryPassword = {
        file = "${inputs.self}/secrets/githubRegistryPassword.age";
      };
    };
  };
}
