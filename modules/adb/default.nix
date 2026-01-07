{
  config,
  lib,
  pkgs,
  inputs,
  systemConfig,
  ...
}: let
  cfg = config.meenzen.adb;
in {
  options.meenzen.adb = {
    enable = lib.mkEnableOption "Enable ADB";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.android-tools];
    users.users."${systemConfig.user.username}".extraGroups = ["adbusers"];
  };
}
