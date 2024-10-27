{
  config,
  lib,
  pkgs,
  systemConfig,
  ...
}: let
  cfg = config.custom.nginx;

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
  options.custom.nginx = {
    enable = lib.mkEnableOption "Enable common Nginx settings";
    testPage = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Hostname of the test page";
      example = "hostname.example.com";
    };
    allowIndexing = lib.mkEnableOption "Allow search engines to crawl websites hosted on this server";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];
    networking.firewall.allowedUDPPorts = [443];

    services.nginx = nginxConfig;

    security.acme = {
      acceptTerms = true;
      defaults.email = systemConfig.user.email;
    };

    environment.etc = {
      # Block URL probing
      "fail2ban/filter.d/nginx-url-probe.local".text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
        [Definition]
        failregex = ^<HOST>.*(GET /(wp-|admin|boaform|phpmyadmin|\.env|\.git)|\.(dll|so|cfm|asp)|(\?|&)(=PHPB8B5F2A0-3C92-11d3-A3A9-4C7B08C10000|=PHPE9568F36-D428-11d2-A769-00AA001ACF42|=PHPE9568F35-D428-11d2-A769-00AA001ACF42|=PHPE9568F34-D428-11d2-A769-00AA001ACF42)|\\x[0-9a-zA-Z]{2})
      '');

      # Block IPs that fail to authenticate using basic authentication
      "fail2ban/filter.d/nginx-auth.local".text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
        [Definition]
        failregex = no user/password was provided for basic authentication.*client: <HOST>
        user .* was not found in.*client: <HOST>
        user .* password mismatch.*client: <HOST>
        ignoreregex =
      '');

      # Block IPs trying to use server as proxy.
      #
      # Matches e.g.
      # 192.168.1.1 - - "GET http://www.something.com/
      "fail2ban/filter.d/nginx-proxy.local".text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
        [Definition]
        failregex = ^<HOST> -.*GET http.*
        ignoreregex =
      '');

      # Block IPs trying to execute scripts such as .php, .pl, .exe and other funny scripts.
      #
      # Matches e.g.
      # 192.168.1.1 - - "GET /something.php
      "fail2ban/filter.d/nginx-noscript.local".text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
        [Definition]
        failregex = ^<HOST> -.*GET.*(\.php|\.asp|\.exe|\.pl|\.cgi|\scgi)
        ignoreregex =
      '');
    };

    services.fail2ban = {
      jails = {
        ngnix-url-probe.settings = {
          # causes false positives
          enabled = false;
          filter = "nginx-url-probe";
          logpath = "/var/log/nginx/access.log";
          action = ''%(action_)s[blocktype=DROP]'';
          backend = "auto";
          maxretry = 5;
          findtime = 600;
        };

        nginx-badbots.settings = {
          enabled = true;
          filter = "apache-badbots";
          logpath = "/var/log/nginx/access.log";
          action = ''%(action_)s[blocktype=DROP]'';
          backend = "auto";
          bantime = 86400; # 1 day
          maxretry = 1;
        };

        nginx-auth.settings = {
          enabled = true;
          filter = "nginx-auth";
          logpath = "/var/log/nginx/error.log";
          action = ''%(action_)s[blocktype=DROP]'';
          backend = "auto";
          bantime = 600; # 10 minutes
          maxretry = 6;
        };

        nginx-proxy.settings = {
          enabled = true;
          filter = "nginx-proxy";
          logpath = "/var/log/nginx/access.log";
          action = ''%(action_)s[blocktype=DROP]'';
          backend = "auto";
          bantime = 86400; # 1 day
          maxretry = 0;
        };

        nginx-noscript.settings = {
          enabled = true;
          filter = "nginx-noscript";
          logpath = "/var/log/nginx/access.log";
          action = ''%(action_)s[blocktype=DROP]'';
          backend = "auto";
          bantime = 86400; # 1 day
          maxretry = 6;
        };
      };
    };
  };
}
