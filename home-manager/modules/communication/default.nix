{
  lib,
  config,
  pkgs,
  ...
}: {
  options.meenzen.communication.enable = lib.mkEnableOption "communication apps";

  config = lib.mkIf config.meenzen.communication.enable {
    home.packages = [
      # build failure
      pkgs.vesktop
      pkgs.mumble
      #pkgs.teamspeak_client
    ];
  };
}
