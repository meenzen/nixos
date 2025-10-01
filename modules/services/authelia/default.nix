{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.authelia;
  instance = "main";
  serviceName = "authelia";
  user = "${serviceName}-${instance}";
  directory = "/var/lib/${serviceName}-${instance}";
in {
  options.meenzen.services.authelia = {
    enable = lib.mkEnableOption "Enable Authelia";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "login.mnzn.dev";
      description = "Domain for Authelia";
    };
    cookieDomain = lib.mkOption {
      type = lib.types.str;
      default = "mnzn.dev";
      description = "Cookies domain for Authelia";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 9091;
      description = "Local port for Authelia";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      autheliaStorageEncryptionKey = {
        file = "${inputs.self}/secrets/autheliaStorageEncryptionKey.age";
        owner = user;
      };
      autheliaSessionSecret = {
        file = "${inputs.self}/secrets/autheliaSessionSecret.age";
        owner = user;
      };
      autheliaOidcIssuerPrivateKey = {
        file = "${inputs.self}/secrets/autheliaOidcIssuerPrivateKey.age";
        owner = user;
      };
      autheliaOidcHmacSecret = {
        file = "${inputs.self}/secrets/autheliaOidcHmacSecret.age";
        owner = user;
      };
      autheliaJwtSecret = {
        file = "${inputs.self}/secrets/autheliaJwtSecret.age";
        owner = user;
      };
      autheliaEmailConfiguration = {
        file = "${inputs.self}/secrets/autheliaEmailConfiguration.age";
        owner = user;
      };
      autheliaOidcClientConfiguration = {
        file = "${inputs.self}/secrets/autheliaOidcClientConfiguration.age";
        owner = user;
      };
    };

    meenzen.backup.paths = [directory];

    services.authelia.instances.${instance} = {
      enable = true;
      user = user;
      secrets = {
        storageEncryptionKeyFile = config.age.secrets.autheliaStorageEncryptionKey.path;
        sessionSecretFile = config.age.secrets.autheliaSessionSecret.path;
        oidcIssuerPrivateKeyFile = config.age.secrets.autheliaOidcIssuerPrivateKey.path;
        oidcHmacSecretFile = config.age.secrets.autheliaOidcHmacSecret.path;
        jwtSecretFile = config.age.secrets.autheliaJwtSecret.path;
      };
      settingsFiles = [
        config.age.secrets.autheliaEmailConfiguration.path
        config.age.secrets.autheliaOidcClientConfiguration.path
      ];
      settings = {
        theme = "auto";
        default_2fa_method = "webauthn";
        access_control = {
          default_policy = "one_factor";
        };
        authentication_backend = {
          file = {
            watch = true;
            search = {
              email = true;
              case_insensitive = true;
            };
            path = "${directory}/users.yml";
          };
        };
        session = {
          cookies = [
            {
              domain = cfg.cookieDomain;
              authelia_url = "https://${cfg.domain}";
            }
          ];
        };
        server = {
          address = "tcp://:${toString cfg.port}/";
        };
        storage = {
          postgres = {
            address = "unix:///run/postgresql";
            database = user;
            username = user;
          };
        };
      };
    };

    meenzen.postgresql.enable = true;
    services.postgresql = {
      ensureUsers = [
        {
          name = user;
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [user];
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
