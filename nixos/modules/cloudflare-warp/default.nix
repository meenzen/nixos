{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.gaming;
in {
  options.custom.cloudflare-warp = {
    enable = lib.mkEnableOption "Enable Cloudflare Warp Client";
  };

  config = lib.mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/issues/213177
    environment.systemPackages = [pkgs.cloudflare-warp];
    systemd.packages = [pkgs.cloudflare-warp];
    systemd.targets.multi-user.wants = ["warp-svc.service"];
  };
}
