{
  pkgs,
  extraConfig,
  ...
}: {
  imports = [
    ./fonts.nix
    ./panels.nix
    ./spectacle.nix
    ./window-rules.nix
  ];

  services.gpg-agent.pinentry.package = pkgs.pinentry-qt;

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

      # virtual desktops
      kwinrc.Desktops.Number = {
        value = 3;
        # always force 3 desktops
        immutable = true;
      };
      kwinrc.Desktops.Rows = 1;

      # general behavior
      kwinrc.Tiling.padding = 4;
      kwinrc.EdgeBarrier.EdgeBarrier = 25;

      # hide cursor when typing
      kwinrc.Plugins.hidecursorEnabled = true;
      kwinrc."Effect-hidecursor" = {
        HideOnTyping = true;
        InactivityDuration = 0;
      };

      # translucency for moving windows
      kwinrc.Plugins.translucencyEnabled = true;

      # wobbly windows
      kwinrc.Plugins.wobblywindowsEnabled = true;

      # german regional settings
      "plasma-localerc".Formats.LANG = "de_DE.UTF-8";
      # english language
      "plasma-localerc".Translations.LANGUAGE = "en_US";
    };
  };
}
