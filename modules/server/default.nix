{
  config,
  lib,
  pkgs,
  inputs,
  systemConfig,
  ...
}: let
  cfg = config.meenzen.server;
in {
  options.meenzen.server = {
    enable = lib.mkEnableOption "Enable Server Mode";
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      hashedPassword.file = "${inputs.self}/secrets/hashedPassword.age";
    };

    networking.firewall.enable = lib.mkForce true;

    security.sudo.wheelNeedsPassword = false;
    users = {
      # Always overwrite manually configured users
      mutableUsers = lib.mkForce false;
      users = {
        root.hashedPasswordFile = lib.mkForce config.age.secrets.hashedPassword.path;
        "${systemConfig.user.username}" = {
          initialPassword = lib.mkForce null;
          hashedPassword = lib.mkForce "!";
        };
      };
    };
  };
}
