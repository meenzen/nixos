{pkgs, ...}: {
  home.packages = [
    pkgs.vlc
    pkgs.strawberry
  ];

  programs.mpv.enable = true;
}
