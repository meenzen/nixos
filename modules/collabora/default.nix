{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.collabora;
  serviceName = "collabora";
in {
  options.meenzen.collabora = {
    enable = lib.mkEnableOption "Enable Collabora Server";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "office.mnzn.dev";
      description = "Domain for Collabora";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 9980;
      description = "Local port for Collabora";
    };
    allowedDomain = lib.mkOption {
      type = lib.types.str;
      default = "cloud\.mnzn\.dev|cloud\.dhess\.dev";
    };
    dictionaries = lib.mkOption {
      type = lib.types.str;
      default = "en_US,de_DE";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      collaboraEnvironment = {
        file = "${inputs.self}/secrets/collaboraEnvironment.age";
      };
    };

    virtualisation.oci-containers.containers."${serviceName}" = {
      image = "docker.io/collabora/code:latest@sha256:05df5e537bf7a72f31c6acb72a37dcf74c77893af5a285c0746c1cc590165fb7";
      ports = ["127.0.0.1:${toString cfg.port}:9980"];
      extraOptions = ["--cap-add" "MKNOD"];
      environment = {
        domain = cfg.allowedDomain;
        extra_params = "--o:ssl.enable=false --o:ssl.termination=true";
        dictionaries = cfg.dictionaries;
      };
      environmentFiles = [
        config.age.secrets.collaboraEnvironment.path
      ];
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };
  };
}
