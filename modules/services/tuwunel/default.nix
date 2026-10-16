{
  config,
  lib,
  secrets,
  ...
}: let
  cfg = config.meenzen.services.tuwunel;
in {
  options.meenzen.services.tuwunel = {
    enable = lib.mkEnableOption "Tuwunel Matrix Server";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "conduit.mnzn.dev";
      description = "Domain for Tuwunel";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 6167;
      description = "Local port for Tuwunel";
    };
  };

  config = lib.mkIf cfg.enable {
    meenzen = {
      nginx.enable = true;
      # Provides the mnzn.dev certificate used by useACMEHost.
      services.acme-mnzn.enable = true;
      backup.paths = ["/var/lib/tuwunel"];
      # well_known.livekit_url points Tuwunel's users at this service
      services.matrix.lk-jwt-service.fullAccessHomeservers = [cfg.domain];
    };

    age.secrets = {
      tuwunelEnvironment = {
        file = "${secrets}/tuwunelEnvironment.age";
        restartUnits = ["tuwunel.service"];
      };
    };

    services.matrix-tuwunel = {
      enable = true;
      environmentFile = config.age.secrets.tuwunelEnvironment.path;

      settings.global = {
        port = [cfg.port];
        server_name = cfg.domain;
        address = ["::1"];
        allow_registration = false;
        allow_federation = true;
        allow_encryption = true;
        well_known = {
          client = "https://${cfg.domain}";
          server = "${cfg.domain}:443";
          livekit_url = "https://${config.meenzen.services.matrix.lk-jwt-service.domain}";
        };
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      useACMEHost = "mnzn.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://[::1]:${toString cfg.port}";
      };
      meenzen.noIndex = true;
    };
  };
}
