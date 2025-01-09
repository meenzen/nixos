{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.hardware.bluetooth;
in {
  options.meenzen.hardware.bluetooth = {
    enable = lib.mkEnableOption "Enable bluetooth support";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };
  };
}
