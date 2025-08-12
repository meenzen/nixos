{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.hyprland;
in {
  options.meenzen.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland";
  };

  config = lib.mkIf cfg.enable {
    # Add a separate boot entry for Hyprland
    specialisation.hyprland.configuration = {
      # Plasma has conflicting settings so it needs to be disabled
      meenzen.plasma.enable = lib.mkForce false;

      # SDDM is awesome
      services.displayManager.sddm.enable = true;
      services.displayManager.sddm.wayland.enable = true;

      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };
      networking.networkmanager.enable = true;

      # KDE Wallet Auto Unlock
      security.pam.services = {
        login.kwallet = {
          enable = true;
          package = lib.mkForce pkgs.kdePackages.kwallet-pam;
          forceRun = true;
        };
        kde = {
          allowNullPassword = true;
          kwallet = {
            enable = true;
            package = lib.mkForce pkgs.kdePackages.kwallet-pam;
            forceRun = true;
          };
        };
      };

      environment.sessionVariables.GTK_USE_PORTAL = "1";
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-hyprland
        ];
      };
      environment.systemPackages = [
        pkgs.xdg-desktop-portal-hyprland
      ];

      programs.dconf.enable = true;
    };
  };
}
