{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.mastodon;
in {
  options.meenzen.mastodon = {
    enable = lib.mkEnableOption "Enable Mastodon Server";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "social.meenzen.net";
      description = "Domain for Mastodon";
    };
    cdnDomain = lib.mkOption {
      type = lib.types.str;
      default = "cdn.social.meenzen.net";
      description = "Domain for proxied media files";
    };
    cdnBucketDomain = lib.mkOption {
      type = lib.types.str;
      default = "fsn1.your-objectstorage.com";
      description = "Domain for media files";
    };
    cdnBucketName = lib.mkOption {
      type = lib.types.str;
      default = "mastodon-cdn";
      description = "Name of the bucket for media files";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      mastodonEmailPassword = {
        file = ../../../secrets/mastodonEmailPassword.age;
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonSecretKeyBase = {
        file = ../../../secrets/mastodonSecretKeyBase.age;
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonOtpSecret = {
        file = ../../../secrets/mastodonOtpSecret.age;
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonVapidPublicKey = {
        file = ../../../secrets/mastodonVapidPublicKey.age;
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonVapidPrivateKey = {
        file = ../../../secrets/mastodonVapidPrivateKey.age;
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonActiveRecordPrimaryKey = {
        file = ../../../secrets/mastodonActiveRecordPrimaryKey.age;
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonActiveRecordDeterministicKey = {
        file = ../../../secrets/mastodonActiveRecordDeterministicKey.age;
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonActiveRecordSalt = {
        file = ../../../secrets/mastodonActiveRecordSalt.age;
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonS3Config = {
        file = ../../../secrets/mastodonS3Config.age;
        owner = "mastodon";
        group = "mastodon";
      };
    };

    services.mastodon = {
      enable = true;
      localDomain = cfg.domain;
      configureNginx = true;
      extraConfig = {
        SINGLE_USER_MODE = "false";
        DEFAULT_LOCALE = "de";
      };
      webProcesses = 1;
      streamingProcesses = 1;
      sidekiqThreads = 10;
      secretKeyBaseFile = config.age.secrets.mastodonSecretKeyBase.path;
      otpSecretFile = config.age.secrets.mastodonOtpSecret.path;
      vapidPublicKeyFile = config.age.secrets.mastodonVapidPublicKey.path;
      vapidPrivateKeyFile = config.age.secrets.mastodonVapidPrivateKey.path;
      activeRecordEncryptionPrimaryKeyFile = config.age.secrets.mastodonActiveRecordPrimaryKey.path;
      activeRecordEncryptionKeyDerivationSaltFile = config.age.secrets.mastodonActiveRecordSalt.path;
      activeRecordEncryptionDeterministicKeyFile = config.age.secrets.mastodonActiveRecordDeterministicKey.path;
      extraEnvFiles = [
        config.age.secrets.mastodonS3Config.path
      ];
      smtp = {
        createLocally = false;
        fromAddress = "Mastodon <mastodon@meenzen.net>";
        authenticate = true;
        host = "mail.meenzen.net";
        port = 587;
        user = "all@meenzen.net";
        passwordFile = config.age.secrets.mastodonEmailPassword.path;
      };
      mediaAutoRemove = {
        enable = true;
        startAt = "daily";
        olderThanDays = 14;
      };
    };

    environment.systemPackages = [
      (
        pkgs.writeScriptBin "mastodon-cleanup" ''
          set -eux

          mastodon-tootctl media remove --days 14
          mastodon-tootctl statuses remove --days 14
          mastodon-tootctl preview-cards remove --days 14
          mastodon-tootctl accounts prune
          mastodon-tootctl media remove --prune-profiles --days 14
        ''
      )
    ];

    # Adapted from this excellent guide: https://stanislas.blog/2018/05/moving-mastodon-media-files-to-wasabi-object-storage/
    services.nginx = {
      proxyCachePath."mastodon" = {
        enable = true;
        levels = "1:2";
        maxSize = "1g";
        inactive = "24h";
        keysZoneSize = "100m";
        keysZoneName = "mastodon_media";
      };
      virtualHosts."${cfg.cdnDomain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/${cfg.cdnBucketName}/" = {
          recommendedProxySettings = false;
          proxyPass = "https://${cfg.cdnBucketDomain}/${cfg.cdnBucketName}/";
          extraConfig = ''
            limit_except GET {
              deny all;
            }

            add_header Cache-Control public;
            add_header "Access-Control-Allow-Origin" "*";
            add_header X-Cached $upstream_cache_status;
            add_header X-Content-Type-Options nosniff;
            add_header Content-Security-Policy "default-src 'none'; form-action 'none'";

            proxy_set_header Host ${cfg.cdnBucketDomain};
            proxy_set_header Connection "";
            proxy_set_header Authorization "";
            proxy_hide_header Set-Cookie;
            proxy_hide_header "Access-Control-Allow-Origin";
            proxy_hide_header "Access-Control-Allow-Methods";
            proxy_hide_header "Access-Control-Allow-Headers";
            proxy_hide_header x-amz-id-2;
            proxy_hide_header x-amz-request-id;
            proxy_hide_header x-amz-meta-server-side-encryption;
            proxy_hide_header x-amz-server-side-encryption;
            proxy_hide_header x-amz-bucket-region;
            proxy_hide_header x-amzn-requestid;
            proxy_hide_header x-debug-backend;
            proxy_hide_header x-debug-bucket;
            proxy_hide_header x-rgw-object-type;
            proxy_ignore_headers Set-Cookie;
            proxy_intercept_errors off;
            proxy_cache mastodon_media;
            proxy_cache_revalidate on;
            proxy_buffering on;
            proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
            proxy_cache_background_update on;
            proxy_cache_lock on;
            proxy_cache_valid 1d;
            proxy_cache_valid 404 1h;
            proxy_ignore_headers Cache-Control;
          '';
        };
      };
    };
  };
}
