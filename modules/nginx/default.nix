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
    // lib.optionalAttrs cfg.enableCloudflare {
      # Use real IP addresses for requests from Cloudflare
      commonHttpConfig = let
        realIpsFromList = lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
        fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
        cfipv4 = fileToList (pkgs.fetchurl {
          url = "https://www.cloudflare.com/ips-v4";
          sha256 = "sha256-8Cxtg7wBqwroV3Fg4DbXAMdFU1m84FTfiE5dfZ5Onns=";
        });
        cfipv6 = fileToList (pkgs.fetchurl {
          url = "https://www.cloudflare.com/ips-v6";
          sha256 = "sha256-np054+g7rQDE3sr9U8Y/piAp89ldto3pN9K+KCNMoKk=";
        });
      in ''
        ${realIpsFromList cfipv4}
        ${realIpsFromList cfipv6}
        real_ip_header CF-Connecting-IP;
      '';
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
    enableCloudflare = lib.mkEnableOption "Enable Cloudflare settings";
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
    meenzen.nginx-badbots.enable = true;

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

    environment.systemPackages = [
      (
        pkgs.writeScriptBin "nginx-goaccess" ''
          set -e
          ${pkgs.goaccess}/bin/goaccess --log-format=COMBINED /var/log/nginx/access.log /var/log/nginx/access.log.1 $@
        ''
      )
      (
        pkgs.writeScriptBin "nginx-goaccess-all" ''
          set -e
          ${pkgs.gzip}/bin/zcat -f /var/log/nginx/access.log.* | ${pkgs.goaccess}/bin/goaccess --log-format=COMBINED /var/log/nginx/access.log $@
        ''
      )
    ];
  };
}
