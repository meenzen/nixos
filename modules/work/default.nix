{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.work;
in {
  options.meenzen.work = {
    enable = lib.mkEnableOption "work environment";
  };

  config = lib.mkIf cfg.enable {
    services.teamviewer.enable = true;

    meenzen.cloudflare-warp.enable = true;
    meenzen.openfortivpn.enable = true;
    meenzen.verapdf.enable = true;

    security.pki.certificateFiles = [
      ./certs/Forti_Proxy_CA.crt
      ./certs/Web_App_CA.crt
    ];

    networking.hosts = {
      "192.168.155.28" = [
        "step-ca.human2.de"
        "safe.human2.de"
        "mde.human2.de"
      ];
    };
  };
}
