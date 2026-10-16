{
  lib,
  config,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    ./steam.nix
  ];

  options.meenzen.gaming.enable =
    lib.mkEnableOption "gaming apps"
    // {default = osConfig.meenzen.gaming.enable;};

  config = lib.mkIf config.meenzen.gaming.enable {
    home.packages = [
      pkgs.prismlauncher
      pkgs.chiaki-ng
    ];

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-vaapi
        obs-vkcapture
        obs-pipewire-audio-capture
        input-overlay
      ];
    };
  };
}
