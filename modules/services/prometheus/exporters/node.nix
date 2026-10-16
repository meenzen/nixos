{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.services.prometheus.exporters.node;

  dashboards = pkgs.fetchFromGitHub {
    owner = "rfmoz";
    repo = "grafana-dashboards";
    rev = "0d3a3c0118f27873342626a4ecb36d35acf0ad01";
    sha256 = "1lf21fxqc96876izglspsskvwcfjdd9dx88m9mhbdks560797c4l";
  };

  fullHostname =
    if toString config.networking.domain == ""
    then config.networking.hostName
    else "${config.networking.hostName}.${config.networking.domain}";
in {
  options.meenzen.services.prometheus.exporters.node = {
    enable = lib.mkEnableOption "Node Exporter";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9100;
      description = "Local port for Node Exporter";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      prometheus = {
        exporters = {
          node = {
            enable = true;
            enabledCollectors = ["systemd" "processes"];
            port = cfg.port;
          };
        };
        scrapeConfigs = [
          {
            job_name = "node";
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

      grafana.provision.dashboards.settings.providers = [
        {
          name = "node-exporter-full";
          options.path = "${dashboards}/prometheus/node-exporter-full.json";
        }
      ];
    };
  };
}
