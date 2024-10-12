{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.cloudflare-warp;
in {
  options.custom.cloudflare-warp = {
    enable = lib.mkEnableOption "Enable Cloudflare Warp Client";
  };

  config = lib.mkIf cfg.enable {
    services.cloudflare-warp.enable = true;
  };
}
