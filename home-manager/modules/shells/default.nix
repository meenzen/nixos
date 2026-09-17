let
  aliases = {
    nano = "nvim";
    vi = "nvim";
    vim = "nvim";
    ls = "exa";
    top = "htop";
    grep = "rg";
    cat = "bat";
    weather = "curl wttr.in/Wiesbaden";
    lolcat = "clolcat";
    neofetch = "fastfetch";
    fuck = "f";
  };
in
  {pkgs, ...}: {
    programs = {
      bash = {
        enable = true;
        enableCompletion = true;
        shellAliases = aliases;
      };

      zsh = {
        enable = true;
        autosuggestion.enable = true;
        enableCompletion = true;
        syntaxHighlighting = {
          enable = true;
        };
        oh-my-zsh = {
          plugins = ["git" "sudo" "docker"];
        };
        shellAliases = aliases;
        plugins = [
          {
            name = "vi-mode";
            src = pkgs.zsh-vi-mode;
            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          }
        ];
        initContent = ''
          zstyle ':completion:*' menu select

          bindkey "^[[1;5C" forward-word
          bindkey "^[[1;5D" backward-word
          bindkey "^H" backward-kill-word
          bindkey "^[[OH" beginning-of-line
          bindkey "^[[OF" end-of-line
        '';
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

    home.packages = [
      # better pay-respects results
      pkgs.nix-index
    ];
  }
