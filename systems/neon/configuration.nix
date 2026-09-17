{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];

  system.stateVersion = "24.11";

  boot = {
    zfs.forceImportRoot = false;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "neon";
    domain = "mnzn.dev";
    hostId = "91312b0a";

    hosts = {
      # Fix forgejo federation with local mastodon instance
      "95.217.150.38" = [
        "social.meenzen.net"
      ];
    };
  };

  meenzen = {
    server.enable = true;
    backup.enable = true;
    hetzner.enable = true;
    grafana.enable = true;
    postgresql.enable = true;
    oci-containers.enable = true;
    mastodon = {
      enable = true;
      enableSearch = true;
    };
    matrix.enable = true;
    collabora.enable = true;
    cheshbot.enable = true;
    attic.enable = true;
    distributed-build.enableHost = true;
    nginx = {
      enable = true;
      enableCloudflare = true;
      testPage = "neon.mnzn.dev";
      allowIndexing = true;
    };
    services = {
      acme-mnzn.enable = true;
      fluent-bit.enable = true;
      tuwunel.enable = true;
      miniflux.enable = true;
      forgejo.enable = true;
      authelia.enable = true;
      mnzn-website.enable = true;
      uptime-kuma.enable = true;
      minecraft.enable = true;
      minecraft.flip.enable = true;
      glitchtip.enable = true;
      lauti.enable = true;
    };
  };

  services.nginx.virtualHosts."neon.mnzn.dev" = {
    enableACME = lib.mkForce false;
    useACMEHost = "mnzn.dev";
  };
}
