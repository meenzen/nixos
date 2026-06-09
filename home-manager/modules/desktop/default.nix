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
  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
    };
  };

  # temporary workaround for stylix issue
  gtk.gtk4.theme = lib.mkForce config.gtk.theme;
}
