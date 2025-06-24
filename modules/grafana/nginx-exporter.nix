{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.nginx-exporter;

  exporter = pkgs.fetchFromGitHub {
    owner = "nginxinc";
    repo = "nginx-prometheus-exporter";
    rev = "9237ce63146ab59b2c5562d28089a529536c5863";
    sha256 = "03v8143485awvr2hb8gqijbgnl958mfi4b4xbw1aywvsc95jby7w";
  };

  fullHostname =
    if toString config.networking.domain == ""
    then config.networking.hostName
    else "${config.networking.hostName}.${config.networking.domain}";
in {
  options.meenzen.nginx-exporter = {
    enable = lib.mkEnableOption "Enable Nginx Exporter";
    port = lib.mkOption {
      type = lib.types.int;
      default = 9113;
      description = "Local port for Nginx Exporter";
    };
  };

  config = lib.mkIf (cfg.enable && config.services.nginx.enable) {
    services.nginx.statusPage = true;
    services.prometheus = {
      exporters = {
        nginx = {
          enable = true;
          port = cfg.port;
        };
      };
      scrapeConfigs = [
        {
          job_name = "nginx";
          static_configs = [
            {
              targets = ["127.0.0.1:${toString cfg.port}"];
              labels = {
                instance = fullHostname;
              };
            }
          ];
        }
      ];
    };

    services.grafana.provision.dashboards.settings.providers = [
      {
        name = "nginx-prometheus-exporter";
        options.path = "${exporter}/grafana/dashboard.json";
      }
    ];
  };
}
