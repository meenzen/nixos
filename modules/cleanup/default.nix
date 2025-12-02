{
  pkgs,
  inputs,
  ...
}: {
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
      pkgs.writeShellApplication {
        name = "cleanup-nix-store";
        text = ''
          ${inputs.self}/bin/optimize
        '';
      }
    )
  ];
}
