{
  config,
  lib,
  osConfig,
  ...
}: {
  config = lib.mkIf config.meenzen.plasma.enable {
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
                  "applications:brave-origin.desktop"
                ]
                ++ osConfig.meenzen.plasma.panel.extraPinnedApps;
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
                ++ osConfig.meenzen.plasma.panel.extraShownTrayItems;
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
  };
}
