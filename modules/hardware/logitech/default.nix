{
  config,
  lib,
  ...
}: let
  cfg = config.meenzen.hardware.logitech;
in {
  options.meenzen.hardware.logitech = {
    enable = lib.mkEnableOption "Logitech hardware support";
  };

  config = lib.mkIf cfg.enable {
    hardware.logitech.wireless.enable = true;

    programs.solaar = {
      enable = true;
      userService.enable = true;
    };
    systemd.user.services.solaar = {
      # The gamescope session breaks graphical services, so don't start them without a display.
      unitConfig.ConditionEnvironment = ["|DISPLAY" "|WAYLAND_DISPLAY"];
      # By default solaar is configured `After=dbus.service`, at that point the display is not guaranteed to be set.
      after = ["graphical-session.target"];
    };
  };
}
