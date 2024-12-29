{pkgs, ...}: {
  # Automatic garbage collection for user profile
  nix.gc = {
    automatic = true;
    frequency = "weekly";
    options = "--delete-older-than 7d";
  };
}
