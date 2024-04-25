{pkgs, ...}: {
  home.packages = with pkgs; [
    firefox

    # https://discourse.nixos.org/t/google-chrome-not-working-after-recent-nixos-rebuild/43746/8
    (google-chrome.override {
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    })

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
