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
    services.cloudflare-warp = {
      enable = true;
      package = pkgs.cloudflare-warp;
    };

    # see https://github.com/NixOS/nixpkgs/issues/504119#issuecomment-4143108440
    networking.firewall.checkReversePath = "loose";
  };
}
