{
  lib,
  config,
  pkgs,
  ...
}: {
  options.meenzen.office.enable = lib.mkEnableOption "office suite";

  config = lib.mkIf config.meenzen.office.enable {
    home.packages = with pkgs; [
      libreoffice-qt-stable
      hunspell
      hunspellDicts.en_US
      hunspellDicts.de_DE
    ];
  };
}
