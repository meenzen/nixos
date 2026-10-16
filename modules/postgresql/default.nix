{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.postgresql;
  privateNetworks = ["10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"];

  # Formats a size in kB the way pgtune does, using the largest unit that divides it.
  formatKB = kb:
    if lib.mod kb (1024 * 1024) == 0
    then "${toString (kb / (1024 * 1024))}GB"
    else if lib.mod kb 1024 == 0
    then "${toString (kb / 1024)}MB"
    else "${toString kb}kB";

  # https://pgtune.leopard.in.ua/ with DB Type "web", OS Type "linux" and Data Storage "ssd".
  tuning = let
    inherit (cfg.tuning) memoryGB cpus maxConnections;
    memoryKB = memoryGB * 1024 * 1024;
    sharedBuffersKB = memoryKB / 4;
    halfCpus = lib.min 4 ((cpus + 1) / 2);
  in
    {
      max_connections = maxConnections;
      shared_buffers = formatKB sharedBuffersKB;
      effective_cache_size = formatKB (memoryKB * 3 / 4);
      maintenance_work_mem = formatKB (lib.min (2 * 1024 * 1024) (memoryKB / 16));
      wal_buffers = formatKB (lib.max 32 (lib.min (16 * 1024) (sharedBuffersKB * 3 / 100)));
      work_mem = formatKB (lib.max 64 ((memoryKB - sharedBuffersKB) / ((maxConnections + cpus) * 3)));
      huge_pages =
        if memoryGB >= 32
        then "try"
        else "off";
    }
    # pgtune only configures parallel workers with at least 4 CPUs.
    // lib.optionalAttrs (cpus >= 4) {
      max_worker_processes = cpus;
      max_parallel_workers_per_gather = halfCpus;
      max_parallel_workers = cpus;
      max_parallel_maintenance_workers = halfCpus;
    };
in {
  options.meenzen.postgresql = {
    enable = lib.mkEnableOption "PostgreSQL";
    enableMajorUpgrade = lib.mkEnableOption "Major Upgrade";
    enableLocalNetwork = lib.mkEnableOption "password-based authentication for private networks";
    passwordFiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {};
      example = lib.literalExpression ''{ myapp = config.age.secrets.myappPostgresPassword.path; }'';
      description = "Files containing the password for each role, set on every start. The files must be readable by the postgres user.";
    };
    tuning = {
      memoryGB = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        example = 16;
        description = "Memory available to PostgreSQL in GB. If null, the memory and CPU related settings keep PostgreSQL's defaults.";
      };
      cpus = lib.mkOption {
        type = lib.types.ints.positive;
        default = 4;
        description = "Number of CPUs available to PostgreSQL.";
      };
      maxConnections = lib.mkOption {
        type = lib.types.ints.positive;
        default = 100;
        description = "Maximum number of client connections.";
      };
    };
  };

  imports = [./scripts.nix];

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enableLocalNetwork -> !config.networking.nftables.enable;
        message = "meenzen.postgresql.enableLocalNetwork opens port 5432 with iptables rules, which don't apply with networking.nftables.enable.";
      }
    ];

    services.postgresql =
      {
        enable = true;
        package = pkgs.postgresql_18;
        settings =
          {
            # Make it go fast
            io_method = "io_uring";

            # https://pgtune.leopard.in.ua/, the settings that don't depend on the hardware
            checkpoint_completion_target = 0.9;
            default_statistics_target = 100;
            random_page_cost = 1.1;
            effective_io_concurrency = 200;
            min_wal_size = "1GB";
            max_wal_size = "4GB";
          }
          // lib.optionalAttrs (cfg.tuning.memoryGB != null) tuning;
      }
      // lib.optionalAttrs cfg.enableLocalNetwork {
        enableTCPIP = true;
        authentication =
          ''
            # Allow password-based authentication for private networks
          ''
          + lib.concatMapStrings (network: "host  all all ${network} md5\n") privateNetworks;
      };
    # Only open the port to the same private networks, not to the public internet.
    networking.firewall.extraCommands = lib.mkIf cfg.enableLocalNetwork (lib.concatMapStrings (network: ''
        iptables -A nixos-fw -p tcp -s ${network} --dport 5432 -j nixos-fw-accept
      '')
      privateNetworks);

    # Replace with ensureUsers.*.passwordFile once https://github.com/NixOS/nixpkgs/pull/326306 is merged
    systemd.services.postgresql-setup.postStart = let
      setPassword = role: file: ''
        password := trim(both from replace(pg_read_file('${file}'), E'\n', '''));
        EXECUTE format('ALTER ROLE %I WITH PASSWORD %L', '${role}', password);
      '';
    in
      lib.mkIf (cfg.passwordFiles != {}) ''
        psql -tA <<'EOF'
        DO $$
        DECLARE password TEXT;
        BEGIN
        ${lib.concatStrings (lib.mapAttrsToList setPassword cfg.passwordFiles)}
        END $$;
        EOF
      '';

    # Raise the open file limit for the PostgreSQL service
    # This is required with io_uring, otherwise 'could not setup io_uring queue: Too many open files' errors may occur
    systemd.services.postgresql.serviceConfig.LimitNOFILE = 65536;

    services.postgresqlBackup = {
      enable = true;
      backupAll = true;
    };
    meenzen.backup.paths = [config.services.postgresqlBackup.location];

    # Major Upgrade Docs: https://nixos.org/manual/nixos/unstable/#module-services-postgres-upgrading
    environment.systemPackages = lib.mkIf cfg.enableMajorUpgrade [
      (let
        # Specify the postgresql package you'd like to upgrade to.
        # Do not forget to list the extensions you need.
        newPostgres = pkgs.postgresql_18;
      in
        pkgs.writeShellApplication {
          name = "postgres-upgrade-cluster";
          text = ''
            set -eux
            # It's perhaps advisable to stop all services that depend on postgresql
            systemctl stop postgresql

            export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"
            export NEWBIN="${newPostgres}/bin"

            export OLDDATA="${config.services.postgresql.dataDir}"
            export OLDBIN="${config.services.postgresql.package}/bin"

            # Enable checksums
            echo "You can enable checksums using this command: 'sudo -u postgres $OLDBIN/pg_checksums --pgdata=\"$OLDDATA\" --enable --progress --verbose'"

            read -p "This will upgrade the postgresql cluster in $OLDDATA to ${newPostgres.version} and store the new cluster in $NEWDATA. Do you want to continue? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]
            then
                exit 1
            fi

            install -d -m 0700 -o postgres -g postgres "$NEWDATA"
            cd "$NEWDATA"
            sudo -u postgres $NEWBIN/initdb -D "$NEWDATA"

            sudo -u postgres $NEWBIN/pg_upgrade \
              --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
              --old-bindir $OLDBIN --new-bindir $NEWBIN \
              "$@"

            echo "Run these commands after starting the new cluster:"
            echo "  sudo -u postgres vacuumdb --all --analyze-in-stages"
            echo "  sudo -u postgres vacuumdb --all --analyze-only"
          '';
        })
    ];
  };
}
