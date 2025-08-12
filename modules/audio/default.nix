{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.audio;
in {
  options.meenzen.audio = {
    enable = lib.mkEnableOption "Enable Audio";
  };

  config = lib.mkIf cfg.enable {
    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      #jack.enable = true;
    };
  };
}
