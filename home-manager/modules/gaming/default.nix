{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  imports = [
    ./steam.nix
  ];

  home.packages = [
    pkgs.prismlauncher
    pkgs.chiaki-ng
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi
      #obs-vkcapture
      obs-pipewire-audio-capture
      input-overlay
    ];
  };
}
