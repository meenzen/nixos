{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.meenzen.distributed-build;
in {
  config = lib.mkIf cfg.enableHost {
    users.groups."${cfg.user}" = {};
    users.users."${cfg.user}" = {
      isNormalUser = true;
      createHome = true;
      description = "Nix distributed build user";
      group = cfg.user;
      hashedPassword = "*";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF40v6Sj2WUopjyFaKZ5KFRv8FK3H1pJt6SxoRruENXo root@framework"
      ];
    };
    nix.settings.trusted-users = [cfg.user];
  };
}
