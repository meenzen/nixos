{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.node-exporter;

  dashboards = pkgs.fetchFromGitHub {
    owner = "rfmoz";
    repo = "grafana-dashboards";
    rev = "cad8539cc4c4ed043935e69b9c1ec23e551806f4";
    sha256 = "sha256-9BYujV2xXRRDvNI4sjimZEB4Z2TY/0WhwJRh5P122rs=";
  };
in {
  options.meenzen.node-exporter = {
    enable = lib.mkEnableOption "Enable Node Exporter";
    port = lib.mkOption {
      type = lib.types.int;
      default = 9100;
      description = "Local port for Node Exporter";
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
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
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ];
    };

    services.grafana.provision.dashboards.settings.providers = [
      {
        name = "node-exporter-full";
        options.path = "${dashboards}/prometheus/node-exporter-full.json";
      }
    ];
  };
}
