{
  config,
  lib,
  ...
}: let
  cfg = config.meenzen.foo;
in {
  options.meenzen.foo = {
    enable = lib.mkEnableOption "foo";
  };

  config = lib.mkIf cfg.enable {
    # some config
  };
}
