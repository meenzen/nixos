{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.foo;
in {
  options.meenzen.foo = {
    enable = lib.mkEnableOption "Enable foo";
  };

  config = lib.mkIf cfg.enable {
    # some config
  };
}
