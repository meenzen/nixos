{
  # ZSH
  programs.zsh.enable = true;
  environment.pathsToLink = ["/share/zsh"];

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
