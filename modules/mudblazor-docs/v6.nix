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
      image = "ghcr.io/meenzen/mudblazor-docs:6@sha256:c33169f77f81e6f8936ac3d9ef9214b7be4036e370249096e6fe6d9cd025b7c5";
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
