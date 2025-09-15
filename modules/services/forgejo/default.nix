{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.forgejo;
in {
  options.meenzen.services.forgejo = {
    enable = lib.mkEnableOption "Enable Forgejo";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "forge.mnzn.dev";
      description = "Domain for Forgejo";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8086;
      description = "Local port for Forgejo";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      forgejoS3Key = {
        file = "${inputs.self}/secrets/forgejoS3Key.age";
      };
      forgejoS3Secret = {
        file = "${inputs.self}/secrets/forgejoS3Secret.age";
      };
    };

    meenzen.backup.paths = [config.services.forgejo.stateDir];

    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;
      database.type = "postgres";
      lfs.enable = true;
      settings = {
        server = {
          DOMAIN = cfg.domain;
          ROOT_URL = "https://${cfg.domain}/";
          HTTP_PORT = cfg.port;
        };
        session.COOKIE_SECURE = true;
        # disable registration, create users using the cli
        service.DISABLE_REGISTRATION = true;
        actions = {
          ENABLED = true;
          DEFAULT_ACTIONS_URL = "github";
        };
        storage = {
          STORAGE_TYPE = "minio";
          MINIO_ENDPOINT = "hel1.your-objectstorage.com";
          MINIO_BUCKET = "meenzen-forgejo";
          MINIO_LOCATION = "hel1";
          MINIO_USE_SSL = true;
          SERVE_DIRECT = false;
        };
        "repository.signing".DEFAULT_TRUST_MODEL = "committer";
        picture.ENABLE_FEDERATED_AVATAR = true;
        federation.ENABLED = true;
      };
      secrets = {
        storage = {
          MINIO_ACCESS_KEY_ID = config.age.secrets.forgejoS3Key.path;
          MINIO_SECRET_ACCESS_KEY = config.age.secrets.forgejoS3Secret.path;
        };
      };
    };

    environment.systemPackages = let
      cfg = config.services.forgejo;
      forgejo-wrapper = pkgs.writeShellApplication {
        name = "forgejo-wrapper";
        runtimeInputs = [pkgs.coreutils];
        text = ''
          cd ${cfg.stateDir}
          sudo="exec"
          if [[ "$USER" != forgejo ]]; then
            sudo='exec /run/wrappers/bin/sudo -u ${cfg.user} -g ${cfg.group}'
          fi

          # if no subcommand is given, use "help" as default so we don't start the server by accident
          if [ $# -eq 0 ]; then
            set -- help
          fi

          $sudo env \
            GITEA_WORK_DIR="${cfg.stateDir}" \
            GITEA_CUSTOM="${cfg.customDir}" \
            FORGEJO_WORK_DIR="${cfg.stateDir}" \
            FORGEJO_CUSTOM="${cfg.customDir}" \
            ${lib.getExe cfg.package} "$@"
        '';
      };
    in [
      forgejo-wrapper
    ];

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      extraConfig = ''
        client_max_body_size 512M;
      '';
      locations."/".proxyPass = "http://localhost:${toString cfg.port}";
    };
  };
}
