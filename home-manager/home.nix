{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common
    ./modules/desktop.nix
    ./modules/dev-tools.nix
    ./modules/system-tools.nix
    ./modules/nix-tools.nix
    ./modules/networking-tools.nix
    ./modules/git.nix
    ./modules/neovim.nix
    ./modules/starship.nix
    ./modules/wezterm.nix
    ./modules/shells.nix
    ./modules/ssh.nix
    ./modules/browsers.nix
    ./modules/gaming.nix
    ./modules/keepass.nix
    ./modules/fun.nix
    ./modules/media-player.nix
  ];

  nixpkgs = {
    overlays = [
      # tokei: add support for razor files, see https://github.com/XAMPPRocky/tokei/pull/992
      (final: prev: {
        tokei = prev.tokei.overrideAttrs (oldAttrs: rec {
          version = "latest-meenzen";
          src = prev.fetchFromGitHub {
            owner = "meenzen";
            repo = "tokei";
            rev = "d1845f54a9bbc0625e83f06556ebab44da9247c8";
            sha256 = "sha256-vQa0ZUxeD3Wj2PH7FLT/GLYl71xQKfKw7rPGS6Lk2JA=";
          };
          cargoDeps = oldAttrs.cargoDeps.overrideAttrs (lib.const {
            inherit src;
            outputHash = "sha256-QuXCl599e/dSuvC/U+eq95xtJnGvbVXYBHLwWgYIhck=";
          });
        });
      })
    ];
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };
}
