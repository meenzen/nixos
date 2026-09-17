{
  config,
  lib,
  ...
}: let
  cfg = config.meenzen.matrix;
in {
  options.meenzen.matrix = {
    enable = lib.mkEnableOption "Enable Matrix Server";
  };

  imports = [
    ./draupnir.nix
    ./mas.nix
    ./rtc.nix
    ./synapse.nix
  ];

  config = lib.mkIf cfg.enable {
    meenzen.matrix = {
      draupnir.enable = true;
      mas.enable = true;
      rtc.enable = true;
      synapse.enable = true;
      synapse.enableWorkers = true;
    };
  };
}
