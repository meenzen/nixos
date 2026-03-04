{
  config,
  lib,
  pkgs-stable,
  ...
}: let
  cfg = config.meenzen.cloudflare-warp;
in {
  options.meenzen.cloudflare-warp = {
    enable = lib.mkEnableOption "Enable Cloudflare Warp Client";
  };

  config = lib.mkIf cfg.enable {
    services.cloudflare-warp = {
      enable = true;
      # Cloudflare Warp 2026.1.150.0 is broken, so use the stable version 2025.10.186.0 instead
      package = pkgs-stable.cloudflare-warp;
    };
  };
}
