{
  config,
  lib,
  ...
}: let
  cfg = config.custom.keyboards;
in {
  options.custom.keyboards.wooting = {
    enable = lib.mkEnableOption "Wooting / Wootility support";
  };

  config = lib.mkIf cfg.wooting.enable {
    hardware.wooting.enable = true;
  };
}
