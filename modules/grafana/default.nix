{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.grafana;
  serviceName = "grafana";
in {
  options.meenzen.grafana = {
    enable = lib.mkEnableOption "Enable Grafana Stack";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "grafana.mnzn.dev";
      description = "Domain for Grafana";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 3000;
      description = "Local port for Grafana";
    };
  };

  imports = [
    ./loki.nix
    ./nginx-exporter.nix
    ./node-exporter.nix
    ./postgres-exporter.nix
    ./prometheus.nix
    ./tempo.nix
  ];

  config = lib.mkIf cfg.enable {
    meenzen.loki.enable = true;
    meenzen.nginx-exporter.enable = true;
    meenzen.node-exporter.enable = true;
    meenzen.postgres-exporter.enable = true;
    meenzen.prometheus.enable = true;
    meenzen.tempo.enable = true;

    age.secrets = {
      grafanaAdminPassword = {
        file = "${inputs.self}/secrets/grafanaAdminPassword.age";
        owner = serviceName;
        group = serviceName;
      };
      grafanaSecretKey = {
        file = "${inputs.self}/secrets/grafanaSecretKey.age";
        owner = serviceName;
        group = serviceName;
      };
    };

    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = cfg.port;
          domain = cfg.domain;
          root_url = "https://${cfg.domain}/";
          enable_gzip = true;
          enforce_domain = true;
        };
        security = {
          cookie_secure = true;
          admin_password = "$__file{${config.age.secrets.grafanaAdminPassword.path}}";
          secret_key = "$__file{${config.age.secrets.grafanaSecretKey.path}}";
        };
      };

      provision.enable = true;
    };

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
