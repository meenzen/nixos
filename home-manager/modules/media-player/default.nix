{pkgs, ...}: {
  home.packages = [
    pkgs.vlc
    pkgs.strawberry
    pkgs.youtube-music
  ];

  programs.mpv.enable = true;
}
