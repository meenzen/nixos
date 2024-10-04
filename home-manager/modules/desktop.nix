{pkgs, ...}: {
  home.packages = with pkgs; [
    onedrive
  ];
  services.nextcloud-client.enable = true;
  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
    };
  };
}
