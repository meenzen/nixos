{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.meenzen.backup;
in {
  options.meenzen.backup = {
    enable = lib.mkEnableOption "Enable backup";
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = [
        "/var/lib/postgresql"
        "/home/user/backup"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      resticEnv.file = "${inputs.self}/secrets/resticEnv.age";
      resticRepository.file = "${inputs.self}/secrets/resticRepository.age";
      resticPassword.file = "${inputs.self}/secrets/resticPassword.age";
    };

    services.restic.backups = {
      daily = {
        initialize = true;

        environmentFile = config.age.secrets.resticEnv.path;
        repositoryFile = config.age.secrets.resticRepository.path;
        passwordFile = config.age.secrets.resticPassword.path;

        exclude = [
          "/var/cache"
          ".cache"
          ".tmp"
          ".log"
        ];

        paths =
          [
            "/etc/group"
            "/etc/machine-id"
            "/etc/passwd"
            "/etc/ssh"
            "/etc/subgid"
            "/etc/subuid"
            "/var/lib/nixos"
            "/home"
            "/root"
          ]
          ++ cfg.paths;

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 3"
        ];
      };
    };
  };
}
