{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.fish;
in {
  options.meenzen.fish = {
    enable = lib.mkEnableOption "fish shell";
    default = lib.mkEnableOption "fish as the default shell";
  };

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;
    users.users = lib.mkIf cfg.default {
      "${config.meenzen.user.username}" = {
        shell = pkgs.fish;
      };
    };
  };
}
