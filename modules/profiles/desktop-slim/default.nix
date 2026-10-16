{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.profiles.desktop-slim;
in {
  options.meenzen.profiles.desktop-slim = {
    enable = lib.mkEnableOption "essential desktop options";
  };

  config = lib.mkIf cfg.enable {
    meenzen = {
      audio.enable = true;
      bootloader.enable = true;
      fonts.enable = true;
      plasma.enable = true;
      services.attic = {
        client.enable = true;
        substituters.enable = true;
      };
    };

    # KDE Partition Manager
    programs.partition-manager.enable = true;

    environment.systemPackages = [
      pkgs.kdePackages.filelight
      pkgs.kdePackages.kolourpaint
      pkgs.xdg-utils
    ];
  };
}
