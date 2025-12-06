{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.printing;
in {
  options.meenzen.printing = {
    enable = lib.mkEnableOption "Enable printing";
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        cups-filters
        cups-browsed
      ];
    };

    environment.systemPackages = with pkgs;
      lib.mkIf config.meenzen.plasma.enable [
        system-config-printer
        kdePackages.skanpage
      ];
  };
}
