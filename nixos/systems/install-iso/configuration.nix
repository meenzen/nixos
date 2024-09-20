{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}: {
  imports = [
    ../../modules
  ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Faster build, see https://nixos.wiki/wiki/Creating_a_NixOS_live_CD#Building_faster
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  # Enable the OpenSSH server so we can install the system remotely
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
  users.users.root.openssh.authorizedKeys.keys = systemConfig.user.authorizedKeys;
  users.users.nixos.openssh.authorizedKeys.keys = systemConfig.user.authorizedKeys;

  # force conflicting options
  hardware.pulseaudio.enable = lib.mkForce false;
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
}
