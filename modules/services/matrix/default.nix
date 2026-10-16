{
  config,
  lib,
  ...
}: let
  cfg = config.meenzen.services.matrix;
in {
  options.meenzen.services.matrix = {
    enable = lib.mkEnableOption "Enable Matrix Server";
  };

  imports = [
    ./draupnir.nix
    ./mas.nix
    ./rtc.nix
    ./synapse.nix
  ];

  config = lib.mkIf cfg.enable {
    meenzen.services.matrix = {
      draupnir.enable = true;
      mas.enable = true;
      rtc.enable = true;
      synapse.enable = true;
      synapse.enableWorkers = true;
    };
  };
}
