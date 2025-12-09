{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  gap = 5;
in {
  # adapted from https://github.com/nix-community/plasma-manager/pull/420/files#diff-6ff781eeeded28d1f35e8a6e5ecfb6325bff16c291f175d0d7a3490209b9f370
  config = lib.mkIf osConfig.meenzen.plasma.tiling.enable {
    programs.plasma.configFile.kwinrc = {
      Plugins.krohnkiteEnabled = true;
      Script-krohnkite = {
        screenGapTop = gap;
        screenGapLeft = gap;
        screenGapRight = gap;
        screenGapBottom = gap;
        screenGapBetween = gap;

        binaryTreeLayoutOrder = 1;
        tileLayoutOrder = 3;
        threeColumnLayoutOrder = 4;
        spiralLayoutOrder = 5;
        quarterLayoutOrder = 6;
        stackedLayoutOrder = 7;
        columnsLayoutOrder = 8;
        floatingLayoutOrder = 10;
        stairLayoutOrder = 11;

        ignoreClass = lib.concatStringsSep "," [
          "kded"
          "krunner"
          "ksshaskpass"
          "org.freedesktop.impl.portal.desktop.kde"
          "org.kde.plasmashell"
          "org.kde.polkit-kde-authentication-agent-1"
          "qalculate-qt"
          "spectacle"
          "xwaylandvideobridge"
          "yakuake"
        ];
        ignoreTitle = lib.concatStringsSep "," [
          "KDE Wayland Compositor"
        ];
      };
    };
  };
}
