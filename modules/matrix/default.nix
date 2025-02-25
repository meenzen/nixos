{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.matrix;
  serviceName = "matrix-synapse";

  dashboards = pkgs.fetchFromGitHub {
    owner = "element-hq";
    repo = "synapse";
    rev = "ac1bf682ff012ee8af5153318eec5d25ed786e90";
    sha256 = "sha256-s6qbYUzxJ9ca3K2X5H0X2WwbwebmnH5wKG2Vj2rGjpg=";
  };
in {
  options.meenzen.matrix = {
    enable = lib.mkEnableOption "Enable Matrix Server";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "mnzn.dev";
      description = "Domain for Matrix Server";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8008;
      description = "Local port for Matrix Server";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      matrixSharedSecret = {
        file = "${inputs.self}/secrets/matrixSharedSecret.age";
        owner = serviceName;
        group = serviceName;
      };
    };

    meenzen.backup.paths = ["/var/lib/matrix-synapse"];

    services.matrix-synapse = {
      enable = true;
      withJemalloc = true;
      enableRegistrationScript = true;

      extraConfigFiles = [
        config.age.secrets.matrixSharedSecret.path
      ];

      settings = {
        server_name = cfg.domain;
        public_baseurl = "https://matrix.${cfg.domain}";

        # Security
        allow_guest_access = false;
        enable_registration = false;

        # Endpoints
        listeners = [
          {
            port = cfg.port;
            bind_addresses = ["::1"];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = ["client" "federation" "metrics"];
                compress = true;
              }
            ];
          }
        ];
        enable_metrics = true;

        # Cleanup
        delete_stale_devices_after = "1y";
        media_retention = {
          remote_media_lifetime = "1y";
          local_media_lifetime = "5y";
        };
        forgotten_room_retention_period = "30d";
      };
    };

    services.postgresql = {
      enable = true;
      initialScript = pkgs.writeText "setup-matrix-synapse.sql" ''
        CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
          TEMPLATE template0
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';
    };

    services.prometheus.scrapeConfigs = [
      {
        job_name = "synapse";
        scrape_interval = "15s";
        metrics_path = "/_synapse/metrics";
        static_configs = [
          {
            targets = ["[::1]:${toString cfg.port}"];
            labels = {
              instance = "matrix.${cfg.domain}";
            };
          }
        ];
      }
    ];

    services.grafana.provision.dashboards.settings.providers = [
      {
        name = "synapse";
        options.path = "${dashboards}/contrib/grafana/synapse.json";
      }
    ];

    services.nginx.virtualHosts."matrix.${cfg.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".extraConfig = ''
        return 404;
      '';
      locations."/_matrix".proxyPass = "http://[::1]:${toString cfg.port}";
      locations."/_synapse/client".proxyPass = "http://[::1]:${toString cfg.port}";
    };

    environment.systemPackages = [
      (
        pkgs.writeScriptBin "matrix-synapse-run-synapse_auto_compressor" ''
          set -eux
          sudo -u matrix-synapse ${pkgs.rust-synapse-state-compress}/bin/synapse_auto_compressor -p "user=matrix-synapse dbname=matrix-synapse host=/run/postgresql" -c 1000 -n 1000
        ''
      )
      (
        pkgs.writeScriptBin "matrix-synapse-vacuum-full" ''
          set -eux
          sudo -u matrix-synapse psql -U matrix-synapse -d matrix-synapse -c "VACUUM FULL VERBOSE"
        ''
      )
    ];
  };
}
