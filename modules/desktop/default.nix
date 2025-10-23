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
    meenzen.audio.enable = true;
    meenzen.bootloader.enable = true;
    meenzen.docker.enable = true;
    meenzen.fonts.enable = true;
    meenzen.home-manager.enable = true;
    meenzen.plasma.enable = true;
    meenzen.stylix.enable = true;
    meenzen.vpn.enable = true;
    meenzen.yubikey.enable = true;
    meenzen.zsh.enable = true;

    # KDE Partition Manager
    programs.partition-manager.enable = true;

    environment.systemPackages = [
      pkgs.kdePackages.filelight
      pkgs.kdePackages.kruler
      pkgs.kdePackages.kcolorchooser
      pkgs.kdePackages.neochat
      pkgs.kdePackages.kolourpaint
      pkgs.kdePackages.ghostwriter
      pkgs.kdePackages.kdenlive
      pkgs.krita
      pkgs.xdg-utils
      pkgs.qpwgraph
    ];
  };
}
