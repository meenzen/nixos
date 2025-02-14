{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.mastodon;

  tootctl = "/run/current-system/sw/bin/mastodon-tootctl";
  cleanupScriptName = "mastodon-cleanup";

  cleanupScript = (
    pkgs.writeScriptBin cleanupScriptName ''
      set -eux

      cd /var/lib/mastodon

      ${tootctl} media remove --days ${toString cfg.cleanupDays}
      ${tootctl} media remove --prune-profiles --days ${toString cfg.cleanupDays}
      ${tootctl} statuses remove --days ${toString cfg.cleanupDays}
      ${tootctl} preview-cards remove --days ${toString cfg.cleanupDays}
    ''
  );
in {
  options.meenzen.mastodon = {
    enable = lib.mkEnableOption "Enable Mastodon Server";
    enableSearch = lib.mkEnableOption "Enable Search, run 'mastodon-tootctl search deploy' after enabling";
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
      default = "hel1.your-objectstorage.com";
      description = "Domain for media files";
    };
    cdnBucketName = lib.mkOption {
      type = lib.types.str;
      default = "meenzen-mastodon";
      description = "Name of the bucket for media files";
    };
    cleanupDays = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = "Days after which unnecessary data is removed";
    };
  };
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (
        final: prev: {
          mastodon = prev.mastodon.overrideAttrs (oldAttrs: {
            patches =
              (oldAttrs.patches or [])
              ++ [
                ./limits.patch
              ];
          });
        }
      )
    ];

    age.secrets = {
      mastodonEmailPassword = {
        file = "${inputs.self}/secrets/mastodonEmailPassword.age";
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonSecretKeyBase = {
        file = "${inputs.self}/secrets/mastodonSecretKeyBase.age";
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonOtpSecret = {
        file = "${inputs.self}/secrets/mastodonOtpSecret.age";
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonVapidPublicKey = {
        file = "${inputs.self}/secrets/mastodonVapidPublicKey.age";
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonVapidPrivateKey = {
        file = "${inputs.self}/secrets/mastodonVapidPrivateKey.age";
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonActiveRecordPrimaryKey = {
        file = "${inputs.self}/secrets/mastodonActiveRecordPrimaryKey.age";
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonActiveRecordDeterministicKey = {
        file = "${inputs.self}/secrets/mastodonActiveRecordDeterministicKey.age";
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonActiveRecordSalt = {
        file = "${inputs.self}/secrets/mastodonActiveRecordSalt.age";
        owner = "mastodon";
        group = "mastodon";
      };
      mastodonS3Config = {
        file = "${inputs.self}/secrets/mastodonS3Config.age";
        owner = "mastodon";
        group = "mastodon";
      };
    };

    meenzen.backup.paths = ["/var/lib/mastodon"];

    services.mastodon = {
      enable = true;
      localDomain = cfg.domain;
      configureNginx = true;
      extraConfig = {
        SINGLE_USER_MODE = "false";
        DEFAULT_LOCALE = "de";

        S3_OPEN_TIMEOUT = "10";
        S3_READ_TIMEOUT = "10";
        S3_ENABLED = "true";
        S3_BUCKET = cfg.cdnBucketName;
        S3_PROTOCOL = "https";
        S3_ENDPOINT = "https://${cfg.cdnBucketDomain}/";
        S3_HOSTNAME = cfg.cdnDomain;
        S3_ALIAS_HOST = cfg.cdnDomain;
        S3_SIGNATURE_VERSION = "v4";
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
        enable = false; # This is already handled by the cleanup script
        startAt = "daily";
        olderThanDays = cfg.cleanupDays;
      };

      elasticsearch.host =
        if cfg.enableSearch
        then "localhost"
        else null;
    };

    services.opensearch.enable = cfg.enableSearch;
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.enableSearch [9200];

    environment.systemPackages = [
      cleanupScript
    ];
    systemd.timers."${cleanupScriptName}" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
    systemd.services."${cleanupScriptName}" = {
      requires = ["mastodon-web.service"];
      script = ''
        ${cleanupScript}/bin/${cleanupScriptName}
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };

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
        locations."/" = {
          recommendedProxySettings = false;
          proxyPass = "https://${cfg.cdnBucketName}.${cfg.cdnBucketDomain}/";
          extraConfig = ''
            limit_except GET {
              deny all;
            }

            add_header Cache-Control public;
            add_header "Access-Control-Allow-Origin" "*";
            add_header X-Cached $upstream_cache_status;
            add_header X-Content-Type-Options nosniff;
            add_header Content-Security-Policy "default-src 'none'; form-action 'none'";

            proxy_set_header Host ${cfg.cdnBucketName}.${cfg.cdnBucketDomain};
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
