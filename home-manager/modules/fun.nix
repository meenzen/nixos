{pkgs, ...}: {
  home.packages = with pkgs; [
    cowsay
    fastfetch
    asciiquarium
    clolcat
  ];
}
