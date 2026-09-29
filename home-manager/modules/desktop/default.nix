{
  pkgs,
  lib,
  config,
  ...
}: {
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

  # temporary workaround for stylix issue
  gtk.gtk4.theme = lib.mkForce config.gtk.theme;
}
