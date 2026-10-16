{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.adb;
in {
  options.meenzen.adb = {
    enable = lib.mkEnableOption "ADB";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.android-tools];
  };
}
