{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.meenzen.attic;
in {
  options.meenzen.attic = {
    enable = lib.mkEnableOption "Enable Attic";
    port = lib.mkOption {
      type = lib.types.int;
      default = 8082;
      description = "Local port for Attic";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "attic.mnzn.dev";
      description = "Domain for Attic";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "atticd";
      description = "User for Attic";
    };
  };

  imports = [
    ./scripts.nix
    ./substituters.nix
  ];

  config = lib.mkIf cfg.enable {
    age.secrets = {
      atticEnvironment = {
        file = "${inputs.self}/secrets/atticEnvironment.age";
      };
    };

    services.atticd = {
      package = inputs.attic.packages."x86_64-linux".attic-server;

      enable = true;
      user = cfg.user;
      group = cfg.user;
      environmentFile = config.age.secrets.atticEnvironment.path;

      settings = {
        listen = "[::]:${toString cfg.port}";
        allowed-hosts = [cfg.domain];
        api-endpoint = "https://${cfg.domain}/";
        database.url = "postgresql://${cfg.user}?host=/run/postgresql";
        jwt = {};
        storage = {
          type = "s3";
          region = "hel1";
          bucket = "meenzen-attic";
          endpoint = "https://hel1.your-objectstorage.com";
        };
        chunking = {
          nar-size-threshold = 512 * 1024; # 512 KiB
          min-size = 256 * 1024; # 256 KiB
          avg-size = 4 * 1024 * 1024; # 4 MiB
          max-size = 16 * 1024 * 1024; # 16 MiB
        };
        compression.type = "zstd";
        garbage-collection = {
          interval = "12 hours";
          default-retention-period = "6 months";
        };
      };
    };

    services.postgresql = {
      ensureUsers = [
        {
          name = cfg.user;
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [cfg.user];
    };

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
        extraConfig = ''
          client_max_body_size 5g;
        '';
      };
    };
  };
}
