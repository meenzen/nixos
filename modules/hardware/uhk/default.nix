{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.hardware.uhk;
in {
  options.meenzen.hardware.uhk = {
    enable = lib.mkEnableOption "Ultimate Hacking Keyboard (UHK) support";
  };

  config = lib.mkIf cfg.enable {
    hardware.keyboard.uhk.enable = true;
    environment.systemPackages = [
      pkgs.uhk-agent
    ];
  };
}
