{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.mastodon;
in {
  options.custom.mastodon = {
    enable = lib.mkEnableOption "Enable Mastodon Server";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "social.meenzen.net";
      description = "Domain for profile-management";
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
  };
}
