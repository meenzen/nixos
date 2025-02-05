{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.openfortivpn;
in {
  options.meenzen.openfortivpn = {
    enable = lib.mkEnableOption "Enable openfortivpn";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.openfortivpn
      pkgs.openfortivpn-webview
    ];
  };
}
