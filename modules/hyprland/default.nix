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
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
    networking.networkmanager.enable = true;
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
  };
}
