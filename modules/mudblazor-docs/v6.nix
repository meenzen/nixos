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
      image = "ghcr.io/meenzen/mudblazor-docs@sha256:637fc5857952499831c30850f72f5a65f4c0e667f2a054f62c9c884a6ba563c7";
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
