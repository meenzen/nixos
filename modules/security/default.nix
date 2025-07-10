{pkgs, ...}: {
  networking.firewall.enable = true;

  # Replace sudo with sudo-rs to prevent memory vulnerabilities
  security.sudo.enable = false;
  security.sudo-rs.enable = true;

  environment.systemPackages = [
    pkgs.uutils-coreutils-noprefix
  ];
}
