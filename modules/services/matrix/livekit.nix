{
  config,
  lib,
  secrets,
  ...
}: let
  cfg = config.meenzen.services.matrix.livekit;
in {
  options.meenzen.services.matrix.livekit = {
    enable = lib.mkEnableOption "LiveKit SFU";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "livekit.mnzn.dev";
      description = "Domain for Livekit";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 7880;
      description = "Port for LiveKit";
    };

    rtc = {
      tcp_port = lib.mkOption {
        type = lib.types.port;
        default = 7881;
        description = "TCP port for WebRTC";
      };

      port_range_start = lib.mkOption {
        type = lib.types.port;
        default = 50000;
        description = "Start of UDP port range for WebRTC";
      };

      port_range_end = lib.mkOption {
        type = lib.types.port;
        default = 51000;
        description = "End of UDP port range for WebRTC";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    meenzen = {
      nginx.enable = true;
      # Provides the mnzn.dev certificate used by useACMEHost.
      services.acme-mnzn.enable = true;
    };

    age.secrets.livekitKeys = {
      file = "${secrets}/livekitKeys.age";
      restartUnits = ["livekit.service"];
    };

    services.livekit = {
      enable = true;
      keyFile = config.age.secrets.livekitKeys.path;
      # Opens the main port and the UDP range, but not rtc.tcp_port.
      openFirewall = true;
      settings = {
        port = cfg.port;
        log_level = "info";
        rtc = {
          inherit (cfg.rtc) tcp_port port_range_start port_range_end;
          use_external_ip = false;
        };
      };
    };

    networking.firewall.allowedTCPPorts = [cfg.rtc.tcp_port];

    services.nginx.virtualHosts.${cfg.domain} = {
      useACMEHost = "mnzn.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
      meenzen.noIndex.enable = true;
    };
  };
}
