{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.conduit;
in {
  options.meenzen.services.conduit = {
    enable = lib.mkEnableOption "Enable Conduit Matrix Server";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "conduit.mnzn.dev";
      description = "Domain for Conduit";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 6167;
      description = "Local port for Conduit";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      conduitEnvironment = {
        file = "${inputs.self}/secrets/conduitEnvironment.age";
      };
    };

    meenzen.backup.paths = [config.services.matrix-conduit.settings.global.database_path];

    services.matrix-conduit = {
      enable = true;
      package = inputs.conduit.packages."x86_64-linux".default;

      settings.global = {
        port = cfg.port;
        server_name = cfg.domain;
        address = "::1";
        database_backend = "rocksdb";
        allow_registration = false;
        allow_federation = true;
        allow_encryption = true;
        enable_lightning_bolt = false;
      };
    };

    systemd.services.conduit.serviceConfig.EnvironmentFile = config.age.secrets.conduitEnvironment.path;

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://[::1]:${toString cfg.port}";
      };
    };
  };
}
