{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.custom.authentik;
in {
  options.custom.authentik = {
    enable = lib.mkEnableOption "Enable authentik";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "sso.mnzn.dev";
      description = "Domain for authentik";
    };
  };

  imports = [
    inputs.authentik-nix.nixosModules.default
  ];

  config = lib.mkIf cfg.enable {
    age.secrets = {
      authentikEnvironment = {
        file = ../../../secrets/authentikEnvironment.age;
      };
    };

    services.authentik = {
      enable = true;
      environmentFile = config.age.secrets.authentikEnvironment.path;
      settings = {
        disable_startup_analytics = true;
        avatars = "initials";
      };
      nginx = {
        enable = true;
        enableACME = true;
        host = cfg.domain;
      };
    };
  };
}