{
  # ZSH
  programs.zsh.enable = true;
  # Make completions work
  environment.pathsToLink = ["/share/zsh"];

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
  };
}
