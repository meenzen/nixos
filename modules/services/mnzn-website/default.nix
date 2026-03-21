{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.mnzn-website;
  serviceName = "mnzn-website";
in {
  options.meenzen.services.mnzn-website = {
    enable = lib.mkEnableOption "Enable mnzn.dev Website";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "mnzn.dev";
      description = "Domain for mnzn.dev Website";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8093;
      description = "Local port for mnzn.dev Website";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      mnznWebsiteEnvironment = {
        file = "${inputs.self}/secrets/mnznWebsiteEnvironment.age";
      };
      mnznWebsitePostgresPassword = {
        file = "${inputs.self}/secrets/mnznWebsitePostgresPassword.age";
        owner = "postgres";
        group = "postgres";
      };
    };
    virtualisation.oci-containers.containers."${serviceName}" = {
      image = "ghcr.io/meenzen/website:0.1.57@sha256:7f148efacbb7b1e12521769ba169b6af1022b515b17143ed9dcf14c119d4caf9";
      ports = ["127.0.0.1:${toString cfg.port}:8080"];
      environment = {
        TZ = "UTC";
        LANG = "en_US.UTF-8";
        ASPNETCORE_FORWARDEDHEADERS_ENABLED = "true";
      };
      environmentFiles = [
        config.age.secrets.mnznWebsiteEnvironment.path
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
      password_file_path = config.age.secrets.mnznWebsitePostgresPassword.path;
    in ''
      psql -tA <<'EOF'
        DO $$
        DECLARE password TEXT;
        BEGIN
          password := trim(both from replace(pg_read_file('${password_file_path}'), E'\n', '''));
          EXECUTE format('ALTER ROLE "${serviceName}" WITH PASSWORD '''%s''';', password);
        END $$;
      EOF
    '';

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
      locations."/.well-known/matrix" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        extraConfig = ''
          add_header Content-Type application/json;
          add_header Access-Control-Allow-Origin *;
        '';
      };
    };
  };
}
