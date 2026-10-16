{
  config,
  lib,
  pkgs,
  secrets,
  ...
}: let
  cfg = config.meenzen.services.cheshbot;
  serviceName = "cheshbot";
in {
  options.meenzen.services.cheshbot = {
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
    meenzen = {
      nginx.enable = true;
      oci-containers.enable = true;
      postgresql = {
        enable = true;
        enableLocalNetwork = true;
        passwordFiles.${serviceName} = config.age.secrets.cheshbotPostgresPassword.path;
      };
    };

    age.secrets = {
      cheshbotEnvironment = {
        file = "${secrets}/cheshbotEnvironment.age";
        restartUnits = ["${config.virtualisation.oci-containers.containers.${serviceName}.serviceName}.service"];
      };
      cheshbotPostgresPassword = {
        file = "${secrets}/cheshbotPostgresPassword.age";
        restartUnits = ["postgresql-setup.service"];
        owner = "postgres";
        group = "postgres";
      };
    };

    virtualisation.oci-containers.containers."${serviceName}" = {
      image = "ghcr.io/meenzen/cheshbot:latest@sha256:49975a9380fc89a8859f3db2a971237e3c6c016759531a8b73c7c17d21937e28";
      ports = ["127.0.0.1:${toString cfg.port}:8080"];
      environment = {
        TZ = "UTC";
        LANG = "en_GB.UTF-8";
        "Serilog__WriteTo__0__Args__formatter" = "Serilog.Formatting.Compact.RenderedCompactJsonFormatter, Serilog.Formatting.Compact";
        "CheshBot__OpenAiModel" = "gpt-4o";
        ASPNETCORE_FORWARDEDHEADERS_ENABLED = "true";
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

    # The image has no HEALTHCHECK and no curl, so wait for the health endpoint from the host. The unit only counts as
    # started, and the deployment only succeeds, once the application is serving requests.
    systemd.services.${config.virtualisation.oci-containers.containers.${serviceName}.serviceName}.serviceConfig = {
      ExecStartPost = "${lib.getExe pkgs.curl} --fail --silent --show-error --output /dev/null --max-time 5 --retry 25 --retry-delay 5 --retry-all-errors http://127.0.0.1:${toString cfg.port}/health";
      # The upstream module disables the start timeout, which would block deployments forever.
      TimeoutStartSec = lib.mkForce "5min";
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
      extraConfig = ''
        add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
      '';
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
  };
}
