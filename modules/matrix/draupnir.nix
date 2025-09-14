{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.matrix.draupnir;
in {
  options.meenzen.matrix.draupnir = {
    enable = lib.mkEnableOption "Enable Draupnir";
    port = lib.mkOption {
      type = lib.types.int;
      default = 8010;
      description = "Local port for Draupnir web interface.";
    };
    managementRoom = lib.mkOption {
      type = lib.types.str;
      description = "The room ID or alias of the management room Draupnir should use.";
      default = "#moderation:mnzn.dev";
    };
  };

  config = lib.mkIf cfg.enable {
    meenzen.backup.paths = [config.services.draupnir.settings.dataPath];
    age.secrets = {
      draupnirAccessToken = {
        file = "${inputs.self}/secrets/draupnirAccessToken.age";
      };
    };

    services.draupnir = {
      enable = true;
      settings = {
        homeserverUrl = "https://${config.meenzen.matrix.synapse.matrixDomain}";
        managementRoom = cfg.managementRoom;
        autojoinOnlyIfManager = true;
        automaticallyRedactForReasons = ["spam" "advertising"];
        web = {
          enabled = true;
          port = cfg.port;
          abuseReporting.enabled = true;
        };
        displayReports = true;
      };
      secrets = {
        accessToken = config.age.secrets.draupnirAccessToken.path;
      };
    };

    # Intercept abuse reports from Synapse and forward them to Draupnir
    services.nginx.virtualHosts."${config.meenzen.matrix.synapse.matrixDomain}" = {
      locations."~ ^/_matrix/client/(r0|v3)/rooms/([^/]*)/report/(.*)$".extraConfig = ''
        mirror /report_mirror;
        # Abuse reports should be sent to Draupnir.
        # The r0 endpoint is deprecated but still used by many clients.
        # As of this writing, the v3 endpoint is the up-to-date version.

        # Add CORS, otherwise a browser will refuse this request.
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since' always;
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;
        add_header 'Access-Control-Max-Age' 1728000;

        rewrite ^/_matrix/client/(?:r0|v3)/rooms/([^/]*)/report/(.*)$ /api/1/report/$1/$2 break;
        proxy_pass http://127.0.0.1:${toString cfg.port};
      '';
      locations."/report_mirror".extraConfig = ''
        internal;
        proxy_pass http://[::1]:${toString config.meenzen.matrix.synapse.port}$request_uri;
      '';
    };
  };
}
