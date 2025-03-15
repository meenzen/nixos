{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.lk-jwt-service;
in {
  options.meenzen.lk-jwt-service = {
    enable = lib.mkEnableOption "Enable lk-jwt-service";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "livekit-jwt.mnzn.dev";
      description = "Domain for lk-jwt-service";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8083;
      description = "Port for lk-jwt-service";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      livekitServiceEnvironment = {
        file = "${inputs.self}/secrets/livekitServiceEnvironment.age";
        owner = "lk-jwt-service";
        group = "lk-jwt-service";
      };
    };

    systemd.services.lk-jwt-service = {
      description = "Minimal service to issue LiveKit JWTs for MatrixRTC";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.lk-jwt-service}/bin/lk-jwt-service";
        Restart = "always";
        RestartSec = "5";
        User = "lk-jwt-service";
        Group = "lk-jwt-service";
        EnvironmentFile = config.age.secrets.livekitServiceEnvironment.path;
      };

      environment = {
        LIVEKIT_URL = "ws://${config.meenzen.livekit.domain}";
        LIVEKIT_JWT_PORT = toString cfg.port;
      };
    };

    users.users.lk-jwt-service = {
      isSystemUser = true;
      group = "lk-jwt-service";
      description = "lk-jwt-service service user";
    };

    users.groups.lk-jwt-service = {};

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
