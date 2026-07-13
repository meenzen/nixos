{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.openfortivpn;
  openfortivpn-webview-qt = pkgs.openfortivpn-webview-qt.overrideAttrs (oldAttrs: {
    patches =
      (oldAttrs.patches or [])
      ++ [
        ./pin-dialog.patch
      ];
  });
in {
  options.meenzen.openfortivpn = {
    enable = lib.mkEnableOption "Enable Fortinet VPN support";
    host = lib.mkOption {
      type = lib.types.str;
      default = "vpn.human.de";
      description = "The Fortinet VPN host to connect to.";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 443;
      description = "The Fortinet VPN port to connect to.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.openfortivpn
      openfortivpn-webview-qt
      (
        pkgs.writeShellApplication
        {
          name = "human-vpn";
          text = ''
            # cache credentials so the next command doesn't ask for the password again
            sudo -v

            openfortivpn-webview "${cfg.host}:${toString cfg.port}" 2>/dev/null \
            | sudo openfortivpn "${cfg.host}:${toString cfg.port}" --cookie-on-stdin --pppd-accept-remote
          '';
        }
      )
    ];
  };
}
