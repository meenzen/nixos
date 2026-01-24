{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.services.uptime-kuma;
in {
  options.meenzen.services.uptime-kuma = {
    enable = lib.mkEnableOption "Enable Uptime Kuma";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "status.mnzn.dev";
      description = "Domain for Uptime Kuma";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8094;
      description = "Local port for Uptime Kuma";
    };
  };

  config = lib.mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      settings = {
        PORT = toString cfg.port;
      };
    };

    meenzen.backup.paths = [config.services.uptime-kuma.settings.DATA_DIR];

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
