{
  config,
  lib,
  pkgs,
  systemConfig,
  ...
}: let
  cfg = config.meenzen.nginx-badbots;
  regexEscape = str: builtins.replaceStrings [''.''] [''\.''] str;
  userAgents = [
    # Marketing / SEO bots
    "AhrefsBot"
    "barkrowler"
    "DataForSeoBot"
    "DotBot"
    "magpie-crawler"
    "MJ12bot"
    "semantic-visions.com"
    "SemrushBot"
    "SenutoBot"
    "trendictionbot"

    # AI bots can fuck off, they are not welcome here.
    "ClaudeBot"
    "GPTBot"

    # Ban Facebook for scraping forge.mnzn.dev which does not allow scraping.
    "meta-externalagent"

    # TikTok
    "Bytespider"
  ];
  userAgentsEscaped = map regexEscape userAgents;
  userAgentsCombined = lib.concatStringsSep "|" userAgentsEscaped;
in {
  options.meenzen.nginx-badbots = {
    enable = lib.mkEnableOption "Block Bad Crawlers";
  };

  config = lib.mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      jails = {
        nginx-badbots.settings = {
          enabled = true;
          filter = "nginx-badbots";
          logpath = "/var/log/nginx/access.log";
          action = ''%(action_)s[blocktype=DROP]'';
          backend = "auto";
          maxretry = 1;
          findtime = 600;
          bantime = 86400;
        };
      };
    };

    environment.etc = {
      "fail2ban/filter.d/nginx-badbots.local".text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
        [Definition]
        failregex = ^<HOST> - .* "-" ".*(${userAgentsCombined}).*"$
        ignoreregex =
      '');
    };
  };
}
