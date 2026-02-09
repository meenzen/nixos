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
      # todo: set to pkgs.linuxPackages when https://github.com/NixOS/nixpkgs/pull/485549 is merged
      else pkgs.linuxPackages_6_18;
  };
}
