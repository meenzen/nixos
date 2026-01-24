{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.services.uptime-kuma;
  domains = [cfg.domain] ++ cfg.extraDomains;
  virtualHosts = builtins.listToAttrs (map (domain: {
      name = domain;
      value = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
        };
      };
    })
    domains);
in {
  options.meenzen.services.uptime-kuma = {
    enable = lib.mkEnableOption "Enable Uptime Kuma";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "uptime.mnzn.dev";
      description = "Domain for Uptime Kuma";
    };
    extraDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "status.mnzn.dev"
      ];
      description = "Additional domains for Uptime Kuma";
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

    services.nginx.virtualHosts = virtualHosts;
  };
}
