{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.loki;
  serviceName = "loki";
in {
  options.meenzen.loki = {
    enable = lib.mkEnableOption "Enable Loki";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "loki.mnzn.dev";
      description = "Domain for Loki";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 3100;
      description = "Local port for Loki";
    };
    grpc-port = lib.mkOption {
      type = lib.types.int;
      default = 3101;
      description = "Local port for Loki";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      lokiAdminPassword = {
        file = "${inputs.self}/secrets/lokiAdminPassword.age";
        owner = "nginx";
        group = "nginx";
      };
    };

    # override promtail url to use local instance
    meenzen.promtail.url = "http://127.0.0.1:${toString cfg.port}/loki/api/v1/push";

    services.loki = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = cfg.port;
          grpc_listen_port = cfg.grpc-port;
        };
        auth_enabled = false;

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore.store = "inmemory";
              replication_factor = 1;
            };
          };
        };

        schema_config = {
          configs = [
            {
              from = "2024-04-01";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          tsdb_shipper = {
            active_index_directory = "/var/lib/loki/index";
            cache_location = "/var/lib/loki/index_cache";
            cache_ttl = "24h";
          };

          filesystem = {
            directory = "/var/lib/loki/chunks";
          };
        };

        compactor = {
          working_directory = "/var/lib/loki";
          delete_request_store = "filesystem";
          compactor_ring.kvstore.store = "inmemory";
          retention_enabled = true;
        };

        limits_config.retention_period = "14d";

        frontend = {
          max_outstanding_per_tenant = 4096;
          compress_responses = true;
        };

        querier.max_concurrent = 2048;

        query_range.results_cache.cache.embedded_cache = {
          enabled = true;
          max_size_mb = 100;
        };

        ruler = {
          storage = {
            type = "local";
            local.directory = "/var/lib/loki/rules";
          };
          ring.kvstore.store = "inmemory";
          enable_api = true;
        };
      };
    };

    # fix startup, see https://github.com/NixOS/nixpkgs/pull/352485
    systemd.services.loki = {
      requires = ["network-online.target"];
      wantedBy = ["multi-user.target"];
    };

    services.grafana.provision.datasources.settings.datasources = [
      {
        name = "Loki";
        type = "loki";
        access = "proxy";
        orgId = 1;
        url = "http://127.0.0.1:${toString cfg.port}";
        basicAuth = false;
        editable = false;
      }
    ];

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
        basicAuthFile = config.age.secrets.lokiAdminPassword.path;
      };
    };
  };
}
