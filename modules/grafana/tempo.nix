{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.tempo;
  serviceName = "tempo";
in {
  options.meenzen.tempo = {
    enable = lib.mkEnableOption "Enable Tempo";
    port = lib.mkOption {
      type = lib.types.int;
      default = 3200;
      description = "Local Tempo port";
    };
    grpc-port = lib.mkOption {
      type = lib.types.int;
      default = 3201;
      description = "Local Tempo gRPC ingest port";
    };
    otlp-port = lib.mkOption {
      type = lib.types.int;
      default = 4317;
      description = "Local Tempo OTLP ingest port";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tempo = {
      enable = true;
      settings = {
        server = {
          http_listen_port = cfg.port;
          grpc_listen_port = cfg.grpc-port;
        };
        distributor.receivers.otlp.protocols.grpc.endpoint = "127.0.0.1:${toString cfg.otlp-port}";
        compactor.compaction.block_retention = "720h"; # 30 days
        storage.trace = {
          backend = "local";
          local.path = "/var/lib/tempo/blocks";
          wal.path = "/var/lib/tempo/wal";
        };
      };
    };

    services.grafana.provision.datasources.settings.datasources = [
      {
        name = "Tempo";
        type = "tempo";
        access = "proxy";
        orgId = 1;
        url = "http://127.0.0.1:${toString cfg.port}";
        basicAuth = false;
        editable = false;
      }
    ];
  };
}
