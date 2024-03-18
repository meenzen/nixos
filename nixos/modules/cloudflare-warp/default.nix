{pkgs, ...}: {
  # https://github.com/NixOS/nixpkgs/issues/213177
  environment.systemPackages = [pkgs.cloudflare-warp]; # for warp-svc
  systemd.packages = [pkgs.cloudflare-warp]; # for warp-cli
  systemd.targets.multi-user.wants = ["warp-svc.service"]; # causes warp-svc to be started automatically
}
