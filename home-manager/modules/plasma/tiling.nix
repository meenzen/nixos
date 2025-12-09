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
    programs.plasma = {
      shortcuts = {
        plasmashell = {
          "manage activities" = "none"; # Conflict Meta+Q
          "next activity" = "none"; # Conflict Meta+Tab
          "previous activity" = "none"; # Conflict Meta+Shift+Tab
          "stop current activity" = "none"; # Conflict Meta+S

          "activate task manager entry 1" = "none"; # Conflict Meta+1
          "activate task manager entry 2" = "none"; # Conflict Meta+2
          "activate task manager entry 3" = "none"; # Conflict Meta+3
          "activate task manager entry 4" = "none"; # Conflict Meta+4
          "activate task manager entry 5" = "none"; # Conflict Meta+5
          "activate task manager entry 6" = "none"; # Conflict Meta+6
          "activate task manager entry 7" = "none"; # Conflict Meta+7
          "activate task manager entry 8" = "none"; # Conflict Meta+8
          "activate task manager entry 9" = "none"; # Conflict Meta+9
          "activate task manager entry 10" = "none"; # Conflict Meta+0
        };
        ksmserver = {
          "Lock Session" = "Ctrl+Alt+Shift+L"; # Conflict Meta+L
        };
        kwin = {
          "Window Close" = ["Meta+Q" "Alt+F4"];

          "Show Desktop" = "none";

          "Switch to Desktop 1" = "Meta+1";
          "Switch to Desktop 2" = "Meta+2";
          "Switch to Desktop 3" = "Meta+3";
          "Switch to Desktop 4" = "Meta+4";
          "Switch to Desktop 5" = "Meta+5";
          "Switch to Desktop 6" = "Meta+6";
          "Switch to Desktop 7" = "Meta+7";
          "Switch to Desktop 8" = "Meta+8";
          "Switch to Desktop 9" = "Meta+9";
          "Switch to Desktop 10" = "Meta+0";
          "Window to Desktop 1" = "Meta+!";
          "Window to Desktop 2" = ''Meta+"'';
          "Window to Desktop 3" = "Meta+§";
          "Window to Desktop 4" = "Meta+$";
          "Window to Desktop 5" = "Meta+%";
          "Window to Desktop 6" = "Meta+&";
          "Window to Desktop 7" = "Meta+/";
          "Window to Desktop 8" = "Meta+(";
          "Window to Desktop 9" = "Meta+Shift)";
          "Window to Desktop 10" = "Meta+=";

          "Window to Next Screen" = "Meta+Shift+Right";
          "Window to Previous Screen" = "Meta+Shift+Left";
          "Switch to Next Screen" = "Meta+Right";
          "Switch to Previous Screen" = "Meta+Left";

          # disable plasma tiling
          "Edit Tiles" = "none"; # Conflict Meta+T
          "Window Quick Tile Bottom" = "none";
          "Window Quick Tile Bottom Left" = "none";
          "Window Quick Tile Bottom Right" = "none";
          "Window Quick Tile Left" = "none";
          "Window Quick Tile Right" = "none";
          "Window Quick Tile Top" = "none";
          "Window Quick Tile Top Left" = "none";
          "Window Quick Tile Top Right" = "none";

          "KrohnkiteToggleFloat" = "Meta+F";
          "KrohnkiteFloatAll" = "Meta+Shift+F";

          "KrohnkiteRotate" = "Meta+R";
          "KrohnkiteRotatePart" = "none";
          "KrohnkitetoggleDock" = "none";

          "KrohnkiteMonocleLayout" = "Meta+M";
          "KrohnkiteBTreeLayout" = "Meta+T";
          "KrohnkiteQuarterLayout" = "none";
          "KrohnkiteTreeColumnLayout" = "none";
          "KrohnkiteColumnsLayout" = "none";
          "KrohnkiteFloatingLayout" = "none";
          "KrohnkiteSpiralLayout" = "none";
          "KrohnkiteSpreadLayout" = "none";
          "KrohnkiteStackedLayout" = "none";
          "KrohnkiteStairLayout" = "none";
          "KrohnkiteTileLayout" = "none";

          "KrohnkiteIncrease" = "none";
          "KrohnkiteDecrease" = "none";
          "KrohnkiteNextLayout" = "Meta+\\\\";
          "KrohnkitePreviousLayout" = "Meta+|";
          "KrohnkiteSetMaster" = "Meta+Return";

          "KrohnkiteShiftLeft" = "Meta+Shift+H";
          "KrohnkiteShiftDown" = "Meta+Shift+J";
          "KrohnkiteShiftUp" = "Meta+Shift+K";
          "KrohnkiteShiftRight" = "Meta+Shift+L";

          "KrohnkiteShrinkWidth" = "Meta+Ctrl+H";
          "KrohnkiteGrowHeight" = "Meta+Ctrl+J";
          "KrohnkiteShrinkHeight" = "Meta+Ctrl+K";
          "KrohnkitegrowWidth" = "Meta+Ctrl+L";

          "KrohnkiteFocusLeft" = "Meta+H";
          "KrohnkiteFocusDown" = "Meta+J";
          "KrohnkiteFocusUp" = "Meta+K";
          "KrohnkiteFocusRight" = "Meta+L";
          "KrohnkiteFocusNext" = "Meta+Tab";
          "KrohnkiteFocusPrev" = "Meta+Shift+Tab";
        };
      };
      configFile = {
        kwinrc = {
          Plugins.krohnkiteEnabled = true;
          Windows = {
            ActiveMouseScreen = false;
            SeparateScreenFocus = true;
          };
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
    };
  };
}
