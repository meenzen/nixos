{
  lib,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.meenzen.plasma.enable {
    programs.plasma.fonts = {
      general = {
        family = "Noto Sans";
        pointSize = 10;
      };
      fixedWidth = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 10;
      };
    };
  };
}
