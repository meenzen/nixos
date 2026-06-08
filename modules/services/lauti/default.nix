{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.lauti;
in {
  options.meenzen.services.lauti = {
    enable = lib.mkEnableOption "Enable LAUTI";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "holzland-kiez.de";
      description = "Domain for LAUTI";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8096;
      description = "Local port for LAUTI";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      lautiEnvironment = {
        file = "${inputs.self}/secrets/lautiEnvironment.age";
      };
    };

    meenzen.backup.paths = [config.services.lauti.dataDir];

    services.lauti = {
      enable = true;
      dataDir = "/var/lib/lauti";
      secrets = [config.age.secrets.lautiEnvironment.path];
      settings = {
        LAUTI_BASE_URL = "https://${cfg.domain}";
        LAUTI_MEDIA_PATH = "/var/lib/lauti/media";
        LAUTI_ADDR = ":${toString cfg.port}";
        LAUTI_LOCALE = "de_DE";
        LAUTI_TIMEZONE = "Europe/Berlin";
        LAUTI_OSM_TILE_SERVER = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";
        LAUTI_OSM_TILE_CACHE_DIR = "/var/lib/lauti/osm";
      };
    };

    # The NixOS module is broken, it sets this to the old name "eintopf"
    systemd.services.lauti.serviceConfig.StateDirectory = lib.mkForce "lauti";

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };
  };
}
