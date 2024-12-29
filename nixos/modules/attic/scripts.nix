{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.attic-client
    (
      pkgs.writeScriptBin "attic-login" ''
        set -e
        if [ -z "$1" ]; then
          echo "Usage: $0 <token>"
          exit 1
        fi
        attic login meenzen https://attic.mnzn.dev $@
      ''
    )
    (
      pkgs.writeScriptBin "attic-push-path" ''
        set -e
        if [ -z "$1" ]; then
          echo "Usage: $0 <path>"
          echo "Example: $0 \$(which bash)"
          exit 1
        fi
        attic push meenzen:main $@
      ''
    )
    (
      pkgs.writeScriptBin "attic-push-system" ''
        set -eux
        attic push meenzen:main /run/current-system $@
      ''
    )
    (
      pkgs.writeScriptBin "attic-push-everything" ''
        set -e
        nix path-info --all | ${pkgs.gnugrep}/bin/grep --invert '\.drv$' | attic push meenzen:main --stdin $@
      ''
    )
  ];
}
