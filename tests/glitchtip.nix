(import ./lib.nix)
{
  name = "glitchtip";
  nodes = {
    machine = {
      pkgs,
      lib,
      modules,
      ...
    }: {
      imports = [
        modules
      ];

      meenzen = {
        test-setup.enable = true;
        services.glitchtip.enable = true;
      };

      services.glitchtip.environmentFiles = lib.mkForce [
        (pkgs.writeText "glitchtipEnvironment" ''
          SECRET_KEY=verysecretkey
          EMAIL_URL=smtp+tls://glitchtip@example:password@mail.example:587
          DEFAULT_FROM_EMAIL=GlitchTip <glitchtip@example>
          AWS_ACCESS_KEY_ID=foobar
          AWS_SECRET_ACCESS_KEY=foobar
          AWS_STORAGE_BUCKET_NAME=foo
          AWS_S3_ENDPOINT_URL=https://foo.example
        '')
      ];
    };
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("nginx.service")
    machine.wait_for_open_port(443)
    machine.wait_for_unit("postgresql.service")
    machine.wait_for_unit("glitchtip.service")
    machine.wait_for_unit("glitchtip-worker.service")
    machine.wait_until_succeeds("curl --insecure --fail --header 'Host: glitch.mnzn.dev' https://127.0.0.1/")
  '';
}
