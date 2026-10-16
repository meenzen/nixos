{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.zsh;
in {
  options.meenzen.zsh = {
    enable = lib.mkEnableOption "Enable zsh";
    default = lib.mkEnableOption "Make zsh the default shell";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;

    # make completions work
    environment.pathsToLink = ["/share/zsh"];

    users.users = lib.mkIf cfg.default {
      "${config.meenzen.user.username}" = {
        shell = pkgs.zsh;
      };
    };
  };
}
