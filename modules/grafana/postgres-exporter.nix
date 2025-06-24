{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.postgres-exporter;

  exporter = pkgs.fetchFromGitHub {
    owner = "prometheus-community";
    repo = "postgres_exporter";
    rev = "6d3078da3553bc1b522388e22fec01a314577cf4";
    sha256 = "0s6qjsj6lv87bcnsd0fnj2lqp1vb19fj2sl014cd6qzllp4h0q1m";
  };

  dashboards = pkgs.fetchFromGitHub {
    owner = "lstn";
    repo = "misc-grafana-dashboards";
    rev = "e18068331e9a54f82766844cad2c7fa098e4a1e0";
    sha256 = "0i9pli3i4rzvm74850jw5c91q7xbnr9cavcy5f8ssgf8j5swyjfh";
  };

  fullHostname =
    if toString config.networking.domain == ""
    then config.networking.hostName
    else "${config.networking.hostName}.${config.networking.domain}";
in {
  options.meenzen.postgres-exporter = {
    enable = lib.mkEnableOption "Enable Postgres Exporter";
    port = lib.mkOption {
      type = lib.types.int;
      default = 9187;
      description = "Local port for Postgres Exporter";
    };
  };

  config = lib.mkIf (cfg.enable && config.services.postgresql.enable) {
    services.prometheus = {
      exporters = {
        postgres = {
          enable = true;
          port = cfg.port;
          runAsLocalSuperUser = true;
          extraFlags = ["--auto-discover-databases"];
        };
      };
      scrapeConfigs = [
        {
          job_name = "postgres";
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
        name = "postgres-exporter";
        options.path = "${exporter}/postgres_mixin/dashboards/postgres-overview.json";
      }
      {
        name = "postgres-database";
        options.path = "${dashboards}/dashboards/postgresql-database.json";
      }
    ];
  };
}
