{
  config,
  lib,
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
      pkgs.chiaki-ng
    ];

    programs.prismlauncher.enable = true;

    programs.obs-studio = {
      enable = true;
      plugins = [
        pkgs.obs-studio-plugins.obs-vaapi
        pkgs.obs-studio-plugins.obs-vkcapture
        pkgs.obs-studio-plugins.obs-pipewire-audio-capture
        pkgs.obs-studio-plugins.input-overlay
      ];
    };
  };
}
