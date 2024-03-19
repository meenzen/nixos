{pkgs, ...}: {
  home.packages = with pkgs; [
    onedrive
  ];
  services.nextcloud-client.enable = true;
}
