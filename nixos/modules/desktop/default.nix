{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.desktop;
in {
  options.meenzen.desktop = {
    enable = lib.mkEnableOption "Enable desktop related options";
  };

  config = lib.mkIf cfg.enable {
    meenzen.adb.enable = true;
    meenzen.bootloader.enable = true;
    meenzen.docker.enable = true;
    meenzen.fonts.enable = true;
    meenzen.home-manager.enable = true;
    meenzen.plasma.enable = true;
    meenzen.stylix.enable = true;
    meenzen.vpn.enable = true;
    meenzen.yubikey.enable = true;
  };
}
