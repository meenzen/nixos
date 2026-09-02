{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.services.glitchtip;

  # GlitchTip explicitly calls conn.load_extension("httpfs") without installing it first, and
  # nixpkgs' duckdb doesn't build httpfs in (it's normally fetched from git at build time, which
  # doesn't work in the Nix sandbox). Fetch the pinned source ourselves and build it in statically.
  duckdbHttpfsSrc = pkgs.fetchFromGitHub {
    owner = "duckdb";
    repo = "duckdb-httpfs";
    # Find the pinned commit in the nixpkgs duckdb package:
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/du/duckdb/versions.json
    # Then grab the extension revision from here using the commit hash:
    # https://github.com/carlopi/duckdb/blob/d8cdaa33fda8df955cc76ef58a280f68f4cd43fa/.github/config/extensions/httpfs.cmake
    rev = "827222fb45a043a7a852d1f7aae46901492a3cda";
    hash = "sha256-sUp7gHI7NzvNUdqpnODmpVgWb5gY0PsIqUXpnKuAzYw=";
  };
  glitchtipPackage = pkgs.glitchtip.overrideAttrs (old: {
    propagatedBuildInputs =
      map (
        drv:
          if (drv.pname or null) == "duckdb"
          then
            drv.overrideAttrs (duckdbOld: {
              buildInputs = (duckdbOld.buildInputs or []) ++ [pkgs.curl];
              cmakeFlags =
                (duckdbOld.cmakeFlags or [])
                ++ [(lib.cmakeFeature "BUILD_EXTENSIONS" "core_functions;json;parquet;icu;httpfs")];
              env =
                (duckdbOld.env or {})
                // {
                  DUCKDB_HTTPFS_DIRECTORY = "${duckdbHttpfsSrc}";
                };
            })
          else drv
      )
      old.propagatedBuildInputs;
  });
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
      package = glitchtipPackage;
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
      useACMEHost = "mnzn.dev";
      forceSSL = true;
      extraConfig = ''
        add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
      '';
    };
  };
}
