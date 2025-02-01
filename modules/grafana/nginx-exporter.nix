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
    rev = "8d61758aa1bc4bcc27dfb76dcb79078c53703bb4";
    sha256 = "sha256-czkzXy0g6Hp0MF77fPojuojW5m7B1vxdYBMMcbMEqxc=";
  };

  fullHostname =
    if config.networking.domain == ""
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
