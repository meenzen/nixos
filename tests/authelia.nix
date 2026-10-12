(import ./lib.nix)
{
  name = "authelia";
  nodes = {
    machine = {
      config,
      pkgs,
      lib,
      modules,
      ...
    }: let
      user = config.services.authelia.instances.main.user;

      secretsDir = "/var/lib/authelia-test-secrets";
      secret = name: pkgs.writeText name "${name}-0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";

      oidcIssuerPrivateKey = pkgs.runCommand "autheliaOidcIssuerPrivateKey" {nativeBuildInputs = [pkgs.openssl];} ''
        openssl genrsa -out $out 2048
      '';

      secretFiles = {
        storageEncryptionKeyFile = secret "autheliaStorageEncryptionKey";
        sessionSecretFile = secret "autheliaSessionSecret";
        oidcIssuerPrivateKeyFile = oidcIssuerPrivateKey;
        oidcHmacSecretFile = secret "autheliaOidcHmacSecret";
        jwtSecretFile = secret "autheliaJwtSecret";
      };

      passwordHash = pkgs.runCommand "authelia-password-hash" {nativeBuildInputs = [pkgs.authelia];} ''
        authelia crypto hash generate argon2 --password test --no-confirm | sed 's/^Digest: //' > $out
      '';

      users = pkgs.writeText "users.yml" ''
        users:
          test:
            displayname: Test
            email: test@mnzn.dev
            password: "${lib.removeSuffix "\n" (builtins.readFile passwordHash)}"
      '';

      settings = pkgs.writeText "autheliaTestSettings.yml" ''
        notifier:
          filesystem:
            filename: /var/lib/authelia-main/notifications.txt
        identity_providers:
          oidc:
            clients:
              - client_id: test
                client_name: Test
                public: true
                authorization_policy: one_factor
                redirect_uris:
                  - https://app.mnzn.dev/callback
                scopes:
                  - openid
      '';
    in {
      imports = [
        modules
      ];

      virtualisation.memorySize = 2048;

      meenzen = {
        test-setup.enable = true;
        services.authelia.enable = true;
      };

      # The authelia module rejects secret files in the Nix store, so copy them out of it.
      services.authelia.instances.main = {
        secrets = lib.mapAttrs (name: _: lib.mkForce "${secretsDir}/${name}") secretFiles;
        settingsFiles = lib.mkForce [settings];
      };

      systemd.tmpfiles.settings.authelia-test =
        lib.mapAttrs' (name: file:
          lib.nameValuePair "${secretsDir}/${name}" {
            "C+" = {
              argument = toString file;
              inherit user;
              group = user;
              mode = "0400";
            };
          })
        secretFiles
        // {
          "/var/lib/authelia-main/users.yml"."C+" = {
            argument = toString users;
            inherit user;
            group = user;
            mode = "0600";
          };
        };
    };
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("postgresql.service")
    machine.wait_for_unit("redis-authelia-main.service")
    machine.wait_for_unit("authelia-main.service")
    machine.wait_for_unit("nginx.service")
    machine.wait_for_open_port(443)

    curl = "curl --insecure --fail --silent --show-error --resolve login.mnzn.dev:443:127.0.0.1"
    machine.wait_until_succeeds(f"{curl} https://login.mnzn.dev/api/health")
    machine.succeed(f"{curl} https://login.mnzn.dev/ | grep -i authelia")
    machine.succeed(f"{curl} https://login.mnzn.dev/.well-known/openid-configuration | grep -F '\"issuer\":\"https://login.mnzn.dev\"'")

    # Logging in stores the session in redis and the authentication log in postgres.
    machine.succeed(
        f"{curl} --header 'Content-Type: application/json' "
        + "--data '{\"username\":\"test\",\"password\":\"test\"}' "
        + "https://login.mnzn.dev/api/firstfactor | grep -F '\"status\":\"OK\"'"
    )
  '';
}
