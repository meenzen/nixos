{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.beeper;
in {
  options.meenzen.beeper = {
    enable = lib.mkEnableOption "Enable Beeper";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.beeper
    ];
  };
}
