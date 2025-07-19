{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.miniflux;
  serviceName = "kener";
in {
  options.meenzen.services.miniflux = {
    enable = lib.mkEnableOption "Enable Miniflux";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "newsreader.mnzn.dev";
      description = "Domain for Miniflux";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8085;
      description = "Local port for Miniflux";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      minifluxEnvironment = {
        file = "${inputs.self}/secrets/minifluxEnvironment.age";
      };
    };

    services.miniflux = {
      enable = true;
      # https://miniflux.app/docs/configuration.html
      config = {
        CLEANUP_FREQUENCY = 48;
        LISTEN_ADDR = "127.0.0.1:${toString cfg.port}";
        BASE_URL = "https://${cfg.domain}";
        HTTPS = 1;
        CREATE_ADMIN = 1;
      };
      adminCredentialsFile = config.age.secrets.minifluxEnvironment.path;
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
