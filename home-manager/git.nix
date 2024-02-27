{
  programs.git = {
    enable = true;
    userName = "Samuel Meenzen";
    userEmail = "samuel@meenzen.net";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      rerere = {
        enabled = true;
      };
    };
  };
}
