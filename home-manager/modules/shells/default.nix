{
  config,
  inputs,
  lib,
  ...
}: let
  aliases = {
    nano = "nvim";
    vi = "nvim";
    vim = "nvim";
    top = "htop";
    grep = "rg";
    cat = "bat";
    weather = "curl wttr.in/Wiesbaden";
    lolcat = "clolcat";
    neofetch = "fastfetch";
    fuck = "f";
  };
in {
  imports = [inputs.nix-index-database.homeModules.nix-index];

  options.meenzen.shells.enable = lib.mkEnableOption "shell configuration";

  config = lib.mkMerge [
    {
      # Command-not-found handler and package suggestions for pay-respects, using the prebuilt nix-index-database.
      # Importing nix-index-database enables nix-index by default, so follow this module instead.
      programs.nix-index.enable = config.meenzen.shells.enable;
    }
    (lib.mkIf config.meenzen.shells.enable {
      programs = {
        bash = {
          enable = true;
          enableCompletion = true;
          shellAliases = aliases;
        };

        fish = {
          enable = true;
          shellAliases = aliases;
          binds = {
            # Ctrl + Backspace to delete word
            "ctrl-h".command = "backward-kill-word";
          };
          interactiveShellInit = ''
            # Disable default greeting message
            set fish_greeting
          '';
        };

        nushell.enable = true;

        # smarter cd command
        zoxide = {
          enable = true;
          options = ["--cmd cd"];
        };

        # command autocorrect
        pay-respects.enable = true;

        # direnv / devenv
        direnv.enable = true;
        direnv.nix-direnv.enable = true;
        devenv.enable = true;
      };
    })
  ];
}
