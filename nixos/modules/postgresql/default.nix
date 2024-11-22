{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.postgresql;
in {
  options.custom.postgresql = {
    enable = lib.mkEnableOption "Enable PostgreSQL";
    enableMajorUpgrade = lib.mkEnableOption "Enable Major Upgrade";
    enableLocalNetwork = lib.mkEnableOption "Allow password-based authentication for private networks";
  };

  config = lib.mkIf cfg.enable {
    services.postgresql =
      {
        enable = true;
        package = pkgs.postgresql_16;
        settings = {
          # https://pgtune.leopard.in.ua/
          # DB Version: 16
          # OS Type: linux
          # DB Type: web
          # Total Memory (RAM): 16 GB
          # CPUs num: 8
          # Data Storage: ssd
          max_connections = 200;
          shared_buffers = "4GB";
          effective_cache_size = "12GB";
          maintenance_work_mem = "1GB";
          checkpoint_completion_target = 0.9;
          wal_buffers = "16MB";
          default_statistics_target = 100;
          random_page_cost = 1.1;
          effective_io_concurrency = 200;
          work_mem = "5242kB";
          huge_pages = "off";
          min_wal_size = "1GB";
          max_wal_size = "4GB";
          max_worker_processes = 8;
          max_parallel_workers_per_gather = 4;
          max_parallel_workers = 8;
          max_parallel_maintenance_workers = 4;
        };
      }
      // lib.optionalAttrs cfg.enableLocalNetwork {
        enableTCPIP = true;
        authentication = ''
          # Allow password-based authentication for private networks
          host  all all 10.0.0.0/8 md5
          host  all all 172.16.0.0/12 md5
          host  all all 192.168.0.0/16 md5
        '';
      };
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.enableLocalNetwork [5432];

    # Major Upgrade Docs: https://nixos.org/manual/nixos/stable/#module-services-postgres-upgrading
    environment.systemPackages = lib.mkIf cfg.enableMajorUpgrade [
      (let
        # Specify the postgresql package you'd like to upgrade to.
        # Do not forget to list the extensions you need.
        newPostgres = pkgs.postgresql_16;
      in
        pkgs.writeScriptBin "upgrade-pg-cluster" ''
          set -eux
          # It's perhaps advisable to stop all services that depend on postgresql
          systemctl stop postgresql

          export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"

          export NEWBIN="${newPostgres}/bin"

          export OLDDATA="${config.services.postgresql.dataDir}"
          export OLDBIN="${config.services.postgresql.package}/bin"

          install -d -m 0700 -o postgres -g postgres "$NEWDATA"
          cd "$NEWDATA"
          sudo -u postgres $NEWBIN/initdb -D "$NEWDATA"

          sudo -u postgres $NEWBIN/pg_upgrade \
            --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
            --old-bindir $OLDBIN --new-bindir $NEWBIN \
            "$@"
        '')
    ];
  };
}