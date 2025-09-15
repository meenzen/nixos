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

  synapseOption =
    if cfg.enableWorkers
    then config.services.matrix-synapse-next
    else config.services.matrix-synapse;

  plugins = with synapseOption.package.plugins; [
    matrix-synapse-s3-storage-provider
  ];

  synapseSharedSettings = {
    server_name = cfg.domain;
    public_baseurl = "https://${cfg.matrixDomain}";

    # General
    max_upload_size = "100M";
    media_upload_limits = [
      {
        time_period = "24h";
        max_size = "500M";
      }
      {
        time_period = "28d";
        max_size = "2G";
      }
    ];

    # Security
    allow_guest_access = false;
    enable_registration = false;
    suppress_key_server_warning = true;

    # Cleanup
    delete_stale_devices_after = "1y";
    media_retention = {
      # Media is not cleaned up from s3, see https://github.com/matrix-org/synapse-s3-storage-provider/issues/115
      # Until this is fixed, there is no reason to enable media retention
      # remote_media_lifetime = "1y";
      # local_media_lifetime = "5y";
    };
    forgotten_room_retention_period = "30d";
  };

  workerConfig = config.services.matrix-synapse-next.workers;
  workerMetricsPorts = lib.range 1 (
    workerConfig.federationSenders
    + workerConfig.federationReceivers
    + workerConfig.initialSyncers
    + workerConfig.normalSyncers
    + workerConfig.eventPersisters
    + (
      if workerConfig.useUserDirectoryWorker
      then 1
      else 0
    )
  );

  mediaUploadScript = let
    command = lib.getExe synapseOption.package.plugins.matrix-synapse-s3-storage-provider;
    dir = "${config.services.matrix-synapse.dataDir}";
    mediaDir = "${dir}/media_store";
    cacheDir = "${dir}/s3_media_upload";

    secretConfig = config.age.secrets.synapseConfig.path;
    dbConfig = pkgs.writeText "database.yaml" ''
      user: matrix-synapse
      database: matrix-synapse
      host: /var/run/postgresql
    '';
  in (pkgs.writeShellApplication {
    name = "matrix-synapse-media-upload";
    text = ''
      # Elevate to service user if needed
      TARGET="${serviceName}"
      USER="$(id -un)"
      if [ "$USER" != "$TARGET" ]; then
        echo "Current user is $USER, switching to $TARGET"
        exec sudo -u "$TARGET" "$0" "$@"
      fi

      get_property() {
        local key="$1"
        grep "$key:" ${secretConfig} | ${pkgs.gawk}/bin/awk '{print $2}'
      }

      mkdir -p ${cacheDir}
      cd ${cacheDir}
      cp -f ${dbConfig} ${cacheDir}/database.yaml

      S3_BUCKET="$(get_property bucket)"
      export S3_BUCKET

      S3_ENDPOINT="$(get_property endpoint_url)"
      export S3_ENDPOINT

      AWS_ACCESS_KEY_ID="$(get_property access_key_id)"
      export AWS_ACCESS_KEY_ID

      AWS_SECRET_ACCESS_KEY="$(get_property secret_access_key)"
      export AWS_SECRET_ACCESS_KEY

      set -x

      ${command} "$@" update-db "${cfg.s3UploadOlderThan}"
      ${command} "$@" check-deleted "${mediaDir}"
      ${command} "$@" upload "${mediaDir}" "$S3_BUCKET" --delete --endpoint-url "$S3_ENDPOINT"
    '';
  });
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
    s3UploadOlderThan = lib.mkOption {
      type = lib.types.str;
      default = "1d";
      description = "Upload media that hasn't been accessed for this duration to S3";
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

    meenzen.backup.paths = [config.services.matrix-synapse.dataDir];

    # Synapse with Workers
    # https://github.com/D4ndellion/nixos-matrix-modules
    services.matrix-synapse-next = lib.mkIf cfg.enableWorkers {
      enable = cfg.enableWorkers;
      enableNginx = cfg.enableWorkers;
      package = pkgs.matrix-synapse;
      plugins = plugins;

      extraConfigFiles = [
        config.age.secrets.synapseConfig.path
      ];

      workers = {
        workerStartingPort = 8200;
        metricsStartingPort = 18083;

        enableMetrics = true;

        federationSenders = 2;
        federationReceivers = 2;
        initialSyncers = 1;
        normalSyncers = 1;
        eventPersisters = 2;
        useUserDirectoryWorker = true;
      };

      # Metrics ports used by workers:
      # ss -ltnp | grep synapse
      #LISTEN 0      50              127.0.0.1:18084      0.0.0.0:*    users:((".synapse_worker",pid=3005816,fd=14))
      #LISTEN 0      50              127.0.0.1:18085      0.0.0.0:*    users:((".synapse_worker",pid=3005817,fd=14))
      #LISTEN 0      50              127.0.0.1:18086      0.0.0.0:*    users:((".synapse_worker",pid=3005827,fd=14))
      #LISTEN 0      50              127.0.0.1:18087      0.0.0.0:*    users:((".synapse_worker",pid=3005818,fd=14))
      #LISTEN 0      50              127.0.0.1:18088      0.0.0.0:*    users:((".synapse_worker",pid=3005819,fd=15))
      #LISTEN 0      50              127.0.0.1:18089      0.0.0.0:*    users:((".synapse_worker",pid=3005820,fd=15))
      #LISTEN 0      50              127.0.0.1:18090      0.0.0.0:*    users:((".synapse_worker",pid=3005830,fd=14))
      #LISTEN 0      50              127.0.0.1:18091      0.0.0.0:*    users:((".synapse_worker",pid=3005821,fd=14))
      #LISTEN 0      50              127.0.0.1:18092      0.0.0.0:*    users:((".synapse_worker",pid=3005829,fd=14))

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
      plugins = plugins;

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

    services.prometheus.scrapeConfigs = [
      {
        job_name = "synapse";
        scrape_interval = "15s";
        metrics_path = "/_synapse/metrics";
        static_configs =
          if cfg.enableWorkers
          then let
            # Worker Metrics: https://element-hq.github.io/synapse/latest/metrics-howto.html?highlight=metrics#monitoring-workers
            # Helper to find a listener exposing metrics
            hasMetrics = l: lib.any (r: lib.elem "metrics" r.names) (l.resources or []);
            mainMetricsListener =
              lib.findFirst hasMetrics null (config.services.matrix-synapse-next.settings.listeners or []);

            mkTarget = {
              port,
              labels,
            }: {
              targets = ["127.0.0.1:${toString port}"];
              inherit labels;
            };

            # todo: fix the master entry, it does not work currently
            masterEntry =
              lib.optional (mainMetricsListener != null && mainMetricsListener ? port)
              (mkTarget {
                port = mainMetricsListener.port;
                labels = {
                  instance = cfg.matrixDomain;
                  job = "master";
                  index = 1;
                };
              });

            wcfg = config.services.matrix-synapse-next.workers;

            workerList = lib.mapAttrsToList lib.nameValuePair wcfg.instances;

            typeToJob = t:
              {
                "fed-sender" = "federation_sender";
                "fed-receiver" = "federation_receiver";
                "initial-sync" = "initial_sync";
                "normal-sync" = "sync";
                "event-persist" = "event_persist";
                "user-dir" = "user_dir";
              }.${
                t
              } or t;

            workerEntries =
              lib.concatMap (
                w: let
                  metricsListener =
                    lib.findFirst hasMetrics null (w.value.settings.worker_listeners or []);
                in
                  lib.optional (metricsListener != null && metricsListener ? port)
                  (mkTarget {
                    port = metricsListener.port;
                    labels = {
                      instance = cfg.matrixDomain;
                      job = typeToJob w.value.type;
                      index = toString w.value.index;
                    };
                  })
              )
              workerList;
          in
            masterEntry ++ workerEntries
          else [
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

    services.nginx.virtualHosts."${cfg.matrixDomain}" =
      if cfg.enableWorkers
      then {
        locations."/_synapse/admin" = {
          proxyPass = "http://$synapse_backend";
        };
        locations."/_synapse/mas" = {
          proxyPass = "http://$synapse_backend";
        };
      }
      else {
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

    systemd.services.matrix-synapse-media-upload = {
      description = "Upload local Synapse media to S3";
      wants = ["network.target" "postgresql.service"];
      after = ["network.target" "postgresql.service"];
      startAt = "hourly";
      serviceConfig = {
        Type = "oneshot";
        User = serviceName;
        WorkingDirectory = config.services.matrix-synapse.dataDir;
        # execute using bash, executing the script directly does not work
        ExecStart = "${pkgs.bash}/bin/bash ${lib.getExe mediaUploadScript} --no-progress";
      };
    };

    # Scripts for manual maintenance tasks
    environment.systemPackages = [
      mediaUploadScript
      (
        pkgs.writeShellApplication {
          name = "matrix-synapse-compress-state";
          runtimeInputs = [
            pkgs.rust-synapse-state-compress
          ];
          text = ''
            set -x
            sudo -u ${serviceName} synapse_auto_compressor -p "user=matrix-synapse dbname=matrix-synapse host=/run/postgresql" -c ${toString cfg.compressorChunkSize} -n ${toString cfg.compressorChunksToCompress}
          '';
        }
      )
      (
        pkgs.writeShellApplication {
          name = "matrix-synapse-vacuum-full";
          text = ''
            set -x
            sudo -u ${serviceName} psql -U matrix-synapse -d matrix-synapse -c "VACUUM FULL VERBOSE"
          '';
        }
      )
    ];
  };
}
