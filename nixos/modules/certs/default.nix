{
  config,
  lib,
  ...
}: let
  cfg = config.custom.certs;
in {
  options.custom.certs = {
    enable = lib.mkEnableOption "Install custom certificates";
  };

  config = lib.mkIf cfg.enable {
    security.pki.certificateFiles = [
      ./Forti_Proxy_CA.crt
      ./Web_App_CA.crt
    ];
  };
}
