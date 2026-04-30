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
    # GlitchTip currently breaks when using redis, so it its disabled for now.
    enableRedis = lib.mkEnableOption "Enable Redis for GlitchTip";
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
      redis.createLocally = cfg.enableRedis;
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
        # If this is not set to an empty string, it will try to connect to the docker default "redis://valkey:6379"
        VALKEY_URL = lib.mkIf (!cfg.enableRedis) "";
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
    };
  };
}
