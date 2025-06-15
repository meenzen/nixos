{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.remote-desktop;
in {
  options.meenzen.remote-desktop = {
    enable = lib.mkEnableOption "Enable Remote Desktop";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.kdePackages.krdc
      pkgs.rustdesk-flutter
    ];
  };
}
