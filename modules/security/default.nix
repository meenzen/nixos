{pkgs, ...}: {
  networking.firewall.enable = true;

  environment.systemPackages = [
    pkgs.uutils-coreutils-noprefix
  ];

  meenzen.sudo-rs.enable = true;
}
