{
  lib,
  config,
  pkgs,
  ...
}: {
  options.meenzen.communication.enable = lib.mkEnableOption "communication apps";

  config = lib.mkIf config.meenzen.communication.enable {
    home.packages = [
      pkgs.vesktop
      pkgs.mumble
    ];
  };
}
