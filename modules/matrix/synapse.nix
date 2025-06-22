{
  config,
  lib,
  pkgs,
  pkgs-unstable-small,
  inputs,
  ...
}: let
  cfg = config.meenzen.matrix.synapse;
  serviceName = "matrix-synapse";

  dashboards = pkgs.fetchFromGitHub {
    owner = "element-hq";
    repo = "synapse";
    rev = "ac1bf682ff012ee8af5153318eec5d25ed786e90";
    sha256 = "sha256-s6qbYUzxJ9ca3K2X5H0X2WwbwebmnH5wKG2Vj2rGjpg=";
  };
in {
  options.meenzen.matrix.synapse = {
    enable = lib.mkEnableOption "Enable Matrix Server";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "mnzn.dev";
      description = "Base Domain for Matrix Server";
    };
    matrixDomain = lib.mkOption {
      type = lib.types.str;
      default = "matrix.mnzn.dev";
      description = "Matrix Domain";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8008;
      description = "Local port for Matrix Server";
    };
    compressorChunkSize = lib.mkOption {
      type = lib.types.int;
      default = 500;
      description = "Chunk size for synapse_auto_compressor";
    };
    compressorChunksToCompress = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "Number of chunks to compress with synapse_auto_compressor";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      # https://nixpk.gs/pr-tracker.html?pr=417990
      (final: prev: {
        matrix-synapse-unwrapped = pkgs-unstable-small.matrix-synapse-unwrapped.overrideAttrs (oldAttrs: {});
      })
    ];

    age.secrets = {
      synapseConfig = {
        file = "${inputs.self}/secrets/synapseConfig.age";
        owner = serviceName;
        group = serviceName;
      };
    };

    meenzen.backup.paths = ["/var/lib/matrix-synapse"];

    services.matrix-synapse = {
      enable = true;
      withJemalloc = true;

      # No longer needed, use mas-cli instead
      enableRegistrationScript = false;

      extraConfigFiles = [
        config.age.secrets.synapseConfig.path
      ];

      settings = {
        server_name = cfg.domain;
        public_baseurl = "https://${cfg.matrixDomain}";

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
              instance = cfg.matrixDomain;
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

    services.nginx.virtualHosts."${cfg.matrixDomain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".extraConfig = ''
        return 404;
      '';
      locations."/_matrix".proxyPass = "http://[::1]:${toString cfg.port}";
      locations."/_synapse/client".proxyPass = "http://[::1]:${toString cfg.port}";
      locations."/_synapse/admin".proxyPass = "http://[::1]:${toString cfg.port}";
    };

    services.synapse-auto-compressor = {
      enable = true;
      startAt = "daily";
      settings = {
        chunk_size = cfg.compressorChunkSize;
        chunks_to_compress = cfg.compressorChunksToCompress;
      };
    };

    # Scripts for manual maintenance tasks
    environment.systemPackages = [
      (
        pkgs.writeScriptBin "matrix-synapse-run-synapse_auto_compressor" ''
          set -eux
          sudo -u matrix-synapse ${pkgs.rust-synapse-state-compress}/bin/synapse_auto_compressor -p "user=matrix-synapse dbname=matrix-synapse host=/run/postgresql" -c ${toString cfg.compressorChunkSize} -n ${toString cfg.compressorChunksToCompress}
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
