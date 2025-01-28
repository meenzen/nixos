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
    compression = true;
    addKeysToAgent = "yes";
    controlMaster = "auto";
    controlPersist = "60m";

    # SSH hosts config
    matchBlocks = {
      proxmox = {
        hostname = "192.168.1.4";
        user = "root";
      };

      "mail.meenzen.net" = {
        hostname = "mail.meenzen.net";
        user = "root";
      };

      "neon.mnzn.dev" = {
        hostname = "neon.mnzn.dev";
        user = "root";
      };

      "ssh-gateway.human-dev.io" = {
        proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
      };

      # Document Library
      postnotes01 = lib.hm.dag.entryAfter ["ssh-gateway.human-dev.io"] {
        hostname = "172.16.0.26";
        proxyJump = "ssh-gateway.human-dev.io";
      };

      # GitLab Runner, cloudflared
      smn_01 = lib.hm.dag.entryAfter ["ssh-gateway.human-dev.io"] {
        hostname = "172.16.0.211";
        proxyJump = "ssh-gateway.human-dev.io";
      };

      # osTicket
      smn_02 = lib.hm.dag.entryAfter ["ssh-gateway.human-dev.io"] {
        hostname = "172.16.0.212";
        proxyJump = "ssh-gateway.human-dev.io";
      };

      hpcredux = lib.hm.dag.entryAfter ["ssh-gateway.human-dev.io"] {
        hostname = "172.16.0.214";
        proxyJump = "ssh-gateway.human-dev.io";
      };

      hpcredux_dev = lib.hm.dag.entryAfter ["ssh-gateway.human-dev.io"] {
        hostname = "172.16.0.215";
        proxyJump = "ssh-gateway.human-dev.io";
      };

      reflector_dev = lib.hm.dag.entryAfter ["ssh-gateway.human-dev.io"] {
        hostname = "172.16.0.220";
        proxyJump = "ssh-gateway.human-dev.io";
      };

      reflector_prod = lib.hm.dag.entryAfter ["ssh-gateway.human-dev.io"] {
        hostname = "172.16.0.224";
        proxyJump = "ssh-gateway.human-dev.io";
      };

      # doku.human2.de
      nginx_static = lib.hm.dag.entryAfter ["ssh-gateway.human-dev.io"] {
        hostname = "172.16.0.216";
        proxyJump = "ssh-gateway.human-dev.io";
      };

      nginx_pisa_01 = lib.hm.dag.entryAfter ["ssh-gateway.human-dev.io"] {
        hostname = "192.168.155.11";
        proxyJump = "ssh-gateway.human-dev.io";
      };

      # webmonitor
      webmonitor = lib.hm.dag.entryAfter ["ssh-gateway.human-dev.io"] {
        hostname = "172.16.0.217";
        proxyJump = "ssh-gateway.human-dev.io";
      };

      # stirling-pdf
      docker01 = lib.hm.dag.entryAfter ["ssh-gateway.human-dev.io"] {
        hostname = "172.16.0.48";
        proxyJump = "ssh-gateway.human-dev.io";
      };

      helabftw1 = lib.hm.dag.entryAfter ["ssh-gateway.human-dev.io"] {
        hostname = "172.16.0.15";
        proxyJump = "ssh-gateway.human-dev.io";
      };

      "git.human.de".hostname = "git.human.de";
      "sentry.human.de".hostname = "167.235.55.186";
      "nix-01.human-dev.io".user = "root";
    };
  };
}
