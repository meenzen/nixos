{pkgs, ...}: {
  # https://github.com/NixOS/nixpkgs/issues/213177
  environment.systemPackages = [pkgs.cloudflare-warp];
  systemd.packages = [pkgs.cloudflare-warp];
  systemd.targets.multi-user.wants = ["warp-svc.service"];
}
