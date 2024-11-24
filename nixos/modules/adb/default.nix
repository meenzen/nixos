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
    programs.adb.enable = true;
    users.users."${systemConfig.user.username}".extraGroups = ["adbusers"];
  };
}
