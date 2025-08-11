{
  config,
  lib,
  pkgs,
  pkgs-review,
  ...
}: let
  cfg = config.meenzen.matrix.element-call;
in {
  options.meenzen.matrix.element-call = {
    enable = lib.mkEnableOption "Enable Element Call";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "call.mnzn.dev";
      description = "Domain for Element Call";
    };
    matrixBaseDomain = lib.mkOption {
      type = lib.types.str;
      default = "mnzn.dev";
      description = "Domain for Matrix Server";
    };
  };

  imports = [
    ./livekit.nix
    ./lk-jwt-service.nix
  ];

  config = lib.mkIf cfg.enable {
    meenzen.livekit.enable = true;
    meenzen.lk-jwt-service.enable = true;

    # Testing latest synapse version
    nixpkgs.overlays = [
      (
        final: prev: {
          matrix-synapse-unwrapped = pkgs-review.matrix-synapse-unwrapped;
        }
      )
    ];

    services.matrix-synapse.settings = {
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

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      root = pkgs.element-call;
      locations."/".extraConfig = ''
        try_files $uri /$uri /index.html;
        add_header Cache-Control "public, max-age=30, stale-while-revalidate=30";
      '';
      # assets can be cached because they have hashed filenames
      locations."/assets".extraConfig = ''
        add_header Cache-Control "public, immutable, max-age=31536000";
      '';
      locations."/config.json".extraConfig = ''
        default_type application/json;
        return 200 '${
          builtins.toJSON {
            default_server_config = {
              "m.homeserver" = {
                "base_url" = "https://matrix.${cfg.matrixBaseDomain}";
                "server_name" = cfg.matrixBaseDomain;
              };
            };
            livekit.livekit_service_url = "https://${config.meenzen.lk-jwt-service.domain}";
          }
        }';
      '';
    };
  };
}
