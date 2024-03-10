{
  home = {
    username = "meenzens";
    homeDirectory = "/home/meenzens";

    # Environt Variables
    sessionVariables = {
      GITLAB_HOST = "https://git.human.de";
      ANSIBLE_NOCOWS = "1";
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.11";
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
