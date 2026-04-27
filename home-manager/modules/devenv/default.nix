{pkgs, ...}: {
  home.packages = [
    pkgs.devenv
  ];
  programs.bash.initExtra = ''
    eval "$(devenv hook bash)"
  '';
  programs.zsh.initContent = ''
    eval "$(devenv hook zsh)"
  '';
  programs.fish.interactiveShellInit = ''
    devenv hook fish | source
  '';
  programs.nushell.extraConfig = ''
    devenv hook nu | save --force ~/.cache/devenv/hook.nu
    source ~/.cache/devenv/hook.nu
  '';
}
