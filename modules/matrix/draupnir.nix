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
      draupnirSynapseAntispamSecret = {
        file = "${inputs.self}/secrets/draupnirSynapseAntispamSecret.age";
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
          address = "0.0.0.0";
          synapseHTTPAntispam.enabled = true;
        };
        pollReports = true;
        displayReports = true;
      };
      secrets = {
        accessToken = config.age.secrets.draupnirAccessToken.path;
        web.synapseHTTPAntispam.authorization = config.age.secrets.draupnirSynapseAntispamSecret.path;
      };
    };

    # Enable synapse-http-antispam plugin for Synapse
    services.matrix-synapse.plugins = with config.services.matrix-synapse.package.plugins; [
      synapse-http-antispam
    ];
    services.matrix-synapse-next.plugins = with config.services.matrix-synapse-next.package.plugins; [
      synapse-http-antispam
    ];
  };
}
