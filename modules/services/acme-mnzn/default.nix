{
  config,
  lib,
  pkgs,
  inputs,
  systemConfig,
  ...
}: let
  cfg = config.meenzen.services.acme-mnzn;
in {
  options.meenzen.services.acme-mnzn = {
    enable = lib.mkEnableOption "Enable ACME for mnzn.dev";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "mnzn.dev";
      description = "Domain for ACME";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      acmeMnznEnvironment = {
        file = "${inputs.self}/secrets/acmeMnznEnvironment.age";
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = systemConfig.user.email;
        # Hell yeah, we absolutely want short-lived certs!
        # https://letsencrypt.org/docs/profiles/#shortlived
        profile = "shortlived";
        renewInterval = "6h";
        renewJitter = "1h";
      };
      certs."${cfg.domain}" = {
        domain = cfg.domain;
        extraDomainNames = ["*.${cfg.domain}"];
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        environmentFile = config.age.secrets.acmeMnznEnvironment.path;
      };
    };

    users.users.nginx.extraGroups = ["acme"];
  };
}
