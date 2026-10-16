{
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;

  # automatically reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
