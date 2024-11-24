{
  config,
  lib,
  ...
}: let
  cfg = config.meenzen.hardware.wooting;
in {
  options.meenzen.hardware.wooting = {
    enable = lib.mkEnableOption "Wooting / Wootility support";
  };

  config = lib.mkIf cfg.enable {
    hardware.wooting.enable = true;
  };
}
