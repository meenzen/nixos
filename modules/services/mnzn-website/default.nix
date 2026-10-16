{
  config,
  lib,
  pkgs,
  secrets,
  ...
}: let
  cfg = config.meenzen.services.mnzn-website;
  serviceName = "mnzn-website";
in {
  options.meenzen.services.mnzn-website = {
    enable = lib.mkEnableOption "mnzn.dev Website";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "mnzn.dev";
      description = "Domain for mnzn.dev Website";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8093;
      description = "Local port for mnzn.dev Website";
    };
  };

  config = lib.mkIf cfg.enable {
    meenzen = {
      nginx.enable = true;
      # Provides the mnzn.dev certificate used by useACMEHost.
      services.acme-mnzn.enable = true;
      oci-containers.enable = true;
      postgresql = {
        enable = true;
        enableLocalNetwork = true;
        passwordFiles.${serviceName} = config.age.secrets.mnznWebsitePostgresPassword.path;
      };
    };

    age.secrets = {
      mnznWebsiteEnvironment = {
        file = "${secrets}/mnznWebsiteEnvironment.age";
        restartUnits = ["${config.virtualisation.oci-containers.containers.${serviceName}.serviceName}.service"];
      };
      mnznWebsitePostgresPassword = {
        file = "${secrets}/mnznWebsitePostgresPassword.age";
        restartUnits = ["postgresql-setup.service"];
        owner = "postgres";
        group = "postgres";
      };
    };
    virtualisation.oci-containers.containers."${serviceName}" = {
      image = "ghcr.io/meenzen/website:0.2.75@sha256:19eaa589bdd882348999b7d4697e6eafea13e5cab1bb0e761052e36ba42107c2";
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

    services.postgresql = {
      ensureUsers = [
        {
          name = serviceName;
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [serviceName];
    };

    # The image has no HEALTHCHECK and no curl, so wait for the health endpoint from the host. The unit only counts as
    # started, and the deployment only succeeds, once the application is serving requests.
    systemd.services.${config.virtualisation.oci-containers.containers.${serviceName}.serviceName}.serviceConfig = {
      ExecStartPost = "${lib.getExe pkgs.curl} --fail --silent --show-error --output /dev/null --max-time 5 --retry 25 --retry-delay 5 --retry-all-errors http://127.0.0.1:${toString cfg.port}/health";
      # The upstream module disables the start timeout, which would block deployments forever.
      TimeoutStartSec = lib.mkForce "5min";
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      useACMEHost = "mnzn.dev";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
      locations."/.well-known/matrix" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        extraConfig = ''
          proxy_hide_header 'Content-Type';
          add_header Content-Type application/json;
          proxy_hide_header 'Access-Control-Allow-Origin';
          add_header Access-Control-Allow-Origin *;
        '';
      };
    };
  };
}
