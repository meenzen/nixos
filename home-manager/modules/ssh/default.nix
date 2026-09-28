{
  lib,
  pkgs,
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
        connectTimeout = 15;
        controlMaster = "auto";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "60m";
        hashKnownHosts = true;
        userKnownHostsFile = "~/.ssh/known_hosts";
      };

      "lithium.localdomain" = {
        hostname = "192.168.1.4";
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
      comline-nixp01 = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "pber2sawv330113.human2.de";
        #proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      "pber2sawv330113.human2.de" = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "pber2sawv330113.human2.de";
        #proxyJump = "ssh-gateway-dmz.human-dev.io";
      };

      nixos-proxy-01 = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.26";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      "192.168.155.26" = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.26";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      comline-nixos-proxy-01 = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "pber2swbv330111.human2.de";
        #proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      "pber2swbv330111.human2.de" = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "pber2swbv330111.human2.de";
        #proxyJump = "ssh-gateway-dmz.human-dev.io";
      };

      nixos-proxy-02 = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.27";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      "192.168.155.27" = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.27";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      comline-nixos-proxy-02 = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "pber2swbv330112.human2.de";
        #proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      "pber2swbv330112.human2.de" = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "pber2swbv330112.human2.de";
        #proxyJump = "ssh-gateway-dmz.human-dev.io";
      };

      nixos-app-01 = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.28";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      "192.168.155.28" = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.28";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      comline-nixos-app-01 = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "pber2sawv330109.human2.de";
        #proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      "pber2sawv330109.human2.de" = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "pber2sawv330109.human2.de";
        #proxyJump = "ssh-gateway-dmz.human-dev.io";
      };

      nixos-app-02 = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.29";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      "192.168.155.29" = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "192.168.155.29";
        proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      comline-nixos-app-02 = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "pber2sawv330110.human2.de";
        #proxyJump = "ssh-gateway-dmz.human-dev.io";
      };
      "pber2sawv330110.human2.de" = lib.hm.dag.entryAfter ["ssh-gateway-dmz.human-dev.io"] {
        hostname = "pber2sawv330110.human2.de";
        #proxyJump = "ssh-gateway-dmz.human-dev.io";
      };

      "git.human.de".hostname = "git.human.de";
      "sentry.human.de".hostname = "sentry.human.de";
      "nix-01.human-dev.io".hostname = "nix-01.human-dev.io";
    };
  };
}
