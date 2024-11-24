{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.latest-kernel;
in {
  options.meenzen.latest-kernel = {
    enable = lib.mkEnableOption "Enable Latest Kernel";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
