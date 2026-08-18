{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.hardware.logitech;
in {
  options.meenzen.hardware.logitech = {
    enable = lib.mkEnableOption "Logitech hardware support";
  };

  config = lib.mkIf cfg.enable {
    hardware.logitech.wireless.enable = true;
    programs.solaar.enable = true;
  };
}
