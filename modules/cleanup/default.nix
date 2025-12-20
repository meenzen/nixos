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

  # cleanup gc roots
  services.angrr = {
    enable = true;
    enableNixGcIntegration = true;
    settings = {
      temporary-root-policies = {
        direnv = {
          path-regex = "/\\.direnv/";
          period = "14d";
        };
        result = {
          path-regex = "/result[^/]*$";
          period = "3d";
        };
      };
      profile-policies = {
        system = {
          profile-paths = ["/nix/var/nix/profiles/system"];
          keep-since = "14d";
          keep-latest-n = 10;
          keep-booted-system = true;
          keep-current-system = true;
        };
      };
    };
  };
  programs.direnv.angrr.autoUse = true;
}
