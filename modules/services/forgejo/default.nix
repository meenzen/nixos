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
      forgejo-wrapper = pkgs.writeScriptBin "forgejo-wrapper" ''
        #!${pkgs.runtimeShell}
        cd ${cfg.stateDir}
        sudo=exec
        if [[ "$USER" != forgejo ]]; then
          sudo='exec /run/wrappers/bin/sudo -u ${cfg.user} -g ${cfg.group} --preserve-env=GITEA_WORK_DIR --preserve-env=GITEA_CUSTOM --preserve-env=FORGEJO_WORK_DIR --preserve-env=FORGEJO_CUSTOM'
        fi
        export GITEA_WORK_DIR=${cfg.stateDir}
        export GITEA_CUSTOM=${cfg.customDir}
        export FORGEJO_WORK_DIR=${cfg.stateDir}
        export FORGEJO_CUSTOM=${cfg.customDir}

        # if no subcommand is given, use "help" as default so we don't start the server by accident
        if [ $# -eq 0 ]; then
          set -- help
        fi

        $sudo ${lib.getExe cfg.package} "$@"
      '';
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
