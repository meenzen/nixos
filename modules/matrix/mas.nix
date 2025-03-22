{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.matrix.mas;
  serviceName = "matrix-authentication-service";
in {
  options.meenzen.matrix.mas = {
    enable = lib.mkEnableOption "Enable Matrix Authentication Service (MAS)";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "auth.mnzn.dev";
      description = "Domain for MAS";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8009;
      description = "Local port for MAS";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.matrix-authentication-service;
      description = "MAS package";
    };
    configFile = lib.mkOption {
      type = lib.types.path;
      description = "MAS configuration file";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      masSecretConfig = {
        file = "${inputs.self}/secrets/masSecretConfig.age";
        owner = serviceName;
        group = serviceName;
      };
    };

    services.matrix-synapse.extras = ["oidc"];

    meenzen.matrix.mas.configFile = lib.mkDefault (
      pkgs.writeTextFile {
        name = "mas-config.yaml";
        text = builtins.toJSON {
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
                ];
                binds = [
                  {address = "[::]:${toString cfg.port}";}
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
          database = {
            host = "/run/postgresql";
            username = serviceName;
            database = serviceName;
            max_connections = 10;
            min_connections = 0;
            connect_timeout = 30;
            idle_timeout = 600;
            max_lifetime = 1800;
          };
          email = {
            from = ''"Authentication Service" <root@localhost>'';
            reply_to = ''"Authentication Service" <root@localhost>'';
            transport = "blackhole";
          };
          passwords = {
            enabled = true;
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
            homeserver = config.meenzen.matrix.synapse.domain;
            endpoint = "http://[::1]:${toString config.meenzen.matrix.synapse.port}";
          };
        };
      }
    );

    environment.systemPackages = [
      cfg.package
      pkgs.syn2mas
      (pkgs.writeScriptBin "mas-cli-wrapper" ''
        sudo -u ${serviceName} ${cfg.package}/bin/mas-cli --config=${cfg.configFile} --config=${config.age.secrets.masSecretConfig.path} $@
      '')
    ];

    users.users."${serviceName}" = {
      isSystemUser = true;
      group = serviceName;
      description = "MAS service user";
    };

    users.groups."${serviceName}" = {};

    systemd.services."${serviceName}" = {
      enable = true;
      description = "MAS";
      wants = ["network-online.target"];
      after = ["network-online.target" "postgresql.service"];
      requires = ["postgresql.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/mas-cli --config=${cfg.configFile} --config=${config.age.secrets.masSecretConfig.path} server";
        User = serviceName;
        Group = serviceName;
        Restart = "on-failure";
      };
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

    services.nginx.virtualHosts."${cfg.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://[::1]:${toString cfg.port}";
      locations."/assets" = {
        root = "${cfg.package}/share/matrix-authentication-service";
        extraConfig = ''
          add_header Cache-Control "public, immutable, max-age=31536000";
        '';
      };
    };

    services.nginx.virtualHosts."${config.meenzen.matrix.synapse.matrixDomain}" = {
      locations."~ ^/_matrix/client/(.*)/(login|logout|refresh)".proxyPass = "http://[::1]:${toString cfg.port}";
    };
  };
}
