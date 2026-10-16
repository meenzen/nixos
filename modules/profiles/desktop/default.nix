{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.profiles.desktop;
in {
  options.meenzen.profiles.desktop = {
    enable = lib.mkEnableOption "desktop related options";
  };

  config = lib.mkIf cfg.enable {
    meenzen = {
      profiles.desktop-slim.enable = true;
      adb.enable = true;
      docker.enable = true;
      home-manager.enable = true;
      stylix.enable = true;
      yubikey.enable = true;
      zsh.enable = true;
      fish.enable = true;
      fish.default = true;
      hardware.logitech.enable = true;
      hardware.uhk.enable = true;
    };

    environment.systemPackages = [
      pkgs.kdePackages.kruler
      pkgs.kdePackages.kcolorchooser
      pkgs.kdePackages.kdenlive
      pkgs.krita
      pkgs.qpwgraph
      pkgs.mission-center
    ];
  };
}
