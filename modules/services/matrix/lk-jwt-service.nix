{
  config,
  lib,
  secrets,
  ...
}: let
  cfg = config.meenzen.services.matrix.lk-jwt-service;
in {
  options.meenzen.services.matrix.lk-jwt-service = {
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

    fullAccessHomeservers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Server names whose users may create new LiveKit rooms. Users of other homeservers can only join calls that
        already exist. The Synapse domain is always included.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    meenzen = {
      nginx.enable = true;
      # Provides the mnzn.dev certificate used by useACMEHost.
      services.acme-mnzn.enable = true;
      services.matrix.lk-jwt-service.fullAccessHomeservers = [config.meenzen.services.matrix.synapse.domain];
    };

    # Same key file as LiveKit, loaded via LoadCredential. lk-jwt-service only accepts a single key in it.
    age.secrets.livekitKeys = {
      file = "${secrets}/livekitKeys.age";
      restartUnits = ["lk-jwt-service.service"];
    };

    services.lk-jwt-service = {
      enable = true;
      livekitUrl = "wss://${config.meenzen.services.matrix.livekit.domain}";
      keyFile = config.age.secrets.livekitKeys.path;
      port = cfg.port;
    };

    # Not exposed by the upstream module, defaults to * (any homeserver)
    systemd.services.lk-jwt-service.environment.LIVEKIT_FULL_ACCESS_HOMESERVERS =
      lib.concatStringsSep "," cfg.fullAccessHomeservers;

    services.nginx.virtualHosts.${cfg.domain} = {
      useACMEHost = "mnzn.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
      extraConfig = ''
        add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
      '';
    };
  };
}
