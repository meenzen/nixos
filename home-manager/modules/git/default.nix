{
  osConfig,
  pkgs,
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
          name = osConfig.meenzen.user.fullName;
          email = osConfig.meenzen.user.email;
          signingkey = "/home/${osConfig.meenzen.user.username}/.ssh/id_ed25519_sk";
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
