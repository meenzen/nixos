{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.meenzen.promtail;

  fullHostname =
    if toString config.networking.domain == ""
    then config.networking.hostName
    else "${config.networking.hostName}.${config.networking.domain}";
in {
  options.meenzen.promtail = {
    enable = lib.mkEnableOption "Enable Promtail";
    url = lib.mkOption {
      type = lib.types.str;
      default = "https://loki.mnzn.dev/loki/api/v1/push";
      description = "Loki url for Promtail";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 9080;
      description = "Local port for Promtail";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      promtailLokiAdminPassword = {
        file = "${inputs.self}/secrets/promtailLokiAdminPassword.age";
        owner = "promtail";
        group = "promtail";
      };
    };

    systemd.services.promtail.serviceConfig.SupplementaryGroups = lib.optional (config.services.nginx.enable) "nginx";

    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = cfg.port;
          grpc_listen_port = 0;
        };
        positions = {
          filename = "/tmp/positions.yaml";
        };
        clients = [
          {
            url = cfg.url;
            basic_auth = {
              username = "admin";
              password_file = config.age.secrets.promtailLokiAdminPassword.path;
            };
          }
        ];
        scrape_configs =
          [
            {
              job_name = "journal";
              journal = {
                max_age = "12h";
                labels = {
                  job = "systemd-journal";
                  host = fullHostname;
                };
              };
              relabel_configs = [
                {
                  source_labels = ["__journal__systemd_unit"];
                  target_label = "unit";
                }
                {
                  source_labels = ["__journal_syslog_identifier"];
                  target_label = "syslog_identifier";
                }
              ];
            }
          ]
          ++ lib.optional (config.services.nginx.enable) {
            job_name = "nginx";
            static_configs = [
              {
                targets = [
                  "127.0.0.1"
                ];
                labels = {
                  job = "nginx";
                  host = fullHostname;
                  __path__ = "/var/log/nginx/*.log";
                };
              }
            ];
          };
      };
    };
  };
}
