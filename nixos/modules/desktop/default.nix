{pkgs, ...}: {
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  # Enable Wayland support in Chromium based apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable CUPS
  services.printing.enable = true;

  # KDE Plasma Desktop
  services.displayManager.sddm.enable = true;
  #services.displayManager.sddm.wayland.enable = true; # SDDM Wayland support is still a little unstable
  services.desktopManager.plasma6.enable = true;
  services.desktopManager.plasma6.enableQt5Integration = true;

  # disable baloo https://github.com/NixOS/nixpkgs/issues/63489#issuecomment-2046058993
  environment.plasma6.excludePackages = [
    pkgs.kdePackages.baloo
  ];

  # Force KDE file picker
  environment.sessionVariables.XDG_CURRENT_DESKTOP = "KDE";
  environment.sessionVariables.GTK_USE_PORTAL = "1";

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  environment.systemPackages = with pkgs; [
    kdePackages.xdg-desktop-portal-kde
    kdePackages.filelight
    kdePackages.kruler
    kdePackages.kcolorchooser
    kdePackages.kdeconnect-kde
    kdePackages.neochat
    kdePackages.kontact
    kdePackages.kmail-account-wizard
    kdePackages.kaccounts-integration
    kdePackages.kaccounts-providers
    kdePackages.kolourpaint
    kdePackages.ghostwriter
    kdePackages.kdenlive
    krita
    xwaylandvideobridge
    xdg-utils
    qpwgraph
  ];

  # fix GTK apps in KDE
  programs.dconf.enable = true;

  # KDE Partition Manager
  programs.partition-manager.enable = true;

  # KDE Connect Firewall
  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
  };
}
