{pkgs, ...}: {
  home.packages = with pkgs; [
    vlc
    strawberry
  ];

  programs.mpv.enable = true;
}
