{pkgs, ...}: {
  home.packages = [
    pkgs.vlc
    pkgs.strawberry
    pkgs.pear-desktop
  ];

  programs.mpv.enable = true;
}
