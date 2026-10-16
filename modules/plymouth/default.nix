{
  config,
  lib,
  ...
}: let
  cfg = config.meenzen.plymouth;
in {
  options.meenzen.plymouth = {
    enable = lib.mkEnableOption "plymouth splash screen";
  };

  config = lib.mkIf cfg.enable {
    boot.plymouth.enable = true;
  };
}
