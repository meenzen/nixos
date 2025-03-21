{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.websites."mnzn.dev";
in {
  options.meenzen.websites."mnzn.dev" = {
    enable = lib.mkEnableOption "Enable mnzn.dev website";
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts."mnzn.dev" = {
      enableACME = true;
      forceSSL = true;
      root = ./public;
      locations."/.well-known/matrix" = {
        extraConfig = ''
          add_header Content-Type application/json;
          add_header Access-Control-Allow-Origin *;
        '';
      };
    };
  };
}
