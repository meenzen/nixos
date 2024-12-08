{pkgs, ...}: {
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
      failregex = ^<HOST> - .* "-" ".*(trendictionbot|SemrushBot|AhrefsBot|ClaudeBot|MJ12bot|Bytespider|DataForSeoBot|GPTBot|magpie-crawler|barkrowler|DotBot|SenutoBot|semantic-visions\.com).*"$
      ignoreregex =
    '');
  };
}
