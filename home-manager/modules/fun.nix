{pkgs, ...}: {
  home.packages = with pkgs; [
    cowsay
    ponysay
    fastfetch
    asciiquarium
    clolcat
    cmatrix
    fortune
    sl
    bb
  ];

  # https://nixpk.gs/pr-tracker.html?pr=325875
  #programs.thefuck.enable = true;
}
