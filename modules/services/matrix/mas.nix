{
  config,
  lib,
  pkgs,
  secrets,
  ...
}: let
  cfg = config.meenzen.services.matrix.mas;
  serviceName = "matrix-authentication-service";
  masCfg = config.services.matrix-authentication-service;

  # The upstream module doesn't expose its generated config, so build the same file for mas-cli-wrapper. Like
  # upstream, drop the null defaults (e.g. upstream_oauth2.providers) the module adds to settings.
  configFile = (pkgs.formats.yaml {}).generate "mas-config.yaml" (
    lib.filterAttrsRecursive (_: v: v != null) (builtins.removeAttrs masCfg.settings ["upstream_oauth2"])
  );
in {
  options.meenzen.services.matrix.mas = {
    enable = lib.mkEnableOption "Matrix Authentication Service (MAS)";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "auth.mnzn.dev";
      description = "Domain for MAS";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8009;
      description = "Local port for MAS";
    };
  };

  config = lib.mkIf cfg.enable {
    meenzen = {
      nginx.enable = true;
      # Provides the mnzn.dev certificate used by useACMEHost.
      services.acme-mnzn.enable = true;
      postgresql.enable = true;
    };

    age.secrets = {
      # Owned by the service user because mas-cli-wrapper reads it directly, the service gets it via LoadCredential.
      masSecretConfig = {
        file = "${secrets}/masSecretConfig.age";
        restartUnits = ["${serviceName}.service"];
        owner = serviceName;
        group = serviceName;
      };
    };

    environment.systemPackages = [
      masCfg.package
      (
        pkgs.writeShellApplication {
          name = "mas-cli-wrapper";
          text = ''
            if [ -z "''${1-}" ]; then
              set -- --help
            fi
            sudo -u ${serviceName} ${masCfg.package}/bin/mas-cli --config=${configFile} --config=${config.age.secrets.masSecretConfig.path} "$@"
          '';
        }
      )
    ];

    # Static user for mas-cli-wrapper and PostgreSQL peer auth. The service uses DynamicUser, which picks up an
    # existing user of the same name.
    users = {
      users.${serviceName} = {
        isSystemUser = true;
        group = serviceName;
        description = "MAS service user";
      };
      groups.${serviceName} = {};
    };

    services = {
      matrix-authentication-service = {
        enable = true;
        createDatabase = true;
        extraConfigFiles = [config.age.secrets.masSecretConfig.path];
        settings = {
          http = {
            listeners = [
              {
                name = "web";
                resources = [
                  {name = "discovery";}
                  {name = "human";}
                  {name = "oauth";}
                  {name = "compat";}
                  {name = "graphql";}
                  {name = "adminapi";}
                ];
                binds = [
                  {
                    host = "::";
                    port = cfg.port;
                  }
                ];
                proxy_protocol = false;
              }
            ];
            trusted_proxies = [
              "192.168.0.0/16"
              "172.16.0.0/12"
              "10.0.0.0/10"
              "127.0.0.1/8"
              "fd00::/8"
              "::1/128"
            ];
            public_base = "https://${cfg.domain}/";
            issuer = "https://${cfg.domain}/";
          };
          passwords = {
            enabled = true;
            # Must match the existing hashes, upstream defaults to argon2id as version 1.
            schemes = [
              {
                version = 1;
                algorithm = "bcrypt";
              }
              {
                version = 2;
                algorithm = "argon2id";
              }
            ];
            minimum_complexity = 3;
          };
          matrix = {
            homeserver = config.meenzen.services.matrix.synapse.domain;
            endpoint =
              if config.meenzen.services.matrix.synapse.enableWorkers
              then "https://${config.meenzen.services.matrix.synapse.matrixDomain}"
              else "http://[::1]:${toString config.meenzen.services.matrix.synapse.port}";
          };
        };
      };

      matrix-synapse.extras = ["oidc"];

      nginx.virtualHosts = {
        "${cfg.domain}" = {
          useACMEHost = "mnzn.dev";
          forceSSL = true;
          locations = {
            "/".proxyPass = "http://[::1]:${toString cfg.port}";
            "/assets" = {
              root = "${masCfg.package}/share/matrix-authentication-service";
              extraConfig = ''
                add_header Cache-Control "public, immutable, max-age=31536000";
              '';
            };
          };
          extraConfig = ''
            add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
          '';
        };
        "${config.meenzen.services.matrix.synapse.matrixDomain}" = {
          locations."~ ^/_matrix/client/(.*)/(login|logout|refresh)".proxyPass = "http://[::1]:${toString cfg.port}";
        };
      };
    };
  };
}
