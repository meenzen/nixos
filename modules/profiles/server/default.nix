{
  config,
  lib,
  secrets,
  ...
}: let
  cfg = config.meenzen.profiles.server;
in {
  options.meenzen.profiles.server = {
    enable = lib.mkEnableOption "Enable Server Mode";
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      hashedPassword.file = "${secrets}/hashedPassword.age";
    };

    networking.firewall.enable = lib.mkForce true;

    # Don't require a password for sudo
    security.sudo.wheelNeedsPassword = false;
    security.sudo-rs.wheelNeedsPassword = false;

    users = {
      # Always overwrite manually configured users
      mutableUsers = lib.mkForce false;
      users = {
        root.hashedPasswordFile = lib.mkForce config.age.secrets.hashedPassword.path;
        "${config.meenzen.user.username}" = {
          initialPassword = lib.mkForce null;
          hashedPassword = lib.mkForce "!";
        };
      };
    };

    meenzen = {
      auto-upgrade = {
        enable = true;
        allowReboot = true;
      };
      services.attic = {
        client.enable = true;
        substituters.enable = true;
      };
    };
  };
}
