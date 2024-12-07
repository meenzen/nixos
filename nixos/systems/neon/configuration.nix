{
  config,
  inputs,
  lib,
  pkgs,
  systemConfig,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix

    ./hardware-configuration.nix
    ./networking.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "neon";
  networking.domain = "mnzn.dev";
  networking.hostId = "91312b0a";
  system.stateVersion = "24.11";

  meenzen.backup.enable = true;
  meenzen.hetzner.enable = true;
  meenzen.nginx = {
    enable = true;
    testPage = "neon.mnzn.dev";
  };
  meenzen.postgresql.enable = true;
  meenzen.oci-containers.enable = true;
  meenzen.mastodon.enable = true;
  meenzen.fedifetcher.enable = true;
  meenzen.matrix.enable = true;
  meenzen.authentik.enable = true;
  meenzen.gitlab.enable = true;
}
