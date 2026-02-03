{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.mudblazor-docs.v6;
  serviceName = "mudblazor-docs-v6";
in {
  options.meenzen.mudblazor-docs.v6 = {
    enable = lib.mkEnableOption "Enable MudBlazor Docs v6";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "v6.mudblazor.mnzn.dev";
      description = "Domain for MudBlazor Docs v6";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8081;
      description = "Local port for MudBlazor Docs v6";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers."${serviceName}" = {
      image = "ghcr.io/meenzen/mudblazor-docs:6@sha256:32f3b1c46e6a7864f06efe9d4c2a951b4bd79ae60b861e30f28c4b5dfbc96ec7";
      ports = ["127.0.0.1:${toString cfg.port}:8080"];
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
