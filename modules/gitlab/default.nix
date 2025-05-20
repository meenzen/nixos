{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.gitlab;
  serviceName = "gitlab";
in {
  options.meenzen.gitlab = {
    enable = lib.mkEnableOption "Enable GitLab";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "git.mnzn.dev";
      description = "Domain for GitLab";
    };
  };

  imports = [
    ./registry.nix
  ];

  config = lib.mkIf cfg.enable {
    meenzen.gitlab.registry.enable = true;

    age.secrets = {
      gitlabSecret = {
        file = "${inputs.self}/secrets/gitlabSecret.age";
        owner = serviceName;
        group = serviceName;
      };
      gitlabOtpSecret = {
        file = "${inputs.self}/secrets/gitlabOtpSecret.age";
        owner = serviceName;
        group = serviceName;
      };
      gitlabDbSecret = {
        file = "${inputs.self}/secrets/gitlabDbSecret.age";
        owner = serviceName;
        group = serviceName;
      };
      gitlabJwsSecret = {
        file = "${inputs.self}/secrets/gitlabJwsSecret.age";
        owner = serviceName;
        group = serviceName;
      };
      gitlabRootPassword = {
        file = "${inputs.self}/secrets/gitlabRootPassword.age";
        owner = serviceName;
        group = serviceName;
      };
      gitlabDatabasePassword = {
        file = "${inputs.self}/secrets/gitlabDatabasePassword.age";
        owner = serviceName;
        group = serviceName;
      };
      gitlabActiveRecordPrimaryKey = {
        file = "${inputs.self}/secrets/gitlabActiveRecordPrimaryKey.age";
        owner = serviceName;
        group = serviceName;
      };
      gitlabActiveRecordDeterministicKey = {
        file = "${inputs.self}/secrets/gitlabActiveRecordDeterministicKey.age";
        owner = serviceName;
        group = serviceName;
      };
      gitlabActiveRecordSalt = {
        file = "${inputs.self}/secrets/gitlabActiveRecordSalt.age";
        owner = serviceName;
        group = serviceName;
      };
    };

    meenzen.backup.paths = ["/var/gitlab/state"];

    services.gitlab = {
      enable = true;
      https = true;
      host = cfg.domain;
      port = 443;

      databasePasswordFile = config.age.secrets.gitlabDatabasePassword.path;
      initialRootPasswordFile = config.age.secrets.gitlabRootPassword.path;
      secrets = {
        secretFile = config.age.secrets.gitlabSecret.path;
        otpFile = config.age.secrets.gitlabOtpSecret.path;
        dbFile = config.age.secrets.gitlabDbSecret.path;
        jwsFile = config.age.secrets.gitlabJwsSecret.path;
        activeRecordPrimaryKeyFile = config.age.secrets.gitlabActiveRecordPrimaryKey.path;
        activeRecordDeterministicKeyFile = config.age.secrets.gitlabActiveRecordDeterministicKey.path;
        activeRecordSaltFile = config.age.secrets.gitlabActiveRecordSalt.path;
      };

      # Example config: https://gitlab.com/gitlab-org/gitlab/blob/master/config/gitlab.yml.example
      extraConfig = {
        omniauth = {
          enabled = true;
          allow_single_sign_on = ["saml"];
          sync_email_from_provider = "saml";
          sync_profile_from_provider = ["saml"];
          sync_profile_attributes = ["email"];
          block_auto_created_users = false;
          auto_link_saml_user = true;
          providers = [
            {
              name = "saml";
              label = "Meenzen Auth";
              args = {
                assertion_consumer_service_url = "https://git.mnzn.dev/users/auth/saml/callback";
                idp_cert_fingerprint = "b7:71:00:c2:60:bb:4e:57:09:cb:ca:09:6c:ec:64:2d:da:76:5d:e4";
                idp_sso_target_url = "https://sso.mnzn.dev/application/saml/gitlab/sso/binding/redirect/";
                issuer = "https://git.mnzn.dev";
                name_identifier_format = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress";
                attribute_statements = {
                  email = ["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"];
                  first_name = ["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"];
                  nickname = ["http://schemas.goauthentik.io/2021/02/saml/username"];
                };
              };
            }
          ];
        };
      };
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
    };
  };
}
