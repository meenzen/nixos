{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.programs;
in {
  options.meenzen.programs = {
    enable = lib.mkEnableOption "Enable Programs";
  };

  config = lib.mkIf cfg.enable {
    # ZSH
    programs.zsh.enable = true;
    # Make completions work
    environment.pathsToLink = ["/share/zsh"];

    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
    };
  };
}
