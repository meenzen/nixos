{
  pkgs,
  lib,
  osConfig,
  ...
}: {
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

  # fix slow steam download speed
  home.file.".steam/steam/steam_dev.cfg".text = lib.mkIf osConfig.programs.steam.enable ''
    @nClientDownloadEnableHTTP2PlatformLinux 0
  '';
}
