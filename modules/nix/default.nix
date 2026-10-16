{
  lib,
  pkgs,
  config,
  ...
}: {
  # Allow installing unfree packages
  nixpkgs.config.allowUnfree = lib.mkForce true;

  nix = {
    settings = {
      # Additional Binary Cache
      substituters = ["https://nix-community.cachix.org"];
      trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
      trusted-users = ["root" "@wheel"];

      # Enable Flakes
      experimental-features = ["nix-command" "flakes"];
    };

    extraOptions = ''
      # Make debugging easier
      log-lines = 25

      # Make sure we don't run out of disk space when building
      min-free = 128000000
      max-free = 1000000000

      # Fall back to building from source if a binary cache is not available
      fallback = true
      connect-timeout = 5
    '';
  };

  # Print diff after rebuild
  system.activationScripts = {
    diff = ''
      if [[ -e /run/current-system ]]; then
        source "${../../bin/lib.sh}"
        PATH=$PATH:${lib.makeBinPath [config.nix.package]}
        print_divider_basic
        ${pkgs.nvd}/bin/nvd diff /run/current-system "$systemConfig" || true
        print_divider_basic
      fi
    '';
  };
}
