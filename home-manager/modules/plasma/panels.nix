{extraConfig, ...}: {
  programs.plasma.panels = [
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
            General.launchers =
              [
                "applications:org.kde.plasma-systemmonitor.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:org.wezfurlong.wezterm.desktop"
                "applications:brave-browser.desktop"
              ]
              ++ extraConfig.additionalPinnedApps;
          };
        }
        "org.kde.plasma.marginsseparator"
        "org.kde.plasma.pager"
        {
          systemTray.items = {
            shown =
              [
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
              ]
              ++ extraConfig.additionalShownSystemTrayItems;
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
}
