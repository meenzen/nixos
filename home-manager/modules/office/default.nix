{pkgs, ...}: {
  home.packages = with pkgs; [
    libreoffice-qt-stable
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_DE
  ];
}
