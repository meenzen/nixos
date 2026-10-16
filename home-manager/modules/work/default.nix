{
  config,
  lib,
  pkgs,
  ...
}: let
  dmz = "ssh-gateway-dmz.human-dev.io";
  comline = "ssh-gateway-comline.human-dev.io";

  # Hosts reached through a Cloudflare Zero Trust SSH gateway, as alias = address
  gatewayHosts = {
    ${dmz} = {
      nixp01 = "172.16.0.204";
      nixos-proxy-01 = "192.168.155.26";
      nixos-proxy-02 = "192.168.155.27";
      nixos-app-01 = "192.168.155.28";
      nixos-app-02 = "192.168.155.29";
    };
    ${comline} = {
      comline-nixp01 = "pber2sawv330113.human2.de";
      comline-nixos-proxy-01 = "pber2swbv330111.human2.de";
      comline-nixos-proxy-02 = "pber2swbv330112.human2.de";
      comline-nixos-app-01 = "pber2sawv330109.human2.de";
      comline-nixos-app-02 = "pber2sawv330110.human2.de";
    };
  };

  # Each host is reachable by its alias and by its address
  gatewayEntries = lib.concatMapAttrs (gateway:
    lib.concatMapAttrs (alias: hostname: let
      entry = lib.hm.dag.entryAfter [gateway] {
        inherit hostname;
        proxyJump = gateway;
      };
    in {
      ${alias} = entry;
      ${hostname} = entry;
    }))
  gatewayHosts;

  cloudflaredProxy = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
in {
  options.meenzen.work.enable = lib.mkEnableOption "work SSH hosts";

  config = lib.mkIf config.meenzen.work.enable {
    # cloudflared is required for tunneling through Cloudflare Zero Trust
    home.packages = [pkgs.cloudflared];

    programs.ssh.settings =
      {
        ${dmz}.proxyCommand = cloudflaredProxy;
        ${comline}.proxyCommand = cloudflaredProxy;

        "git.human.de".hostname = "git.human.de";
        "sentry.human.de".hostname = "sentry.human.de";
        "nix-01.human-dev.io".hostname = "nix-01.human-dev.io";
      }
      // gatewayEntries;
  };
}
