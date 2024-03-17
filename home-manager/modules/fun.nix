{pkgs, ...}: {
  home.packages = with pkgs; [
    cowsay
    fastfetch
    asciiquarium
    clolcat
  ];

  programs.thefuck.enable = true;
}
