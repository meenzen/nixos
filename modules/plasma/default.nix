{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.plasma;
in {
  options.meenzen.plasma = {
    enable = lib.mkEnableOption "Enable Plasma Desktop";
  };

  imports = [./tiling.nix];

  config = lib.mkIf cfg.enable {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # KDE Plasma Desktop
    services = {
      displayManager.plasma-login-manager.enable = true;
      desktopManager = {
        plasma6.enable = true;
        plasma6.enableQt5Integration = true;
      };
    };

    environment = {
      systemPackages = [
        pkgs.kdePackages.xdg-desktop-portal-kde
        pkgs.kdePackages.kdeconnect-kde

        # Required for OCR in Spectacle
        pkgs.tesseract
      ];

      sessionVariables = {
        # Enable Wayland support in Chromium based apps
        NIXOS_OZONE_WL = "1";

        # Force KDE file picker
        XDG_CURRENT_DESKTOP = "KDE";
        GTK_USE_PORTAL = "1";
      };

      plasma6.excludePackages = [
        # disable baloo https://github.com/NixOS/nixpkgs/issues/63489#issuecomment-2046058993
        pkgs.kdePackages.baloo
      ];
    };

    # Fix GTK apps in KDE
    programs.dconf.enable = true;

    # Force KDE file picker
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.kdePackages.xdg-desktop-portal-kde
      ];
    };

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
