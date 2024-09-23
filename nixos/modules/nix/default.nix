{lib, ...}: {
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
      # Allow installing unfree packages
      allowUnfree = true;
      # see https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # Additional Binary Cache
  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://crane.cachix.org"
      "https://attic.conduit.rs/conduit"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
      "conduit:ddcaWZiWm0l0IXZlO8FERRdWvEufwmd0Negl1P+c0Ns="
    ];
  };

  nix.extraOptions = ''
    # Make debugging easier
    log-lines = 25

    # Make sure we don't run out of disk space when building
    min-free = 128000000
    max-free = 1000000000

    # Fall back to building from source if a binary cache is not available
    fallback = true
    connect-timeout = 5
  '';

  # Enable Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];
}
