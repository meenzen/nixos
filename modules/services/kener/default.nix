{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.kener;
  serviceName = "kener";
in {
  options.meenzen.services.kener = {
    # https://kener.ing/
    enable = lib.mkEnableOption "Enable Kener Status Page";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "status.mnzn.dev";
      description = "Domain for Kener";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8084;
      description = "Local port for Kener";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      kenerEnvironment = {
        file = "${inputs.self}/secrets/kenerEnvironment.age";
      };
      kenerPostgresPassword = {
        file = "${inputs.self}/secrets/kenerPostgresPassword.age";
        owner = "postgres";
        group = "postgres";
      };
    };

    virtualisation.oci-containers.containers."${serviceName}" = {
      image = "ghcr.io/rajnandan1/kener:4.0.0@sha256:c1b388a111f2bee39a557662f3e674cb7ed3afdfa05411261c5e698a2d66c131";
      ports = ["127.0.0.1:${toString cfg.port}:3000"];
      volumes = [
        "${serviceName}-uploads:/app/uploads"
      ];
      environment = {
        TZ = "UTC";
        ORIGIN = "https://${cfg.domain}";
      };
      environmentFiles = [
        config.age.secrets.kenerEnvironment.path
      ];
      extraOptions = [
        "--add-host=host.docker.internal:host-gateway"
      ];
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };

    meenzen.postgresql = {
      enable = true;
      enableLocalNetwork = true;
    };
    services.postgresql = {
      ensureUsers = [
        {
          name = serviceName;
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [serviceName];
    };

    # workaround until https://github.com/NixOS/nixpkgs/pull/326306 is merged
    systemd.services.postgresql-setup.postStart = let
      password_file_path = config.age.secrets.kenerPostgresPassword.path;
    in ''
      psql -tA <<'EOF'
        DO $$
        DECLARE password TEXT;
        BEGIN
          password := trim(both from replace(pg_read_file('${password_file_path}'), E'\n', '''));
          EXECUTE format('ALTER ROLE ${serviceName} WITH PASSWORD '''%s''';', password);
        END $$;
      EOF
    '';
  };
}
