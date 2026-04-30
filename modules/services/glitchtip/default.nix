{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.glitchtip;
in {
  options.meenzen.services.glitchtip = {
    enable = lib.mkEnableOption "Enable GlitchTip";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "glitch.mnzn.dev";
      description = "Domain for GlitchTip";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8095;
      description = "Local port for GlitchTip";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      glitchtipEnvironment = {
        file = "${inputs.self}/secrets/glitchtipEnvironment.age";
      };
    };

    meenzen.backup.paths = [config.services.glitchtip.stateDir];

    services.glitchtip = {
      enable = true;
      environmentFiles = [config.age.secrets.glitchtipEnvironment.path];
      nginx = {
        createLocally = true;
        domain = cfg.domain;
      };
      settings = {
        GRANIAN_PORT = cfg.port;
        I_PAID_FOR_GLITCHTIP = "true";
        SECURE_HSTS_SECONDS = "31536000";
        SECURE_HSTS_PRELOAD = "true";
        GLITCHTIP_ENABLE_DUCKDB = "true";
        DEFAULT_FILE_STORAGE = "storages.backends.s3boto3.S3Boto3Storage";
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
    };
  };
}
