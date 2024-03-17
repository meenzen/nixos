{
  # ZSH
  programs.zsh.enable = true;
  environment.pathsToLink = ["/share/zsh"];

  programs.ssh.startAgent = true;
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
  };
}
