{pkgs, ...}: {
  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Deduplicate and optimize nix store
  nix.settings.auto-optimise-store = true;

  environment.systemPackages = [
    (
      pkgs.writeScriptBin "cleanup-nix-store" ''
        set -eux

        nix-collect-garbage --delete-older-than 7d
        sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2
        sudo nix-collect-garbage --delete-older-than 7d
        sudo nix-store --optimise
      ''
    )
  ];
}
