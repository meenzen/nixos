{
  config,
  lib,
  pkgs,
  systemConfig,
  ...
}: let
  cfg = config.meenzen.hardware.esp32;
in {
  options.meenzen.hardware.esp32 = {
    enable = lib.mkEnableOption "Enable ESP32 support";
  };

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      # Espressif USB Serial/JTAG Controller
      SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0660", TAG+="uaccess"
    '';

    users.users."${systemConfig.user.username}".extraGroups = ["dialout"];
  };
}
