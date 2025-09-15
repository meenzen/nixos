{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.gitlab.registry;
  serviceName = "docker-registry";
  databaseConfig = {
    enabled = true;
    host = "/var/run/postgresql";
    dbname = serviceName;
  };
  registryBin = "${config.services.dockerRegistry.package}/bin/registry";
in {
  options.meenzen.services.gitlab.registry = {
    enable = lib.mkEnableOption "Enable GitLab registry";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "registry.mnzn.dev";
      description = "Domain for GitLab registry";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 5000;
      description = "Local port for GitLab registry";
    };
    certDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/gitlab-registry";
      description = "Directory for GitLab registry certificates";
    };
    s3 = {
      bucket = lib.mkOption {
        type = lib.types.str;
        default = "meenzen-gitlab-registry";
        description = "S3 bucket for GitLab registry";
      };
      region = lib.mkOption {
        type = lib.types.str;
        default = "hel1";
        description = "S3 region for GitLab registry";
      };
      regionEndpoint = lib.mkOption {
        type = lib.types.str;
        default = "https://hel1.your-objectstorage.com";
        description = "S3 region endpoint for GitLab registry";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      gitlabRegistryEnvironment = {
        file = "${inputs.self}/secrets/gitlabRegistryEnvironment.age";
        owner = serviceName;
        group = serviceName;
      };
    };

    meenzen.backup.paths = [cfg.certDirectory];

    services.postgresql = {
      ensureUsers = [
        {
          name = serviceName;
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [serviceName];
    };

    services.gitlab = {
      extraConfig = {
        registry = {
          # Unset registry port so that "registry.example.org" instead of "registry.example.org:443" is used
          # as the registry URL in the GitLab UI.
          port = null;
          database = databaseConfig;
        };
      };
      registry = {
        enable = true;
        port = cfg.port;
        externalAddress = cfg.domain;
        externalPort = 443;

        # This certificate is automatically generated and only used for jwt signing.
        certFile = "${cfg.certDirectory}/registry_auth_cert";
        keyFile = "${cfg.certDirectory}/registry_auth_key";
      };
    };

    services.dockerRegistry = {
      # disable local filesystem storage
      storagePath = null;
      extraConfig = {
        # configuration reference: https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md
        storage = {
          s3 = {
            # Override secrets using environment variables REGISTRY_STORAGE_S3_ACCESSKEY and REGISTRY_STORAGE_S3_SECRETKEY
            accesskey = "";
            secretkey = "";
            bucket = cfg.s3.bucket;
            region = cfg.s3.region;
            regionendpoint = cfg.s3.regionEndpoint;
            maxrequestspersecond = 100;
            chunksize = 104857600;
          };
          redirect.disable = true;
        };
        database = databaseConfig;
      };
    };

    systemd.services.docker-registry = {
      after = ["postgresql.target" "gitlab-registry-migrate.service"];
      requires = ["postgresql.target" "gitlab-registry-migrate.service"];
      wants = ["gitlab-registry-migrate.service"];
      serviceConfig.EnvironmentFile = config.age.secrets.gitlabRegistryEnvironment.path;
    };

    systemd.services.gitlab-registry-migrate = {
      after = ["postgresql.target"];
      requires = ["postgresql.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        TimeoutSec = "infinity";
        Restart = "on-failure";
        User = serviceName;
        Group = serviceName;
        EnvironmentFile = config.age.secrets.gitlabRegistryEnvironment.path;
        ExecStart = "${registryBin} database migrate up ${config.services.dockerRegistry.configFile}";
      };
    };

    environment.systemPackages = let
      user = serviceName;
      mkScript = name: command: (pkgs.writeShellApplication {
        name = "gitlab-registry-${name}";
        text = ''
          # Load env file
          export_vars=""
          if [ -f ${config.age.secrets.gitlabRegistryEnvironment.path} ]; then
            while IFS= read -r line || [[ -n "$line" ]]; do
              # Skip empty lines and lines starting with #
              [[ -z "$line" || "$line" == \#* ]] && continue

              # Split on the first '='
              key="''${line%%=*}"
              value="''${line#*=}"

              # Trim leading/trailing spaces from key and value
              key="$(echo -e "''${key}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
              value="$(echo -e "''${value}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

              # Export the variable
              export "$key=$value"
              export_vars+=" $key=$value"
            done < ${config.age.secrets.gitlabRegistryEnvironment.path}
          fi

          if [ $# -eq 0 ]; then
            sudo -u ${user} env "$export_vars" ${registryBin} ${command} ${config.services.dockerRegistry.configFile}
          else
            sudo -u ${user} env "$export_vars" ${registryBin} ${command} "$@" ${config.services.dockerRegistry.configFile}
          fi
        '';
      });
    in [
      (mkScript "garbage-collect" "garbage-collect")
      (mkScript "database-migrate" "database migrate up")
      (mkScript "wrapper" "")
    ];

    services.nginx.virtualHosts."${cfg.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.gitlab.registry.port}";
        extraConfig = ''
          client_max_body_size 0;
        '';
      };
    };
  };
}
