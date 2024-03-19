{pkgs, ...}: {
  home.packages = with pkgs; [];
  services.nextcloud-client.enable = true;
}
