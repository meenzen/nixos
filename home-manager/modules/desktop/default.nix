{
  lib,
  config,
  pkgs,
  ...
}: {
  options.meenzen.desktop.enable = lib.mkEnableOption "cloud sync, mail and download apps";

  config = lib.mkIf config.meenzen.desktop.enable {
    home.packages = [
      pkgs.onedrive
      pkgs.motrix # download manager
    ];

    services.nextcloud-client.enable = true;
    # The gamescope session breaks graphical services, so don't start them without a display.
    systemd.user.services.nextcloud-client.Unit.ConditionEnvironment = ["|DISPLAY" "|WAYLAND_DISPLAY"];

    programs.thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };
  };
}
