{
  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  # Deduplicate and optimize nix store
  nix.settings.auto-optimise-store = true;
}
