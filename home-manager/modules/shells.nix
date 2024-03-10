let
  aliases = {
    nano = "nvim";
    vi = "nvim";
    vim = "nvim";
    ls = "exa";
    top = "htop";
    grep = "rg";
    weather = "curl wttr.in/Wiesbaden";
    lolcat = "clolcat";
  };
in {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin"
      # dotnet
      export PATH=$PATH:$HOME/dotnet
      export PATH=$PATH:$HOME/.dotnet/tools
      export DOTNET_ROOT=$HOME/dotnet
    '';
    shellAliases = aliases;
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting = {
      enable = true;
    };
    oh-my-zsh = {
      plugins = ["git" "sudo" "docker"];
    };
    shellAliases = aliases;
  };

  programs.fish.enable = true;
  programs.nushell.enable = true;

  # marter cd command
  programs.zoxide = {
    enable = true;
    options = ["--cmd cd"];
  };
}
