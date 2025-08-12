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

    # Fix GTK apps in KDE
    programs.dconf.enable = true;

    # Force KDE file picker
    environment.sessionVariables.XDG_CURRENT_DESKTOP = "KDE";
    environment.sessionVariables.GTK_USE_PORTAL = "1";

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.kdePackages.xdg-desktop-portal-kde
      ];
    };

    environment.systemPackages = [
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.kdePackages.kdeconnect-kde
    ];

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
