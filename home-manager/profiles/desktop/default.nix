{
  config,
  lib,
  osConfig,
  ...
}: let
  cfg = config.meenzen.profiles.desktop;
in {
  options.meenzen.profiles.desktop = {
    enable =
      lib.mkEnableOption "desktop applications"
      // {default = osConfig.meenzen.profiles.desktop.enable;};
  };

  config = lib.mkIf cfg.enable {
    meenzen = {
      profiles.cli.enable = true;
      browsers.enable = true;
      code-editors.enable = true;
      communication.enable = true;
      desktop.enable = true;
      gaming.enable = true;
      keepass.enable = true;
      media-player.enable = true;
      office.enable = true;
      wezterm.enable = true;
    };
  };
}
