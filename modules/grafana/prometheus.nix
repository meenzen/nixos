{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.prometheus;
  serviceName = "prometheus";
in {
  options.meenzen.prometheus = {
    enable = lib.mkEnableOption "Enable Prometheus";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "prometheus.mnzn.dev";
      description = "Domain for Prometheus";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 9090;
      description = "Local port for Prometheus";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      prometheusAdminPassword = {
        file = "${inputs.self}/secrets/prometheusAdminPassword.age";
        owner = "nginx";
        group = "nginx";
      };
    };

    services.prometheus = {
      enable = true;
      port = cfg.port;
      webExternalUrl = "https://${cfg.domain}";
      retentionTime = "30d";
      globalConfig = {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };
    };

    services.grafana.provision.datasources.settings.datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        access = "proxy";
        orgId = 1;
        url = "http://127.0.0.1:${toString config.services.prometheus.port}";
        basicAuth = false;
        isDefault = true;
        editable = false;
      }
    ];

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
        basicAuthFile = config.age.secrets.prometheusAdminPassword.path;
      };
    };
  };
}
