{
  config,
  lib,
  secrets,
  ...
}: let
  cfg = config.meenzen.services.grafana;
  serviceName = "grafana";
in {
  options.meenzen.services.grafana = {
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
    meenzen = {
      nginx.enable = true;
      services = {
        # Provides the mnzn.dev certificate used by useACMEHost.
        acme-mnzn.enable = true;
        loki.enable = true;
        nginx-exporter.enable = true;
        node-exporter.enable = true;
        postgres-exporter.enable = true;
        prometheus.enable = true;
        tempo.enable = true;
      };
    };

    age.secrets = {
      grafanaAdminPassword = {
        file = "${secrets}/grafanaAdminPassword.age";
        restartUnits = ["grafana.service"];
        owner = serviceName;
        group = serviceName;
      };
      grafanaSecretKey = {
        file = "${secrets}/grafanaSecretKey.age";
        restartUnits = ["grafana.service"];
        owner = serviceName;
        group = serviceName;
      };
    };

    services = {
      grafana = {
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

      nginx = {
        enable = true;
        virtualHosts."${cfg.domain}" = {
          forceSSL = true;
          useACMEHost = "mnzn.dev";
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            proxyWebsockets = true;
          };
          extraConfig = ''
            add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
          '';
        };
      };
    };
  };
}
