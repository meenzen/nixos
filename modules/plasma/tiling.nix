{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.plasma.tiling;
in {
  options.meenzen.plasma.tiling = {
    enable = lib.mkEnableOption "Enable Plasma Tiling";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kdePackages.krohnkite
    ];
  };
}
