{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.matrix.synapse;
  serviceName = "matrix-synapse";

  dashboards = pkgs.fetchFromGitHub {
    owner = "element-hq";
    repo = "synapse";
    rev = "9135d78b88a429cf0220d6a93bdac7485a3a0f88";
    hash = "sha256-9nN4sQXCamVi+FRN9++FN5nQmjYZnPKDLxjxEuga6EM=";
  };

  synapseSharedSettings = {
    server_name = cfg.domain;
    public_baseurl = "https://${cfg.matrixDomain}";

    # Security
    allow_guest_access = false;
    enable_registration = false;
    suppress_key_server_warning = true;

    # Cleanup
    delete_stale_devices_after = "1y";
    media_retention = {
      remote_media_lifetime = "1y";
      local_media_lifetime = "5y";
    };
    forgotten_room_retention_period = "30d";
  };
in {
  options.meenzen.matrix.synapse = {
    enable = lib.mkEnableOption "Enable Matrix Server";
    enableWorkers = lib.mkEnableOption "Enable Synapse Workers";
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

  imports = [
    inputs.nixos-matrix-modules.nixosModules.default
  ];

  config = lib.mkIf cfg.enable {
    age.secrets = {
      synapseConfig = {
        file = "${inputs.self}/secrets/synapseConfig.age";
        owner = serviceName;
        group = serviceName;
      };
    };

    meenzen.backup.paths = ["/var/lib/matrix-synapse"];

    # Synapse with Workers
    services.matrix-synapse-next = lib.mkIf cfg.enableWorkers {
      enable = cfg.enableWorkers;
      enableNginx = cfg.enableWorkers;
      package = pkgs.matrix-synapse;

      extraConfigFiles = [
        config.age.secrets.synapseConfig.path
      ];

      workers = {
        workerStartingPort = 8200;
        metricsStartingPort = 18083;

        federationSenders = 2;
        federationReceivers = 2;
        initialSyncers = 1;
        normalSyncers = 1;
        eventPersisters = 2;
        useUserDirectoryWorker = true;
      };

      settings =
        {
          database = {
            name = "psycopg2";
            args = {
              host = "/var/run/postgresql";
              user = "matrix-synapse";
              password = "synapse";
              dbname = "matrix-synapse";
            };
          };
          redis = {
            enabled = true;
            path = "/var/run/redis-synapse/redis.sock";
          };
        }
        // synapseSharedSettings;
    };
    systemd.services.matrix-synapse.serviceConfig.TimeoutStartSec = 600;
    services.redis.servers.synapse = lib.mkIf cfg.enableWorkers {
      enable = true;
      user = serviceName;
      unixSocket = "/var/run/redis-synapse/redis.sock";
      unixSocketPerm = 770;
    };

    # Monolithic Synapse
    services.matrix-synapse = lib.mkIf (!cfg.enableWorkers) {
      enable = !cfg.enableWorkers;
      withJemalloc = true;
      enable_metrics = true;

      extraConfigFiles = [
        config.age.secrets.synapseConfig.path
      ];

      settings =
        {
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
        }
        // synapseSharedSettings;
    };

    # todo: make this more reliable
    # see https://github.com/nixos/nixpkgs/blob/master/nixos/modules/services/databases/postgresql.md#initializing-module-services-postgres-initializing
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

    # todo: workers metrics
    services.prometheus.scrapeConfigs = lib.mkIf (!cfg.enableWorkers) [
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

    services.nginx.virtualHosts."${cfg.matrixDomain}" = lib.mkIf (!cfg.enableWorkers) {
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
      # Not compatible with workers because of a stuped assertion: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/matrix/synapse-auto-compressor.nix#L115
      enable = !cfg.enableWorkers;
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
