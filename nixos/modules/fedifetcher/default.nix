{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.fedifetcher;
in {
  options.meenzen.fedifetcher = {
    enable = lib.mkEnableOption "Enable FediFetcher";
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      fedifetcherConfigJson = {
        file = ../../../secrets/fedifetcherConfigJson.age;
      };
    };
    systemd.services.fedifetcher = {
      description = "FediFetcher";
      wants = ["mastodon-web.service"];
      after = ["mastodon-web.service"];
      startAt = "*-*-* *:*:00";
      serviceConfig = {
        Type = "oneshot";
        DynamicUser = true;
        StateDirectory = "fedifetcher";
        LoadCredential = "config.json:${config.age.secrets.fedifetcherConfigJson.path}";
        ExecStart = "${pkgs.fedifetcher}/bin/fedifetcher --config=%d/config.json --state-dir=%S/fedifetcher";
      };
    };
  };
}
