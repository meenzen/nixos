{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.secure-boot;
in {
  options.meenzen.secure-boot = {
    enable = lib.mkEnableOption "Enable Secure Boot";
  };

  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.sbctl
    ];

    # Lanzaboote currently replaces the systemd-boot module.
    # This setting is usually set to true in configuration.nix
    # generated at installation time. So we force it to false
    # for now.
    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        autoReboot = true;
        # required on framework devices
        includeFirmwareBuiltinKeys = true;
      };
    };
  };
}
