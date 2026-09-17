{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.matrix.element-call;

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
  };
in {
  options.meenzen.matrix.element-call = {
    enable = lib.mkEnableOption "Enable Element Call";
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
