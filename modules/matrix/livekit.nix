{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.livekit;
in {
  options.meenzen.livekit = {
    enable = lib.mkEnableOption "LiveKit SFU";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "livekit.mnzn.dev";
      description = "Domain for Livekit";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.livekit;
      description = "LiveKit package";
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      description = "LiveKit configuration file";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 7880;
      description = "Port for LiveKit";
    };

    rtc = {
      tcp_port = lib.mkOption {
        type = lib.types.int;
        default = 7881;
        description = "TCP port for WebRTC";
      };

      port_range_start = lib.mkOption {
        type = lib.types.int;
        default = 50000;
        description = "Start of UDP port range for WebRTC";
      };

      port_range_end = lib.mkOption {
        type = lib.types.int;
        default = 51000;
        description = "End of UDP port range for WebRTC";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      livekitKeys = {
        file = "${inputs.self}/secrets/livekitKeys.age";
        owner = "livekit";
        group = "livekit";
      };
    };

    meenzen.livekit.configFile = lib.mkDefault (
      pkgs.writeTextFile {
        name = "livekit-config.yaml";
        text = builtins.toJSON {
          port = cfg.port;
          log_level = "info";
          rtc = {
            tcp_port = cfg.rtc.tcp_port;
            port_range_start = cfg.rtc.port_range_start;
            port_range_end = cfg.rtc.port_range_end;
            use_external_ip = false;
          };
        };
      }
    );

    systemd.services.livekit = {
      description = "LiveKit SFU server";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/livekit-server --config=${cfg.configFile} --key-file=${config.age.secrets.livekitKeys.path}";
        Restart = "always";
        RestartSec = "5";
        User = "livekit";
        Group = "livekit";
      };
    };

    users.users.livekit = {
      isSystemUser = true;
      group = "livekit";
      description = "LiveKit service user";
    };

    users.groups.livekit = {};

    networking.firewall = {
      allowedTCPPorts = [
        cfg.port
        cfg.rtc.tcp_port
      ];
      allowedUDPPortRanges = [
        {
          from = cfg.rtc.port_range_start;
          to = cfg.rtc.port_range_end;
        }
      ];
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };
  };
}
