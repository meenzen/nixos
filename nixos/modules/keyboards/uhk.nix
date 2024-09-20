{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.keyboards;
in {
  options.custom.keyboards.uhk = {
    enable = lib.mkEnableOption "Ultimate Hacking Keyboard (UHK) support";
  };

  config = lib.mkIf cfg.uhk.enable {
    hardware.keyboard.uhk.enable = true;
    environment.systemPackages = with pkgs; [
      uhk-agent
    ];
  };
}
