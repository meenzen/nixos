{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.mnzn-website;
  serviceName = "mnzn-website";
in {
  options.meenzen.services.mnzn-website = {
    enable = lib.mkEnableOption "Enable mnzn.dev Website";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "mnzn.dev";
      description = "Domain for mnzn.dev Website";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8093;
      description = "Local port for mnzn.dev Website";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      mnznWebsiteEnvironment = {
        file = "${inputs.self}/secrets/mnznWebsiteEnvironment.age";
      };
    };
    virtualisation.oci-containers.containers."${serviceName}" = {
      image = "ghcr.io/meenzen/website:0.1.54@sha256:2008ffdfa5d6c0bbee5c1d67f5aa381f5c1f59c452d071aa3533704972e275a3";
      ports = ["127.0.0.1:${toString cfg.port}:8080"];
      environment = {
        TZ = "UTC";
        LANG = "en_US.UTF-8";
        ASPNETCORE_FORWARDEDHEADERS_ENABLED = "true";
      };
      environmentFiles = [
        config.age.secrets.mnznWebsiteEnvironment.path
      ];
      extraOptions = [
        "--add-host=host.docker.internal:host-gateway"
      ];
      login = {
        registry = config.meenzen.oci-containers.github.registry;
        username = config.meenzen.oci-containers.github.registryUser;
        passwordFile = config.age.secrets.githubRegistryPassword.path;
      };
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
      locations."/.well-known/matrix" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        extraConfig = ''
          add_header Content-Type application/json;
          add_header Access-Control-Allow-Origin *;
        '';
      };
    };
  };
}
