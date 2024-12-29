{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = lib.mkIf config.services.postgresql.enable [
    (
      # https://wiki.postgresql.org/wiki/Disk_Usage
      pkgs.writeScriptBin "postgres-list-database-sizes" ''
        set -eu
        echo "Top 20 databases by size:"
        sudo -u postgres psql << EOF
          SELECT d.datname as Name,  pg_catalog.pg_get_userbyid(d.datdba) as Owner,
              CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
                  THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
                  ELSE 'No Access'
              END as Size
          FROM pg_catalog.pg_database d
              order by
              CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
                  THEN pg_catalog.pg_database_size(d.datname)
                  ELSE NULL
              END desc -- nulls first
              LIMIT 20;
        EOF
      ''
    )
    (
      pkgs.writeScriptBin "postgres-vacuum-full" ''
        set -eu

        LIGHT_BLUE='\033[1;34m'
        NO_COLOR='\033[0m'
        print () {
          echo -e "''${LIGHT_BLUE}$1''${NO_COLOR}"
        }

        print "=> Loading databases..."
        databases=$(sudo -u postgres psql -d postgres -Atc "SELECT datname FROM pg_database WHERE datname NOT IN ('template0', 'template1');")

        for db in $databases; do
          print "==> Vacuuming database: $db"
          sudo -u postgres psql -d "$db" -c "VACUUM FULL VERBOSE;"
        done
      ''
    )
  ];
}
