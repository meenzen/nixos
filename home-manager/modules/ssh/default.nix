{
  lib,
  pkgs,
  config,
  ...
}: {
  # cloudflared is required for tunneling through Cloudflare Zero Trust
  home.packages = [pkgs.cloudflared];

  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # SSH hosts config
    settings = {
      "*" = {
        addKeysToAgent = "yes";
        compression = false;
        controlMaster = "auto";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "60m";
        userKnownHostsFile = "~/.ssh/known_hosts";
      };

      "lithium.localdomain" = {
        hostname = "192.168.1.4";
      };

      # neon.mnzn.dev: disable multiplexing for direct connections
      # workaround for https://github.com/DeterminateSystems/nix-src/issues/441
      "95.217.150.38" = {
        controlMaster = "no";
        controlPath = "none";
      };

      "mail.meenzen.net" = {
        hostname = "mail.meenzen.net";
        user = "root";
      };

      "ssh-gateway-dmz.human-dev.io" = {
        proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
      };

      nixp01 = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "172.16.0.204";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      "172.16.0.204" = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "172.16.0.204";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };

      nixos-proxy-01 = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.26";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      "192.168.155.26" = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.26";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };

      nixos-proxy-02 = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.27";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      "192.168.155.27" = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.27";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };

      nixos-app-01 = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.28";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      "192.168.155.28" = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.28";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };

      nixos-app-02 = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.29";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      "192.168.155.29" = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.29";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };

      "git.human.de".hostname = "git.human.de";
      "sentry.human.de".hostname = "sentry.human.de";
      "nix-01.human-dev.io".hostname = "nix-01.human-dev.io";
    };
  };
}
