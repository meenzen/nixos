{
  config,
  lib,
  pkgs,
  ...
}: {
  options.meenzen.office.enable = lib.mkEnableOption "office suite";

  config = lib.mkIf config.meenzen.office.enable {
    home.packages = [
      pkgs.libreoffice-qt-stable
      pkgs.hunspell
      pkgs.hunspellDicts.en_US
      pkgs.hunspellDicts.de_DE
    ];
  };
}
