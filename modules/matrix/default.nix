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
    ./element-call.nix
    ./mas.nix
    ./synapse.nix
  ];

  config = lib.mkIf cfg.enable {
    meenzen.matrix = {
      draupnir.enable = true;
      element-call.enable = true;
      mas.enable = true;
      synapse.enable = true;
      synapse.enableWorkers = true;
    };
  };
}
