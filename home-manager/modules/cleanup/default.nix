{pkgs, ...}: {
  # Automatic garbage collection for user profile
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
