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

  config = {
    boot.kernelPackages =
      if cfg.enable
      then pkgs.linuxPackages_latest
      else pkgs.linuxPackages;
  };
}
