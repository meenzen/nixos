{
  config,
  lib,
  ...
}: let
  cfg = config.meenzen.test-setup;
in {
  options.meenzen.test-setup = {
    enable = lib.mkEnableOption "Enable Test Setup";
  };

  config = lib.mkIf cfg.enable {
    users.users.root.hashedPassword = lib.mkForce null;
    meenzen.nginx.disableLetsEncrypt = true;
  };
}
