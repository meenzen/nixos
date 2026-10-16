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
    panel = {
      extraPinnedApps = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["applications:steam.desktop"];
        description = "Launchers pinned to the task manager in addition to the default ones";
      };
      extraShownTrayItems = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["org.kde.plasma.battery"];
        description = "System tray items that are always shown in addition to the default ones";
      };
    };
  };

  imports = [./tiling.nix];

  config = lib.mkIf cfg.enable {
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

        # Wayland only, no Plasma X11 session
        pkgs.kdePackages.kwin-x11
      ];
    };

    programs = {
      # Fix GTK apps in KDE
      dconf.enable = true;

      # KMail, Kontact and Merkuro, enabled by default with Plasma
      kde-pim.enable = false;

      # SSH agent with ksshaskpass prompts, e.g. for security key touch confirmation
      ssh = {
        startAgent = true;
        enableAskPassword = true;
      };
    };

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
