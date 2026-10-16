{
  config,
  lib,
  pkgs,
  ...
}: {
  options.meenzen.media-player.enable = lib.mkEnableOption "media players";

  config = lib.mkIf config.meenzen.media-player.enable {
    home.packages = [
      pkgs.vlc
      pkgs.strawberry
      pkgs.pear-desktop
    ];

    programs.mpv.enable = true;
  };
}
