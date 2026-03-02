{pkgs, ...}: {
  home.packages = with pkgs; [
    libreoffice-qt-fresh
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_DE
  ];
}
