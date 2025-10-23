{
  config,
  pkgs,
  systemConfig,
  ...
}: {
  programs = {
    git = {
      enable = true;
      package = pkgs.gitFull;
      lfs.enable = true;
      settings = {
        user.name = systemConfig.user.fullName;
        user.email = systemConfig.user.email;
        init.defaultBranch = "main";
        core.autocrlf = false;
        credential.helper = "libsecret";
        rerere.enabled = true;
        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signingkey = "/home/${systemConfig.user.username}/.ssh/id_ed25519_sk";
      };
    };
    difftastic = {
      enable = true;
      git.enable = true;
    };
    mergiraf.enable = true;
  };
}
