{pkgs, ...}: {
  home.packages = with pkgs; [
    xwaylandvideobridge
    kdePackages.kdeconnect-kde
  ];

  services.nextcloud-client.enable = true;
}
