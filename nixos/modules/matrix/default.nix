{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.matrix;
  serviceName = "matrix-synapse";
in {
  options.meenzen.matrix = {
    enable = lib.mkEnableOption "Enable Matrix Server";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "mnzn.dev";
      description = "Domain for Matrix Server";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      matrixSharedSecret = {
        file = "${inputs.self}/secrets/matrixSharedSecret.age";
        owner = serviceName;
        group = serviceName;
      };
    };

    services.matrix-synapse = {
      enable = true;
      withJemalloc = true;
      enableRegistrationScript = true;

      extraConfigFiles = [
        config.age.secrets.matrixSharedSecret.path
      ];

      settings = {
        server_name = cfg.domain;
        public_baseurl = "https://matrix.${cfg.domain}";
        allow_guest_access = false;
        enable_registration = false;
        listeners = [
          {
            port = 8008;
            bind_addresses = ["::1"];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = ["client" "federation"];
                compress = true;
              }
            ];
          }
        ];
      };
    };

    services.postgresql = {
      enable = true;
      initialScript = pkgs.writeText "setup-matrix-synapse.sql" ''
        CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
          TEMPLATE template0
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';
    };

    services.nginx.virtualHosts."matrix.${cfg.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".extraConfig = ''
        return 404;
      '';
      locations."/_matrix".proxyPass = "http://[::1]:8008";
      locations."/_synapse/client".proxyPass = "http://[::1]:8008";
    };
  };
}
