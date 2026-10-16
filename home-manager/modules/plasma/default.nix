{
  config,
  lib,
  osConfig,
  ...
}: {
  imports = [
    ./fonts.nix
    ./panels.nix
    ./spectacle.nix
    ./tiling.nix
    ./window-rules.nix
  ];

  options.meenzen.plasma = {
    enable =
      lib.mkEnableOption "Plasma configuration"
      // {default = osConfig.meenzen.plasma.enable;};
    tiling.enable =
      lib.mkEnableOption "Plasma tiling shortcuts and rules"
      // {default = osConfig.meenzen.plasma.tiling.enable;};
  };

  config = lib.mkIf config.meenzen.plasma.enable {
    # reference: https://github.com/pjones/plasma-manager/tree/trunk/modules
    programs.plasma = {
      enable = true;

      workspace = {
        clickItemTo = "select";
        lookAndFeel = "org.kde.breezedark.desktop";
      };

      configFile = {
        # disable file indexing
        baloofilerc."Basic Settings"."Indexing-Enabled" = false;
        krunnerrc.Plugins.baloosearchEnabled = false;

        kwinrc = {
          # virtual desktops
          Desktops.Number = {
            value = 9;
            immutable = true;
          };
          Desktops.Rows = 3;

          # general behavior
          Tiling.padding = 4;
          EdgeBarrier.EdgeBarrier = 25;

          Plugins = {
            # hide cursor when typing
            hidecursorEnabled = true;

            # translucency for moving windows
            translucencyEnabled = true;

            # wobbly windows
            wobblywindowsEnabled = true;
          };

          # hide cursor when typing
          "Effect-hidecursor" = {
            HideOnTyping = true;
            InactivityDuration = 0;
          };
        };

        # german regional settings
        "plasma-localerc".Formats.LANG = "de_DE.UTF-8";
        # english language
        "plasma-localerc".Translations.LANGUAGE = "en_US";
      };
    };
  };
}
