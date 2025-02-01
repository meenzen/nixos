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
    rev = "f9c74570ed80d1a67c4a70e155cdb8d9689825eb";
    sha256 = "sha256-zKyr95e170GgbGMwAQolymjg7/hYPaeN9bg8NQKUIDE=";
  };

  dashboards = pkgs.fetchFromGitHub {
    owner = "lstn";
    repo = "misc-grafana-dashboards";
    rev = "68432fdac54781febcd4a05a8007463231ed8d17";
    sha256 = "sha256-sFjbwaLRPIdn/xLFyaFybV8FaaoSNRGyt8WdKfl3lhE=";
  };
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
                instance = config.networking.hostName;
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
