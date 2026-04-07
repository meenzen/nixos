{
  config,
  lib,
  inputs,
  ...
}: let
  serviceName = "fluent-bit";
  cfg = config.meenzen.services.fluent-bit;

  fullHostname =
    if toString config.networking.domain == ""
    then config.networking.hostName
    else "${config.networking.hostName}.${config.networking.domain}";
in {
  options.meenzen.services.fluent-bit = {
    enable = lib.mkEnableOption "Enable Fluent Bit";
    graceLimitSeconds = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = "The grace time limit";
    };
    lokiHost = lib.mkOption {
      type = lib.types.str;
      default = "loki.mnzn.dev";
      description = "Loki host for Fluent Bit";
    };
    lokiUri = lib.mkOption {
      type = lib.types.str;
      default = "/loki/api/v1/push";
      description = "Loki uri for Fluent Bit";
    };
    lokiTls = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use TLS for Loki connection";
    };
    lokiPort = lib.mkOption {
      type = lib.types.int;
      default = 443;
      description = "Loki port for Fluent Bit";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      fluentBitEnvironment = {
        file = "${inputs.self}/secrets/fluentBitEnvironment.age";
      };
    };

    services.fluent-bit = {
      enable = true;
      graceLimit = cfg.graceLimitSeconds;
      settings = {
        pipeline = {
          inputs =
            [
              {
                name = "systemd";
                tag = "host.journal";
                db = "/var/lib/${serviceName}/journal.db";
              }
            ]
            ++ lib.optional (config.services.nginx.enable) {
              name = "tail";
              tag = "host.nginx";
              path = "/var/log/nginx/*.log";
              path_key = "filename";
              db = "/var/lib/${serviceName}/nginx.db";
            };

          filters =
            [
              {
                name = "modify";
                match = "host.journal";
                Copy = [
                  "_SYSTEMD_UNIT unit"
                ];
                Add = [
                  "job systemd-journal"
                  "host ${fullHostname}"
                ];
              }
            ]
            ++ lib.optional (config.services.nginx.enable) {
              name = "modify";
              match = "host.nginx";
              Add = [
                "job nginx"
                "host ${fullHostname}"
              ];
            };

          outputs = [
            {
              name = "loki";
              match = "*";
              host = cfg.lokiHost;
              port = cfg.lokiPort;
              uri = cfg.lokiUri;
              tls =
                if cfg.lokiTls
                then "on"
                else "off";
              http_user = "admin";
              http_passwd = "\${HTTP_PASSWORD}";
              label_keys = "$host,$job,$unit,$syslog_identifier,$filename";
              drop_single_key = "raw";
              line_format = "json";
            }
          ];
        };
        service = {
          grace = cfg.graceLimitSeconds - 1;
          "storage.path" = "/var/lib/${serviceName}/storage";
          "storage.inherit" = "on";
          "storage.type" = "filesystem";
        };
      };
    };

    systemd.services.${serviceName}.serviceConfig = {
      EnvironmentFile = config.age.secrets.fluentBitEnvironment.path;
      SupplementaryGroups = lib.optional (config.services.nginx.enable) "nginx";
      StateDirectory = serviceName;
    };
  };
}
