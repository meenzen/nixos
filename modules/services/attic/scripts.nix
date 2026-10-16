{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.attic-client
    (
      pkgs.writeShellApplication {
        name = "attic-login";
        text = ''
          if [ -z "''${1-}" ]; then
            echo "Usage: $0 <token>"
            exit 1
          fi
          attic login meenzen https://attic.mnzn.dev "$@"
        '';
      }
    )
    (
      pkgs.writeShellApplication {
        name = "attic-push-path";
        text = ''
          if [ -z "''${1-}" ]; then
            echo "Usage: $0 <path>"
            echo "Example: $0 \$(which bash)"
            exit 1
          fi
          attic push meenzen:main "$@"
        '';
      }
    )
    (
      pkgs.writeShellApplication {
        name = "attic-push-system";
        text = ''
          attic push meenzen:main /run/current-system "$@"
        '';
      }
    )
    (
      pkgs.writeShellApplication {
        name = "attic-push-everything";
        text = ''
          nix path-info --all | ${pkgs.gnugrep}/bin/grep --invert '\.drv$' | attic push meenzen:main --stdin "$@"
        '';
      }
    )
  ];
}
