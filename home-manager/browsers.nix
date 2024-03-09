{pkgs, ...}: {
  home.packages = with pkgs; [
    firefox
    microsoft-edge
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
