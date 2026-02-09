{
  config,
  lib,
  pkgs,
  systemConfig,
  ...
}: let
  cfg = config.meenzen.fish;
in {
  options.meenzen.fish = {
    enable = lib.mkEnableOption "Enable fish shell";
    default = lib.mkEnableOption "Make fish the default shell";
  };

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;
    users.users = lib.mkIf cfg.default {
      "${systemConfig.user.username}" = {
        shell = pkgs.fish;
      };
    };
  };
}
