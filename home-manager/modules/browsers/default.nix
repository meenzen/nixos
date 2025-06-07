{pkgs, ...}: let
  args = [
    # Chromium Wayland is broken, see https://github.com/NixOS/nixpkgs/issues/334175
    #"--enable-features=UseOzonePlatform,VaapiVideoDecodeLinuxGL"
    #"--ozone-platform=wayland"
    "--ignore-gpu-blocklist"
    "--enable-zero-copy"
  ];
in {
  home.packages = [
    pkgs.firefox

    # https://discourse.nixos.org/t/google-chrome-not-working-after-recent-nixos-rebuild/43746/8
    (pkgs.google-chrome.override {
      commandLineArgs = args;
    })

    # microsoft-edge # edge is totally borked right now
  ];

  programs.chromium = {
    enable = true;
    package = pkgs.brave.override {
      commandLineArgs = args;
    };
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
