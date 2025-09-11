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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "neon";
  networking.domain = "mnzn.dev";
  networking.hostId = "91312b0a";
  system.stateVersion = "24.11";

  meenzen.server.enable = true;
  meenzen.backup.enable = true;
  meenzen.hetzner.enable = true;
  meenzen.nginx = {
    enable = true;
    enableCloudflare = true;
    testPage = "neon.mnzn.dev";
  };
  meenzen.grafana.enable = true;
  meenzen.promtail.enable = true;
  meenzen.postgresql.enable = true;
  meenzen.oci-containers.enable = true;
  meenzen.mastodon = {
    enable = true;
    enableSearch = true;
  };
  meenzen.fedifetcher.enable = true;
  meenzen.matrix.enable = true;
  meenzen.authentik.enable = true;
  meenzen.gitlab.enable = true;
  meenzen.collabora.enable = true;
  meenzen.cheshbot.enable = true;
  meenzen.attic.enable = true;
  meenzen.distributed-build.enableHost = true;
  meenzen.mudblazor-docs.enable = true;
  meenzen.websites."mnzn.dev".enable = true;
  meenzen.services.kener.enable = true;
  meenzen.services.conduit.enable = true;
  meenzen.services.miniflux.enable = true;
  meenzen.services.forgejo.enable = true;
}
