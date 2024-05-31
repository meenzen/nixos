{
  home = {
    username = "meenzens";
    homeDirectory = "/home/meenzens";

    # Environt Variables
    sessionVariables = {
      GITLAB_HOST = "https://git.human.de";
      ANSIBLE_NOCOWS = "1";
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.11";
  };

  programs.home-manager.enable = true;

  # automatically reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
