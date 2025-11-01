{pkgs, ...}: {
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
}
