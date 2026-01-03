{
  config,
  lib,
  pkgs,
  inputs,
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
    # build failure
    meenzen.matrix.draupnir.enable = false;
    meenzen.matrix.element-call.enable = true;
    meenzen.matrix.mas.enable = true;
    meenzen.matrix.synapse.enable = true;
    meenzen.matrix.synapse.enableWorkers = true;
  };
}
