{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    userName = "Samuel Meenzen";
    userEmail = "samuel@meenzen.net";
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      core.autocrlf = true;
      credential.helper = "libsecret";
      rerere.enabled = true;
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "/home/${config.home.username}/.ssh/id_ed25519_sk";
    };
  };
}
