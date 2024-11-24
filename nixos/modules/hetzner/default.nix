{
  config,
  lib,
  ...
}: let
  cfg = config.meenzen.hetzner;
in {
  options.meenzen.hetzner = {
    enable = lib.mkEnableOption "Enable common Hetzner settings";
  };

  config = lib.mkIf cfg.enable {
    networking.timeServers = ["ntp1.hetzner.de" "ntp2.hetzner.com" "ntp3.hetzner.net"];
    networking.nameservers = [
      "2a01:4ff:ff00::add:1"
      "2a01:4ff:ff00::add:2"
      "185.12.64.1"
      "185.12.64.2"
    ];
  };
}
