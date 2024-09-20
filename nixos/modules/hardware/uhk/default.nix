{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.hardware.uhk;
in {
  options.custom.hardware.uhk = {
    enable = lib.mkEnableOption "Ultimate Hacking Keyboard (UHK) support";
  };

  config = lib.mkIf cfg.enable {
    hardware.keyboard.uhk.enable = true;
    environment.systemPackages = with pkgs; [
      uhk-agent
    ];
  };
}
