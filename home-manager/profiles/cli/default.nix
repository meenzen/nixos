{
  config,
  lib,
  ...
}: let
  cfg = config.meenzen.profiles.cli;
in {
  options.meenzen.profiles.cli = {
    enable = lib.mkEnableOption "command line tools and configuration" // {default = true;};
  };

  config = lib.mkIf cfg.enable {
    meenzen = {
      cleanup.enable = true;
      dev-tools.enable = true;
      fun.enable = true;
      git.enable = true;
      neovim.enable = true;
      nix-tools.enable = true;
      shells.enable = true;
      ssh.enable = true;
      starship.enable = true;
      system-tools.enable = true;
    };
  };
}
