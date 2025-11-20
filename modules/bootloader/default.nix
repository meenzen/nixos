{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.bootloader;
in {
  options.meenzen.bootloader = {
    enable = lib.mkEnableOption "Enable Bootloader";
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 20;
        memtest86.enable = true;
        edk2-uefi-shell.enable = true;
      };
    };
  };
}
