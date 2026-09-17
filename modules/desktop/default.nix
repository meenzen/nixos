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
    meenzen = {
      adb.enable = !cfg.slim;
      audio.enable = true;
      bootloader.enable = true;
      docker.enable = !cfg.slim;
      fonts.enable = true;
      home-manager.enable = !cfg.slim;
      plasma.enable = true;
      stylix.enable = !cfg.slim;
      yubikey.enable = !cfg.slim;
      zsh.enable = !cfg.slim;
      fish.enable = !cfg.slim;
      fish.default = !cfg.slim;
      hardware.logitech.enable = !cfg.slim;
      hardware.uhk.enable = !cfg.slim;
    };

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
        pkgs.mission-center
      ];
  };
}
