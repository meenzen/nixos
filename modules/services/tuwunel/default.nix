{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.tuwunel;
in {
  options.meenzen.services.tuwunel = {
    enable = lib.mkEnableOption "Enable Tuwunel Matrix Server";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "conduit.mnzn.dev";
      description = "Domain for Tuwunel";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 6167;
      description = "Local port for Tuwunel";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      tuwunelEnvironment = {
        file = "${inputs.self}/secrets/tuwunelEnvironment.age";
      };
    };

    meenzen.backup.paths = ["/var/lib/tuwunel"];

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
          livekit_url = "https://${config.meenzen.lk-jwt-service.domain}";
        };
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      useACMEHost = "mnzn.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://[::1]:${toString cfg.port}";
      };
      extraConfig = ''
        add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
      '';
    };
  };
}
