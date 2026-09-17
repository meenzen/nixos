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
      signing.format = "openpgp";
      settings = {
        user = {
          name = systemConfig.user.fullName;
          email = systemConfig.user.email;
          signingkey = "/home/${systemConfig.user.username}/.ssh/id_ed25519_sk";
        };
        init.defaultBranch = "main";
        core.autocrlf = false;
        credential.helper = "libsecret";
        rerere.enabled = true;
        commit.gpgsign = true;
        gpg.format = "ssh";
      };
    };
    difftastic = {
      enable = true;
      git.enable = true;
    };
    mergiraf = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
    };
  };
}
