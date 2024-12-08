{
  config,
  lib,
  pkgs,
  systemConfig,
  ...
}: let
  cfg = config.meenzen.nginx;

  nginxConfig =
    {
      enable = true;
      package = pkgs.nginxMainline;
      recommendedGzipSettings = true;
      recommendedBrotliSettings = true;
      recommendedZstdSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      clientMaxBodySize = "100m";
    }
    // lib.optionalAttrs (!cfg.allowIndexing) {
      appendHttpConfig = ''
        add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
      '';
    }
    // lib.optionalAttrs (cfg.testPage != "") {
      virtualHosts = {
        "${cfg.testPage}" = {
          enableACME = true;
          forceSSL = true;
        };
      };
    };
in {
  options.meenzen.nginx = {
    enable = lib.mkEnableOption "Enable common Nginx settings";
    testPage = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Hostname of the test page";
      example = "hostname.example.com";
    };
    allowIndexing = lib.mkEnableOption "Allow search engines to crawl websites hosted on this server";
  };

  imports = [
    ./nginx-badbots.nix
  ];

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];
    networking.firewall.allowedUDPPorts = [443];

    services.nginx = nginxConfig;

    security.acme = {
      acceptTerms = true;
      defaults.email = systemConfig.user.email;
    };
    meenzen.backup.paths = [
      "/var/lib/acme"
    ];
  };
}
