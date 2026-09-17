{
  config,
  lib,
  ...
}: let
  cfg = config.meenzen.matrix.rtc;

  synapseSettings = {
    # The maximum allowed duration by which sent events can be delayed, as
    # per MSC4140.
    max_event_delay_duration = "24h";

    rc_message = {
      # This needs to match at least e2ee key sharing frequency plus a bit of headroom
      # Note key sharing events are bursty
      per_second = 0.5;
      burst_count = 30;
    };

    # This needs to match at least the heart-beat frequency plus a bit of headroom
    # Currently the heart-beat is every 5 seconds which translates into a rate of 0.2s
    rc_delayed_event_mgmt = {
      per_second = 1;
      burst_count = 20;
    };

    matrix_rtc.transports = [
      {
        type = "livekit";
        # todo: set up lk-jwt-service as an appservice once 0.7 is available in nixpkgs
        # see https://github.com/NixOS/nixpkgs/issues/562332
        # see https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html#matrix_rtc
        #url = "wss://${config.meenzen.livekit.domain}";

        # for now, use the legacy approach
        livekit_service_url = "https://${config.meenzen.lk-jwt-service.domain}/livekit/jwt";
      }
    ];
  };
in {
  options.meenzen.matrix.rtc = {
    enable = lib.mkEnableOption "Enable Matrix RTC";
  };

  imports = [
    ./livekit.nix
    ./lk-jwt-service.nix
  ];

  config = lib.mkIf cfg.enable {
    meenzen = {
      livekit.enable = true;
      lk-jwt-service.enable = true;
    };

    services = {
      matrix-synapse.settings = synapseSettings;
      matrix-synapse-next.settings = synapseSettings;
    };
  };
}
