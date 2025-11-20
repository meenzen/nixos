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
    slim = lib.mkEnableOption "Only enable essential desktop options";
  };

  config = lib.mkIf cfg.enable {
    meenzen.adb.enable = !cfg.slim;
    meenzen.audio.enable = true;
    meenzen.bootloader.enable = true;
    meenzen.docker.enable = !cfg.slim;
    meenzen.fonts.enable = true;
    meenzen.home-manager.enable = !cfg.slim;
    meenzen.plasma.enable = true;
    meenzen.stylix.enable = !cfg.slim;
    meenzen.yubikey.enable = !cfg.slim;
    meenzen.zsh.enable = !cfg.slim;

    # KDE Partition Manager
    programs.partition-manager.enable = true;

    environment.systemPackages =
      [
        pkgs.kdePackages.filelight
        pkgs.kdePackages.kolourpaint
        pkgs.xdg-utils
      ]
      ++ lib.optionals (!cfg.slim) [
        pkgs.kdePackages.kruler
        pkgs.kdePackages.kcolorchooser
        pkgs.kdePackages.kdenlive
        pkgs.krita
        pkgs.qpwgraph
      ];
  };
}
