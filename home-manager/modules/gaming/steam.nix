{
  config,
  osConfig,
  lib,
  ...
}: {
  config = lib.mkIf (config.meenzen.gaming.enable && osConfig.programs.steam.enable) {
    # fix slow steam download speed
    home.file.".steam/steam/steam_dev.cfg".text = ''
      @nClientDownloadEnableHTTP2PlatformLinux 0
    '';
  };
}
