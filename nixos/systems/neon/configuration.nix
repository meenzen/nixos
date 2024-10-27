{
  config,
  lib,
  pkgs,
  systemConfig,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "neon";
  networking.domain = "mnzn.dev";
  networking.hostId = "91312b0a";
  system.stateVersion = "24.11";

  custom.hetzner.enable = true;
  custom.nginx = {
    enable = true;
    testPage = "neon.mnzn.dev";
  };
  custom.postgresql.enable = true;
  custom.oci-containers.enable = true;
  custom.mastodon.enable = true;
}
