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

    meenzen = {
      cloudflare-warp.enable = true;
      openfortivpn.enable = true;
      verapdf.enable = true;
    };

    security.pki.certificateFiles = [
      ./certs/Forti_Proxy_CA.crt
      ./certs/Web_App_CA.crt
    ];

    environment.systemPackages = with pkgs; [
      claude-code
      claude-monitor
      # claude likes to use python, so let's install it
      python3
    ];
  };
}
