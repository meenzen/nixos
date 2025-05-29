{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.cheshbot;
  serviceName = "cheshbot";
in {
  options.meenzen.cheshbot = {
    enable = lib.mkEnableOption "Enable CheshBot";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "bot.cheshires-wonderland.com";
      description = "Domain for CheshBot";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "Local port for CheshBot";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      cheshbotEnvironment = {
        file = "${inputs.self}/secrets/cheshbotEnvironment.age";
      };
      cheshbotPostgresPassword = {
        file = "${inputs.self}/secrets/cheshbotPostgresPassword.age";
        owner = "postgres";
        group = "postgres";
      };
    };

    virtualisation.oci-containers.containers."${serviceName}" = {
      image = "ghcr.io/meenzen/cheshbot:latest@sha256:8c1cf3283b7858bd9d08393f373ad30fc9cbf322e6b42ea73a906500799ca73c";
      ports = ["127.0.0.1:${toString cfg.port}:8080"];
      environment = {
        TZ = "UTC";
        LANG = "en_GB.UTF-8";
        "Serilog__WriteTo__0__Args__formatter" = "Serilog.Formatting.Compact.RenderedCompactJsonFormatter, Serilog.Formatting.Compact";
        "CheshBot__OpenAiModel" = "gpt-4o";
      };
      environmentFiles = [
        config.age.secrets.cheshbotEnvironment.path
      ];
      extraOptions = [
        "--add-host=host.docker.internal:host-gateway"
      ];
      login = {
        registry = config.meenzen.oci-containers.github.registry;
        username = config.meenzen.oci-containers.github.registryUser;
        passwordFile = config.age.secrets.githubRegistryPassword.path;
      };
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
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
    systemd.services.postgresql.postStart = let
      password_file_path = config.age.secrets.cheshbotPostgresPassword.path;
    in ''
      $PSQL -tA <<'EOF'
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
