{
  config,
  lib,
  options,
  ...
}: let
  cfg = config.meenzen.test-setup;
in {
  options.meenzen.test-setup = {
    enable = lib.mkEnableOption "Enable Test Setup";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        # The `testing` option is only declared by the NixOS test framework.
        assertion = options ? testing;
        message = "meenzen.test-setup.enable is set outside of a NixOS VM test. It disables Let's Encrypt and the root password, never enable it on a real host.";
      }
    ];

    users.users.root.hashedPassword = lib.mkForce null;
    meenzen.nginx.disableLetsEncrypt = true;
  };
}
