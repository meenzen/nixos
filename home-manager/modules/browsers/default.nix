{
  lib,
  config,
  pkgs,
  ...
}: let
  args = [
    "--enable-features=UseOzonePlatform,VaapiVideoDecodeLinuxGL"
    "--ozone-platform=wayland"
    "--ignore-gpu-blocklist"
    "--enable-zero-copy"
  ];
in {
  options.meenzen.browsers.enable = lib.mkEnableOption "web browsers";

  config = lib.mkIf config.meenzen.browsers.enable {
    home.packages = [
      pkgs.firefox

      (pkgs.google-chrome.override {
        commandLineArgs = args;
      })
    ];

    programs.chromium = {
      enable = true;
      package = pkgs.brave-origin.override {
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
  };
}
