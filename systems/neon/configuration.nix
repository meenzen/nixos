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
    #./vms.nix
  ];

  boot.zfs.forceImportRoot = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "neon";
  networking.domain = "mnzn.dev";
  networking.hostId = "91312b0a";
  system.stateVersion = "24.11";

  meenzen.server.enable = true;
  meenzen.backup.enable = true;
  meenzen.hetzner.enable = true;

  meenzen.services.acme-mnzn.enable = true;
  meenzen.nginx = {
    enable = true;
    enableCloudflare = true;
    testPage = "neon.mnzn.dev";
  };
  services.nginx.virtualHosts."neon.mnzn.dev" = {
    enableACME = lib.mkForce false;
    useACMEHost = "mnzn.dev";
  };

  meenzen.grafana.enable = true;
  meenzen.services.fluent-bit.enable = true;
  meenzen.postgresql.enable = true;
  meenzen.oci-containers.enable = true;
  meenzen.mastodon = {
    enable = true;
    enableSearch = true;
  };
  meenzen.matrix.enable = true;
  meenzen.collabora.enable = true;
  meenzen.cheshbot.enable = true;
  meenzen.attic.enable = true;
  meenzen.distributed-build.enableHost = true;
  meenzen.services.conduit.enable = true;
  meenzen.services.miniflux.enable = true;
  meenzen.services.forgejo.enable = true;
  meenzen.services.authelia.enable = true;
  meenzen.services.mnzn-website.enable = true;
  meenzen.services.uptime-kuma.enable = true;
  meenzen.services.minecraft.enable = true;
  meenzen.services.minecraft.flip.enable = true;
  meenzen.services.glitchtip.enable = true;
  meenzen.services.lauti.enable = true;
}
