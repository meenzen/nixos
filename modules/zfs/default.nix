{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = lib.mkIf config.boot.zfs.enabled [
    (
      pkgs.writeShellApplication {
        name = "zfs-update-pool";
        runtimeInputs = [config.boot.zfs.package];
        text = ''
          if [ "$(id -u)" -ne 0 ]; then
            exec sudo "$0" "$@"
          fi

          if [ -n "''${1-}" ]; then
            pool="$1"
          else
            mapfile -t pools < <(zpool list -H -o name)
            if [ "''${#pools[@]}" -eq 0 ]; then
              echo "No zfs pools found"
              exit 1
            elif [ "''${#pools[@]}" -eq 1 ]; then
              pool="''${pools[0]}"
            else
              PS3="Select pool: "
              select pool in "''${pools[@]}"; do
                [ -n "$pool" ] && break
              done
              [ -n "''${pool-}" ] || exit 1
            fi
          fi

          echo "=> Updating pool: $pool"
          set -x
          zfs set atime=off "$pool"
          zpool set autotrim=on "$pool"
          zpool upgrade "$pool"
          zpool trim "$pool"
          zpool status -t "$pool"
        '';
      }
    )
  ];
}
