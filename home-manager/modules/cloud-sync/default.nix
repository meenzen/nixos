{
  config,
  lib,
  pkgs,
  ...
}: {
  options.meenzen.cloud-sync.enable = lib.mkEnableOption "cloud storage sync clients";

  config = lib.mkIf config.meenzen.cloud-sync.enable {
    home.packages = [
      pkgs.onedrive
    ];

    services.nextcloud-client.enable = true;
    # The gamescope session breaks graphical services, so don't start them without a display.
    systemd.user.services.nextcloud-client.Unit.ConditionEnvironment = ["|DISPLAY" "|WAYLAND_DISPLAY"];
  };
}
