{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.yubikey;
in {
  options.meenzen.yubikey = {
    enable = lib.mkEnableOption "Enable YubiKey Support";
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [
      pkgs.yubikey-personalization
    ];

    # Smartcard support
    services.pcscd.enable = true;

    # Management GUI
    environment.systemPackages = [
      pkgs.yubioath-flutter
    ];
  };
}
