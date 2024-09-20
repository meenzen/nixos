{
  config,
  lib,
  ...
}: let
  cfg = config.custom.hardware.wooting;
in {
  options.custom.hardware.wooting = {
    enable = lib.mkEnableOption "Wooting / Wootility support";
  };

  config = lib.mkIf cfg.enable {
    hardware.wooting.enable = true;
  };
}
