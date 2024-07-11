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
  };
in
  {pkgs, ...}: {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = aliases;
    };

    programs.zsh = {
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
      initExtra = ''
        zstyle ':completion:*' menu select

        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        bindkey "^H" backward-kill-word
        bindkey "^[[OH" beginning-of-line
        bindkey "^[[OF" end-of-line
      '';
    };

    programs.fish.enable = true;
    programs.nushell.enable = true;

    # smarter cd command
    programs.zoxide = {
      enable = true;
      options = ["--cmd cd"];
    };

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
  }
