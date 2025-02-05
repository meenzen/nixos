{pkgs, ...}: {
  home.packages = [
    pkgs.cowsay
    pkgs.ponysay
    pkgs.fastfetch
    pkgs.asciiquarium
    pkgs.clolcat
    pkgs.cmatrix
    pkgs.fortune
    pkgs.sl
    pkgs.bb
  ];

  programs.thefuck.enable = true;
}
