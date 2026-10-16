{
  config,
  lib,
  ...
}: {
  options.meenzen.cleanup.enable = lib.mkEnableOption "automatic garbage collection of the user profile";

  config = lib.mkIf config.meenzen.cleanup.enable {
    # Automatic garbage collection for user profile
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
