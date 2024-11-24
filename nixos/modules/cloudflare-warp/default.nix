{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.cloudflare-warp;
in {
  options.meenzen.cloudflare-warp = {
    enable = lib.mkEnableOption "Enable Cloudflare Warp Client";
  };

  config = lib.mkIf cfg.enable {
    services.cloudflare-warp.enable = true;
  };
}
