{pkgs, ...}: {
  home.packages = with pkgs; [
    firefox
    google-chrome
    # microsoft-edge # edge is totally borked right now
  ];

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      # Bypass Paywalls Chrome Clean
      {
        id = "lkbebcjgcmobigpeffafkodonchffocl";
        updateUrl = "https://gitlab.com/magnolia1234/bypass-paywalls-chrome-clean/-/raw/master/updates.xml";
      }
      # AdNauseam
      {
        id = "dkoaabhijcomjinndlgbmfnmnjnmdeeb";
        updateUrl = "https://rednoise.org/adnauseam/updates.xml";
      }
    ];
  };
}
