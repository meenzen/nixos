{
  pkgs,
  systemConfig,
  ...
}: {
  programs.zsh.enable = true;

  # make completions work
  environment.pathsToLink = ["/share/zsh"];

  users.users = {
    "${systemConfig.user.username}" = {
      shell = pkgs.zsh;
    };
  };
}
