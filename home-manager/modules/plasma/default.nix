{
  # reference: https://github.com/pjones/plasma-manager/tree/trunk/modules
  programs.plasma = {
    enable = true;

    workspace = {
      clickItemTo = "select";
      lookAndFeel = "org.kde.breezedark.desktop";
    };

    fonts = {
      general = {
        family = "Noto Sans";
        pointSize = 10;
      };
      fixedWidth = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 10;
      };
    };

    panels = [
      {
        floating = true;
        location = "top";
        height = 44;
        widgets = [
          {
            name = "org.kde.plasma.kickoff";
            config = {
              General.icon = "nix-snowflake-white";
            };
          }
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General.launchers = [
                "applications:org.kde.plasma-systemmonitor.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:org.wezfurlong.wezterm.desktop"
                "applications:brave-browser.desktop"
                "applications:rider.desktop"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.pager"
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
              ];
            };
          }
          {
            digitalClock = {
              calendar.firstDayOfWeek = "monday";
              time.format = "24h";
            };
          }
        ];
      }
    ];

    spectacle.shortcuts = {
      captureActiveWindow = "Meta+Print";
      captureCurrentMonitor = "Print";
      captureEntireDesktop = "Shift+Print";
      captureRectangularRegion = "Meta+Shift+S";
      captureWindowUnderCursor = "Meta+Ctrl+Print";
      launch = "Meta+S";
      launchWithoutCapturing = "Meta+Alt+S";
      recordRegion = "Meta+Shift+R";
      recordScreen = "Meta+Alt+R";
      recordWindow = "Meta+Ctrl+R";
    };

    configFile = {
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
      krunnerrc.Plugins.baloosearchEnabled = false;
      kwinrc.Desktops.Number = {
        value = 3;
        # always force 3 desktops
        immutable = true;
      };
      kwinrc.Desktops.Rows = 1;
      kwinrc.Tiling.padding = 4;
      kwinrc.EdgeBarrier.EdgeBarrier = 25;

      # german regional settings
      "plasma-localerc".Formats.LANG = "de_DE.UTF-8";
      # english language
      "plasma-localerc".Translations.LANGUAGE = "en_US";
    };
  };
}
