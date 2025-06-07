{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.plasma;
in {
  options.meenzen.plasma = {
    enable = lib.mkEnableOption "Enable Plasma Desktop";
  };

  config = lib.mkIf cfg.enable {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      #jack.enable = true;
    };

    # Enable Wayland support in Chromium based apps
    # Chromium Wayland is broken, see https://github.com/NixOS/nixpkgs/issues/334175
    #environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Enable CUPS
    services.printing.enable = true;

    # KDE Plasma Desktop
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
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
      extraPortals = [
        pkgs.kdePackages.xdg-desktop-portal-kde
      ];
    };

    environment.systemPackages = [
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.kdePackages.filelight
      pkgs.kdePackages.kruler
      pkgs.kdePackages.kcolorchooser
      pkgs.kdePackages.kdeconnect-kde
      pkgs.kdePackages.neochat
      pkgs.kdePackages.kolourpaint
      pkgs.kdePackages.ghostwriter
      pkgs.kdePackages.kdenlive
      pkgs.kdePackages.xwaylandvideobridge
      pkgs.krita
      pkgs.xdg-utils
      pkgs.qpwgraph
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
  };
}
