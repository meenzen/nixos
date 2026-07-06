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
      (
        pkgs.writeShellApplication
        {
          name = "openfortivpn-connect";
          text = ''
            VPN_HOST=vpn.human.de
            VPN_PORT=443
            openfortivpn-webview "''${VPN_HOST}:''${VPN_PORT}" 2>/dev/null \
            | sudo openfortivpn "''${VPN_HOST}:''${VPN_PORT}" --cookie-on-stdin --pppd-accept-remote
          '';
        }
      )
    ];
  };
}
