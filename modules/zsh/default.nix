{
  config,
  lib,
  pkgs,
  systemConfig,
  ...
}: let
  cfg = config.meenzen.zsh;
in {
  options.meenzen.zsh = {
    enable = lib.mkEnableOption "Enable zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;

    # make completions work
    environment.pathsToLink = ["/share/zsh"];

    users.users = {
      "${systemConfig.user.username}" = {
        shell = pkgs.zsh;
      };
    };
  };
}
